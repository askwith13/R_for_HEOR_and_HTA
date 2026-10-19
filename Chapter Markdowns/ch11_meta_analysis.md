# Chapter 11 — Meta-Analysis

**Part:** III. Statistical Methods for Evidence Synthesis and Analysis
**Status:** complete — all six Jev rubric dimensions pass after one
revision pass (agency_grounding and readability both initially failed).

## Sections covered (map to TOC 1:1)
11.1 Fixed-effect and random-effects models (`meta`, `metafor`)
11.2 Heterogeneity and its quantification
11.3 Publication bias and small-study effects
11.4 Meta-regression
11.5 Meta-analysis of time-to-event outcomes
11.6 Diagnostic test accuracy meta-analysis
11.7 Meta-analysis of proportions and rates

## Bridge from Chapter 10
Opens by contrasting with Ch.10's single-study IPD extrapolation: this
chapter is about combining *several already-analysed studies* into one
pooled estimate, not building one curve from one dataset.

## Key claims and notation established (binding for later chapters)
- **§11.1**: fixed-effect ("common effect," pure sampling noise across
  studies) vs random-effects (each study estimates its own true effect
  from a distribution) framed as the first decision, not the first R
  call. `meta::metabin()`/`metacont()`/`metagen()` with `sm=` and
  `method.tau=`; `metafor::escalc()`+`rma()` with `method=` one of
  `"FE"`/`"DL"`/`"REML"`/`"ML"`/`"PM"`. REML recommended as the primary
  random-effects $\tau^2$ estimator over DerSimonian-Laird (DL), with
  DL retained only as a sensitivity check — DL is known to understate
  $\tau^2$ with few studies or rare binary events, the typical TB-
  programme situation. Tied explicitly to Ch.10's AIC/BIC + visual +
  clinical-plausibility model-selection discipline as the same kind of
  pre-registered, not-post-hoc choice.
- **§11.2**: $Q$, $\tau^2$, $I^2$ each explained as answering a
  different question (significance-style test vs. variance on the
  effect-measure scale vs. a readable percentage). Cochrane Handbook's
  rough $I^2$ bands (0-40/30-60/50-90/75-100%) given with the explicit
  overlap caveat. `forest()` (both packages) with `prediction = TRUE`
  for a prediction interval established as the standard report format.
- **§11.3**: funnel plots; `meta::metabias(method.bias="linreg")` /
  `metafor::regtest(model="lm")` for Egger's test; `trimfill()` in both
  packages as a sensitivity check, never a replacement estimate.
  Established floor: both tests need ≥10 studies for meaningful power,
  which most TB-programme meta-analyses (5-8 studies) will not meet —
  qualitative funnel-plot description is the fallback.
- **§11.4**: `metafor::rma(mods = ~var)`; `QM` test of moderators vs.
  residual heterogeneity; ≥10 studies per moderator rule of thumb;
  pre-specification required. **Ecological bias** named explicitly as
  the reason between-study moderator associations cannot be read as
  within-study/patient-level effects — Cochrane guidance requires IPD
  meta-analysis for that inference, not aggregate meta-regression.
- **§11.5**: pooling `log(HR)` with SE derived from a reported CI via
  `(log(U) - log(L)) / (2 * 1.96)`; `meta::metagen(sm = "HR")`
  back-transforms with `exp()` for reporting. Explicit mechanism
  established for how this chapter's output feeds Chapter 10's
  machinery: the pooled `log(HR)` becomes the multiplier on the
  Ch.10-selected reference-arm `flexsurv` hazard function — the "HR
  method" of extrapolation, with uncertainty often itself modelled as
  log-normal in a later PSA. Cross-references Ch.10 §10.11's Guyot et
  al. (2012) IPD-reconstruction algorithm via the Cochrane Handbook
  Ch.6 extraction hierarchy (direct HR+SE preferred over a reconstructed
  HR).
- **§11.6**: bivariate random-effects model for jointly correlated
  sensitivity/specificity; `mada::reitsma()` and `madad()`; SROC curve
  via `plot(fit, sroc.type = "ruttergates")`; `metafor::rma.mv()` noted
  as an alternative hand-specified bivariate route. Forward-points to
  Chapter 12 for network meta-analysis of diagnostic accuracy when
  multiple rapid tests lack head-to-head trials.
- **§11.7**: single-group proportion/rate pooling via
  `metafor::escalc()` measures `"PLO"` (logit), `"PFT"`
  (double-arcsine/Freeman-Tukey, for near-0/1 proportions), `"IRLN"`
  (log incidence rate); `predict(..., transf = ...)` for mandatory
  back-transformation before reporting. High $I^2$ (often >90%) framed
  as expected/normal for cross-site TB prevalence pooling, not a
  modelling failure — subgroup reporting by region/risk group
  recommended over one blended figure.

## Package/function-name verification (continuing Ch.6-10's lesson)
All functions cross-checked as real before acceptance: `meta::metabin()`,
`metacont()`, `metagen()`, `forest()`, `funnel()`, `metabias()`,
`trimfill()`; `metafor::escalc()`, `rma()`, `rma.mv()`, `regtest()`,
`predict()` with `transf=`; `mada::reitsma()`, `madad()`. No invented
functions found. Uncertain exact argument spellings (none arose this
chapter — all signatures used are well-established and stable across
package versions) were not an issue here, unlike Ch.8/Ch.10's
`eq5d::eq5d()`/`IPDfromKM` caution cases.

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: no candidate identified this
  chapter. The forest plot and funnel plot ARE the pedagogically
  central diagrams and are already R-code-generated (Track 2), not
  conceptual/structural diagrams Claude would draw separately.
- **Track 2 (R-generated charts)**: three candidates logged as Pending
  in `progress/image_tracker.md` — (1) a forest plot from §11.1/§11.2
  (the single most important plot in the chapter), (2) a funnel plot
  with trim-and-fill overlay from §11.3, (3) an SROC curve from §11.6's
  `mada::reitsma()` worked example. No `// TODO-IMAGE` comments
  inserted in the `.typ` file — the code calls (`forest()`, `funnel()`,
  `plot(fit, sroc.type=...)`) already carry the pedagogical point
  in-line, consistent with the logging-only treatment used for Ch.9
  §9.3 and Ch.10 §10.2/§10.12.

## Jev rubric scores (raw, 1-10 scale)
First pass: coverage 7.97, technical_correctness 7.64, code_validity
7.56, **agency_grounding 5.8** (FAILED), internal_consistency 8.11,
**readability 5.69** (FAILED).

Revision pass (two dimensions targeted): added a named NICE DSU TSD 1
(Dias et al., 2011) agency-note to §11.1 on when fixed- vs
random-effects is justified, and a named CHEERS 2022 (Husereau et al.,
2022) item-15 agency-note to §11.7 on reporting synthesis method when a
pooled estimate feeds a later decision model — following the Ch.2/3/9
established fix pattern of naming a specific document rather than a
generic agency claim. For readability, simplified the chapter-opening
roadmap paragraph into shorter sentences and split the dense §11.2
three-statistic ($Q$/$\tau^2$/$I^2$) paragraph so each statistic gets
its own short explanation of what question it answers.

Re-scored: coverage 8.03, technical_correctness 7.55, code_validity
7.59, **agency_grounding 7.87** (now passes), internal_consistency
8.02, **readability 6.49** (now passes). All six dimensions clear the
6/10 threshold — chapter complete, no further revision needed.

## Open items / things later chapters should not contradict
- Chapter 12 (Indirect Treatment Comparisons and Network Meta-Analysis)
  should pick up from this chapter's pairwise meta-analysis vocabulary
  ($I^2$/$\tau^2$ heterogeneity framing, fixed-vs-random-effects
  discipline) when extending to network-level synthesis — §11.6's
  forward-pointer to network DTA synthesis is one explicit hook.
- The pooled-`log(HR)`-as-extrapolation-multiplier mechanism (§11.5) is
  now an established book-wide convention; Chapters 17-20
  (decision-analytic modelling) building comparator-arm survival from a
  reference-arm `flexsurv` fit (Ch.10) plus a meta-analytic HR (Ch.11)
  should reuse this exact mechanism rather than reinventing it.
- CHEERS 2022 item 15 (synthesis-method reporting when a pooled
  estimate feeds a decision model) is now cited in both Ch.9 and
  Ch.11 — later chapters building Markov/partitioned-survival models
  fed by a pooled transition probability (Ch.19/20) should trace back
  to this reporting requirement rather than treating the pooled input
  as a given.
- No unresolved open flags from this chapter (unlike Ch.10's readability
  flag, which remains separately open and is not addressed here).
