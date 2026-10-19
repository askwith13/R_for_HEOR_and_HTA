# Chapter 10 — Survival Analysis for Economic Evaluation

**Part:** III. Statistical Methods for Evidence Synthesis and Analysis
**Status:** complete, with readability flagged to Dr Aswath (see below) —
all other five dimensions clear the 6/10 threshold.

## Sections covered (map to TOC 1:1)
10.1 Kaplan-Meier and life tables (`survival`, `ggsurvfit`, `survminer`)
10.2 Parametric models (`flexsurv`): exponential, Weibull, Gompertz,
log-logistic, log-normal, generalised gamma
10.3 Flexible and spline-based models (`flexsurvspline`, Royston-Parmar)
10.4 Mixture-cure and non-mixture cure models (`flexsurvcure`)
10.5 Piecewise and landmark models
10.6 Model selection: AIC/BIC, visual fit, clinical plausibility
10.7 Proportional hazards diagnostics and non-PH alternatives
10.8 Covariate-adjusted and treatment-effect-specific models
10.9 Extrapolation: external data, background mortality, expert elicitation
10.10 Competing risks and multi-state models (`mstate`, `flexsurv`)
10.11 Reconstructing IPD from published KM curves (`IPDfromKM`)
10.12 Reporting extrapolation per NICE DSU TSD 14 and 21

## Bridge from Chapter 9
Opens by picking up directly where Ch.9 §9.6 left off: `survival::survfit()`
and `Surv()` were introduced there narrowly, for IPCW censored-cost
weighting. Chapter 10 returns to the same two functions and develops the
full survival-extrapolation machinery around them.

## Key claims and notation established (binding for later chapters)
- **§10.1 KM/life tables**: `survival::Surv()`/`survfit()` for the
  non-parametric estimator; `ggsurvfit::survfit2()`+`ggsurvfit()`+
  `add_risktable()` and `survminer::ggsurvplot()` both presented as real,
  valid plotting routes — no preference forced between them.
- **§10.2 parametric models**: `flexsurv::flexsurvreg()` with
  `dist = "exp"/"weibull"/"gompertz"/"llogis"/"lnorm"/"gengamma"` — this
  exact six-distribution set is now the book's standing reference family,
  reused in §10.6, §10.7, §10.9, §10.12 and expected to recur in Ch.17-20's
  decision models whenever survival curves feed a Markov/partitioned
  survival structure.
- **§10.3 flexible/spline models**: `flexsurv::flexsurvspline()` with
  `k = 0/1/2` knots and `scale = "hazard"/"odds"/"normal"`; `k=0` collapses
  to a standard parametric equivalent. Established as a flexibility CHECK
  on the chosen standard model, not usually the base case.
- **§10.4 cure models**: `flexsurvcure::flexsurvcure()`, `mixture = TRUE`
  (explicit π + (1-π)·S_u(t) blend) vs `mixture = FALSE` (non-mixture,
  latent-process form); `anc` argument reused from flexsurv's ancillary-
  parameter mechanism. Pitfall established: a fitted cure fraction can be
  purely a censoring artefact, not evidence of biological cure.
- **§10.5 piecewise/landmark**: `survival::survSplit()` + `coxph(strata())`
  for formal piecewise hazards; informal landmark splicing of empirical KM
  (≤ landmark) with a parametric/spline tail (> landmark) established as
  the more common HEOR-practice pattern. Pre-specified, clinically-motivated
  cut-points required — post-hoc cut-point selection flagged as overfitting.
- **§10.6 model selection**: the three-part discipline — AIC/BIC + visual
  KM-overlay fit across the FULL observed period + clinical plausibility of
  the extrapolated tail — established as the book's standing extrapolation-
  selection standard, directly feeding §10.12's TSD 14 citation.
- **§10.7 PH diagnostics**: `survival::cox.zph()` (Schoenfeld residuals) as
  the standard test; non-PH alternatives are time-varying Cox
  (`survSplit()`+interaction), AFT models (flexsurv with weibull/llogis/
  lnorm — explicitly noted as AFT forms), and hazard-scale
  `flexsurvspline()`.
- **§10.8 covariate-adjusted models**: `flexsurvreg()`'s default behaviour
  (covariates on location/scale) vs the `anc` argument (covariates on
  ancillary/shape parameters, reused from §10.4) — established distinction
  for "population-average" vs "subgroup/shape-varying" treatment effects.
  `summary(fit, newdata = ...)` for arm/covariate-specific curves.
- **§10.9 extrapolation discipline**: four-part layered argument —
  (1) best parametric/spline fit, (2) background-mortality floor explicitly
  tied to Ch.8 §8.5's additive/multiplicative decrement convention (hazard
  floor via `pmax(disease_hazard, bg_hazard)`), (3) external-data
  cross-check via `readr::read_csv()` per Ch.5, (4) forward pointer (not
  developed) to SHELF expert elicitation in Ch.14 §14.7.
- **§10.10 competing risks/multi-state**: cause-specific vs subdistribution
  (Fine-Gray) hazard distinction; `mstate::transMat()`/`msprep()`/`msfit()`
  real workflow for a 4-state TB pathway (TxSuccess→Failure→Retreat→Death,
  Death absorbing from every state); `flexsurvreg()` fitted per-transition
  (subsetting `msdat` on `trans`) for parametric extrapolation of multi-state
  models — this is the pattern a later multi-state decision model
  (Ch.19/21) should reuse rather than re-deriving.
- **§10.11 IPD reconstruction**: real Guyot et al. (2012, *BMC Medical
  Research Methodology*) algorithm described in full (digitize → read risk
  table → back-solve interval-by-interval → output reconstructed IPD);
  `IPDfromKM::getpoints()`/`getIPD()` named as the real exported functions
  implementing it, with exact argument signatures DELIBERATELY left
  unasserted pending `?getpoints`/`?getIPD` verification — same cautious
  pattern established in Ch.8 for `eq5d::eq5d()`.
- **§10.12 agency grounding (the chapter's dedicated agency section)**:
  NICE DSU TSD 14 (Latimer, 2011/2013) and NICE DSU TSD 21 (Rutherford,
  Lambert et al.) both named and described at real specificity — TSD 14
  covers the 6-distribution family + PH testing + visual/clinical-
  plausibility selection; TSD 21 extends to spline/Royston-Parmar models
  and cure models that post-date/exceed TSD 14's scope. Fulfils the
  forward commitment flagged in Ch.2's run-log entry ("Ch.10 must cite
  DSU TSD 14/21").

## Package/function-name verification (continuing Ch.6-9's lesson)
All functions cross-checked as real before acceptance: `survival::Surv()`,
`survfit()`, `coxph()`, `cox.zph()`, `survSplit()`; `ggsurvfit::survfit2()`,
`ggsurvfit()`, `add_confidence_interval()`, `add_risktable()`;
`survminer::ggsurvplot()`; `flexsurv::flexsurvreg()` (dist= argument values
confirmed), `flexsurvspline()` (k=, scale= confirmed), `anc=` argument;
`flexsurvcure::flexsurvcure()` (mixture= argument confirmed);
`mstate::transMat()`, `msprep()`, `msfit()`; `IPDfromKM::getpoints()`,
`getIPD()` (real exported functions implementing Guyot et al. 2012, exact
argument names left unasserted per the eq5d-style caution). No invented
functions found this chapter.

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: one candidate identified — a
  flowchart of the 4-state TB pathway (TxSuccess → Failure → Retreat →
  Death, with Death reachable from every state) from §10.10, which would
  communicate the `mstate::transMat()` structure faster as a diagram than
  as the current prose + code `transMat()` call. Logged as Pending in
  `progress/image_tracker.md`.
- **Track 2 (R-generated charts)**: two candidates identified — (1) a KM
  curve overlaid with multiple parametric fits from §10.2/§10.6 (the single
  most pedagogically useful plot in the chapter — `plot(fit, main=...)`
  output), and (2) an extrapolated-hazard-function plot from §10.12's TSD
  21 discussion (hazard, not survival, scale) showing why spline/cure
  model tails need separate hazard-scale scrutiny. Both logged as Pending;
  no `// TODO-IMAGE` comments inserted in the .typ file since the
  numeric/code diagnostics already carry the pedagogical point without a
  blocking placeholder (same logging-only treatment as Ch.9 §9.3's
  histogram entry).

## Jev rubric scores (raw, 1-10 scale)
First pass: coverage 7.63, technical_correctness 7.55, code_validity 7.01,
agency_grounding 8.3, internal_consistency 8.08, **readability 5.95**
(FAILED, below 6/10 threshold — all five other dimensions passed).

Revision pass (readability only — simplified three dense passages: the
chapter-opening bridge paragraph rewritten as an explicit roadmap listing
each section's purpose, the §10.7 PH-assumption definition sentence
split and the term "PH" introduced explicitly, the §10.10 competing-risks
opening reworked into shorter sentences with a concrete worked example
foregrounded, and §10.12's TSD 14/21 agency-note restructured from dense
bullet-embedded prose into a "four things it asks for" / "two ways it
extends" plain-language framing). Re-scored: coverage 7.68,
technical_correctness 7.54, code_validity 6.9, agency_grounding 8.31,
internal_consistency 8.13, **readability 5.86** (still FAILED, and
essentially unchanged / marginally lower than the first pass).

**This is two consecutive low scores on the same dimension (readability)
across the one permitted revision cycle. Per the skill's stop rule, no
further revision pass was attempted — flagging to Dr Aswath instead of
looping.** Both readability scores (5.95 then 5.86) sit close to but
below the 6/10 line, with the rubric's own stated readability concern
(code-dense chapters covering many packages/functions per section, for a
reader with "basic HEOR exposure growing via this book itself") plausibly
describing Chapter 10 structurally: twelve subsections, each introducing
at least one new package/function, is the highest per-chapter R-surface-
area of any chapter so far in the book. A further revision attempt risks
diminishing returns without a structural change (e.g. splitting
code-density across more worked examples, adding more plain-language
scaffolding between sections) that is better decided by Dr Aswath than
attempted a third time inside this tick.

## Open items / things later chapters should not contradict
- Chapter 11 (Meta-Analysis) should pick up from this chapter's parametric-
  distribution and model-selection vocabulary when it discusses pooling
  survival/time-to-event outcomes in §11.5.
- The six-distribution `flexsurvreg(dist=...)` family, the `anc=` argument
  mechanism, and the AIC/BIC + visual + clinical-plausibility selection
  triad are now established book-wide conventions — later chapters
  (17-21, decision-analytic modelling) building survival-informed Markov
  or partitioned-survival models should reuse this vocabulary rather than
  reintroducing it.
- `mstate::transMat()`/`msprep()`/`msfit()` is now an established real-
  package reference for multi-state pathway modelling; Ch.19/21 building
  multi-state decision models should extend this chapter's TB-pathway
  example rather than inventing a disconnected one.
- `IPDfromKM::getpoints()`/`getIPD()` exact argument names still need
  live verification against the installed package version before a later
  chapter uses them in an exercise or worked example with real code —
  this chapter deliberately left them unasserted.
- **Open flag for Dr Aswath**: readability failed twice in a row on this
  chapter specifically (5.95, then 5.86 after one targeted revision). No
  further automatic revision was attempted per the skill's stop rule.
  Worth a manual look if this chapter is read standalone as a reference.
