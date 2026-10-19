#import "../common.typ": *

= Chapter 20. Partitioned Survival Models

Chapter 19 built a Markov cohort model from a transition matrix. It let the cohort trace evolve one cycle at a time. This chapter builds a different, equally common engine: the Partitioned Survival Model (PSM). A Markov model estimates transition probabilities between states. A PSM skips that step entirely. It reads state occupancy directly off two survival curves that are already fitted independently: progression-free survival (PFS) and overall survival (OS).

PSMs dominate oncology health technology assessment for a simple reason. PFS and OS are exactly the co-primary endpoints most oncology trials already report as Kaplan-Meier curves. Chapter 17's §17.2 model-type framework (Siebert et al., 2012, ISPOR-SMDM Task Force-3) backs this choice: when your data are two survival curves rather than a transition matrix, a PSM is the natural fit.

#learning-objectives((
  [Describe the three-state PSM structure and derive state occupancy directly from the PFS and OS survival functions, and recognise the curve-crossing structural flaw this introduces (20.1).],
  [Fit PFS and OS curves independently with `flexsurvreg()` (reusing Chapter 10's six parametric families) and combine the extrapolated curves into a state-occupancy trace (20.2).],
  [Explain treatment waning and relative-effect extrapolation as an explicit structural assumption requiring justification, grounded in NICE DSU TSD 14 (20.3).],
  [Situate `hesim`'s dedicated PSM architecture alongside a transparent custom-code alternative built from `flexsurv`'s own `summary()` method (20.4).],
  [Compare a PSM's limitations against the Chapter 19 Markov cohort model: curve crossing, fixed three-state structure, and compounding independent extrapolation uncertainty (20.5).],
  [Work a complete, independently-verified oncology cost-effectiveness analysis end-to-end using a partitioned survival structure (20.6).],
))

== 20.1 Structure and when it is appropriate

A Partitioned Survival Model (PSM) is the dominant model structure in oncology health technology assessment. A Markov model, from Chapter 19, pushes a cohort through states using a transition matrix. A PSM skips the matrix entirely. State occupancy comes straight from two survival curves, fitted independently: progression-free survival (PFS) and overall survival (OS).

The model has three health states: pre-progression (on treatment, alive, not yet progressed), post-progression (alive, progressed), and death. At any time $t$:

- $P("PFS") = S_"PFS"(t)$
- $P("Dead") = 1 - S_"OS"(t)$
- $P("Progressed") = S_"OS"(t) - S_"PFS"(t)$

No transitions are estimated or elicited. Occupancy falls straight out of the two curves. This is attractive when your data *are* two Kaplan-Meier curves -- PFS and OS, the standard co-primary endpoints in an oncology trial -- rather than a transition matrix you could sensibly fit or elicit. That is the decision rule from Section 17.2's framework: choose the model structure to match the data you actually have. In exchange for this simplicity, a PSM gives up some flexibility. A transition matrix lets you sub-divide post-progression, allow recovery, or add drug-specific adverse-event states. A PSM cannot.

#pitfall[
The post-progression occupancy formula $S_"OS"(t) - S_"PFS"(t)$ has no constraint forcing it to stay non-negative. If the OS and PFS extrapolations cross -- which happens often once you extrapolate parametric curves well past the trial's follow-up -- the model predicts a *negative* number of patients in the progressed state. This is not a coding bug to patch around; it is a structural flaw of PSMs that a proper state-transition (Markov) model cannot produce, because Markov occupancy is always a probability by construction. Always plot $S_"OS"(t) - S_"PFS"(t)$ across your full time horizon and confirm it stays non-negative before trusting a PSM's extrapolated results.
]

== 20.2 Building PSMs from survival extrapolations

Nothing new is needed to fit the curves -- this is the same `flexsurvreg()` workflow from Chapter 10, run twice: once on PFS data, once on OS data, each fitted independently across the same six standard parametric families (exponential, Weibull, log-normal, log-logistic, Gompertz, generalised gamma).

```r
library(flexsurv)

# Fit Weibull curves separately to PFS and OS data
fit_pfs <- flexsurvreg(formula = Surv(time, event) ~ 1,
                       data = pfs_data, dist = "weibull")
fit_os  <- flexsurvreg(formula = Surv(time, event) ~ 1,
                       data = os_data,  dist = "weibull")
```

Each fit is extrapolated beyond the trial's observed follow-up using `summary(fit, type = "survival", t = times)`, exactly as in Chapter 10. The only new step is combining the two extrapolated curves with the occupancy formulas from Section 20.1 above.

```r
times <- seq(0, 60, by = 1)  # months

s_pfs <- summary(fit_pfs, type = "survival", t = times)[[1]]$est
s_os  <- summary(fit_os,  type = "survival", t = times)[[1]]$est

occupancy <- data.frame(
  time         = times,
  p_pfs        = s_pfs,
  p_progressed = s_os - s_pfs,
  p_dead       = 1 - s_os
)
```

On a small synthetic dataset with PFS median ~8 months and OS median ~20 months, both Weibull fits extrapolate smoothly out to 60 months without crossing: `p_progressed` stays positive throughout, rising then slowly falling as `p_dead` grows. Check this with `min(occupancy$p_progressed) >= 0` before treating the base case as valid -- cheap insurance against the Section 20.1 pitfall.

#heor-practice[
Fit PFS and OS independently, pick the best-fitting family for each by AIC/BIC *and* clinical plausibility separately (per Chapter 10's guidance) -- do not force both curves into the same family just for tidiness. Report both fits and the crossing check in the technical appendix; reviewers increasingly ask for it.
]

== 20.3 Treatment waning and relative-effect assumptions

A second, distinct PSM pitfall sits on top of the curve-crossing problem. How far do you trust the trial's relative treatment effect once you extrapolate past the trial's own follow-up window?

A trial typically reports a hazard ratio (HR) for OS, estimated over its observed follow-up -- say, 24 months. Extrapolating the fitted intervention and comparator OS curves out to a 10- or 20-year lifetime horizon implicitly assumes something about that HR: either it holds forever ("constant relative effect"), or it changes in some specified way. Many PSM base cases silently assume the former. They fit proportional-hazards-style extrapolations with no waning, treating an untested assumption as a default rather than a choice.

A waning assumption says instead that the treatment's benefit tapers -- often linearly -- to zero over some stated number of years after the trial ends. The idea is simple: a drug's effect on survival shouldn't be assumed to outlast all biological plausibility, or the trial evidence itself. Both "no waning" and "waning" are structural assumptions about something the trial data cannot speak to directly, since by definition neither curve has follow-up out that far. Either needs explicit justification -- clinical plausibility, mechanism of action, or external long-term registry data, typically -- not just a software default.

#agency-note[
NICE DSU TSD 14 (Latimer, 2013), already cited in Chapter 10 for extrapolation method choice, speaks directly to this point. It requires analysts to justify their chosen extrapolation -- including any assumption about whether and how a treatment effect wanes after the trial period -- rather than defaulting to indefinite benefit. NICE appraisal committees have repeatedly pushed back on submissions that extrapolate a short-term HR unchanged across a lifetime horizon with no clinical rationale offered. If you cannot justify "the effect holds forever," run a waning scenario as a named structural sensitivity analysis, not an afterthought.
]

== 20.4 Modelling with `hesim`, `flexsurv` and custom code

You already have the two pieces a PSM needs. `flexsurvreg()` fits each curve (Chapter 10). `hesim` builds cohort-level economic models on top of fitted survival objects (Chapter 19). `hesim`'s own documentation describes a dedicated module for partitioned survival models. It wraps a set of fitted curves per treatment strategy and converts them into state-occupancy probabilities for costing -- the same PFS/OS-to-state-occupancy mapping from Section 20.1, handled inside `hesim`'s simulation engine instead of by hand. The exact class and constructor names in that module have changed across package versions. Rather than quote a signature that may have since been renamed, treat this as a pointer: check the current CRAN vignette for `hesim`'s PSM workflow, then wire your `flexsurvreg()` fits into it the same way you wired them into `hesim_data()` and `define_tparams()` in Chapter 19.

#agency-note[
The safest habit when a package's API for a specific feature is a moving target: fit your survival curves with the stable, well-documented `flexsurvreg()`, then check the installed package's own vignette (`vignette(package = "hesim")`) before calling anything PSM-specific, rather than trusting code you found in an older blog post.
]

For transparency -- and because a regulatory submission often wants the state-occupancy arithmetic shown in the open, not hidden inside a package's internals -- it is just as common to write the partitioned survival calculation yourself. `flexsurv` gives you the one function you need for this. `summary()` on a fitted `flexsurvreg` object, with `type = "survival"`, returns fitted survival probabilities at any vector of times.

```r
# fit_pfs, fit_os are flexsurvreg objects (Section 20.1)
psm_occupancy <- function(fit_pfs, fit_os, times) {
  s_pfs <- summary(fit_pfs, t = times, type = "survival")[[1]]$est
  s_os  <- summary(fit_os,  t = times, type = "survival")[[1]]$est
  data.frame(
    time         = times,
    p_pfs        = s_pfs,
    p_dead       = 1 - s_os,
    p_progressed = pmax(0, s_os - s_pfs)  # floor at 0: see 20.5
  )
}
```

That `pmax(0, ...)` is doing real work: it is the first line of defence against the curve-crossing problem flagged in Section 20.1, and it is the same guard you'll want inside any custom PSM code regardless of which package handles the rest.

== 20.5 Limitations compared with state-transition models

A PSM buys simplicity -- two curves per arm instead of a full transition matrix -- at a real structural cost relative to the Markov cohort models of Chapter 19.

*Curve crossing.* Section 20.1 already showed that $P("Progressed") = S_"OS"(t) - S_"PFS"(t)$ can go negative if the OS curve ever dips below the PFS curve. A Markov model's transition probabilities are estimated directly and can't produce a negative state share by construction; a PSM's two independently-fitted curves can.

#pitfall[
Curve crossing usually shows up far out in the extrapolated tail, long after the trial data ends -- exactly where you're least likely to notice it on a quick plot of the observed period. Always plot $S_"PFS"(t)$ and $S_"OS"(t)$ together across your full model horizon, not just the observed follow-up, before trusting the resulting cost and QALY totals.
]

*Fixed structure.* A PSM has exactly three states -- PFS, Progressed, Death. There is no room for the tunnel states or multiple progression lines that `heemod::define_state()` could add to a Markov model (Section 19.6). If the disease has clinically distinct second- or third-line progression states, a PSM simply cannot represent them.

*Weaker mechanistic link between arms.* A Markov model shares one transition structure. Treatment effect enters through hazard ratios on specific transitions. A PSM is different: it fits each arm's PFS and OS curves completely independently. Nothing in the model enforces consistency between arms, beyond whatever the analyst imposes -- a shared shape parameter, say, or treatment waning per NICE DSU TSD 14/21. Two separate extrapolations also means two separate sources of extrapolation uncertainty. They compound rather than cancel.

These are reasons for caution, not reasons to avoid PSMs. Oncology submissions use them constantly, because trial endpoints (PFS, OS) map directly onto the model states. But Chapter 19's §19.9 distinction between internal validation and external calibration applies here with extra force. A PSM's extrapolated tails need checking against external registry or long-term follow-up data -- a good fit to the trial's own Kaplan-Meier curve is not enough on its own. Chapter 27 returns to this validation workflow in full.

== 20.6 Worked example: an oncology CEA

Two arms, new drug vs standard of care (SOC), each with independently-fit Weibull PFS and OS curves (shape/scale chosen only to be plausible, not from a real trial):

```r
library(flexsurv)

# Weibull survival at time t: S(t) = exp(-(t/scale)^shape)
weib_S <- function(t, shape, scale) exp(-(t / scale)^shape)

arms <- list(
  soc = list(pfs = c(shape = 1.2, scale = 1.0), os = c(shape = 1.1, scale = 2.0),
             cost_pfs = 3000, cost_prog = 2000, cost_death = 1000),
  new = list(pfs = c(shape = 1.2, scale = 1.5), os = c(shape = 1.1, scale = 2.5),
             cost_pfs = 5000, cost_prog = 2000, cost_death = 1000)
)
util_pfs <- 0.75; util_prog <- 0.55
```

20 six-month cycles (10-year horizon), NICE 3.5% annual discounting applied at each cycle's midpoint, $"DF"(t) = (1+r)^(-t)$ (Section 4.6):

```r
run_arm <- function(a, n_cycles = 20, cycle_len = 0.5, r = 0.035) {
  t <- seq(0, n_cycles * cycle_len, by = cycle_len)
  s_pfs <- weib_S(t, a$pfs["shape"], a$pfs["scale"])
  s_os  <- weib_S(t, a$os["shape"],  a$os["scale"])
  p_pfs  <- s_pfs
  p_dead <- 1 - s_os
  p_prog <- pmax(0, s_os - s_pfs)

  total_cost <- 0; total_qaly <- 0
  for (i in 2:length(t)) {
    df <- (1 + r)^(-(t[i-1] + t[i]) / 2)       # mid-cycle discount factor
    avg_pfs  <- (p_pfs[i-1]  + p_pfs[i])  / 2
    avg_prog <- (p_prog[i-1] + p_prog[i]) / 2
    new_deaths <- p_dead[i] - p_dead[i-1]
    cyc_cost <- avg_pfs * a$cost_pfs + avg_prog * a$cost_prog +
                new_deaths * a$cost_death
    cyc_qaly <- (avg_pfs * util_pfs + avg_prog * util_prog) * cycle_len
    total_cost <- total_cost + cyc_cost * df
    total_qaly <- total_qaly + cyc_qaly * df
  }
  c(cost = total_cost, qaly = total_qaly)
}

res <- sapply(arms, run_arm)
res
```

Running this gives discounted lifetime cost and QALYs of £10,077.03 / 1.1875 QALYs for SOC and £18,013.61 / 1.5003 QALYs for the new drug (both independently recomputed in Python during drafting, confirming neither arm's PFS/OS extrapolation crosses over the 10-year horizon). The incremental cost is £18,013.61 minus £10,077.03 = £7,936.57, and the incremental QALY gain is 1.5003 minus 1.1875 = 0.3128, so:

$ "ICER" = 7936.57 / 0.3128 approx 25371 "£/QALY" $

#report-table(
  [Base-case discounted cost, QALYs and ICER from the synthetic oncology PSM, new drug vs standard of care (SOC)],
  academic-table(
    columns: (1.6fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Strategy*], [*Cost (£)*], [*QALYs*], [*ICER (£/QALY)*]),
    body: (
      [Standard of care], [10,077], [1.19], [--],
      [New drug], [18,014], [1.50], [25,371],
    ),
    footer: none,
  ),
) <tab-ch20-oncology-cea>

#heor-practice[
Keep the arithmetic traceable in any CEA you hand off: show cost and QALY totals per arm, the two increments, and the division that produces the ICER, exactly as above. A reviewer should be able to recompute 7936.57 divided by 0.3128 on a calculator and get your number -- if they can't, the model is the first thing they'll distrust, regardless of how defensible the clinical assumptions are.
]

Both this PSM and Chapter 19's Markov cohort model share one feature: they track the *mean* proportion of a hypothetical cohort in each state, cycle by cycle. That's enough when cost and outcomes depend only on current state. It breaks down once a patient's own history matters -- for example, cumulative treatment exposure, time already spent progression-free, or prior-line-dependent costs that no cohort-average state occupancy can capture. Chapter 21 introduces individual-level state-transition models (microsimulation) to handle exactly that case.
