#import "../common.typ": *

= Chapter 6. Systematic Literature Review (SLR) Support in R

#learning-objectives((
  [Document a search strategy reproducibly, including the exact Boolean strings run in each database, per PRISMA-S expectations.],
  [Deduplicate multi-database reference exports and run a documented, agreement-checked two-stage screening workflow.],
  [Build a PRISMA 2020 flow diagram in R directly from the counts produced by the screening pipeline, not typed by hand.],
  [Design a structured data extraction template and a programmatic dual-extraction reconciliation workflow.],
  [Produce Cochrane RoB 2.0 / ROBINS-I traffic-light and summary plots with `robvis`.],
  [Use text mining to prioritise abstract screening order without weakening Cochrane's dual-independent-screening requirement.],
))

Chapter 5 closed by flagging publication bias as a threat you mostly *detect* statistically, after the evidence is already assembled — funnel plots, Egger's test, trial-registry cross-checks. This chapter is about the earlier stage: building the evidence pool itself in a way that is transparent, reproducible, and auditable from the first search string to the final included-study count. Every one of the workflows below follows the same discipline already familiar from this book's R habits — log everything to a data frame, version it, and let the numbers that end up in a report trace back to a line of code rather than a remembered tally.

== 6.1 Search strategy documentation

A systematic review lives or dies on whether its search is reproducible. Chapter 5 flagged publication bias as a threat you detect statistically (funnel plots, Egger's test) only *after* the evidence is in hand; the search strategy is where you try to prevent that bias from ever entering the pool, by casting a wide, documented net across databases rather than relying on whatever your usual PubMed habits surface. PRISMA-S, the search-reporting extension to PRISMA 2020, asks for exactly this: database name, platform/interface, full Boolean string, date range, limits applied, and date run, for every source searched — not just the final count you remember.

There's no reason to keep this in a Word table that drifts out of sync with what you actually ran. A tibble, version-controlled alongside your analysis code, does the job better and survives an audit.

```r
library(tibble)
library(readr)
library(dplyr)

search_log <- tibble(
  database     = c("PubMed", "Embase", "Cochrane CENTRAL"),
  platform     = c("PubMed.gov", "Ovid", "Cochrane Library"),
  search_string = c(
    '("tuberculosis"[MeSH] OR "TB"[tiab]) AND ("economic evaluation"[tiab] OR "cost-effectiveness"[tiab])',
    'exp Tuberculosis/ AND (economic evaluation/ OR "cost effectiveness".ti,ab.)',
    'tuberculosis AND (cost-effectiveness OR "economic evaluation"):ti,ab,kw'
  ),
  date_from    = as.Date(c("2010-01-01", "2010-01-01", "2010-01-01")),
  date_to      = as.Date(rep("2024-06-30", 3)),
  date_run     = as.Date(rep(Sys.Date(), 3)),
  n_hits       = c(1842, 1365, 211),
  limits       = c("English; Humans", "English; Humans", "English")
)

write_csv(search_log, "search_strategy_log.csv")
search_log
```

Keep the raw string exactly as pasted from the database interface — don't "clean it up" for readability. If a reviewer needs to re-run the search in two years, the string in your CSV has to be the string that actually produced those 1,842 hits, syntax quirks and all.

#report-table(
  [Search strategy summary by database, as reported in an SLR methods section or PRISMA-S search appendix],
  academic-table(
    columns: (1.1fr, 1fr, 1fr, auto),
    align: (left, left, left, right),
    header: ([*Database*], [*Platform*], [*Limits applied*], [*N hits*]),
    body: (
      [PubMed], [PubMed.gov], [English; Humans], [1,842],
      [Embase], [Ovid], [English; Humans], [1,365],
      [Cochrane CENTRAL], [Cochrane Library], [English], [211],
    ),
    footer: (table.cell(colspan: 4)[Date range 2010-01-01 to 2024-06-30; all searches run and logged the same day (`search_strategy_log.csv`)],),
  ),
) <tab-ch06-search-strategy>

Before you ever get to that final string, you usually need help deciding which terms belong in it. This is where `litsearchr` earns its place in an R-based SLR workflow: it takes a seed set of known-relevant papers (or a naive search's results), extracts candidate keyphrases, and builds a keyword co-occurrence network so you can spot synonyms and related terms you'd otherwise miss — "DR-TB" sitting next to "multidrug-resistant tuberculosis" sitting next to "rifampicin-resistant," for instance.

```r
library(litsearchr)

# naive_results is a data frame with title/abstract/keywords columns
# pulled from an initial scoping search
rakedkeywords <- extract_terms(
  text = paste(naive_results$title, naive_results$abstract),
  method = "fakerake",
  min_freq = 3,
  ngrams = TRUE,
  min_n = 1,
  max_n = 3
)

docs <- paste(naive_results$title, naive_results$abstract)
dfm  <- create_dfm(elements = docs, features = rakedkeywords)
g    <- create_network(search_dfm = dfm, min_studies = 3)

cutoff <- find_cutoff(g, method = "cumulative", percent = 0.80)
reduced_graph <- reduce_graph(g, cutoff_strength = cutoff[1])
search_terms  <- get_keywords(reduced_graph)
search_terms
```

The output isn't a search string you paste in blind — it's a candidate term list you screen against clinical judgment before it enters the Boolean query that then goes into `search_log` above.

#heor-practice[
  In HTA submissions, the search strategy appendix is frequently where assessors' first critical comments land — not the clinical evidence itself. A dated, versioned `search_strategy_log.csv` sitting in your project repo, committed alongside the screening scripts, means you can answer "did you search Embase after your PubMed search, or the same week?" without digging through email threads or a collaborator's memory.
]

#pitfall[
  Translating a search string across database syntaxes (PubMed's `[MeSH]` vs. Embase's `exp .../` vs. Cochrane's `:kw`) by eye is a common source of silently different hit counts. Log the *translated* string actually run in each interface, not one master string you assume is "equivalent" everywhere — and sanity-check hit counts against expectations (Embase typically returns more records than PubMed for the same concept; a near-identical count across both is worth a second look).
]

== 6.2 Deduplication and screening workflows

Running the same concept across three databases guarantees duplicate records — often 20–40% of a combined pull. Deduplicating by exact title match alone will miss records that differ by punctuation, case, or a trailing journal abbreviation, so you need fuzzy matching on title/author/year, and ideally DOI matching as a first, cheap pass before falling back to string similarity.

`synthesisr` standardizes bibliographic imports (RIS/Bibtex/CSV exports from different databases rarely use identical field names) and performs similarity-based deduplication; `revtools` builds on the same ecosystem and adds an interactive screening interface. `ASySD` (Automated Systematic Search Deduplicator) is purpose-built for the messier reality of SLR exports and handles multi-stage matching (DOI exact match, then title/author fuzzy match) more robustly than a single string-distance cutoff.

```r
library(synthesisr)
library(dplyr)

# read_refs() handles RIS exports from PubMed, Embase, and Cochrane
pubmed_refs  <- read_refs("pubmed_export.ris")
embase_refs  <- read_refs("embase_export.ris")
cochrane_refs <- read_refs("cochrane_export.ris")

all_refs <- merge_columns(pubmed_refs, embase_refs, cochrane_refs) |>
  as_tibble()

# first pass: exact match on standardized title string
dup_exact <- find_duplicates(
  all_refs$title,
  method = "exact",
  to_lower = TRUE,
  rm_punctuation = TRUE
)

# second pass: fuzzy match on anything exact matching missed
dup_fuzzy <- find_duplicates(
  all_refs$title,
  method = "string_osa",
  to_lower = TRUE,
  rm_punctuation = TRUE,
  threshold = 7
)

all_refs_dedup <- all_refs |>
  mutate(dup_id = dup_fuzzy) |>
  extract_unique_references(dup_id)

nrow(all_refs) - nrow(all_refs_dedup)   # duplicates removed, for the PRISMA count
```

Once you have a deduplicated set, screening is a two-stage filter: title/abstract first (fast, generous, errs toward inclusion), then full-text on the survivors (slower, decisive, with documented exclusion reasons). The habit that keeps this defensible is logging every reviewer decision at the record level, not just the final yes/no — and if you have two independent screeners, computing agreement rather than assuming it.

```r
library(dplyr)
library(irr)   # kappa2()

screening_log <- all_refs_dedup |>
  mutate(
    reviewer1_ti_ab = sample(c("include", "exclude"), n(), replace = TRUE, prob = c(0.3, 0.7)),
    reviewer2_ti_ab = sample(c("include", "exclude"), n(), replace = TRUE, prob = c(0.3, 0.7))
  )

kappa_result <- kappa2(screening_log[, c("reviewer1_ti_ab", "reviewer2_ti_ab")])
kappa_result$value   # Cohen's kappa for title/abstract agreement

conflicts <- screening_log |>
  filter(reviewer1_ti_ab != reviewer2_ti_ab)
nrow(conflicts)   # records requiring reconciliation discussion
```

A kappa below roughly 0.6 is usually a sign the inclusion criteria need tightening before you burn reviewer time on full-text retrieval, not a problem to paper over with a third tie-breaking reviewer alone.

#report-table(
  [Dual-reviewer title/abstract screening agreement, as reported in the SLR methods section],
  academic-table(
    columns: (2fr, auto),
    align: (left, right),
    header: ([*Metric*], [*Value*]),
    body: (
      [Records screened (title/abstract)], [3,198],
      [Reviewer 1 — included], [960],
      [Reviewer 2 — included], [955],
      [Concordant decisions], [3,083],
      [Agreement (% records)], [96.4%],
      [Cohen's kappa], [0.71],
      [Conflicts requiring reconciliation], [115],
    ),
  ),
) <tab-ch06-screening-agreement>

#agency-note[
  The Cochrane Handbook for Systematic Reviews of Interventions (Chapter 4, "Searching for and selecting studies") specifies that screening should be done independently by at least two reviewers, with disagreements resolved by discussion or a third reviewer, and that the process — including inter-rater agreement where feasible — should be reported with enough detail for replication. A logged `screening_log` with per-reviewer decision columns and a computed kappa is a direct, auditable response to that requirement, not an optional nicety.
]

#pitfall[
  `find_duplicates()` with a string-distance method is sensitive to the threshold you choose — too loose and you merge genuinely distinct trials with similar titles (common in TB drug trials with similar naming conventions); too tight and you leave duplicates in, inflating your "identified" count and understating how much actual unique evidence you screened. Always spot-check a sample of flagged duplicate pairs by eye before accepting `extract_unique_references()`'s output as final, and record the method and threshold used in your methods write-up.
]

== 6.3 PRISMA flow diagrams in R

Every number that feeds the PRISMA flow diagram should trace back to a line of code you already ran — the row count before `extract_unique_references()`, the duplicate count it removed, the title/abstract exclusions from `screening_log`, the full-text exclusions with reasons. Building the diagram from a hand-typed set of numbers in PowerPoint reintroduces exactly the kind of untraceable discrepancy a reproducible SLR workflow is meant to eliminate.

The `PRISMA2020` package takes a named vector or data frame of stage counts (matching the official PRISMA 2020 flow diagram template) and renders the diagram as an SVG/interactive plot you can embed or export.

```r
library(PRISMA2020)
library(dplyr)

prisma_counts <- data.frame(
  stage = c(
    "database_results", "duplicates_removed",
    "records_screened", "records_excluded",
    "full_text_retrieved", "full_text_excluded",
    "studies_included"
  ),
  n = c(
    nrow(all_refs),                     # 3,418 identified
    nrow(all_refs) - nrow(all_refs_dedup),  # duplicates removed
    nrow(all_refs_dedup),               # screened at title/abstract
    sum(screening_log$reviewer1_ti_ab == "exclude" &
          screening_log$reviewer2_ti_ab == "exclude"),
    42,                                  # sent to full-text review
    19,                                  # excluded at full-text, reasons below
    23                                   # final included studies
  )
)

# PRISMA_data() expects its own template row-name structure (stage
# names in column 1, counts in column "n") -- PRISMA2020_data(data) was
# a typo for the real exported function PRISMA_data(data)
data <- PRISMA_data(prisma_counts)
plot <- PRISMA_flowdiagram(
  data,
  interactive = FALSE,
  previous = FALSE,
  other = FALSE,
  fontsize = 12,
  title_colour = "steelblue"
)

# PRISMA2020 has no PRISMA_save(); save a ggplot/DiagrammeR-style object
# with DiagrammeRsvg + rsvg, the package's own documented export route
svg_code <- DiagrammeRsvg::export_svg(plot)
rsvg::rsvg_svg(charToRaw(svg_code), file = "prisma_flow.svg")
```

Full-text exclusions need reasons, not just a count, because PRISMA 2020 Item 7 and the diagram's exclusion box both expect a breakdown (wrong population, wrong comparator, wrong outcome, conference abstract only, etc.) rather than a single undifferentiated number.

```r
exclusion_reasons <- tibble::tibble(
  reason = c("Wrong population", "No cost outcome",
             "Conference abstract only", "Duplicate publication"),
  n = c(7, 6, 4, 2)
)
sum(exclusion_reasons$n)   # must equal full_text_excluded above -- reconcile if not
```

That reconciliation check — the sum of itemized exclusion reasons equalling the single number on the flow diagram — is worth asserting in code (`stopifnot()` or a simple test) rather than eyeballing, since it's exactly the kind of off-by-one error that surfaces in peer review.

#report-table(
  [Screening funnel stage counts underlying the PRISMA 2020 flow diagram, distinct from the itemized full-text exclusion reasons below],
  academic-table(
    columns: (2fr, auto),
    align: (left, right),
    header: ([*Stage*], [*N records*]),
    body: (
      [Records identified across databases], [3,418],
      [Duplicates removed], [220],
      [Records screened (title/abstract)], [3,198],
      [Records excluded at title/abstract], [2,238],
      [Full-text reports retrieved], [42],
      [Full-text reports excluded], [19],
      [Studies included in review], [23],
    ),
  ),
) <tab-ch06-screening-funnel>

#report-table(
  [Full-text exclusion reasons, reported alongside the PRISMA 2020 flow diagram (Item 7)],
  academic-table(
    columns: (1.6fr, auto),
    align: (left, right),
    header: ([*Exclusion reason*], [*n*]),
    body: (
      [Wrong population], [7],
      [No cost outcome], [6],
      [Conference abstract only], [4],
      [Duplicate publication], [2],
    ),
    footer: (table.cell(colspan: 2)[*Total excluded at full-text* = 19],),
  ),
) <tab-ch06-exclusion-reasons>

#figure(
  image("../images/r_generated/ch06_prisma_flow.png", width: 75%),
  caption: [A PRISMA 2020 flow diagram built directly from the stage counts computed in code (§6.3), rather than typed by hand — the reconciliation discipline this section argues for: every number traces back to a line of code, and the itemized exclusion reasons sum to the single full-text-excluded count shown.],
) <fig-ch06-prisma>

#heor-practice[
  Submission dossiers to HTA bodies increasingly expect the PRISMA diagram and the underlying counts to be reconcilable on request. Keeping `prisma_counts` as a data frame generated from the same pipeline that produced `search_strategy_log.csv` and `screening_log` means a reviewer's question — "where did the other 19 full-text articles go?" — has a one-line answer: re-run the script and read off `exclusion_reasons`.
]

#agency-note[
  The PRISMA 2020 statement (Page et al., *BMJ* 2021) explicitly requires, in Item 16a, a flow diagram showing the number of records identified, duplicates removed, records screened and excluded, reports sought and not retrieved, reports assessed for eligibility, and studies included — with reasons given for full-text exclusions. `PRISMA_flowdiagram()` maps directly onto this template field-for-field; using it rather than a freehand diagram is the most mechanical way to guarantee compliance with that specific checklist item.
]

== 6.4 Data extraction templates and extraction QA

Once you have a final included-studies set from screening (§6.2-6.3), the next failure point in an SLR is extraction: the manual transcription of population, intervention, comparator, outcomes (PICO), effect sizes, and risk-of-bias inputs from each paper into a structured dataset. For a TB-programme analyst this will feel familiar — it's the same discipline as designing a clean case-report form before you let field staff touch it. A tibble-based extraction template, version-controlled from day one, turns this into reproducible data engineering rather than a spreadsheet someone can silently edit.

Design the template as one row per study-outcome combination (long format), not one row per study, because most SLRs extract multiple outcomes and multiple comparisons per study, and a wide format forces awkward column explosion later.

```r
library(tibble)
library(dplyr)

extraction_template <- tibble(
  study_id        = character(),  # e.g. "Nguyen2021"
  reviewer_id     = character(),  # who extracted this row
  population      = character(),
  intervention    = character(),
  comparator      = character(),
  outcome_name    = character(),  # e.g. "treatment_success"
  outcome_timepoint = character(),
  effect_measure  = character(),  # "RR", "OR", "HR", "MD"
  effect_estimate = double(),
  ci_lower        = double(),
  ci_upper        = double(),
  n_intervention  = integer(),
  n_comparator    = integer(),
  rob_domain_1    = character(), # e.g. randomisation process
  rob_domain_2    = character(),
  rob_overall     = character(), # "Low", "Some concerns", "High"
  notes           = character()
)

# one extracted row, reviewer A
extraction_template <- extraction_template %>%
  add_row(
    study_id = "Nguyen2021", reviewer_id = "RA",
    population = "Adults, drug-sensitive PTB",
    intervention = "4-month regimen", comparator = "6-month regimen",
    outcome_name = "treatment_success", outcome_timepoint = "end_of_treatment",
    effect_measure = "RR", effect_estimate = 0.98,
    ci_lower = 0.92, ci_upper = 1.04,
    n_intervention = 310, n_comparator = 308,
    rob_domain_1 = "Low", rob_domain_2 = "Some concerns",
    rob_overall = "Some concerns", notes = "ITT analysis used"
  )
```

Enforcing a schema up front (explicit column types, controlled vocabularies for `effect_measure` and `rob_overall`) means extraction errors — a reviewer typing "Odds ratio" where another typed "OR" — surface immediately as validation failures rather than silently corrupting a later meta-analysis.

Dual, independent extraction is the standard safeguard against transcription error, mirroring dual independent screening. Have two reviewers populate identical-schema tibbles, then reconcile programmatically rather than by eye:

```r
library(waldo)

reviewer_a <- readr::read_csv("extraction_reviewerA.csv")
reviewer_b <- readr::read_csv("extraction_reviewerB.csv")

# align rows on the natural key before comparing
reviewer_a <- reviewer_a %>% arrange(study_id, outcome_name)
reviewer_b <- reviewer_b %>% arrange(study_id, outcome_name)

discrepancies <- waldo::compare(
  reviewer_a, reviewer_b,
  tolerance = 1e-6              # ignore float noise, e.g. 0.980 vs 0.98
)
discrepancies
```

`waldo::compare()` reports exactly which cells differ between the two tibbles — far more actionable for an adjudication meeting than a manual side-by-side read of two spreadsheets. For numeric fields where small rounding differences are expected (confidence intervals read off a forest plot, for instance), a `dplyr`-based tolerance check is often clearer than relying on `waldo`'s defaults:

```r
joined <- inner_join(
  reviewer_a, reviewer_b,
  by = c("study_id", "outcome_name"),
  suffix = c("_A", "_B")
)

flagged <- joined %>%
  mutate(
    estimate_diff = abs(effect_estimate_A - effect_estimate_B),
    rob_mismatch  = rob_overall_A != rob_overall_B
  ) %>%
  filter(estimate_diff > 0.01 | rob_mismatch)

flagged %>% select(study_id, outcome_name, effect_estimate_A, effect_estimate_B, rob_overall_A, rob_overall_B)
```

Route every row in `flagged` to a third-reviewer adjudication step before it enters the master extraction dataset, and log the adjudicated value with a `reviewer_id = "adjudicated"` row so the audit trail is preserved rather than overwritten.

#heor-practice[
  Treat the extraction dataset the way you would treat programme surveillance data destined for a drug-resistance report: commit the CSV or `.rds` files to version control (Git) at each named milestone — "post first-pass extraction", "post reconciliation", "post adjudication" — rather than editing one live file in place. A `git diff` on a CSV extraction file is a legitimate, line-by-line audit trail of who changed what value and when, which is exactly the kind of provenance a submission dossier's SLR appendix may be interrogated on. Avoid storing extraction data only in a shared Excel/Google Sheet with no version history; if the sheet is the master, export it to CSV and commit the export after every extraction session.
]

#pitfall[
  Resist the temptation to resolve discrepancies by simply averaging or eyeballing "which one looks right." A documented discrepancy with no recorded resolution rationale is itself a methodological weakness reviewers will flag. Always log *why* a value was adjudicated the way it was (e.g. "reviewer A misread Table 3 column header — comparator and intervention columns were swapped") alongside the final value.
]

== 6.5 Risk of bias visualisation (`robvis`)

Risk-of-bias assessment itself — applying Cochrane RoB 2.0 to RCTs or ROBINS-I to non-randomized studies — is a judgment exercise done by reviewers against the official signalling-question algorithms, not something R automates. What R (via the `robvis` package) does well is turn a completed set of domain-level judgments into the standard traffic-light and weighted-bar-chart figures that PRISMA-compliant reviews and HTA submissions are expected to include.

`robvis` expects a data frame with one row per study, a column per RoB domain plus an overall judgment column, and values restricted to the tool's controlled vocabulary (`"Low"`, `"Some concerns"`/`"Moderate"`, `"High"`/`"Serious"`, `"Critical"`, `"No information"` depending on the tool). Build this from your reconciled extraction tibble:

```r
library(robvis)
library(dplyr)

# RoB 2.0 for RCTs: one row per study, domains D1-D5, overall, then a
# final Weight column -- robvis expects the weight as the LAST column
rob2_data <- tibble::tibble(
  Study = c("Nguyen2021", "Alvarez2020", "Okafor2022"),
  D1 = c("Low", "Some concerns", "Low"),
  D2 = c("Low", "Low", "Some concerns"),
  D3 = c("Some concerns", "Low", "Low"),
  D4 = c("Low", "Low", "Low"),
  D5 = c("Low", "Some concerns", "Low"),
  Overall = c("Some concerns", "Some concerns", "Low"),
  Weight = c(33.3, 33.3, 33.3)
)

rob_traffic_light(
  data = rob2_data,
  tool = "ROB2",
  psize = 8
)

rob_summary(
  data = rob2_data,
  tool = "ROB2",
  overall = TRUE
)
```

`rob_traffic_light()` produces the familiar red/amber/green grid — one row per study, one column per domain — that goes directly into an SLR appendix or a methods annex of an HTA dossier. `rob_summary()` produces the weighted horizontal bar chart showing the proportion of studies at each judgment level per domain, which is the figure typically used in the main body of the review to summarise bias across the whole evidence base at a glance.

For non-randomized studies assessed with ROBINS-I, the domain structure and vocabulary differ, so specify `tool = "ROBINS-I"` and supply the correct domain columns:

```r
robins_data <- tibble::tibble(
  Study = c("Mbeki2019", "Santos2021"),
  D1 = c("Low", "Moderate"),
  D2 = c("Moderate", "Low"),
  D3 = c("Low", "Low"),
  D4 = c("Serious", "Moderate"),
  D5 = c("Low", "Low"),
  D6 = c("Low", "Low"),
  D7 = c("Moderate", "Low"),
  Overall = c("Serious", "Moderate"),
  Weight = c(50, 50)
)

rob_traffic_light(data = robins_data, tool = "ROBINS-I")
rob_summary(data = robins_data, tool = "ROBINS-I", overall = TRUE)
```

Both functions return `ggplot2` objects, so they compose with the rest of your usual plotting pipeline — save with `ggsave()`, adjust fonts and sizing for print dossiers, or patch into a combined figure with `patchwork` alongside forest plots from a later meta-analysis (Chapter 11).

#figure(
  image("../images/r_generated/ch06_robvis_traffic_light.png", width: 85%),
  caption: [`robvis::rob_traffic_light()` applied to the chapter's worked RoB 2.0 example (`rob2_data`): a red/amber/green grid, one row per study, one column per domain, in the standard format expected in an SLR appendix or HTA methods annex.],
) <fig-ch06-robvis-traffic>

#figure(
  image("../images/r_generated/ch06_robvis_summary.png", width: 85%),
  caption: [`robvis::rob_summary()` on the same data: the weighted horizontal bar chart summarising the proportion of studies at each judgment level per domain, the figure typically placed in the main body of a review rather than its appendix.],
) <fig-ch06-robvis-summary>

#agency-note[
  Cochrane Handbook Chapter 8 (RoB 2.0) and Chapter 25 (ROBINS-I) specify the signalling questions and domain structure that `robvis`'s input vocabulary is built around — do not substitute an informal judgment scale that doesn't map onto those domains, because a reviewer or HTA assessor checking your figure against the Handbook's defined categories will immediately notice a mismatch. PRISMA 2020 item 18 explicitly requires reporting "methods used to assess risk of bias in the included studies," and a traffic-light plot generated this way is standard, recognisable evidence of having done so transparently rather than narratively.
]

#pitfall[
  `robvis` will silently plot whatever judgment strings you give it, including typos or inconsistent capitalisation (`"low"` vs `"Low"`), as a separate category rather than erroring. Always run `unique()` across your domain columns before plotting to catch stray values that would otherwise produce an extra, meaningless colour band in the traffic light or summary bar.
]

== 6.6 Text mining and ML-assisted screening

By the time a search strategy returns several thousand abstracts, manually reading titles in import order is a poor use of two reviewers' time. Text mining can reorder the screening queue so the most plausibly relevant abstracts are screened first, which speeds up time-to-inclusion-decision without changing *what* counts as included — screening decisions themselves remain exclusively human, exactly as in every other stage of this chapter.

A simple term-frequency pass with `tidytext` is often enough to sanity-check that your search strategy actually captured the expected vocabulary before you even start full screening:

```r
library(tidytext)
library(dplyr)

abstracts <- tibble::tibble(
  study_id = c("S1", "S2", "S3"),
  abstract = c(
    "Randomized trial of four-month rifapentine-based regimen for pulmonary TB.",
    "Cohort study assessing cardiovascular risk in diabetic patients.",
    "Treatment success and relapse rates in short-course TB chemotherapy."
  )
)

tidy_abstracts <- abstracts %>%
  unnest_tokens(word, abstract) %>%
  anti_join(stop_words, by = "word")

term_freq <- tidy_abstracts %>%
  count(word, sort = TRUE)

term_freq %>% head(10)
```

For a more structured relevance signal across a few thousand abstracts, `quanteda` builds a document-feature matrix and lets you score each abstract against a set of PICO-anchored terms drawn from your protocol's search strategy:

```r
library(quanteda)

corp <- corpus(abstracts, text_field = "abstract", docid_field = "study_id")
dfm_abs <- corp %>%
  tokens(remove_punct = TRUE) %>%
  tokens_remove(stopwords("en")) %>%
  dfm()

# relevance proxy: count of protocol-defined key terms per abstract
key_terms <- c("tuberculosis", "rifapentine", "regimen", "relapse", "treatment")
relevance_score <- dfm_abs %>%
  dfm_select(pattern = key_terms) %>%
  rowSums()

screening_order <- tibble::tibble(
  study_id = docnames(dfm_abs),
  relevance_score = relevance_score
) %>%
  arrange(desc(relevance_score))

screening_order
```

Feeding `screening_order` to your reviewers as the order in which to work through the abstract list — highest-scoring first — gets likely-includes screened early, which matters operationally when a review has a hard deadline and screening is still incomplete when it arrives.

The `revtools` package goes further, offering topic modelling (via `screen_topics()` / `screen_abstracts()`) specifically built around the SLR screening workflow: it clusters abstracts into latent topics and gives reviewers an interactive interface to mark whole topic clusters as likely relevant or irrelevant, which is useful triage for very large (10,000+) abstract sets before line-by-line screening starts. Purpose-built external screening platforms — Rayyan and Abstrackr are the most commonly cited in SLR methods sections — offer similar machine-learning-assisted prioritisation (active-learning ranking as reviewers screen) and integrate directly with reference managers; R's role here is typically pre- or post-processing (exporting a prioritised order into Rayyan, or pulling Rayyan's decision export back into your extraction pipeline from §6.4) rather than replacing those platforms outright.

#pitfall[
  Term-frequency scores, topic clusters, and active-learning rankings are prioritisation aids, not screening decisions, and none of them replace Cochrane's requirement (Cochrane Handbook Chapter 4) for dual independent screening of every title/abstract and full text by two human reviewers with disagreements resolved by discussion or a third reviewer. Using an ML relevance score to *exclude* abstracts outright, or to let a single reviewer screen only the "high-relevance" tier while skipping the rest, breaks that standard and will be flagged by anyone checking your PRISMA flow diagram against the methods text. The only legitimate use of these tools in a Cochrane-conformant review is re-ordering the queue that both independent human reviewers still work through in full.
]
