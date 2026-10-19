# Chapter 16 — Regression Models for HEOR Data

**Part:** III. Statistical Methods for Evidence Synthesis and Analysis
**Status:** complete — ALL SIX Jev rubric dimensions passed on the FIRST
draft, no revision pass needed. Notably, this BREAKS the four-chapter
readability-flag streak (Chapters 10, 13, 14, 15 all failed readability
after two revision attempts each) — readability scored 6.23/10, clearing
the 6/10 threshold cleanly.

## Sections covered (map to TOC 1:1)
16.1 Generalised linear models
16.2 Mixed-effects and hierarchical models
16.3 Count data and zero-inflated models
16.4 Quantile and ordinal regression
16.5 Machine learning for prediction and heterogeneity of treatment effect
16.6 Subgroup analysis and effect modification

## Bridge from Chapter 15
Opens by framing this chapter as the regression machinery underlying
Chapter 15's propensity-score/DR methods, Chapter 9's cost models, and
Chapter 8's utility regression — explicitly unifying them as GLM special
cases rather than treating this as disconnected new material.

## Key claims and notation established (binding for later chapters)
- **§16.1**: GLM framework (exponential-family distribution + linear
  predictor + link function) stated explicitly; three outcome families
  (binomial/logit, Poisson-or-negbin/log, gamma/log) mapped to HEOR
  outcome types. Explicitly does NOT re-derive Chapter 9's gamma-cost
  GLM mechanics — cross-referenced by section number (§9.4) instead.
  Worked `glm()` logistic example on a toy TB regimen/success dataset
  with `broom::tidy(exponentiate = TRUE, conf.int = TRUE)` and
  `predict(type = "response")` — both argument choices called out
  explicitly as commonly-forgotten reporting steps.
- **§16.2**: Fixed vs random effects formally distinguished. ICC
  (intraclass correlation coefficient) introduced as the proportion of
  outcome variance attributable to the clustering factor. Random
  intercept (`(1 | clinic_id)`) vs random slope (`(1 + age | clinic_id)`)
  distinguished, with explicit caution that random slopes cost
  estimability, especially with few clusters (relevant to a TB
  multi-site programme). `lme4::glmer()` worked example with a toy
  9-patient/3-clinic dataset; `lme4::lmer()` named as the Gaussian
  counterpart for repeated HRQoL measures; `nlme::lme()` named as an
  older alternative for flexible correlation structures.
- **§16.3**: Overdispersion (`MASS::glm.nb()`) distinguished from excess
  structural zeros (`pscl::zeroinfl()`), with the two-part `count | zero`
  formula syntax explained. Zero-inflated vs hurdle models (`pscl::hurdle()`)
  conceptually distinguished: zero-inflated mixes two zero-generating
  processes together, hurdle requires clearing a binary "any events"
  gate before a truncated count model applies.
- **§16.4**: Quantile regression (`quantreg::rq(tau = )`) introduced as
  modelling a specific percentile rather than the mean — explicitly
  framed as complementary to, not a replacement for, Chapter 9's
  gamma-GLM cost treatment (use GLM for a single mean-cost estimate
  feeding a budget-impact model; use quantile regression when the
  question is about a specific point in the distribution, e.g. the
  costly tail). `MASS::polr()` explicitly NOT re-derived — pointed back
  to Chapter 8 where it was first used for utility mapping.
  `ordinal::clm()` introduced as an alternative. Proportional-odds
  assumption named as commonly assumed-but-unchecked.
- **§16.5**: `grf::causal_forest()` framed explicitly as the ML-flexible
  cousin of Chapter 15's doubly-robust estimators — nonparametric
  treatment-effect heterogeneity (HTE) estimation vs Chapter 15's
  parametric/semiparametric DR average-effect estimation. Contrasted
  with plain prediction forests (`randomForest::randomForest()`,
  `ranger::ranger()`, which predict outcomes, not treatment effects).
  `glmnet::glmnet()`/`cv.glmnet(alpha = , lambda = )` introduced for
  LASSO/elastic-net variable selection in high-dimensional covariate
  settings, framed as a screening step feeding into §16.6's
  domain-driven subgroup analysis, not a replacement for it.
- **§16.6**: Pre-specified vs exploratory subgroup analysis distinguished
  with ICH E9(R1) (already established in Chapter 7) cited for
  pre-specification requirements. Interaction-term test
  (`treatment * subgroup` in `glm()`) established as the formal test of
  effect modification — explicitly NOT a pair of separate within-subgroup
  analyses. Forest-plot display explicitly reuses Chapter 11's
  `metafor::forest()` mechanics rather than introducing new plotting
  code. Prognostic-factor vs effect-modifier distinction explicitly
  reused BY NAME from Chapter 15 §15.3's DAG-based framing, continuing
  that chapter's established terminology rather than re-deriving it.

## Package/function-name verification (continuing Ch.6-15's lesson)
`glm()`, `broom::tidy()`, `predict.glm()`, `lme4::lmer()`/`glmer()`,
`nlme::lme()`, `MASS::glm.nb()`, `pscl::zeroinfl()`/`hurdle()`,
`quantreg::rq()`, `MASS::polr()` (reused from Ch.8), `ordinal::clm()`,
`randomForest::randomForest()`, `ranger::ranger()`,
`grf::causal_forest()`, `glmnet::glmnet()`/`cv.glmnet()`,
`metafor::forest()` (reused from Ch.11) — all confirmed real, standard
functions/signatures during assembly. `countreg::hurdle()` was
considered and explicitly dropped from the final text in favour of
`pscl::hurdle()` only, since `countreg` is not a stable CRAN package —
continuing the Ch.13/15 tooling-honesty pattern of not naming
unreliable/non-CRAN packages as equivalent to a CRAN-stable alternative.

## Agency grounding (proactive, per the Ch.4/5 lesson)
Three specific named documents used, none generic: CHEERS 2022 items 20
and 26 (§16.1, statistical model/family/link reporting), NICE DSU TSD 3
(§16.2, random-effects models under plausible heterogeneity — extending
the already-established TSD 1/2/3/14/16/18/21/33 family of named NICE
DSU references), and EMA/CHMP/539146/2013 "Guideline on the
investigation of subgroups in confirmatory clinical trials" (§16.6, a
genuinely new named regulatory document for this book, verified to be
a real EMA guideline rather than invented).

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: no new candidate logged — this
  chapter's content (GLM family selection, mixed-model structure) is
  adequately served by the worked code examples and prose; no genuinely
  structural/process diagram identified.
- **Track 2 (R-generated charts)**: two candidates logged as Pending in
  `image_tracker.md`: (1) a `grf`-style scatter of estimated per-patient
  treatment effects (`tau_hat`) from §16.5's causal-forest example,
  illustrating HTE spread; (2) a subgroup forest plot from §16.6 (either
  `ggplot2` or `metafor::forest()` applied to subgroup-specific
  estimates) as a worked companion to the chapter's interaction-term
  example.

## "How to report this" table check (per the mandatory step 11c)
No `report-table`/`ref-table` inserted this chapter. Reviewed every
worked example (glm() coefficient table, glmer() summary, glm.nb()/
zeroinfl() output, rq() quantile coefficients, causal_forest() tau_hat
summary, glm() interaction coefficient) and judged that `broom::tidy()`'s
own tabular output, already shown inline as code output, is the natural
"how to report this" artifact for a regression-coefficient table in this
chapter — adding a separate boxed table would duplicate that output
without adding real reporting-convention content beyond what Chapters 9
and 14 already modelled for GLM/Bayesian coefficient tables. This is a
genuine "zero tables, stated explicitly" chapter per the skill's
guidance, not an oversight.

## Jev rubric scores (raw, 1-10 scale)
First pass, ALL SIX dimensions passed — no revision needed: coverage
8.38, technical_correctness 7.33, code_validity 7.13, agency_grounding
7.93, internal_consistency 8.00, **readability 6.23** (clears the 6/10
threshold — the first chapter since Chapter 9 to clear readability on
the first draft, and the first to clear it at all since the four-chapter
streak of Chapters 10/13/14/15 each failing it after two revision
attempts).

**Readability-recovery observation worth recording**: this chapter
deliberately followed the "fewer ideas, more depth" guidance given to
its sub-agent drafters — six subsections, each scoped to 2-3 core ideas
with one concrete worked example apiece, explicit cross-references to
earlier chapters instead of re-deriving material (Ch.8's `polr()`,
Ch.9's cost-GLM mechanics, Ch.11's forest-plot mechanics, Ch.15's
DAG-based prognostic/effect-modifier distinction), rather than trying to
cover every related method or caveat. This is consistent with the
cross-chapter hypothesis recorded in Ch.10/13/14/15's markdowns that
concept DENSITY, not sentence length, drives the readability score — and
is the first chapter since that hypothesis was formed to test it by
deliberately limiting density from the first draft rather than
sentence-splitting after a failing score. The result (clean pass) is
one data point in favour of the density hypothesis, though not
conclusive on its own — the dedicated cross-chapter readability pass for
Chapters 10/13/14/15 remains a live, separately-flagged item (see those
chapters' markdowns) since this chapter does not retroactively fix them.

## Open items / things later chapters should not contradict
- Chapter 17 (Principles of Decision Modelling) opens Part IV and should
  pick up from this chapter's closing transition: Part III's estimation
  toolkit (effects, confounding adjustment, pooling, heterogeneity) is
  now complete, and Chapter 17 shifts to "what should a health system do
  about it" — model conceptualisation, type choice, structural
  assumptions/diagrams, parameter taxonomy, documentation, workflow, and
  ISPOR-SMDM/NICE good-practice guidelines.
- NICE DSU TSD 3 and EMA/CHMP/539146/2013 are now newly-named book-wide
  agency references, alongside the already-established TSD 1/2/14/16/18/21/33
  family and CHEERS 2022's item-level citations.
- `grf::causal_forest()`'s per-patient `tau_hat` output and
  `glmnet::cv.glmnet()`'s LASSO variable selection are now established
  as the book's ML-flexible HTE/variable-selection tools; any later
  chapter introducing patient-level heterogeneity (e.g. Chapter 21's
  microsimulation, Chapter 33's PRO/preference work) may reuse these by
  name rather than re-deriving.
- The readability-recovery pattern (density-first drafting, explicit
  cross-referencing instead of re-derivation) should be applied
  proactively to Chapters 17 onward, not just treated as a one-off
  success — this is now a second confirmed, generalisable lesson
  alongside the Ch.2/3/4 agency-grounding lesson.
