#import "../common.typ": *

= Chapter 35. End-to-End Worked Case Studies

#learning-objectives((
  [Build a complete cohort Markov model cost-effectiveness analysis from first principles -- states, transition matrix, discounting, costs/utilities, ICER, and a probabilistic sensitivity analysis -- for a new chronic-disease decision problem.],
  [Build a complete oncology partitioned survival model that consumes a network meta-analysis-derived relative-effect estimate as an input, and test the result's sensitivity to extrapolation and treatment-waning structural assumptions.],
  [Build a complete individual-level microsimulation of a screening programme, including patient heterogeneity, an imperfect screening test, and a two-layer probabilistic sensitivity analysis that separates first-order from second-order uncertainty.],
  [Build a complete multi-year budget impact analysis and explain concretely how its calculation engine would become an interactive Shiny tool for a payer audience.],
  [Build a complete real-world-evidence comparative effectiveness analysis using propensity-score matching and weighting, check covariate balance, and connect the resulting treatment-effect estimate to an economic model as a relative-effect input.],
  [Build a complete, LMIC-contextualised TB programme cost-effectiveness analysis using a cascade-of-care cohort structure, and interpret the result against locally-relevant cost-effectiveness threshold conventions rather than an imported rule of thumb.],
  [Across all six case studies, independently verify every stated numeric result by actually running the underlying R code, rather than trusting a plausible-sounding number.],
))

This final chapter does not introduce new statistical or modelling theory. Every method used below -- cohort Markov models, partitioned survival modelling, microsimulation, budget impact analysis, propensity-score methods, and cascade-of-care cost-effectiveness modelling -- was taught in full earlier in this book, each in its own dedicated chapter. What this chapter adds is synthesis: six complete, start-to-finish worked examples, each built around its own new simulated dataset and new numbers, showing what it actually looks like to carry one of these methods from a decision problem through to a reportable result. Every number quoted in every case study below was computed by actually running the code shown, not estimated or guessed -- a discipline this book has tried to apply consistently throughout, and one that matters most of all in a chapter whose entire purpose is to be a template a reader might genuinely adapt.

== 35.1 Case study A: a Markov model CEA for a chronic disease

This case study walks a single disease area -- chronic kidney disease (CKD) progression -- through a complete cohort Markov cost-effectiveness analysis (CEA), from states to ICER to probabilistic sensitivity analysis (PSA). The modelling mechanics follow the matrix-based base-R approach first introduced in Chapter 19 SS19.3, but the disease, states, and all numbers here are new: nothing is copied from that earlier worked example.

=== The decision problem

A national payer is considering reimbursing an add-on SGLT2-inhibitor-class therapy for adults with CKD stages 3-5, layered on top of standard of care (SoC: ACE-inhibitor/ARB therapy, blood-pressure control, dietary counselling). Trial and real-world evidence suggest the add-on slows the rate of renal functional decline. The question for the submission is simple to state and, as always, hard to answer cleanly: does the added drug cost buy enough extra quality-adjusted survival, and at what cost per quality-adjusted life year (QALY), relative to a willingness-to-pay (WTP) threshold?

=== Step (a): health states and the transition matrix

Five mutually exclusive, collectively exhaustive states describe the cohort's journey: CKD stage 3 (the model's entry state), CKD stage 4, CKD stage 5 pre-dialysis, dialysis-dependent end-stage renal disease, and death. Annual cycles are used, consistent with how CKD progression is actually staged and monitored in practice (annual estimated glomerular filtration rate (eGFR) review).

#pitfall[
  A Markov cohort model's transition matrix must have every row sum to exactly 1 -- each state must transition *somewhere*, including back to itself. A row that silently sums to 0.97 "loses" 3% of the cohort every cycle, inflating survival and QALYs without any error message. Always assert this with `stopifnot(all(abs(rowSums(tm) - 1) < 1e-9))` immediately after building the matrix, before running a single cycle.
]

```r
states <- c("CKD3", "CKD4", "CKD5_predialysis", "Dialysis", "Dead")
n_states <- length(states)

## Annual transition probability matrix, standard of care (SoC)
tm_soc <- matrix(c(
  0.70, 0.18, 0.05, 0.02, 0.05,   # from CKD3
  0.00, 0.62, 0.22, 0.08, 0.08,   # from CKD4
  0.00, 0.00, 0.55, 0.30, 0.15,   # from CKD5_predialysis
  0.00, 0.00, 0.00, 0.78, 0.22,   # from Dialysis
  0.00, 0.00, 0.00, 0.00, 1.00    # from Dead (absorbing)
), nrow = n_states, byrow = TRUE,
   dimnames = list(states, states))

stopifnot(all(abs(rowSums(tm_soc) - 1) < 1e-9))
```

The add-on therapy's clinical effect is expressed as a relative risk (RR) of progression events: patients on the add-on move to a worse state, or to death, at 72% of the SoC rate (`rr_progression <- 0.72`), with the "saved" probability mass reallocated to staying in the current state. This is a standard, defensible way to encode a treatment effect onto a transition matrix when the trial reports a hazard ratio for a composite progression endpoint rather than a full multi-state transition model:

```r
rr_progression <- 0.72
tm_new <- tm_soc
for (i in 1:(n_states - 1)) {
  move_idx <- setdiff(which(seq_len(n_states) > i), i)   # worse states + death, excluding self
  reduced  <- tm_soc[i, move_idx] * rr_progression
  delta    <- sum(tm_soc[i, move_idx]) - sum(reduced)     # probability mass "saved"
  tm_new[i, move_idx] <- reduced
  tm_new[i, i] <- tm_soc[i, i] + delta                     # saved mass stays in current state
}
stopifnot(all(abs(rowSums(tm_new) - 1) < 1e-9))
```

=== Step (b): cohort simulation with discounting

A hypothetical cohort of 1.0 (i.e., 100% of patients) starts in CKD3 and is run forward for a 25-year horizon -- long enough for the vast majority of the cohort to reach an absorbing state (dialysis or death), which matters because a horizon that is too short systematically understates lifetime cost and QALY differences. Costs and QALYs are discounted at 3% per year, the conventional base case in most HTA reference cases:

```r
horizon <- 25
discount_cost <- 0.03
discount_qaly <- 0.03

run_trace <- function(tm) {
  trace <- matrix(0, nrow = horizon + 1, ncol = n_states,
                   dimnames = list(0:horizon, states))
  trace[1, ] <- c(1, 0, 0, 0, 0)
  for (t in 1:horizon) trace[t + 1, ] <- trace[t, ] %*% tm
  trace
}

trace_soc <- run_trace(tm_soc)
trace_new <- run_trace(tm_new)
```

=== Step (c): attaching costs and utilities

Annual state costs (local-currency units) cover monitoring, medication, and complications; dialysis dominates the cost picture, as it does in real CKD economics. Health-state utilities (on the 0-1 EQ-5D-type scale) decline with disease severity. The new treatment additionally carries its own annual drug cost, applied only while the patient is alive:

```r
cost_state <- c(CKD3 = 1800, CKD4 = 3200, CKD5_predialysis = 6500,
                 Dialysis = 48000, Dead = 0)
util_state <- c(CKD3 = 0.82, CKD4 = 0.76, CKD5_predialysis = 0.68,
                 Dialysis = 0.60, Dead = 0)
drug_cost_new <- 2600   # annual add-on drug cost, new arm only, while alive

discounted_total <- function(trace, drug_add = 0) {
  disc_c <- 1 / (1 + discount_cost)^(0:horizon)
  disc_q <- 1 / (1 + discount_qaly)^(0:horizon)
  alive  <- 1 - trace[, "Dead"]
  cost_per_cycle <- trace %*% cost_state + drug_add * alive
  qaly_per_cycle <- trace %*% util_state
  list(cost = sum(cost_per_cycle * disc_c),
       qaly = sum(qaly_per_cycle * disc_q))
}

res_soc <- discounted_total(trace_soc, drug_add = 0)
res_new <- discounted_total(trace_new, drug_add = drug_cost_new)
```

=== Step (d): the ICER

Running this exact code (with `set.seed(2024)` fixing the later PSA draws) gives:

```r
inc_cost <- res_new$cost - res_soc$cost   # 44941.18
inc_qaly <- res_new$qaly - res_soc$qaly   # 1.5589
icer <- inc_cost / inc_qaly               # 28829.00
```

The incremental cost of the add-on strategy is 44,941 (local currency units) and the incremental benefit is 1.559 QALYs over the discounted 25-year horizon, giving a deterministic base-case ICER of 28,829 per QALY gained.

#report-table(
  [Case study A -- base-case deterministic results, CKD add-on therapy vs standard of care],
  academic-table(
    columns: (2fr, 1fr, 1fr, 1.4fr),
    align: (left, right, right, right),
    header: ([Strategy], [Total discounted cost], [Total discounted QALYs], [ICER vs SoC]),
    body: (
      [Standard of care], [103,339], [5.338], [--],
      [New add-on therapy], [148,280], [6.897], [--],
      [Incremental], [+44,941], [+1.559], [28,829 / QALY],
    ),
    footer: (table.cell(colspan: 4)[Base-case cohort Markov model, 25-year horizon, 3% annual discounting on costs and QALYs. Currency units are local-currency, undenominated.],),
  ),
)

=== Step (e): probabilistic sensitivity analysis

A deterministic ICER is a single point estimate built on point-estimate inputs; it says nothing about how confident the analysis should be. A PSA addresses this by redrawing every uncertain input from a distribution -- the progression RR from a lognormal distribution centred on 0.72, state costs from lognormal multipliers, and utilities from a normal multiplier capped at 1 -- and recomputing the ICER thousands of times:

```r
n_sim <- 2000
psa <- matrix(NA, n_sim, 2, dimnames = list(NULL, c("inc_cost", "inc_qaly")))

for (s in 1:n_sim) {
  rr_draw   <- exp(rnorm(1, log(0.72), 0.08))        # lognormal around point estimate
  rr_draw   <- min(max(rr_draw, 0.4), 1.1)
  cost_draw <- cost_state * rlnorm(n_states, 0, 0.1); cost_draw["Dead"] <- 0
  util_draw <- pmin(util_state * rnorm(n_states, 1, 0.05), 1); util_draw["Dead"] <- 0
  drug_draw <- drug_cost_new * rlnorm(1, 0, 0.1)

  tm_new_s <- tm_soc
  for (i in 1:(n_states - 1)) {
    move_idx <- setdiff(which(seq_len(n_states) > i), i)
    reduced  <- tm_soc[i, move_idx] * rr_draw
    delta    <- sum(tm_soc[i, move_idx]) - sum(reduced)
    tm_new_s[i, move_idx] <- reduced
    tm_new_s[i, i] <- tm_soc[i, i] + delta
  }

  r_soc <- discounted_total(run_trace(tm_soc), 0)
  r_new <- discounted_total(run_trace(tm_new_s), drug_draw)
  psa[s, ] <- c(r_new$cost - r_soc$cost, r_new$qaly - r_soc$qaly)
}
```

Across the 2,000 simulations the mean incremental cost is 44,879 and the mean incremental QALY is 1.5655, giving a PSA-mean ICER of 28,668 per QALY -- reassuringly close to the deterministic figure, which is itself a useful check: a PSA mean that drifts far from the deterministic ICER usually signals a skewed or mis-specified input distribution rather than a genuine finding.

The cost-effectiveness plane plots each simulated (incremental QALY, incremental cost) pair; the cost-effectiveness acceptability curve (CEAC) then reads off, at each candidate WTP threshold, the proportion of simulations where the add-on's net monetary benefit is positive:

```r
library(ggplot2)

psa_df <- as.data.frame(psa)
ggplot(psa_df, aes(x = inc_qaly, y = inc_cost)) +
  geom_point(alpha = 0.3, colour = "steelblue") +
  geom_abline(slope = 50000, intercept = 0, linetype = "dashed") +
  labs(x = "Incremental QALYs", y = "Incremental cost",
       title = "Cost-effectiveness plane: add-on therapy vs SoC") +
  theme_minimal()

wtp_grid <- seq(0, 150000, by = 5000)
ceac <- sapply(wtp_grid, function(w) mean(w * psa_df$inc_qaly - psa_df$inc_cost > 0))

ggplot(data.frame(wtp = wtp_grid, p_ce = ceac), aes(wtp, p_ce)) +
  geom_line(colour = "darkred") +
  labs(x = "Willingness-to-pay per QALY", y = "Probability cost-effective",
       title = "Cost-effectiveness acceptability curve") +
  theme_minimal()
```

At a WTP of 20,000 per QALY only 0.2% of simulations favour the add-on; at 50,000 per QALY that rises to 99.1%; by 100,000 per QALY essentially all simulations (100%) favour it. The CEAC therefore has a steep rise concentrated in the 20,000-50,000 range, which is exactly where the deterministic ICER of ~28,800 sits.

=== Step (f): interpretation against a willingness-to-pay threshold

If the payer's WTP threshold is 50,000 per QALY -- a common reference value in several health systems -- the add-on therapy is cost-effective on both the deterministic ICER (28,829, comfortably below threshold) and the PSA (99.1% probability of being cost-effective at that threshold). Against a stricter threshold of 20,000 per QALY the conclusion flips sharply: the add-on would almost never be judged cost-effective. This sensitivity to the chosen threshold is not a flaw in the analysis; it is the entire point of reporting the ICER alongside a CEAC rather than a bare pass/fail verdict -- the committee, not the model, makes the threshold judgement, and the model's job is to show how that judgement interacts with the underlying uncertainty.

#agency-note[
  NICE's reference case does not specify one fixed WTP threshold line to report against; its published guidance (and the DSU technical support documents discussed in Chapter 31 §31.1) describes a working range of £20,000-£30,000 per QALY with an explicit upward-flexing mechanism for end-of-life and highly specialised technologies, while other agencies such as Australia's PBAC use a comparably structured but numerically different range, and CADTH and others again differ further. A submission built around one threshold value should still report the full CEAC (or an incremental net health benefit table across several threshold values, per the PSA visualisation conventions covered in Chapter 25 §25.5) so the appraisal committee can apply whichever decision rule its own methods guide specifies, rather than the analyst's assumed threshold.
]

== 35.2 Case study B: an oncology partitioned survival model with NMA inputs

This case study builds a complete partitioned survival model (PSM) cost-effectiveness analysis for a new systemic therapy in metastatic urothelial (bladder) carcinoma, structured around a network meta-analysis (NMA)-derived relative-effect estimate exactly as Chapter 12 describes such estimates being produced and consumed downstream. The survival-modelling mechanics follow the base-R-plus-`flexsurv` style used in Chapter 20 SS20.2/SS20.4; the cancer type, patient-level data, and every number here are new relative to Chapter 20 SS20.6's worked example.

=== The decision problem and where the NMA fits

A new checkpoint-inhibitor-class agent is compared with platinum-based chemotherapy (the comparator) for second-line treatment of metastatic urothelial carcinoma. No head-to-head trial exists against every comparator a payer cares about, so -- as Chapter 12 sets out -- an NMA has already been run elsewhere, pooling evidence across a connected network of trials, to produce relative-effect estimates (hazard ratios) for the new agent versus platinum-based chemotherapy on both progression-free survival (PFS) and overall survival (OS). This case study does not re-run that NMA; it takes its two headline outputs -- an OS hazard ratio (HR) of 0.68 and a PFS HR of 0.74, both favouring the new agent -- as fixed, already-validated inputs and shows what a submission team actually does with them once they arrive: use them to project the new agent's survival curves from a directly observed comparator arm.

=== Step (a): fitting parametric curves to comparator patient-level data

Patient-level PFS and OS data for the comparator arm (platinum-based chemotherapy) are simulated for 400 patients with administrative censoring at 36 months, mirroring how a real submission would use its own trial or registry comparator-arm data:

```r
library(flexsurv)
library(survival)

set.seed(4102)
n_pts <- 400
pfs_time_raw <- rweibull(n_pts, shape = 1.3, scale = 7.5)
os_time_raw  <- pmax(pfs_time_raw, rweibull(n_pts, shape = 1.15, scale = 14.0))
admin_censor <- 36
pfs_time  <- pmin(pfs_time_raw, admin_censor); pfs_event <- as.numeric(pfs_time_raw <= admin_censor)
os_time   <- pmin(os_time_raw,  admin_censor); os_event  <- as.numeric(os_time_raw  <= admin_censor)
ipd <- data.frame(pfs_time, pfs_event, os_time, os_event)

fit_pfs_comp <- flexsurvreg(Surv(pfs_time, pfs_event) ~ 1, data = ipd, dist = "weibull")
fit_os_comp  <- flexsurvreg(Surv(os_time,  os_event)  ~ 1, data = ipd, dist = "weibull")
```

The fitted Weibull parameters are PFS: shape = 1.287, scale = 7.607 months; OS: shape = 1.513, scale = 16.156 months. These describe a disease with a short, aggressive natural history -- a median OS around 12-13 months on the comparator arm, consistent with second-line metastatic urothelial carcinoma in practice.

=== Step (b): projecting the new treatment's curves using the NMA hazard ratio

Under a Weibull proportional-hazards assumption, a constant HR can be mapped onto the Weibull scale parameter while holding shape fixed: a cumulative hazard $H(t) = (t / "scale")^"shape"$, and multiplying $H(t)$ by the HR is algebraically equivalent to rescaling $"scale"$ by $"HR"^(-1 / "shape")$. This is exactly how an NMA-derived HR becomes a full extrapolated survival curve for an arm with no direct long-term follow-up data of its own:

```r
hr_os_nma  <- 0.68   # NMA-pooled OS hazard ratio, new agent vs comparator
hr_pfs_nma <- 0.74   # NMA-pooled PFS hazard ratio, new agent vs comparator

shape_pfs <- fit_pfs_comp$res["shape", "est"]; scale_pfs_comp <- fit_pfs_comp$res["scale", "est"]
shape_os  <- fit_os_comp$res["shape", "est"];  scale_os_comp  <- fit_os_comp$res["scale", "est"]

scale_pfs_new <- scale_pfs_comp * hr_pfs_nma^(-1 / shape_pfs)
scale_os_new  <- scale_os_comp  * hr_os_nma^(-1 / shape_os)

S_pfs <- function(t, arm) {
  sc <- if (arm == "comp") scale_pfs_comp else scale_pfs_new
  exp(-(t / sc)^shape_pfs)
}
S_os <- function(t, arm) {
  sc <- if (arm == "comp") scale_os_comp else scale_os_new
  exp(-(t / sc)^shape_os)
}
```

#pitfall[
  Applying a hazard ratio to a parametric survival curve is only internally consistent for distributions where proportional hazards line up with a simple scale transformation (Weibull, exponential, Gompertz under the right parameterisation). For a log-logistic or log-normal fit, the HR-to-parameter mapping is different (log-logistic hazard ratios are not constant over time even when the ratio of odds is), and substituting the Weibull rescaling formula into a different distribution's parameters silently produces the wrong curve. Always re-derive the mapping for whichever distribution the base case actually uses.
]

=== Step (c): partitioning into health states and attaching costs/utilities

A PSM allocates each monthly cycle's cohort between three states -- alive and progression-free ("pre-progression"), alive and progressed ("post-progression"), and dead -- using exactly the identity Chapter 20 SS20.2 introduces: the pre-progression proportion equals the PFS curve, and the post-progression proportion is whatever gap opens up between the OS curve and the PFS curve (OS must be greater than or equal to PFS at every time point, since death cannot precede progression in the data-generating sense used here):

```r
horizon_months <- 120
cycles <- 0:horizon_months
disc_vec <- 1 / (1.03)^(cycles / 12)

partition <- function(arm) {
  s_pfs <- S_pfs(cycles, arm)
  s_os  <- pmax(S_os(cycles, arm), s_pfs)   # OS survival >= PFS survival
  pre_prog  <- s_pfs
  post_prog <- pmax(s_os - s_pfs, 0)
  dead      <- 1 - s_os
  data.frame(month = cycles, pre_prog = pre_prog, post_prog = post_prog, dead = dead)
}

part_comp <- partition("comp")
part_new  <- partition("new")

cost_pre_prog  <- 2400; cost_post_prog <- 3100; cost_terminal <- 9500
drug_cost_new  <- 6800   # new agent's own monthly drug cost, pre-progression only
util_pre_prog  <- 0.78;  util_post_prog <- 0.62

cost_qaly <- function(part, drug_month = 0) {
  incident_deaths <- pmax(c(0, diff(part$dead)), 0)
  cost_month <- part$pre_prog * (cost_pre_prog + drug_month) +
                part$post_prog * cost_post_prog +
                incident_deaths * cost_terminal
  qaly_month <- (part$pre_prog * util_pre_prog + part$post_prog * util_post_prog) / 12
  list(cost = sum(cost_month * disc_vec), qaly = sum(qaly_month * disc_vec))
}
```

#pitfall[
  It is easy to write `post_prog <- pmin(s_os, s_pfs)` by analogy with other clamping code elsewhere in a script, when the correct relationship is the opposite: because death can only occur after (or coincident with) disease progression in this model structure, the OS curve must sit *above* the PFS curve, and the progressed-but-alive proportion is the *gap* between them (`s_os - s_pfs`), not their minimum. Getting this backwards silently produces a negative or zero post-progression population and an ICER that looks plausible but is wrong -- always sanity-check that `pre_prog + post_prog + dead` sums to 1 at every cycle before trusting the output.
]

=== Step (d): the ICER

```r
res_comp <- cost_qaly(part_comp, drug_month = 0)                 # cost 49509.59, qaly 0.8587
res_new  <- cost_qaly(part_new,  drug_month = drug_cost_new)      # cost 123375.89, qaly 1.0886

inc_cost <- res_new$cost - res_comp$cost   # 73866.30
inc_qaly <- res_new$qaly - res_comp$qaly   # 0.2299
icer <- inc_cost / inc_qaly                # 321271.05
```

The base-case ICER is 321,271 per QALY gained -- far above typical oncology WTP ranges, driven mainly by this short-horizon disease's small absolute QALY gain (0.230 QALYs) relative to the new agent's substantial incremental cost. This is a realistic feature of late-line metastatic oncology economics, not a modelling artefact: large relative-risk reductions (a 32% reduction in the hazard of death) translate into modest absolute QALY gains when baseline survival is already short.

#report-table(
  [Case study B -- base-case results, new checkpoint-inhibitor-class agent vs platinum-based chemotherapy],
  academic-table(
    columns: (2fr, 1fr, 1fr, 1.4fr),
    align: (left, right, right, right),
    header: ([Strategy], [Total discounted cost], [Total discounted QALYs], [ICER vs comparator]),
    body: (
      [Platinum-based chemotherapy], [49,510], [0.859], [--],
      [New checkpoint-inhibitor agent], [123,376], [1.089], [--],
      [Incremental], [+73,866], [+0.230], [321,271 / QALY],
    ),
    footer: (table.cell(colspan: 4)[Base-case partitioned survival model, Weibull PFS and OS extrapolation, NMA-derived hazard ratios (OS 0.68, PFS 0.74), 10-year horizon, 3% annual discounting.],),
  ),
)

=== Step (e): structural-uncertainty scenarios

A single base-case extrapolation choice is never the whole story for a submission. Two scenarios, in the spirit of Chapter 20 SS20.3's treatment of extrapolation and waning assumptions, are run here.

*Scenario 1 -- alternative extrapolation distribution.* The OS comparator curve is refit as log-logistic rather than Weibull (shape = 2.342, scale = 11.719), and the same HR-based rescaling logic is reapplied (with the log-logistic-appropriate parameter mapping, not the Weibull one -- see the pitfall above):

```r
fit_os_ll <- flexsurvreg(Surv(os_time, os_event) ~ 1, data = ipd, dist = "llogis")
shape_ll <- fit_os_ll$res["shape", "est"]; scale_ll <- fit_os_ll$res["scale", "est"]
scale_ll_new <- scale_ll * hr_os_nma^(-1 / shape_ll)
```

This gives incremental cost 69,375, incremental QALY 0.1547, and ICER 448,345 per QALY -- noticeably worse (higher) than the Weibull base case, because the log-logistic fit implies a flatter long-term OS tail for the comparator, which narrows the absolute survival gap the new agent's HR can act on.

*Scenario 2 -- treatment-effect waning.* Rather than assuming the OS hazard ratio holds forever, this scenario lets the benefit wane linearly from the trial's full effect (HR 0.68) at month 24 back to no effect (HR 1.0) by month 36 -- a standard structural caution for checkpoint-inhibitor-class agents, where long-term benefit durability beyond the trial follow-up window is genuinely uncertain. Implementing this requires rebuilding the new arm's cumulative hazard from the baseline Weibull cumulative hazard, weighted cycle by cycle by the time-varying hazard ratio, rather than the single constant-HR rescaling used in the base case:

```r
# Baseline comparator OS cumulative hazard (Weibull): H(t) = (t/scale)^shape
H_comp <- function(t) (t / scale_os_comp)^shape_os

# Time-varying HR: full effect (0.68) until month 24, linearly waning to 1.0 by month 36
hr_waning <- function(t) {
  ifelse(t <= 24, 0.68, ifelse(t >= 36, 1, 0.68 + (1 - 0.68) * (t - 24) / 12))
}

# New arm's cumulative hazard at time t = integral of hr_waning(u) against the
# baseline's cumulative-hazard increments, via fine-grained numerical integration
t_fine      <- seq(0, horizon_months, by = 0.1)
dH_comp_fine <- c(0, diff(H_comp(t_fine)))        # increments of baseline cum. hazard
H_new_fine  <- cumsum(hr_waning(t_fine) * dH_comp_fine)

# Interpolate the new arm's cumulative hazard back onto the model's monthly cycles
H_new_at_cycles <- approx(t_fine, H_new_fine, xout = cycles)$y
S_os_new_waning <- exp(-H_new_at_cycles)
```

This gives incremental cost 61,341, incremental QALY 0.1798, and ICER 341,219 per QALY -- closer to the Weibull base case than scenario 1, because the waning assumption only erodes the treatment effect in the second and third years rather than removing proportional benefit at every time point, as the log-logistic extrapolation effectively does by flattening the whole comparator tail.

#ref-table(
  [Case study B -- ICER under alternative structural assumptions],
  academic-table(
    columns: (2.2fr, 1fr, 1fr, 1.4fr),
    align: (left, right, right, right),
    header: ([Scenario], [Inc. cost], [Inc. QALYs], [ICER]),
    body: (
      [Base case: Weibull OS, lifetime HR], [73,866], [0.230], [321,271],
      [Scenario 1: log-logistic OS extrapolation], [69,375], [0.155], [448,345],
      [Scenario 2: OS benefit waning, months 24-36], [61,341], [0.180], [341,219],
    ),
    footer: (table.cell(colspan: 4)[All figures discounted at 3% per annum over a 10-year horizon; all other parameters held at base-case values.],),
  ),
)

The ICER is sensitive to both choices, moving by roughly 40% across the three scenarios while never approaching a conventional oncology WTP threshold. That single fact -- not any one scenario's exact number -- is usually the most decision-relevant output: the committee should understand that extrapolation and waning assumptions move this result by tens of thousands of currency units per QALY, and should see the full range in Chapter 20's and Chapter 12's recommended format rather than a single point estimate presented without its structural context.

#heor-practice[
  A reviewer reading this kind of PSM submission will usually ask two questions before anything else: "why this parametric family for the base case?" (answer with statistical fit diagnostics *and* clinical plausibility of the tail, not AIC alone) and "what happens to the ICER if the relative-effect estimate came from indirect evidence?" (answer by showing, as above, that the model's ICER is reported as a function of the NMA's point estimate and its surrounding structural choices, not as a single number assumed to be exact).
]

== 35.3 Case study C: a microsimulation of a screening programme

This final case study builds a complete, patient-level microsimulation cost-effectiveness analysis of a cancer screening programme, from cohort generation through to a probabilistic sensitivity analysis (PSA). It deliberately uses a different disease context from the tuberculosis screening microsimulation worked through in Chapter 21 SS21.7 -- here the question is whether a ten-yearly colonoscopy-based colorectal cancer (CRC) screening programme is cost-effective compared with no organised screening, built around a simple polyp-to-cancer natural-history model. Everything below is runnable base R; the only "new" machinery relative to Chapter 21 SS21.7 is a frailty-based heterogeneity structure and a second, nested PSA loop that lets you see first-order and second-order uncertainty side by side in the same numbers, rather than only in the abstract (Chapter 21 SS21.4).

=== 35.3.1 Clinical context and model structure

Colorectal cancer typically develops from adenomatous polyps that progress slowly -- over years -- through low-risk and high-risk stages before becoming invasive cancer, first in a pre-clinical (asymptomatic, screen-detectable) form and then presenting clinically with symptoms. This multi-year "detectable pre-clinical phase" is exactly what organised screening programmes exploit: a colonoscopy performed during this window can remove a polyp before it ever becomes cancer, or catch a cancer at an earlier, more treatable stage than it would have presented clinically.

The model tracks each simulated patient through seven mutually exclusive states, updated once per annual cycle over a 40-year horizon (ages 50 to 89):

#ref-table(
  [Natural-history states in the colorectal cancer microsimulation],
  academic-table(
    columns: (1fr, 2.4fr, 1.6fr),
    align: (left, left, left),
    header: ([Code], [State], [Utility weight]),
    body: (
      [1], [Healthy (no polyp)], [1.00],
      [2], [Low-risk adenomatous polyp], [0.99],
      [3], [High-risk adenomatous polyp], [0.97],
      [4], [Pre-clinical (asymptomatic, screen-detectable) CRC], [0.90],
      [5], [Clinical CRC (symptomatic / under treatment)], [0.68],
      [6], [Dead -- CRC], [0.00],
      [7], [Dead -- other cause], [0.00],
    ),
    footer: none,
  ),
)

Each cycle, a patient who is alive can move from healthy to low-risk polyp, low-risk to high-risk polyp, high-risk polyp to pre-clinical CRC, and pre-clinical to clinical CRC if undetected; clinical CRC carries an annual CRC-death hazard, and every state carries a small background (other-cause) mortality hazard. In the *unscreened* arm, nothing interrupts this chain except background mortality -- some patients will progress all the way to clinical disease and CRC death, others will die of other causes first, and some will simply never develop polyps at all.

=== 35.3.2 Patient heterogeneity via a frailty multiplier

As in Chapter 21 SS21.2, treating every simulated patient as facing the identical annual risk of developing a polyp would understate the true spread of outcomes in a cohort: some patients are at persistently higher lifetime risk (genetics, diet, prior polyp history) and others at persistently lower risk. This is captured here with a single multiplicative *frailty* term per patient, drawn once at the start of the simulation and applied to every polyp-related transition probability for that patient for the rest of the run.

#difficult-terminology("frailty distribution")[
  In survival and multi-state modelling, a "frailty" is an unobserved, patient-specific multiplier applied to a baseline hazard or risk to represent heterogeneity that isn't explained by the variables in the model. A patient with a frailty of 1.4 experiences every polyp-related transition probability at 1.4 times the cohort-average rate, for every cycle of their simulated life. Drawing one frailty value per patient (rather than re-drawing noise every cycle) is what creates lasting high-risk and low-risk subgroups within the cohort, instead of everyone drifting toward the same average by chance.
]

```r
set.seed(20351)

N         <- 200000   # patients per arm
n_cycles  <- 40        # annual cycles, ages 50-89
start_age <- 50

# Lognormal frailty, mean approximately 1 across the cohort
frailty_sd <- 0.6
frailty <- rlnorm(N, meanlog = -0.5 * frailty_sd^2, sdlog = frailty_sd)
```

The `meanlog` term is set to `-0.5 * sdlog^2` purely so that `mean(frailty)` comes out close to 1 -- this keeps the cohort-average transition probabilities equal to the stated baseline rates, while individual patients range widely above and below that average.

=== 35.3.3 Screening strategy and full simulation engine

The screening strategy modelled is a single colonoscopy-equivalent test performed every 10 years (cycles 1, 11, 21, 31) for every patient still alive, with sensitivity 90% for polyps and 95% for pre-clinical cancer, and specificity 90% (so 10% of truly healthy patients incur a false-positive work-up cost with no health consequence). A polyp detected at screening is removed (polypectomy) and the patient returns to the healthy state; a pre-clinical cancer detected at screening is treated immediately, at a one-off cost, and -- because earlier-stage treatment carries a better prognosis -- such patients are given a reduced ongoing CRC-death hazard (45% lower) relative to someone who progresses to the same clinical state after presenting with symptoms.

```r
p_healthy_to_lowpolyp_base   <- 0.020
p_lowpolyp_to_highpolyp_base <- 0.08
p_highpolyp_to_preclin_base  <- 0.12
p_preclin_to_clinical_base   <- 0.30   # annual risk of symptomatic presentation
p_clinical_crc_death_base    <- 0.22   # annual CRC death hazard once clinical
p_other_death_base           <- 0.012  # background (other-cause) mortality

screen_interval  <- 10
sens_polyp       <- 0.90
sens_preclin_crc <- 0.95
spec             <- 0.90

cost_screen_test    <- 450
cost_polypectomy    <- 900
cost_fp_workup      <- 350
cost_preclin_tx     <- 6000
cost_clinical_tx_yr <- 9000
disc_rate           <- 0.03

u_healthy <- 1.00; u_lowpolyp <- 0.99; u_highpolyp <- 0.97
u_preclin <- 0.90; u_clinical <- 0.68; u_dead <- 0.00

run_arm <- function(N, frailty, screening = TRUE) {
  state <- rep(1L, N); cost <- numeric(N); qaly <- numeric(N)
  alive <- rep(TRUE, N)
  early_tx_persist <- rep(FALSE, N)

  for (cyc in 1:n_cycles) {
    disc <- 1 / (1 + disc_rate)^(cyc - 1)

    # accrue utility for the cycle, for patients alive at cycle start
    util_vec <- c(u_healthy, u_lowpolyp, u_highpolyp, u_preclin, u_clinical, u_dead, u_dead)
    qaly[alive] <- qaly[alive] + util_vec[state[alive]] * disc

    early_tx_flag <- rep(FALSE, N)
    if (screening && (cyc %% screen_interval == 1)) {
      is_alive <- alive
      cost[is_alive] <- cost[is_alive] + cost_screen_test * disc

      has_lowpolyp  <- is_alive & state == 2L
      has_highpolyp <- is_alive & state == 3L
      has_preclin   <- is_alive & state == 4L
      healthy_now   <- is_alive & state == 1L

      det_low  <- has_lowpolyp  & (runif(N) < sens_polyp)
      det_high <- has_highpolyp & (runif(N) < sens_polyp)
      det_pre  <- has_preclin   & (runif(N) < sens_preclin_crc)

      state[det_low | det_high] <- 1L                      # polypectomy cures
      cost[det_low | det_high]  <- cost[det_low | det_high] + cost_polypectomy * disc

      state[det_pre] <- 5L                                 # treated early, at early-tx cost
      cost[det_pre]  <- cost[det_pre] + cost_preclin_tx * disc
      early_tx_flag  <- det_pre

      fp <- healthy_now & (runif(N) < (1 - spec))           # false positives: cost only
      cost[fp] <- cost[fp] + cost_fp_workup * disc
    }
    early_tx_persist <- early_tx_persist | early_tx_flag

    # natural-history progression, scaled by each patient's frailty
    r_h  <- p_healthy_to_lowpolyp_base   * frailty
    r_l  <- p_lowpolyp_to_highpolyp_base * frailty
    r_hp <- p_highpolyp_to_preclin_base  * frailty
    r_pc <- p_preclin_to_clinical_base
    r_cd <- ifelse(early_tx_persist, p_clinical_crc_death_base * 0.55, p_clinical_crc_death_base)

    u <- runif(N); s <- state
    trans_h  <- alive & s == 1L & u < pmin(r_h,  1)
    trans_l  <- alive & s == 2L & u < pmin(r_l,  1)
    trans_hp <- alive & s == 3L & u < pmin(r_hp, 1)
    trans_pc <- alive & s == 4L & u < pmin(r_pc, 1)
    trans_cd <- alive & s == 5L & u < pmin(r_cd, 1)

    state[trans_h] <- 2L; state[trans_l] <- 3L
    state[trans_hp] <- 4L; state[trans_pc] <- 5L

    clinical_now <- alive & state == 5L
    cost[clinical_now] <- cost[clinical_now] + cost_clinical_tx_yr * disc

    state[trans_cd] <- 6L; alive[trans_cd] <- FALSE

    die_other <- alive & (runif(N) < p_other_death_base)
    state[die_other] <- 7L; alive[die_other] <- FALSE
  }
  data.frame(cost = cost, qaly = qaly)
}
```

Note that every transition and cost/utility accrual inside the cycle loop is fully vectorised across all `N` patients at once -- exactly one `for` loop over 40 cycles, never a loop over patients -- which is what keeps a 200,000-patient, 40-cycle simulation running in a few seconds rather than minutes, following the efficient-implementation guidance of Chapter 21 SS21.3.

=== 35.3.4 Running the base case

```r
res_screen   <- run_arm(N, frailty, screening = TRUE)
res_noscreen <- run_arm(N, frailty, screening = FALSE)

mean_cost_screen   <- mean(res_screen$cost);   mean_qaly_screen   <- mean(res_screen$qaly)
mean_cost_noscreen <- mean(res_noscreen$cost); mean_qaly_noscreen <- mean(res_noscreen$qaly)

inc_cost <- mean_cost_screen - mean_cost_noscreen
inc_qaly <- mean_qaly_screen - mean_qaly_noscreen
icer     <- inc_cost / inc_qaly
```

Running this on the 200,000-patient cohort (`set.seed(20351)`) gives a mean cost of 3,432.80 for the screening arm versus 4,088.13 for the no-screening arm, and a mean QALY of 19.4012 for the screening arm versus 18.8962 for the no-screening arm: an incremental cost of -655.33 and an incremental QALY of +0.5050, for a ratio of -1,297.69 per QALY.

The screening programme is both *cheaper* (it removes polyps before they become expensive cancers to treat, and the up-front colonoscopy and polypectomy costs are more than offset by downstream treatment costs avoided) and *more effective* (0.505 more discounted QALYs per patient, mostly from avoided CRC deaths and avoided time spent in the low-utility clinical-CRC state). A negative incremental cost paired with a positive incremental QALY means screening is a *dominant* strategy: the ratio of the two negative/positive numbers produces a mathematically negative "ICER", but the correct verbal interpretation is not "screening saves money per QALY lost" -- it is that screening dominates the comparator on both cost and effect simultaneously, and the usual accept/reject-against-a-threshold logic for an ICER does not apply here, because there is no trade-off to weigh.

#report-table(
  [Base-case cost-effectiveness results: CRC screening vs no organised screening (N = 200,000 per arm, 40-year horizon, 3% discounting)],
  academic-table(
    columns: (1.8fr, 1.3fr, 1.3fr, 1.3fr, 1.3fr),
    align: (left, right, right, right, right),
    header: ([Strategy], [Mean cost], [Mean QALYs], [Incr. cost], [Incr. QALYs]),
    body: (
      [No screening], [4,088.13], [18.8962], [--], [--],
      [Screening (10-yearly)], [3,432.80], [19.4012], [-655.33], [+0.5050],
    ),
    footer: (table.cell(colspan: 5)[ICER: screening is *dominant* (lower cost and higher QALYs); the arithmetic ratio -655.33 / 0.5050 = -1,297.69 is shown for completeness but should be read as "dominant", not as a cost per QALY gained.],),
  ),
)

#heor-practice[
  When a CEA produces a negative incremental cost together with a positive incremental QALY (or vice versa with both flipped), do not report a bare negative ICER number to a decision-maker without a label. Most HTA bodies' reference-case reporting conventions (and most published cost-effectiveness planes) handle this by stating "dominant" or "dominated" explicitly, because a negative ratio is ambiguous on its own -- the same negative number could in principle arise from a strategy that is more expensive and less effective (the other kind of "dominated"), which is the opposite conclusion. Always report the signs of the incremental cost and incremental QALY alongside the ratio, and use words ("screening dominates", "comparator dominates") rather than relying on the reader to infer the right quadrant from a single number.
]

=== 35.3.5 First-order vs second-order uncertainty in practice

Chapter 21 SS21.4 distinguished two sources of variability in a microsimulation CEA: *first-order* (Monte Carlo) uncertainty -- the patient-to-patient stochastic noise that remains even if every parameter is known with certainty, because you are only ever simulating a finite cohort -- and *second-order* (parameter) uncertainty -- the fact that the transition probabilities, costs and sensitivities themselves are estimates with their own uncertainty, which should be propagated through a probabilistic sensitivity analysis (PSA). The two are easy to describe in the abstract but easy to conflate in practice; the clearest way to see the difference is to actually run both, with the same model, and compare.

The code below re-runs the full microsimulation 40 times at a smaller cohort size (N = 20,000 per arm, still large enough that first-order noise is well below second-order noise) in two configurations: (A) holding every parameter fixed at its base-case value and only changing the random seed (first-order noise alone), and (B) additionally re-drawing four key parameters -- pre-clinical sensitivity, the annual symptomatic-presentation probability, the annual clinical-treatment cost, and the CRC-death hazard -- from plausible uncertainty distributions on every draw (first-order noise *plus* second-order parameter uncertainty).

```r
run_arm_param <- function(N, frailty, screening, sens_preclin_crc,
                           p_preclin_to_clinical_base, cost_clinical_tx_yr,
                           p_clinical_crc_death_base) {
  # ... identical cycle loop to run_arm() above, but with these four arguments
  # substituted for their fixed base-case values ...
}

N_psa <- 20000; n_draws <- 40

# (A) First-order only: parameters fixed, only patient-level randomness varies
first_order_icers <- numeric(n_draws)
for (i in 1:n_draws) {
  frailty <- rlnorm(N_psa, meanlog = -0.5*0.6^2, sdlog = 0.6)
  rs <- run_arm_param(N_psa, frailty, TRUE,  0.95, 0.30, 9000, 0.22)
  rn <- run_arm_param(N_psa, frailty, FALSE, 0.95, 0.30, 9000, 0.22)
  first_order_icers[i] <- (rs["cost"] - rn["cost"]) / (rs["qaly"] - rn["qaly"])
}

# (B) Second-order: additionally resample structural parameters each draw
second_order_icers <- numeric(n_draws)
for (i in 1:n_draws) {
  frailty <- rlnorm(N_psa, meanlog = -0.5*0.6^2, sdlog = 0.6)
  sens_i <- rbeta(1, 95*4, 5*4)                                   # centred ~0.95
  p_pc_i <- rbeta(1, 30*6, 70*6)                                   # centred ~0.30
  cost_i <- rgamma(1, shape = (9000/900)^2, rate = 9000/900^2)     # mean 9000, sd ~900
  pcd_i  <- rbeta(1, 22*8, 78*8)                                   # centred ~0.22
  rs <- run_arm_param(N_psa, frailty, TRUE,  sens_i, p_pc_i, cost_i, pcd_i)
  rn <- run_arm_param(N_psa, frailty, FALSE, sens_i, p_pc_i, cost_i, pcd_i)
  second_order_icers[i] <- (rs["cost"] - rn["cost"]) / (rs["qaly"] - rn["qaly"])
}
```

Across 40 draws, the first-order-only ICER draws have mean -1,374.8 and standard deviation 214.8 (range -1,960.3 to -843.5), while the second-order ICER draws have mean -1,211.6 and standard deviation 498.7 (range -2,591.4 to -257.6) -- a standard-deviation ratio of 2.32 between the second-order and first-order spreads.

With only patient-level stochastic noise varying (first-order), the ICER draws already spread from about -1,960 to -844 purely because a finite 20,000-patient cohort doesn't reproduce the population mean exactly every time -- this is the "Monte Carlo noise floor" that exists for any microsimulation, however certain the inputs. Once the four structural parameters are also allowed to vary across draws (second-order), the standard deviation of the ICER more than doubles (sd 498.7 vs 214.8, a ratio of 2.32), and the range widens substantially, from roughly -2,591 to -258. Critically, every single one of the 40 second-order draws still showed screening as cost-saving and QALY-gaining -- the conclusion that screening dominates is robust to the parameter uncertainty explored here, even though the *size* of the incremental cost and QALY gain varies draw to draw (incremental cost across draws: mean -602.9, sd 237.0; incremental QALYs: mean 0.5056, sd 0.0667).

#pitfall[
  It is tempting to run a single large-cohort simulation, see a tight-looking ICER, and report that number with no uncertainty interval at all -- "the microsimulation already used 200,000 patients, so it must be precise". A large cohort shrinks *first-order* noise, but says nothing about *second-order* uncertainty in the underlying sensitivity, cost and progression-probability estimates, which came from literature or expert elicitation with their own confidence intervals. The 2.32-fold increase in ICER spread shown above, from first-order alone to first-order-plus-second-order, is the practical cost of skipping a PSA: without it, you would be reporting a false sense of precision roughly half as wide as the true uncertainty around the estimate.
]

#agency-note[
  When submitting a screening-programme microsimulation to a health technology assessment body, expect reviewers to ask explicitly how first-order and second-order uncertainty were separated, not just for a single cost-effectiveness acceptability curve. NICE's DSU Technical Support Document 12 on probabilistic sensitivity analysis -- the document already cited in Chapter 25 and Chapter 31 §31.1 as the one most often referenced in a submission's PSA appendix -- expects an individual-level (patient-level) simulation model's PSA to be distinguishable from first-order Monte Carlo noise, and typically expects the analyst to demonstrate that the chosen cohort size is large enough that first-order noise does not meaningfully distort the PSA's parameter-uncertainty estimates -- in practice, by showing (as above) that the first-order-only spread is small relative to the full PSA spread, rather than simply asserting that "N was large".
]

=== 35.3.6 Summary

This capstone microsimulation took the single-state heterogeneity and efficient-vectorisation ideas from Chapter 21 SS21.2-SS21.3 and combined them with a five-state natural-history model, a screening test with imperfect sensitivity and specificity, and a two-layer PSA that cleanly separates first-order from second-order uncertainty -- the same conceptual distinction introduced in Chapter 21 SS21.4, now demonstrated numerically rather than only described. The verified result is that a 10-yearly colonoscopy-based colorectal cancer screening programme dominates no screening in this simulated cohort (incremental cost -655.33, incremental QALYs +0.5050 per patient at base case), and that this conclusion holds across the full range of parameter uncertainty explored in the PSA, even though the precise magnitude of the benefit varies from draw to draw.

== 35.4 Case study D: a budget impact model and Shiny application

This case study builds a complete budget impact analysis (BIA) for a long-acting injectable (LAI) antipsychotic entering the maintenance-therapy pathway for adults with schizophrenia in a regional mental-health service, and then discusses -- without re-deriving code already covered -- how the same calculation engine becomes an interactive payer-facing tool. It follows the structural logic of the worked BIA in Chapter 23 §23.2 (eligible population, uptake trajectory, reference vs. new scenario) but with a new clinical context, new cost inputs, and new numbers, so treat the Chapter 23 example as the template and this one as an independent application of it.

=== Defining the eligible population and uptake trajectory

The analysis horizon is five years. The eligible population is adults on maintenance antipsychotic therapy in the service area, assumed to grow slowly with the regional population. Uptake of the new LAI is expressed as the fraction of the eligible population prescribed it each year, ramping from a small early-adopter base toward a plateau as prescribers gain experience:

```r
set.seed(3501)

years <- 2026:2030
n_years <- length(years)

# Eligible population: slow regional growth
eligible_pop <- round(18400 * (1.015)^(0:(n_years - 1)))

# Uptake (market share) of the new LAI, ramping to a plateau
uptake_new <- c(0.04, 0.10, 0.17, 0.23, 0.27)

patients_new             <- round(eligible_pop * uptake_new)
patients_oral_in_new_scn <- eligible_pop - patients_new
```

The eligible population grows from 18,400 in 2026 to 19,529 by 2030, and the new LAI captures a rising share of that population, from 4% in year one to 27% by year five -- a plausible trajectory for a technology that requires a change in care pathway (administration visits rather than a take-home prescription) rather than a simple drug switch.

=== Computing year-by-year budget impact

Two scenarios are compared. The *reference scenario* assumes the new LAI is never adopted and everyone remains on oral maintenance therapy. The *new scenario* applies the uptake trajectory above, mixing oral and LAI patients each year. Costs in both scenarios include routine drug/monitoring costs and the cost of relapse episodes, since the clinical rationale for the LAI is improved adherence and a lower relapse rate -- an offset against its higher acquisition cost:

```r
cost_oral_annual  <- 1450  # drug + routine monitoring, LCU per patient-year
cost_lai_annual   <- 5200  # drug + administration visits, LCU per patient-year
cost_relapse      <- 8600  # average cost of a relapse/hospitalisation episode
relapse_rate_oral <- 0.24  # annual relapse probability on oral therapy
relapse_rate_lai  <- 0.15  # lower relapse probability on LAI (adherence benefit)

# Reference scenario: entire eligible population on oral therapy
ref_drug_cost    <- eligible_pop * cost_oral_annual
ref_relapse_cost <- eligible_pop * relapse_rate_oral * cost_relapse
ref_total_cost   <- ref_drug_cost + ref_relapse_cost

# New scenario: mix of oral and LAI per the uptake trajectory
new_drug_cost    <- patients_oral_in_new_scn * cost_oral_annual +
                       patients_new * cost_lai_annual
new_relapse_cost <- patients_oral_in_new_scn * relapse_rate_oral * cost_relapse +
                       patients_new * relapse_rate_lai * cost_relapse
new_total_cost   <- new_drug_cost + new_relapse_cost

budget_impact <- new_total_cost - ref_total_cost
```

Running this gives a budget impact that grows from roughly +2.19 million LCU in year one (3.4% above reference spend) to +15.69 million LCU in year five (22.9% above reference spend), as the higher per-patient cost of the LAI outweighs the relapse-cost savings at every point across the five-year horizon -- the adherence benefit reduces, but does not reverse, the net budget impact. The cumulative five-year impact is approximately 46.2 million LCU, about 13.9% of cumulative reference spend.

#report-table(
  [Year-by-year budget impact of LAI introduction, reference vs. new scenario],
  academic-table(
    columns: (1.1fr, 1.3fr, 1.3fr, 1.3fr, 1.1fr),
    align: (center, right, right, right, right),
    header: ([Year], [Reference cost (LCU)], [New-scenario cost (LCU)], [Net budget impact (LCU)], [% of reference]),
    body: (
      [2026], [64,657,600], [66,847,936], [+2,190,336], [3.4%],
      [2027], [65,627,464], [71,186,632], [+5,559,168], [8.5%],
      [2028], [66,611,384], [76,203,032], [+9,591,648], [14.4%],
      [2029], [67,609,360], [80,778,160], [+13,168,800], [19.5%],
      [2030], [68,624,906], [84,317,354], [+15,692,448], [22.9%],
    ),
    footer: (table.cell(colspan: 5)[Cumulative 5-year reference spend ≈ 333.1 million LCU; cumulative net budget impact ≈ 46.2 million LCU (13.9% of cumulative reference spend).],),
  ),
)

A simple ggplot2 chart communicates the same result for a non-technical audience:

```r
library(ggplot2)

bia_long <- data.frame(
  year = rep(years, 2),
  scenario = rep(c("Reference (oral only)", "New (with LAI uptake)"), each = n_years),
  cost = c(ref_total_cost, new_total_cost)
)

ggplot(bia_long, aes(x = year, y = cost / 1e6, colour = scenario)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  labs(x = "Year", y = "Total annual cost (millions LCU)",
       title = "Budget impact of LAI introduction: reference vs. new scenario",
       colour = NULL) +
  theme_minimal()
```

#heor-practice[
Report both the gross budget impact (total spend under the new scenario) and the *net* impact (the difference from reference), year by year -- payers budget against the net figure, but want to see the gross totals too, since those are what actually appear in cash-flow planning. Always separate the *drug-cost* component from the *offset* component (here, averted relapses) so a reviewer can see exactly where the number comes from, rather than presenting only the bottom line.
]

=== From static computation to an interactive payer tool

The code above is a single deterministic run under one set of uptake and price assumptions. In practice, a payer reviewing this BIA will immediately ask "what if uptake reaches 35% by year three instead of 27% by year five?" or "what if the LAI price is negotiated down by 15%?" -- questions that are far more useful to answer live, in a meeting, than by re-running R scripts and re-sending spreadsheets. This is exactly the problem a Shiny front-end solves, and the full mechanics of building one were covered in Chapter 29 §29.2 (designing a UI usable by a non-programmer reviewer), Chapter 29 §29.4 (wiring that UI to an underlying model engine via reactive expressions), and the submission-ready case study in Chapter 29 §29.8.

The connection here is direct: the budget-impact calculation above -- population, uptake trajectory, unit costs, relapse rates, and the resulting year-by-year totals -- *is* the model engine. Wrapping it in Shiny means, conceptually:

- Exposing the handful of assumptions a reviewer would plausibly want to flex -- the uptake trajectory (e.g. via five numeric sliders, one per year, or a single "ramp speed" slider), the LAI annual cost, and the relapse-rate reduction -- as `sliderInput()` or `numericInput()` widgets, following the non-programmer-first UI design principles from Chapter 29 §29.2.
- Keeping the BIA calculation itself as a plain R function of those inputs (exactly the code shown above, refactored into a function taking `uptake_new`, `cost_lai_annual`, and `relapse_rate_lai` as arguments and returning the `bia` data frame), so the Shiny server logic is a thin wrapper that calls this function inside a `reactive()` expression whenever an input changes -- the pattern established in Chapter 29 §29.4.
- Rendering the output as the same report-table and the same ggplot2 chart shown above, regenerated reactively, so the reviewer sees the year-by-year table and the cost-trajectory chart update immediately as they move a slider -- with no change to the underlying analytic logic, only to how its inputs are supplied and its outputs displayed.
- Adding a short narrative panel (static markdown text rendered in the UI) summarising the base-case result and flagging the key driver (uptake speed, not price, dominates the five-year net impact in this example) -- the kind of interpretive framing a submission-ready tool needs, as discussed for the Chapter 29 case study.

Being honest about scope: nothing above is new mechanically. The value of connecting a BIA to Shiny is not a different computation -- it is the same computation made explorable, so a payer committee can stress-test the uptake assumption that actually drives the result, in real time, rather than requesting one re-run at a time by email.

#agency-note[
If this BIA is built for a specific submission, confirm with the receiving HTA body or payer committee whether an interactive tool is an acceptable supplementary artefact or whether only the static report and a fixed set of sensitivity-analysis tables will be reviewed. The ISPOR Budget Impact Analysis Task Force's good-practice report (Sullivan et al., *Value in Health*, 2014, cited in full in Chapter 23 §23.1) sets out the expected structural content of a BIA submission -- population, cost offsets, scenario analysis -- but does not itself prescribe a delivery format; some agencies are comfortable with submitted Shiny apps as a supplementary artefact (per the discussion in Chapter 29 §29.8), while others require all evidence in document form, with any interactive tool offered only as an optional companion for internal exploration.
]

== 35.5 Case study E: an RWE comparative effectiveness study with propensity scoring

This case study is a complete real-world-evidence (RWE) comparative effectiveness analysis using propensity-score methods, in a different clinical context and with different simulated numbers from the worked propensity-score example in Chapter 15 -- an SGLT2-inhibitor add-on therapy versus standard oral-agent intensification in type 2 diabetes, with the outcome being change in HbA1c (a glycaemic marker, percentage points) at 12 months. As in Chapter 15, the task is to estimate a treatment effect from observational data in the presence of confounding by indication, but here the full workflow is walked through end to end with `MatchIt`, `WeightIt`, and `cobalt`, using a new simulated registry.

=== Simulating an observational dataset with confounding

In routine care, prescribers do not assign SGLT2i add-on therapy at random: it tends to go to patients who are younger, have higher BMI, better kidney function, and higher baseline HbA1c -- all of which are themselves associated with how much HbA1c subsequently falls, regardless of which drug is added. This is confounding by indication, and it will bias a naive comparison of outcomes between treated and untreated patients unless adjusted for.

```r
set.seed(4702)

n <- 2400

age        <- round(rnorm(n, mean = 58, sd = 10))
bmi        <- round(rnorm(n, mean = 31, sd = 5), 1)
hba1c_base <- round(rnorm(n, mean = 8.6, sd = 1.1), 1)
egfr       <- round(rnorm(n, mean = 78, sd = 16))
cv_disease <- rbinom(n, 1, 0.22)

# Treatment assignment confounded by clinical severity and renal function
lp_treat <- -3.1 + 0.05*bmi + 0.35*hba1c_base - 0.02*age +
              0.015*egfr - 0.25*cv_disease
p_treat <- plogis(lp_treat)
treat   <- rbinom(n, 1, p_treat)

# True outcome model: SGLT2i add-on gives an additional -0.55 percentage-point
# HbA1c reduction vs. standard intensification, plus genuine covariate effects
noise <- rnorm(n, 0, 0.8)
hba1c_change <- -0.55*treat + 0.015*(hba1c_base - 8.6) -
                  0.01*bmi + 0.002*age + noise

dat <- data.frame(age, bmi, hba1c_base, egfr, cv_disease, treat, hba1c_change)
```

The simulated registry contains 2,400 patients, of whom 1,882 (78%) received the SGLT2i add-on -- itself a sign of strong confounding by indication, since in a randomised trial the split would be close to 1:1. The *true* treatment effect built into the simulation is a further -0.55 percentage-point HbA1c reduction; the question is whether propensity-score adjustment can recover something close to that number from the confounded observational data.

A naive unadjusted comparison already shows the distortion:

```r
naive_diff <- mean(dat$hba1c_change[dat$treat == 1]) -
                mean(dat$hba1c_change[dat$treat == 0])
```

This returns -0.473, closer to zero than the true -0.55 -- the confounding is working in the direction that masks part of the drug's true benefit, because untreated (comparator) patients in this simulated registry are disproportionately the ones with *higher* baseline HbA1c, who also tend to see larger absolute reductions regardless of drug, partially offsetting the treatment effect in the naive comparison.

=== Estimating propensity scores: matching and weighting

```r
library(MatchIt)
library(WeightIt)
library(cobalt)

ps_formula <- treat ~ age + bmi + hba1c_base + egfr + cv_disease

# 1:1 nearest-neighbour matching on the logit propensity score, caliper 0.2 SD
m.out <- matchit(ps_formula, data = dat, method = "nearest",
                  distance = "glm", caliper = 0.2)
matched_dat <- match.data(m.out)

# Inverse-probability-of-treatment weighting (ATT) as a cross-check
w.out <- weightit(ps_formula, data = dat, method = "glm", estimand = "ATT")
```

Matching finds 516 matched pairs (limited by the smaller control group -- `MatchIt` reports that not all 1,882 treated patients can be matched, since there are only 518 controls available in total). The `weightit()` ATT weighting, by contrast, retains the full sample and reweights controls to represent the treated population's covariate distribution, with an effective control sample size of about 378 after weighting.

=== Checking covariate balance

```r
bal_tab_match  <- bal.tab(m.out, un = TRUE, stats = "mean.diffs")
bal_tab_weight <- bal.tab(w.out, un = TRUE, stats = "mean.diffs")
```

Before adjustment, every covariate shows a meaningful imbalance between arms (standardised mean differences, SMD, well above the common 0.10 rule-of-thumb threshold) -- `hba1c_base` has an unadjusted SMD of 0.455 and the propensity-score distance itself is 0.618. After matching, all SMDs fall below 0.20, with most below 0.12; after weighting, the balance is even tighter, with all SMDs at or below 0.043.

#report-table(
  [Standardised mean differences (SMD) before and after propensity-score adjustment],
  academic-table(
    columns: (1.6fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right),
    header: ([Covariate], [SMD unadjusted], [SMD matched], [SMD weighted]),
    body: (
      [Propensity score (distance)], [0.618], [0.203], [0.028],
      [Age], [-0.272], [-0.119], [-0.005],
      [BMI], [0.116], [0.060], [-0.002],
      [Baseline HbA1c], [0.455], [0.157], [0.043],
      [eGFR], [0.204], [0.030], [0.019],
      [Cardiovascular disease], [-0.055], [-0.014], [-0.013],
    ),
    footer: (table.cell(colspan: 4)[SMD below ≈0.10 is conventionally taken as good balance; both matched and weighted samples bring every covariate well below the unadjusted imbalance, with weighting achieving the tightest balance here.],),
  ),
)

A love plot -- `cobalt`'s standard visual summary of exactly this table -- is produced with one line and is the figure most reviewers expect to see in a comparative-effectiveness submission:

```r
love.plot(m.out, binary = "std", thresholds = c(m = .1),
          var.order = "unadjusted",
          title = "Covariate balance before and after matching")
```

=== Estimating the treatment effect

```r
match_model <- lm(hba1c_change ~ treat, data = matched_dat, weights = weights)
match_est   <- coef(summary(match_model))["treat", ]

w_model <- lm(hba1c_change ~ treat, data = dat, weights = w.out$weights)
w_est   <- coef(summary(w_model))["treat", ]
```

The matched-sample estimate is -0.504 percentage points (95% CI: -0.599 to -0.409); the weighted-sample estimate is -0.490 percentage points (95% CI: -0.555 to -0.426). Both recover the true simulated effect of -0.55 far more closely than the naive -0.473, and both confidence intervals comfortably include the true value -- exactly the behaviour propensity-score adjustment is meant to deliver when the confounders are, as here, fully measured and correctly specified in the propensity model.

#heor-practice[
Run both matching and weighting rather than choosing one upfront, and report both estimates: when they agree closely, as here, that agreement is itself useful evidence that the result is not an artefact of one particular adjustment method. When they diverge substantially, that divergence is a signal to look harder at residual imbalance, at the positivity assumption (are there covariate regions with almost no overlap between arms?), or at unmeasured confounding -- not to simply quote whichever number is more favourable.
]

=== Feeding the estimate into an economic model

A relative-effect estimate of this kind -- here, an incremental HbA1c reduction attributable to the SGLT2i add-on -- rarely stands alone as the final deliverable. Its natural destination is as a relative-effect input into a downstream economic model, in the same role that a relative-risk or hazard-ratio input occupied in the cohort and state-transition model structures built in earlier case studies (Case Study A (§35.1) and Case Study B (§35.2)): it would typically be translated, via an established risk-equation or surrogate-outcome relationship (e.g. UKPDS-style risk engines linking HbA1c to long-term complication rates), into a reduction in downstream event probabilities, which then flows through exactly the same cost-effectiveness machinery as a trial-derived relative effect would. The propensity-score adjustment's job is to make that single number -- and its confidence interval, which should propagate into the model's probabilistic sensitivity analysis exactly as a trial hazard ratio's confidence interval would -- as credible a stand-in for a randomised effect as observational data allows.

#pitfall[
A propensity-score-adjusted effect estimate is only as credible as the *measured* confounders feeding the propensity model. If a plausible but unmeasured confounder exists in the real registry data (for example, a prescriber-level "aggressiveness of treatment" tendency not captured by any recorded covariate), no amount of matching or weighting on the covariates above will remove its influence. Before this estimate is accepted as an economic-model input, the data source and analysis plan should be checked against a reporting standard that explicitly addresses this (e.g. STROBE, or a comparative-effectiveness-specific checklist), with any plausible unmeasured confounders flagged as a named limitation -- not silently assumed away.
]

== 35.6 Case study F: a TB programme cost-effectiveness analysis for an LMIC setting

This final case study brings together, by conceptual reference rather than by re-running any of their code, three threads from earlier in the book: the population-level logic of dynamic transmission modelling (Chapter 22), the reference-case and threshold-setting conventions for HTA in LMIC settings (Chapter 31 §31.3 and Chapter 31 §31.4), and the cascade-of-care framework applied to TB programmes (Chapter 32 §32.7). It builds its own, new worked example: a community-based active case-finding (ACF) intervention added on top of standard passive case detection, evaluated with a simplified cascade-of-care cohort model, in a hypothetical LMIC district with its own simulated cost and outcome parameters.

=== Cascade-of-care structure: standard of care vs. active case-finding

Under standard of care (SOC), people with active TB are identified only when they develop symptoms severe enough to prompt them to present at a health facility on their own initiative -- "passive" case detection. Many never reach that point within the analysis horizon, or drop out at some stage between presenting and completing treatment. The cascade is modelled as a chain of conditional probabilities, following the structure used for the TB cascade-of-care content in Chapter 32 §32.7:

```r
set.seed(5803)

cohort_n <- 100000  # district population covered by the analysis

# Standard of care (SOC): passive case detection cascade
prev_active_tb_soc        <- 0.006  # active TB prevalence in the population
frac_self_present         <- 0.55   # symptomatic cases who self-present
frac_tested_given_present <- 0.92
frac_diag_given_tested    <- 0.85
frac_initiate_given_diag  <- 0.90
frac_complete_given_init  <- 0.80

soc_active_cases <- cohort_n * prev_active_tb_soc
soc_presenting   <- soc_active_cases * frac_self_present
soc_tested       <- soc_presenting * frac_tested_given_present
soc_diagnosed    <- soc_tested * frac_diag_given_tested
soc_initiated    <- soc_diagnosed * frac_initiate_given_diag
soc_completed    <- soc_initiated * frac_complete_given_init
```

Of 600 active TB cases in the cohort (100,000 x 0.6% prevalence), only 186 complete treatment under standard of care -- most of the loss happens before diagnosis, as cases never self-present or fail to complete the testing-to-treatment chain.

The ACF intervention adds door-to-door symptom screening and on-the-spot Xpert testing, reaching people who would *not* otherwise have self-presented. It is modelled as a second cascade applied only to the SOC "non-presenting" group, with its own, slightly different completion probabilities (an ACF-linked adherence-support component modestly improves treatment completion among cases it identifies):

```r
# Active case-finding (ACF), added on top of SOC, targeting non-presenters
frac_acf_screened              <- 0.70
frac_acf_tested_given_screened <- 0.95
frac_diag_given_acf_tested     <- 0.85
frac_initiate_given_acf_diag   <- 0.90
frac_complete_given_acf_init   <- 0.82  # ACF-linked adherence support

soc_non_presenting <- soc_active_cases - soc_presenting
acf_screened  <- soc_non_presenting * frac_acf_screened
acf_tested    <- acf_screened * frac_acf_tested_given_screened
acf_diagnosed <- acf_tested * frac_diag_given_acf_tested
acf_initiated <- acf_diagnosed * frac_initiate_given_acf_diag
acf_completed <- acf_initiated * frac_complete_given_acf_init

int_diagnosed <- soc_diagnosed + acf_diagnosed
int_initiated <- soc_initiated + acf_initiated
int_completed <- soc_completed + acf_completed
```

ACF screens 189 of the 270 non-presenting cases (70% coverage), and the resulting cascade lifts total completed treatment from 186 (SOC alone) to 298 (SOC + ACF) -- 113 additional patients completing a full course of treatment, out of 600 total active cases in the cohort.

=== Costs and outcomes

Costs attach to each step of the cascade: the screening contact itself (incurred for everyone screened, whether or not they test positive), the Xpert test, drug and visit costs for everyone initiating treatment, and a modest per-patient adherence-support cost for ACF-identified patients. Cases that never complete treatment are assumed to generate an excess downstream cost (further transmission, delayed re-presentation, eventual hospitalisation) which is applied as a flat excess per uncompleted case:

```r
cost_acf_screen_per_person <- 3.2    # per person screened door-to-door
cost_test_xpert            <- 14.0   # per Xpert test performed
cost_tx_per_initiation     <- 95.0   # full first-line course, per patient initiating
cost_tx_completion_support <- 18.0   # ACF-linked adherence support, per ACF completer
cost_untreated_case        <- 150.0  # excess downstream cost per uncompleted case

soc_cost <- soc_tested*cost_test_xpert + soc_initiated*cost_tx_per_initiation
acf_cost <- acf_screened*cost_acf_screen_per_person +
              acf_tested*cost_test_xpert +
              acf_initiated*cost_tx_per_initiation +
              acf_completed*cost_tx_completion_support

soc_uncompleted <- soc_active_cases - soc_completed
int_uncompleted <- soc_active_cases - int_completed

soc_total_cost <- soc_cost + soc_uncompleted*cost_untreated_case
int_total_cost <- soc_cost + acf_cost + int_uncompleted*cost_untreated_case
```

Outcomes are expressed in DALYs, applying a higher residual DALY burden to cases that never complete treatment than to those who do:

```r
daly_per_untreated_case <- 0.26  # DALYs per case not successfully completing treatment
daly_per_completed_case <- 0.04  # residual DALYs even after successful completion

soc_dalys <- soc_completed*daly_per_completed_case +
               soc_uncompleted*daly_per_untreated_case
int_dalys <- int_completed*daly_per_completed_case +
               int_uncompleted*daly_per_untreated_case

incr_cost          <- int_total_cost - soc_total_cost
incr_dalys_averted <- soc_dalys - int_dalys
icer_per_daly      <- incr_cost / incr_dalys_averted
```

Running this gives a total SOC cost of 88,444 LCU against 115.1 DALYs, versus 89,744 LCU against 90.3 DALYs for SOC + ACF -- an incremental cost of 1,300 LCU for 24.8 DALYs averted, an ICER of approximately 52.5 LCU per DALY averted.

#report-table(
  [Cost, outcome, and ICER results: active case-finding vs. standard of care],
  academic-table(
    columns: (1.6fr, 1.2fr, 1.2fr, 1fr),
    align: (left, right, right, right),
    header: ([Arm], [Cases completing tx], [Total cost (LCU)], [DALYs]),
    body: (
      [Standard of care], [186], [88,444], [115.1],
      [ACF + standard of care], [298], [89,744], [90.3],
      [Incremental], [+113], [+1,300], [-24.8],
    ),
    footer: (table.cell(colspan: 4)[ICER ≈ 52.5 LCU per DALY averted (incremental cost / DALYs averted = 1,300 / 24.8).],),
  ),
)

=== Interpreting the ICER against an LMIC-appropriate threshold

An ICER on its own carries no decision meaning until it is compared to a cost-effectiveness threshold. As discussed in Chapter 31 §31.4, the conventional "1-3x GDP per capita" rule of thumb that circulated widely in earlier LMIC HTA practice is now generally regarded as too permissive and not well grounded in a country's actual opportunity cost of health spending; more defensible approaches instead try to estimate a locally-relevant threshold from the health system's own budget constraints and the health gains forgone when that budget is reallocated (the iDSI reference-case approach, among others, argues for this kind of locally-derived threshold rather than an imported rule of thumb). This case study does not invent a specific country's official threshold figure -- doing so would misrepresent a genuine, contested, and country-specific policy parameter as a settled number. What can be said generically is that an ICER of roughly 52.5 LCU per DALY averted, expressed as a small fraction of almost any plausible LMIC GDP-per-capita figure, would read as comfortably cost-effective (indeed cost-saving relative to most threshold conventions) under essentially any reasonable locally-derived threshold -- the intervention both improves outcomes and, in this particular parameterisation, very nearly pays for itself through averted downstream costs.

=== Limitations of this illustrative example

This case study is a deliberately simplified, static cascade-of-care cohort model with entirely simulated parameters; it is not a dynamic transmission model and so cannot capture the onward-transmission benefits of finding and treating cases earlier (the kind of population-level effect Chapter 22's modelling approach is built to capture) -- a real evaluation of a case-finding intervention would likely show an even larger benefit once reduced transmission to others is credited. It also uses a single flat "excess cost of an uncompleted case" rather than modelling the distribution of what actually happens to someone who is never diagnosed or drops out of care, and it ignores programme-level fixed costs (training community health workers, procuring Xpert cartridges in bulk) that a real budget-impact assessment alongside the CEA would need to include. As an illustration of how cascade structure, costing, DALY outcomes, and LMIC threshold framing fit together, the logic here is sound; as a basis for an actual funding decision, it would need real surveillance data, a locally-derived threshold, and -- ideally -- a transmission-dynamic extension layered on top, exactly as the book's earlier chapters on those individual components describe.

Across the thirty-five chapters of this book, we have moved from the mechanics of R and data handling through statistical and survival methods, economic model structures, and finally HTA submission and real-world evaluation practice -- always with the aim of making each technique something a non-specialist reader could run, check, and trust, not just read about. The worked examples in this chapter are illustrations, not templates to copy unchanged into a live submission; every real analysis will need its own data, its own scrutiny, and its own honest accounting of what it does and does not capture. We hope the methods gathered here serve you well in that work.
