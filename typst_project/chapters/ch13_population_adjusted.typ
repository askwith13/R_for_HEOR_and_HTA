#import "../common.typ": *

= Chapter 13. Population-Adjusted Indirect Comparisons

Chapter 12 closed with a warning: network meta-regression is data-hungry. It only adjusts for imbalance at the *study* level, using trial-arm covariate means as a coarse proxy for patient-level differences. This chapter takes up exactly that gap.

Picture the situation this way. One trial in your evidence base hands you individual patient data (IPD) under a data-sharing agreement. The comparator trial exists to you only as a published table of aggregate data (AgD). You suspect the two trial populations differ on covariates that *change the size of the treatment effect itself* — not just covariates that shift outcomes up or down by the same amount in both arms. That is exactly when population-adjustment methods become necessary.

This chapter covers three methods, in order of increasing data demand: matching-adjusted indirect comparison (MAIC, §13.2) and simulated treatment comparison (STC, §13.3) — both two-trial methods — then multilevel network meta-regression (ML-NMR, §13.4), which extends the same idea to a full network. The chapter closes with NICE DSU TSD 18 (§13.5), the single most important agency reference governing all three methods.

#learning-objectives((
  [Distinguish an effect modifier from a pure prognostic factor, and explain why only the former biases an anchored indirect comparison under covariate imbalance],
  [Explain when population adjustment is needed instead of, or in addition to, standard anchored indirect comparison (Bucher/NMA, Chapter 12)],
  [Implement a basic matching-adjusted indirect comparison (MAIC) in R: estimate odds-weights via method of moments, compute effective sample size (ESS), and fit a weighted Cox model for time-to-event outcomes],
  [Explain why a large ESS loss after MAIC weighting is a credibility concern that must be reported, not a cosmetic detail],
  [Contrast MAIC's weighting-model assumption with simulated treatment comparison's (STC) outcome-regression-model assumption, and explain the non-collapsibility pitfall that threatens STC on nonlinear outcome scales],
  [Describe how multilevel network meta-regression (ML-NMR) generalises STC's logic to a full network of IPD and AgD-only trials via numerical integration over each AgD trial's reported covariate distribution, using the `multinma` package introduced in Chapter 12],
  [State NICE DSU TSD 18's core requirements for a population-adjusted submission: prespecified effect modifiers, covariate-balance reporting, ESS reporting, and its stated method preference ordering],
  [Explain why an unanchored population-adjusted comparison carries materially higher risk of bias from unmeasured confounding than an anchored one, and why it should be a last resort],
))

== 13.1 When population adjustment is needed

Chapter 12 closed with a warning worth repeating before we go further: standard network meta-regression is data-hungry. In practice it adjusts for covariate imbalance only at the *study* level, using trial-arm means as proxies for patient-level confounding and effect modification. That is a coarse instrument. Sometimes the trials you actually have won't cooperate with even that: one trial hands you full individual patient data (IPD) under a data-sharing agreement, while the comparator trial(s) exist to you only as a published table of aggregate data (AgD). Ecological regression on study-level covariates is often not possible in that situation, and even when it is, it is fragile.

This is the precise situation population-adjustment methods are built for: _one IPD trial, one or more AgD trials, connected through a common comparator, with a real concern that effect modifiers are distributed differently across the trial populations._ If the trials' populations are similar enough on anything that matters, ordinary anchored indirect comparison — Bucher's method or the NMA machinery of Chapter 12 — remains the right tool, and it is more efficient and more transparent than anything in this chapter. Population adjustment is a response to imbalance, not a default upgrade.

The methodological fork in the road is the distinction between _effect modifiers_ and _prognostic factors_, and getting it right is not a technicality — it determines whether MAIC or STC is justified at all, and which covariates belong in the adjustment.

- A _prognostic factor_ predicts outcome risk regardless of treatment: it shifts outcomes up or down in both arms more or less equally. Baseline disease severity, for instance, often predicts worse outcomes whether a patient is on the active drug or the comparator.
- An _effect modifier_ changes the *relative* treatment effect itself: the treatment works differently (not just outcomes differently) depending on the covariate's value. Biomarker status that predicts a larger drug benefit in biomarker-positive patients is a classic effect modifier.

For an _anchored_ comparison (both trials share a common comparator arm, and we are estimating a relative effect via that anchor), imbalance in pure prognostic factors across the two trial populations cancels out in the within-trial contrast — it does not bias the indirect comparison, because prognostic effects are differenced away on each side of the anchor before the two relative effects are compared. Imbalance in *effect modifiers*, by contrast, does not cancel: if the IPD trial's population has a different effect-modifier distribution than the AgD trial's population, the two trials' relative treatment effects are not estimating the same quantity, and the ordinary indirect comparison is biased. Population adjustment exists specifically to re-weight or re-model the IPD trial so that its effect-modifier distribution matches the AgD trial's, before the relative effect is computed.

#pitfall[
  A common and costly error is to throw every available baseline covariate into the matching or outcome-regression model — age, sex, disease duration, biomarker status, prior therapies — on the reasoning that "more adjustment is more rigorous." It is the opposite. Adjusting for a pure prognostic factor that is *not* an effect modifier does nothing for bias and only burns effective sample size (see §13.2) and inflates variance. Worse, for an _unanchored_ comparison (single-arm or no shared comparator), the prognostic/effect-modifier distinction collapses — *all* prognostic factors and effect modifiers must be balanced, because there is no within-trial differencing to cancel prognostic imbalance. Decide the anchor status and the covariate roles (ideally pre-specified with clinical input, not chosen post hoc by which variables happen to "improve" the result) before fitting anything.
]

The two workhorse methods for this setting — matching-adjusted indirect comparison (MAIC) and simulated treatment comparison (STC) — differ in *how* they re-express the IPD trial in the AgD trial's population: one reweights patients, the other reshapes a regression model. We take each in turn.

== 13.2 Matching-adjusted indirect comparison (MAIC)

MAIC reweights the IPD-trial patients so that the *weighted* IPD population's covariate moments — typically the means, occasionally also variances for continuous covariates — match the moments reported in the AgD trial's publication (usually just means and sometimes SDs, since that is all an aggregate table ever gives you). The weights are not arbitrary: they come from a logistic-regression-style propensity model fit by method of moments, so that the resulting population looks, on the matched covariates, like the comparator trial's population.

#shiny-app-box("maic_weight_ess_explorer", [Drag how far the IPD trial's covariates sit from the AgD trial's targets and watch MAIC weights, effective sample size, and the weighted treatment effect update live.])

_The weighting mechanism._ For each matched covariate $x_j$, define the IPD patient's covariate vector centered on the AgD trial's reported mean: $z_i = x_i - bar(x)^"AgD"$. MAIC assigns each IPD patient $i$ an odds-weight
$ w_i = exp(z_i^T alpha) $
where $alpha$ is chosen so that the weighted means of $z$ in the IPD data are exactly zero — i.e., the weighted IPD sample's covariate means equal the AgD trial's reported means. This is a method-of-moments problem solved by minimizing a convex objective (the method is numerically identical to calibrating a logistic propensity score without ever observing the AgD patients' outcomes or covariates individually — only their published moments are needed).

```r
# Toy MAIC weight estimation via method of moments
# x: matrix of IPD covariates to match (e.g., age, baseline severity)
# target_means: named vector of AgD-trial reported means for the same covariates

Q <- function(alpha, z) {
  # z = x - target_means, centered IPD covariates
  sum(exp(z %*% alpha))
}

z <- scale(ipd[, c("age", "severity")], center = target_means, scale = FALSE)

fit <- optim(
  par = rep(0, ncol(z)),
  fn  = Q,
  z   = z,
  method = "BFGS"
)

alpha_hat <- fit$par
w <- exp(z %*% alpha_hat)        # odds-weights, one per IPD patient
w <- w / mean(w)                  # optional rescaling, mean weight = 1
```

#report-table(
  [Baseline covariate balance between the IPD trial and the AgD trial, before and after MAIC odds-weighting],
  academic-table(
    columns: (1.6fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Covariate*], [*IPD, unweighted*], [*IPD, MAIC-weighted*], [*AgD trial (target)*]),
    body: (
      [Age, years (mean)], [58.2], [61.4], [61.4],
      [Baseline ECOG status $gt.eq$ 1, %], [42], [55], [55],
      [Prior-therapy count (mean)], [1.3], [2.1], [2.1],
    ),
    footer: (table.cell(colspan: 4)[After weighting, the IPD sample's matched covariate means equal the AgD trial's reported means by construction (method-of-moments calibration); any covariate omitted from the matching set is not guaranteed to balance and should be checked separately.],),
  ),
) <tab-ch13-maic-covariate-balance>

#figure(
  image("../images/r_generated/ch13_maic_love_plot.png", width: 85%),
  caption: [A love plot of the same covariate balance shown in @tab-ch13-maic-covariate-balance: absolute standardized mean differences between the IPD trial and the AgD trial's reported target, before (red) and after (green) MAIC odds-weighting. By construction, MAIC drives every matched covariate's SMD to exactly zero — the diagnostic that matters is whether any *unmatched* effect modifier remains imbalanced. SMDs computed against illustrative typical-scale standard deviations for each covariate type, since the chapter's worked example reports only means, not SDs.]
) <fig-ch13-maic-love-plot>

_Effective sample size (ESS)._ Reweighting trades bias reduction for a loss of precision, and that loss must be quantified and reported, not buried in a supplementary table. The standard diagnostic is
$ "ESS" = (sum_i w_i)^2 / sum_i w_i^2 $
which answers "how many *unweighted* patients would given this much statistical information?" A MAIC that starts with $N=400$ IPD patients but produces $"ESS" = 120$ has thrown away roughly 70% of its effective information — a real quality-of-evidence red flag. A large ESS drop usually signals that the IPD and AgD populations barely overlap on the matched covariates, that a few patients are carrying almost all the weight, and that the resulting estimate's confidence interval will be much wider (and its extrapolation much less trustworthy) than the nominal sample size would suggest. Reviewers and HTA bodies expect ESS reported alongside the original N for exactly this reason.

```r
ess <- sum(w)^2 / sum(w^2)
ess
```

#heor-practice[
  Suppose an IPD trial of 400 patients is matched to an AgD trial on two effect modifiers: baseline ECOG status and prior-therapy count. After solving for the odds-weights, 15 patients at the extreme ends of the covariate distributions receive weights 8–12 times the mean weight, while the bulk of patients are weighted near zero. Plugging the resulting weights into the ESS formula gives $(sum w_i)^2/sum w_i^2 approx 120$. The matched comparison should be reported with both numbers side by side — "IPD N = 400, ESS = 120 (30%)" — so a reviewer can immediately gauge how much of the original trial's information survived the reweighting, rather than comparing standard errors for the matched analysis on a seemingly unchanged 400-patient footing.
]

#report-table(
  [Effective sample size before and after MAIC weighting (illustrative 400-patient IPD trial matched on two effect modifiers)],
  academic-table(
    columns: (1.6fr, auto, auto),
    align: (left, right, right),
    header: ([*Quantity*], [*Value*], [*% of unweighted N*]),
    body: (
      [IPD sample size, N (unweighted)], [400], [100%],
      [Effective sample size, ESS (MAIC-weighted)], [120], [30%],
    ),
    footer: (table.cell(colspan: 3)[Report ESS alongside the raw N in every MAIC analysis; an ESS this far below N signals that a small number of extreme weights are driving the matched estimate and that its confidence interval will be wider than the nominal N suggests.],),
  ),
) <tab-ch13-maic-ess>

_Time-to-event outcomes._ MAIC's reweighting logic extends directly to survival outcomes by using the odds-weights $w_i$ as case weights in a weighted Kaplan–Meier curve and a weighted Cox model — no new estimation machinery is needed, only weighted versions of the usual estimators.

```r
library(survival)

# Weighted Cox model using MAIC odds-weights as case weights
cox_fit <- coxph(
  Surv(time, event) ~ treatment,
  data    = ipd,
  weights = w          # odds-weights from the MAIC step above
)

summary(cox_fit)

# Weighted Kaplan-Meier for the matched IPD population
km_fit <- survfit(Surv(time, event) ~ treatment, data = ipd, weights = w)
```

Robust (sandwich-type) standard errors are typically preferred over the naive weighted-Cox standard errors here, since the weights are themselves estimated quantities and ordinary Cox variance formulas do not account for that extra uncertainty; `coxph()` with `cluster()` or a bootstrap over the full weight-estimation-plus-outcome-model pipeline are the usual fixes, and this is worth flagging explicitly in any write-up.

#difficult-terminology("robust (sandwich-type) standard errors")[
A standard error tells you how much a parameter estimate would bounce around if you repeated the study; the usual formula for calculating it assumes the model's error structure is exactly right. "Robust" or "sandwich-type" standard errors are a way of calculating that same uncertainty that doesn't lean on that assumption being correct — they're called "sandwich" because the formula literally sandwiches a middle piece (built from the observed data's actual variability) between two outer pieces derived from the model. Here, that matters because the MAIC weights fed into the Cox model aren't fixed, known numbers — they were themselves *estimated* from the matching step, carrying their own uncertainty, which an ordinary (non-robust) standard error would silently ignore, making the reported confidence interval too narrow and the result look more precise than it really is. Think of it as the statistical equivalent of accounting for the fact that your ruler itself has some wobble, rather than assuming every measurement taken with it is exact.
]

A practical note on tooling: there is no single dominant, actively maintained CRAN package that performs MAIC end to end. Most published MAICs are implemented by hand in R, essentially as the `optim()`-based weighting step above followed by a weighted outcome model. A `maic` package exists on GitHub and is used by some HTA submissions, but it is _not on CRAN_, has not been through CRAN's review process, and should be treated as unreviewed third-party code — inspect its weighting and variance-estimation internals line by line, or reproduce its output with your own `optim()` call, before relying on it for a submission.

== 13.3 Simulated treatment comparison (STC)

STC addresses the same imbalance problem as MAIC but by a different mechanism. Instead of reweighting patients, STC fits an _outcome regression model_ on the IPD trial — the treatment effect plus the matched covariates as predictors — and then predicts what the outcome would have been had the IPD trial's population had the AgD trial's reported covariate means. Where MAIC asks "how do I reweight my patients to look like theirs?", STC asks "what does my outcome model say would happen to a population with their average characteristics?"

Concretely, for a continuous or binary outcome:

```r
# Outcome regression model on the IPD trial, including a
# treatment x covariate interaction to capture effect modification
stc_fit <- glm(
  outcome ~ treatment * age + treatment * severity,
  data   = ipd,
  family = binomial()
)

# Predict the treatment effect at the AgD trial's reported means
newdata <- data.frame(
  treatment = c(0, 1),
  age       = target_means["age"],
  severity  = target_means["severity"]
)

preds <- predict(stc_fit, newdata = newdata, type = "link")
stc_log_odds_ratio <- preds[2] - preds[1]
```

#report-table(
  [Illustrative STC outcome-regression coefficients (logistic model, IPD trial, treatment $times$ covariate interactions), and the resulting log-odds-ratio predicted at the AgD trial's reported covariate means],
  academic-table(
    columns: (1.8fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Term*], [*Estimate*], [*SE*], [*p*]),
    body: (
      [Treatment], [0.41], [0.18], [0.023],
      [Age (centered)], [-0.02], [0.01], [0.085],
      [Severity (centered)], [-0.31], [0.12], [0.010],
      [Treatment $times$ age], [0.015], [0.019], [0.431],
      [Treatment $times$ severity], [0.28], [0.11], [0.012],
    ),
    footer: (table.cell(colspan: 4)[Predicted log-odds ratio at the AgD trial's reported means (age = 61.4, severity index = 2.1): 0.52, i.e. OR $approx$ 1.68 -- a *conditional* effect at those covariate values, not yet the population-average effect; see the non-collapsibility caution above before reporting this as the final STC estimate.],),
  ),
) <tab-ch13-stc-coefficients>

The appeal is efficiency: STC uses all $N$ IPD patients in the regression rather than discarding information to an ESS-reduced weighted subsample, so it does not suffer MAIC's precision penalty from extreme weights. The cost is a stronger assumption: STC's validity depends on _correctly specifying the outcome model_, including its functional form, which covariates (and interactions) belong in it, and — critically for nonlinear models — the right scale on which to summarize the "effect at the mean."

#pitfall[
  For a linear model on a continuous outcome, "predict the outcome at the covariate means" and "the average outcome across the covariate distribution" give the same answer, so STC is relatively safe there. For _nonlinear_ outcome models — logistic regression on odds ratios, Cox regression on hazard ratios — they do not. The reason has a name: _non-collapsibility_. The conditional treatment effect (adjusted for covariates, evaluated at their mean) and the marginal treatment effect (averaged over the whole covariate distribution) are two different quantities on the odds-ratio or hazard-ratio scale. This is true even when the model is perfectly specified. So plugging the AgD trial's mean covariate values into a fitted logistic or Cox model, and reading off the "treatment effect," gives a *conditional* effect at those particular covariate values. It does not give the *population-average* effect that an aggregate-data trial reports — and that the indirect comparison needs to match. Treating these as interchangeable biases the comparison, even when every covariate is balanced and the outcome model is otherwise correct. The fix: simulate outcomes across the full joint covariate distribution implied by the AgD trial's reported summary statistics, average the simulated individual predictions on the natural outcome scale, then transform back to odds ratios or hazard ratios. This simulation step is the "simulated" in the method's name. Skipping it is the single most common STC implementation error.
]

#difficult-terminology("conditional treatment effect / marginal treatment effect")[
These two phrases sound like they should mean almost the same thing, but on
a nonlinear scale (odds ratio, hazard ratio) they genuinely do not, and the
gap between them is the whole reason non-collapsibility matters. A
*conditional* effect is "the treatment effect for a patient (or group of
patients) who all share one specific set of covariate values" — e.g. "the
odds ratio for a 61-year-old patient with a severity score of 2.1," read
straight off a fitted regression's coefficient. A *marginal* effect is "the
treatment effect averaged across the whole population's actual mix of
covariate values" — the number an aggregate-data trial's reported odds
ratio or hazard ratio actually represents, since that trial never
conditioned on anyone's individual covariates in the first place.

A quick worked example makes the gap concrete. Simulate 100,000 patients,
half with mild disease and half with severe, with a treatment that has
exactly the same true log-odds effect (0.7, i.e. an odds ratio of about
2.0) in both subgroups — no genuine effect modification by severity at
all, by construction:
```r
set.seed(1)
n <- 100000
severity <- rbinom(n, 1, 0.5)   # 0 = mild, 1 = severe
treat <- rbinom(n, 1, 0.5)
lp <- -1 + 0.7 * treat + 1.5 * severity  # constant treatment log-odds effect
y <- rbinom(n, 1, plogis(lp))

m <- glm(y ~ treat + severity, family = binomial)
exp(coef(m)["treat"])  # conditional OR, adjusted for severity
```
Fitting a logistic regression recovers a *conditional* odds ratio of
about *1.98* — close to the true 2.0, as expected. But now average the
model's predicted probabilities under "everyone treated" versus "no one
treated," across the real mix of mild and severe patients in the sample,
and convert that to an odds ratio:
```r
p1 <- mean(predict(m, newdata = transform(df, treat = 1), type = "response"))
p0 <- mean(predict(m, newdata = transform(df, treat = 0), type = "response"))
(p1 / (1 - p1)) / (p0 / (1 - p0))  # marginal OR
```
This gives a *marginal* odds ratio of about *1.82* — noticeably smaller,
despite the underlying model being exactly right and having no real
effect modification at all. Nothing is wrong with the model; odds ratios
themselves simply don't average the way risk differences do (a risk
difference, by contrast, collapses cleanly — this is specifically an
odds-ratio/hazard-ratio problem, not a general statistics problem). STC's
entire extra "simulate across the covariate distribution" step described
above exists purely to convert the easy-to-fit conditional estimate into
the marginal estimate that can actually be compared against an aggregate
trial's reported result.
]

The practical trade-off between the two methods comes down to *which* model you must get right. MAIC's validity rests on correctly specifying the _weighting/matching model_ — which covariates drive the propensity-style weights — but it makes no assumption about the outcome's functional form; the weighted outcome analysis can be as simple as a weighted Kaplan–Meier curve. STC's validity rests on correctly specifying the _outcome regression model_, including its functional form and the covariate-by-treatment interactions that encode effect modification. But STC uses the full IPD sample, with no ESS penalty. Neither assumption dominates the other in general. The choice usually comes down to how much confidence you have in modelling the outcome mechanism versus modelling the covariate-balancing mechanism, and how severe the expected ESS loss would be under MAIC given how much the two trial populations actually overlap.

#agency-note[
  NICE DSU Technical Support Document 18 (Phillippo et al., 2016) is the standard methodological reference underpinning both MAIC and STC, and sets out NICE's expectations for reporting ESS, covariate selection, and sensitivity analyses in a submission. §13.5 of this chapter covers TSD 18's guidance in full; treat the summary here only as a signpost to that fuller discussion.
]

== 13.4 Multilevel network meta-regression (ML-NMR)

MAIC and STC, as developed in §13.1–13.3, share a structural limitation: both operate on exactly two trials — one with individual patient data (IPD) and one reporting only aggregate data (AgD) — connected by a single comparison. The moment either trial sits inside a larger network of three or more treatments, these two-trial methods have no natural extension: you would need to run a separate MAIC or STC for every AgD trial against the IPD trial, throwing away the internal consistency that a proper network provides and giving no single coherent treatment-effect ranking across the whole network.

Multilevel network meta-regression (ML-NMR), developed by Phillippo, Ades, Dias, Welton, and colleagues (Phillippo et al. 2020, *Journal of the Royal Statistical Society Series A*), closes this gap. It generalises population adjustment from the two-trial case to a full network containing an arbitrary mix of IPD and AgD-only studies. The core idea extends STC's logic rather than replacing it: fit an individual-level regression model for the outcome — treatment, effect-modifying covariates, and treatment-by-covariate interactions — using whichever trials contribute IPD. For the trials that report only AgD, instead of plugging in a single covariate mean (as STC does), ML-NMR numerically integrates the individual-level prediction equation over each AgD trial's *reported covariate distribution*. When an AgD trial publishes not just means but also standard deviations and, ideally, correlations between effect modifiers, ML-NMR uses that fuller distributional information, rather than collapsing it to a point. This is what makes ML-NMR more defensible than moment-matching approaches when the data exist to support it — but also considerably more data-demanding, since it requires AgD trials to report enough distributional detail (not just means) for the covariates that matter.

ML-NMR is not a new tool bolted onto this book's toolkit — it is the same `multinma` package (Phillippo et al.) already introduced in Chapter 12 §12.4 for Bayesian network meta-analysis, used in exactly the same workflow. There, you built a network with `set_ipd()` and `set_agd_arm()` and fit it with `multinma::nma()` assuming no effect modification. ML-NMR is what happens when that regression model is allowed to include covariate-by-treatment interaction terms, and the AgD arms are no longer treated as covariate-free: each AgD study additionally needs numerical integration points describing its covariate distribution so that the individual-level model's predictions can be correctly marginalised to that study's population. The documented function for generating these integration points is `multinma::add_integration()`, which builds Quasi-Monte Carlo integration points (via a Gaussian copula and Sobol' sequences) from each AgD study's reported covariate means, SDs, and — where available — correlations.

#difficult-terminology("Sobol' sequences / Quasi-Monte Carlo integration points")[
"Numerically integrating" over a covariate distribution just means: rather than plugging in one single average value (as STC does), generate a large number of representative sample points that collectively cover the whole range of plausible covariate values for that trial's population, and average the model's prediction over all of them. Ordinary Monte Carlo would do this with purely random points, which cluster unevenly by chance (like randomly scattering dots on a dartboard — some areas get too many, some too few). A Sobol' sequence instead generates points in a carefully structured, non-random pattern that spreads them out evenly across the space — closer to laying dots on a grid, but cleverer, so that even a modest number of points gives a good, stable approximation of the integral. "Quasi-Monte Carlo" is the general name for this family of structured-point integration techniques, and Sobol' sequences are simply the most common recipe used to generate the points.
]

#difficult-terminology("Gaussian copula")[
When an AgD trial reports several covariates' means, SDs, and the correlations between them (e.g. age and disease severity tend to rise together), you need a way to generate *jointly* realistic sample values for all the covariates at once — not just realistic values for each covariate separately, ignoring how they relate to each other. A Gaussian copula is the mathematical device that does this: it takes each covariate's own individually-specified distribution (which doesn't have to be Normal at all) and "glues" them together using a correlation structure borrowed from the multivariate Normal distribution, producing joint sample points that respect both each covariate's own shape and the reported correlations between them. A rough analogy: imagine you know the typical height and weight distributions separately, plus the fact that taller people tend to be heavier — a copula is the recipe for generating pairs of (height, weight) values that look like genuine people, rather than randomly mixing a height from one person with a weight from someone unrelated.
]

A schematic workflow, keeping the illustrative code deliberately light and consistent with the Chapter 12 pattern:

```r
library(multinma)

# Network combining IPD and AgD-only trials, as in Ch.12 §12.4
net <- combine_network(
  set_ipd(ipd_trial, study = study, trt = trt, y = outcome,
          trt_class = NULL),
  set_agd_arm(agd_trials, study = study, trt = trt,
              r = events, n = n)
)

# Supply numerical integration points for each AgD trial's
# covariate distribution -- consult the current multinma
# documentation for the exact distribution-argument syntax,
# which has evolved across package versions.
net_int <- add_integration(
  net,
  age = distr(qnorm, mean = age_mean, sd = age_sd),
  ecog = distr(qbern, prob = ecog_prop)
)

# Fit the regression model with effect-modifier interactions
ml_nmr_fit <- nma(net_int,
                   trt_effects = "fixed",
                   regression = ~ age + ecog,
                   class_interactions = "common")
```

The call shapes for `set_ipd()`, `set_agd_arm()`, and `nma()` mirror Chapter 12 exactly; `add_integration()` is the one genuinely new step, and its covariate-distribution argument syntax has changed across `multinma` releases, so treat the `distr(qnorm, ...)` style above as illustrative rather than copy-ready — always check the installed version's help page and vignette before running a submission analysis.

#heor-practice[
  Think of ML-NMR as "STC done properly across a whole network." STC matches an AgD trial to one covariate value (its mean); ML-NMR matches it to the trial's *entire reported covariate distribution*, and does so simultaneously for every AgD trial in the network while preserving one internally consistent set of relative treatment effects. The price is data: ML-NMR only delivers its full benefit when AgD trials publish SDs and, where effect modifiers interact, correlations — not just means. When that reporting is thin, ML-NMR can gracefully fall back toward STC-like behaviour, but its defensibility advantage shrinks accordingly.
]

#figure(
  image("../images/conceptual/ch13_method_decision_map.png", width: 100%),
  caption: [A quick triage map for choosing among MAIC, STC and ML-NMR, based on how many trials are in the evidence base and how much covariate detail the AgD trial(s) report. The §13.1-§13.4 prose walks through this same logic linearly; this is a fast index back into it, not a replacement for reading the assumptions each method actually requires.],
) <fig-ch13-method-decision-map>

#ref-table(
  [Comparison of the three population-adjustment methods covered in this chapter: data requirements, core assumption, and typical use case],
  academic-table(
    columns: (auto, 1.4fr, 1.6fr, 1.6fr),
    align: (left, left, left, left),
    header: ([*Method*], [*Data requirement*], [*Key assumption*], [*Typical use case*]),
    body: (
      [MAIC], [IPD for one trial + AgD (covariate means, sometimes SDs) for the comparator trial], [Weighting/matching model is correctly specified; matched covariates include all relevant effect modifiers], [Simple two-trial comparison with an IPD submission trial and one published AgD comparator, especially for survival outcomes via weighted Kaplan–Meier/Cox],
      [STC], [IPD for one trial + AgD (covariate means) for the comparator trial], [Outcome regression model is correctly specified, including functional form and treatment-by-covariate interactions; non-collapsibility handled via simulation on nonlinear scales], [Two-trial comparison where the analyst has strong confidence in the outcome model and wants to retain full IPD precision (no ESS penalty)],
      [ML-NMR], [IPD for some trials + AgD (covariate means, SDs, and ideally correlations) for the rest, across a full network], [Individual-level regression model is correctly specified; AgD trials report enough distributional detail for numerical integration], [Networks of three or more treatments mixing IPD and AgD-only trials, where a single internally consistent set of relative effects is required],
    ),
  ),
) <tab-ch13-method-comparison>

== 13.5 Limitations, assumptions and agency expectations (NICE DSU TSD 18)

Every method introduced in this chapter — MAIC, STC, and ML-NMR — answers the same underlying problem (effect-modifier imbalance across trials that cannot be resolved by a standard anchored NMA or Bucher indirect comparison) with different trade-offs between data requirements and defensibility. NICE DSU Technical Support Document 18, *Methods for Population-Adjusted Indirect Comparisons in Submissions to NICE* (Phillippo, Ades, Dias, Palmer, Abrams, Welton; first published 2016, subsequently updated), is the standard reference that HTA bodies and manufacturers alike use to judge whether a population-adjusted analysis is appropriate and well-executed. It is the single most important named document in this chapter, and no submission using MAIC, STC, or ML-NMR should be prepared without direct reference to it.

#agency-note[
  *What TSD 18 actually requires, in outline:*
  - *Justify the need for adjustment.* A standard NMA or Bucher comparison is the default; population adjustment is only warranted when the company can demonstrate an effect-modifier imbalance problem between the trial populations — not simply assert that one might exist.
  - *Prespecify effect modifiers before seeing comparative results.* The list of covariates to adjust for must be clinically justified and fixed in advance (via literature review, clinical input, or prior trials), independent of the analysis's own outcome.
  - *Report covariate balance before and after weighting* (for MAIC) so reviewers can see what imbalance existed and how much of it was corrected.
  - *Report the effective sample size (ESS)* after weighting and discuss what an ESS loss implies for the precision and credibility of the result.
  - *State a method preference, data permitting.* TSD 18's stated ordering, roughly, is ML-NMR > STC > MAIC: ML-NMR preserves a network's internal consistency and uses the full covariate distribution; STC retains the IPD trial's own outcome model and standard errors; MAIC, by reweighting the IPD sample to match only the AgD trial's reported moments, discards information and can inflate variance by effectively down-weighting the IPD trial's within-trial precision. Choose MAIC because it is simplest to implement, not because it is DSU 18's preferred option.
]

#ref-table(
  [NICE DSU TSD 18: named limitations of population-adjustment methods and the agency's stated concern for each],
  academic-table(
    columns: (1.4fr, 2.2fr),
    align: (left, left),
    header: ([*Limitation*], [*TSD 18's stated concern*]),
    body: (
      [Target-population specificity], [An adjusted estimate is valid only for the population it was adjusted to (typically the AgD trial's population); it does not carry the transportability assumption of a standard NMA, so a different target population requires a fresh adjustment],
      [Unmeasured confounding in unanchored comparisons], [Without a common comparator to absorb unmeasured differences, an unanchored analysis implicitly assumes every effect modifier and prognostic factor has been measured and correctly adjusted for -- rarely fully defensible; unanchored designs carry materially higher bias risk than anchored ones],
      [Post-hoc effect-modifier selection], [Choosing or dropping covariates after seeing how they change the adjusted result is a recognised form of analytical bias; the effect-modifier list must be prespecified from external clinical and literature evidence before the adjusted analysis is run],
      [ESS loss (MAIC specifically)], [A large drop in effective sample size after weighting signals that a small number of extreme weights are driving the result and that the reported confidence interval may understate true uncertainty; ESS must be reported prominently, not in an appendix],
      [Thin AgD reporting], [ML-NMR's advantage over STC depends on AgD trials publishing covariate SDs and, where relevant, correlations -- not just means; when that detail is absent, ML-NMR degrades toward STC-like behaviour and its defensibility edge shrinks],
    ),
  ),
) <tab-ch13-tsd18-limitations>

#pitfall[
  *Post-hoc effect-modifier selection.* Choosing or dropping candidate effect modifiers *after* looking at how they change the adjusted treatment effect is a well-recognised form of analytical bias, and it is explicitly criticised by the DSU and by NICE Evidence Review Groups (ERGs) when detected. It lets an analyst chase the covariate set that produces the most favourable result while presenting it as a neutral, methods-driven choice. The defence is procedural, not statistical: fix the effect-modifier list from external clinical and literature evidence *before* running the adjusted analysis, document that process in the submission, and resist any temptation to revise the list once results are in hand.
]

#agency-note[
  *ESS as a credibility signal, not a footnote.* For MAIC in particular, a large drop in effective sample size after weighting (e.g., an ESS that falls to a small fraction of the original IPD sample size) is not a cosmetic detail — ERGs treat it as a direct warning sign that the weights are being driven by a small number of extreme observations, that the weighted estimate's reported confidence interval may understate true uncertainty, and that the result may not generalise robustly to the target population. Submissions should report ESS prominently alongside the adjusted estimate, not bury it in an appendix, and should discuss explicitly what the ESS loss implies for the analysis's reliability — silence on this point is itself a flag reviewers are trained to look for.
]

Two further limitations apply across all three methods and deserve to be stated plainly rather than left implicit.

First, *a population-adjusted estimate is only valid for the one target population it was adjusted to* — typically the AgD trial's population, since that is the population whose covariate distribution (or moments) the IPD trial was reweighted or regressed onto. This is a fundamentally different assumption from a standard NMA's transportability of relative effects, which assumes (rightly or wrongly) that a relative treatment effect generalises across reasonably similar populations. A MAIC-, STC-, or ML-NMR-adjusted estimate carries no such claim: adjust the same IPD trial to a different AgD trial's population and you may well get a different answer, and that is expected, not a contradiction. Decision-makers who want an estimate for a population other than the one used in adjustment need a fresh adjustment, not a reuse of the existing one.

Second, *unanchored comparisons deserve particular caution*. An anchored comparison (MAIC, STC, or ML-NMR performed within a network that still has a common comparator connecting the trials) uses that common comparator to cancel out between-trial differences that are not captured by the measured covariates — the anchor absorbs some of the risk from unmeasured confounding. An unanchored comparison, by contrast, arises when no such common-comparator link exists at all, so the entire burden of adjustment falls on the outcome regression model with no anchor to offset what that model misses.

#pitfall[
  *Unanchored comparisons are a last resort, not a default.* TSD 18 is explicit that unanchored population-adjusted comparisons carry a materially higher risk of bias from unmeasured confounding and unmeasured effect modification than their anchored counterparts, because there is no common-comparator trial arm to absorb whatever the adjustment model fails to capture. An unanchored analysis implicitly assumes that *all* effect modifiers and prognostic factors have been measured and correctly adjusted for — an assumption that is rarely fully defensible. Reach for an unanchored design only when no anchored route exists, and when you do, report the limitation transparently and prominently in the submission rather than presenting the result with the same confidence as an anchored estimate.
]
