#import "../common.typ": *

= Appendix F. Data Sets Used in This Book

Per this book's stated policy (see the opening chapters' data-handling guidance): no real patient-level, commercially licensed, or otherwise non-redistributable data is used anywhere in this book. Every worked example's numbers are either generated inline by the code itself (synthetic, `set.seed()`-reproducible, and clearly labelled as illustrative) or loaded from a small number of named placeholder files that stand in for the kind of file a reader's own analysis would actually load.

This appendix is the data dictionary for those placeholder files: where each one is referenced, what it illustrates, and what a reader adapting the example would need to supply in its place. None of the files below ship as real data inside the companion repository -- each is a stand-in filename chosen to make the import code read naturally, not a dataset this book distributes.

== Data dictionary

#ref-table(
  [Placeholder data files referenced by this book's companion code, by chapter],
  academic-table(
    columns: (1.6fr, 1fr, 2.6fr),
    align: (left, left, left),
    header: ([Filename], [Referenced in], [What it illustrates]),
    body: (
      [`data/unit_costs_2023q4.csv`], [Chapter 5], [A quarterly unit-cost extract exported from a hospital costing database, illustrating `readr::read_csv()` with explicit column-type specification and `problems()`/`spec()` diagnostics.],
      [`data/registry_extract_2023.xlsx`], [Chapter 5], [A multi-sheet registry extract, illustrating `readxl::excel_sheets()` for sheet discovery followed by `read_excel()` for a specific sheet.],
      [`data/adsl.sas7bdat`], [Chapter 5], [A SAS transport/dataset file in the ADaM subject-level-analysis-dataset format, illustrating `haven::read_sas()` for SDTM/ADaM-style clinical trial data exchange.],
      [`data/hh_survey_2022.dta`], [Chapter 5], [A Stata `.dta` file illustrating `haven::read_dta()`, modelled on the kind of household-survey export a DHS (Demographic and Health Surveys) extract would produce.],
      [`extraction_reviewerA.csv`], [Chapter 6], [One of two independent reviewers' systematic-literature-review data-extraction spreadsheets, illustrating a dual-screening QA comparison via the `waldo` package.],
      [`extraction_reviewerB.csv`], [Chapter 6], [The second reviewer's independent extraction spreadsheet, compared against reviewer A's for the same QA check.],
      [`trial_econ_extract.csv`], [Chapter 7], [A trial economic extract with utility scores and total healthcare cost over follow-up, used as the worked dataset for the chapter's missing-data handling methods.],
      [`registry_survival_5yr.csv`], [Chapter 10], [An external registry's survival data, used to extend a trial's own observed Kaplan-Meier curve beyond its follow-up window.],
      [`national_life_table.csv`], [Chapter 10], [A national all-cause life table, used as a plausibility bound against which an extrapolated survival curve can be sanity-checked.],
      [`data/raw_cohort.csv`], [Chapter 30], [A raw cohort file illustrating the first `tar_target()` input of a `targets`-based reproducible pipeline.],
    ),
    footer: (table.cell(colspan: 3)[All ten files are placeholder filenames only; no file of any of these names ships inside this book's companion repository. A reader adapting a worked example should either generate an equivalent synthetic dataset inline (the pattern most other chapters in this book already follow) or substitute their own real file at that path.],),
  ),
)

== How to treat a placeholder when adapting an example

Two honest paths exist for turning any row above into something that actually runs, and the right choice depends on what the surrounding worked example is trying to teach:

#heor-practice[
  If the surrounding code's point is the *downstream analysis* (fitting a survival model, checking missing-data patterns, running a QA comparison) rather than the *import mechanics themselves*, the cleanest fix is almost always to replace the `read_csv()`/`read_excel()`/`read_sas()`/`read_dta()` call with a short block of inline data generation -- `data.frame()` plus `rnorm()`/`rbinom()`/`rgamma()` and a fixed `set.seed()`, exactly as most other chapters in this book already do. This keeps the example fully self-contained, removes the external-file dependency entirely, and is the pattern this book favours wherever the import step itself is not the lesson.
]

#pitfall[
  Chapter 5's own point in its file-format section is teaching the import mechanics -- `readr`, `readxl`, `haven`, and `DBI` each handle a different real-world file format with different pitfalls (column-type guessing, multi-sheet navigation, labelled-value decoding, parameterised queries). Silently swapping those four worked examples for inline-generated data would remove the exact lesson that section exists to teach. For those four files specifically, the more honest fix is to substitute a small, real, synthetic file of the reader's own construction -- built once, saved to disk, and then genuinely read back with the real import function -- rather than skipping the read step altogether.
]

No real patient-level, commercially licensed, or otherwise non-redistributable file should ever be placed in a `data/` folder intended for public release, regardless of which path above is chosen.
