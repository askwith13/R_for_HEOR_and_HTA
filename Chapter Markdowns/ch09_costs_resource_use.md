# Chapter 9 — Costs and Resource Use

**Part:** II. Data for HEOR
**Status:** complete (one revision pass needed on agency_grounding, then all six dimensions cleared)

## Sections covered (map to TOC 1:1)
9.1 Identifying, measuring and valuing resources
9.2 Unit costs and inflation or currency conversion (PPP adjustments)
9.3 Cost data features: skewness, zero-inflation, heavy tails
9.4 Regression models for costs: GLMs, two-part models, gamma models
9.5 Cost-of-illness and micro-costing studies
9.6 Handling censored cost data

## Bridge from Chapter 8
Opens by picking up directly where Ch.8 closed: utilities and costs are
the two halves of the cost/QALY pair since Chapter 4's WTP threshold
introduction; this chapter covers the cost half — identification,
measurement, valuation, and the statistical handling of the resulting
(skewed, zero-inflated, sometimes censored) cost data.

## Key claims and notation established (binding for later chapters)
- **§9.1 identify/measure/value**: costing decomposed into three
  distinct steps kept as separate tibble columns (quantity, unit cost)
  rather than pre-multiplied — explicit continuity with Ch.8's
  separate-utility-decrement-lookup discipline. TB programme resource
  categories: diagnostic (Xpert, culture/DST), drug (FDC, second-line
  regimens), programmatic (DOT visits), patient-borne (societal
  perspective). Provenance (`source` column) required per item.
- **§9.2 inflation/PPP**: strict ordering rule — inflate to a common
  price year WITHIN the source currency first, then convert currency
  (nominal exchange rate or PPP) second. Worked R functions
  `inflate_cost()` and `to_intl_dollars()` with toy CPI/PPP lookup
  tables. World Bank ICP PPP factors and WHO-CHOICE LMIC unit-cost
  database named as real sources for an Indian TB-programme analyst's
  cross-country benchmarking.
- **§9.3 cost data shape**: explicit, deliberate contrast with Ch.8's
  utility support — utilities bounded [0,1] with a ceiling spike at 1;
  costs bounded only below at 0, no ceiling, heavy right tail,
  structural zero-inflation (NOT missing data per Ch.7's mechanism
  taxonomy). Worked diagnostic R code (simulated TB cohort via
  `rgamma()` + rare-outlier process) showing `pct_zero`, skewness,
  mean >> median.
- **§9.4 cost regression**: gamma GLM with log link
  (`glm(cost~x, family=Gamma(link="log"))`) as the defensible default
  for positive cost data, contrasted against naive `lm()`. Real
  function names verified: `Gamma()`, `gaussian(link="log")`,
  `inverse.gaussian(link="log")`. Two-part (hurdle-style) model for
  zero-inflated costs: binomial part1 composed with gamma part2,
  E[cost|x] = P(cost>0|x) × E[cost|cost>0,x]. `pscl::hurdle()`
  correctly flagged as built for zero-inflated COUNTS not continuous
  cost; `twopartm::tpm()` (Belotti, Deb, Manning & Norton 2015)
  verified via live CRAN/web search during assembly as the real
  dedicated continuous two-part cost package — no invented package
  name used. `mgcv::gam()` with `s(age)` smooth for non-linear
  cost-age relationships. Pitfall established: never exponentiate a
  log-OLS prediction and call it the mean cost (recovers the median,
  not the mean); Duan's smearing estimator is the correct fix —
  explicitly parallels Ch.8's retransformation-bias discipline for
  bounded utilities.
- **§9.5 cost-of-illness/micro-costing**: prevalence-based vs
  incidence-based COI distinguished; top-down vs bottom-up
  (micro-costing) costing direction distinguished; WHO-CHOICE's hybrid
  pattern (bottom-up for consumables, top-down for overheads) grounded
  in a real named document (see agency grounding below).
- **§9.6 censored cost data**: naive mean-of-observed and
  complete-case analysis both flagged as biased because cost accrual
  is correlated with follow-up time (a patient censored early has had
  less time to accumulate cost). Lin et al. (1997, *Biometrics*)
  partitioned estimator and inverse-probability-of-censoring weighting
  (IPCW) introduced as the real, correct estimators, with a
  from-scratch IPCW R implementation using `survival::survfit()` on
  the flipped censoring indicator (no invented specialized package).
  Closes with an explicit forward transition to Chapter 10: the
  Kaplan-Meier machinery underlying the censored-cost estimators here
  is the same machinery Ch.10 develops in full.

## Agency grounding — revision pass required and completed
First Jev pass flagged `agency_grounding` at 5.57/10 (below the 6/10
threshold) — the §9.2 and §9.5 agency-notes referenced "NICE reference
case" and "WHO-CHOICE's costing guidance" without naming a specific
citable document, repeating the exact generic-framing mistake first
caught in Ch.2/Ch.3. Revision: §9.2's agency-note now explicitly names
NICE's "NICE health technology evaluations: the manual" (PMG36,
already established in Ch.8) and cites CHEERS 2022 (Husereau et al.,
*Value in Health*, 2022) item 15 by its real authorship; §9.5's
agency-note now names Tan-Torres Edejer et al. (2003), *Making Choices
in Health: WHO Guide to Cost-Effectiveness Analysis* — the real
foundational WHO-CHOICE methodological reference — plus ISPOR's Good
Research Practices for cost-of-illness and micro-costing studies.
Re-score: agency_grounding rose to 7.3/10, all six dimensions clear.
This is now the third chapter (after Ch.2, Ch.3) needing this specific
fix pattern — reinforces that "named agency program" alone (e.g.
"WHO-CHOICE", "NICE reference case") is not sufficient; a specific
citable document/author/year is required every time.

## Package/function-name verification (continuing Ch.6-8's lesson)
All functions cross-checked as real before acceptance: `glm()` with
`Gamma(link="log")`, `gaussian(link="log")`, `inverse.gaussian(link=
"log")`; `pscl::hurdle()` (real, but correctly scoped to count data,
not asserted as the right tool for continuous cost); `twopartm::tpm()`
(verified via live web search during assembly — CRAN package
confirmed real, with `tpm()` as its actual exported function name,
Belotti/Deb/Manning/Norton 2015 citation confirmed); `mgcv::gam()`
with `s()` smooth terms; `survival::survfit()` and `Surv()`. No
invented functions found this chapter.

## Image tracking (per skill's mandatory step 11b)
- **Track 1:** none identified this chapter — the
  identification/measurement/valuation decomposition (§9.1) and the
  top-down/bottom-up costing distinction (§9.5) are conceptual
  contrasts adequately served by prose and `#list()` blocks at this
  length; no genuinely diagram-shaped structural content found.
- **Track 2:** one candidate logged in `progress/image_tracker.md` —
  a right-skewed cost histogram (or density plot) from §9.3's
  simulated TB cohort data (`tb_costs`), illustrating the zero-spike
  and heavy right tail visually alongside the numeric diagnostics
  already in the chapter. Status: Pending (Dr Aswath to render and
  supply). No `// TODO-IMAGE` comment was inserted in the .typ file
  for this one since the numeric diagnostic table already fully
  carries the pedagogical point without a blocking placeholder —
  logged for future enhancement rather than a hard dependency.

## Jev rubric scores (raw, 1-10 scale)
First pass: coverage 8.31, technical_correctness 7.5, code_validity
7.07, agency_grounding 5.57 (FAILED, below 6/10 threshold),
internal_consistency 8.46, readability 6.55.

After one revision pass (agency-note re-grounding only): coverage
8.42, technical_correctness 7.57, code_validity 7.0, agency_grounding
7.3, internal_consistency 8.48, readability 6.58. All six dimensions
now clear the 6/10 threshold.

## Open items / things later chapters should not contradict
- Chapter 10 (Survival Analysis for Economic Evaluation) should pick
  up directly from §9.6's closing transition: `survival::survfit()`
  and the Kaplan-Meier estimator were introduced here specifically for
  the censoring DISTRIBUTION (IPCW weights), not yet for the full
  survival-time extrapolation machinery — Ch.10 develops that in full
  without needing to re-derive the censoring intuition from scratch.
- `twopartm::tpm()` is now an established real-package reference for
  continuous two-part cost models; if a later chapter needs its exact
  argument names, verify against `?twopartm::tpm` first, per the
  standing Ch.6 lesson.
- The gamma-GLM-vs-OLS and censored-cost-estimator worked examples use
  a toy TB cohort (`tb_costs`, `cohort`) — a later chapter building a
  full TB-programme worked case study (e.g. Chapter 35) could extend
  this same toy dataset rather than inventing a disconnected one.
- Tan-Torres Edejer et al. (2003) WHO-CHOICE guide and ISPOR's
  cost-of-illness/micro-costing good-practice guidance are now
  established real-document references for LMIC costing methodology;
  reuse them rather than re-citing "WHO-CHOICE" generically in a later
  chapter.
