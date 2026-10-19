# Chapter 13 — Population-Adjusted Indirect Comparisons

**Part:** III. Statistical Methods for Evidence Synthesis and Analysis
**Status:** complete — five of six Jev rubric dimensions pass; readability
remains below the 6/10 threshold after one revision pass (flagged, not
looped further, per the skill's two-consecutive-low-scores stop rule).

## Sections covered (map to TOC 1:1)
13.1 When population adjustment is needed
13.2 Matching-adjusted indirect comparison (MAIC) — weighting, ESS, time-to-event outcomes
13.3 Simulated treatment comparison (STC)
13.4 Multilevel network meta-regression (ML-NMR)
13.5 Limitations, assumptions and agency expectations (NICE DSU TSD 18)

## Bridge from Chapter 12
Opens by picking up Ch.12 §12.6's exact forward-pointer: standard network
meta-regression is data-hungry and only adjusts for imbalance at the
*study* level via trial-arm covariate means. This chapter closes that gap
using individual patient-level data (IPD) from one trial plus aggregate
data (AgD) from another, when population-level covariate imbalance in
*effect modifiers* (not just prognostic factors) threatens standard
anchored indirect comparison.

## Key claims and notation established (binding for later chapters)
- **§13.1**: the central methodological fork — *effect modifiers* (change
  the relative treatment effect) vs *prognostic factors* (shift outcomes
  uniformly in both arms). For an **anchored** comparison, prognostic
  imbalance cancels within-trial; effect-modifier imbalance does not, and
  that is exactly what population adjustment corrects. For an
  **unanchored** comparison, this distinction collapses — all covariates
  (prognostic and effect-modifying) must be balanced.
- **§13.2 MAIC**: odds-weight $w_i = exp(z_i^T alpha)$ solved by
  method-of-moments via `stats::optim()`; effective sample size
  $"ESS" = (sum w_i)^2 / sum w_i^2$, worked illustration N=400 → ESS≈120
  (30% retained) as a credibility red flag, not a footnote. Time-to-event
  handling via `survival::coxph(weights=)`/`survfit(weights=)` reusing
  the odds-weights as case weights, with a note that robust/sandwich SEs
  are preferred since the weights are themselves estimated. Tooling
  honesty: no dominant CRAN package for MAIC exists; it is typically
  hand-coded via `optim()`; the GitHub `maic` package is explicitly
  flagged as NOT on CRAN and unreviewed — continuing the Ch.6/12 standing
  lesson of never inventing or over-trusting unverified tooling.
- **§13.3 STC**: outcome regression (`glm()` with treatment×covariate
  interactions) predicted at the AgD trial's reported covariate means.
  Central pitfall: **non-collapsibility** — on nonlinear scales (odds
  ratio, hazard ratio), the conditional effect at the covariate mean and
  the marginal/population-average effect are different quantities even
  under a correctly specified model; the fix is simulating across the
  full covariate distribution and averaging on the natural scale before
  back-transforming, not point-plugging at the mean. MAIC/STC contrasted
  explicitly: MAIC needs a correct *weighting* model, STC needs a correct
  *outcome* model; neither dominates in general.
- **§13.4 ML-NMR**: framed as STC generalized from two trials to a full
  IPD+AgD network via numerical integration over each AgD trial's
  reported covariate distribution (not just its mean). Reuses the
  `multinma` package already introduced in Ch.12 §12.4 (`set_ipd()`,
  `set_agd_arm()`, `nma()`) — explicitly NOT a new tool — with
  `add_integration()` as the one new function, its exact
  distribution-argument syntax explicitly hedged as version-dependent
  rather than asserted as fact (continuing the Ch.8/Ch.12
  cautious-uncertainty pattern).
- **§13.5 TSD 18**: the chapter's dedicated agency-grounding section.
  NICE DSU Technical Support Document 18 (Phillippo et al. 2016) named
  as THE standard reference, with its real requirements enumerated:
  justify the need for adjustment, prespecify effect modifiers *before*
  seeing results (pitfall: post-hoc selection is explicitly criticised by
  DSU/ERGs), report covariate balance before/after weighting, report ESS
  and interpret its loss, and TSD 18's stated method preference ordering
  ML-NMR > STC > MAIC. Two further named limitations: (1) a
  population-adjusted estimate is valid only for the one target (AgD)
  population it was adjusted to — unlike standard NMA's transportability
  assumption; (2) unanchored comparisons carry materially higher risk of
  bias from unmeasured confounding and should be a last resort, not a
  default, per TSD 18.

## Package/function-name verification (continuing Ch.6-12's lesson)
`stats::optim()`, `survival::coxph(weights=)`, `survfit(weights=)`,
`glm()`, `predict()` — all standard, verified. `multinma::set_ipd()`,
`set_agd_arm()`, `nma()` reused from Ch.12 (already verified there).
`multinma::add_integration()` confirmed as a real documented function
(one live web search performed during assembly), but its exact
covariate-distribution argument syntax is explicitly hedged in the
chapter text as version-sensitive rather than presented as a fixed,
copy-ready signature — a cautious middle ground between asserting and
inventing. The GitHub `maic` package is explicitly named as NOT on CRAN
and unreviewed, rather than silently treated as equivalent to a CRAN
package.

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: one new candidate logged — C11, a
  method-decision flowchart ("how many trials / IPD coverage / AgD
  covariate-reporting detail" → MAIC vs STC vs ML-NMR). Logged as
  Pending, low priority (prose already covers the logic linearly).
- **Track 2 (R-generated charts)**: one new candidate logged — T12, a
  MAIC covariate-balance "love plot" (standardised mean differences
  before/after weighting) per TSD 18's expected reporting. Logged as
  Pending, optional, no `// TODO-IMAGE` marker inserted since §13.2's
  prose/code stands alone without it.

## Jev rubric scores (raw, 1-10 scale)
First pass: coverage 8.07, technical_correctness 7.52, code_validity
6.23, agency_grounding 7.78, internal_consistency 8.33,
**readability 5.57** (FAILED — only dimension below threshold).

Revision pass (readability only): rewrote the chapter-opening bridge
into three shorter paragraphs instead of one dense one; broke up the
§13.1 opening sentence (removed an embedded §-cross-reference mid-
sentence); rewrote the §13.3 non-collapsibility pitfall and the
MAIC-vs-STC trade-off paragraph into shorter sentences with less nested
clause structure.

Re-scored: coverage 8.12, technical_correctness 7.30, code_validity
6.33, agency_grounding 7.69, internal_consistency 8.31,
**readability 5.17** (still FAILED — effectively flat/slightly lower).

Per the skill's stop-after-two-consecutive-low-scores rule, did **NOT**
attempt a third revision. **Flagged to Dr Aswath**: Chapter 13's
readability score has not cleared the threshold across two attempts.
Hypothesis, consistent with the Chapter 10 precedent (also a readability
flag that didn't move on one revision): this chapter has an unusually
high density of tightly-coupled technical distinctions packed into a
short span (effect modifier vs prognostic factor, MAIC vs STC model
assumptions, non-collapsibility, ML-NMR's distributional vs point-mean
matching, TSD 18's five-item checklist) with comparatively little
narrative "breathing room" between them — the same high-concept-density
pattern flagged in Ch.10's markdown. A future full rewrite pass (not
just sentence-splitting) breaking §13.2-13.3 into more numbered
sub-steps with explicit "first... then..." signposting may be the real
fix, worth considering across both Ch.10 and Ch.13 together rather than
chapter-by-chapter patching.

## Open items / things later chapters should not contradict
- Chapter 14 (Bayesian Methods for HEOR) should pick up naturally from
  this chapter's Bayesian ML-NMR thread (`multinma`, already used in
  Ch.12 and Ch.13) when it covers MCMC diagnostics in full generality —
  §13.4 deliberately deferred full convergence-diagnostic detail to
  Ch.12 §12.4's existing `gelman.diag()` treatment rather than
  duplicating it a third time.
- TSD 18's method preference ordering (ML-NMR > STC > MAIC) is now an
  established, specifically-named book-wide convention; any later
  chapter discussing population-adjustment methodology should cite it
  by number, not generically.
- **Unresolved open flag (readability), not addressed here**: Chapter 13
  joins Chapter 10 as the second chapter in the book with an open,
  unresolved readability flag after the two-revision stop rule. Worth a
  dedicated cross-chapter readability pass later rather than continuing
  to patch chapter-by-chapter.
