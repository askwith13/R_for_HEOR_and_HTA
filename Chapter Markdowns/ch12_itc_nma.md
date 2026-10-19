# Chapter 12 — Indirect Treatment Comparisons and Network Meta-Analysis

**Part:** III. Statistical Methods for Evidence Synthesis and Analysis
**Status:** complete — all six Jev rubric dimensions passed on the FIRST
draft, no revision pass needed.

## Sections covered (map to TOC 1:1)
12.1 Why indirect comparison is needed
12.2 Bucher method
12.3 Frequentist NMA (`netmeta`)
12.4 Bayesian NMA (`gemtc`, `multinma`, `bnma`)
12.5 Consistency and inconsistency assessment (node-splitting, design-by-treatment)
12.6 Network meta-regression
12.7 NMA of survival outcomes: fractional polynomials and time-varying hazard ratios
12.8 Ranking, SUCRA and rankograms
12.9 Reporting per NICE DSU TSD 2, ISPOR and PRISMA-NMA

## Bridge from Chapter 11
Opens by contrasting Ch.11's pairwise meta-analysis (every trial compares
the same two treatments) against the new problem: treatments compared only
through a shared comparator, never head-to-head. The whole chapter is one
idea at increasing scale — combine evidence only through relative effects
anchored on a common comparator, never by comparing absolute outcomes
across trials.

## Key claims and notation established (binding for later chapters)
- **§12.1**: naive cross-trial absolute-outcome comparison destroys
  randomisation and is invalid; anchored indirect comparison preserves
  within-trial randomisation by working only with relative effects.
- **§12.2 Bucher method**: $log("HR"_(A C)) = log("HR"_(A B)) - log("HR"_(C B))$
  with variances *adding* (not subtracting) because the two pooled
  estimates are independent. Worked TB example: $d_(A C)=-0.52$ (SE 0.18),
  $d_(B C)=-0.28$ (SE 0.21) → indirect $d_(A B)=-0.24$, SE 0.2767, HR 0.79,
  95% CI (0.46, 1.35) — arithmetic independently verified. Hard limit:
  only valid for a single common-comparator star/triangle network;
  relies on the transitivity/similarity assumption.
- **§12.3 netmeta**: `pairwise()` (arm-level → contrast-level reshape),
  `netmeta()` (fits the network, common+random effects side by side,
  `reference.group=`), `netgraph()` (network diagram, edge thickness by
  study count), `netrank()` (P-scores), `netleague()` (full pairwise
  league table). `decomp.design()` flagged for the global consistency
  check, detailed fully in §12.5. The network-graph `#figure` in §12.3.4
  uses the already-supplied Track-2 PNG `ch12_network_graph.png`.
- **§12.4 Bayesian NMA**: `gemtc` (JAGS-based, `mtc.network()`/
  `mtc.model()`/`mtc.run()`, closest to NICE DSU TSD 2's own worked
  examples), `multinma` (Stan-based, Phillippo et al., supports mixed
  IPD+AgD networks, forward-points to Ch.13's ML-NMR), `bnma` (lighter
  JAGS alternative). Three real reasons Bayesian is preferred for NMA:
  full posterior for probabilistic CEA, correct multi-arm-trial
  correlation handling, direct feed of MCMC draws into a PSA.
  `gelman.diag()` convergence check (threshold <1.05) explicitly
  required before trusting any posterior summary; full MCMC diagnostics
  detail deliberately deferred to Chapter 14 rather than duplicated here.
- **§12.5 consistency**: *transitivity* (the assumption) vs *consistency*
  (its statistical footprint) explicitly distinguished from Ch.11's
  ordinary between-study heterogeneity — a new, network-specific concept.
  Node-splitting (`gemtc::mtc.nodesplit()`, `netmeta::netsplit()`) checks
  one edge at a time; design-by-treatment interaction (Higgins et al.
  2012, `netmeta::decomp.design()`) decomposes Cochran's $Q$ into
  within-design and inconsistency components globally. NICE DSU TSD 4
  named. Pitfall: a non-significant inconsistency test is underpowered,
  not proof of consistency.
- **§12.6 network meta-regression**: `gemtc::mtc.model(regressor=...)`
  and `multinma::nma(regression=~cov*.trt)`. Explicitly reuses and
  intensifies Ch.11 §11.4's ecological-bias caveat — now the covariate
  also has to explain inconsistency, not just heterogeneity, and data
  requirements grow. Forward-points the resulting data-hunger limitation
  to Chapter 13's IPD-based population-adjustment methods (MAIC, STC,
  ML-NMR) as the next natural escalation when study-level covariates
  are not enough.
- **§12.7 survival NMA**: extends Ch.11 §11.5's established mechanism
  (pooled log(HR) as multiplier on a Ch.10 flexsurv reference-arm hazard)
  to a full network, first under proportional hazards, then via
  fractional-polynomial models (Jansen 2011, NICE DSU TSD 18/companion
  guidance) for time-varying hazard ratios. Explicitly and honestly flags
  that NO mainstream CRAN package implements the full Jansen
  fractional-polynomial network survival model end to end — distinguishes
  the real, verified `flexsurv::flexsurvspline()` single-arm fitting step
  from the bespoke custom JAGS/Stan network step, rather than fabricating
  a function call. This is now a standing lesson for later chapters:
  when tooling genuinely doesn't exist, say so, don't invent it.
- **§12.8 ranking**: SUCRA (Salanti et al. 2011) from `gemtc::
  rank.probability()`/`sucra()`; P-scores (Rücker & Schwarzer 2015) as
  the frequentist analogue via `netmeta::netrank()` (already introduced
  in §12.3) and `rankogram()`. Pitfall established: a top SUCRA/P-score
  can coexist with wide, overlapping intervals vs. the next-best
  treatment — never report a ranking without the underlying effect
  estimates and their uncertainty alongside it.
- **§12.9 reporting**: NICE DSU TSD 2 (Dias et al. 2011) reporting
  checklist (network diagram, evidence table, fit statistics, consistency
  results, ranking-with-uncertainty); ISPOR good practice task force
  report (Jansen et al. 2014) as the complementary decision-maker audit
  lens; PRISMA-NMA extension (Hutton et al. 2015, *Annals of Internal
  Medicine*) adding network-specific SLR checklist items, explicitly
  cross-referenced to Chapter 6's PRISMA2020-package flow diagram rather
  than requiring a second diagram.

## Package/function-name verification (continuing Ch.6-11's lesson)
All functions cross-checked as real before acceptance: `netmeta::
pairwise()`, `netmeta()`, `netgraph()`, `netrank()`, `netleague()`,
`rankogram()`, `decomp.design()`, `netsplit()`; `gemtc::mtc.network()`,
`mtc.model()`, `mtc.run()`, `mtc.nodesplit()`, `rank.probability()`,
`sucra()`; `multinma::set_agd_arm()`, `nma()`, `relative_effects()`;
`flexsurv::flexsurvspline()` (reused from Ch.10). No invented functions
found. Where real tooling genuinely does not exist (full fractional-
polynomial network survival model, §12.7), the chapter says so explicitly
rather than inventing a function — a new instance of the Ch.8/Ch.10
cautious-uncertainty pattern, now extended from "argument spelling
uncertain" to "no package implements this at all."

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: no new candidate — checked and
  logged as Skipped (C10 in `image_tracker.md`): the network-geometry
  visualisation is already covered by the Track-2 `netgraph()` output
  (T11, already supplied and embedded), so no separate conceptual
  diagram is needed.
- **Track 2 (R-generated charts)**: one entry, already supplied and
  embedded (not pending) — the `netmeta::netgraph()` network diagram
  for the chapter's 4-treatment worked TB example, inserted as a
  captioned, labelled `#figure()` in §12.3.4 (`<fig-ch12-netgraph>`).
  Logged as T11, status Done.

## Jev rubric scores (raw, 1-10 scale)
First pass, ALL SIX dimensions pass — no revision needed: coverage 8.32,
technical_correctness 8.09, code_validity 7.55, agency_grounding 8.17,
internal_consistency 8.57, readability 6.29.

## Open items / things later chapters should not contradict
- Chapter 13 (Population-Adjusted Indirect Comparisons) should pick up
  directly from §12.6's closing forward-pointer: network meta-regression
  is data-hungry and relies on study-level (ecological) covariates, which
  is exactly the gap MAIC/STC/ML-NMR exist to close with individual
  patient data.
- The pooled-log(HR)-as-multiplier mechanism from Ch.11 §11.5 is now
  extended to full networks (§12.3-12.4 constant-HR case) and to
  time-varying hazard ratios (§12.7 fractional-polynomial case) — later
  decision-modelling chapters (17-20) building comparator-arm survival
  curves fed by an NMA rather than a single pairwise meta-analysis should
  reuse this exact extended mechanism.
- NICE DSU TSD 2 and TSD 4 are now both established, specifically-named
  agency references for this book; any later chapter discussing NMA
  methodology or its reporting should cite them by number, not generically.
- The §12.7 honesty pattern ("no CRAN package does this end-to-end, here
  is the real building-block function and here is what remains bespoke")
  is a new standing lesson — apply it in any future chapter where the
  state-of-the-art genuinely outpaces available R tooling (a plausible
  recurrence point: Ch.22 dynamic/agent-based models, Ch.26 EVSI's more
  exotic computation methods).
- No unresolved open flags from this chapter.
