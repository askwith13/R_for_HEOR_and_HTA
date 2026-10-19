# Chapter 22. Discrete Event Simulation and Dynamic Models

## Sections covered (all 6 TOC subsections)
- **22.1 Concepts: events, queues, resources and attributes** — picks up
  directly from Chapter 21's closing transition: microsimulation keeps
  each patient's heterogeneity and history but still simulates patients
  INDEPENDENTLY; DES drops that independence so patients can interact
  (queue for a nurse, compete for a bed). Introduces entity/arrival,
  event queue, resource+capacity, attribute, and trajectory via
  `difficult-terminology()` boxes, grounded in a single-nurse TB-screening
  clinic analogy used throughout the rest of the chapter. A pitfall
  explicitly distinguishes DES's resource-contention interaction from
  dynamic transmission models' infectious-contact interaction (§22.4).
- **22.2 DES with `simmer`** — real `simmer` API verified against
  r-simmer.org/CRAN docs: `simmer()`, `trajectory()`, `seize()`/`release()`,
  `timeout()`, `add_resource()`, `add_generator()`, `run()`,
  `get_mon_arrivals()`, `get_mon_resources()`. Worked M/M/1 single-nurse
  clinic example; verified by hand against the closed-form M/M/1 queueing
  benchmark (W_q = rho/(mu-lambda) = 32 min, L_q = 3.2, L = 4 for
  lambda=1/10, mu=1/8). Pitfall on `rexp()`'s rate-not-mean parameterisation.
- **22.3 Competing events and time-to-event sampling** — operationalises
  Chapter 10's competing-risks framing as literal DES mechanics: multiple
  candidate next-events race, smallest time wins. Flags honestly that
  `simmer`'s `timeout()` has no native race-and-take-minimum primitive, so
  the race must be resolved manually in R before being handed to
  `timeout()`/`branch()`. **Caught and fixed during assembly**: the
  original sub-agent draft called a non-existent `simmer::get_global_mgr()`
  inside a `branch()` option function — replaced with the real documented
  pattern, `get_attribute(env, "name")` where `env` is the `simmer()`
  object already in scope via normal R closure rules.
- **22.4 Infectious disease transmission models** — real SIR/SEIR ODEs in
  Typst math mode; `deSolve::ode()` worked toy SIR example (R0=2,
  N=10,000); `EpiModel`'s `dcm()`/`icm()`/`netsim()`/`netest()` introduced
  for agent-based/network alternatives with an explicit hedge that exact
  argument names vary by `EpiModel` version. `difficult-terminology()`
  boxes for homogeneous mixing assumption and network epidemic model.
  Links transmission-model output to cost-effectiveness accounting
  (infections/cases/deaths averted costed and QALY-weighted exactly as in
  Ch.17-20's static models). Pitfall on static models mis-estimating
  infectious-disease intervention value by missing herd/indirect
  protection, now anchored to a named, verified source (see Jev fix below).
- **22.5 Choosing between Markov, DES and dynamic models** — a `ref-table`
  (correctly, not `report-table` — this is a reference/comparison table,
  not a computed result) comparing Markov cohort / microsimulation / DES /
  dynamic transmission across individual heterogeneity, interaction,
  typical use, computational cost, and R package family. Decision rule:
  "does one simulated person's outcome change another's risk or resource
  access?"
- **22.6 Worked example: a TB screening/preventive-therapy intervention
  model** — SEIR compartmental model, `deSolve::ode()`, N=100,000, 10-year
  horizon, baseline (ve=0) vs 30%-effective programme (ve=0.3).
  **All numeric claims independently verified by actually running the
  embedded R code** during assembly (see verification section below) —
  every number in the prose and the `report-table` matched the real R
  output exactly. Explicit caveat that unit costs/QALY-loss figures are
  illustrative, not real TB costing data.

## Independent verification performed during assembly
Ran the chapter's own `deSolve::ode()` code (not just read it) via
`Rscript` to check every stated numeric claim before finalizing:
- Toy SIR (R0=2, N=10,000): peak day 45, peak infectious 15.3%, final
  attack rate 79.7% — all matched the draft's stated numbers exactly.
- TB SEIR worked example (§22.6): cumulative infections 4,979 (no
  intervention) vs 873 (intervention), 4,106 cases averted (82.5%
  reduction), peak infectious prevalence 1,417 vs 153, treatment cost
  $7.47M vs $1.31M, QALYs lost 747 vs 131, net budget impact -$5.60M —
  all matched the draft's stated numbers exactly. No arithmetic
  corrections needed this chapter (continuing the standing lesson from
  Ch.4/Ch.6: always re-run the numbers, don't just read for plausibility).

## Notation/terminology introduced (for later-chapter continuity)
- Entity/arrival, event queue, resource+capacity, attribute, trajectory
  (DES vocabulary, `simmer`-specific usage).
- `simmer`'s `get_attribute(env, name)` pattern for reading an
  entity attribute inside a `branch()` option function — `env` is the
  `simmer()` object captured by ordinary R closure rules, not a special
  accessor. (There is no `simmer::get_global_mgr()` — do not reuse that
  name in a later chapter.)
- SIR/SEIR notation: S, E, I, R compartments; beta (transmission rate),
  gamma (recovery rate), sigma (latent-to-active progression rate),
  R0 = beta/gamma (basic reproduction number), force of infection =
  beta*I/N (modified multiplicatively by (1-ve) when an intervention with
  effectiveness `ve` is present).
- "Homogeneous mixing assumption" and "network epidemic model" as new
  difficult-terminology entries — if a later chapter revisits agent-based
  or network models, cross-reference these rather than re-defining them.

## Agency grounding (three named ISPOR-SMDM Task Force reports now anchor this chapter)
- Karnon et al. (2012) ISPOR-SMDM Task Force-4, "Modeling Using Discrete
  Event Simulation" (Value in Health 15(5):821-827) — added as an
  agency-note in §22.1, naming its 5-stage best-practice framework
  (structural development, parameter estimation, model implementation,
  model analysis, representation/reporting).
- Pitman et al. (2012) ISPOR-SMDM Task Force-5, "Dynamic Transmission
  Modeling" (Value in Health 15(5):828-834) — used in §22.4's pitfall on
  static models missing herd/indirect protection.
- Siebert et al. (2012) ISPOR-SMDM Task Force-3 (already established in
  Ch.17/Ch.21) — explicitly tied to the §22.5 decision framework via a new
  agency-note, cross-referencing the Task Force-4/5 citations above so
  every row of the model-choice table traces to a named source.

## Image tracking (per skill's mandatory step 11b)
- **Track 1**: logged new candidate C18 (§22.1/22.4 DES mechanics +
  SEIR compartment-flow diagrams) as Pending/low priority — the chapter's
  prose + real executable R code already make both mechanisms concrete.
- **Track 2**: logged new candidate T24 (§22.6 two-panel epidemic-curve
  plot, baseline vs intervention, from the SEIR worked example) as
  Pending — Dr Aswath to supply. No `TODO-IMAGE` marker inserted since
  §22.6's worked arithmetic and report-table stand alone without it.

## "How to report this" table check (per the mandatory step 11c)
One `report-table` (§22.6's final TB screening-programme result table,
`<tab-ch22-tbscreen-result>` — a genuine computed result from the
chapter's own `deSolve::ode()` worked example) and one `ref-table`
(§22.5's model-choice comparison, `<tab-ch22-modelcompare>` — correctly
NOT labelled report-table since it organizes/compares existing model
families rather than reporting a result the chapter's code just computed).

## Shiny app candidate scan (per the mandatory step 11f)
Two genuine candidates logged in `progress/shiny_app_candidates.md`:
M/M/1 Queue Utilisation Explorer (§22.2, sliders for arrival/service rate
showing the non-linear wait-time blow-up as utilisation approaches 1) and
SEIR Epidemic Curve and Herd-Effect Explorer (§22.4/22.6, sliders for R0/
sigma/ve re-running the compartmental model live, showing the non-linear
relationship between intervention effectiveness and final epidemic size).
Updated the file's total count (40->42) and coverage line (1-21 -> 1-22).

## Jev rubric scores (raw, 1-10 scale)
**First pass**: coverage 8.31, technical_correctness 6.86, code_validity
6.81, agency_grounding 4.87 (FAILED), internal_consistency 8.33.
**Readability (prose-only method), first pass**: 7.15/10 (PASSED —
first draft, no revision needed on readability).
Did one revision pass targeting agency_grounding only: added the
Karnon et al. (2012) Task Force-4 agency-note to §22.1 and the Siebert
et al. (2012) Task Force-3 cross-reference agency-note to §22.5 (see
above). **Re-score**: coverage 8.44, technical_correctness 6.91,
code_validity 6.82, agency_grounding 7.3 (PASSED), internal_consistency
8.35. All six dimensions now clear the 6/10 threshold. No further
revision needed.

## Open items / things later chapters should not contradict
- Chapter 23 (Budget Impact Analysis) picks up where this chapter left
  off structurally: §22.4's cost/QALY accounting for infections averted
  is the last new model-output-to-economics link before the book moves
  from clinical/epidemiological model structures (Ch.17-22) into
  budget-impact and distributional methods (Ch.23-24).
- `simmer`'s verified real functions (`simmer()`, `trajectory()`,
  `seize()`/`release()`, `timeout()`, `add_resource()`, `add_generator()`,
  `run()`, `get_mon_arrivals()`, `get_mon_resources()`, `branch()`,
  `set_attribute()`, `get_attribute()`) and `deSolve::ode()` are now
  book-wide references — any later chapter reusing DES/ODE machinery
  should verify NEW signatures with the same live-lookup discipline
  rather than assuming continuity.
- `EpiModel`'s `dcm()`/`icm()`/`netsim()`/`netest()` are introduced with
  an explicit version-sensitivity hedge — do not treat the argument names
  shown here as a guaranteed-stable signature in a later chapter without
  re-verifying against whatever `EpiModel` version is actually in use.
- The toy SIR numbers (R0=2, N=10,000: peak day 45, 15.3% peak
  infectious, 79.7% final attack rate) and the TB SEIR worked-example
  numbers (§22.6: 4,979 vs 873 cumulative infections per 100,000 at
  10 years, 4,106 averted, 82.5% reduction, peak 1,417 vs 153, net
  budget impact -$5.60M) are now book-wide reference numbers if any
  later chapter revisits this exact compartmental structure — they were
  independently re-verified by running the code, not just asserted.
- Three ISPOR-SMDM Task Force reports (3, 4, 5) are now established,
  citable book-wide references for model-structure-choice questions —
  Chapter 23+ should check whether one of these is the more specific/
  appropriate citation before reaching for a different or more generic
  reference when discussing model-structure selection.
