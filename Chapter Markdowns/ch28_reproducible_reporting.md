# Chapter 28: Reproducible Reporting

**Part VI: Reporting, Communication and Deployment** (first chapter of this Part — a new real Part VI divider was inserted in `book.typ` immediately before this chapter's `#include`, following the Part I-V precedent).

## Status
Drafted via cron tick (2026-10-20), delegating 28.1-28.4 and 28.5-28.8 to two parallel sub-agents, assembled into one Typst file. All six Jev rubric dimensions passed on the FIRST draft — no revision pass needed.

## Jev scores (raw, 1-10)
- Coverage: 7.87
- Technical correctness: 7.51
- Code validity: 6.13
- Agency grounding: 7.46
- Internal consistency: 8.46
- Readability (prose-only): 7.16

All six clear the 6/10 threshold on the first draft.

## What the chapter covers

**28.1 Quarto and R Markdown for HEOR reports.** Opens by picking up Chapter 27's closing line directly: validation evidence is only useful once documented reproducibly. Explains Quarto vs. classic R Markdown (standalone multi-language CLI tool vs. `rmarkdown`/`knitr` R packages), YAML front matter structure, chunk options (`echo`, `eval`, `warning`, `fig-cap`, `tbl-cap`), and a worked example rendering a TB-model HEOR summary report to both HTML and Word from one `.qmd` source.

**28.2 Parameterised reports.** The `params:` YAML mechanism, `quarto render --execute-params`/`-P key:value` CLI overrides, and an R driver loop over a scenarios data frame using `quarto::quarto_render(execute_params=)` to batch-render one report per scenario with filenames encoding scenario identity — a pitfall box on stale default params when rendering interactively without overrides.

**28.3 Producing Word, PDF, HTML and PowerPoint outputs.** `format:` YAML key listing multiple output targets at once, `reference-doc` for Word/PPT house-style templates, the LaTeX requirement for PDF via `tinytex::install_tinytex()`/`tlmgr_install()`, and `officedown::rdocx_document` + `officer` for native editable Word/PPT elements beyond what Pandoc's generic conversion supports.

**28.4 Publication-ready tables (gt, gtsummary, flextable, kableExtra).** An honest ref-table comparing the four packages' niches (gtsummary for clinical summaries, gt as general-purpose, flextable for Word/PPT-native output, kableExtra for lightweight LaTeX/HTML). A worked ICER/NMB example recomputes `icer = -844.14/0.1440 ≈ -5862.08` and `nmb = 0.1440*50000 - (-844.14) = 8044.14` — independently re-verified, matching the Chapter 25/27 base-case figures exactly — presented as a report-table, then rendered through `gt`, `flextable` and `kableExtra` code. A difficult-terminology box explains dominance (why a negative ICER here means "dominant," not "cost-saving per QALY" in the usual sense).

**28.5 Publication-ready graphics (ggplot2 themes, colour-blind-safe palettes).** A reusable `theme_heor()` built on `theme_minimal()` + `theme_set()`; `viridis::scale_colour_viridis_d()`/`_c()` for colour-blind-safe palettes; `colorspace::simulate_cvd()` for a CVD-simulation preview (a GitHub-only `colorblindr` alternative is mentioned but hedged as not independently re-verified, with a pitfall on GitHub-only package fragility); `ggsave(width=, height=, units=, dpi=)` for print-resolution exports, with an agency-note on journal/NICE figure-resolution requirements.

**28.6 CHEERS 2022 reporting checklist implementation.** Describes CHEERS 2022 (Husereau, Drummond, Augustovski, et al., *Value in Health* 2022;25(1):10-31) accurately as a 28-item checklist, deliberately limiting specific item-number claims to items 1, 15, 20 and 26 (cross-referencing Chapter 11's synthesis methods and Chapter 16's regression reporting) rather than fabricating all 28 item texts. Builds a `cheers_checklist` tracking data frame via `tribble()` and a ref-table of the illustrative subset — correctly NOT a report-table, since it organizes checklist references rather than presenting a freshly computed result.

**28.7 Automating dossier and submission appendices.** Explains dossiers and Quarto child documents via `{{< include >}}`, explicitly analogized to this book's own `book.typ` `#include` structure. Shows a parent dossier document with shared `params:` (country, perspective) visible to every included child, with a pitfall on shared R-session state/object-name collisions across children, and an agency-note citing NICE's Technology Appraisal process multi-section submission structure.

**28.8 Automating routine reports across programmes or districts.** Loops `quarto::quarto_render()` across an illustrative (explicitly fictional) Indian TB district data frame via `purrr::pwalk()` and an equivalent `for` loop, with a pitfall on wrapping batch renders in `tryCatch()`. Closes with a scheduling discussion contrasting a simple `cron` job against a `targets` pipeline (`tar_target()`/`tar_render()`/`tar_make()`), recommending starting simple and reaching for `targets` only once redundant recomputation becomes a real cost.

## Verification discipline
Every numeric claim was independently re-computed before acceptance: the ICER (-844.14/0.1440 = -5862.083...) and NMB (0.1440×50000 - (-844.14) = 8044.14) worked example matches the Chapter 25/27 reference figures exactly. The CHEERS 2022 citation (Husereau et al., *Value in Health* 2022;25(1):10-31) is a real published checklist; item numbers/content were deliberately restricted to the four (1, 15, 20, 26) the drafting sub-agent was confident about rather than inventing wording for all 28 items. Several R function names flagged by the sub-agents as uncertain (`officedown::block_toc()` exact signature, `colorblindr::cvd_grid()`, `tarchetypes::tar_map()` argument details) were either removed, hedged explicitly in-text, or kept only as an illustrative non-runnable sketch — continuing the book's tooling-honesty discipline.

## Mandatory per-tick steps
- **Image tracker**: 1 new explicit Track-1 skip (C24 — chapter content is procedural/workflow-sequential, no structural diagram needed) plus 1 new Track-2 `TODO`-style pending entry (T42, colour-blind-safe palette CVD-simulation comparison grid for SS28.5).
- **Shiny candidates**: 0 new genuine candidates — explicitly logged with reasoning (a CVD-palette-toggle slider considered and rejected as not offering genuine continuous/non-trivial exploration). Total remains 56 across 25 chapters-with-content.
- **Code extraction**: 27 R/YAML/bash code blocks extracted to `code/ch28_reproducible_reporting/`.
- **renv.lock**: 15 packages identified (10 verified installed on this machine, 5 unverified markers — honest manifest, no fabricated versions).
- **Difficult terminology**: 11 boxes inserted (YAML, chunk, render, parameterised report, LaTeX, colour-blind-safe palette, dominant/dominance, checklist-based reporting, dossier, child document, targets pipeline).

## Compile result
Compiled cleanly on the first pass, zero warnings. `book.pdf` grew from 491 to **523 pages**. New Part VI divider inserted before this chapter's include.

## Continuity notes for Chapter 29
Chapter 29 (Interactive Models and Web Applications with Shiny) is the second chapter of Part VI — no new Part divider needed. It should build directly on this chapter's parameterised-rendering and reproducibility discipline, extending from static/batch reports into live interactive front-ends for the same TB Markov model and PSA outputs.
