# Chapter 6 — Systematic Literature Review (SLR) Support in R

**Part:** II. Data for HEOR
**Status:** complete (ONE revision pass on code_validity — see below)

## Sections covered (map to TOC 1:1)
6.1 Search strategy documentation
6.2 Deduplication and screening workflows
6.3 PRISMA flow diagrams in R
6.4 Data extraction templates and extraction QA
6.5 Risk of bias visualisation (`robvis`)
6.6 Text mining and ML-assisted screening

## Bridge from Chapter 5
Opens by explicitly linking to Ch.5's publication-bias foreshadowing
(funnel plots, Egger's test as *detection* tools applied after the
evidence pool exists) and frames this chapter as the earlier stage —
building the evidence pool itself transparently so bias is minimised
going in, not just caught coming out.

## Key claims and notation established (binding for later chapters)
- **§6.1 search documentation**: tibble-based `search_log` (database,
  platform, search_string, date_from/to, date_run, n_hits, limits)
  written to CSV, per PRISMA-S reporting requirements — the exact
  translated Boolean string run in each interface, not one "master"
  string assumed equivalent everywhere. `litsearchr::extract_terms()`
  (fakerake method)/`create_dfm()`/`create_network()`/`find_cutoff()`/
  `reduce_graph()`/`get_keywords()` pipeline for keyword co-occurrence
  term discovery from a seed/naive search.
- **§6.2 dedup/screening**: `synthesisr::read_refs()`/`merge_columns()`
  for multi-database RIS import; `find_duplicates()` exact pass then
  fuzzy (`string_osa`, threshold) pass; `extract_unique_references()`.
  Two-stage screening (title/abstract → full-text) logged per-record;
  `irr::kappa2()` for inter-rater agreement — kappa below ~0.6 flagged
  as a signal to tighten inclusion criteria, not paper over with a
  third reviewer.
- **§6.3 PRISMA flow diagram**: `PRISMA2020::PRISMA_data()` +
  `PRISMA_flowdiagram()` building the diagram directly from counts
  computed in code (never hand-typed), with an itemized
  `exclusion_reasons` tibble reconciled in code against the single
  full-text-excluded count.
- **§6.4 extraction**: long-format (one row per study-outcome)
  `extraction_template` tibble with explicit column types and
  controlled vocabularies; dual independent extraction reconciled
  programmatically with `waldo::compare()` plus a dplyr tolerance-join
  check; adjudicated rows logged with `reviewer_id = "adjudicated"` to
  preserve the audit trail rather than overwrite it.
- **§6.5 RoB visualisation**: `robvis::rob_traffic_light()` and
  `rob_summary()` for both ROB2 (RCTs, domains D1-D5) and ROBINS-I
  (non-randomized, domains D1-D7), each requiring a final `Weight`
  column per the package's real function signature. Both return
  `ggplot2` objects.
- **§6.6 text mining/ML screening**: `tidytext` term-frequency as a
  search-strategy sanity check; `quanteda` PICO-term relevance scoring
  used explicitly ONLY to re-order the screening queue, never to
  exclude; `revtools` topic-modelling triage and external tools
  (Rayyan, Abstrackr) mentioned as complementary. Explicit pitfall:
  none of these replace Cochrane's dual independent screening
  requirement for every record.

## Revision made (code_validity dimension)
First Jev pass scored `code_validity` at **4.75/10** (below the 6/10
threshold), all five other dimensions passing. Investigated by
independently checking the two flagged R snippets against real CRAN
package documentation rather than re-asserting them:
- §6.3: the chapter had called a non-existent `PRISMA2020_data()` —
  the real exported function is `PRISMA_data()`. The chapter also
  called a non-existent `PRISMA_save()` — the package has no such
  function; corrected to its actual documented export route via
  `DiagrammeRsvg::export_svg()` + `rsvg::rsvg_svg()`.
- §6.5: both `robvis` worked examples (ROB2 and ROBINS-I) were missing
  the **`Weight`** column that `rob_traffic_light()`/`rob_summary()`
  require as the final column per the package's real function
  signature and its own worked examples (confirmed via CRAN reference
  manual). Added `Weight` columns to both example tibbles.
- Cross-checked all other code in the chapter (`litsearchr`,
  `synthesisr`, `waldo`, `tidytext`, `quanteda`) against real package
  documentation at the same time — all confirmed correct, including
  `litsearchr::extract_terms()`'s `ngrams = TRUE` argument which was
  present but worth flagging as genuinely real (not invented).
Recompiled cleanly, re-scored: `code_validity` rose to **7.8/10**, all
six dimensions now pass.

## Agency grounding — proactive, all real named documents
Continuing the proactive discipline from Ch.4/5: PRISMA-S extension to
PRISMA 2020 (§6.1), Cochrane Handbook Chapter 4 "Searching for and
selecting studies" (§6.2), the PRISMA 2020 statement (Page et al. 2021,
*BMJ*) Item 16a (§6.3), Cochrane Handbook Chapter 8 (RoB 2.0) and
Chapter 25 (ROBINS-I) plus PRISMA 2020 Item 18 (§6.5), Cochrane Handbook
Chapter 4 again anchoring the §6.6 pitfall on ML-assisted screening.
No fabricated document names or invented statistics.

## Image tracking (per skill's mandatory step 11b)
- **Track 1:** none identified this chapter — no genuinely
  non-data-driven structural/process concept needing a Claude-made
  diagram (the two-stage screening funnel is already a PRISMA diagram,
  Track 2).
- **Track 2:** two entries logged — (a) the rendered PRISMA flow
  diagram from §6.3's own `PRISMA_flowdiagram()` code once Dr Aswath
  runs it; (b) the `robvis` traffic-light and summary bar plots from
  §6.5's `rob2_data`/`robins_data` worked examples. Both have
  `TODO-IMAGE` markers inserted at the exact point in the `.typ` file;
  book compiles cleanly with both present.

## Jev rubric scores (raw, 1-10 scale) — after one revision pass
coverage 8.46, technical_correctness 7.58, code_validity **7.8** (was
4.75 before revision), agency_grounding 6.19, internal_consistency
8.22, readability 6.25. All six dimensions now clear the 6/10
threshold.

## Open items / things later chapters should not contradict
- Chapter 11 (meta-analysis) should build on this chapter's search/
  screening/extraction pipeline rather than re-deriving a literature
  dataset from scratch — the `extraction_template` schema (§6.4) is
  the natural input shape for a `meta`/`metafor` effect-size table.
- Chapter 10 (survival analysis) and later chapters citing extracted
  literature effect sizes should reuse this chapter's `effect_measure`
  controlled vocabulary (`"RR"`, `"OR"`, `"HR"`, `"MD"`) rather than
  inventing new labels.
- **New standing lesson, now explicit for future chapters**: when a
  sub-agent's R code calls a package function by name, independently
  verify the function actually exists with that name/signature against
  real package documentation (CRAN reference manual, GitHub README) —
  not just that the code "looks plausible" for the package. This
  generalizes the Ch.4 lesson (verify stated NUMBERS) to verifying
  stated FUNCTION NAMES/signatures, after this chapter's two real
  invented-function catches (`PRISMA2020_data()`, `PRISMA_save()`) and
  one real missing-argument catch (`robvis`'s required `Weight`
  column).
- Any later chapter using `robvis` (none currently planned, but worth
  flagging) must include the `Weight` column in example data frames.
