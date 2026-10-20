#import "../common.typ": *

= Chapter 27. Model Calibration, Validation and Quality Assurance

#learning-objectives((
  [Calibrate an unobserved model parameter against an external target using random search and Nelder-Mead optimisation, and describe when Bayesian calibration, Approximate Bayesian Computation (ABC), or Incremental Mixture Importance Sampling (IMIS) are preferable.],
  [Cross-validate a model's structure against held-out data, distinguishing a structural problem from a miscalibrated parameter.],
  [Write `testthat` unit tests, extreme-value tests, and a replication check to verify that a model's code does what it is intended to do.],
  [Describe the AdViSHE validation framework's domains and locate ISPOR-SMDM's own validation guidance.],
  [Apply code review, pull-request workflows, and independent "black-box" replication as organisational practices that support model credibility.],
  [Distinguish face validity, internal validity, cross-validation, and external (predictive) validity, and compute a simple external-validity comparison.],
))

== 27.1 Calibration methods: random search, Nelder-Mead, Bayesian calibration, ABC, IMIS

Every Markov cohort model built so far in this book -- the 4-state TB model from Chapter 19, with its PSA in Chapter 25 and VOI analysis in Chapter 26 -- has relied on transition probabilities drawn from published trial data or expert elicitation. In practice, at least one transition is rarely observed directly. Suppose the probability of moving from "On-treatment-failed" to "Cured" without ever being recorded as such in the trial (a silent spontaneous resolution) is not reported anywhere in the literature. We cannot look this number up; we must infer it by _calibration_: finding the parameter value (or set of values) that makes the model's predicted outputs match a known real-world target.

#difficult-terminology("calibration target")[
  A calibration target is an external, independently-measured outcome that the model should be able to reproduce if its hidden parameters are set correctly -- for example, a national registry's reported 5-year all-cause mortality rate among TB patients, or a published cure rate from a large cohort study. Think of it like fitting a key to a lock: the lock (the real-world target) is fixed and known; the calibration process tries different keys (parameter values) until the model's output matches the target closely enough. The target itself should come from a different data source than whatever was used to build the rest of the model, or the exercise merely confirms the model reproduces its own inputs.
]

For our worked example, suppose a published TB cohort registry reports a 5-year all-cause mortality rate of 32% among patients on standard-of-care treatment. Our Chapter 19 model has an unknown parameter -- call it `p_hidden`, the annual probability of silent transition from "On-treatment-failed" to "Cured" -- that is not well identified by trial data alone. We calibrate `p_hidden` so that the model's predicted 5-year mortality under SoC matches the registry's 32% target.

=== Random search

The simplest calibration approach: draw many candidate values for `p_hidden` from a plausible range, run the model for each, and keep the value (or values) that give the closest match to the target. No gradient, no clever search -- just brute-force sampling.

```r
set.seed(123)
n_draws <- 500
p_hidden_candidates <- runif(n_draws, min = 0.01, max = 0.30)

run_model_mortality <- function(p_hidden) {
  # run_tb_markov() is the Chapter 19 cohort model, extended to accept
  # the hidden parameter and return 5-year all-cause mortality under SoC
  result <- run_tb_markov(p_hidden = p_hidden, arm = "SoC", horizon_years = 5)
  result$mortality_5yr
}

predicted_mortality <- sapply(p_hidden_candidates, run_model_mortality)
target_mortality <- 0.32

# squared-error distance from target
sq_error <- (predicted_mortality - target_mortality)^2
best_idx <- which.min(sq_error)
p_hidden_best_rs <- p_hidden_candidates[best_idx]
```

Random search is easy to parallelize and never gets stuck in a local optimum the way gradient-based methods can, but it is inefficient: with only one free parameter, 500 draws is already overkill, and with five or more unknown parameters the same grid density becomes computationally prohibitive (the number of draws needed to maintain the same coverage grows exponentially with the number of parameters -- the so-called curse of dimensionality).

#pitfall[
  A single calibration target is a weak test. If `p_hidden` is calibrated only to match 5-year mortality, many different combinations of _other_ model parameters could also have been adjusted to hit that same single number -- the calibration is underdetermined, and the chosen value of `p_hidden` could be compensating for an error elsewhere in the model rather than reflecting the true biological transition rate. Where possible, calibrate against _multiple_ independent targets simultaneously (e.g. 5-year mortality _and_ 2-year treatment failure rate) and check that the single calibrated parameter set reproduces all of them adequately -- not just the one you happened to check.
]

=== Nelder-Mead optimization

#difficult-terminology("Nelder-Mead optimization")[
  Nelder-Mead is a numerical search algorithm for finding the input value that minimizes (or maximizes) a function, without needing calculus derivatives. It works by maintaining a small set of trial points (a "simplex" -- for one parameter, just two points; for two parameters, a triangle) and iteratively replacing the worst-performing point with a better one, reflecting, expanding or shrinking the simplex as it goes. An analogy: imagine searching for the lowest point in a foggy valley by feel alone, with a small group of people spread a few paces apart -- the person standing in the worst (highest) spot keeps moving toward where the others are lower, and the group gradually converges on the valley floor. It is slower to converge than gradient-based methods but does not require the function to be differentiable, which matters here because our model output (a result of discrete Markov cycles) is not a smooth analytic function of `p_hidden`.
]

R's base `optim()` function supports Nelder-Mead directly. We define an objective function -- the squared distance between model-predicted and target mortality -- and let `optim()` search for the minimizing `p_hidden`.

```r
objective_fn <- function(p_hidden) {
  # optim() with Nelder-Mead can propose a value outside [0,1]; guard it
  p_hidden <- min(max(p_hidden, 0.001), 0.999)
  predicted <- run_model_mortality(p_hidden)
  (predicted - target_mortality)^2
}

fit <- optim(
  par    = 0.15,              # starting guess for p_hidden
  fn     = objective_fn,
  method = "Nelder-Mead",
  control = list(reltol = 1e-8)
)

p_hidden_calibrated <- fit$par
calibration_sq_error <- fit$value
```

Suppose this converges to `p_hidden_calibrated = 0.084`, with the model then predicting 5-year mortality of 31.7% against the 32.0% target -- a squared error of $(0.317 - 0.320)^2 = 0.0000009$, i.e. an absolute gap of 0.3 percentage points, small enough to accept as a well-calibrated fit.

#report-table(
  [Calibration target vs. model-predicted value, TB Markov model, SoC arm],
  academic-table(
    columns: (auto, auto, auto, auto),
    align: (left, right, right, right),
    header: ([Outcome], [Target (registry)], [Model-predicted (calibrated)], [Absolute gap]),
    body: (
      [5-year all-cause mortality, SoC], [32.0%], [31.7%], [0.3 pp],
    ),
    footer: (table.cell(colspan: 4)[Model-predicted value from `optim()` Nelder-Mead calibration of the hidden transition probability `p_hidden`, starting value 0.15, converged value 0.084. pp = percentage points.],),
  ),
)

#heor-practice[
  Always report the calibrated parameter value _alongside_ a plausibility check against clinical or biological priors -- a calibrated transition probability that falls far outside the range any clinician would consider plausible (e.g. a calibrated value of 0.95 for a transition believed clinically to be rare) is a signal that the model structure, not just the parameter, needs re-examination. Calibration can compensate for a structural problem elsewhere in the model, producing a "well-fitted" but biologically implausible parameter.
]

=== Bayesian calibration

Random search and Nelder-Mead both return a single "best" point estimate for `p_hidden`. Bayesian calibration instead treats `p_hidden` as a random variable with a prior distribution (reflecting what is plausible before seeing the calibration target), and updates that prior using the likelihood of the observed target data to produce a full posterior distribution over `p_hidden`. This posterior naturally captures calibration _uncertainty_ -- which then flows through to wider, more honest uncertainty in the cost-effectiveness results downstream, rather than treating the calibrated value as if it were known with certainty (which plain optimization implicitly does).

Conceptually, a Bayesian calibration workflow for our example would: (1) specify a prior for `p_hidden`, e.g. Beta distributed, centered on a clinically plausible range; (2) define a likelihood function describing how probable the observed registry mortality rate of 32% is, for each candidate value of `p_hidden`, given sampling or measurement uncertainty around that registry estimate; (3) use a Markov Chain Monte Carlo (MCMC) sampler to draw from the resulting posterior distribution over `p_hidden`; and (4) propagate the full posterior -- not just its mean -- through the cost-effectiveness model, in the same spirit as the PSA draws in Chapter 25.

R has packages oriented toward this kind of model calibration (for instance the CRAN package `BayesianTools` provides general-purpose MCMC and sensitivity tools for calibrating arbitrary simulation models against data). We will not reproduce specific function calls from that package here, because getting the exact argument names and defaults wrong would be worse than not showing code at all -- if you adopt this approach, work from the package's own current vignette and documentation rather than from code copied out of a general textbook, since calibration packages' APIs do change across versions.

=== Approximate Bayesian Computation (ABC)

#difficult-terminology("Approximate Bayesian Computation (ABC)")[
  ABC is a family of methods for doing Bayesian-style calibration when the likelihood function -- the mathematical expression for how probable the observed data is, given a parameter value -- is too complicated or expensive to write down explicitly, which is common for simulation models like Markov cohort models run many times over. Instead of computing a likelihood, ABC repeatedly: draws a candidate parameter value from the prior, runs the full simulation model with that value, and checks whether the _simulated_ outcome is close enough to the _observed_ target. Parameter draws that produce simulated outcomes within an acceptable distance of the target are kept; those that do not are rejected. The surviving draws approximate the posterior distribution. An analogy: rather than solving a lock's combination mathematically, you try many physical keys and keep only the ones that turn far enough to feel "close enough" to opening it, without ever formally modeling what "closeness of fit" means in equation form.
]

For our TB model, a basic ABC rejection scheme would look conceptually like the random-search code above, but instead of keeping only the single closest draw, it would keep _all_ draws whose predicted mortality falls within some tolerance (say, plus-or-minus 1 percentage point) of the 32% target, and treat the surviving set of `p_hidden` values as an approximate posterior sample. R has a CRAN package named `EasyABC` oriented toward this kind of rejection and sequential ABC; as with `BayesianTools` above, we deliberately do not reproduce specific function signatures here, since we cannot independently confirm current argument names without risking an inaccurate example -- consult that package's own documentation directly before using it.

=== Incremental Mixture Importance Sampling (IMIS)

IMIS is a more sample-efficient alternative to plain ABC rejection sampling, originally developed in the health-decision-modeling literature specifically for calibrating cohort and dynamic disease models (it has been used, for example, in HIV and tuberculosis policy models). Conceptually, IMIS starts by sampling from the prior, as in ABC, but then iteratively builds a mixture of distributions concentrated around the regions of parameter space that gave the best fit to the target in earlier iterations, progressively focusing the sampling effort rather than searching the whole prior space with equal density throughout. This can reach a usable approximate posterior with far fewer total model runs than naive rejection ABC, which matters when each run of the TB Markov model (or a more complex dynamic transmission model) is computationally expensive. We flag IMIS here as a named method you should know exists and search for by name if a project needs calibration efficiency beyond basic ABC; we do not reproduce a specific R implementation's call signature, for the same reason noted above for `BayesianTools` and `EasyABC`.

#agency-note[
  The ISPOR-SMDM Modeling Good Research Practices Task Force series (published jointly in _Medical Decision Making_ and _Value in Health_, around 2012) includes a task force report specifically on model transparency and validation, which discusses calibration as one dimension of model validation alongside face validity, internal verification, and external validation against independent data. If calibration is central to a model being submitted to a HTA body, cite the relevant task force report by its actual title and year as published -- check the exact citation in your reference manager or the ISPOR website rather than relying on a title reconstructed from memory, since task force numbering and titles across that series are easy to misattribute.
]

== 27.2 Cross-validation of model structure

Calibration (27.1) answers "what parameter value makes this model fit the target?" Cross-validation of model structure asks a different, prior question: "is this the right model structure in the first place?" A model can be beautifully calibrated to match every target perfectly and still have the wrong number of health states, the wrong set of allowed transitions, or an inappropriate cycle length -- calibration can mask structural error by forcing a fit, whereas structural cross-validation tests whether the chosen structure generalizes.

The core technique, borrowed from general statistical modeling, is to split available data into a _training_ portion used to calibrate or fit the model, and a _held-out_ portion used only to check predictions afterward, never touched during fitting. For our TB model, suppose the registry providing the 32% 5-year mortality calibration target actually covers two separate enrollment cohorts: an earlier cohort (used to derive the calibration target in 27.1) and a later, independent cohort for which 3-year (not 5-year) mortality was also reported, at 21%. We can use the later cohort purely as an out-of-sample check: does the model, calibrated only against the first cohort's 5-year figure, also correctly predict the second cohort's 3-year mortality, which it never saw during fitting?

```r
# Model was calibrated only against the 5-year target from cohort 1 (27.1).
# Now check an out-of-sample prediction against cohort 2's independent data,
# which was never used anywhere in the calibration step above.
predicted_3yr_mortality <- run_tb_markov(
  p_hidden     = p_hidden_calibrated,
  arm          = "SoC",
  horizon_years = 3
)$mortality_5yr   # function returns cumulative mortality at the requested horizon

held_out_target <- 0.21
cross_val_gap <- predicted_3yr_mortality - held_out_target
```

If `predicted_3yr_mortality` comes out close to 0.21 (say within 1-2 percentage points), that is reassuring evidence the model's _structure_ -- not just the one calibrated parameter -- captures the underlying disease process reasonably well, because it generalizes to data it never saw. If the gap is large, the problem is not necessarily the calibrated parameter value; it may be that the model is missing a relevant health state, has an unrealistic cycle length, or omits a clinically important transition pathway, and no amount of re-calibrating `p_hidden` within the existing structure will fix a mismatch that is actually structural.

A second, complementary cross-validation approach for structure specifically (rather than data splitting) is to build two or more _competing_ model structures -- for example, a 4-state model (our Chapter 19 structure) versus a 5-state model that separately distinguishes relapse from primary treatment failure -- calibrate each separately against the same training target, and then compare which structure better predicts the held-out target. The structure that generalizes better to unseen data, not merely the structure that fits the training target most closely, is the one with stronger support.

#pitfall[
  Structural cross-validation only works if the held-out data is genuinely independent of whatever was used to build the model's assumptions in the first place. If both the training target and the "held-out" check come from the same registry, use overlapping patients, or were both already known to the model builders when they chose the model's structure (e.g. the number of health states) during Chapter 19's design phase, the held-out check is not really independent and will tend to look falsely reassuring.
]

== 27.3 Verification: unit testing with `testthat`, extreme-value tests, replication

Calibration and structural cross-validation both assume the underlying code correctly implements the intended model. _Verification_ is the separate, more basic question: does the code do what we believe it does, independent of any external calibration target? A model can be perfectly calibrated to a real-world target purely by chance, while still containing a coding error (e.g. a transition-probability matrix whose rows do not sum to 1, silently losing or creating cohort members every cycle). Verification catches this class of error directly, by testing the code's internal logic rather than its external fit.

#difficult-terminology("unit testing")[
  Unit testing means writing small, automated pieces of code whose only job is to check that another specific piece of code behaves as expected, and running those checks automatically every time the underlying code changes. It is analogous to a hospital's routine quality-control check on a diagnostic machine -- rather than trusting that the machine is well-calibrated because it was built correctly once, staff run a known reference sample through it periodically and confirm the reported result matches the known answer; if it does not, the machine is flagged before it is used on real patients. `testthat` is the standard R package for writing these automated checks.
]

=== Unit test: transition matrix row-sums equal 1

Every row of a Markov transition probability matrix must sum to exactly 1, because each row describes the full set of mutually exclusive, exhaustive destinations for a cohort member starting in that state during one cycle -- if a row sums to less than 1, cohort members vanish each cycle; if it sums to more than 1, cohort members are created from nothing. This is the single most common silent bug in hand-built Markov cohort models, and it is trivial to test automatically.

```r
library(testthat)

# tm_soc is the 4x4 transition probability matrix for the SoC arm,
# built in Chapter 19 (rows: Well, Failed, Cured, Dead; same column order)
test_that("SoC transition matrix rows sum to 1", {
  row_sums <- rowSums(tm_soc)
  expect_equal(row_sums, rep(1, nrow(tm_soc)), tolerance = 1e-8)
})

test_that("New-regimen transition matrix rows sum to 1", {
  row_sums <- rowSums(tm_new)
  expect_equal(row_sums, rep(1, nrow(tm_new)), tolerance = 1e-8)
})
```

A `tolerance = 1e-8` argument is deliberate: floating-point arithmetic rarely produces an exact 1.000000000 when probabilities are added, so an overly strict `expect_equal` comparing to exactly 1 with no tolerance would fail on correct code purely due to rounding noise, while a tolerance of 1e-8 is tight enough to catch a genuine row-sum error (e.g. a row summing to 0.95 because a transition was mistakenly omitted) while tolerating harmless floating-point noise far smaller than any clinically meaningful difference.

=== Extreme-value test

An extreme-value test deliberately sets an input parameter to an implausible, extreme boundary value -- not because that value is clinically realistic, but because the model's behavior at the extreme is mathematically predictable, so any deviation from the predicted extreme behavior reveals a coding bug. If we set the "Well-on-treatment" to "Dead" annual mortality probability to exactly 1 (certain death within one cycle for every cohort member in that state), the model should report that essentially zero cohort members survive past the first cycle -- any other output means the cycling logic itself is broken, independent of whether a probability of 1 is remotely realistic for TB mortality.

```r
test_that("certain mortality (p = 1) drives survivors to zero after cycle 1", {
  tm_extreme <- tm_soc
  # Force the Well-on-treatment row to transition to Dead with certainty.
  # Column order: Well, Failed, Cured, Dead
  tm_extreme["Well", ] <- c(0, 0, 0, 1)

  result_extreme <- run_tb_markov_matrix(
    transition_matrix = tm_extreme,
    starting_state    = "Well",
    horizon_years      = 5
  )

  # After the very first cycle, zero cohort members remain alive in any
  # non-Dead state, by construction of the forced transition above.
  survivors_after_cycle_1 <- sum(result_extreme$trace[2, c("Well", "Failed", "Cured")])
  expect_equal(survivors_after_cycle_1, 0, tolerance = 1e-10)
})
```

#pitfall[
  Extreme-value tests are only informative if the extreme value is actually mathematically determinate. Setting a _cost_ parameter to zero, for instance, is a weaker test than setting a _transition probability_ to 1 or 0, because many cost model structures will "pass" a zero-cost extreme test trivially (total cost is zero, which is correct but uninformative about whether the rest of the cost calculation logic works). Choose extremes where the correct answer is unambiguous _and_ where getting it wrong would require the test to actually exercise meaningful parts of the model's logic -- a transition probability of exactly 1 or 0 forces a specific, checkable cohort trace, which is a stronger test than a trivially zero-dollar cost.
]

=== Replication

Replication, in the verification sense used here, means confirming that running the _identical_ model code, with the _identical_ random seed and inputs, on a different machine or in a different R session produces _identical_ numeric output -- not merely "similar" output. This catches a different class of error than unit tests: platform-dependent behavior (e.g. an R package version difference changing a default argument), uncontrolled randomness (a random number generator seed that was not actually fixed everywhere it needed to be), or silent dependency on the state of a previous script run rather than a clean session.

The practical check is straightforward: set the random seed explicitly at the top of the script (as the PSA code in Chapter 25 already does with `set.seed()` before drawing the 2000 parameter sets), run the full model end-to-end in a fresh R session, and save the key numeric outputs -- for example the base-case incremental cost of -dollar 844.14 and incremental QALY of 0.1440 from Chapter 25 -- to a file. Then run the same script again, either in a new session on the same machine after restarting R, or ideally on a colleague's separate machine with the same package versions installed, and confirm the newly produced numbers match the saved ones exactly (or within an extremely tight numeric tolerance consistent with floating-point arithmetic, not within a clinically-motivated tolerance band).

```r
# At the top of the master analysis script, before any random draws:
set.seed(20240101)

# ... full PSA and base-case model run as built in Chapters 19 and 25 ...

# Save key outputs for later replication comparison
saveRDS(
  list(
    incr_cost  = incr_cost_base_case,   # expect -844.14
    incr_qaly  = incr_qaly_base_case,   # expect 0.1440
    incr_nmb   = incr_nmb_wtp_50k       # expect 8044
  ),
  file = "replication_reference_outputs.rds"
)

# On a second machine or fresh session, after rerunning the identical script:
reference <- readRDS("replication_reference_outputs.rds")
test_that("replicated run matches reference outputs exactly", {
  expect_equal(incr_cost_base_case, reference$incr_cost, tolerance = 1e-6)
  expect_equal(incr_qaly_base_case, reference$incr_qaly, tolerance = 1e-6)
  expect_equal(incr_nmb_wtp_50k, reference$incr_nmb, tolerance = 1e-6)
})
```

#heor-practice[
  Before submitting a cost-effectiveness model to a reimbursement body, have someone _other_ than the original model builder attempt a clean replication run on their own machine, from the raw code and documented package versions alone, with no informal guidance from the original author beyond the written analysis plan. If a second analyst cannot independently reproduce the headline incremental cost, incremental QALY, and ICER from the documentation as written, the documentation -- not just the code -- has a gap that a reviewer at the HTA body is equally likely to hit.
]

== 27.4 Validation frameworks (AdViSHE, TECH-VER, ISPOR-SMDM)

Sections 27.1-27.3 addressed *verification*: did we build the model right? We checked that the TB Markov cohort model's code executes correctly, that its mechanics calibrate sensibly, and that unit tests catch regressions in the transition logic. This section turns to *validation*: did we build the right model? Verification is an internal, technical question about implementation fidelity; validation is an external question about whether the model's structure, inputs, and outputs are defensible representations of the real-world decision problem it claims to inform. A model can pass every unit test in Chapter 27.3 and still be the wrong model -- missing a key health state, using an implausible transition structure, or producing outputs that contradict trial or real-world evidence. The sections that follow (27.4-27.6) are about catching that second category of failure.

A widely cited framework for organizing this work is *AdViSHE* (Assessment of the Validation Status of Health-Economic decision models), published by Vemer, Corro Ramos, van Voorn, Al, and Feenstra (2016) in _Pharmacoeconomics_. AdViSHE is a structured checklist that modelers complete and submit alongside a model, so that reviewers, payers, and HTA bodies can see explicitly what validation work has (and has not) been done. It organizes validation effort into several domains:

- *Conceptual model validation* -- is the model's structure (health states, transitions, comparators, time horizon) an adequate representation of the disease and decision problem, as judged against clinical knowledge and existing literature? This connects directly to the model-conceptualization step introduced in Chapter 17.
- *Input data validation* -- are the parameter values (transition probabilities, costs, utilities) sourced appropriately, and are they used consistently with how they were derived?
- *Implementation validation* -- does the model run correctly, free of mechanical errors? This is essentially the verification question from 27.1-27.3, and AdViSHE explicitly treats it as one validation domain among several rather than the whole of validation.
- *Operational validation* -- do the model's outputs behave plausibly and match independent expectations, including comparison against other models or against observed data? This is where cross-validation and external validity (27.6) live.
- *Other validation* -- softer evidence of credibility, such as independent review of the model by a second party, or the model's provenance and prior use in other submissions.

#heor-practice[
Framing validation as a checklist with discrete domains -- rather than a single pass/fail judgment -- is itself the useful part of AdViSHE. It gives a submission team a concrete list of evidence to assemble (clinical expert sign-off on structure, a data-source table, a verification log, a comparison against other published models) rather than a vague assurance that "the model has been validated."
]

ISPOR and the Society for Medical Decision Making (SMDM) jointly produced a seven-part *Modeling Good Research Practices Task Force* series covering model structure, data, parameter estimation, model transparency, and validation among other topics. The task force report most directly relevant here is Eddy, Hollingworth, Caro, Tsevat, McDonald, and Wong (2012), "Model Transparency and Validation," ISPOR-SMDM Modeling Good Research Practices Task Force-7, published jointly in _Value in Health_ and _Medical Decision Making_. That report makes the same verification/validation distinction used as this section's opening bridge, and it further separates validation into face validity, internal validity (verification, in their terminology), cross-validation, and external (predictive) validity -- the same taxonomy structuring section 27.6 below.

A further checklist sometimes referenced in HTA practice, under names such as *TECH-VER*, is aimed at systematic *technical verification* of a model's code and calculations -- essentially a structured audit trail confirming that formulas, cell references, and code paths match the documented methods. The authors of this book are not confident of a single canonical citation for a framework under that exact name, so rather than inventing a specific author or year, TECH-VER is described here at the level of the general practice it represents: a line-by-line, independently conducted technical check of a model's implementation, distinct from -- and complementary to -- the structural and output-level validation domains of AdViSHE. Readers planning a submission that references TECH-VER specifically should confirm the current source document with the relevant HTA body rather than relying on this book.

#ref-table(
  [AdViSHE validation domains and their relationship to this book's chapters],
  academic-table(
    columns: (auto, 1fr, auto),
    align: (left, left, left),
    header: ([*Domain*], [*Question asked*], [*Covered in*]),
    body: (
      [Conceptual model], [Is the model structure a sensible representation of the disease and decision problem?], [Ch. 17; §27.6 face validity],
      [Input data], [Are parameter sources and their use appropriate?], [Ch. 18-19],
      [Implementation], [Does the model run correctly (verification)?], [§27.1-27.3],
      [Operational], [Do outputs match independent expectations (other models, real data)?], [§27.6 cross- and external validity],
      [Other], [Has the model had independent review?], [§27.5],
    ),
    footer: none,
  ),
)

== 27.5 Code review and peer review practices

Validation is not only a property of a finished model; it is also a property of the *process* used to build it. Health-economic models in R benefit from the same code-review discipline used in professional software development, adapted to the fact that a modeling error can change a reimbursement decision rather than just a feature.

The most direct mechanism is a *git-based pull-request review workflow*, building on the version-control practices introduced in Chapter 2. Rather than committing changes to the TB Markov model directly onto a shared branch, a modeler opens a pull request containing, for example, a change to the SoC-arm mortality transition probability. A second modeler reviews the diff, checks that the change is consistent with the cited source, re-runs the test suite from 27.3, and only then approves the merge. This produces a durable audit trail: for every parameter change in the model's history, there is a reviewed, timestamped record of who changed what, why, and who checked it.

A stronger and more expensive form of independent scrutiny, common in HTA practice, is *second-modeler "black-box" replication*: a second analyst, given only the same inputs, assumptions, and target outputs as the original team -- but deliberately *not* given the original code -- builds an independent implementation of the same model from scratch. If the TB Markov model's incremental cost-effectiveness ratio from the independent build matches the original team's result within an acceptable tolerance, this is strong operational-validation evidence (AdViSHE's "other validation" domain) that is largely immune to a shared coding error, since the two implementations do not share code. Discrepancies, when they arise, are often themselves diagnostic: they tend to trace back to an ambiguous assumption in the original model specification that the two teams resolved differently, which is valuable information in its own right.

#agency-note[
ISPOR-SMDM guidance (Eddy et al. 2012, Task Force-7) explicitly recommends independent review and, where feasible, independent replication as part of establishing a model's credibility, precisely because a single team -- however careful -- cannot fully audit its own blind spots. Treat a clean black-box replication as meaningfully stronger evidence than a self-reported internal QA pass; budget and schedule for it on any model intended to support a high-stakes reimbursement submission.
]

A lighter-weight but continuously running layer of scrutiny is the *testthat*-based continuous integration (CI) suite introduced in section 27.3. Where black-box replication is a one-off, resource-intensive check typically performed once per submission, CI tests run on every commit and every pull request, automatically re-verifying that state occupancies still sum to one, that known reference-case outputs have not silently drifted, and that cost and QALY totals remain within expected bounds after each change. Pull-request review and CI are complementary: CI catches mechanical regressions immediately and cheaply; human review catches conceptual and judgment errors that no automated test is written to detect, because no one anticipated that particular mistake.

#pitfall[
A pull request that passes every CI check is not the same as a pull request that has been genuinely reviewed. CI tests only catch what someone thought to test for; they say nothing about whether a change is clinically or economically sensible. Do not let a green CI badge substitute for a human reviewer actually reading the diff and the rationale behind it.
]

== 27.6 Face validity, internal, cross and external validity

Building on the Eddy et al. (2012) taxonomy introduced in 27.4, this section works through four distinct senses of "the model is valid," each asking a different question and requiring different evidence.

*Face validity* asks whether the model's structure and assumptions look sensible to people who know the disease and the decision context -- a qualitative, expert-judgment check rather than a numerical test. For the TB Markov model, face validity was substantively addressed during the model-conceptualization step in Chapter 17, when clinical input shaped the choice of health states (e.g., active TB, treatment, cured, dead) and the plausibility of the comparator structure (New regimen vs. SoC). Face validity is revisited here because it is not a one-time event: every subsequent structural change to the model -- a new health state, a revised transition pathway -- warrants a fresh face-validity check with clinical input before the change is accepted.

#difficult-terminology("face validity")[
Face validity is the simplest and least rigorous form of validation: a domain expert looks at a model's structure and assumptions and judges whether they are plausible on their face, without running any numbers. It is a necessary first filter -- an implausible structure is not worth validating numerically -- but it is not sufficient on its own, because a structurally sensible model can still produce numerically wrong outputs.
]

*Internal validity* asks whether the model's own internal logic and arithmetic are self-consistent: do the mechanics do what they are supposed to do? This is the same check already demonstrated mechanically in Chapter 19 and automated in 27.1-27.3 -- for instance, confirming that the four state-occupancy proportions in each model cycle sum to 1 (within floating-point tolerance), that costs and QALYs accumulate correctly across cycles, and that no probability mass silently leaks out of the state vector. Internal validity overlaps heavily with what Eddy et al. (2012) call verification; it is listed here to complete the taxonomy, not because it needs re-explaining after 27.1-27.3.

*Cross-validation* -- in this health-economic-modeling sense -- compares this model's results against the results of *other, independently built* models addressing the same decision problem (for example, other published TB cost-effectiveness models evaluating similar regimens). Close agreement is reassuring; disagreement motivates investigating whether the models differ in structure, data sources, or time horizon, and whether one is more defensible than the other.

#difficult-terminology("cross-validation (health-economic sense)")[
This term is a naming collision with the statistical/machine-learning sense of cross-validation used in Chapter 16 (splitting a dataset into folds to estimate out-of-sample predictive performance). In health-economic model validation, cross-validation means something structurally different: comparing one *entire decision model's* outputs against those of *other, separately built* models of the same decision problem. No data-splitting or resampling is involved. When reading HTA methods guidance, infer which sense is meant from context -- a statistics chapter means the ML sense; a model-validation chapter (like this one) means the model-comparison sense.
]

*External validity* -- also called predictive validity -- asks whether the model's *projected* outcomes, extended forward in time, match what *actually happened* in the real world once enough time has passed to observe it. This is the most demanding form of validation, because it requires real-world follow-up data that may not exist until years after the model was built; Chapter 15's real-world-evidence (RWE) methods are the natural data source for making this comparison once such data become available.

*Illustrative worked example.* Suppose the TB Markov model, run forward from treatment initiation, predicts 10-year overall survival of 78% for patients on the New regimen. Suppose further that a (clearly illustrative, not an actual published figure) real-world TB cohort followed for 10 years after a comparable regimen reports observed 10-year survival of 74%. The absolute difference is:

$ 78 - 74 = 4 $ percentage points.

As a relative (percentage) difference relative to the observed figure:

$ (78 - 74) / 74 times 100 approx 5.41 $ percent.

So the model's prediction is 4 percentage points higher than the illustrative observed cohort figure, or about 5.4% higher in relative terms. Whether a 4-percentage-point gap is "close enough" is a judgment call that depends on the cohort's sample size and confidence interval, the time elapsed, and how much the real-world cohort's population and care pathway diverge from the model's assumed population -- but the computation above is exactly the kind of check an external-validity exercise performs: take the model's forward-projected number, take the later-observed number for the same quantity, and quantify the gap.

#report-table(
  [Illustrative external-validity comparison for 10-year survival, New regimen],
  academic-table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    header: ([*Quantity*], [*Value*], [*Source*]),
    body: (
      [Model-predicted 10-year survival], [78%], [TB Markov model, Ch. 19],
      [Observed 10-year survival (illustrative cohort)], [74%], [Illustrative RWE comparator],
      [Absolute difference], [4 pp], [Computed above],
      [Relative difference], [≈5.41%], [Computed above],
    ),
    footer: (table.cell(colspan: 3)[Figures for the observed cohort are illustrative, not drawn from a published source, and are used only to demonstrate the external-validity calculation.],),
  ),
)

#pitfall[
Do not treat a close match between model predictions and real-world outcomes as proof the model is "correct." A single cohort's 10-year outcome is one noisy data point; close agreement could be coincidental, and disagreement could reflect a real-world population that differs from the model's target population rather than a flawed model. External validity checks are evidence to weigh, not a verdict to declare from one comparison.
]

Taken together, face validity, internal validity, cross-validation, and external validity form a layered evidence base: a model that looks sensible to experts, computes correctly, agrees with independently built peers, and -- where data eventually permit -- tracks real-world outcomes, has accumulated a substantially stronger validation case than a model that only passes one of these checks. None of this evidence is useful, however, if it is scattered across emails, slide decks, and someone's memory of a meeting. Chapter 28, Reproducible Reporting, takes up exactly that problem: how the verification evidence from 27.1-27.3 and the validation evidence from 27.4-27.6 get written down, version-controlled, and communicated to reviewers and decision-makers in a form that is itself reproducible.
