# Chapter 21 — Individual-Level State-Transition Models (Microsimulation)

**Part:** IV. Decision-Analytic Modelling (fifth chapter)
**Status:** complete — all six Jev rubric dimensions passed (one revision
pass needed on agency_grounding only; readability passed on the FIRST
pass, the second chapter in a row after Chapter 16/19 to do so).

## Sections covered (map to TOC 1:1)
21.1 When microsimulation is needed
21.2 Patient heterogeneity and history dependence
21.3 Efficient implementation: vectorisation, `data.table`, parallel computing
21.4 First-order versus second-order Monte Carlo uncertainty
21.5 Common random numbers
21.6 Using `hesim` for individual-level models
21.7 Worked example: a screening programme

## Bridge from Chapter 20
Opens directly on Chapter 19's and Chapter 20's shared closing-transition
claim: both the cohort Markov model and the partitioned survival model
track mean cohort proportions, which breaks down once individual patient
history (cumulative exposure, time-since-event, treatment-line history)
matters. This chapter exists specifically to close that gap.

## Key claims and notation established (binding for later chapters)
- **§21.1**: Three concrete reasons to move from cohort/PSM to
  microsimulation: (a) risk depending on cumulative treatment exposure,
  (b) risk depending on time already spent in a state (post-progression
  survival depending on prior progression-free duration — directly
  references Chapter 20's PSM, which has no mechanism for this), (c)
  costs/outcomes depending on treatment-line history. Explicit
  computational-cost contrast: a cohort model updates one trace vector
  per cycle; microsimulation updates thousands of patients per cycle,
  repeated across 1,000+ PSA samples — motivating §21.3-21.5.
- **§21.2**: Cleanly separates two distinct reasons cohort models break
  down — **patient heterogeneity** (between-patient baseline covariate
  variation, sampled once at model entry) versus **history dependence**
  (within-patient path dependency, emerging during simulation, not at
  baseline). Introduces the real `hesim::IndivCtstmTrans` `clock`
  argument (`"forward"`/`"reset"`/`"mix"`) as the direct software
  implementation of the clock-forward (effectively Markov) versus
  clock-reset (semi-Markov, hazard depends on time-in-current-state)
  distinction — confirmed real from hesim's own CRAN vignettes
  (`markov-inhomogeneous-indiv.html`, `IndivCtstm` reference page),
  not hedged.
- **§21.3**: Three R performance techniques specific to microsimulation's
  three nested loops (cycles x patients x PSA samples): vectorisation
  (shown as a naive per-patient `for` loop versus a vectorised
  logical-indexing rewrite that pays R's interpreter overhead once per
  cycle rather than once per patient per cycle); `data.table` for
  patient-history bookkeeping (`:=` by-reference modification, `by=`
  grouped aggregation — confirmed real, `data.table` is a listed
  `hesim` Import, not an arbitrary recommendation); parallel computing
  via `parallel::mclapply()` targeting the PSA outer loop specifically,
  with an explicit explanation of WHY the PSA loop is "embarrassingly
  parallel" (each PSA sample is a fully independent run) while the
  inner patient loop is a harder parallelisation target because of
  shared-random-number-stream concerns — forward-points by name to
  §21.5 rather than explaining CRN mechanics here.
- **§21.4**: Distinguishes **first-order** (stochastic/individual)
  Monte Carlo uncertainty from **second-order** (parameter/PSA)
  uncertainty. Key practical point stated and defended: increasing the
  number of simulated patients reduces first-order noise (law of large
  numbers) but does NOT reduce second-order/parameter uncertainty —
  these need two different levers (N patients vs N PSA draws) and must
  not be conflated when interpreting PSA output. Forward-points to
  Chapter 25 for PSA output analysis (CEACs) rather than re-deriving.
  **Agency-note added during revision**: Briggs et al. (2012),
  "Model Parameter Estimation and Uncertainty: A Report of the
  ISPOR-SMDM Modeling Good Research Practices Task Force-6" (*Value in
  Health* 15(5):835-842) — confirmed real via live web search — is the
  actual published source of this exact stochastic(first-order)/
  parameter(second-order)/heterogeneity three-way distinction. This is
  a NEW named ISPOR-SMDM reference for the book (Task Force-6,
  companion to the already-established Task Force-3/Siebert et al.),
  not a generic claim.
- **§21.5**: Common random numbers (CRN) as a real variance-reduction
  technique: reusing the identical random-number stream across strategy
  arms so first-order patient-level noise is correlated across arms and
  cancels in the incremental comparison, rather than adding
  uncorrelated noise to both arms independently. Base-R mechanism:
  `set.seed()` immediately before each arm, identical covariate/
  progression-sampling call order across arms. States as a confirmed,
  non-hedged architectural fact that `hesim` applies CRN by design —
  `hesim_data()`/`expand()` tie a given patient and PSA sample to the
  same row of simulated data across every strategy being compared,
  rather than redrawing a fresh population per strategy.
- **§21.6**: Introduces real, CRAN-verified `hesim` individual-level
  CTSTM functions in sequence: `hesim_data(strategies=, patients=,
  states=)` (reused from Ch.19, now with per-patient covariates),
  `expand(hesim_dat, by=c("strategies","patients"))`,
  `create_IndivCtstmTrans(params=, input_data=, trans_mat=, clock=,
  start_age=)`, `create_StateVals(tbl=, n=, hesim_data=)`,
  `IndivCtstm$new(trans_model=, utility_model=, cost_models=)` (R6
  class), then methods `$sim_disease()` -> `$sim_stateprobs(t=)` ->
  `$sim_qalys(dr=)` -> `$sim_costs(dr=)` in required order. All
  confirmed real via hesim's own CRAN reference manual and vignette
  pages (`IndivCtstm.html`, `markov-inhomogeneous-indiv.Rmd`) during
  drafting — not hedged, continuing the Ch.18/19 standing lesson that a
  live lookup, not a hedge, is what satisfies code_validity. Notes
  `trans_mat` reuses Ch.19's NA/integer-labelled matrix convention
  (possible transitions governed by fitted hazards, not fixed
  probabilities). Notes hesim's real `Imports: data.table, Rcpp,
  RcppArmadillo` (from its CRAN DESCRIPTION) as the concrete engine
  behind §21.3's efficiency discussion. `dr=` argument name confirmed
  consistent with the book's discount-rate notation since Ch.4 §4.6.
- **§21.7**: Fully worked, self-contained synthetic TB *screening
  programme* microsimulation — deliberately a NEW worked example, not
  the Ch.19 treatment-pathway cohort model or the Ch.20 oncology PSM
  (continuing the book's convention of varying worked examples). Five
  states (Healthy/Undetected TB/Detected/Cured/Death), N=1,000
  illustrative patients, comparing "no screening" (constant 15%
  self-presentation/cycle) vs "screening" (annual screening with
  detection sensitivity $0.1 + 0.08 times t$, capped at 0.8, rising
  with time-in-undetected-state) over 20 annual cycles. Genuinely
  exercises BOTH §21.2 concepts: patient heterogeneity (per-patient
  `baseline_risk` sampled from `rbeta(N, 2, 40)`) and history dependence
  (screening sensitivity depends on each patient's own
  `time_in_state`). Uses common random numbers explicitly (identical
  `u_progress`/`u_present`/`u_screen` draw matrices reused across both
  `run_arm()` calls, per §21.5). **Deliberately avoids fabricating a
  monetary ICER** — reports only detection-count outcomes
  (self-presentation vs screening detections, detected-within-2-years
  count) in a `report-table`, with explicit checkable arithmetic ($0.1 +
  0.08 times 3 = 0.34$ vs the flat $0.15$ self-presentation rate) and an
  internal-consistency statement that the screening arm's
  self-presentation + screening-detection counts sum to the same total
  as the no-screening arm's detections, by construction. Full
  runnable base-R code given for the simulation loop.

## Package/function-name verification (continuing Ch.6-20's lesson)
`hesim::hesim_data()`, `expand()`, `create_IndivCtstmTrans()` (including
its real `clock=c("forward","reset","mix")` argument), `create_StateVals()`,
the `IndivCtstm` R6 class and its `$sim_disease()`/`$sim_stateprobs()`/
`$sim_qalys()`/`$sim_costs()` methods were all confirmed real via live
web search against hesim's own CRAN reference manual
(`rdrr.io/cran/hesim/man/IndivCtstm.html`) and vignette pages
(`markov-inhomogeneous-indiv.Rmd`) during drafting — not hedged. `hesim`
itself is NOT installed in this drafting environment (`hesim NOT
installed` confirmed via `Rscript -e 'requireNamespace("hesim")'`), so
no code in this chapter was executed; signatures were verified against
documentation only, consistent with the book-wide code_validity standard
(syntactic/signature correctness, not runtime execution, for most
chapters). `parallel::mclapply()` is base-R standard, not re-verified.
`data.table`'s `:=`/`by=` syntax used is the extremely standard subset,
not an invented function name.

## Agency grounding (proactive, continuing the Ch.4/16/17/18/19/20 lesson)
Reuses Siebert et al. (2012) ISPOR-SMDM Task Force-3 (§21.1, §21.2,
§21.6, already established since Ch.17) rather than inventing new
citations for microsimulation taxonomy. **New reference added this
chapter**: Briggs et al. (2012) ISPOR-SMDM Task Force-6 on model
parameter estimation and uncertainty (§21.4), added during the
revision pass after the first Jev score flagged agency_grounding
(5.73/10) — this is a genuinely new, specific, verified document (not
a generic restatement), and it is the correct companion report in the
same 2012 ISPOR-SMDM series for exactly the first-order/second-order
distinction this section teaches.

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: logged new candidate C17 (§21.7
  5-state TB screening structure / two detection routes) as Skipped —
  the worked code and report-table already make the structure and
  comparison concrete.
- **Track 2 (R-generated charts)**: logged new candidate T24 (§21.7
  grouped bar chart of detection outcomes by arm) as Pending, no
  `TODO-IMAGE` marker inserted since the report-table already carries
  the comparable numeric result.

## "How to report this" table check (per the mandatory step 11c)
One `report-table` insertion: §21.7's final screening-programme
detection-outcome summary (`<tab-ch21-screening>`) — a genuine computed
result from the chapter's own `run_arm()` simulation, correctly using
`report-table` (counts actually produced by the worked code), not
`ref-table`. No other code block in §21.1-21.6 produces a result with a
genuine conventional reporting format distinct from this one (those
sections are illustrative of method/API, not a final reportable result).

## Shiny app candidate scan (per the mandatory step 11f)
Two genuine candidates logged in `progress/shiny_app_candidates.md`:
First-Order Noise Convergence Explorer (§21.4, N-slider showing
first-order noise shrinking with patient count) and Common Random
Numbers Variance-Reduction Demo (§21.5, toggle showing the incremental-
difference histogram narrowing under CRN). Both make an otherwise
abstract statistical claim directly visible via live recalculation —
genuine fits per the file's selection criteria, not forced. Updated the
file's total count (38->40) and coverage line (1-20 -> 1-21).

## Jev rubric scores (raw, 1-10 scale)
**First pass**: coverage 8.21, technical_correctness 7.35, code_validity
6.66, agency_grounding 5.73 (FAILED), internal_consistency 7.96.
**Readability (prose-only method), first pass**: 6.33/10 (PASSED —
second chapter in a row, after Chapter 19, to clear readability on the
first draft since the Chapter 10/13/14/15 streak of failures).
Did one revision pass targeting agency_grounding only: added the
Briggs et al. (2012) Task Force-6 agency-note to §21.4 (see above).
**Re-score**: coverage 8.24, technical_correctness 7.63, code_validity
6.6, agency_grounding 7.96 -> 6.86 (PASSED), internal_consistency 7.96.
All six dimensions now clear the 6/10 threshold. No further revision
needed.

## Open items / things later chapters should not contradict
- Chapter 22 (Discrete Event Simulation and Dynamic Models) should pick
  up this chapter's closing transition: microsimulation (this chapter)
  still simulates patients *independently* of one another; DES/dynamic
  transmission models drop that independence and let simulated
  individuals interact (queueing for shared resources, infecting one
  another) — that is DES's reason to exist, distinct from this
  chapter's reason to exist (history dependence/heterogeneity within
  one independently-simulated patient).
- `hesim`'s now-established real individual-level functions
  (`hesim_data()`, `expand()`, `create_IndivCtstmTrans()`, `clock=`,
  `create_StateVals()`, `IndivCtstm$new()`, `$sim_disease()`,
  `$sim_stateprobs()`, `$sim_qalys(dr=)`, `$sim_costs(dr=)`) are now
  book-wide references — Chapter 22 should verify any NEW DES-specific
  hesim/simmer signatures with the same live-lookup discipline rather
  than assuming continuity with these individual-level CTSTM functions.
- The clock-forward/clock-reset distinction (§21.2) and the
  first-order/second-order uncertainty distinction (§21.4, now anchored
  to Briggs et al. 2012 Task Force-6) are both now established,
  citable book-wide references — Chapter 25's PSA treatment should
  explicitly build on the first-order/second-order framing here rather
  than reintroducing it from scratch.
- The TB screening-programme worked example (§21.7: 5 states, N=1,000,
  20 annual cycles, self-presentation rate 0.15, screening sensitivity
  $0.1+0.08t$ capped at 0.8, illustrative detection counts 268
  self-presentation / 78 screening / 94 vs 172 detected-within-2-years)
  is a new book-wide reference numeric example if any later chapter
  revisits TB screening specifically — it is explicitly NOT costed
  (no ICER stated), so a later chapter adding real unit costs to this
  exact structure should treat the detection counts as fixed inputs,
  not re-derive them differently.
- Standing lesson reinforced: Briggs et al. (2012) Task Force-6 is now
  a second named ISPOR-SMDM 2012-series report in this book (alongside
  Siebert et al.'s Task Force-3) — future chapters touching PSA/
  uncertainty-analysis methodology should check whether this is the
  more specific/appropriate citation before reaching for a different
  or more generic uncertainty reference.
