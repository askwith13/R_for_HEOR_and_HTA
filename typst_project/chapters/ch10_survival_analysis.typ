#import "../common.typ": *

= Chapter 10. Survival Analysis for Economic Evaluation

#learning-objectives((
  [Fit and plot Kaplan-Meier estimates and life tables using `survival`, `ggsurvfit` and `survminer` (§10.1)],
  [Fit the six standard parametric survival distributions with `flexsurv::flexsurvreg()` (§10.2)],
  [Fit flexible, spline-based Royston-Parmar models with `flexsurv::flexsurvspline()` (§10.3)],
  [Fit mixture and non-mixture cure models with `flexsurvcure::flexsurvcure()` (§10.4)],
  [Build piecewise and landmark extrapolations that combine empirical and parametric survival (§10.5)],
  [Select an extrapolation model using AIC/BIC, visual fit, and clinical plausibility together (§10.6)],
  [Test the proportional hazards assumption with `survival::cox.zph()` and choose a non-PH alternative where needed (§10.7)],
  [Build covariate-adjusted and treatment-effect-specific survival models (§10.8)],
  [Extrapolate survival using external data, background mortality, and expert elicitation (§10.9)],
  [Model competing risks and multi-state pathways with `mstate` and `flexsurv` (§10.10)],
  [Reconstruct individual patient data from a published Kaplan-Meier curve with `IPDfromKM` (§10.11)],
  [Report survival extrapolation in line with NICE DSU TSD 14 and TSD 21 (§10.12)],
))

Chapter 9 closed by introducing `survival::survfit()` and `Surv()` for
one narrow purpose: building inverse-probability-of-censoring weights
for censored cost data. This chapter comes back to that same machinery
and builds it out properly. Here is the roadmap: start with the
model-free Kaplan-Meier curve (§10.1), move to fitting a parametric
curve so you can extrapolate beyond the trial's follow-up (§10.2-§10.6),
check and handle cases where the simple "constant hazard ratio"
assumption breaks down (§10.7-§10.9), extend to pathways with more than
one possible outcome (§10.10-§10.11), and finish with exactly what a
submission needs to report to satisfy NICE's own written guidance on
this topic (§10.12). Each section builds on the last, so read them in
order the first time through.

== 10.1 Kaplan-Meier and life tables

You already met `survival::Surv()` and `survival::survfit()` in Chapter 9, where we used them to build inverse-probability-of-censoring weights for cost data. Here we return to the same two functions for their original purpose: describing the survival experience of a cohort, non-parametrically, as the foundation everything else in this chapter builds on.

The Kaplan-Meier (KM) estimator is the step-function analogue of a life table — at each event time it recalculates the proportion of the at-risk set that survives past that instant, and multiplies these conditional probabilities together. For a TB-programme analyst this will feel familiar: it is conceptually the same bookkeeping as a programme cohort analysis, just computed at the resolution of individual event times rather than fixed intervals (6-month, 12-month cohort outcomes).

```r
library(survival)

fit <- survfit(Surv(time, status) ~ arm, data = trial_df)
summary(fit)
```

`time` is time-on-study (months, say), and `status` is the usual 1 = event, 0 = censored coding. The `~ arm` term stratifies the KM curve by treatment arm — essential in HEOR work, since the whole point is usually to compare extrapolated survival between a new intervention and a comparator.

Life tables (actuarial estimators) are the discrete-time cousin of the KM estimator — they group events into fixed intervals (e.g. each year) rather than using exact event times. `survival::survfit()` will produce an actuarial-style table if you pre-aggregate your data into interval counts, but in practice almost all HEOR survival work in R uses the exact-time KM estimator rather than classical life tables, because source trial data are individual patient data (IPD), not grouped registry counts. We mention life tables mainly so you recognise the term when it appears in NICE or HTA submission templates referring to older epidemiological methods.

For plotting, two tidyverse-friendly packages dominate: `ggsurvfit` and `survminer`.

```r
library(ggsurvfit)

survfit2(Surv(time, status) ~ arm, data = trial_df) |>
  ggsurvfit() +
  add_confidence_interval() +
  add_risktable()
```

`ggsurvfit::survfit2()` is a thin wrapper around `survival::survfit()` that keeps the formula call bundled with the plotting pipe, and `add_risktable()` gives you the number-at-risk row underneath the x-axis that every HTA reviewer expects to see.

```r
library(survminer)

ggsurvplot(fit, data = trial_df, risk.table = TRUE,
           conf.int = TRUE, pval = TRUE)
```

`survminer::ggsurvplot()` is the older, more heavily parameterised alternative — it does more in one call (log-rank p-value annotation, risk table, median survival lines) at the cost of a less ggplot2-native object if you want to customise further downstream. Either is defensible in a submission; pick one and be consistent across your analysis.

#heor-practice[
  Every HTA economic model that extrapolates survival should open with the observed KM curve, full stop — regulators and HTA reviewers (NICE DSU TSD 14, ICER reference case) expect to see the "trial period" fit visually overlaid with whatever parametric curve you eventually choose to extrapolate with, so that the point of divergence between observed and modelled survival is inspectable, not asserted.
]

#figure(
  image("../images/r_generated/ch10_trial_vs_extrapolated.png", width: 85%),
  caption: [Exactly the diagnostic the practice note above asks for: the observed Kaplan-Meier curve (black) against a chosen parametric fit (here, Gompertz), solid where it is fitted to real trial-period data and dashed where it is pure extrapolation beyond the 36-month follow-up window. The vertical dotted line marks the trial's end — everything to its right is a model assumption, not an observation, and should be labelled as such in any submission.],
) <fig-ch10-trial-extrapolation>

#pitfall[
  `survfit()` silently treats anyone not explicitly flagged `status == 1` as censored. If your event indicator was recoded upstream (e.g. a SQL extract where dead/alive was stored as `'Y'/'N'` strings and someone cast it to numeric without checking `0`/`1` directions), you can get a KM curve that is the mirror image of reality and it will not throw an error — always sanity-check with `table(trial_df$status)` and a known-rate benchmark before trusting the curve.
]

== 10.2 Parametric models

The KM curve only describes survival for as long as you have follow-up data. For a cost-effectiveness model you almost always need survival projected over a lifetime horizon, far beyond the trial's observation window — and that requires fitting a parametric distribution whose tail behaviour you can defend analytically, rather than just eyeballing where the KM curve seems to be heading.

The `flexsurv` package is the standard R workhorse for this. `flexsurv::flexsurvreg()` has the same `Surv(time, status) ~ ...` formula interface you already know, plus a `dist = ` argument selecting the parametric family:

```r
library(flexsurv)

fit_exp      <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "exp")
fit_weibull  <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "weibull")
fit_gompertz <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "gompertz")
fit_llogis   <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "llogis")
fit_lnorm    <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "lnorm")
fit_gengamma <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "gengamma")
```

Each distribution encodes a different assumption about the hazard shape over time, which is really the thing you are choosing, not the distribution name itself:

- *Exponential* (`"exp"`) — constant hazard. One parameter, almost never plausible for a chronic disease but a useful lower-bound sanity check.
- *Weibull* (`"weibull"`) — monotonically increasing or decreasing hazard, shape fixed by one parameter. Common for mortality that worsens steadily with age or disease progression.
- *Gompertz* (`"gompertz"`) — hazard that increases (or decreases) exponentially with time; a long-standing favourite for all-cause general-population mortality extrapolation.
- *Log-logistic* (`"llogis"`) — hazard can rise then fall (a hump), useful when early risk is elevated and later risk plateaus or drops.
- *Log-normal* (`"lnorm"`) — similar hump-shaped hazard behaviour to log-logistic, fitted on the log-time scale.
- *Generalised gamma* (`"gengamma"`) — a flexible three-parameter family that nests exponential, Weibull and log-normal as special cases; useful as an umbrella comparison model, at the cost of being harder to interpret and sometimes unstable to fit with sparse data.

Comparing fits is done the way you would compare any likelihood-based R models — AIC/BIC plus a visual check:

```r
AIC(fit_exp, fit_weibull, fit_gompertz, fit_llogis, fit_lnorm, fit_gengamma)

plot(fit_gompertz, main = "Gompertz fit vs KM")
```

`plot()` on a `flexsurvreg` object automatically overlays the fitted parametric curve against the KM estimate, which is the single most useful diagnostic in this whole section.

#figure(
  image("../images/r_generated/ch10_km_parametric_overlay.png", width: 85%),
  caption: [The observed Kaplan-Meier curve (black step function) overlaid with all six standard parametric families fitted via `flexsurvreg()`. Within the trial's follow-up window the fits visually cluster close to the KM curve and to each other — the divergence that matters for extrapolation only becomes visible once the curves are projected beyond the observed data (see @fig-ch10-hazard).],
) <fig-ch10-km-overlay>

#heor-practice[
  NICE DSU TSD 14 and most HTA bodies expect you to report *all six* standard parametric fits (or at minimum exponential, Weibull, Gompertz, log-logistic, log-normal, generalised gamma) with AIC/BIC tabulated side by side, plus visual and clinical-plausibility justification for whichever one is chosen for the base case — "it had the lowest AIC" is necessary but not sufficient; a model with slightly worse AIC that produces a clinically plausible long-term hazard is often preferred over one that fits the trial tail well but extrapolates implausibly (e.g. a cure-like plateau with no biological rationale).
]

#pitfall[
  AIC/BIC only tell you about fit *within the observed data range* — two distributions can have near-identical AIC on a trial with two years of follow-up and diverge wildly once extrapolated to twenty years. Always plot the extrapolated curve out to your full model time horizon (`summary(fit, t = seq(0, horizon, by = ...))`) before trusting an AIC ranking for anything beyond the trial period.
]

== 10.3 Flexible and spline-based models

The six standard parametric families in §10.2 each assume a fixed, simple hazard shape. Real disease hazards — especially in conditions with changing treatment effect over time, or where a trial's hazard shape genuinely does something unusual (e.g. a drop-off after a defined treatment-stopping point) — can need more flexibility than any single-shape parametric curve offers without overfitting the whole dataset to force it.

The Royston-Parmar spline-based survival model, implemented in R as `flexsurv::flexsurvspline()`, solves this by modelling a spline on the log-cumulative-hazard (or related) scale, with the number of "knots" controlling flexibility:

```r
library(flexsurv)

fit_spline0 <- flexsurvspline(Surv(time, status) ~ arm, data = trial_df, k = 0)
fit_spline1 <- flexsurvspline(Surv(time, status) ~ arm, data = trial_df, k = 1)
fit_spline2 <- flexsurvspline(Surv(time, status) ~ arm, data = trial_df, k = 2)
```

`k = 0` (zero internal knots) collapses to one of the standard parametric families depending on the `scale = ` argument (`"hazard"`, `"odds"` or `"normal"` — defaulting to the Weibull-equivalent on the hazard scale), so it is a useful baseline before adding flexibility. Each additional knot (`k = 1`, `k = 2`, ...) allows an extra inflection in the hazard shape, at the cost of an extra parameter to estimate and interpret.

```r
AIC(fit_spline0, fit_spline1, fit_spline2, fit_gompertz, fit_gengamma)
plot(fit_spline1, main = "1-knot spline vs KM")
```

Because splines are piecewise and fit the observed data very closely, they are excellent at reproducing the trial-period KM curve — but that closeness is exactly why extrapolation beyond the data needs extra scrutiny: a spline has no built-in assumption about what the hazard does once you run out of data, so beyond the last knot it extrapolates essentially linearly on whatever scale you chose, which can produce hazards that neither clinicians nor biology would endorse.

#heor-practice[
  Spline models are best used as a *flexibility check* on your chosen standard parametric model, not usually as the base-case extrapolation itself, unless you have strong external long-term data (registry, national life tables) to anchor the tail. A common, reviewer-friendly workflow: fit `flexsurvspline()` with one or two knots, confirm it tracks the KM curve no better than your chosen standard parametric fit *within* the trial period, and if it does track meaningfully better, investigate why (treatment-stopping rule? crossover? subgroup heterogeneity?) rather than simply swapping in the spline as the new base case.
]

#pitfall[
  More knots will always reduce AIC within the observed data — splines are flexible enough to chase noise, especially in TB-programme-style IPD with modest sample sizes and a long tail of sparse late-follow-up events. Treat any spline with `k >= 2` on anything less than a few hundred events as a plausible overfit until you've checked that the extra knot survives a visual bootstrap or sensitivity check, not just an AIC improvement.
]

#report-table(
  [How to report this: Royston-Parmar spline knot-selection comparison (`flexsurvspline()`, hazard scale) across k = 0-3 internal knots, with AIC/BIC and the within-trial-period fit improvement each extra knot buys -- the format for justifying a chosen knot count against TSD 21's expectation that knot selection be reported, not merely asserted.],
  academic-table(
    columns: (1.2fr, auto, auto, auto, auto, 1.8fr),
    align: (left, right, right, right, right, left),
    header: ([*Knots (k)*], [*Parameters*], [*-2LogLik*], [*AIC*], [*BIC*], [*Notes*]),
    body: (
      [0 (Weibull-equivalent)], [2], [799.1], [803.1], [808.5], [Baseline; equivalent to standard Weibull on the hazard scale],
      [1], [3], [793.4], [799.4], [807.1], [Captures an early hazard bend not visible in k = 0],
      [2], [4], [791.0], [799.0], [809.0], [Marginal AIC gain over k = 1; extra knot not clinically motivated],
      [3], [5], [790.1], [800.1], [812.3], [BIC increases versus k = 1-2: additional flexibility not supported by sample size],
    ),
    footer: (table.cell(colspan: 6)[*Selected:* k = 1 for the base case -- lowest BIC and the smallest model whose extra flexibility tracks a plausible early hazard change; k >= 2 shows the AIC-chasing pattern flagged in the pitfall above.],),
  ),
) <tab-ch10-spline-knots>

== 10.4 Mixture-cure and non-mixture cure models

*In plain terms first:* every model in §10.2 assumes that, eventually, everyone has the event — the survival curve always keeps falling toward zero, however slowly. But some conditions genuinely leave a fraction of patients who are, in effect, "cured": they never relapse, no matter how long you follow them. If that is true of your data, forcing an ordinary Weibull or Gompertz curve onto it is a category error — the curve will keep sliding downward long after the real data has flattened out, systematically understating long-term survival. A *cure model* fixes this by explicitly fitting two things at once: the proportion who are cured, and a separate survival curve just for the ones who are not.

Every parametric curve fitted in §10.2 — Weibull, Gompertz, log-logistic, generalised gamma — assumes that, given enough follow-up, every patient in the model eventually experiences the event. For many TB treatment outcomes that assumption is fine: everyone who survives active disease is still at risk of relapse or death indefinitely. But for some oncology indications, and arguably for a "treatment-success" endpoint sustained well beyond the biological window for TB relapse, a meaningful fraction of patients may never experience the event at all — they are statistically "cured." Ordinary parametric models forced to fit such data either underestimate the plateau (the Weibull tail keeps falling) or overestimate it (the log-logistic tail flattens for the wrong reason, as a pure curve-fitting artefact rather than a clinical one).

Cure models address this directly by estimating a *cure fraction* π — the proportion of the cohort who will never experience the event — alongside a standard parametric survival distribution for the "uncured" subgroup. The `flexsurvcure` package extends the `flexsurv` machinery from §10.2-§10.3 with exactly this structure, via `flexsurvcure::flexsurvcure()`.

#figure(
  image("../images/r_generated/ch10_cure_model_illustration.png", width: 88%),
  caption: [A simulated cohort where 25% of patients are genuinely cured. The observed Kaplan-Meier curve (black) correctly plateaus near 0.25 instead of continuing to fall. An ordinary Weibull (orange), which has no way to represent a cure fraction, keeps sliding downward and badly understates long-term survival. A mixture cure model (blue) matches the plateau because it estimates the cure fraction directly — here recovering π ≈ 0.24, close to the true simulated value of 0.25.],
) <fig-ch10-cure-model>

Two structurally different cure model families are supported, selected by the `mixture` argument:

```r
library(flexsurvcure)
library(flexsurv)
library(survival)

# Mixture cure model: S(t) = pi + (1 - pi) * S_u(t)
fit_mix <- flexsurvcure(
  Surv(time, status) ~ 1,
  data = tb_followup,
  dist = "weibull",
  mixture = TRUE
)

# Non-mixture cure model: S(t) = pi ^ (1 - S_u(t))
fit_nmix <- flexsurvcure(
  Surv(time, status) ~ 1,
  data = tb_followup,
  dist = "weibull",
  mixture = FALSE
)

fit_mix
```

In the *mixture* form, the population is an explicit blend: a cured fraction π with survival fixed at 1 forever, and an uncured fraction (1-π) following the chosen parametric distribution. This is the more clinically interpretable form for HEOR write-ups — π reads directly as "proportion cured" — and it extends naturally to covariates on both the cure fraction and the uncured-group survival:

```r
fit_mix_cov <- flexsurvcure(
  Surv(time, status) ~ arm,
  data = tb_followup,
  dist = "weibull",
  mixture = TRUE,
  anc = list(shape = ~ arm)
)
```

The *non-mixture* form arises from a different generative story (a latent number of malignant/infectious cells following a Poisson process, each with independent probability of elimination) and is more common in oncology cure-modelling traditions. Both forms nest the standard non-cure model as π → 0, so a likelihood-ratio test or AIC comparison against the corresponding plain `flexsurvreg` fit (§10.2) is a reasonable first check of whether a cure fraction is statistically supported at all.

#pitfall[
  A fitted cure fraction is a *statistical* artefact of the likelihood, not evidence of biological cure. A model will happily return a cure estimate of 0.15 purely because the observed Kaplan-Meier curve (§10.1) flattens near the end of follow-up — which is exactly what *censoring* also does. Short or administratively-censored follow-up is the single most common cause of a spuriously large cure estimate. Always check: does the KM curve's plateau extend across enough separated event-free time, with enough patients still at risk at the plateau, to distinguish "nobody left to have an event" from "these people are actually cured"? If follow-up barely exceeds the plausible window for relapse, treat any cure-model result as exploratory only.
]

#heor-practice[
  When a submission depends on a cure assumption, present the cure fraction alongside its 95% CI (`summary()` on the `flexsurvcure` object returns this) and run a one-way sensitivity analysis setting the cure fraction to zero and to the CI bounds in the economic model. Reviewers at HTA bodies (NICE, in particular, following TSD 14 guidance — see §10.12) routinely request this, and having it ready pre-empts a request for clarification that otherwise stalls appraisal.
]

#report-table(
  [How to report this: cure-fraction estimate from a mixture cure model (`flexsurvcure()`, Weibull uncured distribution), with the 95% confidence interval `summary()` returns, alongside the AIC comparison against the corresponding non-cure Weibull fit that motivates including a cure fraction at all.],
  academic-table(
    columns: (1.8fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Parameter*], [*Estimate*], [*95% CI lower*], [*95% CI upper*]),
    body: (
      [Cure fraction (pi)], [0.24], [0.17], [0.32],
      [Uncured Weibull shape], [1.42], [1.08], [1.87],
      [Uncured Weibull scale], [18.6], [14.2], [24.3],
    ),
    footer: (
      table.cell(colspan: 4)[*Model comparison*],
      [Mixture cure model AIC], [812.4], [--], [--],
      [Standard Weibull (no cure) AIC], [829.1], [--], [--],
    ),
  ),
) <tab-ch10-cure-fraction>

== 10.5 Piecewise and landmark models

*In plain terms first:* sometimes the reason one curve doesn't fit well isn't that you chose the wrong family — it's that the real hazard genuinely behaves differently in different time windows (for example, high risk during active treatment, then a much calmer surveillance phase afterwards). No single smooth curve can bend sharply enough to capture that kind of structural change without overfitting elsewhere. The practical fix, called a *landmark* approach, is almost deliberately low-tech: trust the real, observed Kaplan-Meier curve for as long as you have good data, and only hand off to a fitted parametric curve for the unobserved tail beyond that point — rather than asking one curve to explain both phases at once.

Cure models relax the *shape* assumption; piecewise models relax it in a different way, by abandoning the idea that one parametric family must hold over the entire time horizon. A piecewise (segmented) model fits different hazard or survival behaviour in separate time intervals, stitched together at one or more cut-points. This is a natural fit whenever a clinical or data-generating mechanism changes partway through follow-up — for instance, a fixed-duration TB regimen where hazard during active treatment differs structurally from hazard during the post-treatment surveillance period, or trials where hazard behaviour measured within the trial should not simply be extrapolated using whatever curve happened to win AIC (§10.6) beyond the data.

A *landmark* approach is the simplest practical version of this idea for extrapolation: fit (or simply use) the empirical Kaplan-Meier estimate for the observed trial duration, and attach a parametric extrapolation only from a chosen landmark time point onward, rather than letting one parametric curve govern both the well-observed early period and the long unobserved tail.

#figure(
  image("../images/r_generated/ch10_landmark_splice.png", width: 90%),
  caption: [A simulated trial where hazard genuinely drops after a 12-month landmark (shaded: the higher-hazard active-treatment phase). A single Weibull fitted to all the data (orange, dashed) is forced to compromise between the two phases and fits neither well. The landmark approach (blue) instead uses the real KM curve up to 12 months, then splices in a tail model fitted only to the post-landmark data — tracking the true post-landmark decline far more closely.],
) <fig-ch10-landmark>

```r
library(survival)
library(flexsurv)

landmark_time <- 24  # months; chosen where KM data becomes sparse

fit_pw <- survival::survSplit(
  Surv(time, status) ~ .,
  data = tb_followup,
  cut = landmark_time,
  episode = "period"
)

fit_pw_exp <- survival::coxph(
  Surv(tstart, time, status) ~ strata(period),
  data = fit_pw
)
```

In practice, the economic-model-facing version of a landmark approach is often simpler than fitting a formal piecewise hazard model in R: use the KM estimate directly for t ≤ landmark, then splice in a `flexsurvreg` or `flexsurvspline` fit (§10.2-§10.3) — chosen for clinical plausibility of its tail, not merely best AIC — for t > landmark. The spline models of §10.3 are a particularly natural extrapolation partner here because their flexible knot structure can be fitted to just the later portion of follow-up without distorting the early, well-observed KM shape.

```r
tail_data <- subset(tb_followup, time > landmark_time)

fit_tail <- flexsurvspline(
  Surv(time, status) ~ 1,
  data = tb_followup,
  k = 1,
  scale = "hazard"
)
```

#pitfall[
  A piecewise model with a cut-point placed wherever the hazard *happens* to look like it changes, chosen after inspecting the data, is overfitting dressed up as flexibility — the same multiple-comparisons problem as moving a regression breakpoint until $R^2$ improves. Cut-points should be pre-specified from a clinical rationale (end of a fixed treatment course, a protocol-defined visit, a known change in standard of care) wherever possible, not selected by eyeballing the KM curve for the best-looking kink.
]

#heor-practice[
  Landmark extrapolation is especially defensible — and increasingly expected by reviewers — whenever a trial's follow-up is short relative to the economic model's time horizon, since it keeps the empirical, assumption-free KM estimate (§10.1) governing exactly the period where trial data are informative, and confines parametric or spline modelling risk to the period where it is unavoidable.
]

== 10.6 Model selection: AIC/BIC, visual fit, clinical plausibility

*In plain terms first:* this section is about a single, important trap. Every statistic you can compute from a model — AIC, BIC, log-likelihood — only measures how well the curve matches the data you actually observed. It has nothing to say about the part of the curve beyond your data, even though that unobserved region is usually what drives most of an economic model's lifetime costs and QALYs. Two curves can score almost identically on AIC and still tell completely different stories about year 10 or year 20. The fix isn't a smarter statistic — it's to never trust a single number alone: always look at the extrapolated curve with your own eyes, and ask whether its long-run shape makes clinical sense.

Every model fitted across §10.2-§10.5 — standard parametric families, spline models, cure models, piecewise/landmark constructions — produces a log-likelihood, and every one of those model objects supports the base R generics directly:

```r
fits <- list(
  exp      = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "exp"),
  weibull  = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "weibull"),
  gompertz = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "gompertz"),
  llogis   = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "llogis"),
  lnorm    = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "lnorm"),
  gengamma = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "gengamma")
)

sapply(fits, AIC)
sapply(fits, BIC)
```

AIC and BIC rank goodness-of-fit *to the observed data*, penalised for the number of parameters (BIC more heavily, favouring simpler models in larger samples). They are a legitimate, necessary first filter — a model that fits the observed follow-up poorly should rarely be carried forward regardless of how convenient its extrapolated tail looks. But an information criterion says nothing about behaviour *beyond* the data, which is precisely the region that drives most of the lifetime cost and QALY impact in an economic model.

#report-table(
  [How to report this: AIC/BIC model-comparison table across the six standard parametric survival distributions fitted with `flexsurvreg()`, the TSD 14-expected candidate set and reporting format for justifying a base-case extrapolation choice.],
  academic-table(
    columns: (1.4fr, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    header: ([*Distribution*], [*Parameters*], [*-2LogLik*], [*AIC*], [*BIC*]),
    body: (
      [Exponential], [1], [812.6], [814.6], [817.3],
      [Weibull], [2], [798.2], [802.2], [807.6],
      [Gompertz], [2], [796.8], [800.8], [806.2],
      [Log-logistic], [2], [799.5], [803.5], [808.9],
      [Log-normal], [2], [801.1], [805.1], [810.5],
      [Generalised gamma], [3], [795.9], [801.9], [809.9],
    ),
    footer: (table.cell(colspan: 5)[*Gompertz selected for the base case*: lowest AIC among two-parameter families and a clinically plausible extrapolated tail; generalised gamma's marginally lower AIC did not outweigh its less stable shape-parameter estimate (§10.2).],),
  ),
) <tab-ch10-aic-bic>

#pitfall[
  Two curves can have near-identical AIC over the observed follow-up and diverge enormously once extrapolated — one flattening into a plausible long-term plateau, the other decaying to near-zero survival within a few extra years. AIC/BIC cannot distinguish between them because both explain the *observed* data equally well; the difference lives entirely in the unobserved region the criterion was never calculating over. Selecting a final extrapolation model on AIC/BIC alone is one of the most common and most criticised errors in HTA submissions.
]

#figure(
  image("../images/r_generated/ch10_aic_trap.png", width: 90%),
  caption: [A simulated 24-month trial where a Weibull and a log-normal fit the observed data almost equally well (AIC 1302.6 vs 1306.7 — a difference most analysts would call negligible). Extrapolated to a 10-year horizon (shaded region), the two curves diverge sharply: by month 120 one projects roughly 6% survival and the other under 1%. AIC alone gives no warning that this divergence is coming, because it is calculated entirely within the unshaded region.],
) <fig-ch10-aic-trap>

Two further checks are required alongside the statistical criteria, and should be treated as mandatory, not optional, for any model informing extrapolation:

- *Visual fit against the full observed follow-up.* Overlay each candidate curve on the Kaplan-Meier estimate (§10.1) across the *entire* observed period, not just a global fit statistic — look specifically for systematic departures in the region with the most patients still at risk, since that is where poor fit matters most for inference.
- *Clinical plausibility of the extrapolated tail.* Beyond the data, ask whether the shape is biologically defensible: does a Gompertz tail imply an implausibly rapid late-life hazard escalation for this population? Does a cure-model fraction (§10.4) correspond to a mechanism (e.g. durable bacteriological clearance) that a clinician would recognise, or is it just where the likelihood happened to settle? Plot each candidate's extrapolated survival against the full economic-model time horizon and sanity-check the implied long-term survival or life-years against external epidemiological data or clinical opinion.

```r
plot(fits$weibull, type = "survival")
lines(survfit(Surv(time, status) ~ 1, data = tb_followup), col = "grey40")

plot(fits$gompertz, type = "survival", t = seq(0, 240, by = 1))
```

This three-part discipline — statistical fit (AIC/BIC), visual fit, and clinical plausibility of the tail — is the core of the NICE DSU Technical Support Document 14 (Latimer, 2013) guidance on survival extrapolation, still the reference standard cited by most HTA bodies. §10.12 returns to this guidance in full detail, including external-data validation and expert-elicitation approaches to tail plausibility; the practical takeaway here is simply that no single number from `AIC()` should ever be the sole basis for choosing an extrapolation model.

#heor-practice[
  Build the habit of reporting all three elements together for every extrapolation choice in a submission: an AIC/BIC table across candidate models, a KM-overlay plot across observed follow-up, and a long-horizon extrapolation plot with a short clinical-plausibility justification for the chosen tail. This triad is close to a checklist item in NICE technical engagement, and assembling it alongside model-fitting — rather than retrofitting it after a model is already locked into the economic model — saves substantial rework later.
]

#agency-note[
  For a TB programme specifically, "clinical plausibility of the tail" has a concrete anchor: published TB relapse-hazard literature and programme surveillance data give an external benchmark for what a defensible long-term hazard or cure fraction looks like. Treat any model whose extrapolated tail falls well outside that external range as a candidate to be interrogated, not adopted, however well it scores on AIC.
]

== 10.7 Proportional hazards diagnostics and non-PH alternatives

Chapter 10's Cox models (via `survival::coxph()`) and the parametric curves fitted with `flexsurv::flexsurvreg()` in §10.2 share a hidden assumption whenever a treatment or covariate effect is expressed as a single hazard ratio: that the ratio of hazards between arms stays constant for the whole follow-up period. This is sometimes called the proportional hazards (PH) assumption. In an economic model this assumption is load-bearing — it is usually what licenses stretching a trial's within-trial hazard ratio across a lifetime horizon. If the assumption is wrong, the extrapolated incremental QALYs and costs inherit that error, often invisibly.

=== Testing the proportional hazards assumption

`survival::cox.zph()` tests whether the scaled Schoenfeld residuals from a fitted `coxph()` model are correlated with time. Under PH, residuals for a covariate should fluctuate randomly around zero; a trend indicates a time-varying effect.

```r
library(survival)

cox_fit <- coxph(Surv(time, status) ~ arm + age + ecog_ps, data = os_data)
zph_test <- cox.zph(cox_fit)
zph_test
plot(zph_test, var = "arm")
```

A significant global or `arm`-specific p-value (conventionally < 0.05) is evidence against PH for that term. The accompanying plot shows the estimated log hazard ratio against time; a flat line supports PH, a clear slope does not.

#pitfall[
  A non-significant `cox.zph()` test is not proof of PH — it is merely absence of evidence, and the test has low power in small or heavily censored trials (exactly the oncology trials HEOR models often rely on). Conversely, with very large samples, trivial and clinically irrelevant time-trends can reach significance. Always pair the test with the Schoenfeld residual plot and clinical judgement about mechanism (e.g. a new treatment with delayed onset, or diminishing effect as resistance emerges) before deciding PH is tenable.
]

#report-table(
  [How to report this: `cox.zph()` proportional-hazards diagnostics for a Cox model of treatment arm, age and ECOG performance status -- the conventional format for presenting per-covariate and global Schoenfeld-residual test statistics alongside the PH decision each motivates.],
  academic-table(
    columns: (1.4fr, auto, auto, auto, 1.6fr),
    align: (left, right, right, right, left),
    header: ([*Term*], [*chi-square*], [*df*], [*p-value*], [*PH decision*]),
    body: (
      [arm], [1.2], [1], [0.27], [Supported -- no evidence of a time-varying treatment effect],
      [age], [0.4], [1], [0.53], [Supported],
      [`ecog_ps`], [7.8], [1], [0.005], [Rejected -- effect of ECOG status changes materially over follow-up],
      [GLOBAL], [9.1], [3], [0.028], [Rejected overall -- a non-PH alternative structure is warranted (see below)],
    ),
    footer: (table.cell(colspan: 5)[*Model:* `coxph(Surv(time, status) ~ arm + age + ecog_ps)`; global rejection driven by `ecog_ps`, motivating the AFT or spline-based non-PH alternatives discussed next.],),
  ),
) <tab-ch10-cox-zph>

=== When PH fails: alternative hazard structures

If PH is rejected, three broad options replace the single hazard ratio:

- *Piecewise/time-varying hazard ratio* — fit `coxph()` with a time-dependent covariate (e.g. via `survival::survSplit()` to cut follow-up into intervals and interact `arm` with interval), yielding a stepped hazard ratio rather than a constant one.
- *Accelerated failure time (AFT) models* — `flexsurv::flexsurvreg()` with `dist = "weibull"`, `"llogis"`, or `"lnorm"` from §10.2 are AFT forms: treatment rescales survival *time* rather than multiplying the hazard, which can fit crossing or converging survival curves that PH cannot.
- *Flexible spline-based hazards* — `flexsurv::flexsurvspline()` allows the treatment effect to enter on the hazard, odds, or normal scale with splines on the baseline, directly relaxing PH while remaining a parametric, extrapolable model.

```r
library(flexsurv)

aft_weibull <- flexsurvreg(
  Surv(time, status) ~ arm,
  data = os_data,
  dist = "weibull"
)

spline_fit <- flexsurvspline(
  Surv(time, status) ~ arm,
  data = os_data,
  k = 1,
  scale = "hazard"
)
```

#heor-practice[
  NICE's DSU TSD 14 (survival analysis for economic evaluation) treats PH testing as a mandatory first step before any extrapolation, and expects submissions that reject PH to justify the alternative structural choice clinically, not just statistically. In a reimbursement submission, present `cox.zph()` output and the Schoenfeld plot alongside the chosen non-PH model as part of the base-case justification, not as a sensitivity analysis afterthought.
]

== 10.8 Covariate-adjusted and treatment-effect-specific models

Economic models rarely want a single marginal survival curve per arm; they want the curve for a population defined by baseline covariates (age, stage, biomarker status) and sometimes a treatment effect that itself depends on those covariates. Building on the `flexsurvreg()` syntax from §10.2, covariates enter through the familiar formula interface — but *where* they enter (location, scale, or shape of the distribution) changes what the model can represent.

=== Covariates on the location/scale parameter

By default, `flexsurvreg()` places covariates on the main location parameter of the chosen distribution (the rate for exponential, the scale for Weibull, etc.), which is the AFT-style adjustment used throughout §10.2.

```r
adj_weibull <- flexsurvreg(
  Surv(time, status) ~ arm + age + ecog_ps,
  data = os_data,
  dist = "weibull"
)
```

This yields a single estimated treatment effect, held constant across the covariate distribution — adequate when the question is "what survival curve for a patient of average age and ECOG status," but it cannot represent a treatment effect that differs by subgroup.

=== Covariates on ancillary (shape) parameters

`flexsurvreg()`'s `anc` argument attaches covariates to a distribution's ancillary parameter (e.g. the shape of a Weibull or Gompertz, the sigma of a log-normal), letting a covariate change the *shape* of the hazard trajectory rather than only its scale.

```r
shape_fit <- flexsurvreg(
  Surv(time, status) ~ arm,
  anc = list(shape = ~ arm),
  data = os_data,
  dist = "weibull"
)
```

Here `arm` enters both the scale (via the main formula) and the shape (via `anc`), allowing treatment to alter not just how long patients survive but whether the hazard is increasing, decreasing, or constant over time — a natural way to express mechanisms like "early benefit that fades" without abandoning a parametric, extrapolable family.

#pitfall[
  Adding covariates to ancillary parameters multiplies the number of estimated coefficients quickly, and with trial-sized samples (hundreds, not thousands) the shape-parameter estimates can become unstable even when the model converges. Check standard errors and confidence intervals on the `anc` coefficients specifically — a wide interval on a shape-by-treatment interaction is a sign the data cannot support that extra flexibility, however appealing the fit statistic.
]

=== Treatment-effect-specific extrapolation

Once a covariate-adjusted model is fitted, `summary()` on the `flexsurvreg` object with a `newdata` argument produces arm- and covariate-specific survival curves directly, which feed into the Markov or partitioned-survival model exactly as the unadjusted curves did in §10.2-10.5.

```r
newdat <- data.frame(arm = c("control", "treatment"), age = 60, ecog_ps = 1)
summary(shape_fit, newdata = newdat, t = seq(0, 60, by = 1), type = "survival")
```

#heor-practice[
  Decide before fitting whether the economic question is population-average (one curve per arm) or subgroup-specific (curves varying by baseline covariates): this determines whether `anc` and interaction terms belong in the base case or in a scenario analysis. Reviewers increasingly expect covariate-adjusted analyses when a trial shows baseline imbalance between arms, since an unadjusted hazard ratio can then be confounded rather than purely a treatment effect.
]

== 10.9 Extrapolation: external data, background mortality, expert elicitation

Trials report follow-up measured in months; reimbursement decisions are made on lifetime horizons. Every model in this chapter — from the single `flexsurvreg()` fit in §10.2 to the non-PH alternatives in §10.7 — eventually has to answer a question the trial data cannot answer alone: what happens to the survival curve beyond the last observed event. Three complementary tools manage that gap: external data, background mortality, and structured expert elicitation.

=== Anchoring with external data

Where available, longer-follow-up data from a related trial, a registry, or a published meta-analysis can validate or recalibrate the tail of an extrapolated curve. The common workflow is to source external Kaplan-Meier data, read it in exactly as any other tabular data (`readr::read_csv()`, per Ch.5), and overlay it against the within-trial parametric fit visually and via landmark survival comparisons (e.g. does the model's 5-year survival estimate sit near the external estimate) rather than formally refitting the trial model to pooled data.

```r
library(readr)
library(dplyr)

external_km <- read_csv("registry_survival_5yr.csv")

model_est <- summary(aft_weibull, t = 60, type = "survival")[[1]]
external_est <- external_km |> filter(time_months == 60)

bind_rows(model = model_est, external = external_est)
```

=== Background mortality as a plausibility bound

§8.5 introduced layering age- and sex-matched general-population mortality beneath disease-specific mortality once the disease-specific hazard falls below the general-population hazard — the standard device for making sure a chronic-disease model does not extrapolate a disease-specific survival curve indefinitely below what a healthy member of the same population would experience. In extrapolation, that convention becomes a *constraint*, not just a modelling convenience: a national life table (read in as plain CSV/Excel via `readr::read_csv()` or `readxl::read_excel()`, per Ch.5) sets the ceiling on hazard, so predicted survival should never fall below the general-population curve for the matching age-sex strata.

```r
library(readr)
library(dplyr)

life_table <- read_csv("national_life_table.csv")  # age, sex, qx (annual mortality prob.)

disease_hazard <- -log(1 - 0.08)
bg_hazard <- life_table |>
  filter(age == 70, sex == "female") |>
  pull(qx) |>
  (\(qx) -log(1 - qx))()

combined_hazard <- pmax(disease_hazard, bg_hazard)
combined_hazard
```

#agency-note[
  Treat this the same way Ch.8 §8.5 did: compute background mortality on the same timescale (annual vs monthly) as the disease-specific hazard before comparing or combining them, and apply the comparison at every model cycle, not just at the point where extrapolation begins — a disease hazard that dips below background mortality transiently (not just permanently at the tail) still needs the floor applied at that cycle.
]

#pitfall[
  A parametric curve with a poorly chosen tail shape (e.g. a log-normal or log-logistic fitted mainly to capture early-curve flexibility) can imply a long-term hazard that *decreases* with age, eventually crossing below general-population survival — biologically implausible for almost any serious disease. Plot the extrapolated curve against the life-table curve over the full model horizon as a standard diagnostic, not an edge-case check; NICE DSU TSD 14 reviewers routinely flag curves that cross.
]

=== Expert elicitation for structural and tail uncertainty

When neither longer trial follow-up nor comparable external data exist — common for recently approved treatments with short median follow-up — formal expert elicitation offers a way to quantify uncertainty about the extrapolated tail (e.g. long-term treatment-effect waning, cure fraction plausibility) that is defensible rather than ad hoc. The SHELF (SHeffield ELicitation Framework) protocol is the most widely used approach in HTA submissions for eliciting probability distributions from clinical experts on quantities like long-term survival proportions; it is covered in full in Ch.14 §14.7, including how elicited distributions are encoded as priors or scenario inputs. For now, the point to carry forward is structural: expert elicitation does not replace the parametric or external-data analysis above, it supplements it — typically by bounding or re-weighting extrapolation scenarios ("optimistic," "base-case," "pessimistic" tail assumptions) that are then propagated through the probabilistic sensitivity analysis built on the survival models of this chapter.

#heor-practice[
  Build the extrapolation case as a layered argument, not a single curve: (1) the best-fitting parametric or spline model from §10.2-10.8, (2) a background-mortality floor from §8.5's convention, (3) a cross-check against any available external data, and (4) where tail uncertainty remains material to the decision, a structured elicitation exercise (Ch.14 §14.7) to characterise that uncertainty rather than asserting a single point estimate. Submissions that show all four elements together are markedly more resilient under HTA committee scrutiny than a single AIC-selected curve.
]

== 10.10 Competing risks and multi-state models

Every extrapolation so far in this chapter — §10.2's parametric distributions, §10.9's extrapolation workflow — has treated the clinical course as one single transition: alive to dead, or progression-free to progressed. Many HEOR models need more states than that. Picture a TB treatment-pathway model tracking *treatment success*, *loss to follow-up*, *treatment failure/retreatment*, and *death*. Loss to follow-up competes with cure for who "claims" a patient first, and retreatment is itself a transition with its own hazard. A standard Kaplan-Meier or single-event parametric fit mishandles this silently: if you censor a patient at a competing event (instead of modelling that event explicitly), you bias the cumulative incidence of the event you actually care about — usually inflating it.

Two R packages work together to handle this: `mstate` for the data-management and semi-parametric multi-state machinery, and `flexsurv` for fitting parametric or flexible distributions to each transition separately — exactly what a multi-state cost-effectiveness model needs for extrapolation.

=== Competing risks: cause-specific vs. subdistribution hazards

With competing risks, there are at least two legitimate hazard concepts, and they answer different questions:

- The *cause-specific hazard* treats competing events as censoring and asks "among patients still at risk of this event, what's the instantaneous rate?" It is the right quantity for understanding aetiology/mechanism.
- The *subdistribution hazard* (Fine-Gray) keeps patients who experienced the competing event in the risk set (as if destined never to have the event of interest) and directly models the *cumulative incidence function* (CIF) — the probability of this event by time t in the presence of competing risks. This is usually the quantity a cost-effectiveness model wants, because the model needs the actual probability mass flowing into each state, not a hypothetical hazard in a world where competing events don't happen.

#pitfall[
  Censoring competing events in a standard Kaplan-Meier fit produces a cumulative incidence estimate that is *too high* — treating a competing event as censoring systematically overstates the true probability of the event of interest when competing risks are non-trivial. This is the single most common competing-risks error in submitted HTA models: a "time to loss-to-follow-up" curve fitted by censoring deaths will overestimate loss-to-follow-up, because dead patients can no longer be lost to follow-up but a censoring-based estimator treats them as still "at risk" and still eligible to drop out indefinitely. Always check whether competing events were censored or modelled when critiquing a submitted dossier's multi-state structure.
]

=== Data preparation and fitting with `mstate`

`mstate` works from a *transition matrix* describing the permitted moves between states, and converts standard long-format survival data into the stacked "msdata" format multi-state models require.

```r
library(mstate)
library(survival)

tmat <- transMat(
  x = list(
    c(2, 4),     # from Treatment success: to Failure, or Death
    c(3, 4),     # from Failure: to Retreatment, or Death
    c(4),        # from Retreatment: to Death
    c()          # Death is absorbing
  ),
  names = c("TxSuccess", "Failure", "Retreat", "Death")
)

msdat <- msprep(
  time  = cbind(tx_success_time, failure_time, retreat_time, death_time),
  status = cbind(tx_success_status, failure_status, retreat_status, death_status),
  data  = tb_cohort,
  trans = tmat
)

cox_trans <- coxph(Surv(Tstart, Tstop, status) ~ strata(trans), data = msdat)
msf <- msfit(cox_trans, trans = tmat)
```

`msprep()` is doing the unglamorous but essential work: for every patient and every transition they were at risk of, it creates a row with a start time, stop time, and event indicator, in the "counting process" format `coxph()` expects when combined with `Surv(Tstart, Tstop, status)`. `msfit()` then assembles the fitted cumulative hazards per transition into the full set of transition probabilities — the quantity that actually populates a multi-state Markov cohort model's transition-probability matrix.

=== Parametric extrapolation of transition-specific hazards with `flexsurv`

`mstate`'s default Cox-based fitting is semi-parametric and does not extrapolate beyond the observed follow-up — exactly the gap §10.9 was built to fill for single-event models. The natural extension is to fit `flexsurvreg()` (§10.2's workhorse) separately to each transition's data, by subsetting the `msdata` object on `trans` and fitting the usual parametric families:

```r
library(flexsurv)

transition_fits <- lapply(1:3, function(k) {
  flexsurvreg(
    Surv(Tstart, Tstop, status) ~ 1,
    data = subset(msdat, trans == k),
    dist = "weibull"
  )
})
```

Each `transition_fits[[k]]` can then be extrapolated exactly as in §10.9, and the resulting transition-specific survival curves assembled into a cohort trace — this is precisely how a multi-state partitioned-survival economic model is extrapolated in practice: fit and select a distribution *per transition*, not one global curve for the whole pathway.

#heor-practice[
  Decide the multi-state structure from the clinical pathway *before* reaching for `mstate` syntax. A model with "Death" reachable from every intermediate state is almost always right for chronic or infectious disease pathways (nobody is protected from dying by being mid-treatment) — map every edge in `transMat()` against a clinician-validated pathway diagram, not just the transitions that happen to appear in the trial dataset.
]

== 10.11 Reconstructing individual patient data from published Kaplan-Meier curves

Submitted HTA evidence frequently gives you a published trial's Kaplan-Meier *curve* as a figure, with a risk table beneath it, but not the underlying patient-level survival times — the original IPD may sit behind a confidentiality wall at the manufacturer, or the publication predates routine IPD sharing. Yet §10.2's parametric fitting and §10.9's extrapolation both need IPD (or something that behaves like it) as their input. The standard solution is the algorithm of Guyot, Ades, Ouwens and Welton (2012, *BMC Medical Research Methodology*), implemented in the `IPDfromKM` package, which reconstructs an approximate patient-level dataset directly from a digitized KM curve plus its risk table.

=== The Guyot et al. (2012) reconstruction algorithm

The algorithm's logic is a clever inversion of how a KM curve is built in the first place:

+ *Digitize* the published curve: read off (t, S(t)) coordinate pairs at a fine grid of points along the printed curve (typically using plot-digitizing software or manual pixel-coordinate extraction).
+ Read the *numbers-at-risk table* printed beneath the curve at its labelled time points — this is the critical extra ingredient the original KM figure alone does not give you, because it anchors how many individuals are being censored versus experiencing events between risk-table intervals.
+ Use the risk-table counts together with the digitized S(t) step heights to back-solve, interval by interval, for the number of events and the number of censorings consistent with the observed drop in S(t) — effectively running the Kaplan-Meier product-limit formula in reverse.
+ Output a reconstructed dataset of individual (time, event/censor) records that, when a KM curve is refitted to them, closely reproduces the original published curve.

The reconstruction is necessarily approximate — it cannot recover information the published curve never contained (exact censoring times within an interval are allocated by an assumed-uniform rule, for instance) — but it has become the de facto accepted method in HTA submissions for enabling parametric extrapolation when only published curves are available.

=== Using `IPDfromKM`

```r
library(IPDfromKM)

# Step 1: digitize the curve (coordinates read from the published figure,
# e.g. via a digitizer such as WebPlotDigitizer or Engauge)
preprocessed <- getpoints(
  dat     = digitized_coordinates,
  tot.events = NULL,
  trisk   = risk_table_times,
  nrisk.data = risk_table_numbers
)

# Step 2: getIPD() runs the Guyot et al. algorithm to back-calculate
# individual event/censoring times consistent with both the digitized
# curve and the risk table
reconstructed <- getIPD(
  prep    = preprocessed,
  armID   = 1,
  tot.events = NULL
)

ipd_fit <- flexsurv::flexsurvreg(
  survival::Surv(time, status) ~ 1,
  data = reconstructed$IPD,
  dist = "weibull"
)
```

Exact argument names vary slightly by `IPDfromKM` version — consult `?getpoints` and `?getIPD` in your installed version before relying on a specific call signature; the purpose and overall two-step workflow (digitize-and-anchor, then back-calculate) is stable across versions.

#pitfall[
  Reconstructed IPD is a statistical approximation layered on top of an already-approximate digitization step. Two failure modes recur in practice: (1) mis-reading the risk-table time points so they don't align with the digitized curve's x-axis grid, which silently corrupts the back-calculated event counts for every later interval; and (2) over-trusting the reconstructed tail — KM curves are read least precisely in their sparse, high-censoring right tail, which is exactly the region §10.9's extrapolation choice is most sensitive to. Always refit a KM curve to the reconstructed IPD and visually overlay it on the original published figure before using the reconstruction for anything downstream.
]

#heor-practice[
  Treat IPD reconstruction as a documented, auditable step in its own right, not an invisible preprocessing detail. Record the digitizing software, the coordinate-extraction screenshots, and the risk-table transcription alongside the reconstructed dataset, because a NICE committee or external assessment group reviewing your submission will often want to independently verify that the reconstruction matches the original publication's curve.
]

== 10.12 Reporting extrapolation following NICE DSU TSD 14 and 21

#agency-note[
  Everything built across this chapter — the parametric family in §10.2, the Royston-Parmar spline models of §10.3, the cure models of §10.4, the statistical-and-clinical-plausibility selection logic of §10.6, and the extrapolation mechanics of §10.9 — exists because two specific NICE Decision Support Unit Technical Support Documents spell out what UK (and, by wide adoption, international) HTA bodies expect to see when a submission extrapolates trial-observed survival beyond the data. Chapter 2 of this book flagged that this chapter would need to cite them properly; here is the substance, not just the citation.

  *NICE DSU TSD 14 — "Survival Analysis for Economic Evaluations Alongside Clinical Trials: Extrapolation with Patient-Level Data"* (Latimer, 2011, updated 2013) is the foundational document. In plain terms, it asks for four things:
  - Fit the standard parametric survival distributions — exponential, Weibull, Gompertz, log-logistic, log-normal, and the generalised gamma — exactly the family fitted with `flexsurvreg()` in §10.2. TSD 14 is the reason this particular set of six distributions is the default candidate list in essentially every UK submission.
  - *Test the proportional hazards assumption* before committing to a PH-based extrapolation structure, because an extrapolation built on an unjustified PH assumption carries that error across the whole modelled time horizon.
  - Use a visual and statistical model-selection toolkit together: inspect hazard and log-cumulative-hazard plots against each candidate distribution's theoretical shape, alongside AIC/BIC — the same diagnostics §10.6 walked through in code.
  - Justify the final choice on statistical fit *and* clinical plausibility together, which is the central principle TSD 14 states and §10.6 of this chapter echoes in applied form: a distribution that fits the observed Kaplan-Meier curve best is not automatically the right choice if its extrapolated tail implies a hazard shape (e.g. a declining hazard of death many years out) that no clinician would endorse for the disease in question.

  *NICE DSU TSD 21 — "Flexible Methods for Survival Analysis"* (Rutherford, Lambert, et al.) is the newer document. It exists because TSD 14's standard six-distribution family can be too restrictive for real trial data — proportional-hazards or fixed-shape-hazard assumptions often fail, especially with modern trials showing treatment-effect waning, delayed separation of arms, or crossing hazards. TSD 21 extends TSD 14's logic in two ways:
  - It covers *flexible spline-based models* — specifically Royston-Parmar models (§10.3's `flexsurvspline()`) — which relax the fixed-hazard-shape constraint of the standard family by modelling the log-cumulative-hazard as a spline function of log time, with the number and placement of knots as explicit, reportable choices.
  - It covers *cure models* (§10.4's mixture and non-mixture cure fits), for disease areas where a meaningful fraction of the treated population may be effectively cured and face only background mortality thereafter — a structural assumption none of TSD 14's six distributions can represent, since none of them has a "cured fraction" parameter.
  - TSD 21 is also explicit that flexible methods trade the standard family's extrapolation parsimony for better in-sample fit, and that this trade-off itself needs reporting: a spline model with many knots can fit the observed KM curve closely while behaving erratically once extrapolated past the data, so TSD 21 asks for the extrapolated hazard function to be shown, not just the extrapolated survival curve.

  #figure(
    image("../images/r_generated/ch10_extrapolated_hazard_plot.png", width: 85%),
    caption: [The extrapolated hazard function for a standard Weibull fit versus a one-knot Royston-Parmar spline, fitted to the same simulated trial data. The two curves track closely within the observed 0-36 month follow-up window but diverge sharply once extrapolated — exactly the TSD 21 diagnostic that an extrapolated survival-scale plot alone would hide.],
  ) <fig-ch10-hazard>

  Put simply, a submission report built from this chapter's methods should contain: the candidate distribution set and a reason for including or excluding flexible/cure-model alternatives; the proportional-hazards diagnostic; visual fit plots (KM overlay, hazard plot) for every candidate; an AIC/BIC table; a clinical-plausibility narrative for the selected model's extrapolated tail, ideally benchmarked against external data (population life tables, disease registries); and, where a spline or cure model is used, explicit justification for the knot count/placement or the cure-fraction assumption. A reviewer who knows TSD 14/21 will look for each of these elements by name — fitting six distributions, reporting AIC, and picking the lowest AIC without a clinical-plausibility and extrapolated-hazard discussion will not satisfy either document's stated expectations, however clean the R code behind it was.
]

#pitfall[
  TSD 14 and TSD 21 are frequently cited in submissions as a bibliography entry without the actual diagnostics being reported — an AIC table alone does not constitute compliance with either document. Reviewers for NICE and other HTA bodies increasingly ask explicitly for the proportional-hazards check and the extrapolated-hazard-function plot (not just the survival curve), because these are the two diagnostics TSD 14 and TSD 21 respectively treat as mandatory, not optional, components of a defensible extrapolation.
]
