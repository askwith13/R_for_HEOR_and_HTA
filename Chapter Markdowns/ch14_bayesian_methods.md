# Chapter 14 — Bayesian Methods for HEOR

**Part:** III. Statistical Methods for Evidence Synthesis and Analysis
**Status:** complete — five of six Jev rubric dimensions pass; readability
remains below the 6/10 threshold after one revision pass (flagged, not
looped further, per the skill's two-consecutive-low-scores stop rule —
third chapter in the book to hit this, after Chapter 10 and Chapter 13).

## Sections covered (map to TOC 1:1)
14.1 Bayesian thinking for decision makers
14.2 Priors: informative, weakly informative and vague priors
14.3 MCMC with Stan, JAGS and `brms`
14.4 Diagnostics: convergence, effective sample size, posterior predictive checks
14.5 Bayesian evidence synthesis
14.6 Bayesian decision analysis
14.7 Expert elicitation methods (SHELF)
14.8 Bayesian health economic modelling workflows

## Bridge from Chapter 12/13
Opens by picking up Chapter 12's explicit, named forward-pointer: Ch.12
flagged a `gelman.diag()` convergence check as mandatory for its Bayesian
NMA models (`gemtc`/`multinma`/`bnma`) but deliberately deferred the full
diagnostics explanation to this chapter. §14.4 fulfils that promise.

## Key claims and notation established (binding for later chapters)
- **§14.1**: $"posterior" prop "likelihood" times "prior"$; explicit contrast
  between a frequentist confidence interval (long-run procedure statement)
  and a Bayesian credible interval (direct probability statement about
  $theta$ itself) — this distinction is now load-bearing for how later
  chapters describe CEAC/decision-uncertainty statements.
- **§14.2**: informative / weakly informative / vague priors distinguished
  with concrete HEOR examples. Conjugate Beta-Binomial update worked
  through explicitly: prior $"Beta"(150,42)$ (a prior TB survey, 78%
  success), new cohort $y=34$, $n=40$ → posterior $"Beta"(184,48)$,
  posterior mean $184/232 = 0.793$ — arithmetic independently verified
  during assembly (continuing the Ch.4 standing lesson: always redo a
  sub-agent's stated numeric result, don't just check plausibility).
  First `report-table` use since the "How to report this" tables feature
  was added (Oct 2026): a prior-vs-posterior summary table for this exact
  worked example, correctly reserved for `report-table` (not `ref-table`)
  since it reports the chapter's own just-computed result.
- **§14.3**: all three engines (`rstan::stan()`, `rjags::jags.model()` +
  `coda.samples()`, `brms::brm()` with `set_prior()`) fit the identical
  Beta-Binomial/logistic toy model side by side, so the reader can compare
  syntax directly. Metropolis-Hastings → HMC → NUTS explained as a chain
  of successive refinements, explicitly tied back to why Stan models
  (Ch.12's `multinma`) typically need fewer iterations than JAGS models
  (Ch.12's `gemtc`) for the same effective sample size.
- **§14.4 (the chapter's debt-payoff section)**: R-hat/Gelman-Rubin
  statistic explained mechanically (between-chain vs within-chain
  variance comparison); two thresholds distinguished and both are now
  book-wide conventions — $< 1.05$ (the `gemtc`/NICE DSU NMA tradition
  already used informally in Ch.12) vs the stricter $< 1.01$ (modern
  Stan-ecosystem guidance). Effective sample size (ESS) explicitly
  distinguished from raw iteration count — a chain can have excellent
  R-hat and still unusable ESS if it mixes slowly within a converged
  region, a distinct failure mode worth knowing separately. Posterior
  predictive checks (`bayesplot::ppc_dens_overlay()`) introduced as a
  model-fit check, explicitly distinguished from a convergence check
  (sampler worked vs model is good are different questions).
- **§14.5**: explicitly does NOT re-derive Ch.12's Bayesian NMA mechanics
  — states the general principle (a Bayesian posterior is a joint sample
  over every parameter, correlations intact; a frequentist CI is not) and
  reuses `gemtc::relative.effect()`'s `mcmc.list` output as the bridge
  object into §14.6.
- **§14.6 (the chapter's core practical payoff)**: posterior MCMC draws
  used directly, unmodified, as a PSA sample — no intermediate
  distribution-fitting step. Full worked R loop: each row of a posterior
  relative-effect sample becomes one PSA iteration, preserving
  cross-contrast correlation that an independently-sampled PSA cannot
  reproduce without manually imposing a correlation matrix. This is now
  an established book-wide mechanism any later Bayesian-evidence chapter
  should reuse by name rather than re-deriving.
- **§14.7**: SHELF (Sheffield Elicitation Framework) introduced as a
  structured protocol (facilitator/experts roles; individual elicitation
  before group reconciliation, deliberately in that order to avoid
  anchoring) for parameters with no usable data — rare disease, orphan
  drug, early-stage HTA submissions. `SHELF::fitdist()`/`plotfit()` used
  with confidence; `SHELF::feedback()`'s exact signature explicitly
  hedged as not independently re-verified against live CRAN docs —
  continuing the Ch.8/Ch.12/Ch.13 cautious-uncertainty pattern rather
  than asserting a fabricated signature.
- **§14.8**: explicit 6-step end-to-end workflow (prior → synthesis →
  MCMC fitting → diagnostics → posterior-as-PSA → reporting) as a
  capstone roadmap. Forward-points by chapter number to Chapter 25
  (PSA/uncertainty, which picks up exactly at Step 5) and Chapter 26
  (Value of Information — EVPI/EVPPI computed directly from posterior
  draws without the extra approximating machinery a non-Bayesian PSA
  would need). This is now a binding commitment: Ch.25/26 should
  explicitly reuse this chapter's posterior-as-PSA-sample framing rather
  than introducing PSA mechanics as if from scratch.

## Package/function-name verification (continuing Ch.6-13's lesson)
`rstan::stan()`, `rjags::jags.model()`/`coda.samples()`, `brms::brm()`/
`set_prior()`, `coda::gelman.diag()`/`effectiveSize()`,
`bayesplot::mcmc_trace()`/`ppc_dens_overlay()`, `rstan::check_hmc_diagnostics()`/
`monitor()`/`extract()`/`traceplot()`, `gemtc::relative.effect()` (reused
from Ch.12) — all confirmed real, standard functions/signatures.
`SHELF::fitdist()` and `SHELF::plotfit()` used directly; `SHELF::feedback()`
explicitly flagged as not independently re-verified, hedged in-text rather
than asserted — the cautious-uncertainty pattern applied honestly rather
than either fabricating or omitting the function.

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: no new candidate logged — the
  prior→synthesis→MCMC→diagnostics→PSA→reporting workflow in §14.8 is a
  strong future candidate for a Mermaid flowchart (6 linear steps,
  `flowchart LR` would suit it well per the established lesson) but
  deferred to a later batch pass per the skill's "optional per-tick"
  allowance — logged as Pending, medium priority, in `image_tracker.md`.
- **Track 2 (R-generated charts)**: three `// TODO-IMAGE` markers
  inserted at exact code locations, book still compiles cleanly: (1) a
  `bayesplot::mcmc_trace()` healthy 4-chain trace plot (§14.4), (2) a
  `bayesplot::ppc_dens_overlay()` posterior-predictive-check plot
  (§14.4), (3) a `SHELF::plotfit()` fitted-distribution-vs-elicited-
  quantiles plot (§14.7). All logged in `image_tracker.md` as Pending.

## Jev rubric scores (raw, 1-10 scale)
First pass: coverage 8.2, technical_correctness 7.99, code_validity
7.82, agency_grounding 8.06, internal_consistency 8.22,
**readability 5.44** (FAILED — only dimension below threshold).

Revision pass (readability only): rewrote the chapter-opening bridge
into short paragraphs with an explicit bulleted section-arc list (same
fix pattern as Ch.10/Ch.13); broke the dense §14.1 prior/likelihood/
posterior paragraph into three short standalone paragraphs instead of
one long sentence-chain; rewrote the §14.3 Metropolis-Hastings/HMC/NUTS/
Gibbs paragraph block into four short, clearly separated paragraphs
instead of three dense ones.

Re-scored: coverage 8.31, technical_correctness 8.03, code_validity
7.69, agency_grounding 8.03, internal_consistency 8.13,
**readability 5.5** (still FAILED — effectively flat, +0.06).

Per the skill's stop-after-two-consecutive-low-scores rule, did **NOT**
attempt a third revision. **Flagged to Dr Aswath**: Chapter 14 joins
Chapter 10 and Chapter 13 as the third chapter in the book with an
unresolved readability flag after two revision attempts. The pattern is
now a clear trend rather than isolated incidents: all three flagged
chapters (10, 13, 14) are the book's most mathematically/conceptually
dense chapters so far — survival extrapolation methods, population
adjustment, and now Bayesian inference/MCMC. Sentence-splitting alone
(the fix applied each time) is not moving the score. This strengthens
the hypothesis already recorded in Ch.10/13's markdowns: a dedicated
cross-chapter readability pass — restructuring these three chapters with
more numbered sub-steps, more worked mini-examples per concept, and
possibly shorter subsections split across more headings — is likely the
real fix, not further chapter-by-chapter sentence editing.

## Open items / things later chapters should not contradict
- Chapter 15 (Real-World Evidence and Causal Inference) should pick up
  from this chapter's Bayesian framing where relevant (e.g. Bayesian
  propensity score methods, if covered) but is not required to use
  Bayesian methods throughout — RWE/causal inference in this book is
  primarily frequentist (DAGs, propensity scores, g-methods, IV/RD,
  DiD) with Bayesian methods as an occasional option, not the default.
- Chapters 25 (Handling Uncertainty) and 26 (Value of Information) have
  a now-binding commitment to reuse this chapter's §14.6 posterior-as-
  PSA-sample mechanism and §14.8's 6-step workflow framing by name,
  rather than introducing PSA/VOI mechanics as if this chapter didn't
  exist.
- NICE DSU TSD 33 (expert elicitation) is now a newly-named book-wide
  agency reference alongside the already-established TSD 2, TSD 4,
  TSD 14/21, and TSD 18.
- **Unresolved open flag (readability), not addressed here**: Chapter 14
  is the third chapter in the book with an open, unresolved readability
  flag after the two-revision stop rule (after Ch.10 and Ch.13). A
  dedicated cross-chapter readability pass covering Chapters 10, 13 and
  14 together is increasingly the right next move rather than continuing
  to patch chapter-by-chapter — worth raising with Dr Aswath as a
  candidate out-of-band task.
