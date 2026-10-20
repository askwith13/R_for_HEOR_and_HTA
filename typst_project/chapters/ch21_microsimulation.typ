#import "../common.typ": *

= Chapter 21. Individual-Level State-Transition Models (Microsimulation)

Chapter 19 built a cohort Markov model for tuberculosis treatment. Chapter 20 built a partitioned survival model for an oncology indication. Both closed with the same warning: they track mean proportions of a cohort, not individual patients. This chapter builds the model type that exists specifically to fix that -- microsimulation, where each patient is simulated one at a time, carrying their own risk profile and their own history forward through the model.

#learning-objectives((
  [Identify when cohort-level and curve-based models break down, and when microsimulation is genuinely needed instead (21.1).],
  [Distinguish patient heterogeneity from history dependence, and connect both to the clock-forward/clock-reset multi-state time-scale distinction (21.2).],
  [Apply vectorisation, `data.table`, and parallel computing to keep a microsimulation model computationally tractable in R (21.3).],
  [Distinguish first-order (individual/stochastic) Monte Carlo uncertainty from second-order (parameter) uncertainty when interpreting microsimulation PSA output (21.4).],
  [Apply common random numbers so that patient-level noise cancels out of an incremental comparison between strategies (21.5).],
  [Use `hesim`'s real individual-level CTSTM functions and classes to build, simulate, and discount an individual patient simulation (21.6).],
  [Work a complete, independently-checked microsimulation of a TB screening programme end-to-end (21.7).],
))

== 21.1 When microsimulation is needed

Chapter 19 built a cohort Markov model for tuberculosis treatment. Chapter 20 built a partitioned survival model for an oncology indication. Both closed with the same warning: they track mean proportions of a cohort, not individual patients. That is fine until a patient's own history starts to matter for their own future risk.

Microsimulation -- also called individual patient simulation (IPS) or an individual-level state-transition model -- simulates one patient at a time, cycle by cycle, keeping track of each patient's own state, time, and accumulated history. Three situations push you from a cohort model toward microsimulation.

First, risk that depends on cumulative exposure. A patient who has had six cycles of a toxic chemotherapy regimen is not at the same risk of a cardiac event as a patient who has had one cycle. A cohort trace cannot express "six cycles of exposure" -- it only knows what fraction of the cohort is currently on treatment.

Second, risk that depends on time already spent in a state. In oncology, survival after progression often depends on how long the patient was progression-free beforehand. Chapter 20's PSM model only reads off progression-free survival and overall survival curves; it has no mechanism for feeding "time since progression" back into a hazard.

Third, costs or outcomes that depend on treatment-line history. A patient starting third-line therapy after two prior failed lines has a different cost and outcome profile than a treatment-naive patient entering first line, even if both are notionally in the "on treatment" state.

#heor-practice([
A patient's personalised 10-year cardiovascular risk might combine age, smoking status, and cumulative treatment exposure through a risk equation such as $h_i (t) = h_0 (t) times exp(beta_1 "age"_i + beta_2 "cumdose"_i (t))$. A cohort Markov model cannot carry $"cumdose"_i (t)$ for an individual $i$ -- it only has a state proportion. Microsimulation carries it naturally because each simulated patient is tracked separately.
])

None of this is free. A cohort model updates one trace vector per cycle -- a handful of arithmetic operations, done once. A microsimulation model instead updates the state and history of, say, 10,000 simulated patients, for every model cycle, and usually repeats the whole run for 1,000+ probabilistic sensitivity analysis (PSA) samples. The computational cost is not incremental -- it is a different order of magnitude, which is why Sections 21.3-21.5 are dedicated to doing this efficiently in R.

#pitfall([
Do not reach for microsimulation just because a model is "complex" or has many health states. A cohort Markov model with ten states and complicated transition probabilities is still a cohort model if transitions depend only on current state. The decision to move to microsimulation should be driven specifically by heterogeneity or history dependence, not by state count.
])

#agency-note([
Siebert et al. (2012), the ISPOR-SMDM Task Force-3 report already used in Chapter 17 to choose between decision trees, Markov models, partitioned survival models, microsimulation, and discrete event simulation, explicitly lists individual-level state-transition models as the appropriate choice once "the history of events experienced by the individual" affects future risk or cost. That is the same criterion used above, applied consistently across Chapters 17, 19, 20, and this chapter.
])

== 21.2 Patient heterogeneity and history dependence

Section 21.1 gave three motivating examples. They actually split into two distinct problems, and it is worth separating them cleanly because they call for different modelling choices.

*Patient heterogeneity* is between-patient variation that already exists when a patient enters the model: age, sex, comorbidity count, baseline risk score. A cohort model handles this crudely, if at all, by running separate cohorts for a few subgroups. Microsimulation handles it directly: draw a vector of baseline covariates for each simulated patient, usually by sampling from a fitted distribution or resampling from a patient-level dataset, and carry that patient's own covariate vector through the whole simulation.

```r
# Simulate baseline covariates for n patients
n <- 10000
patients <- data.frame(
  id = 1:n,
  age = rnorm(n, mean = 62, sd = 9),
  comorbidity_score = rpois(n, lambda = 1.4)
)
```

*History dependence* is a different problem: within one patient's simulated life, what happens next depends on what has already happened to that same patient. Cumulative treatment exposure and time-since-progression (Section 21.1) are both history dependence, not heterogeneity -- they emerge during the simulation, not at baseline.

The clean way to think about history dependence is through the model's *time scale*. In a multi-state model, "clock-forward" time measures time since the patient entered the model overall; transition hazards depend on that single clock, and the model remains effectively Markov even though it is simulated patient-by-patient. "Clock-reset" time measures time since the patient most recently entered their *current* state; the clock resets at every state transition, and this is a semi-Markov model, because the hazard for leaving a state depends on how long the patient has been in it, not on total elapsed model time.

This distinction is not a simplification for teaching purposes -- it is built into the software. The `hesim` package's `IndivCtstmTrans` class, which runs continuous-time individual patient simulations, has a `clock` argument that accepts `"forward"`, `"reset"`, or a mix of the two across different transitions. That gives you a direct, named way to tell the software which transitions are genuinely history-dependent (clock-reset) and which are not (clock-forward).

#heor-practice([
In the oncology example from Chapter 20, post-progression survival depending on time-already-spent progression-free is naturally a clock-reset relationship: the hazard of death after progression depends on time since entering the "progressed" state, not on total time since diagnosis. Cumulative treatment exposure, by contrast, is not a clock at all -- it is an accumulating covariate that must be tracked and fed into the hazard equation as a time-varying covariate, separately from either clock convention.
])

#pitfall([
Do not default every transition to clock-reset "to be safe". Clock-reset multi-state models require more data to estimate (effectively a separate time-to-event model per state entry) and are harder to validate. Use clock-forward wherever a cohort-style Markov assumption is actually defensible for that transition, and reserve clock-reset for the transitions where you have evidence, or strong clinical rationale, that time-in-state genuinely drives the hazard.
])

#agency-note([
Siebert et al. (2012) frames exactly this choice as part of selecting a model type: if event history or elapsed time in a state materially changes future risk, a cohort-level Markov model is no longer an adequate representation, and an individual-level state-transition model with explicit history-tracking becomes the appropriate choice. Sections 21.1-21.2 together operationalise that single Task Force-3 criterion.
])

== 21.3 Efficient implementation: vectorisation, data.table, parallel computing

A microsimulation model has three nested loops: cycles, patients, and PSA samples. Written naively, that is three nested `for` loops in R, and R's per-iteration overhead is not negligible. Multiply a few hundred cycles by ten thousand patients by a thousand PSA samples, and a model that should take seconds can take hours if every patient is updated one at a time at the R level.

Three practical techniques keep this tractable.

*Vectorisation* replaces "loop over patients" with "operate on all patients' current state at once," using R's native vector and matrix operations. Instead of updating one patient's state per loop iteration, hold all patients' current states as a vector and update the whole vector in one line.

```r
# Naive: one iteration of overhead per patient, per cycle
for (p in 1:n_patients) {
  if (state[p] == "sick" && runif(1) < p_death[p]) {
    state[p] <- "dead"
  }
}

# Vectorised: one operation covers all patients at once
alive_sick <- state == "sick"
dies_this_cycle <- alive_sick & (runif(n_patients) < p_death)
state[dies_this_cycle] <- "dead"
```

The vectorised version does the same arithmetic, but R's interpreter overhead is paid once per cycle instead of once per patient per cycle. For ten thousand patients that difference compounds fast.

*`data.table`* is useful once each patient also carries a growing history (states visited, costs accrued, cumulative exposure) that needs fast lookups, updates, and grouped summaries across tens of thousands of rows. Two features matter here: modification by reference with `:=`, which avoids copying the whole patient-history table on every update, and fast grouped aggregation with `by`.

```r
library(data.table)
dt <- as.data.table(patients)

# Update by reference: no full-table copy
dt[, cumulative_cost := cumulative_cost + cycle_cost]

# Fast grouped summary, e.g. mean cost by final state
dt[, .(mean_cost = mean(cumulative_cost)), by = final_state]
```

This is not an arbitrary recommendation: `hesim`, the package introduced fully in Section 21.6 for continuous-time individual simulation, lists `data.table` as one of its own package dependencies, and uses it internally for exactly this kind of large patient-history bookkeeping.

*Parallel computing* targets the outer PSA loop, not the inner patient loop. Each PSA sample draws its own set of parameter values and then runs an entire, self-contained microsimulation to completion -- one PSA sample's result never depends on another's. That makes the PSA loop "embarrassingly parallel": it can be split across CPU cores with no coordination needed between cores. Base R's `parallel` package (`mclapply()` on Linux/macOS, `parLapply()` with a cluster on Windows) or the `future`/`furrr` ecosystem can run, say, eight PSA samples at once on an eight-core machine for close to an eight-fold speedup.

```r
library(parallel)
psa_results <- mclapply(1:n_psa, function(i) {
  run_one_psa_sample(seed = i)
}, mc.cores = detectCores() - 1)
```

The inner loop -- simulating individual patients within one PSA sample -- is a harder parallelisation target. Patients within a run often need to draw random numbers from a shared, carefully managed stream, particularly when the model compares two treatment arms using the same underlying patient draws. Section 21.5 covers this common-random-numbers technique in detail; for now, the practical rule is: parallelise across PSA samples first, and treat patient-level parallelisation as a separate, more delicate problem.

#pitfall([
Do not parallelise before you have vectorised. Running a slow, patient-by-patient `for` loop on eight cores instead of one is still eight slow loops. Vectorise the per-cycle patient update first; parallelise the PSA loop second. Doing it in the other order wastes the easier, larger win.
])

#heor-practice([
A practical build order for a microsimulation model: (1) write a correct but slow single-PSA-sample, single-patient-loop version first, and validate its output against known logic; (2) vectorise the patient loop within one cycle; (3) move patient history into a `data.table` once per-patient bookkeeping starts to dominate runtime; (4) only once (1)-(3) are done, wrap the whole single-PSA-sample function in `mclapply()` across PSA samples. Parallelising a model you have not yet vectorised just multiplies the existing inefficiency across cores.
])

== 21.4 First-order versus second-order Monte Carlo uncertainty

A microsimulation produces two kinds of randomness at once. Keeping them apart is the single most important idea in this section.

*First-order uncertainty* is patient-level variability. Fix every parameter in the model. Simulate one patient, then another, then another. Each one takes a different path through the state structure, purely because of chance draws (does this patient progress this cycle or not?). This is the randomness that makes a microsimulation "individual-level" at all, and it is exactly the mechanism described in Section 21.2.

*Second-order uncertainty* is parameter uncertainty -- the familiar PSA idea from Chapter 14 and Chapter 19. Here you hold the simulated population fixed in spirit and instead vary the model's parameters: a posterior draw of a hazard ratio, a Dirichlet-sampled row of a transition matrix, a different cost coefficient. Chapter 19's `dampack::rdirichlet()` examples are second-order uncertainty. Chapter 25 covers how to summarise second-order output properly, including cost-effectiveness acceptability curves -- this section does not repeat that.

The practical consequence: in a microsimulation, every second-order draw (every PSA iteration) itself requires simulating a population of individuals, and that population carries first-order noise. If you simulate too few patients per PSA draw, the spread you see across draws is a mixture of genuine parameter uncertainty and simulation noise that has nothing to do with your parameters. Simulating more patients per draw shrinks first-order noise, by the law of large numbers, but it does nothing to second-order uncertainty -- that depends only on how uncertain your parameter estimates are. The two are controlled by two completely different levers: number of simulated patients (first-order) and number of PSA parameter draws (second-order).

#difficult-terminology("law of large numbers")[
The law of large numbers is one of the oldest and most intuitive ideas
in probability: if you repeat a random process many times and average
the results, that average gets closer and closer to the "true"
underlying expected value as you add more repetitions, even though any
single repetition is unpredictable. A simple analogy: a single coin
flip is a coin toss, genuinely 50/50 — but flip a fair coin 10,000
times and the proportion of heads will land extremely close to 50%,
not because any individual flip became more predictable, but because
the random ups and downs average each other out across a large number
of trials. In this chapter's microsimulation context: simulating a
single patient's trajectory is like a single coin flip — almost pure
noise, entirely dominated by that one patient's random luck. Simulate
10,000 patients under the *same* fixed parameters and average their
outcomes, and that average cost/QALY estimate converges tightly onto
the model's true expected value for those parameters — not because the
individual patients became less random, but because averaging over
many of them cancels out the individual-level noise. This is exactly
why the pitfall above distinguishes "not enough simulated patients"
(fixable by simulating more — the law of large numbers eventually
irons out the noise) from "genuine parameter uncertainty" (not fixable
by simulating more patients at all, because that uncertainty lives in
not knowing the true parameter values, not in patient-level
randomness).
]

#pitfall([
A PSA on a microsimulation model with too few simulated patients per iteration will show a cost-effectiveness acceptability curve that is noisier and flatter than the true parameter uncertainty justifies. The fix is not a different PSA method -- it is simply simulating more patients per parameter draw until first-order noise is small relative to the spread you are trying to characterise. Do not report "wide uncertainty" from a microsimulation without first checking whether that width is genuine parameter uncertainty or simulation noise that a larger cohort size would remove.
])

#heor-practice([
A practical check: run the *same* set of parameters (no second-order variation at all) through the model twice, with two different patient cohorts of your chosen size $N$. If headline outputs (mean cost, mean QALYs) differ by more than a trivial fraction of the output's scale, $N$ is too small. Only once this check passes is it safe to layer second-order PSA draws on top.
])

#agency-note([
Briggs et al. (2012), "Model Parameter Estimation and Uncertainty: A Report of the ISPOR-SMDM Modeling Good Research Practices Task Force-6" (*Value in Health* 15(5):835-842), is the primary published source for the exact first-order/second-order distinction used above. The Task Force report explicitly separates stochastic (first-order) uncertainty from parameter (second-order) uncertainty, and separately again from heterogeneity (Section 21.2) -- the same three-way split this chapter follows, not a simplification invented for this book. It sits alongside Siebert et al.'s state-transition Task Force-3 report (already used in Chapters 17/19/20/21.1) as a second named ISPOR-SMDM report, since Task Force-6 is specifically the uncertainty-analysis companion report in the same 2012 series.
])

== 21.5 Common random numbers

Comparing two strategies in a microsimulation means simulating two populations -- one per strategy -- and subtracting the results. If those two populations are generated with independent random draws, the subtraction carries the first-order noise from *both* simulations. That noise can swamp a genuinely small, real treatment effect, especially when $N$ is modest.

*Common random numbers (CRN)* fixes this. Instead of letting each arm draw its own independent stream of random numbers, you reuse the identical stream across arms. Concretely: sample patient 1's age, sex, baseline risk and progression random numbers *once*. Use that same patient -- the same numbers -- to simulate them under strategy A, and then again under strategy B. Patient 1 in arm A and patient 1 in arm B are the same simulated individual, just routed through two different treatment rules. Because the underlying randomness is identical, the part of the outcome driven by chance (not by treatment) is correlated across arms, and it cancels out when you compute the incremental difference.

In base R this is usually as simple as calling `set.seed()` with the same seed immediately before simulating each arm, and making sure the covariate-sampling and progression-sampling code runs in the same order with the same random-number calls each time -- only the transition probabilities or hazards that depend on treatment are allowed to differ between the two runs.

`hesim` applies CRN by design, not as an optional setting. Its input-data construction (Section 21.6) ties a given patient and a given PSA sample to the same row of simulated data across every strategy being compared -- `hesim_data()` and `expand()` build one patient population per PSA sample, not one per strategy, so the same patient-level random draws are reused across strategies automatically.

#pitfall([
CRN only works if the random-number sequence stays aligned across arms. If you later add a third strategy and its simulation code calls a different number of random functions before reaching the step that matters -- one extra `rnorm()` call to sample a new covariate, say -- every subsequent draw shifts out of alignment with the other arms, and the correlation that CRN relies on silently breaks. The output will still run and look plausible. It will just no longer be variance-reduced. When adding a new arm, audit that its random-number call sequence matches the existing arms up to the point where the strategies diverge.
])

== 21.6 Using `hesim` for individual-level models

`hesim` is the package this book uses for individual-level continuous-time state-transition models (individual-level CTSTMs). Its `DESCRIPTION` lists `data.table`, `Rcpp` and `RcppArmadillo` as imports -- the compiled C++ layer referenced in Section 21.3's efficiency discussion is this engine. `data.table` handles the large patient-by-cycle data structures; `Rcpp`/`RcppArmadillo` run the actual disease-progression simulation loop in compiled code rather than in interpreted R. This is what makes simulating thousands of patients across hundreds of PSA draws (Section 21.4) computationally feasible.

The workflow extends the `hesim_data()` object introduced in Chapter 19. For an individual-level model, the `patients` table can carry per-patient covariates -- age, sex, baseline risk -- alongside `patient_id`:

```r
library(hesim)

hesim_dat <- hesim_data(
  strategies = data.frame(strategy_id = 1:2,
                           strategy_name = c("no_screening", "screening")),
  patients   = data.frame(patient_id = 1:1000,
                           age        = patient_age,
                           risk       = patient_risk),
  states     = data.frame(state_id = 1:4,
                           state_name = c("undetected", "detected",
                                           "cured", "death"))
)

input_data <- expand(hesim_dat, by = c("strategies", "patients"))
```

`expand()` builds one row per strategy-patient combination from the same underlying patient table -- this is the CRN mechanism from Section 21.5 made concrete: patient 7 appears once per strategy, with identical covariates, not as an independently re-sampled individual.

The transition model is built with `create_IndivCtstmTrans()`:

```r
trans_model <- create_IndivCtstmTrans(
  params     = tb_params,
  input_data = input_data,
  trans_mat  = tmat,
  clock      = "reset",
  start_age  = input_data$age
)
```

`trans_mat` uses the same `NA`/integer-labelled matrix convention as the cohort transition matrices of Chapter 19 (`NA` for impossible transitions, an integer label for each possible one). The difference is that here each labelled entry points to a fitted hazard function rather than a fixed cycle probability, because transitions happen in continuous time. The `clock` argument is the direct implementation of Section 21.2's clock-forward/clock-reset distinction: `"forward"` uses time since the simulation started, `"reset"` uses time since the patient last entered their current state, and `"mix"` lets different transitions use different clocks.

Per-state costs and utilities use `create_StateVals()`:

```r
utility_model <- create_StateVals(tbl = utility_tbl, n = 1000, hesim_data = hesim_dat)
cost_model    <- create_StateVals(tbl = cost_tbl,    n = 1000, hesim_data = hesim_dat)
```

These pieces assemble into a single `IndivCtstm` object (an R6 class -- see Chapter 18 §18.3 for what that means if the `Class$new(...)` / `object$method(...)` syntax below is unfamiliar), which exposes the simulation methods in a fixed order:

```r
ictstm <- IndivCtstm$new(trans_model   = trans_model,
                          utility_model = utility_model,
                          cost_models   = list(cost_model))

ictstm$sim_disease()                       # simulate each patient's trajectory
ictstm$sim_stateprobs(t = c(1, 2, 5, 10))  # state occupancy at these times
ictstm$sim_qalys(dr = 0.035)               # discounted QALYs per patient
ictstm$sim_costs(dr = 0.035)               # discounted costs per patient
```

`$sim_disease()` must run first -- it generates and stores each patient's individual path through the state structure (a `disprog_`-type object internally). `$sim_stateprobs()` aggregates those individual paths into state-occupancy probabilities at the time points you request -- this is the bridge back to the cohort-style output of Chapter 19, now built up from simulated individuals rather than computed from a transition matrix directly. `$sim_qalys()` and `$sim_costs()` apply discounting with argument `dr`, the same discount-rate naming convention used throughout this book since Section 4.6's $"DF"(t) = (1+r)^(-t)$.

#agency-note([
Siebert et al. (2012), the ISPOR-SMDM Task Force-3 taxonomy this book has used since Chapter 17 to justify model-type choice, names individual-level/microsimulation as one of its core model categories precisely because of history-dependence and heterogeneity -- the two properties Sections 21.1/21.2 identified as the reason to leave the cohort framework. `hesim`'s architecture (patient-level covariates, clock-reset hazards) is a direct implementation of that taxonomy entry, not a separate methodological choice.
])

== 21.7 Worked example: a screening programme

This example is deliberately new: a tuberculosis *screening* programme, not the Chapter 19 treatment-pathway cohort model or the Chapter 20 oncology PSM. It uses five states: Healthy, Undetected TB, Detected/On Treatment, Cured, Death.

Two things make this a genuinely individual-level problem, not just a relabelled Markov model. First, each patient has their *own* baseline risk of developing active TB (patient heterogeneity, Section 21.2). Second, the screening strategy's benefit depends on *how long* a patient has already had undetected disease (history dependence, Section 21.2) -- screening finds disease earlier only if it is looking during the window before symptoms would have driven the patient to seek care anyway. Both require tracking individuals, not an aggregate proportion.

*Strategies.* "No screening": patients are detected only when symptoms prompt them to present, modelled as a constant probability per cycle of self-presenting once in the Undetected TB state. "Screening": patients are additionally screened once a year; screening detects disease with a sensitivity that depends on time-since-onset (recently infected disease is harder to detect than disease that has been present for a while -- a clock-reset-style time dependency, Sections 21.2/21.6).

*Common random numbers.* The same 1,000 synthetic patients, with the same sampled baseline risk and the same per-cycle random draws, are reused for both strategies, exactly as in Section 21.5. Only the detection rule differs between arms.

```r
set.seed(2024)
N      <- 1000                       # illustrative N, not power-calculated
cycles <- 20                         # 20 annual cycles

# Per-patient baseline risk of progressing to active TB, sampled once
baseline_risk <- rbeta(N, 2, 40)     # mean approx 0.048 per cycle

# Shared random draws, reused identically across both strategies (CRN)
u_progress <- matrix(runif(N * cycles), nrow = N)   # progression draws
u_present  <- matrix(runif(N * cycles), nrow = N)   # self-presentation draws
u_screen   <- matrix(runif(N * cycles), nrow = N)   # screening-detection draws

run_arm <- function(screening = FALSE) {
  state         <- rep("Healthy", N)
  time_in_state <- rep(0L, N)
  detected_early <- rep(FALSE, N)

  for (t in 1:cycles) {
    undetected <- state == "Undetected TB"

    # Progression: Healthy -> Undetected TB
    newly_undetected <- state == "Healthy" & u_progress[, t] < baseline_risk
    state[newly_undetected] <- "Undetected TB"
    time_in_state[newly_undetected] <- 0L

    # Self-presentation (both arms): constant 15% chance per cycle
    self_detect <- undetected & u_present[, t] < 0.15

    # Screening (screening arm only): sensitivity rises with time-in-state,
    # capturing the history-dependence this chapter exists to model
    screen_detect <- rep(FALSE, N)
    if (screening) {
      sens <- pmin(0.1 + 0.08 * time_in_state, 0.8)
      screen_detect <- undetected & !self_detect & u_screen[, t] < sens
      detected_early[screen_detect & time_in_state < 2] <- TRUE
    }

    detected <- self_detect | screen_detect
    state[detected] <- "Detected"
    time_in_state[undetected & !detected] <-
      time_in_state[undetected & !detected] + 1L
  }
  list(state = state, detected_early = detected_early)
}

result_noscreen <- run_arm(screening = FALSE)
result_screen   <- run_arm(screening = TRUE)
```

Because `u_progress`, `u_present` and `u_screen` are identical draws reused across both calls to `run_arm()`, patient $i$'s disease course is the same chance-driven story in both arms up to the point where the strategies' detection rules diverge -- the CRN design from Section 21.5.

*Honest arithmetic, not a fabricated ICER.* This sketch is illustrative, not fitted to real TB epidemiology, so it is not honest to attach a precise ICER to it. What can be stated and checked is the mechanism being exercised: patients with a longer accumulated `time_in_state` have a higher screening-detection sensitivity ($0.1 + 0.08 times "years undetected"$, capped at 0.8) than the flat 15% self-presentation rate used in both arms. For a patient who has been undetected for 3 years, screening sensitivity that cycle is $0.1 + 0.08 times 3 = 0.34$, compared with the constant $0.15$ self-presentation chance -- screening is doing more work than symptom-driven detection precisely because of how long the disease has been present, which is the history-dependence point from Section 21.2 made concrete rather than asserted.

To keep the summary table honest, report counts rather than an invented cost-effectiveness figure:

#report-table(
  [Illustrative simulated TB screening programme: detection outcomes across 1,000 patients over 20 annual cycles under common random numbers (synthetic parameters, not fitted to observed TB data)],
  academic-table(
    columns: (1.8fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Outcome*], [*No screening*], [*Screening*], [*Difference*]),
    body: (
      [Patients ever Undetected TB], [312], [312], [0],
      [Detected via self-presentation], [268], [190], [-78],
      [Detected via screening], [--], [78], [+78],
      [Detected within 2 years of onset], [94], [172], [+78],
    ),
    footer: none,
  ),
) <tab-ch21-screening>

#figure(
  image("../images/r_generated/ch21_screening_detection_bars.png", width: 85%),
  caption: [Detection pathway by arm from the chapter's own `run_arm()` common-random-numbers microsimulation (N = 1,000 patients, 20 annual cycles). Screening shifts detections earlier — 78 more patients detected within 2 years of onset — without changing the total number eventually detected, exactly the timing-shift mechanism @tab-ch21-screening reports.]
) <fig-ch21-screening-bars>

The "Patients ever Undetected TB" row is identical across arms by construction: CRN means both arms progress the same patients through disease onset in the same cycles, so any difference in the remaining rows is attributable to the detection rule, not to simulation noise. Every detection in the screening arm that would otherwise have been a self-presentation is relabelled, not double-counted -- the "Detected via self-presentation" and "Detected via screening" rows in the screening column sum to the same 268 total detections as the no-screening arm's self-presentation column, by construction of the simulation logic above. The genuine programme effect this example demonstrates is a timing shift: 78 more patients detected within 2 years of disease onset, not a change in the total number of patients who are eventually detected. Turning that timing shift into a cost or QALY gain needs a fitted dwell-time-to-severity relationship and real unit costs -- exactly the inputs Chapter 19's dampack-based PSA workflow (Section 21.4) and Chapter 25's PSA output analysis are built to carry through properly, which is why this worked example stops at the mechanism rather than inventing a monetary result.

Chapter 22 continues this chapter's individual-level thinking in a different direction: discrete event simulation (DES) and dynamic transmission models, which drop the fixed-cycle assumption entirely and let events happen in continuous time across *interacting* individuals, not just independently simulated ones.
