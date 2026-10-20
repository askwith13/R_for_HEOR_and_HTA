# Chapter 30: R Packages and Pipelines for Model Development

**Part VI: Reporting, Communication and Deployment** (third and final chapter of this Part — no new Part divider needed, Part VI was opened by Chapter 28).

## Status
Drafted via interactive session (2026-10-20), delegating 30.1-30.4 and 30.5-30.7 to two parallel sub-agents, assembled into one Typst file. ONE revision pass was needed (code_validity scored 5.96 on first draft, 6.02 after fix) — all six Jev rubric dimensions now pass.

## Jev scores (raw, 1-10, after revision)
- Coverage: 8.34
- Technical correctness: 7.05
- Code validity: 6.02 (was 5.96 pre-revision)
- Agency grounding: 7.41
- Internal consistency: 8.42
- Readability (prose-only): 7.15

All six clear the 6/10 threshold.

## What the chapter covers

**30.1 Why package your model.** Four reasons to turn a loose folder of scripts into a proper installable R package: versioning/citability, explicit dependency management via `DESCRIPTION`, documentation that lives with the code, and portable `testthat` tests (cross-referencing Chapter 27). A pitfall box on NOT packaging prematurely — a one-off exploratory script doesn't need full scaffolding.

**30.2 Package structure with `usethis` and `devtools`.** `usethis::create_package()`/`use_r()`/`use_testthat()`/`use_package()` for scaffolding; `devtools::load_all()`/`check()`/`install()` for the development workflow; the `DESCRIPTION` file's `Imports`/`Depends` fields and semantic versioning (MAJOR.MINOR.PATCH) explained; standard package layout (`R/`, `man/`, `tests/`, `DESCRIPTION`, `NAMESPACE`). Exact `usethis`/`devtools` argument signatures explicitly hedged as illustrative rather than version-pinned, continuing the book's tooling-honesty discipline.

**30.3 Documentation with `roxygen2` and `pkgdown`.** `#'`-comment syntax (`@param`/`@return`/`@export` tags) shown via a worked `run_markov_model()` stub; `roxygen2::roxygenise()`/`devtools::document()` regenerate `.Rd` files and `NAMESPACE`; `pkgdown::build_site()` builds a browsable documentation website from the same roxygen docs. An agency-note citing the NICE DSU TSD series and the ERG's model-checking expectation during technical engagement.

**30.4 Pipelines with `targets` and `renv`.** `targets` for a reproducible pipeline (`_targets.R`, `tar_target()`, `tar_make()`), explicitly cross-referencing Chapter 28's scheduling discussion — `tar_make()`'s change-detection only re-runs targets whose inputs have actually changed, a real time-saver once calibration/PSA steps are slow. Combined with `renv` (cross-referencing Chapter 2 and Chapter 28) for dependency-version locking. An agency-note citing CADTH's guidance on reproducible economic-evaluation submissions.

**30.5 Continuous integration with GitHub Actions.** CI explained conceptually (a disposable "runner" machine restores `renv.lock`, runs `R CMD check` + `testthat` on every push), cross-referencing Chapter 2/28's `renv.lock` and 30.2's `devtools::check()`. A heor-practice box on adding a CI status badge to the README; a pitfall explicitly cross-referencing Chapter 27 §27.5's point that a green CI badge is NOT the same as genuine human review — CI catches mechanical breakage, not clinical/conceptual correctness.

**30.6 Sharing models with HTA agencies and reviewers.** Three sharing mechanisms (private repo collaborator access, a tagged release attached to the Chapter 28 dossier, a public repo for genuinely open models). Explains what a git tagged release actually is — a fixed snapshot versus the live, changing main branch — and why pinning a reviewer to a specific release matters for reproducibility. An agency-note citing NICE's Technology Appraisal process requiring the ERG-reviewed model to be a fixed, traceable, versioned artifact.

**30.7 Open-source model licensing and the open-source HEOR movement.** MIT (permissive) vs GPL-3 (copyleft) vs CC-BY compared in a `ref-table`, with an explicit non-legal-advice disclaimer recommending the organisation's legal/IP team for real decisions. References this book's OWN real `LICENSE` file precedent (code=MIT, prose=All Rights Reserved) as a concrete worked example — independently confirmed to match the actual repo `LICENSE` file verbatim. Closes with the open-source HEOR movement (auditable R models vs closed proprietary Excel/TreeAge) tied back to the book's Chapter 1 transparency theme, and a closing transition: Chapter 30 is the final chapter of Part VI, Chapter 31 opens Part VII: HTA in Practice.

## Verification discipline
This chapter is architecturally/procedurally focused (no computed numeric worked examples requiring arithmetic re-verification, consistent with Chapters 1/2/28's precedent for infrastructure-heavy content). Caught and fixed ONE real code-validity issue: a GitHub Actions YAML example was originally drafted wrapped inside an ```` ```r ```` fence with every line commented out ("YAML shown inside an R-labelled fence" per the sub-agent's own acknowledgment) — not genuinely valid/runnable R. Fixed by moving it to a proper ```` ```yaml ```` fence, matching Chapter 28's established convention for non-R code blocks. Independently confirmed two cross-chapter claims: (1) `renv` is genuinely discussed in Chapter 2 (33 mentions in `ch02_r_environment.typ`), supporting the §30.4/30.5 cross-references; (2) the repo's actual `LICENSE` file verbatim matches §30.7's description (MIT for companion code only, prose All Rights Reserved) — not a fabricated or approximate claim.

## Mandatory per-tick steps
- **Image tracker**: 1 new explicit Track-1 skip (C26 — architectural/procedural content already concrete via worked code examples and one comparison table; a `targets` dependency-graph diagram was considered but the chapter's own `_targets.R` listing already shows the dependency chain linearly, so judged non-essential). 0 new Track-2 entries (no R-generated statistical chart content — this chapter is about packaging/shipping a model, not producing plots from data).
- **Shiny candidates**: 0 new genuine candidates — infrastructure/procedural content, not a methodological HEOR parameter suited to interactive exploration; a "targets dependency-graph explorer" was considered and rejected as a developer tool rather than a genuine HEOR-methodology exploration. Total remains 56 across 27 chapters.
- **Code extraction**: 12 R/YAML code blocks extracted to `code/ch30_r_packages_pipelines/`.
- **renv.lock**: 4 packages identified (usethis, devtools, roxygen2/pkgdown, targets — all 4 verified installed on this machine, zero unverified markers, fully honest manifest).
- **Difficult terminology**: 13 boxes inserted (R package, DESCRIPTION file, semantic versioning, NAMESPACE, roxygen2/@export tag, pipeline/dependency graph, build cache/memoisation, continuous integration (CI), YAML workflow file, tagged release, open-source license, permissive vs. copyleft license).

## Compile result
Compiled cleanly on the first pass (and again after the code_validity revision), zero warnings. `book.pdf` grew from 543 to **556 pages**.

## Continuity notes for Chapter 31
Chapter 31 (Agency Requirements and Reference Cases) is the FIRST chapter of Part VII: HTA in Practice — a new `#part-divider("VII", "HTA in Practice")` call IS needed before Chapter 31's `#include`, per the skill's Part-boundary table. It should pick up directly on §30.7's closing transition: now that a model can be built, packaged, documented, piped, tested, shared, and licensed, the book turns from "how models are built and shared" to "what the agencies actually require once a model arrives" at their door.
