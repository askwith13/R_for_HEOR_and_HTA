# Chapter 29: Interactive Models and Web Applications with Shiny

**Part VI: Reporting, Communication and Deployment** (second chapter of this Part — no new Part divider needed, Part VI was opened by Chapter 28).

## Status
Drafted via interactive session (2026-10-20), delegating 29.1-29.4 and 29.5-29.8 to two parallel sub-agents, assembled into one Typst file. All six Jev rubric dimensions passed on the FIRST draft — no revision pass needed.

## Jev scores (raw, 1-10)
- Coverage: 8.20
- Technical correctness: 7.94
- Code validity: 6.34
- Agency grounding: 7.24
- Internal consistency: 8.05
- Readability (prose-only): 7.29

All six clear the 6/10 threshold on the first draft.

## What the chapter covers

**29.1 Shiny fundamentals for model front-ends.** Explains the `ui`/`server` split and the reactive programming model (reactive values from input widgets, `reactive({})` expressions, `observeEvent()`/`observe()` observers), with a minimal complete toy app wrapping a 2-input/1-output ICER calculator. Worked example (treatment cost $5,000, comparator $2,000, QALY gain 0.15) independently verified: incremental cost $3,000, ICER = $3,000/0.15 = $20,000/QALY.

**29.2 Designing a user interface for non-programmers.** `sidebarLayout()` vs `navbarPage()`/`bslib::page_navbar()`; matching widget type to the parameter's mental model (slider for bounded/continuous, numeric for precision, select for named categories); plain-language labelling; `bslib::tooltip()`; progressive disclosure via `accordion()`/`conditionalPanel()` for advanced parameters. A pitfall box on exposing every parameter at once overwhelming a non-technical reviewer. An agency-note citing Australia's PBAC Guidelines Version 5.0 (2016) requirement for a "fully executable electronic model."

**29.3 Modular Shiny with `golem` and `rhino`.** Shiny modules (`moduleServer()`/`NS()`) as the base unit of reuse; `golem` (ThinkR, app-as-a-package convention) vs `rhino` (Posit/Appsilon, stricter structure with a JS/Sass build pipeline) vs plain modules, explicitly hedged as illustrative of each framework's philosophy rather than exact version-pinned syntax, continuing the book's tooling-honesty discipline. A `ref-table` compares all three across 5 dimensions (setup overhead, best-fit use case, testing convention, front-end styling, learning curve).

**29.4 Linking Shiny to the model engine and PSA outputs.** Distinguishes cheap continuously-updating `reactive({})` blocks from expensive `eventReactive()`-gated PSA runs tied to an explicit "Run model" `actionButton()`. Reuses the book's established base-case numbers verbatim (incremental cost -$844.14, incremental QALY 0.1440, incremental NMB $8,044.14 at WTP=$50,000) — independently re-verified: 50000×0.1440 − (−844.14) = 8044.14, exact match to Chapters 25/27/28. A heor-practice box on keeping model logic (testable per Chapter 27) separate from reactive wiring. An agency-note citing NICE DSU TSD 12 (PSA in decision-analytic modelling).

**29.5 Downloadable reports and audit trails.** `downloadHandler()` explicitly calling the SAME `quarto::quarto_render()` pipeline from Chapter 28 (not a separate ad-hoc export route) so the downloaded document matches what the reviewer saw on screen. Audit trail concept via a `log_event()` function appending timestamped rows to a CSV, keyed on Shiny's own `session$token` (anonymous, no personal identifier). A pitfall box on not inadvertently logging free-text/sensitive input. An agency-note citing the NICE DSU TSD series and the ERG reproducibility expectation.

**29.6 Deployment: shinyapps.io, Posit Connect, Docker, servers.** Compares three deployment routes honestly as context-dependent rather than one-size-fits-all: shinyapps.io (managed, simplest), Posit Connect (ties to Chapter 28's scheduled-report mechanism), Docker + self-hosted server (full control, illustrative Dockerfile hedged as not version-verified). A `ref-table` compares all three across 6 dimensions including typical IT/data-governance fit.

**29.7 Security, validation and agency expectations for web-based models.** The `req()`/`validate()`/`need()` input-validation pattern with a worked example; model-exposure concerns and authentication options (shinyapps.io authorized-users tier, Posit Connect auth); a pitfall on validation not being centralized, so a `downloadHandler()` could bypass an on-screen check. An agency-note grounding "what agencies actually expect" in NICE's Technology Appraisal process and its "technical engagement" stage, explicit that an interactive app supplements but never replaces full code access for the ERG.

**29.8 Case study: a transparent, reviewable submission-ready model app.** Capstone combining 29.1-29.7 into one illustrative `app.R` skeleton for the TB Markov model: bounded `numericInput()`s, an `eventReactive()`-gated "Run PSA" button, `validate()`/`need()` checks, `log_event()` audit calls, and a `downloadHandler()` driving the Chapter 28 Quarto pipeline. Closes with a transition to Chapter 30 (R Packages and Pipelines for Model Development).

## Verification discipline
Every numeric claim independently re-computed: the 29.1 toy ICER ($20,000/QALY from $3,000/0.15) and the 29.4 NMB reuse of the book's established base case (50000×0.1440 − (−844.14) = 8044.14, exact match to Chapters 25/27/28 — no drift). The two `academic-table()` calls drafted by the sub-agents used an incorrect call signature (raw `table.header()` + nested row arrays) that did not match `common.typ`'s actual `academic-table(columns:, align:, header:, body:, footer:)` contract — caught and corrected during assembly, both tables visually verified clean post-fix (Table 85, Table 86). `golem`/`rhino` function signatures explicitly hedged as illustrative rather than version-pinned, consistent with the book's tooling-honesty rule. All agency-notes cite a specific named document/process (PBAC Guidelines v5.0, NICE DSU TSD 12, NICE Technology Appraisal "technical engagement"/ERG review) rather than a generic "agencies expect X" sentence.

## Mandatory per-tick steps
- **Image tracker**: 1 new explicit Track-1 skip (C25 — chapter content is architectural/procedural Shiny app-design guidance, already made concrete via real worked code examples and the two comparison tables; no additional structural diagram judged necessary). 0 new Track-2 entries (no R-generated statistical chart content in this chapter — it is about building web apps, not producing plots from data).
- **Shiny candidates**: 0 new genuine candidates — this chapter is ABOUT Shiny apps rather than a methodological topic that would itself benefit from one; explicitly logged with that reasoning, consistent with how other infrastructure/procedural chapters (1, 2, 28) were handled.
- **Code extraction**: pending — run `extract_chapter_code.py --chapter 29` next.
- **renv.lock**: pending — run `generate_chapter_renvlock.py --chapter 29` next.
- **Difficult terminology**: 13 boxes inserted (reactive programming, reactive expression, observer, Shiny module, namespacing, golem, rhino, hot-reloading, downloadHandler(), audit trail, shinyapps.io, Docker image/containerization, reverse proxy, input validation, penetration testing — 14 total across the chapter).

## Compile result
Compiled cleanly on the first pass, zero warnings. `book.pdf` grew from 523 to **541 pages**.

## Continuity notes for Chapter 30
Chapter 30 (R Packages and Pipelines for Model Development) is the third and final chapter of Part VI — no new Part divider needed. It should pick up directly on this chapter's closing transition: with a validated, auditable interactive front end now built, the natural next step is packaging the whole model (code, tests, docs) into a proper installable R package with a reproducible pipeline, rather than a loose collection of scripts.
