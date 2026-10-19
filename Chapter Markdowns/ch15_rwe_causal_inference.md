# Chapter 15 — Real-World Evidence (RWE) and Causal Inference

**Part:** III. Statistical Methods for Evidence Synthesis and Analysis
**Status:** complete — five of six Jev rubric dimensions pass; readability
remains well below the 6/10 threshold after one revision pass (flagged,
not looped further, per the skill's two-consecutive-low-scores stop rule
— fourth consecutive chapter with this flag after Chapters 10, 13, 14,
and by a wide margin the lowest readability score of the four so far).

## Sections covered (map to TOC 1:1)
15.1 Fit-for-purpose RWD and RWE frameworks
15.2 Study design: cohort, case-control, target trial emulation
15.3 Confounding and bias, with DAGs (`dagitty`, `ggdag`)
15.4 Propensity scores: matching, weighting, stratification (`MatchIt`, `WeightIt`, `cobalt`)
15.5 Doubly robust estimators and g-methods
15.6 Instrumental variables and regression discontinuity
15.7 Difference-in-differences and interrupted time series
15.8 Treatment switching and crossover adjustment (RPSFTM, IPCW)
15.9 E-values and quantitative bias analysis
15.10 OHDSI/OMOP workflows in R
15.11 Using external control arms and synthetic control arms

## Bridge from Chapter 14
Opens by contrasting Ch.14's trusted-structure evidence (trial data,
pooled posteriors) with this chapter's untrusted-structure evidence
(RWD never collected to answer a causal question). Explicitly restates
and follows through on Ch.14's closing framing: RWE/causal inference
methods are predominantly frequentist in this book, Bayesian is an
occasional option, not the default — propensity scores, DR estimators,
IV/RD, DiD/ITS are all introduced frequentist-first.

## Key claims and notation established (binding for later chapters)
- **§15.1**: FDA's 2023 RWD/EHR-and-claims guidance two-part
  relevance/reliability test named as the de facto global RWE-fitness
  standard; EMA's DARWIN EU named as the parallel European framework.
  "Data provenance and fitness memo" introduced as a pre-analysis
  artefact, illustrated with a toy `tibble::tribble()` checklist.
- **§15.2**: Target trial emulation (Hernán & Robins 2016, *AJE*)
  formalised as "specify the hypothetical trial protocol, then specify
  the emulation" — explicit protocol table built in R. Immortal time
  bias and prevalent-user bias both named and demonstrated with code:
  `time_zero` set to `regimen_start`, never to `diagnosis_dt`, with a
  `lead_in_days` diagnostic column as the audit check.
- **§15.3**: DAG-based confounder/mediator/collider taxonomy built with
  `ggdag::dagify()`; `dagitty::adjustmentSets()` used to derive the
  minimal sufficient adjustment set programmatically — the toy TB DAG
  correctly excludes `nutrition` (a mediator) from the returned set
  `{hiv}`. STROBE statement (22-item checklist, TREND/RECORD
  extensions) introduced as a drafting template, not a post-hoc audit.
  Explicit statement that this chapter's methods are conventionally
  frequentist, Bayesian causal inference is the deliberate exception.
- **§15.4**: Propensity score $e(x) = P(T=1|X=x)$ formally defined
  (Rosenbaum & Rubin). `MatchIt::matchit()` (nearest/caliper),
  `WeightIt::weightit()` (ATE vs ATT estimands explicitly contrasted),
  `cobalt::bal.tab()`/`love.plot()` for balance diagnostics, SMD < 0.1
  established as the book's balance threshold. **Worked IPTW ATE
  hand-calculation independently re-verified during assembly**: 6-patient
  toy cohort, treated weighted mean $60/6=10.000$, control weighted mean
  $23/6=3.833$, ATE $=6.167$ weeks — arithmetic redone from scratch
  during assembly per the Ch.4 standing lesson, matches the chapter's
  own R code output comment (`#> 6.166667`).
- **§15.5**: AIPW formula stated explicitly with both the
  residual-correction and plain-regression terms; `AIPW::AIPW$new()`
  and a lighter weighted-regression DR alternative both shown.
  G-computation coded by hand via `predict()` under counterfactual
  `trt` assignment; `gfoRmula`/`ipw::ipwtm()` named for genuinely
  time-varying treatment-confounder feedback (the TB adherence →
  smear-result → regimen-change loop used as the motivating example).
- **§15.6**: IV exclusion-restriction/independence assumptions stated
  formally; `ivreg::ivreg()`/`AER::ivreg()` 2SLS with
  `diagnostics=TRUE` (weak-instrument F-test, Wu-Hausman, Sargan) —
  F<10 named as the conventional weak-instrument threshold.
  `rdrobust::rdrobust()`/`rdplot()` for RD with the `rddensity`
  manipulation-test package named as the companion check.
- **§15.7**: DiD estimator formula stated; naive TWFE flagged as
  biased under staggered adoption (Goodman-Bacon negative-weighting
  problem named explicitly) with `did::att_gt()`/`aggte()` as the fix.
  ITS via `segmented::segmented()` and an explicit level/slope-change
  `lm()` specification; Newey-West SE correction
  (`sandwich::NeweyWest()`) named for residual autocorrelation.
- **§15.8**: NICE DSU TSD 16 (Latimer & Abrams, treatment switching)
  named as the governing reference for RPSFTM/IPCW choice. `rpsftm`
  CRAN package (Simon Bond) and `ipcwswitch` package (Louis Y et al.)
  both used with real function calls; tooling-honesty note that
  neither covers every design variant (two-way switching, re-switching)
  — continuing the Ch.13 MAIC hand-coding precedent.
- **§15.9**: E-value (VanderWeele & Ding 2017) formally introduced;
  `EValue::evalues.RR()/OR()/HR()/OLS()` all shown with real arguments.
  First `report-table` use in this chapter: a 4-endpoint E-value
  summary table, correctly using `report-table` (not `ref-table`)
  since the values are illustrative computed outputs presented in a
  standard sensitivity-reporting format.
- **§15.10**: OHDSI/OMOP CDM introduced; `DatabaseConnector`,
  `FeatureExtraction`, `CohortMethod` (real, actively maintained OHDSI
  packages) shown end to end (`getDbCohortMethodData`/`createPs`/
  `matchOnPs`/`fitOutcomeModel`). Explicit scope-of-use caveat: this
  infrastructure is overkill for a single flat-file analysis and earns
  its complexity only for federated multi-site network studies.
- **§15.11**: External control arm (ECA) vs synthetic control arm
  distinguished (Abadie/Diamond/Hainmueller method named for the
  latter). `MatchIt`-based propensity-matched ECA coded. Tooling
  honesty: no CRAN package specifically targets clinical synthetic
  control construction; `Synth`/`tidysynth` named as adjacent
  econometric tools requiring real adaptation — continuing the
  Ch.6/12/13 non-fabrication pattern. Closing paragraph forward-points
  to Chapter 16 (GLMs, mixed-effects, zero-inflated models,
  quantile/ordinal regression, ML for heterogeneous treatment effects,
  subgroup analysis).

## Package/function-name verification (continuing Ch.6-14's lesson)
`dagitty::dagify()`/`adjustmentSets()`, `ggdag::ggdag()`/
`ggdag_adjustment_set()`, `MatchIt::matchit()`/`match.data()`,
`WeightIt::weightit()`, `cobalt::bal.tab()`/`love.plot()`,
`AIPW::AIPW$new()`, `ivreg::ivreg()`, `rdrobust::rdrobust()`/`rdplot()`,
`did::att_gt()`/`aggte()`/`ggdid()`, `segmented::segmented()`,
`rpsftm::rpsftm()`, `ipcwswitch::ipcw.data()`/`ipcw.est()`,
`EValue::evalues.RR()/OR()/HR()/OLS()`, OHDSI's `DatabaseConnector`/
`FeatureExtraction`/`CohortMethod` real exported functions — all
confirmed real, standard functions/signatures. `rpsftm` and
`ipcwswitch` both explicitly flagged as not covering every switching
design variant rather than presented as universal solutions. No single
CRAN package claimed for clinical synthetic control arms — explicitly
stated as a gap, with `Synth`/`tidysynth` named as adjacent-but-not-
equivalent econometric tools.

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: one new candidate logged — a DAG
  render of the §15.3 TB regimen/HIV/nutrition/site-capacity graph
  (the `ggdag::ggdag()` call already produces this programmatically in
  R, so this is really a Track-2-style R-generated image, logged under
  Track 1 only because it is diagram-like rather than a statistical
  plot; flagged for reclassification review). Logged as Pending.
- **Track 2 (R-generated charts)**: four new candidates logged: (1)
  the §15.3 `ggdag` DAG plot itself, (2) §15.4's `love.plot()`
  covariate-balance plot, (3) §15.6's `rdplot()` RD scatter, (4)
  §15.7's DiD pre-trend line plot and `ggdid()` event-study plot. All
  logged as Pending in `image_tracker.md`.

## Jev rubric scores (raw, 1-10 scale)
First pass: coverage 7.84, technical_correctness 7.55, code_validity
7.33, agency_grounding 6.56, internal_consistency 7.91,
**readability 3.40** (FAILED — only dimension below threshold, and by
a much wider margin than any prior flagged chapter).

Revision pass (readability only): rewrote the chapter-opening bridge
into four short paragraphs instead of three dense ones; broke the
§15.5 opening (DR-motivation) sentence into three short sentences;
broke the §15.3 opening (DAG-motivation) sentence into two short
paragraphs; broke the §15.9 opening (E-value motivation) sentence into
two short sentences.

Re-scored: coverage 7.93, technical_correctness 7.56, code_validity
7.38, agency_grounding 6.52, internal_consistency 7.99,
**readability 3.35** (still FAILED — effectively flat, slightly lower).

Per the skill's stop-after-two-consecutive-low-scores rule, did **NOT**
attempt a third revision. **Flagged to Dr Aswath**: Chapter 15 is the
FOURTH consecutive chapter in the book with an unresolved readability
flag after Chapters 10, 13, and 14 — and its score (3.35-3.40) is
markedly worse than any of the three prior flagged chapters (which
ranged 5.17-5.95). Sentence-splitting, the fix pattern applied
successfully nowhere in this cluster, clearly is not the real lever.
This chapter is also, on a plain read, the most method-dense chapter
in the book so far: eleven subsections covering eleven substantially
distinct causal-inference methods (target trial emulation, DAGs, PS
matching/weighting, DR/g-methods, IV, RD, DiD, ITS, treatment
switching, E-values, OMOP, external controls), each requiring its own
notation, its own R package, and its own named agency reference, with
comparatively little room to let any one idea breathe. The hypothesis
recorded in Ch.10/13/14's markdowns — that high concept-density is the
real driver, not sentence length — is now strongly reinforced by this
chapter's much lower score. **This strengthens the case, raised in
Ch.14's markdown, for a dedicated cross-chapter readability
pass/restructuring effort covering Chapters 10, 13, 14, and now 15
together** (e.g. splitting some of the densest subsections into their
own numbered sub-steps, adding more worked mini-examples, or in
Chapter 15's case specifically, considering whether 11 subsections in
one chapter is simply too many for the stated audience and whether a
future revision should split this chapter into two) — continuing to
patch chapter-by-chapter is very unlikely to move the readability
score meaningfully based on four data points now pointing the same way.

## Open items / things later chapters should not contradict
- Chapter 16 (Regression Models for HEOR Data) should pick up directly
  from this chapter's closing transition (GLMs, mixed-effects,
  zero-inflated models, quantile/ordinal regression, ML for
  heterogeneous treatment effects, subgroup analysis) and may
  naturally reuse this chapter's propensity-score/DR machinery when
  covering heterogeneity-of-treatment-effect estimation.
- NICE DSU TSD 16 (treatment switching) is now a newly-named
  book-wide agency reference alongside TSD 2, TSD 4, TSD 14/21, TSD 18,
  and TSD 33.
- The FDA's RWE Framework (21st Century Cures Act §3022), the 2023
  RWD/EHR-claims guidance, the 2023 externally-controlled-trials draft
  guidance, EMA's DARWIN EU, NICE's 2022 real-world evidence
  framework, and the STROBE/TREND/RECORD reporting checklists are all
  now established, specifically-named book-wide references for any
  later RWE-adjacent discussion (e.g. Chapter 31's agency comparison
  chapter should cross-reference these by name rather than re-deriving).
- **Unresolved open flag (readability), not addressed here**: Chapter
  15 joins Chapters 10, 13, and 14 as the fourth chapter in the book
  with an open, unresolved readability flag after the two-revision stop
  rule — and the worst-scoring of the four. A dedicated cross-chapter
  readability pass/restructuring effort covering Chapters 10, 13, 14,
  and 15 together is now a clearly overdue candidate out-of-band task
  to raise with Dr Aswath, rather than continuing to patch
  chapter-by-chapter with diminishing (in this case, negligible)
  returns.
