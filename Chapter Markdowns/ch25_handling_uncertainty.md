# Chapter 25: Handling Uncertainty

**Part V: Uncertainty, Value of Information and Model Validation** (first chapter of Part V — a new real Part V divider was inserted in `book.typ` immediately before this chapter's include, following the Part I–IV precedent built earlier in this session).

## Status
Drafted manually on 2026-10-20, continuing Dr Aswath's direct request to accelerate rather than wait for the next cron tick (the same request that produced Chapter 24). All six Jev rubric dimensions passed on the first draft — third chapter in a row (after Ch.23, Ch.24) to do so.

## Jev scores (raw, 1–10)
- Coverage: 8.59
- Technical correctness: 7.63
- Code validity: 7.87
- Agency grounding: 6.21
- Internal consistency: 8.16
- Readability (prose-only): 6.32

All six clear the 6/10 threshold — no revision pass needed.

## What the chapter covers

**25.1 Types of uncertainty.** Uses Briggs, Weinstein, Fenwick, Karnon, Sculpher and Paltiel's ISPOR-SMDM Task Force-6 report (*Value in Health* / *Medical Decision Making*, 2012) as the authoritative taxonomy: parameter uncertainty (imprecision in a single input estimate — what PSA addresses), structural uncertainty (which model shape/assumption set is correct — Markov vs partitioned survival, survival-distribution choice, comparator set), methodological uncertainty (which analytic convention governs — discount rate, perspective, utility value set; resolved by adopting a reference case rather than probabilistic weighting), and heterogeneity (real, explainable variation across patient subgroups — explicitly NOT a form of uncertainty, and the classic pitfall of pooling it into a single PSA distribution is called out explicitly). Bilcke, Beutels, Brisson and Jit (2011, *Medical Decision Making*) is cited for the practical handling of structural/methodological uncertainty via named scenario analysis.

**25.2 Deterministic sensitivity analysis.** One-way sensitivity analysis on five parameters (New-regimen cure probability, shared p(Fail→Death), annual discount rate, New-regimen drug cost, shared on-treatment utility) of a simplified, reused Chapter 19 4-state TB Markov model (the same New-regimen-vs-SoC comparison set up in Chapter 17). Base case: incremental cost −$844.14, incremental QALY 0.1440, incremental NMB $8,044 at WTP=$50,000/QALY — independently re-verified in Python. Two-way sensitivity analysis on the two most influential parameters (cure probability × drug cost) confirms the decision does not flip even at the worst joint corner tested (NMB still $3,106). A tornado diagram is built in `ggplot2`, with an explicit pitfall box on using `pmin()`/`pmax()` defensively since the discount rate's "low" bound actually produces the *higher* NMB — a common source of mis-drawn tornado bars.

**25.3 Scenario analysis scripts.** Distinguishes scenario analysis (named, coherent parameter bundles — "optimistic"/"pessimistic") from deterministic sensitivity analysis (one-at-a-time parameter isolation) via a difficult-terminology box. Builds a fully generic `run_scenarios()` engine using `modifyList()` that works unmodified against any model function with a "named list in, named vector out" signature. Worked optimistic/base/pessimistic example reusing Chapter 19's 4-state model, independently verified in both R logic and a parallel Python re-implementation.

**25.4 Probabilistic sensitivity analysis: choosing distributions.** This section delivers on Chapter 19 §19.8's explicit promise ("Chapter 25 covers the general conventions for choosing PSA distributions for different parameter types") — Beta for probabilities/proportions (pseudo-count parameterization), Gamma or lognormal for costs (right-skewed, non-negative), Beta for utilities, (log-)normal for relative-effect estimates, and multivariate normal via Cholesky decomposition for correlated relative effects — explicitly cross-referencing rather than re-deriving Chapter 19's Dirichlet/Cholesky machinery for transition-matrix rows. Includes hand-checked 5-draw verification per distribution family, then a full n=2000 PSA loop with an explicit convergence/Monte Carlo error check (running mean stabilizes by N=1000–1500).

**25.5 Visualising uncertainty.** Builds all four standard PSA visualizations (CE plane, CEAC, CEAF, incremental-NMB histogram) directly in `ggplot2`, since `dampack` and `BCEA` are confirmed not installed in this drafting environment (flagged per the tooling-honesty rule). BCEA's real CRAN functions (`bcea()`, `ceac.plot()`, `multi.ce()`) were confirmed via a live web search before being cited by name.

**25.6 Threshold analysis.** Built explicitly as the computational mirror of Chapter 24 §24.5's value-based-pricing rearranged ICER formula. Worked breakeven-cost example reusing §25.3's base case: a 0.15-QALY-gain regimen's breakeven total cost at WTP=$50,000/QALY is $8,455.34 — independently verified in Python.

## Numeric verification
Every stated numeric claim in the chapter was independently re-computed in Python before being accepted: base-case incremental NMB ($8,044), all 5 one-way sensitivity swings, the 3×3 two-way grid, the 3-scenario cost/QALY table, and the threshold-analysis breakeven cost — all exact matches with no corrections needed.

## Mandatory per-tick steps
- **Image tracker**: 5 new `TODO-IMAGE` entries (T33–T37: tornado diagram, CE plane, CEAC, CEAF, NMB histogram) plus one explicit skip (C20 — uncertainty taxonomy already made concrete by its own ref-table).
- **Shiny candidates**: 3 new genuine candidates added — Tornado Diagram Parameter-Range Explorer, PSA Distribution & CEAC Explorer, Threshold Analysis Breakeven Calculator. Total now 49 across 23 chapters.
- **Code extraction**: 14 R code blocks extracted to `code/ch25_handling_uncertainty/`.
- **renv.lock**: 4 packages, all verified installed.
- **Difficult terminology**: 6 boxes inserted inline during drafting (stochastic/first-order uncertainty, net monetary benefit, scenario vs. one-way sensitivity analysis, multivariate normal distribution, Monte Carlo error, CEAC, CEAF, threshold analysis).

## Compile result
Compiled cleanly on the first pass, zero warnings. `book.pdf` grew from 410 to **438 pages**. New Part V divider page visually verified clean via `pdftoppm` + `vision_analyze`.

## Continuity notes for Chapter 26
Chapter 26 (Value of Information Analysis) is the second chapter of Part V — no new Part divider needed. It should build directly on this chapter's PSA machinery (the n=2000 PSA loop, NMB framework) rather than re-deriving it, extending into EVPI/EVPPI territory.
