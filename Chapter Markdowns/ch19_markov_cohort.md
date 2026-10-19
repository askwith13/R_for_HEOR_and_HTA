# Chapter 19 — Markov Cohort Models

**Part:** IV. Decision-Analytic Modelling (third chapter)
**Status:** complete — ALL SIX Jev rubric dimensions passed on the FIRST
draft, no revision pass needed (coverage 8.36, technical_correctness
7.57, code_validity 7.9, agency_grounding 7.68, internal_consistency
8.38, readability 6.61 prose-only).

## Sections covered (map to TOC 1:1)
19.1 States, transitions and cycles
19.2 Time-homogeneous and time-dependent transition matrices
19.3 Building a Markov model in base R (matrix-based approach)
19.4 Using `heemod`, `hesim` and `dampack`
19.5 Applying costs and QALYs, discounting and half-cycle correction
19.6 Tunnel states and state residence time
19.7 Age-dependent transitions and background mortality
19.8 Probabilistic transition matrices (Dirichlet) and Cholesky decomposition
19.9 Calibration and validation
19.10 Worked example: a chronic-disease CEA

## Bridge from Chapter 18 / honouring Chapter 17's forward commitment
Opens by explicitly honouring Chapter 17 §17.2's resolution of the TB
regimen question (4-month rifapentine-moxifloxacin, Study 31/A5349, vs
6-month standard 2HRZE/4HR) to a Markov cohort model, and reuses §17.3's
`DiagrammeR::grViz()`-diagrammed 4-state structure (On Treatment / Cured
/ Treatment Failure / Death, with the `Fail -> OnTx` back-edge and Death
reachable from every state) verbatim as this chapter's running example —
exactly the commitment Chapter 17's markdown flagged as binding for this
chapter. Also fulfils Chapter 18 §18.5's tree-to-Markov handoff pattern
conceptually (not literally re-run), since §19.1's initial occupancy
vector (100% On Treatment) is the simple starting distribution Chapter
18's markdown anticipated this chapter might use if a full tree-integration
was out of scope.

## Key claims and notation established (binding for later chapters)
- **§19.1**: Markov state/transition probability/cycle/memorylessness
  defined. Illustrative per-6-month-cycle TB transition probabilities
  established as book-wide reference numbers: p(OnTx->Cured)=0.75,
  p(OnTx->Fail)=0.08, p(OnTx->Death)=0.02, p(OnTx->OnTx)=0.15;
  p(Fail->OnTx)=0.60, p(Fail->Death)=0.15, p(Fail->Fail)=0.25;
  p(Cured->Death)=0.01 (background mortality), p(Cured->Cured)=0.99;
  Death fully absorbing. All rows independently re-verified to sum to
  1.00. Pitfall on row-sum/absorbing-state leakage bugs. Agency-note
  reuses Siebert et al. (2012) ISPOR-SMDM Task Force-3 (already
  established in Ch.17) rather than inventing a new citation.
- **§19.2**: Time-homogeneous vs time-dependent matrices; TB
  treatment-failure front-loading as the motivating real-world example;
  explicit forward-pointers to §19.6 (tunnel states) and §19.7
  (age-dependent background mortality) as the two mechanisms that
  implement time-dependence within an otherwise homogeneous framework.
- **§19.3**: Full runnable base-R matrix-and-loop cohort trace (4x4
  transition matrix, `rowSums()` stopifnot defensive check, 20-cycle
  loop via `%*%`). Occupancy trace at cycles 0/5/10/20 independently
  recomputed and verified exactly: cycle 5 (0.0054, 0.9130, 0.0025,
  0.0791), cycle 10 (0.0001, 0.8750, 0.0000, 0.1249), cycle 20 (0.0000,
  0.7914, 0.0000, 0.2086) for (OnTx, Cured, Fail, Death). `report-table`
  inserted with this computed result. `TODO-IMAGE` marker inserted
  immediately after for a full-trace plot (Track 2 T21).
- **§19.4**: Verified real CRAN signatures via live documentation
  lookup (not hedged, continuing the Ch.18 standing lesson):
  `heemod::define_transition(state_names=, ...)` with the `C`
  complementary-probability keyword; `define_state(cost=, utility=)`;
  `define_strategy(transition=, <state-name>=<state-object>, ...)`;
  `run_model(..., parameters=, init=, cycles=, method=c("life-table",
  "beginning","end"), cost=, effect=)`. A worked 2-state `heemod`
  rebuild demonstrates the `C` keyword exactly reproducing the §19.1
  hand-derived remainder probabilities. `hesim::hesim_data(strategies=,
  patients=, states=)`, `define_tparams()`, `tpmatrix()`,
  `create_CohortDtstm()` introduced as a real but only sketched
  architecture (full hesim PSA usage explicitly deferred to Ch.25).
  `dampack::calculate_icers(cost=, effect=, strategies=)` introduced as
  the standard ICER post-processing step; `dampack`'s PSA/VOI functions
  (`run_psa()`, `owsa()`, `ceac()`) explicitly deferred to Ch.25-26.
- **§19.5**: Discounting formula $DF(t)=(1+r)^{-t}$ cross-referenced to
  Ch.4 §4.6 (not re-derived). NICE's 3.5%-per-annum reference-case rate
  converted to a per-6-month-cycle rate: $(1.035)^{0.5}-1 = 0.017349$,
  independently recomputed. Half-cycle correction (trapezoidal/
  life-table averaging) explicitly tied to `heemod::run_model()`'s
  `method = "life-table"` default from §19.4 as the real software
  implementation of the same correction. Worked 5-cycle QALY discounting
  example independently recomputed: undiscounted total 2.140, discounted
  total 2.031 (~5.1% reduction).
- **§19.6**: Tunnel-state concept (OnTx_cycle1/2/3 sub-states) explained
  as the fix for time-since-state-entry-dependent risk, distinct from
  §19.2's generic time-dependence. `heemod`'s real, documented
  `state_time` variable introduced as the automatic tunnel-expansion
  mechanism. Pitfall callout on cycles-since-model-start vs
  cycles-since-state-entry, tied explicitly to the `Fail -> OnTx`
  re-entry back-edge established in §19.1.
- **§19.7**: Additive-hazard vs max-of-two-probabilities methods for
  combining background mortality with disease-specific death without
  double-counting; NICE DSU guidance named as preferring the
  hazard-based combination. `heemod`'s `model_time` variable introduced
  as distinct from §19.6's `state_time` (cycles since model start vs
  cycles since state entry). Cross-references Chapter 10's background-
  mortality/extrapolation treatment by name rather than re-deriving it.
- **§19.8**: Dirichlet distribution established as the correct
  multivariate distribution for whole-row PSA sampling of a transition
  matrix (vs independent per-cell Betas, which break the sum-to-1
  constraint); `dampack::rdirichlet()` identified as the real exported
  function for this. Cholesky decomposition (`chol()` in base R;
  `heemod`'s real `Suggests`-listed `mvnfast` dependency) introduced,
  kept conceptual, for correlated continuous PSA parameters — explicitly
  flagged as a *different* tool for a *different* problem (whole-row
  constraint vs cross-parameter correlation), not interchangeable.
  Cross-references Chapter 25 by name for the full PSA treatment.
- **§19.9**: Calibration (adjusting unobserved parameters to match
  external targets) explicitly distinguished from validation (face,
  internal/verification, cross, external). States precisely where both
  belong in the workflow: after the base-case `run_model()` run, before
  PSA. Forward-points by name (without explaining mechanics) to Chapter
  27 for calibration methods (random search, Nelder-Mead, Bayesian
  calibration, ABC, IMIS) and validation frameworks (AdViSHE, TECH-VER,
  ISPOR-SMDM). Agency-note reuses the ISPOR-SMDM Task Force's
  verification-vs-validation distinction rather than inventing a new
  framing.
- **§19.10**: Fully worked, self-contained chronic-disease (Well /
  Diseased / Dead) CEA comparing a disease-modifying therapy (DMT)
  against standard care (SoC) — deliberately NOT the TB example, per the
  skill's convention of varying worked examples within a chapter where
  useful. 3x3 transition matrices per arm, each row independently
  verified to sum to 1.00. Half-cycle-corrected, 3%-annual-discounted
  base-R run over 20 cycles. All arithmetic independently recomputed:
  SoC discounted cost \$29,317.05 / QALYs 5.5522; DMT discounted cost
  \$56,917.97 / QALYs 6.6704; incremental cost \$27,600.92; incremental
  QALYs 1.1181; ICER \$24,685/QALY (recomputed as
  27,600.92 / 1.1181 = 24,685.08, confirmed below the conventional
  \$30,000-\$50,000 WTP threshold). `report-table` inserted with the full
  CEA result. Closes the chapter with a transition to Chapter 20
  (Partitioned Survival Models), explicitly citing Ch.17 §17.2's
  model-type framework for when a PSM (survival-curve-driven) is the
  better structural choice over a hand-specified transition matrix.

## Package/function-name verification (continuing Ch.6-18's lesson)
`heemod::define_transition()`, `define_state()`, `define_strategy()`,
`run_model()` (including its `method=` argument's three real values and
the `C` keyword), `state_time`, and `model_time` all confirmed real via
live CRAN reference-manual/vignette lookup during drafting (continuing
the Ch.18 lesson that a hedge is not itself sufficient — the live
lookup was done, not just disclosed as uncertain). `hesim::hesim_data()`,
`define_tparams()`, `tpmatrix()`, `create_CohortDtstm()` confirmed real
via `hesim`'s own CRAN vignette (`markov-cohort.html`), used only in a
clearly-labelled sketch rather than a complete worked example, since
full hesim PSA mechanics are Ch.25's job. `dampack::calculate_icers()`
and `dampack::rdirichlet()` confirmed real via `dampack`'s own CRAN
reference manual. `mvnfast` confirmed as a real `heemod` `Suggests`
dependency (not invented) from `heemod`'s own CRAN `DESCRIPTION`.

## Agency grounding (proactive, per the Ch.4/16/17/18 lesson)
Reuses Siebert et al. (2012) ISPOR-SMDM Task Force-3 (§19.1, already
established in Ch.17) and the ISPOR-SMDM Task Force's
verification-vs-validation framing (§19.9) rather than inventing new
citations, since this chapter's content is a direct continuation of
Ch.17's already-grounded framework rather than introducing a genuinely
new methodological area. Names NICE DSU guidance on hazard-based
background-mortality combination (§19.7) and the NICE 3.5% reference-case
discount rate (§19.5, cross-referencing Ch.4) as the chapter's other
specific agency anchors.

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: logged new candidate C15 (§19.6
  tunnel-state expansion flowchart) as Pending, lower priority since the
  worked transition-matrix code already makes the tunnel mechanism
  concrete without a diagram.
- **Track 2 (R-generated charts)**: logged new candidate T21 (§19.3
  full 20-cycle occupancy trace, stacked-area/multi-line plot) as
  Pending, with a `// TODO-IMAGE` marker inserted at the exact point in
  `ch19_markov_cohort.typ` immediately after the report-table.

## "How to report this" table check (per the mandatory step 11c)
Two `report-table` insertions, both genuine computed results: §19.3's
occupancy trace at cycles 0/5/10/20, and §19.10's final chronic-disease
CEA result (cost/QALYs/incremental/ICER per arm). One `ref-table`
insertion: §19.10's transition-probability comparison table (SoC vs
DMT) — correctly classified as `ref-table` rather than `report-table`
since it is the chapter's own INPUT assumption, not a computed output.
§19.5's discounting-stream table is a `report-table` since it is a
computed result (the discounted QALY stream) from the chapter's own
worked arithmetic.

## Jev rubric scores (raw, 1-10 scale)
First pass, ALL SIX dimensions passed — no revision needed: coverage
8.36, technical_correctness 7.57, code_validity 7.9, agency_grounding
7.68, internal_consistency 8.38, readability 6.61 (prose-only method,
clears the 6/10 threshold).

## Open items / things later chapters should not contradict
- Chapter 20 (Partitioned Survival Models) should pick up directly from
  this chapter's closing transition, using Ch.17 §17.2's framework to
  justify PSMs as the right choice when outcomes are driven by
  extrapolated survival curves (Ch.10) rather than a hand-specified
  transition matrix — do NOT reuse the exact 4-state TB Markov structure
  from this chapter as the PSM's running example; a genuinely
  survival-curve-driven oncology-style example (per the TOC's own
  §20.6 "oncology CEA" worked-example framing) is more appropriate.
- `heemod`'s real, verified function signatures (`define_transition()`,
  `define_state()`, `define_strategy()`, `run_model()`, `state_time`,
  `model_time`) and `hesim`'s/`dampack`'s real signatures are now
  book-wide references — Chapter 20 should verify any further
  `hesim`/`flexsurv` combination signatures with the same live-lookup
  discipline before using them.
- The per-6-month-cycle TB transition probabilities established in
  §19.1 (p(OnTx->Cured)=0.75, etc.) are now book-wide reference numbers
  if any later chapter revisits this exact TB Markov example (e.g. a
  Chapter 25 PSA worked example reusing this base case) — reuse them
  rather than inventing new illustrative numbers for the same model.
- Dirichlet-for-whole-rows and Cholesky-for-correlated-normals (§19.8)
  is now a standing distinction Chapter 25's PSA-distribution-choice
  section should reference and build on, not re-derive from scratch.
- The calibration-vs-validation distinction and Chapter 27 forward-
  pointer (§19.9) is now established; Chapter 27 should explicitly
  pick up this exact framing (calibration = outputs pin down inputs;
  validation = is the model credible) rather than introducing a
  different taxonomy.
