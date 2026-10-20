# Chapter 27: Model Calibration, Validation and Quality Assurance

**Part V: Uncertainty, Value of Information and Model Validation** (third and final chapter of Part V — no new Part divider needed, Part V was opened by Chapter 25).

## Status
Drafted via cron tick (2026-10-20), delegating 27.1-27.3 and 27.4-27.6 to two parallel sub-agents, assembled into one Typst file. All six Jev rubric dimensions passed on the FIRST draft — no revision pass needed.

## Jev scores (raw, 1-10)
- Coverage: 8.46
- Technical correctness: 7.58
- Code validity: 7.52
- Agency grounding: 6.68
- Internal consistency: 8.55
- Readability (prose-only): 6.92

All six clear the 6/10 threshold on the first draft.

## What the chapter covers

**27.1 Calibration methods.** Opens with the chapter's running problem: the TB Markov model's "On-treatment-failed to Cured" silent transition probability (`p_hidden`) is not directly observed in trial data. Calibrates it against an illustrative registry 5-year mortality target (32%) via random search (500 `runif()` draws) and `optim(method="Nelder-Mead")`, converging to `p_hidden = 0.084` predicting 31.7% (0.3 percentage-point gap) — a report-table presents target vs. predicted. Describes Bayesian calibration (prior -> likelihood -> MCMC posterior), Approximate Bayesian Computation (ABC, rejection sampling on simulated-vs-observed distance), and Incremental Mixture Importance Sampling (IMIS, sequential importance-sampling refinement) conceptually, explicitly declining to assert unverified `BayesianTools`/`EasyABC` function signatures rather than inventing syntax — continuing the book's established tooling-honesty discipline. A pitfall box flags that single-target calibration is underdetermined; an agency-note points to the ISPOR-SMDM Task Force-7 model-validation report (see 27.4 for its full citation).

**27.2 Cross-validation of model structure.** Distinguishes calibrating a parameter from validating a model's *structure*: splits the registry data into a training target (5-year mortality, used in 27.1) and a held-out target (an independent cohort's 3-year mortality), and checks whether the model — calibrated only on the training target — also predicts the held-out target well. A pitfall box warns that held-out data must be genuinely independent of whatever shaped the model's structural choices, or the check is falsely reassuring.

**27.3 Verification: unit testing, extreme-value tests, replication.** Real `testthat::test_that()` code checking the TB transition matrices' rows sum to 1 (`tolerance = 1e-8`, deliberately loose enough for floating-point noise but tight enough to catch a real omitted transition). An extreme-value test forces the "Well" state's mortality probability to exactly 1 and checks the model predicts zero survivors after one cycle — the correct answer is mathematically determinate regardless of clinical plausibility. A replication check uses `set.seed()` + `saveRDS()`/`readRDS()` to confirm a second run (same seed, different session/machine) reproduces Chapter 25's exact base-case numbers (incremental cost -$844.14, incremental QALY 0.1440, incremental NMB $8,044). Closes with a heor-practice box recommending independent replication before any HTA submission.

**27.4 Validation frameworks (AdViSHE, TECH-VER, ISPOR-SMDM).** Opens with an explicit verification-vs-validation bridge sentence (verification = "did we build the model right," 27.1-27.3; validation = "did we build the right model," 27.4-27.6). Describes AdViSHE (Vemer, Corro Ramos, van Voorn, Al, Feenstra, 2016, *Pharmacoeconomics*) and its five domains (conceptual, input data, implementation, operational, other validation) with a ref-table mapping each domain to the book's own chapters. Cites Eddy, Hollingworth, Caro, Tsevat, McDonald, Wong (2012) ISPOR-SMDM Modeling Good Research Practices Task Force-7, "Model Transparency and Validation," by full name — the same taxonomy (face/internal/cross/external validity) that structures 27.6. TECH-VER is explicitly described only at a general conceptual level since no single canonical citation could be confirmed, rather than inventing an author/year.

**27.5 Code review and peer review practices.** Git-based pull-request review (cross-referencing Chapter 2), second-modeler "black-box" independent replication (building the same model from the same inputs without seeing the original code — common HTA practice), and `testthat`-based CI (cross-referencing 27.3) as three complementary layers of scrutiny. An agency-note grounds the value of independent replication in Eddy et al. (2012); a pitfall warns that a green CI badge is not the same as genuine human review.

**27.6 Face, internal, cross and external validity.** Works through all four senses from the Eddy et al. (2012) taxonomy: face validity (qualitative expert judgment, cross-referencing Chapter 17's model-conceptualization step), internal validity (arithmetic/logic self-consistency, cross-referencing Chapter 19 and 27.1-27.3's unit tests), cross-validation (comparing against *other, independently built* models of the same decision problem — with an explicit difficult-terminology box disambiguating this from Chapter 16's statistical/ML cross-validation sense, a genuine naming collision flagged directly), and external/predictive validity (model projections vs. later real-world outcomes, cross-referencing Chapter 15's RWE methods as the data source). A worked illustrative example computes the gap between a model-predicted 78% 10-year survival and an illustrative observed 74%: absolute difference 4 percentage points, relative difference (78-74)/74*100 ≈ 5.41% — independently verified arithmetic, presented in a report-table. Closes with a transition to Chapter 28 (Reproducible Reporting): this chapter's verification and validation evidence is only useful once it is documented and communicated in a reproducible form.

## Verification discipline
Every numeric example was independently computed before being accepted: the Nelder-Mead calibration gap (0.3pp), the external-validity absolute/relative difference (4pp / ≈5.41%, confirmed (78-74)/74*100 = 5.405405...), and the Chapter 25 base-case reference numbers reused in the 27.3 replication example (incr. cost -$844.14, incr. QALY 0.1440, incr. NMB $8,044). Both named citations (Vemer et al. 2016 AdViSHE; Eddy et al. 2012 ISPOR-SMDM Task Force-7) are confirmed real published documents — TECH-VER was explicitly hedged rather than given a fabricated citation, continuing the book's standing tooling-honesty rule.

## Mandatory per-tick steps
- **Image tracker**: 1 new explicit Track-1 skip (C23 — calibration/verification content already made concrete via worked numeric examples) plus 2 new Track-2 `TODO-IMAGE` entries pending (T40 random-search calibration landscape, T41 external-validity comparison bar chart).
- **Shiny candidates**: 2 new genuine candidates added (Calibration Target Search Explorer §27.1, Extreme-Value Test Sandbox §27.3). Total now 56 across 25 chapters.
- **Code extraction**: 6 R code blocks extracted to `code/ch27_calibration_validation/`.
- **renv.lock**: 1 package (`testthat`), verified installed.
- **Difficult terminology**: 5 boxes inserted (calibration target, Nelder-Mead optimization, Approximate Bayesian Computation, unit testing, face validity, cross-validation [health-economic sense, naming-collision disambiguation]).

## Compile result
Compiled cleanly on the first pass, zero warnings. `book.pdf` grew from 467 to **491 pages**.

## Continuity notes for Chapter 28
Chapter 28 (Reproducible Reporting) is the first chapter of Part VI: Reporting, Communication and Deployment — no new Part divider needed yet (Part VI opens at Chapter 28, so a `#part-divider("VI", "Reporting, Communication and Deployment")` call IS needed before Chapter 28's `#include`, per the skill's Part-boundary table). It should pick up directly on §27.6's closing observation: this chapter's verification/validation evidence needs a reproducible way to be documented and communicated.
