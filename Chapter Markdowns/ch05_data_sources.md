# Chapter 5 — Data Sources and Data Management

**Part:** II. Data for HEOR
**Status:** complete (NO revision pass needed — all six dimensions passed on first draft)

## Sections covered (map to TOC 1:1)
5.1 Clinical trial data (CDISC SDTM/ADaM concepts)
5.2 Registries, claims, electronic health records and surveys
5.3 Published literature as a data source
5.4 Importing data: `readr`, `readxl`, `haven`, `DBI`, APIs
5.5 Data dictionaries, metadata and codebooks
5.6 Data quality checks (`pointblank`, `assertr`, `validate`)
5.7 Data governance, privacy and de-identification

## First Part II chapter — milestone
This is the first chapter of Part II (Data for HEOR), opening the book's
second major arc after Part I's foundations. Delegated to 3 parallel
sub-agents (5.1-5.3, 5.4-5.5, 5.6-5.7), assembled into one Typst file.

## Key claims and notation established (binding for later chapters)
- **SDTM vs ADaM, correctly distinguished**: SDTM = collected data,
  organised into domains (`DM`, `AE`, `LB`, `EX`, `VS`, ...); ADaM =
  analysis-ready data derived FROM SDTM (`ADSL` subject-level cornerstone,
  `ADAE`, `ADLB`). Relationship is strictly directional: SDTM → ADaM →
  TLFs. `FL`-suffix flag convention and `TRT01P` (planned) vs `TRT01A`
  (actual) treatment distinction introduced — relevant to any later
  chapter touching trial-derived effectiveness/ITT-vs-per-protocol
  framing.
- **Four real-world data source families** characterized with their
  genuine strengths/weaknesses/biases: registries (prospective,
  condition-defined, selected populations), claims (billing-code-based,
  no clinical detail, upcoding risk), EHR (rich but messy/unstructured/
  interoperability-limited), surveys (only source of genuine self-report
  outcomes incl. utilities — directly foreshadows Chapter 8's utility
  data).
- **Publication bias** explained as a real threat to any literature-
  derived model parameter (funnel plots, Egger's test, trial-registry
  cross-checks as detection tools) — explicitly foreshadows Chapter 6
  (SLR) and Chapter 11 (meta-analysis) without duplicating their content.
- **§5.4 import toolkit**: `readr::read_csv()` with explicit `col_types`
  (never trust the 1000-row type guess), `readxl::read_excel()` with
  `range=`, `haven::read_sas/read_dta/read_sav()` with the
  `haven_labelled` class and `as_factor()`/`zap_labels()` conversion
  choice, `DBI::dbConnect()`/`dbGetQuery()` with parameterized queries
  (leverages Dr Aswath's existing SQL strength directly), `httr2`
  request-pipe pattern against a real WHO GHO API example.
- **§5.5 codebook pattern**: tribble-based codebook data frame (name/
  label/type/values/missing_codes columns) as the baseline, `labelled`
  package (`labelled()`, `var_label()`, `val_labels()`, `to_factor()`)
  for SAS/SPSS-style value-labelled data — ties directly to §5.4's
  `haven` import.
- **§5.6 validation, tied explicitly to Chapter 4's pipeline**: a
  cost/qaly tibble (same shape as Ch.4's `treatments` tibble) is
  validated with `pointblank` (`create_agent()`/`col_vals_gte()`/
  `col_vals_lte()`/`interrogate()`), `assertr`
  (`verify()`/`assert()`/`within_bounds()`), and `validate`
  (`validator()`/`confront()`) — all real CRAN function signatures,
  confirmed no invented functions — explicitly BEFORE running the
  dominance/frontier logic, catching a negative cost and a utility > 1
  in the worked example. This is the first chapter to explicitly chain
  back into Ch.4's exact pipeline pattern as promised in Ch.4's own
  markdown summary.
- **§5.7 governance/privacy, grounded in Dr Aswath's own career context**:
  de-identification/anonymization vs pseudonymization distinction;
  HIPAA Safe Harbor (18 identifier categories) vs Expert Determination;
  GDPR special-category health data + pseudonymization-as-technical-
  measure; India's DPDPA 2023 general principles (purpose limitation,
  data minimisation, security safeguards, grievance redress) stated at
  the level of real principles without fabricating unverified section
  numbers. Explicitly ties back to Chapter 2's Git/GitHub coverage
  (never commit raw patient-level data) and to this book's own practice
  of using synthetic data throughout. Quasi-identifier re-identification
  risk explained with a concrete TB-programme example (facility + exact
  date + drug-resistance pattern + sub-district can re-identify even
  with no name column).

## Agency grounding — proactive, all real named documents
Continuing the proactive-grounding discipline established in Ch.4: CDISC
SDTM/ADaM Implementation Guides + FDA Data Standards Catalog (§5.1), ICH
E3 (§5.1), NICE PMG36 (2022) RWE-source-justification expectation + FDA
RWE guidance (§5.2), NICE PMG36 evidence-search-strategy transparency +
Cochrane Handbook for Systematic Reviews of Interventions (§5.3), CDISC
define.xml + NICE PMG36 ERG-reproducibility expectation (§5.5), ICH
E6(R2) GCP data-confidentiality requirement (§5.7). No fabricated
document names or invented statistics; India's DPDPA 2023 described at
the level of general real principles rather than specific section
numbers not independently verifiable.

## Code
All R code uses real package function signatures — `readr`, `readxl`,
`haven`, `DBI`/`RPostgres`, `httr2`/`jsonlite`, `pointblank`, `assertr`,
`validate`, `labelled`, `dplyr`, `purrr`, `tibble` — confirmed during
assembly review, no invented functions.

## Image tracking (per skill's mandatory step 11b)
- **Track 1:** none identified for this chapter — no genuinely
  non-data-driven structural/process concept needing a Claude-made
  diagram (data-source-type comparison is adequately handled by the
  existing `#list()` enumeration).
- **Track 2:** none identified — this chapter is import/governance/QA
  focused with no R code naturally producing a statistical plot (the
  `pointblank`/`validate` outputs are tabular QA reports, not charts).

## Jev rubric scores (raw, 1-10 scale) — single pass, no revision
coverage 8.53, technical_correctness 7.95, code_validity 8.28,
agency_grounding 8.21, internal_consistency 8.84, readability 7.35.
All six dimensions clear the 6/10 threshold on the first draft.

## Open items / things later chapters should not contradict
- Chapter 6 (SLR support in R) should build directly on §5.3's
  publication-bias framing and the literature-parameter-extraction-log
  pattern introduced here.
- Chapter 7 (missing data) should honor the missing-vs-not-measured
  distinction raised in §5.2's EHR discussion.
- Chapter 8 (HRQoL/utilities) should build on §5.2's framing of surveys
  as the structurally necessary source for utility data.
- Chapter 10 (survival analysis) and Chapter 19 (Markov models) continue
  to owe forward commitments established in Ch.3/Ch.4; unaffected by
  this chapter.
- Any later chapter handling trial-derived effectiveness inputs should
  reuse this chapter's TRT01P/TRT01A (planned vs actual treatment) and
  SDTM-vs-ADaM distinction rather than re-explaining it from scratch.
- Confirmed generalizable pattern continuing: proactive agency-note
  grounding in named real documents from the first draft avoided a
  revision cycle again (4th chapter in a row to do so after Ch.4
  established the proactive pattern) — continue into Ch.6 onward.
