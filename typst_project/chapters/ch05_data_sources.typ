#import "../common.typ": *

= Chapter 5. Data Sources and Data Management

#learning-objectives((
  [Distinguish CDISC SDTM (collected, domain-organised trial data) from ADaM (analysis-ready derived data), and explain why ADaM datasets are generally preferred as model inputs where available.],
  [Characterise the distinct strengths, weaknesses and provenance biases of registries, administrative claims, electronic health records, and survey data as real-world data sources.],
  [Treat published literature as a data source with its own extraction discipline, and explain why publication bias threatens any model parameter pulled from an ad hoc literature search.],
  [Import health-economic data from flat files, spreadsheets, SAS/Stata/SPSS files, relational databases, and web APIs using `readr`, `readxl`, `haven`, `DBI` and `httr2`.],
  [Construct and maintain a data dictionary / codebook that documents variable meaning, coding, and derivation logic, including with the `labelled` package.],
  [Apply programmatic data quality checks (`pointblank`, `assertr`, `validate`) to catch impossible values — negative costs, out-of-range utilities — before they reach a cost-effectiveness pipeline.],
  [Apply the core concepts of data governance, de-identification, and privacy law (HIPAA, GDPR, India's DPDPA 2023) to patient-level HEOR data handling.],
))

== 5.1 Clinical trial data (CDISC SDTM/ADaM concepts)

For most HEOR analysts trained in TB programme surveillance or routine public-health M&E, the first encounter with sponsor-provided clinical trial data comes as a jolt. The data are not a single flat line-list you built yourself from a case-based database; they are dozens of interlinked tables governed by a standard you did not write and cannot casually reshape. Understanding that standard — the Clinical Data Interchange Standards Consortium's (CDISC) Study Data Tabulation Model (SDTM) and Analysis Data Model (ADaM) — is a prerequisite for doing economic modelling work that touches regulated trial data, because nearly every phase II/III trial submitted to a regulator in the last fifteen years has been structured this way, and increasingly so are the trials that feed economic submissions to HTA bodies.

SDTM and ADaM solve two different problems, and conflating them is the single most common conceptual error newcomers make. SDTM is the standard for *collected* data: it organises what was observed or recorded during the trial into standardised *domains*, each a rectangular dataset with a controlled set of variables. `DM` holds one row per subject with demographics (age, sex, arm assignment, dates of first/last exposure); `AE` holds one row per adverse event per subject (with standardised terms, severity grades, relatedness, onset/resolution dates); `LB` holds laboratory results in long format (one row per subject per visit per analyte); `EX` holds exposure/dosing records; `VS` holds vital signs; and so on through dozens of other two-letter domain codes. SDTM datasets are deliberately close to raw collection — they are not yet statistically "analysis-ready." A single AE record, for instance, does not by itself tell you whether that event counts toward a "treatment-emergent adverse event" (TEAE) analysis population, because that determination requires business rules (did the event start after first dose? within a specified window?) that are not SDTM's job to encode.

ADaM is the standard for *analysis-ready* derived data built *from* SDTM, not alongside it or instead of it. The cornerstone ADaM dataset is `ADSL` (Subject-Level Analysis dataset), one row per subject carrying derived flags and population indicators — intent-to-treat flag, safety population flag, treatment duration, baseline disease severity category — that get merged onto every other analysis dataset so that subgroup and population definitions stay consistent across every output in the submission. Built on top of ADSL are domain-specific analysis datasets such as `ADAE` (derived from SDTM `AE` plus ADSL, now carrying the TEAE flag, duration calculations, and toxicity grade shifts) or `ADLB` (derived from SDTM `LB`, now carrying baseline values, change-from-baseline, and shift-table categories attached to each record). The relationship is strictly directional: SDTM feeds ADaM, ADaM feeds statistical analysis and tables/figures/listings, and nothing flows backward. For an HEOR analyst building a cost-effectiveness model off trial data, this matters practically — you want ADaM datasets (particularly ADSL and ADAE/ADTTE-style time-to-event datasets) wherever they exist, because the analysis-ready derivations (populations, flags, time-to-event censoring rules) have already been vetted against the statistical analysis plan. Going back to raw SDTM domains and re-deriving those flags yourself is both more work and a source of discrepancy risk against the trial's own published results.

#agency-note[
CDISC's SDTM and ADaM Implementation Guides are the data standards named explicitly in the FDA's Data Standards Catalog and required for electronic study data submitted to FDA (and, for ICH-aligned submissions, broadly expected by other ICH regulators) for the relevant study start dates covered by that catalog. ICH E3 ("Structure and Content of Clinical Study Reports") separately governs how the *narrative* clinical study report is organised, including appendices that reference the underlying datasets; it does not itself define a data model, but study reports built to ICH E3 are now routinely accompanied by SDTM/ADaM datasets and define-XML metadata. An HEOR analyst requesting trial data from a sponsor's clinical data management or biostatistics group should expect ADaM datasets with accompanying define.xml metadata files describing every variable's derivation — reading that define.xml before touching the data is non-negotiable, because variable names recur across domains with domain-specific meanings.
]

In practice you will rarely receive true SAS transport (`.xpt`) files directly for ad hoc exploratory modelling work; more often a biostatistics partner exports a derived extract. But knowing the domain structure lets you sanity-check what you're given. A minimal, illustrative read of an ADaM-style subject-level dataset in R might look like this:

```r
library(haven)
library(dplyr)

# Read an ADaM subject-level analysis dataset (ADSL) from SAS transport format
adsl <- read_xpt("adsl.xpt")

# ADSL carries one row per subject with population flags already derived
adsl_summary <- adsl |>
  filter(SAFFL == "Y") |>                 # safety population flag
  group_by(TRT01P) |>                     # planned treatment, ADaM naming convention
  summarise(
    n = n(),
    mean_age = mean(AGE, na.rm = TRUE),
    pct_female = mean(SEX == "F", na.rm = TRUE) * 100
  )

adsl_summary
```

Two ADaM naming conventions are worth internalising early because they recur constantly: variables ending in `FL` are flags (`Y`/`N`/blank), and paired variables like `TRT01P`/`TRT01A` distinguish *planned* treatment (as randomised) from *actual* treatment (as received) — a distinction that matters enormously if your economic model is meant to reflect intention-to-treat effectiveness versus per-protocol or as-treated efficacy assumptions. Getting this pairing wrong is a quiet way to silently misstate your model's analysis population without any error being thrown.

The `adsl_summary` output above is not merely an intermediate check — summarised, by-arm baseline demographics computed straight from ADSL are exactly the content of the "Baseline characteristics" table that opens almost every clinical study report and HTA submission's patient population section.

#report-table(
  [Baseline demographic summary of the safety population by planned treatment arm (ADSL-derived), the conventional "Table 1" format for clinical study reports and HTA submissions],
  academic-table(
    columns: (1.6fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Treatment arm (TRT01P)*], [*N*], [*Mean age (years)*], [*Female (%)*]),
    body: (
      [Placebo], [148], [61.4], [47.3],
      [Standard dose], [151], [60.8], [49.0],
      [High dose], [149], [62.1], [45.6],
    ),
    footer: (table.cell(colspan: 4)[Safety population (SAFFL = "Y"); age and sex as recorded in ADSL],),
  ),
) <tab-ch05-adsl-baseline>

#pitfall[
Do not merge SDTM domain datasets directly to build your own "ADSL-equivalent" population flags from scratch when ADaM datasets already exist for the trial. SDTM `AE` records, for example, are not pre-filtered to treatment-emergent events, and naively counting all AE rows per arm will systematically overstate adverse event rates relative to the trial's own published safety tables, because it ignores the TEAE windowing logic that the biostatistics team already encoded in `ADAE`. If ADaM datasets are unavailable and you must derive flags from raw SDTM yourself, document every derivation rule and reconcile your subject counts against the trial's CONSORT diagram and published demographic table before proceeding — a mismatch at that stage means your derivation logic is wrong, not the source data.
]

== 5.2 Registries, claims, electronic health records and surveys

Outside the tightly governed world of SDTM/ADaM, most of the "real-world" data an HEOR analyst touches comes from four families of sources that look superficially similar — they are all large tables of patient-level information — but differ fundamentally in how they were generated, what they are fit for, and where they will mislead you if you are not careful. The TB-programme instinct to ask "who collected this, for what purpose, and what did they have an incentive to record accurately?" transfers directly here and is, if anything, the single most useful habit you already have.

Disease *registries* are purpose-built, typically prospective, collections of patients with a defined condition, enrolled and followed specifically because they have that condition — a national TB registry, a cancer registry, a rare-disease natural history registry. Because registries are designed around a clinical question, data quality on the variables central to that question (diagnosis confirmation, key outcomes, treatment regimen) tends to be relatively high, and longitudinal follow-up can be genuinely strong. The structural limitation is selection: registry populations are, by construction, the patients who were diagnosed, referred, and consented into the registry, which is rarely a random or representative sample of all patients with the condition — a limitation TB programme analysts will recognise immediately from case-based surveillance versus true population incidence.

Administrative *claims* data — insurance billing records, whether from private payers or public schemes — are generated as a byproduct of the reimbursement process, not for research, and that provenance shapes everything about their strengths and weaknesses. Their great strength is scale and completeness of health-service utilisation: every reimbursed encounter, drug fill, and procedure tends to leave a billing trace, which makes claims data excellent for costing, utilisation patterns, and longitudinal tracking of care pathways across providers — things a single-site registry or trial cannot see. Their great weakness is clinical granularity: claims data record diagnosis and procedure *codes* (ICD, CPT, HCPCS, or local equivalents) attached to a billing event, not direct clinical measurements; there is no lab value, no severity grade, no free-text clinical reasoning, and diagnosis codes are sometimes recorded for billing optimisation rather than clinical precision (a phenomenon generically called "upcoding" that any analyst working with programmatic reporting data will recognise under different names).

*Electronic health record* (EHR) data sit at nearly the opposite end of the granularity spectrum from claims. EHRs capture rich clinical detail — vital signs, lab trends, clinician notes, imaging reports — generated at the point of care rather than at the point of billing. That richness is also the problem: EHR data are notoriously messy, heterogeneous across institutions and vendor systems, often only locally structured (a lab value field may be clean while diagnosis information lives only in unstructured clinical text requiring natural-language processing to extract), and plagued by interoperability failures when trying to link a patient's record across different health systems or care episodes. Distinguishing "value is genuinely missing" from "value was never measured at this encounter" from "value was recorded somewhere in free text we haven't extracted" is a recurring, unglamorous task in any EHR analysis.

*Survey* data — whether a dedicated health-utility survey, a national health interview survey, or a patient-reported-outcomes substudy — rely on self-report, and inherit all the familiar biases of self-report instruments: recall bias, social-desirability bias, non-response bias (who agrees to answer a 45-minute survey is rarely a random sample of the target population), and the general gap between what a patient reports and what a clinical record would show. Surveys remain indispensable, however, for exactly the outcomes that claims and EHR data structurally cannot capture — health-related quality of life, utility weights, out-of-pocket spending, and patient experience — which is precisely why so much of the QALY-generating utility data you'll use in cost-effectiveness modelling (Chapter 8 onward) originates from survey instruments rather than administrative records.

#list(
  [*Registries*: prospective, condition-defined enrolment; higher data quality on core variables; selected, non-representative populations.],
  [*Claims*: large-volume, billing-code-based; excellent for utilisation/cost; no direct clinical detail, coding driven partly by reimbursement incentives.],
  [*EHR*: rich clinical granularity at point of care; messy, heterogeneous, interoperability-limited; extensive missing/unstructured data.],
  [*Surveys*: only source for genuine self-reported outcomes (utilities, QoL, experience); subject to recall, social-desirability, and non-response bias.],
)

The four source families map onto distinct HEOR modelling use cases rather than being interchangeable, and that mapping is itself the kind of hierarchy a methods section should state explicitly when justifying a parameter's source.

#ref-table(
  [Fit-for-purpose mapping of real-world and trial-derived data source types to common HEOR model inputs],
  academic-table(
    columns: (1fr, 1.8fr, 1.6fr),
    align: (left, left, left),
    header: ([*Source type*], [*Typically well suited to*], [*Typically poorly suited to*]),
    body: (
      [RCT (SDTM/ADaM)], [Relative treatment effect, trial-period safety and efficacy], [Long-term extrapolation beyond follow-up, real-world adherence],
      [Registry], [Natural history, long-term outcomes in diagnosed patients], [Population-level incidence, undiagnosed/unreferred patients],
      [Administrative claims], [Resource use, costing, longitudinal care pathways], [Clinical severity, lab-confirmed diagnosis, quality of life],
      [EHR], [Clinical event detail, lab trends, comorbidity capture], [Cross-system linkage, structured utility/cost extraction],
      [Survey], [Health utilities, QALY weights, patient-reported outcomes], [Resource-use costing, objective clinical endpoints],
      [Published literature], [Comparative effect sizes absent a head-to-head trial, background rates], [Patient-level heterogeneity, population-specific calibration],
    ),
  ),
) <tab-ch05-source-hierarchy>

A practical first step with any of these four source types in R is the same regardless of provenance: profile missingness and coding structure before doing anything substantive, because the failure modes above show up as specific, checkable patterns in the data.

```r
library(dplyr)
library(purrr)

# Generic first-pass profiling for a real-world data extract,
# whether claims, EHR, or registry sourced
profile_source_data <- function(df) {
  map_dfr(names(df), function(col) {
    x <- df[[col]]
    tibble(
      variable = col,
      pct_missing = round(mean(is.na(x)) * 100, 1),
      n_distinct = n_distinct(x, na.rm = TRUE),
      type = class(x)[1]
    )
  }) |>
    arrange(desc(pct_missing))
}

claims_profile <- profile_source_data(claims_extract)
head(claims_profile, 10)
```

A column with near-zero missingness but a suspiciously small set of distinct values in a claims extract is often a diagnosis code field clustered around a handful of billable categories; a column with 40% missingness in an EHR extract is often a lab value only ordered for a clinical subgroup, not a value missing-at-random — and that distinction has direct consequences for whether later imputation in your model is defensible (a topic picked up again in Chapter 7's treatment of missing data).

#heor-practice[
When a sponsor or health-system partner hands you a "real-world evidence" extract without documentation, do not take the source label (registry, claims, EHR) at face value — check it against the data's own fingerprints. Billing-code-only fields with no accompanying clinical values and a visit-level grain strongly suggest claims; free-text or heavily missing structured fields alongside visit timestamps suggest EHR; a small number of tightly curated outcome variables with strong longitudinal completeness suggest a purpose-built registry. Getting the provenance right determines which biases you need to defend against in your eventual HTA submission — reviewers will ask.
]

#agency-note[
NICE's Health Technology Evaluations Manual (PMG36, 2022) explicitly expects companies to justify the choice and quality of real-world data sources used in an evidence submission, including describing data provenance, completeness, and potential biases relative to the decision problem — a registry, claims extract, or EHR cohort cannot simply be asserted as representative of the UK clinical population without supporting justification. Equivalent expectations about real-world evidence transparency and fitness-for-purpose appear in FDA's real-world evidence guidance documents for regulatory decision-making. Analysts should document data source, extraction logic, and known limitations as rigorously as they would document a trial's SDTM/ADaM provenance.
]

== 5.3 Published literature as a data source

Not every input to an economic model comes from a dataset you can open in R at all. A large share of the parameters in any cost-effectiveness model — relative treatment effects when no head-to-head trial exists, long-term survival extrapolation anchors, utility decrements for specific health states, background mortality and incidence rates for comparator arms — come instead from the published literature: individual trial publications, systematic reviews, and meta-analyses. Treating published literature as a *data source* in its own right, with its own collection, extraction, and quality-appraisal discipline, is as important as treating a claims extract or registry with appropriate scepticism about provenance.

The starting point is usually a systematic literature review (SLR), which Chapter 6 covers in depth as a process; what matters here is recognising why that formal process exists rather than simply Google Scholar–searching for a few convenient trials. An ad hoc literature search is vulnerable to exactly the selection problems that plague any non-random sampling exercise: you are more likely to find, read, and cite papers that are highly cited, recently published, available in open access, and — crucially — that report positive, statistically significant results. This last point is the heart of *publication bias*: trials and studies with null or unfavourable results are systematically less likely to be published at all, or are published after longer delay, in lower-visibility journals, or with selective outcome reporting that emphasises secondary endpoints when the primary endpoint was negative. A model built by pulling point estimates from whichever three papers surfaced first on a search is at serious risk of systematically overestimating treatment effect, precisely because positive results are overrepresented in what gets published and found.

Meta-analysis, covered properly in Chapter 11, is the statistical machinery for pooling effect estimates across multiple studies once a systematic review has identified them, and it exists partly as a defence against the limitations of any single trial's precision — but it is not a defence against publication bias itself; a meta-analysis of a biased set of published trials simply produces a precisely wrong pooled estimate. Funnel plots, Egger's test, and trial registry cross-checks (comparing published results against pre-registered trial protocols on registries such as ClinicalTrials.gov) are the standard tools for detecting whether publication bias is likely operating in a given evidence base, and an HEOR analyst pulling a hazard ratio from a published meta-analysis for use in a model should check whether the authors examined this at all before trusting the pooled number uncritically.

#difficult-terminology("funnel plot / Egger's test")[
Both are ways of checking whether a meta-analysis's pooled evidence
base looks suspiciously incomplete — specifically, whether small
studies with unfavourable results seem to be missing. A *funnel plot*
is a scatter chart with each study's estimated effect size (e.g. a
risk ratio) on one axis and a measure of that study's precision (often
sample size, or the inverse of its standard error) on the other. If
publication bias is absent, the plot should look like a roughly
symmetric, upside-down funnel: small, imprecise studies scatter widely
on both sides of the pooled average, while large, precise studies
cluster tightly near it. If small studies showing an unfavourable or
null result are more likely to go unpublished, the plot becomes
visibly lopsided — small studies appear only on the "favourable" side,
leaving a gap on the other, like a funnel with one side sheared off.
*Egger's test* is the formal statistical counterpart: rather than
eyeballing the plot for asymmetry, it runs a regression of each
study's effect size against its precision and tests whether the
resulting line is significantly tilted away from zero — a significant
tilt is read as statistical evidence of the same asymmetry the funnel
plot shows visually. Neither test proves publication bias exists (a
real, genuine difference between small and large studies can also
cause asymmetry), but both are the field's standard first-line checks
before trusting a pooled estimate at face value.
]

In the interim, before Chapter 6's formal SLR methodology, a reasonable working discipline when extracting parameters from literature for a model is to keep a structured, auditable extraction log rather than copying numbers directly into model code — the same instinct that already governs good practice in extracting data from a clinical dataset applies to extracting data from a PDF.

```r
library(tibble)
library(readr)

# A minimal structured extraction log for literature-derived
# model parameters -- auditable, reproducible, and easy to
# cross-check against a later formal SLR in Chapter 6
param_log <- tribble(
  ~parameter,            ~value, ~source_citation,                 ~source_type,       ~notes,
  "hr_pfs_drugA_vs_soc",   0.62, "Smith et al. 2021, NEJM",         "RCT publication",  "ITT population, 95% CI 0.48-0.80",
  "utility_progressed",   0.68, "Jones et al. 2019, Qual Life Res", "Utility study",    "EQ-5D-3L, UK value set",
  "cost_ae_grade3plus",   1450, "National tariff schedule 2023",   "Admin/tariff",      "2023 GBP, not inflated"
)

write_csv(param_log, "literature_parameter_log.csv")
param_log
```

Keeping source type, citation, and context notes alongside each extracted value does two things: it makes the eventual model auditable by a third party (including an HTA reviewer), and it forces you to notice, at extraction time, when a parameter's "source" is actually a secondary citation of a citation rather than the primary study — a surprisingly common and avoidable error.

#pitfall[
Extracting a single point estimate from a published trial or meta-analysis without also recording its confidence interval, the population it applies to, and the follow-up duration is a false economy. When that parameter later needs to flow into a probabilistic sensitivity analysis (Chapter 25), you will either have to re-find the paper under time pressure or, worse, invent a plausible-looking distribution around a number whose true uncertainty you never actually captured. Record the full uncertainty information once, at extraction time, alongside the point estimate.
]

#agency-note[
NICE's Health Technology Evaluations Manual (PMG36, 2022) requires that evidence submissions describe the search strategy, selection criteria, and quality appraisal used to identify clinical and economic evidence, explicitly so that reviewers can assess the risk of selective or biased evidence identification — a requirement that applies as much to parameters quietly pulled from literature for an economic model as to the clinical evidence base itself. Cochrane's Handbook for Systematic Reviews of Interventions likewise sets out, as the internationally recognised methodological reference, the expectation that a review's search be systematic and its risk-of-bias and publication-bias assessment be reported explicitly rather than assumed absent.
]

== 5.4 Importing data: `readr`, `readxl`, `haven`, `DBI`, APIs

A TB programme analyst moving into HEOR work quickly discovers that the hardest part of an analysis is rarely the statistics — it is getting the data into R in a shape you can trust. Cost and outcomes data for HTA submissions arrive in an unglamorous variety of formats: flat files exported from a surveillance system, Excel workbooks maintained by a finance officer, SAS transport files from a contract research organisation, Stata extracts from a DHS-style household survey, and increasingly, live pulls from a claims warehouse or a public API. This section builds a working toolkit across all five, with an eye toward the habits — explicit column typing, encoding checks, provenance logging — that keep an import pipeline reproducible six months later when a reviewer asks "where did this number come from?"

=== Delimited and flat files with `readr`

For CSV, TSV, and other delimited files, `readr::read_csv()` is the workhorse. Compared to base R's `read.csv()`, it is faster on large files, guesses column types from a larger sample by default, never silently converts strings to factors, and — critically for reproducibility — prints a column specification you can freeze into the script.

```r
library(readr)

# Import quarterly unit-cost data exported from a costing database
unit_costs <- read_csv(
  "data/unit_costs_2023q4.csv",
  col_types = cols(
    facility_id   = col_character(),
    cost_centre   = col_character(),
    unit_cost_usd = col_double(),
    report_date   = col_date(format = "%Y-%m-%d")
  ),
  na = c("", "NA", "N/A", "-99")
)

problems(unit_costs)   # surfaces any parsing failures row-by-row
spec(unit_costs)       # the frozen column specification, paste into the script
```

Pinning `col_types` explicitly rather than accepting `readr`'s guess is the single habit most worth adopting from this section. A silent type mismatch — a patient ID parsed as numeric and losing a leading zero, or a cost column parsed as character because one row contains a stray comma — is exactly the kind of error that survives into a cost-effectiveness model undetected.

#pitfall[
`readr`'s type guessing samples only the first 1,000 rows by default. A numeric-looking ID column that turns alphanumeric at row 1,200, or a currency column where one late row contains `"1,234.56"` with a thousands separator, will parse cleanly up to that point and then silently coerce to `NA` or character from there on. Always pass an explicit `col_types` specification for any file that feeds a submission-facing analysis, and always inspect `problems()` after import — it is empty far less often than you'd expect.
]

=== Spreadsheets with `readxl`

Excel remains the lingua franca of health-sector data exchange, and `readxl::read_excel()` reads `.xls` and `.xlsx` without requiring Excel itself or any system dependency — useful on a locked-down analysis server. Its main complications are multi-sheet workbooks, header rows that don't start at row 1, and merged cells that leave ragged blank columns.

```r
library(readxl)

# List sheets before committing to one
excel_sheets("data/registry_extract_2023.xlsx")

registry_raw <- read_excel(
  "data/registry_extract_2023.xlsx",
  sheet = "Enrolment",
  range = "A3:N850",        # skip title rows and a trailing totals row
  col_types = c("text", "text", "date", "numeric", "text",
                "numeric", "numeric", "text", "text", "text",
                "numeric", "text", "text", "numeric"),
  na = c("", "NA", "Not recorded")
)
```

Specifying `range` directly is often more robust than `skip =` plus `n_max =`, because finance and clinical teams frequently insert or delete header rows between workbook versions without warning; a hard-coded range at least fails loudly (wrong number of columns) rather than silently ingesting a title row as data.

=== Clinical trial and survey formats with `haven`

Clinical trial data exchanged with a CRO, and large household surveys such as DHS or WHO STEPS, are routinely distributed as SAS, Stata, or SPSS files. `haven` reads all three natively and — importantly — preserves value labels and SAS/SPSS "missing" codes as attributes rather than discarding them, which matters a great deal once you reach the codebook work in §5.5.

```r
library(haven)

# SAS transport/dataset file (common for SDTM/ADaM exchange)
adsl <- read_sas("data/adsl.sas7bdat")

# Stata .dta (e.g. a DHS-derived household dataset)
survey_dta <- read_dta("data/hh_survey_2022.dta")

# SPSS .sav
qol_spss <- read_sav("data/qol_followup.sav")

# Inspect preserved labelling
attributes(survey_dta$wealth_quintile)
```

A column read with `haven` is typically of class `haven_labelled` — it behaves like a numeric or character vector but carries an attached label and, for SAS/SPSS, a set of user-defined missing codes. Before merging or modelling, convert deliberately rather than letting the labelled class leak into `dplyr` pipelines unexamined:

```r
library(dplyr)
library(haven)

survey_clean <- survey_dta |>
  mutate(
    wealth_quintile = as_factor(wealth_quintile),   # labels become factor levels
    age_years       = zap_labels(age_years)         # strip labels, keep plain numeric
  )
```

#pitfall[
`haven_labelled` columns print deceptively like ordinary numbers in a console or `glimpse()`, but arithmetic and joins on them can behave unexpectedly, and some `tidyverse` verbs will warn or drop the class silently. Decide at import time, column by column, whether you want `as_factor()` (keep the coded meaning) or `zap_labels()` (keep only the numeric value) — don't leave the decision for whoever inherits the script.
]

=== Databases with `DBI`

For a claims warehouse, a TB case-based surveillance database, or any registry sitting behind a relational database, `DBI` gives a backend-agnostic connection interface — the same `dbConnect()` / `dbGetQuery()` pattern works whether the backend driver underneath is `RPostgres`, `odbc`, `RSQLite`, or `RMariaDB`. Given your SQL background, this is likely the most immediately comfortable part of the pipeline: write the query exactly as you would in any SQL client, and let `DBI` hand back a data frame.

```r
library(DBI)
library(RPostgres)

con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "claims_warehouse",
  host     = Sys.getenv("CLAIMS_DB_HOST"),
  port     = 5432,
  user     = Sys.getenv("CLAIMS_DB_USER"),
  password = Sys.getenv("CLAIMS_DB_PASSWORD")
)

inpatient_costs <- dbGetQuery(con, "
  SELECT
    patient_id,
    admission_date,
    discharge_date,
    diagnosis_code,
    total_charge_usd
  FROM claims.inpatient_episodes
  WHERE admission_date >= '2022-01-01'
    AND diagnosis_code LIKE 'A15%'   -- respiratory TB, ICD-10
")

dbDisconnect(con)
```

Two habits carry over directly from your SQL work and are worth keeping explicit in R scripts:

#list(
  [Push filtering and aggregation into the SQL string wherever the database can do it efficiently — pulling an entire multi-year claims table into R memory just to `filter()` it afterward wastes both the database's indexing and your laptop's RAM.],
  [Never hard-code credentials in a script that might end up in version control; read them from environment variables (`Sys.getenv()`) or a credentials manager, as above.],
)

For parameterised queries — avoiding both SQL injection and the temptation to build query strings with `paste0()` — `DBI::dbGetQuery()` accepts a `params` argument with placeholders:

#difficult-terminology("SQL injection")[
SQL injection is a security flaw that arises whenever a program builds
a database query by pasting untrusted text — commonly, text a user
typed into a form — directly into the query string, rather than
keeping the query's structure and the user-supplied values cleanly
separate. If a patient ID field is pasted straight into a query like
`"SELECT * FROM patients WHERE id = '" + user_input + "'"`, and a user
(malicious or merely careless) enters something like
`' OR '1'='1`, the resulting pasted-together query can end up
selecting *every* row in the table rather than just one patient's
record, or worse, running entirely different commands the original
query never intended, because the database cannot tell the difference
between "data the user supplied" and "instructions that are part of
the query itself" once they've been concatenated into one string.
Parameterised queries (as shown just below) avoid this entirely by
sending the query's fixed structure and the user-supplied values to
the database as two genuinely separate pieces, so a value like
`' OR '1'='1` is always treated as a literal, harmless piece of data
to search for — never as part of the query's logic — no matter what
it contains.
]

```r
dbGetQuery(
  con,
  "SELECT * FROM claims.inpatient_episodes WHERE patient_id = $1",
  params = list("PT-00482")
)
```

#heor-practice[
Many HEOR analyses blend a clinical/claims extract from `DBI` with a published unit-cost list imported via `readxl`, and a trial dataset via `haven`. Keep each source's import in its own clearly commented block with the raw object named by its origin (`claims_raw`, `unitcost_raw`, `trial_raw`) before any joining — it makes the eventual data-management appendix of an HTA submission dossier far easier to write, because you can trace every derived variable back to a single named import step.
]

=== Public and institutional APIs

Increasingly, reference data for an HEOR model — WHO Global Health Observatory indicators, World Bank price deflators, or a national TB programme's own API-exposed dashboard — is available as a web API returning JSON rather than a static file. The modern idiomatic approach uses `httr2`, which replaced `httr` as the recommended tidyverse-adjacent HTTP client; the pattern, however, is one you'll recognise from any REST API work.

```r
library(httr2)
library(jsonlite)

# Example: WHO Global Health Observatory API (public, no key required)
resp <- request("https://ghoapi.azureedge.net/api") |>
  req_url_path_append("TB_e_inc_num") |>   # TB incidence indicator code
  req_url_query(`$filter` = "SpatialDim eq 'IND'") |>
  req_perform()

resp_check_status(resp)   # raises an informative error on 4xx/5xx

tb_incidence <- resp |>
  resp_body_json(simplifyVector = TRUE)

tb_incidence_df <- tb_incidence$value   # the JSON payload's tabular "value" array
```

For APIs that require an authentication key, pass it as a header rather than embedding it in the URL, and again source it from an environment variable:

```r
resp <- request("https://api.example-registry.org/v1/indicators") |>
  req_headers(Authorization = paste("Bearer", Sys.getenv("REGISTRY_API_KEY"))) |>
  req_perform()
```

`httr2`'s request objects are immutable and pipeable, which makes a multi-step request (path, query parameters, headers, body) read as a clear sequence of transformations rather than a single dense function call — a small ergonomic advantage over the older `httr::GET()` interface, though `httr::GET()` plus `httr::content()` remains perfectly serviceable if you encounter it in an older codebase.

#pitfall[
Public health APIs change their response schema more often than their documentation is updated. Never assume `resp_body_json()`'s structure is stable release to release — print `str()` of the parsed object immediately after a new API integration, and consider caching the raw JSON response to disk (`jsonlite::write_json()`) alongside the parsed data frame, so that a downstream schema change in your parsing code can be debugged against a frozen snapshot rather than a live, possibly-already-changed endpoint.
]

== 5.5 Data dictionaries, metadata and codebooks

Importing a file correctly is necessary but not sufficient. Every dataset that feeds an HEOR analysis or HTA submission needs an accompanying data dictionary — sometimes called a codebook — that documents what each variable actually means, independent of the analyst who imported it. This is not bureaucratic overhead; it is the artefact that lets a reviewer, a collaborator, or you yourself in eighteen months reconstruct the logic behind a derived variable without re-reading the whole pipeline.

=== What a data dictionary must contain

A complete data dictionary, at minimum, documents for every variable:

#list(
  [*Variable name* as it appears in the dataset, and a short human-readable *label* (e.g. `txn_outcome` → "TB treatment outcome at 12 months").],
  [*Type and units* — numeric currency in which year's USD, a date in which format, a continuous measure's unit of measurement (mg/dL, QALYs, days).],
  [*Value code mappings* for categorical variables — e.g. `1 = Cured`, `2 = Completed`, `3 = Failed`, `4 = Died`, `5 = Lost to follow-up`, matching whatever coding scheme the source system used (often a national or WHO-standard classification).],
  [*Missing-value codes* and their meaning — a claims field coded `-99` for "not applicable" versus `-98` for "known missing" behaves very differently in an analysis, and conflating them silently biases downstream estimates.],
  [*Derivation logic* for any variable that is not raw input — the exact formula or rule used to compute it, e.g. "`cost_per_episode_usd` = sum of `facility_cost` + `medication_cost` + `transport_reimbursement`, inflated to 2023 USD using the World Bank GDP deflator."],
)

For a dataset built up over several processing stages — raw extract, cleaned, derived-variables-added — it is good practice to maintain the dictionary as a living document updated at each stage, not retrospectively reconstructed at write-up time, which is when details are most likely to be misremembered.

=== Practical R approaches

The simplest workable codebook is a data frame — one row per variable, with columns for name, label, type, allowed values, and missingness codes — saved alongside the dataset it describes:

```r
library(tibble)

codebook <- tribble(
  ~variable,              ~label,                              ~type,       ~values,                              ~missing_codes,
  "patient_id",           "Unique patient identifier",          "character", NA,                                   NA,
  "txn_outcome",          "TB treatment outcome at 12 months",  "integer",   "1=Cured; 2=Completed; 3=Failed; 4=Died; 5=LTFU", "-99=Not applicable; -98=Unknown",
  "cost_per_episode_usd", "Total treatment cost, 2023 USD",     "double",    NA,                                   "-99=Not costed"
)

write_csv(codebook, "data/codebooks/tb_outcomes_codebook.csv")
```

This plain-data-frame pattern is transparent, version-controllable, and trivially joinable with the dataset's own column names for an automated consistency check (flagging any dataset column absent from the codebook, or vice versa).

Where the source data already arrives value-labelled — as is typical of `haven`-imported SAS or SPSS files — the `labelled` package lets you preserve and manipulate that labelling natively in R rather than translating it into a separate lookup table:

```r
library(labelled)

# Attach value labels directly to a vector, SAS/SPSS style
txn_outcome <- labelled(
  c(1, 2, 3, 1, 4, 5),
  labels = c(Cured = 1, Completed = 2, Failed = 3, Died = 4, "Lost to follow-up" = 5)
)

var_label(txn_outcome) <- "TB treatment outcome at 12 months"

# Generate a human-readable summary straight from the labelled vector
look_for(txn_outcome)        # one-line variable summary with label and value range
val_labels(txn_outcome)      # the full code -> label mapping

# Convert to factor for modelling, keeping only the chosen labels as levels
txn_outcome_factor <- to_factor(txn_outcome)
```

`labelled` is especially useful when a dataset is re-exported for sharing with a collaborator who expects SPSS- or Stata-style coding; `labelled::write_sav()` and companion functions round-trip the labels back out into those formats, so the codebook travels with the data rather than living only in a separate document that can drift out of sync.

#heor-practice[
Whichever pattern you choose, generate the codebook programmatically from the dataset wherever possible (column names, types, and observed value ranges pulled directly via code) rather than typed by hand, and re-run that generation step every time the dataset is rebuilt. A hand-maintained codebook reliably drifts out of sync with the data within a few pipeline iterations; a codebook partially generated from the data itself cannot drift on the parts it covers.
]

#agency-note[
For HTA submissions in particular, data documentation is not optional polish — it is an explicit regulatory and reimbursement-agency expectation. CDISC's *define.xml* standard requires a machine-readable metadata file accompanying SDTM and ADaM datasets submitted to agencies such as FDA and PMDA, documenting every variable's name, label, type, controlled terminology, origin, and derivation algorithm in a structured, agency-parseable format — the formal, standardised cousin of the codebook patterns shown above. NICE's Health Technology Evaluations Manual (PMG36, 2022) likewise sets out expectations that the data and analyses underpinning a submission be transparent and reproducible by the Evidence Review Group, which in practice is unachievable without variable-level documentation of exactly this kind. Treat the codebook as a submission-grade deliverable from the start of an analysis, not an afterthought assembled under deadline pressure once the modelling is finished.
]

== 5.6 Data quality checks (`pointblank`, `assertr`, `validate`)

Every dominance and efficiency-frontier computation in Chapter 4 assumed that the input tibble of costs and QALYs was clean: no negative costs, no utilities above 1, no silently missing arms. That assumption rarely survives contact with a real data extract. Claims databases carry transcription errors, trial case report forms arrive with "9999" placeholder codes for missing fields, and TB programme registers accumulate duplicate patient IDs across reporting quarters. Before any cost-effectiveness logic runs, the data must be validated — not eyeballed, but checked programmatically against explicit rules that encode what "valid" means for health-economic data. R has three mature packages for this: `pointblank`, `assertr`, and `validate`, each with a slightly different philosophy but the same goal of turning implicit assumptions into explicit, auditable checks.

#shiny-app-box("validation_rule_threshold_tuner", [Drag each validation rule's bounds and watch pass/fail counts update live against a simulated dataset with known, deliberately injected errors.])

`pointblank` builds an *agent* that holds a set of validation rules and then runs them all at once via `interrogate()`, producing a report of which rows and columns failed which rule. This is well suited to a formal, documented QA step — the kind an HTA submission's data management appendix might reference.

```r
library(pointblank)
library(dplyr)

# cost_qaly_tbl: one row per treatment arm, as used in Ch.4's
# dominance pipeline (cost, qaly, strategy columns)
cost_qaly_tbl <- tibble::tibble(
  strategy = c("Standard care", "New regimen", "Combination"),
  cost     = c(1200, 1850, -340),     # note the impossible negative cost
  qaly     = c(0.72, 0.81, 1.04),     # note the impossible utility > 1
  n_missing_followup = c(0, 3, NA)
)

agent <- create_agent(
  tbl = cost_qaly_tbl,
  label = "Cost-QALY QA before dominance analysis"
) |>
  col_vals_gte(columns = cost, value = 0) |>
  col_vals_lte(columns = qaly, value = 1) |>
  col_vals_gte(columns = qaly, value = 0) |>
  col_vals_not_null(columns = c(strategy, cost, qaly)) |>
  interrogate()

agent
# plot/export: get_agent_report(agent, display_table = FALSE)
```

Running `interrogate()` here will flag the "Combination" row twice — once for `cost < 0` and once for `qaly > 1` — *before* a single dominance comparison is attempted. Feeding unvalidated data into the ICER-ranking and dominance logic from Chapter 4 would otherwise produce a plausible-looking but meaningless frontier.

The `pointblank` agent's `interrogate()` report is itself a conventional reporting artefact: HTA submissions' data-management appendices typically summarise exactly this rule-by-rule pass/fail outcome rather than reproducing the raw agent object.

#report-table(
  [Data validation summary for the cost-QALY input table, showing rule-by-rule pass/fail counts as reported in a submission's data-management appendix],
  academic-table(
    columns: (1.8fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Validation rule*], [*N rows checked*], [*N failed*], [*Pass rate (%)*]),
    body: (
      [`cost >= 0` (no negative cost)], [3], [1], [66.7],
      [`qaly <= 1` (utility not exceeding 1)], [3], [1], [66.7],
      [`qaly >= 0` (non-negative utility)], [3], [0], [100.0],
      [`strategy`, `cost`, `qaly` not missing], [3], [0], [100.0],
    ),
    footer: (table.cell(colspan: 4)[Source: `cost_qaly_tbl`; "Combination" row fails both the cost and utility bounds checks],),
  ),
) <tab-ch05-dq-validation>

`assertr` takes a lighter, pipe-native approach, well suited to inline checks inside a `dplyr` pipeline rather than a standalone report:

```r
library(assertr)
library(dplyr)

cost_qaly_tbl |>
  verify(nrow(cost_qaly_tbl) > 0) |>
  assert(within_bounds(0, 1), qaly) |>
  assert(within_bounds(0, Inf), cost) |>
  assert(not_na, strategy, cost, qaly) |>
  # only rows that pass all assertions reach the dominance step
  arrange(cost)
```

`assert()` halts the pipeline with a descriptive error (row index and offending value) the moment a rule is violated, which is useful in an analysis script where you want a hard stop rather than a report to review later. `verify()` checks a logical condition on the whole data frame (e.g. that it is non-empty after a join), and `within_bounds()` is exactly the kind of range check that flags a utility above 1 or a cost below zero.

`validate` separates rule definition from rule application even more explicitly, which scales well when the same rule set needs to be applied to many extracts over time (e.g. successive quarterly TB programme uploads):

```r
library(validate)

rules <- validator(
  cost_nonneg   = cost >= 0,
  qaly_bounded  = qaly >= 0 & qaly <= 1,
  strategy_set  = !is.na(strategy),
  followup_ok   = is.na(n_missing_followup) | n_missing_followup >= 0
)

out <- confront(cost_qaly_tbl, rules)
summary(out)
# sapply(out, function(x) sum(!x@expr)) # count fails per rule
```

`confront()` returns a result object that can be summarised, plotted, or written to a log file, giving a persistent audit trail of exactly which rule failed on which row of which dataset version — valuable when a TB programme analyst needs to justify, months later, why a particular district's quarter was excluded from a cost analysis.

#heor-practice[
Treat validation as a pipeline *stage*, not a one-off script you run when something looks wrong. In a reproducible analysis (Chapter 3's `targets` or a plain `source()` chain), the validation step should sit between "load raw extract" and "compute dominance/ICERs," and the pipeline should fail loudly — not produce a frontier plot — when a rule is violated. For HTA submissions, exporting the `pointblank` or `validate` report alongside the analysis code gives reviewers direct evidence that implausible values (negative costs, utilities > 1, impossible QALY decrements) were checked for and excluded or corrected, not missed.
]

#pitfall[
A validation rule that is too loose is worse than no rule at all, because it creates false confidence. `qaly <= 1` catches an impossible health state but does not catch a QALY of exactly 1.000000 held constant across 40 patient-years of follow-up, which is numerically valid but clinically absurd. Pair range checks with distributional sanity checks (e.g. `col_vals_between()` tightened to a clinically plausible range, or a quick `summary()`/histogram pass) rather than relying on hard mathematical bounds alone.
]

== 5.7 Data governance, privacy and de-identification

Validating values is necessary but not sufficient. Before a TB programme dataset, a claims extract, or a trial case report form ever reaches an R script, it has to be handled in a way that respects the people behind the rows — and, for anyone managing patient-level data professionally, that is a legal obligation as much as an ethical one. The vocabulary matters here, because "anonymous" is used loosely in casual conversation but has a precise technical meaning in every major privacy framework:

#list(
  [*De-identification / anonymization* removes or transforms identifying information such that the remaining data cannot reasonably be linked back to an individual, by anyone, using any reasonably available means. Properly anonymized data generally falls outside the scope of data-protection law entirely — but "properly" is a high bar, especially for small denominators (a district with three TB patients of a rare drug-resistance pattern is not anonymous just because the name column was dropped).],
  [*Pseudonymization* replaces direct identifiers (name, national ID, exact address) with a code or token, but keeps a way — often a separate, access-controlled key table — to re-identify the record if needed. Pseudonymized data is still personal data under most frameworks, because re-identification remains possible; it reduces risk, but it is not the same as anonymization.]
)

In the US, HIPAA sets out two recognised routes to de-identification. *Safe Harbor* specifies an enumerated list of 18 identifier categories (names, geographic subdivisions smaller than a state, all elements of dates except year, phone/fax numbers, medical record numbers, and so on) that must be removed or generalised; it is mechanical and auditable, but blunt. *Expert Determination* instead has a qualified statistician or scientist formally assess and document that the re-identification risk is "very small," using accepted statistical methods — appropriate when Safe Harbor's blunt removals would destroy analytic value (e.g. needing exact dates to compute time-to-event survival curves). Neither route is specific to US data only in spirit — the underlying logic (enumerate-and-remove versus risk-assess-and-document) is a useful mental model anywhere.

The EU's GDPR applies to any personal data concerning an identified or identifiable natural person, with special-category status (and extra safeguards) for health data specifically. For trial or RWE data originating from or concerning EU subjects, GDPR requires a documented lawful basis for processing, data minimisation, and — critically for anyone sharing analysis code or data extracts across borders — restrictions on transferring personal data outside the EU/EEA without an adequate safeguard. Pseudonymization is explicitly recognised in GDPR as a risk-reducing *technical measure*, not an exemption from the regulation.

India's Digital Personal Data Protection Act (DPDPA), 2023, is the relevant framework for anyone working with government health programme data in India — including TB programme (Ni-kshay and related) patient-level records. It establishes general principles that will shape how such data must be governed going forward: processing personal data only for a specified, lawful purpose with the data principal's consent or another permitted legal basis, collecting no more data than necessary for that purpose, implementing reasonable security safeguards against breach, and providing mechanisms for grievance redress. For a government health data role handling patient-level records, the practical implication is that *data minimisation and purpose limitation are not optional best practices — they are converging with statutory obligation*.

#agency-note[
ICH E6(R2) Good Clinical Practice guidance, in its sections on data handling and essential documents, requires that trial data be attributable, confidential, and protected from unauthorised access throughout the trial and in archived records — confidentiality of subject data is treated as a core GCP obligation, not an afterthought bolted on at publication. Any R-based trial or RWE analysis workflow that touches patient-level data should be able to show, concretely, how access to the raw identifiable extract was restricted and how only de-identified or pseudonymized data reached the analysis environment — this is the kind of evidence a GCP audit or an HTA body's data governance review will actually ask to see.
]

On the practical, R-side side of this: the single most common and most avoidable governance failure is a patient-level `.csv` ending up in a public (or even a private-but-over-shared) GitHub repository, because Chapter 2's `git add .` habit does not pause to ask what is in the file. Raw extracts with names, exact dates of birth, or facility-linked IDs small enough to re-identify someone must never be committed to version control, full stop — not even to a repo you believe is private, because history persists, forks happen, and access lists change. The workable pattern is the one this book itself uses throughout: write and share R code against small, clearly-labelled *synthetic or simulated* datasets (as in Chapter 4's cost-QALY tibbles), keep any real patient-level extract in a `.gitignore`'d local or access-controlled location, and if a working example genuinely needs to resemble real data's statistical structure, generate it synthetically (resampling distributions, adding noise, or using a package such as `synthpop`) rather than lightly-perturbing real records and hoping that counts as de-identified.

#pitfall[
Dropping the name and ID columns from a spreadsheet is not de-identification. A TB programme extract with facility name, exact diagnosis date, drug-resistance pattern, and sub-district can re-identify a specific patient through the combination of fields even with no name column at all — this is the well-documented "quasi-identifier" problem. Before calling any dataset de-identified, check cell sizes for rare combinations (small-count suppression), generalise or bin dates and geography where exact precision isn't analytically required, and document which identifiers were removed versus generalised versus retained under restricted access.
]

With the data pipeline now covered end to end — sourcing from clinical, claims, registry, and public-health systems; wrangling and reshaping it reproducibly; and validating and governing it before it ever touches an economic model — the next step in building an evidence base is working backwards from data to the published literature that frames and justifies it. Chapter 6 turns to R's growing toolkit for systematic literature review: searching and deduplicating records across databases, managing screening workflows, and extracting study-level data in a way that is as reproducible and auditable as the data management practices just established here.