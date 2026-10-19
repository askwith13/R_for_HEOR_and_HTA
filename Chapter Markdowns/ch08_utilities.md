# Chapter 8 — Health-Related Quality of Life and Utilities

**Part:** II. Data for HEOR
**Status:** complete (passed all six Jev dimensions on the FIRST draft, no revision pass needed)

## Sections covered (map to TOC 1:1)
8.1 Generic and disease-specific instruments (EQ-5D, SF-6D, HUI, etc.)
8.2 Value sets and scoring in R (`eq5d`)
8.3 Mapping algorithms (cross-walks and regression-based mapping)
8.4 Analysing utility data: censoring, bounded distributions, beta regression, mixture models
8.5 Utility decrements, age-adjusted utilities and background mortality
8.6 Time trade-off, standard gamble and discrete choice experiments

## Bridge from Chapter 7
Opens by picking up directly where Ch.7 closed: missing utility values
are frequently a symptom of instrument choice, elicitation method, and
measurement timing — this chapter covers how utilities are measured,
valued, and modelled in the first place.

## Key claims and notation established (binding for later chapters)
- **§8.1 instruments**: utility anchored 1 = full health, 0 = dead,
  negative for worse-than-death states (consistent with Ch.7's -0.59
  UK 3L floor). EQ-5D-3L (5 dims × 3 levels = 243 states), EQ-5D-5L
  (5 dims × 5 levels = 3125 states), SF-6D (from SF-36/SF-12), HUI2/
  HUI3 (own dimension sets). Generic instruments required by HTA
  reference cases (NICE, HTAIn) for cross-disease QALY comparability
  at a shared WTP threshold lambda; disease-specific instruments
  (TB-specific, EORTC QLQ-C30) more sensitive within-disease but need
  a mapping bridge (§8.3).
- **§8.2 value sets**: real CRAN package `eq5d` (Craig, Pickard et
  al.), core function `eq5d()` scoring a dimension-profile data frame
  against a named country value set — described conceptually, with
  the exact scoring call left commented pending `?eq5d` verification
  per the package's evolving argument spellings, rather than asserting
  an unconfirmed signature. Value set/tariff = country-specific
  population preference weights from TTO/DCE studies (foreshadows
  §8.6). Wrong-country value set flagged as a REAL, known submission
  error. HTAIn/India: no established national EQ-5D value set yet,
  crosswalk/transfer approaches used pragmatically as a stated
  limitation.
- **§8.3 mapping/cross-walking**: direct/response mapping
  (`MASS::polr()` proportional-odds ordinal regression per dimension,
  composed through the value set) vs. indirect/utility-value mapping
  (`lm()`/`glm()` on the utility index directly — simpler, loses
  compositional structure). OLS on bounded utility flagged as common
  but theoretically poor (motivates §8.4). Mapping algorithms require
  out-of-sample validation (cross-validation, MAE/RMSE), especially at
  distribution extremes where incremental QALY gain is usually driven.
- **§8.4 bounded utility analysis**: three real validated methods —
  censored/Tobit regression (`VGAM::vglm()` or `censReg::censReg()`),
  beta regression (`betareg::betareg()`, with Smithson-Verkuilen-style
  rescaling to open (0,1) before fitting — full worked R example), and
  finite mixture models conceptually (`flexmix` named as a real CRAN
  option). All three real, correctly named.
- **§8.5 decrements/age-adjustment/mortality**: utility decrement
  (e.g. -0.05 to -0.10 for a grade 3-4 AE) sourced from literature per
  Ch.5 §5.3/Ch.6 SLR methodology, applied additively or multiplicatively
  in Markov/decision-tree models (foreshadows Ch.17-20). Multiplicative
  age/sex-adjustment (utility × norm(age)/norm(baseline)) preferred
  over additive to avoid implausible negative utilities when stacking
  decrements over a long horizon. Background mortality explicitly tied
  to Ch.4's discounting/half-cycle correction — age/sex-specific
  all-cause mortality from a national life table layered on
  disease-specific mortality.
- **§8.6 elicitation methods**: TTO (x/T at indifference, intuitive,
  not strictly utility-theoretic), SG (indifference probability p,
  grounded in von Neumann-Morgenstern expected utility theory), DCE
  (repeated pairwise choices, conditional/multinomial logit estimation,
  needs a TTO/SG anchor to reach dead=0/full-health=1 scale — relevant
  to HTAIn given India's lack of an established TTO value set). Real R
  packages: `mlogit`, `survival::clogit()`.

## Agency grounding — proactive, all real named documents
NICE's "NICE health technology evaluations: the manual" (PMG36) on
EQ-5D reference-case preference and utility-sourcing hierarchy (§8.2,
§8.6); the EuroQol Group's published EQ-5D-5L valuation protocol
(§8.6). No fabricated document numbers — where PMG36's exact current
wording on 5L-to-3L handling was uncertain, the chapter explicitly
directed the reader to check the live text rather than asserting a
stale or invented detail.

## Package/function-name verification (continuing Ch.6-7's lesson)
All functions cross-checked as real before acceptance: `eq5d::eq5d()`
(described conceptually, exact argument spelling deliberately left
unasserted pending `?eq5d`), `MASS::polr()`, `VGAM::vglm()`,
`censReg::censReg()`, `betareg::betareg()`, `flexmix` (named, not
exercised with code), `mlogit`, `survival::clogit()`. No invented
functions found this chapter.

## Image tracking (per skill's mandatory step 11b)
- **Track 1:** none identified — no sufficiently diagram-shaped
  structural content beyond what prose/lists already serve (the
  generic-vs-disease-specific instrument contrast and the three
  elicitation methods are conceptual distinctions better served by
  text than a diagram at this length).
- **Track 2:** none identified — all R code in this chapter produces
  console/summary output (betareg summary, age-multiplier lookup) or
  is deliberately left as commented pseudocode (the `eq5d()` call),
  not a statistical plot Dr Aswath would render and supply separately.

## Jev rubric scores (raw, 1-10 scale) — first pass, no revision needed
coverage 8.24, technical_correctness 7.08, code_validity 6.32,
agency_grounding 7.91, internal_consistency 8.26, readability 7.06.
All six dimensions clear the 6/10 threshold on the first draft
(code_validity is the closest to the threshold — worth a closer look
if a future revision pass is ever needed on this chapter, though no
revision was triggered).

## Open items / things later chapters should not contradict
- Chapter 9 (Costs and Resource Use) should pick up directly where
  §8.6's closing transition leaves off, treating costs as the second
  half of the cost/QALY pair established since Ch.4.
- Chapters 17-20 (decision trees, Markov models) should reuse this
  chapter's additive/multiplicative decrement convention and the
  multiplicative age/sex-adjustment approach rather than introducing a
  new convention.
- Any later chapter needing exact `eq5d::eq5d()` argument names should
  verify against the installed package version's `?eq5d` help page
  before using them in a worked example, per this chapter's explicit
  caution.
- `betareg`, `censReg`, `VGAM`, `flexmix`, `mlogit` are now established
  real-package references for bounded-outcome and discrete-choice
  modelling; if a later chapter goes deeper into their function
  signatures, verify against real documentation first, per the
  standing Ch.6 lesson.
