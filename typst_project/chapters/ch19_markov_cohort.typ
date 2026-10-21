#import "../common.typ": *

= Chapter 19. Markov Cohort Models

Chapter 18 built the simplest decision-analytic engine -- the tree -- and closed with its §18.5 handoff pattern: a tree's terminal-leaf path probabilities seed the time-0 cohort distribution of a longer-term model. This chapter builds that longer-term model. Chapter 17's §17.2 model-type framework resolved the book's running TB example -- a choice between a 4-month rifapentine-moxifloxacin regimen (Study 31/A5349) and the 6-month standard daily regimen (2HRZE/4HR) -- to a *Markov cohort model*, diagrammed in §17.3's `DiagrammeR::grViz()` example with four states: On Treatment, Cured, Treatment Failure, Death. This chapter turns that diagram into a runnable, cost-and-QALY-producing model, first by hand in base R, then via the dedicated CRAN packages built for exactly this job.

#learning-objectives((
  [Define a Markov state, transition probability and cycle, and compute a cohort trace by the roll-forward matrix-multiplication method, verifying that every transition-matrix row sums to 1 (19.1).],
  [Distinguish time-homogeneous from time-dependent transition matrices and explain why many real clinical transitions are not homogeneous (19.2).],
  [Implement a complete cohort Markov trace in base R using nothing but a matrix and a loop, and read off state occupancy at any cycle (19.3).],
  [Use `heemod`'s `define_transition()`/`define_state()`/`define_strategy()`/`run_model()` pipeline, `hesim`'s data-scaffold architecture, and `dampack::calculate_icers()` for post-processing, with verified real function signatures (19.4).],
  [Apply discounting and half-cycle correction to a cycle-by-cycle cost/QALY trace, and connect both to Chapter 4's discounting treatment and to `heemod`'s `method = "life-table"` option (19.5).],
  [Explain what a tunnel state is, why it is needed when a transition probability depends on time-since-state-entry, and how `heemod`'s `state_time` variable automates it (19.6).],
  [Combine age-dependent background mortality with disease-specific mortality without double-counting, using `heemod`'s `model_time` variable (19.7).],
  [Explain why whole transition-matrix rows need Dirichlet-distributed PSA draws rather than independent Betas per cell, and when a Cholesky decomposition is needed instead (19.8).],
  [Distinguish calibration from validation and identify where each belongs in the modelling workflow, forward-pointing to Chapter 27 (19.9).],
  [Work a complete, independently-verified chronic-disease cost-effectiveness analysis end-to-end, from transition matrix to ICER (19.10).],
))

== 19.1 States, transitions and cycles

Chapter 17 resolved the regimen-choice question -- 4-month rifapentine-moxifloxacin (Study 31/A5349) versus the 6-month standard daily regimen (2HRZE/4HR) -- into a *Markov cohort model* built on four *states*: On Treatment, Cured, Treatment Failure, and Death. This section turns that diagram (§17.3's `grViz()` structure) into numbers.

#shiny-app-box("markov_cohort_trace_builder", [Drag each outbound transition probability and watch the 20-cycle state-occupancy trace redraw live, showing how small changes compound over many cycles.])

A *Markov state* is a mutually exclusive, collectively exhaustive health/treatment status a patient can occupy at any point in the model. A *transition probability* is the chance of moving from one state to another over one *cycle* -- a fixed unit of model time (here, six months, matching the typical duration of intensive-phase decision-making in TB care). The defining simplification is the *Markov assumption* (memorylessness): the probability of each future transition depends only on the *current* state, never on how a patient got there or how long they have been in it. A patient who has failed treatment once and been re-treated is, under this assumption, statistically indistinguishable from one on their first course -- clearly a simplification for TB, where prior-failure patients often carry resistant organisms and worse prognosis. Chapter 21's microsimulation relaxes exactly this restriction by tracking individual patient history; we flag the limitation here and defer the fix.

Using the four states and the back-edge from Chapter 17 (Fail -> OnTx, re-treatment; Death reachable from every state), here are illustrative per-six-month-cycle transition probabilities. These are invented for pedagogical purposes and are *not* a clinical claim -- a real model would source them from the Study 31 and standard-of-care trial arms, or from WHO TB outcome cohorts.

From *On Treatment*: cured $p=0.75$, fail $p=0.08$, die $p=0.02$, remain on treatment $p = 1 - 0.75 - 0.08 - 0.02 = 0.15$.

From *Treatment Failure*: re-enter treatment $p=0.60$, die $p=0.15$, remain in failure $p = 1 - 0.60 - 0.15 = 0.25$.

From *Cured*: Cured is not absorbing -- cured patients still face ordinary background mortality, here taken as $p=0.01$ per cycle, so remain cured $p=0.99$.

From *Death*: absorbing, $p("Death" -> "Death") = 1$, all other entries zero.

#pitfall[
A transition matrix row that does not sum exactly to 1 is one of the most common and most dangerous Markov-model bugs: probability mass silently leaks out of (or is fabricated into) the cohort every cycle, and the error compounds invisibly over dozens of cycles before anyone notices the totals look odd. The usual cause is a copy-paste edit to one cell without re-deriving the complementary "stay" probability. *Always* verify row sums as an explicit step, not an assumption -- §19.3's code does this with `rowSums()` before running a single cycle. A second common variant: forgetting that *Death* must be absolutely absorbing. If a modeller later edits the Death row to add, say, a spurious resurrection probability (sometimes from sloppy sensitivity-analysis scripting that perturbs every cell including diagonal absorbing ones), the cohort's death count can decrease over time -- a biologically impossible and easily caught red flag if you plot cumulative deaths and see it dip.
]

Worked check, On Treatment row: $0.15 + 0.75 + 0.08 + 0.02 = 1.00$ checkmark.

#agency-note[
Siebert et al. (2012), "State-Transition Modeling: A Report of the ISPOR-SMDM Modeling Good Research Practices Task Force-3," already cited in Chapter 17, is the standard methodological reference for everything in this chapter: state definition, cycle length choice, half-cycle correction, and when a Markov model is adequate versus when individual-level simulation (their Task Force companion papers) is required. Re-consult it directly when justifying structural choices in a real submission.
]

== 19.2 Time-homogeneous and time-dependent transition matrices

The matrix in §19.1 is *time-homogeneous*: the same four probabilities apply in cycle 1, cycle 10, and cycle 20, regardless of how long the cohort has been running or how old a given patient is. This is the simplest and most common starting assumption, and it is exactly what the plain matrix-multiplication approach in §19.3 encodes.

Many real TB and chronic-disease transitions are *not* homogeneous. Treatment-failure risk in TB is classically *front-loaded*: most failures and early deaths occur in the first few months of a treatment course, with the hazard tapering as patients who tolerate therapy and respond clear their bacterial burden. A single fixed $p("OnTx" -> "Fail")$ averaged over the whole treatment course will overstate late-cycle risk and understate early-cycle risk -- potentially biasing a cost-effectiveness comparison between a short four-month regimen and a long six-month one, since the *timing* of failure within the course matters for how much cost and QALY loss is already "banked" by the time it happens.

A *time-dependent* (non-homogeneous) matrix instead makes one or more transition probabilities a function of the cycle index $t$ (time since model start, or more precisely time since entering the current state) -- for example a declining hazard for $p_("OnTx" -> "Fail")(t)$, or a background-mortality cell that rises with cohort age as $t$ increases. Implementing this in base R just means indexing into a *list* of matrices (one per cycle, or one per age band) rather than reusing a single matrix in the loop -- mechanically trivial, but it requires the probabilities to be *derived* from a hazard function or an age-specific life table rather than assumed constant. A tunnel-state device (covered in §19.6) is often used precisely to let risk vary with *time since entering* a state even inside an otherwise time-homogeneous framework, and age-dependent background mortality is picked up again in §19.7.

== 19.3 Building a Markov model in base R (matrix-based approach)

The cleanest way to understand a cohort Markov model is to write it with nothing but a matrix and a loop. Base R needs no special package for this; `expm::"%^%"` (matrix power) is a convenient but entirely optional shortcut for jumping straight to cycle $n$ without looping.

```r
# Four states, in a fixed order used throughout the chapter
state_names <- c("OnTx", "Cured", "Fail", "Death")

# Transition matrix: rows = "from", columns = "to"
P <- matrix(
  c(0.15, 0.75, 0.08, 0.02,   # from OnTx
    0.00, 0.99, 0.00, 0.01,   # from Cured
    0.60, 0.00, 0.25, 0.15,   # from Fail
    0.00, 0.00, 0.00, 1.00),  # from Death (absorbing)
  nrow = 4, byrow = TRUE,
  dimnames = list(state_names, state_names)
)

# Defensive check: every row must sum to exactly 1
stopifnot(all(abs(rowSums(P) - 1) < 1e-9))

# Initial state-occupancy vector: whole cohort starts On Treatment
init <- c(OnTx = 1, Cured = 0, Fail = 0, Death = 0)

n_cycles <- 20  # 20 six-month cycles = 10 years

# Trace matrix: rows = cycles 0..n_cycles, columns = states
trace <- matrix(NA_real_, nrow = n_cycles + 1, ncol = 4,
                 dimnames = list(0:n_cycles, state_names))
trace[1, ] <- init

for (t in seq_len(n_cycles)) {
  trace[t + 1, ] <- trace[t, ] %*% P
}

round(trace[c(1, 6, 11, 21), ], 4)  # cycles 0, 5, 10, 20
```

Running this loop (independently re-verified during assembly) gives the occupancy trace below. The cohort initially pours out of On Treatment, most of it settling into Cured, a small residual fraction cycling through Fail (which keeps feeding a trickle back into OnTx and onward into Death), and Death's share climbing monotonically, as it must for an absorbing state.

#report-table(
  [State occupancy from the base-R cohort trace, cycles 0, 5, 10, 20 (proportion of starting cohort)],
  academic-table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    header: ([*Cycle*], [*On Treatment*], [*Cured*], [*Treatment Failure*], [*Death*]),
    body: (
      [0],  [1.0000], [0.0000], [0.0000], [0.0000],
      [5],  [0.0054], [0.9130], [0.0025], [0.0791],
      [10], [0.0001], [0.8750], [0.0000], [0.1249],
      [20], [0.0000], [0.7914], [0.0000], [0.2086],
    ),
    footer: none,
  )
) <tab-ch19-trace>

By cycle 20 (10 years), almost 21% of the original cohort has died (from TB or background causes) and the remainder has essentially settled in Cured, since Fail and On Treatment occupancy decays toward zero -- the expected long-run behaviour of a model with one absorbing state and no permanent non-absorbing "parking" state. This trace is the raw ingredient §19.5 will multiply by state costs and utilities, cycle by cycle, to get discounted costs and QALYs.

#figure(
  image("../images/r_generated/ch19_markov_trace.png", width: 85%),
  caption: [Full 20-cycle state-occupancy trace from the base-R cohort loop above, stacked by state. Mass drains rapidly out of On Treatment in the first 1-2 cycles, with most of it settling into Cured (the large green band) and a small residual passing through Treatment Failure before being re-absorbed; Death's share (grey) climbs monotonically across all 20 cycles, as it must for an absorbing state.],
) <fig-ch19-trace>

== 19.4 Using heemod, hesim and dampack

Writing the loop by hand in §19.3 is instructive, but production HEOR models are rarely hand-rolled this way -- bookkeeping for costs, utilities, discounting, half-cycle correction, strategy comparison, and probabilistic sensitivity analysis (PSA) quickly gets unwieldy. Three CRAN packages cover this ground at increasing levels of sophistication: `heemod`, `hesim`, and `dampack`.

`heemod` implements cohort Markov models with the same matrix-and-states logic as §19.3, but wrapped in a declarative syntax. `heemod::define_transition()` builds the matrix from named cell expressions, row by row, and crucially supports the keyword `C` to mean "fill in whatever makes this row sum to 1" -- exactly the complementary "remainder" probability computed by hand in §19.1. `heemod::define_state()` attaches a per-cycle `cost=` and `utility=` to one state. `heemod::define_strategy()` combines one transition object with one state object per state (named arguments matching the state names). `heemod::run_model()` takes one or more strategies plus `parameters = define_parameters()`, an `init=` occupancy vector, the number of `cycles=`, a `method=` argument (`"life-table"`, `"beginning"`, or `"end"`) controlling how half-cycle correction is applied -- revisited in §19.5 -- and `cost=`/`effect=` expressions naming which state variables to accumulate.

A simplified 2-state rebuild (On Treatment / Resolved, collapsing Cured+Death for brevity) illustrates the pattern:

```r
library(heemod)

tm <- define_transition(
  state_names = c("OnTx", "Resolved"),
  C,    0.85,   # from OnTx: fill-in remainder, then 0.85 to Resolved
  0,    C       # from Resolved: 0 back to OnTx, remainder (1) stays
)

s_ontx <- define_state(cost = 500, utility = 0.65)
s_resolved <- define_state(cost = 50, utility = 0.90)

strat <- define_strategy(
  transition = tm,
  OnTx = s_ontx,
  Resolved = s_resolved
)

res <- run_model(
  strat,
  parameters = define_parameters(),
  init = c(1, 0),
  cycles = 20,
  method = "life-table",
  cost = cost,
  effect = utility
)
```

Here `C` in the first row fills in $1 - 0.85 = 0.15$ (stay On Treatment); `C` in the second row fills in $1 - 0 = 1$ (stay Resolved), making it absorbing -- the same arithmetic discipline as §19.1, now delegated to the package.

`hesim` takes a different, more modular architecture built for larger, heterogeneous-cohort or patient-level problems. `hesim::hesim_data(strategies=, patients=, states=)` builds a data scaffold describing every strategy/patient/state combination up front, rather than one fixed matrix. `define_tparams()` builds transformed-parameter expressions that reference a `tpmatrix()` (a tidy, long-format transition-probability matrix, often with one row per PSA draw), and `create_CohortDtstm()` instantiates a cohort discrete-time state-transition model from those pieces. Sketch only -- hesim's real power (patient heterogeneity and built-in PSA) gets the fuller treatment in Chapter 25:

```r
# Illustrative sketch only -- architecture, not a complete runnable model
hesim_dat <- hesim_data(
  strategies = data.frame(strategy_id = 1:2),
  patients   = data.frame(patient_id = 1:100),
  states     = data.frame(state_id = 1:3, state_name = c("OnTx", "Cured", "Fail"))
)
tp_params <- define_tparams({
  list(tpmatrix = tpmatrix(...))   # references draws/covariates
})
cohort_model <- create_CohortDtstm(define_model(tparams_def = tp_params), hesim_dat)
```

Choose `hesim` over `heemod` when you need patient subgroups, covariate-varying transition probabilities, or PSA machinery built into the object model from the start, rather than bolted on afterward.

Once any of these produces per-strategy cost and effect totals, `dampack`'s `calculate_icers(cost=, effect=, strategies=)` is the standard post-processing step: it takes vectors of total discounted cost and effect (one value per strategy) and returns a dominance-aware ICER table -- flagging strategies that are *dominated* (more costly, less effective than an alternative) or *extendedly dominated*, and computing incremental cost-effectiveness ratios only along the efficient frontier. Its companion PSA/VOI tooling (`run_psa()`, `owsa()` one-way sensitivity analysis, `ceac()` cost-effectiveness acceptability curves) is deferred to Chapters 25-26, where probabilistic analysis of exactly this TB model is built out properly.

== 19.5 Applying costs and QALYs, discounting and half-cycle correction

Occupancy traces are not yet a cost-effectiveness result: each cycle's state occupancy must be multiplied by that state's per-cycle cost and utility, summed across states and cycles, and *discounted* -- future costs and health effects are worth less than present ones, as Chapter 4 §4.6 already established for simple decision-tree-style calculations. The same discount factor applies here, just compounded cycle by cycle rather than year by year: $"DF"(t) = (1+r)^(-t)$ where $r$ is the *per-cycle* discount rate and $t$ is the cycle index. NICE's reference case specifies $r = 3.5%$ per annum for *both* costs and health effects (NICE, "Guide to the methods of technology appraisal"); converting to a six-month cycle rate uses $(1.035)^(0.5) - 1 approx 0.01735$, i.e. about 1.735% per half-year cycle, consistent with Chapter 4's compounding logic.

#shiny-app-box("discounting_half_cycle_correction_comparator", [Drag the discount rate and toggle beginning/end/half-cycle correction and watch total discounted QALYs/costs recompute live.])

*Half-cycle correction* addresses a subtler bias: the raw trace assumes the whole cohort occupies each state for the *entire* cycle, as if transitions happen only at cycle boundaries, when in reality patients move between states at varying points within a cycle. The standard fix -- the *trapezoidal* or *life-table* method -- approximates each cycle's contribution as the *average* of the occupancy at the start and at the end of the cycle, rather than using the end-of-cycle (or start-of-cycle) value alone for the whole interval. This is precisely what `heemod::run_model()`'s `method = "life-table"` default (introduced in §19.4) computes under the hood: it is the real-software implementation of the same trapezoidal averaging, as opposed to `method = "beginning"` or `"end"`, which deliberately omit the correction and bias results in opposite directions.

Worked numeric example: suppose a cohort accrues QALYs of 0.40, 0.42, 0.43, 0.44, 0.45 in cycles 1 through 5 (ignore half-cycle correction here for clarity, to isolate the discounting arithmetic), at NICE's per-cycle rate $r approx 0.01735$. Discounting cycle $t$'s QALYs by $(1+r)^(-t)$:

#report-table(
  [Discounting a 5-cycle QALY stream at NICE's 3.5% annual rate (1.735% per 6-month cycle)],
  academic-table(
    columns: (auto, auto, auto, auto),
    align: (right, right, right, right),
    header: ([*Cycle* $t$], [*Undiscounted QALYs*], [*Discount factor* $(1+r)^(-t)$], [*Discounted QALYs*]),
    body: (
      [1], [0.40], [0.9829], [0.3932],
      [2], [0.42], [0.9662], [0.4058],
      [3], [0.43], [0.9497], [0.4084],
      [4], [0.44], [0.9335], [0.4107],
      [5], [0.45], [0.9176], [0.4129],
    ),
    footer: ([*Total*: undiscounted 2.1400, discounted 2.0310],),
  )
) <tab-ch19-discount>

Total undiscounted QALYs across the five cycles: $0.40+0.42+0.43+0.44+0.45 = 2.14$. Total discounted QALYs: 2.031 (summing the last column) -- a reduction of about 5.1%, consistent with a modest discount rate applied over a short 2.5-year horizon; the gap widens substantially over the full 10-year, 20-cycle horizon used in §19.3.

The next section, §19.6, extends this same trace-and-discount machinery to *tunnel states* -- the device that lets a formally time-homogeneous Markov model mimic the time-dependent, front-loaded risks flagged in §19.2.

== 19.6 Tunnel states and state residence time

Section 19.5 showed how discounting and half-cycle correction convert a cycle-by-cycle Markov trace into a defensible present-value estimate of cost and QALYs. Both techniques assume the trace itself is trustworthy -- but that trust rests on *memorylessness*: the assumption from §19.1 that a transition probability depends only on which state a patient currently occupies, not on how long they have been there. That assumption is frequently false, and this section shows the standard workaround.

#shiny-app-box("tunnel_state_risk_shape_explorer", [Drag failure-risk sliders for each tunnel sub-state and watch flat vs. front-loaded occupancy traces diverge live.])

Consider the *On Treatment* state in our running TB model. A patient who has just started the 6-month standard regimen (2HRZE/4HR) and one who is in their fifth month on the same regimen are both coded as "On Treatment" in a simple 4-state model, yet their risk of *Treatment Failure* is not plausibly identical -- early non-response and late relapse-on-treatment have different biological drivers, and clinically we would expect the failure hazard to shift across the course of treatment rather than stay flat. A model that applies a single $p("OnTx" -> "Fail") = 0.08$ per 6-month cycle regardless of time-since-entry is implicitly averaging over this heterogeneity, which can bias cost and QALY estimates when the state-entry mix differs between the two arms being compared (as it typically does when one arm shortens treatment duration, exactly our Study 31/A5349 comparison).

The fix is the *tunnel state*: instead of one "On Treatment" state, define a short chain of sub-states that a cohort passes through in strict sequence -- `OnTx_cycle1`, `OnTx_cycle2`, `OnTx_cycle3`, ... -- each carrying its own row of outbound transition probabilities. A patient entering treatment always starts at `OnTx_cycle1`; from there they can only move to `Cured`, `Fail`, `Death`, or forward into `OnTx_cycle2` (never back into `OnTx_cycle1`, and never skip ahead). This restores memorylessness *within* each tunnel sub-state while still letting the aggregate "on treatment" risk profile vary smoothly across state-time. Tunnel states are not a hack bolted onto the Markov formalism -- they are the textbook general-purpose device for representing any non-exponential (non-memoryless) sojourn-time effect inside a cohort Markov model, at the cost of a larger but still linear state space.

#figure(
  image("../images/conceptual/ch19_tunnel_state_expansion.png", width: 100%),
  caption: [Tunnel-state expansion: the single time-homogeneous "On Treatment" state (bottom) versus its expansion into a chain of `OnTx_cycle1`, `OnTx_cycle2`, `OnTx_cycle3`, ... sub-states (top), each with its own outbound transition probabilities to Cured/Fail/Death.],
) <fig-ch19-tunnel-state-expansion>

Hand-building tunnel states is mechanical but tedious: every tunnel sub-state needs its own column of parameters, and with several time-varying quantities (failure risk, state cost, state utility) the bookkeeping grows quickly. `heemod` removes this burden with its `state_time` variable. Inside `define_transition()` or `define_state()`, any expression that references `state_time` is automatically recognised as state-time-dependent, and `heemod` expands the relevant state into the necessary tunnel states behind the scenes when the strategy is run -- the modeller writes one expression, not N hand-coded sub-states. This is a real, documented `heemod` feature, not an approximation layered on top of the package; the mechanics described above are exactly what `state_time` is implementing under the hood.

```r
library(heemod)

# Illustrative: failure risk declining with cycles spent on treatment
f_fail_by_state_time <- function(state_time) {
  dplyr::case_when(
    state_time <= 1 ~ 0.12,   # cycle 1 on treatment: higher early-failure risk
    state_time == 2 ~ 0.08,   # cycle 2: matches the base-case §19.1-19.5 value
    state_time >= 3 ~ 0.04    # cycle 3+: lower residual risk
  )
}

tm_tunnel <- define_transition(
  state_names = c("OnTx", "Cured", "Fail", "Death"),
  C,    0.75,  state_time,  0.02,
  0,    1,     0,           0,
  0.60, 0,     C,           0.15,
  0,    0,     0,           1
)
```

#pitfall[
A common implementation error is tracking *cycles since model start* rather than *cycles since entry into the state*. These coincide only for patients who never leave and re-enter a state -- but our Markov structure explicitly has a `Fail -> OnTx` back-edge: a patient who fails and re-enters treatment restarts their own on-treatment clock, even though the overall model clock keeps advancing. A tunnel implementation (hand-built or via `heemod`'s `state_time`) must reset the counter at every (re-)entry event, not read it off the global cycle index, or failure/relapse patients will be assigned the wrong column of the tunnel -- silently understating their early-tunnel risk on a second course of treatment.
]

== 19.7 Age-dependent transitions and background mortality

Tunnel states handle risks that vary with time *since entering a state*. A separate and equally common violation of memorylessness is risk that varies with the patient's *age* or with *calendar time* in the model overall -- most importantly, *background mortality*: the risk of dying from causes unrelated to TB, which rises steeply and non-linearly with age regardless of treatment arm.

A model that applies a single, constant $p(-> "Death")$ in every state ignores this entirely, which is defensible only for a short time horizon or a narrow, homogeneous-age cohort. For a lifetime horizon -- or any model where disease-specific mortality is modest relative to all-cause mortality in an ageing cohort -- background mortality must be pulled in explicitly, typically from a national or WHO life table giving age- and sex-specific annual mortality probabilities. Chapter 10's treatment of survival analysis and extrapolation covers how such life tables are sourced and used to extrapolate beyond trial follow-up; this section is concerned only with how they combine with disease-specific risk *inside* the transition matrix.

The practical problem is double-counting: if a cycle's disease-specific death transition (e.g. *Treatment Failure* -> *Death*, $p = 0.15$ per cycle in our base case) and the age-matched background mortality probability are simply added, patients who would have died of TB-related causes *and* who were also at background risk get counted twice, inflating total mortality unrealistically. Two standard approaches avoid this:

- *Additive-hazard approach*: convert both probabilities to instantaneous hazards (rate $= -ln(1 - p) \/ "cycle length"$), sum the hazards, then convert the combined hazard back to a cycle probability. This is the theoretically cleaner approach because hazards (unlike probabilities) are additive by construction.
- *Maximum-of-two-probabilities approach*: take $p("Death")$ for the cycle as $max(p_"disease-specific", p_"background")$, on the reasoning that a patient cannot die twice and the dominant risk should drive the outcome. This is simpler to implement but is a cruder approximation, particularly when both probabilities are of comparable, non-trivial magnitude.

NICE DSU guidance -- the same Technical Support Document series already relied on for structural and survival-extrapolation choices earlier in this book -- recommends the hazard-based combination as the more defensible default, reserving the max-probability shortcut for cases where background mortality is negligible next to disease-specific risk (which is *not* generally true for an ageing TB cohort followed over a long horizon).

`heemod` supports age- and calendar-time-dependent parameters through its `model_time` variable, which is conceptually distinct from the `state_time` variable introduced in §19.6: `state_time` counts cycles since entry into the *current* state, while `model_time` counts cycles since the *start of the model run* (and, combined with a starting age, maps directly onto life-table age bands).

```r
library(heemod)

# Illustrative life-table lookup keyed on model_time (age = start_age + model_time)
background_mortality <- function(model_time, start_age = 45) {
  age <- start_age + model_time
  dplyr::case_when(
    age < 50 ~ 0.01,
    age < 65 ~ 0.03,
    TRUE     ~ 0.08
  )
}

# Combine via additive hazards, cycle length = 0.5 years (6-month cycles)
p_combined_death <- function(p_disease, model_time) {
  h_disease <- -log(1 - p_disease)
  h_bg      <- -log(1 - background_mortality(model_time))
  1 - exp(-(h_disease + h_bg))
}
```

== 19.8 Probabilistic transition matrices (Dirichlet) and Cholesky decomposition

Chapter 25 covers the general conventions for choosing PSA distributions for different parameter types (probabilities, costs, utilities, relative-effect estimates). Transition probabilities raise a structural wrinkle that deserves attention here, specific to the Markov setting: every row of a transition matrix must sum to exactly 1, so the cells within a row are not independent. Sampling each cell of a row from its own independent Beta distribution during a probabilistic sensitivity analysis will, in general, produce a row that no longer sums to 1 -- silently breaking the Markov model's core algebraic constraint.

The natural fix is the *Dirichlet distribution*, the multivariate generalisation of the Beta that is specifically defined over vectors whose entries sum to 1. Just as a $"Beta"(a, b)$ distribution is the conjugate posterior for a binomial proportion given $a$ and $b$ "pseudo-counts" of success and failure, a $"Dirichlet"(alpha_1, ..., alpha_k)$ distribution is the conjugate posterior for a whole row of a multinomial transition, given a vector of pseudo-counts $alpha_1, ..., alpha_k$ -- one count per destination state. Concretely, if you have (or can construct) a count matrix recording how many patients observed to start a cycle in state $i$ were observed to end it in state $j$ -- `hesim`'s own documentation illustrates this with its count-matrix worked examples for exactly this purpose -- each row of that count matrix directly parameterises a Dirichlet distribution for the corresponding row of the transition matrix, and every draw from it automatically sums to 1.

`dampack` exports a ready-to-use `rdirichlet()` function for this: given a row of counts, it returns PSA draws for that row that respect the sum-to-1 constraint by construction.

#difficult-terminology("conjugate posterior")[
In Bayesian statistics, you start with a *prior* distribution
(your belief about a parameter before seeing data), combine it with
observed data, and end up with a *posterior* distribution (your
updated belief after seeing the data). In general, that combination
step requires heavy computation — simulation methods like MCMC, as
used elsewhere in this book. A "conjugate" prior is a special, lucky
case where the prior and the data-generating distribution are
mathematically matched so that the posterior comes out in the *same
family* as the prior, with a simple formula instead of simulation.
Concretely: if your prior for a success probability is a $"Beta"(a, b)$
distribution (think of $a$ and $b$ as "pretend" prior counts of past
successes and failures), and you then observe real data of $s$
successes and $f$ failures, the posterior is just another Beta
distribution — $"Beta"(a + s, b + f)$ — you simply add your observed
counts onto the prior's pretend counts. No simulation, no numerical
approximation, just arithmetic. That is exactly why Beta pairs so
neatly with binomial (yes/no) data, and why its multivariate cousin,
Dirichlet, pairs the same way with multinomial (more-than-two-outcome)
data: both are conjugate to the kind of data a Markov transition
matrix naturally produces, which is what makes `rdirichlet()`'s
pseudo-count trick above work with a one-line function call rather
than a full Bayesian model fit.
]

```r
library(dampack)

# Illustrative counts underlying the OnTx row: Cured / Fail / Death / OnTx (stay)
# (e.g. out of 100 patients starting a cycle On Treatment: 75 cured, 8 failed, 2 died,
#  with the remainder continuing on treatment -- counts need not match cycle fractions
#  exactly, they encode the *evidence strength* behind each cell)
alpha_ontx <- c(Cured = 75, Fail = 8, Death = 2, OnTx = 15)

psa_draws_ontx <- dampack::rdirichlet(n = 1000, alpha = alpha_ontx)
# each row of psa_draws_ontx sums to 1 by construction -- no post-hoc renormalisation needed
```

A related but conceptually separate problem arises for *correlated* normal- or lognormal-distributed parameters -- for instance, if the relative treatment effect on *Cure* and the relative treatment effect on *Failure* are not independent (clinically plausible, since both are downstream of the same underlying treatment-response process), sampling them from independent univariate distributions during PSA throws away that correlation and can understate or overstate joint uncertainty. The standard device for preserving a specified correlation structure is the *Cholesky decomposition* of the correlation (or covariance) matrix: factorising it as $Sigma = L L^T$ lets you transform a vector of independent standard normal draws into a vector of correlated normal draws via $x_"correlated" = mu + L z$. In base R this is a single call to `chol()`; `heemod`'s own PSA machinery uses the `mvnfast` package internally for exactly this multivariate-normal sampling step (`mvnfast` is listed as a real `Suggests` dependency in `heemod`'s own CRAN `DESCRIPTION`). The full mechanics of building and validating a PSA correlation structure belong to Chapter 25 -- the point to carry forward here is narrower: whole transition-matrix rows need a Dirichlet, correlated continuous parameters need a Cholesky-based multivariate normal, and conflating the two (e.g. trying to "correlate" Dirichlet-sampled rows with a Cholesky step meant for normals) produces draws that no longer have a coherent probabilistic interpretation.

== 19.9 Calibration and validation

*Calibration* and *validation* are often used loosely as synonyms in casual modelling talk, but they answer different questions and belong at different points in the workflow.

*Calibration* is the process of adjusting one or more uncertain, unobserved (or poorly observed) model parameters so that the model's *outputs* match some external target. In our TB model, the transition probability from *Treatment Failure* back into *Death* (as opposed to re-entering *On Treatment*) might be informed only weakly by trial data, while a registry reports a well-measured 5-year all-cause survival curve for patients who ever failed first-line treatment. Calibration would search over plausible values of that transition probability until the model's own predicted 5-year survival curve for the Fail-exposed cohort matches the registry curve as closely as possible. Calibration therefore uses *outputs* to pin down uncertain *inputs* -- it runs in the opposite direction from a normal forward model evaluation.

*Validation*, by contrast, asks whether the model (with its parameters already set, calibrated or not) is *correct and credible* for its intended purpose, assessed from several distinct angles:

- *Face validity* -- does a domain expert agree the structure, assumptions and parameter directions are clinically sensible, before looking hard at the numbers?
- *Internal (verification) validity* -- does the model behave correctly at known boundary or extreme-value conditions (e.g. do state occupancies still sum to 1 every cycle, does setting a transition probability to 0 or 1 produce the expected degenerate trace, does cost scale linearly when a unit cost is doubled)?
- *Cross-validation* -- do the model's results broadly agree with other independently published models addressing the same decision problem, and if not, can the discrepancy be traced to an identifiable structural or parameter difference?
- *External validation* -- do the model's *predictions* (e.g. projected 5-year outcomes) hold up against real-world data collected after the model was built, the strongest and least commonly achievable form of validation.

Both calibration and validation checks belong at a specific point in the modelling workflow: *after* the base-case `run_model()` call produces a working, internally consistent trace and economic summary, and *before* any probabilistic sensitivity analysis is run on top of it. Running PSA over a miscalibrated or unvalidated base case simply propagates the error through every draw at greater computational cost, without fixing anything.

This chapter deliberately does not work through the calibration *methods* themselves -- random search, Nelder-Mead and other optimisation routines, Bayesian calibration, Approximate Bayesian Computation (ABC), and Incremental Mixture Importance Sampling (IMIS) are all real, established calibration techniques, and Chapter 27 (Model Calibration, Validation and Quality Assurance) is where they are covered in full. Chapter 27 is likewise where the formal validation *frameworks* referenced across HEOR practice -- AdViSHE (Assessment of the Validation Status of Health-Economic decision models), the ISPOR-SMDM Modeling Good Research Practices Task Force validation recommendations, and the TECH-VER checklist -- are introduced and applied in detail. The job of this section is only to mark where, in the sequence from §19.1's model structure through this chapter's extensions, that checking must happen.

#agency-note[
The ISPOR-SMDM Modeling Good Research Practices Task Force's model transparency and validation recommendations -- already referenced earlier in this book for general modelling conduct -- explicitly separate verification ("did we build the model right?") from validation ("did we build the right model?"). Keep that distinction sharp in any model documentation submitted to a HTA body: reviewers expect to see both addressed, and conflating the two in a single paragraph is a common and avoidable source of clarification requests during technical review.
]

== 19.10 Worked example: a chronic-disease CEA

To consolidate §19.1-19.9 end-to-end, this section works a complete cost-effectiveness analysis on a deliberately different, simpler example -- a chronic, non-infectious condition -- so the mechanics stand on their own rather than being read as a continuation of the TB numbers used throughout the chapter.

#shiny-app-box("soc_vs_dmt_icer_dashboard", [Drag each arm's transition probabilities, state costs and utilities and watch the full 10-year discounted ICER and CE-plane point update live.])

*Setting*: a 3-state model -- *Well*, *Diseased*, *Dead* -- comparing a new disease-modifying therapy (DMT) against standard care (SoC) for a chronic progressive condition, over 20 six-month cycles (10 years), with a 3% annual discount rate applied to both costs and QALYs and half-cycle correction applied throughout (per §19.5's convention). All patients start *Well*. The transition matrices below are illustrative, not drawn from any specific published trial, and are constructed so DMT reduces the probability of progressing from *Well* to *Diseased* and of dying while *Diseased*, at a higher per-cycle treatment cost.

#ref-table(
  [Illustrative per-6-month-cycle transition probabilities, by arm],
  academic-table(
    columns: (1.6fr, auto, auto, auto),
    align: (left, center, center, left),
    header: ([*Transition*], [*SoC*], [*DMT*], [*Note*]),
    body: (
      [Well $->$ Well], [0.80], [0.85], [DMT slows progression],
      [Well $->$ Diseased], [0.15], [0.10], [],
      [Well $->$ Dead], [0.05], [0.05], [background + baseline risk, held equal],
      [Diseased $->$ Diseased], [0.85], [0.90], [DMT also slows decline once diseased],
      [Diseased $->$ Dead], [0.15], [0.10], [],
      [Dead $->$ Dead], [1.00], [1.00], [absorbing],
    ),
    footer: (table.cell(colspan: 4)[Each row sums to 1.00 in both arms, confirmed by direct summation.],),
  )
)

*State values*: a six-month cost of \$500 (Well) / \$8,000 (Diseased) under SoC, rising to \$3,500 (Well, reflecting the DMT's own acquisition cost) / \$11,000 (Diseased, DMT plus any added monitoring) under the new therapy; six-month utility weights of 0.90 (Well) and 0.60 (Diseased), assumed equal across arms (the DMT is assumed to slow progression, not to change the intrinsic health-state utilities conditional on being in a state).

```r
# Base-R cohort trace with half-cycle-corrected discounting, following §19.5's pattern
run_chronic_model <- function(tm, cost_vec, util_vec, cycles = 20, r = 0.03) {
  trace <- matrix(0, nrow = cycles + 1, ncol = 3)
  trace[1, ] <- c(1, 0, 0)                 # start: 100% Well
  for (t in 2:(cycles + 1)) {
    trace[t, ] <- trace[t - 1, ] %*% tm
  }
  total_cost <- 0; total_qaly <- 0
  for (t in 1:cycles) {
    avg_occ <- (trace[t, ] + trace[t + 1, ]) / 2   # half-cycle correction
    disc <- 1 / (1 + r)^t
    total_cost <- total_cost + sum(avg_occ * cost_vec) * disc
    total_qaly <- total_qaly + sum(avg_occ * util_vec) * disc
  }
  list(trace = trace, cost = total_cost, qaly = total_qaly)
}

tm_soc <- matrix(c(0.80, 0.15, 0.05,
                    0.00, 0.85, 0.15,
                    0.00, 0.00, 1.00), nrow = 3, byrow = TRUE)
tm_dmt <- matrix(c(0.85, 0.10, 0.05,
                    0.00, 0.90, 0.10,
                    0.00, 0.00, 1.00), nrow = 3, byrow = TRUE)

res_soc <- run_chronic_model(tm_soc, c(500, 8000, 0), c(0.90, 0.60, 0))
res_dmt <- run_chronic_model(tm_dmt, c(3500, 11000, 0), c(0.90, 0.60, 0))
```

Running this trace (independently re-verified during assembly) gives discounted 10-year totals of \$29,317.05 in cost and 5.5522 QALYs under SoC, and \$56,917.97 in cost and 6.6704 QALYs under DMT. The resulting incremental cost is $56917.97 - 29317.05 = 27600.92$, and the incremental QALY gain is $6.6704 - 5.5522 = 1.1181$, giving an ICER of $27600.92 \/ 1.1181 = 24685$ per QALY gained -- below a conventional \$30,000-\$50,000 willingness-to-pay threshold, so DMT would be judged cost-effective against SoC at that threshold under this illustrative parameterisation.

#report-table(
  [Chronic-disease CEA: discounted 10-year results, SoC vs DMT],
  academic-table(
    columns: (1.4fr, auto, auto, auto, auto, auto),
    align: (left, right, right, right, right, right),
    header: ([*Arm*], [*Cost*], [*QALYs*], [*Incr. Cost*], [*Incr. QALYs*], [*ICER*]),
    body: (
      [Standard care (SoC)], [29,317.05], [5.5522], [--], [--], [--],
      [Disease-modifying therapy (DMT)], [56,917.97], [6.6704], [27,600.92], [1.1181], [24,685],
    ),
    footer: (table.cell(colspan: 6)[3% annual discounting; half-cycle correction applied; 20 six-month cycles (10-year horizon). ICER = incremental cost / incremental QALYs = 27,600.92 / 1.1181.],),
  )
) <tab-ch19-cea>

This worked example closes the chapter's treatment of cohort Markov models: states, transitions and cycles (§19.1), time-homogeneous and time-dependent matrices (§19.2-19.3), implementation in base R and in `heemod`/`hesim`/`dampack` (§19.4), discounting and half-cycle correction (§19.5), tunnel states for time-since-entry effects (§19.6), age- and calendar-time-dependent transitions (§19.7), Dirichlet- and Cholesky-based uncertainty propagation (§19.8), and where calibration and validation sit in the workflow (§19.9) all feed directly into the cost and QALY totals computed here. Not every decision problem is well served by a hand-specified transition matrix, however: per the structural-choice framework set out in Chapter 17 (§17.2), when an outcome is driven directly by extrapolated survival curves fitted in Chapter 10 -- rather than by a small number of clinically interpretable health states and transitions -- a *partitioned survival model* is usually the more natural and more transparent structural choice. Chapter 20 takes up partitioned survival models next.
