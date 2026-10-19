# Chapter 2 — Setting Up an R Environment for HEOR

**Part:** I. Foundations
**Status:** complete (one revision pass on agency_grounding dimension)

## Sections covered (map to TOC 1:1)
2.1 Installing R, RStudio/Positron and Quarto
2.2 Project structure for HEOR analyses
2.3 Package management with `renv`
2.4 Version control with Git and GitHub
2.5 Working with Stan, JAGS and C++ toolchains
2.6 Containers (Docker) for reproducible models
2.7 Recommended package ecosystem (overview map)

## Key claims / infrastructure established
- R via CRAN; RStudio vs Positron (Posit's VS Code-based IDE, gaining
  traction for multi-language R+Python HEOR work); Quarto for
  reproducible reporting (`quarto::quarto_version()`).
- Project folder convention (binding for all later chapters' worked
  examples): `data-raw/` (immutable raw input), `data/` (derived,
  regenerable), `R/` (reusable functions), `analysis/` (scripts/Quarto
  docs), `output/` (disposable), `renv/` + `renv.lock`. Scaffolded via
  `usethis::create_project()`.
- `renv` workflow: `renv::init()` → `renv::snapshot()` →
  `renv::restore()`. `renv.lock` is plain JSON, version-controlled,
  records R version + exact package versions/sources.
- Git/GitHub: PR review framed explicitly as mirroring HTA agency
  technical review. `.gitignore` discipline: commit `renv.lock`, NEVER
  commit patient-level data (even transiently — Git history retains it).
- Stan/JAGS: `cmdstanr` recommended over `rstan` (thinner wrapper,
  tracks Stan releases faster). C++ toolchain required per-OS: Rtools
  (Windows), Xcode CLI tools (Mac), build-essential (Linux). Real
  functions: `cmdstanr::check_cmdstan_toolchain()`,
  `cmdstanr::install_cmdstan()`.
- Docker: `rocker/r-ver` base image pins OS/system libs/R version
  beyond what `renv` can cover; worked example Dockerfile chains
  `renv::restore()` inside the container. Posit Package Manager
  (`packagemanager.posit.co`) for fast binary installs + dated CRAN
  snapshots. Decision rule given: containerize only if a third party
  without R expertise must independently reproduce exact numbers;
  otherwise `renv` alone suffices.
- §2.7 package ecosystem table — the single most load-bearing table in
  the book's early chapters. Maps packages to specific later chapter
  numbers (binding cross-references other chapters should honor):
  - Data wrangling (tidyverse, data.table) → Ch. 3–5
  - Survival analysis (survival, flexsurv, flexsurvcure) → Ch. 10
  - Meta-analysis (meta, metafor) → Ch. 11
  - NMA (netmeta, gemtc, multinma) → Ch. 12
  - Bayesian (brms, rstan, cmdstanr) → Ch. 14
  - Decision trees (rdecision, heemod) → Ch. 18
  - Markov/cohort (heemod, hesim) → Ch. 19
  - Uncertainty/VOI (BCEA, dampack, voi) → Ch. 25–26
  - Missing data (mice, Amelia, missForest) → Ch. 25
  - Reporting (Quarto, gt, gtsummary, flextable) → Ch. 28
  - Interactive apps (shiny, golem, rhino) → Ch. 29

## Agency grounding — specific citations now anchored in this chapter
(Binding precedent: later chapters' agency-note callouts should name
specific guidance documents, not vague "agencies expect X" language —
this is what the revision pass fixed.)
- NICE technology appraisal process: requires submission of the
  *executable* model (not just a written methods description) so the
  Evidence Review Group (ERG) can independently re-run and verify it
  during technical engagement.
- NICE DSU TSD 2 (network meta-analysis methodology, → Ch. 12):
  explicitly requires reporting of software and MCMC convergence
  diagnostics used for a Bayesian NMA, not just point estimates.
- CADTH Guidelines for the Economic Evaluation of Health Technologies:
  requires an electronic copy of the submitted model.
- Cross-reference flagged for Ch. 10: NICE DSU TSD 14 and TSD 21
  (survival extrapolation) are named here as examples of the DSU TSD
  series — Ch. 10 should actually deliver on this reference.

## Code
Real, technically accurate code across R, bash, and one Dockerfile.
No invented functions/packages — `renv::init/snapshot/restore()`,
`usethis::create_project()`, `cmdstanr::check_cmdstan_toolchain()`,
`cmdstanr::install_cmdstan()`, git CLI commands, and the Dockerfile's
apt packages (`libxml2-dev`, `libcurl4-openssl-dev`, `libssl-dev`,
`gfortran`) are all genuine.

## Notation / terminology — no changes from Chapter 1
ICER = ΔC/ΔE not restated here (infrastructure chapter, correctly out
of scope). Callout conventions (heor-practice, pitfall, agency-note,
learning-objectives) used identically to Chapter 1's established
pattern — confirmed by internal_consistency score of 8.68/10.

## Jev rubric scores (raw, 1-10 scale)
**First pass:** coverage 7.78, technical_correctness 8.02, code_validity
7.87, agency_grounding **2.81 (FAILED, revision triggered)**,
internal_consistency 8.82, readability 6.45.

**After revision** (strengthened 3 agency-note callouts with named,
specific guidance documents instead of generic "agencies expect..."
language): coverage 7.51, technical_correctness 7.84, code_validity
7.55, **agency_grounding 7.91 (PASSED)**, internal_consistency 8.68,
readability 6.46. All six dimensions clear the 6/10 threshold.

## Open items / things later chapters should not contradict
- Chapter 10 must actually cite NICE DSU TSD 14 and TSD 21 by name for
  survival extrapolation, since Chapter 2 already name-drops them as a
  forward reference — don't let that promise go unfulfilled.
- Chapter 12 must actually cite NICE DSU TSD 2's convergence-diagnostic
  reporting requirement, since Chapter 2 already attributes this claim
  to Ch. 12 specifically.
- The §2.7 package-to-chapter table is now a binding map — if any later
  chapter ends up NOT covering a package promised here (e.g. if Ch. 19
  ends up not meaningfully distinguishing heemod vs hesim), that is an
  internal-consistency problem worth catching at that chapter's own
  Jev-scoring stage, not deferred to a final audit.
- Lesson for future chapters' agency-note callouts: generic "HTA
  agencies increasingly expect X" framing scores poorly on Jev's
  agency_grounding dimension — name the specific document/process step
  every time (DSU TSD numbers, named guideline documents, specific
  process stages like "technical engagement" or "ERG review").
