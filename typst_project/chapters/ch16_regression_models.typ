#import "../common.typ": *

= Chapter 16. Regression Models for HEOR Data

Chapter 15 estimated treatment effects while adjusting for confounding —
propensity scores, doubly robust estimators, instrumental variables. This
chapter steps back to the regression machinery those methods are built
from, and extends it in two directions the earlier chapters only touched
in passing: handling the specific outcome shapes HEOR data actually takes
(binary, count, skewed, ordinal), and handling the structure HEOR data
actually has (patients clustered within clinics, treatment effects that
vary across patients rather than sitting at one average value). By the
end of the chapter, the regression toolkit used everywhere else in this
book — cost models in Chapter 9, utility mapping in Chapter 8, the GLM
core of the propensity-score and doubly-robust estimators in Chapter 15
— will sit inside one coherent framework.

#learning-objectives((
  [Fit and interpret the three GLM families used throughout HEOR —
  binomial/logistic, Poisson/negative-binomial, and gamma — and correctly
  back-transform coefficients through the link function.],
  [Recognise when HEOR data is clustered (patients within clinics, repeated
  measures within patients) and fit a mixed-effects model with `lme4`.],
  [Model overdispersed and zero-inflated count outcomes, and distinguish
  a zero-inflated model from a hurdle model.],
  [Use quantile regression to model a specific percentile of a skewed
  cost or length-of-stay distribution, and ordinal regression for
  Likert-scale PRO data.],
  [Use random/causal forests and penalised regression (LASSO/elastic net)
  to estimate treatment-effect heterogeneity and select variables from a
  high-dimensional covariate set.],
  [Distinguish pre-specified from exploratory subgroup analysis, test
  effect modification via an interaction term, and avoid the multiplicity
  pitfall of subgroup fishing.],
))

== 16.1 Generalised linear models

Every regression model you have fit so far in this book — the gamma cost
models in Chapter 9, the logistic-type transformations behind utility
regression in Chapter 8 — is a special case of one framework: the
*generalised linear model* (GLM). A GLM has three ingredients: a
distribution for the outcome from the exponential family (binomial,
Poisson, negative binomial, gamma, Gaussian, ...), a *linear predictor*
($eta = beta_0 + beta_1 x_1 + ...$), and a *link function* that connects
the two ($g(mu) = eta$). Once you see the pattern, "which model do I
fit?" becomes "which distribution matches my outcome's support, and
which link makes the linear predictor behave?" — rather than a new
method to memorise every time.

#shiny-app-box("logistic_link_function_explorer", [Drag a logistic-regression coefficient and intercept and watch the predicted-probability S-curve reshape live on the link vs. response scale.])

#difficult-terminology("exponential family")[
"Exponential family" is not a statement about exponential growth — it's
a technical label for a whole group of probability distributions
(normal/Gaussian, binomial, Poisson, negative binomial, gamma, and a
handful of others) that all share the same underlying mathematical
form once you write them out algebraically. That shared form is the
reason a single piece of software machinery — the GLM-fitting
algorithm — can estimate all of them: R doesn't need a bespoke fitting
routine for "binary outcome regression" and a different one for "count
outcome regression"; it needs one general algorithm plus a
specification of *which* exponential-family distribution and *which*
link function apply to your outcome. Practically, you never need to
verify exponential-family membership yourself — the handful of
distributions you'll actually use in HEOR work (binomial for yes/no
outcomes, Poisson or negative binomial for counts, gamma for skewed
positive costs, Gaussian for roughly symmetric continuous outcomes) are
all members, which is precisely why `glm()` can fit all of them through
the same `family = ` argument.
]

Three outcome types cover most HEOR regression work:

- *Binary outcomes* (treatment success/failure, culture conversion,
  mortality) use the binomial family with a logit link — logistic
  regression. The logit link keeps predicted probabilities between 0
  and 1.
- *Count outcomes* (hospitalisations, adverse-event episodes, clinic
  visits) use a Poisson or negative-binomial family with a log link.
  Negative binomial is the safer default in practice: TB programme
  count data is almost always overdispersed (variance exceeds the
  mean), and Poisson's assumption that they're equal is routinely
  violated.
- *Skewed, strictly positive cost data* uses a gamma family with a log
  link — exactly the model built in detail in §9.4. This subsection will
  not re-derive it; the mechanics (mean-scale modelling via the log
  link, no retransformation bias) are identical, because it is the same
  GLM framework applied to a different exponential-family member.

In base R, all three are one function: `glm()`. You only change the
`family` argument.

```r
library(dplyr)
library(broom)

# Toy multi-site TB treatment-outcome dataset
tb_outcomes <- tibble::tribble(
  ~patient_id, ~regimen,    ~age, ~baseline_smear, ~success,
  1,           "standard",  34,   "positive",      1,
  2,           "standard",  45,   "positive",      0,
  3,           "shortened", 29,   "negative",      1,
  4,           "shortened", 51,   "positive",      1,
  5,           "standard",  38,   "negative",      0,
  6,           "shortened", 61,   "positive",      0,
  7,           "shortened", 27,   "negative",      1,
  8,           "standard",  42,   "positive",      1
)

fit_logit <- glm(
  success ~ regimen + age + baseline_smear,
  family = binomial(link = "logit"),
  data   = tb_outcomes
)

# Tabulate coefficients, odds ratios and confidence intervals
broom::tidy(fit_logit, exponentiate = TRUE, conf.int = TRUE)

# Predicted probability of success for a new patient
predict(
  fit_logit,
  newdata = tibble::tibble(regimen = "shortened", age = 40, baseline_smear = "positive"),
  type    = "response"
)
```

`broom::tidy(..., exponentiate = TRUE)` is doing real work here, not just
formatting: it exponentiates the log-odds coefficients into odds ratios
so you can report them directly. `predict(..., type = "response")`
back-transforms through the inverse link to give a probability rather
than a log-odds value. Both arguments matter, and forgetting them is the
single most common GLM reporting error.

#pitfall([
A GLM's raw coefficients live on the *link* scale, not the scale anyone
wants to read. For a logistic model, `coef(fit_logit)` returns log-odds;
for a Poisson or gamma model with a log link, raw coefficients are
log-rate or log-cost-ratio. Reporting these numbers unchanged — "age
effect: 0.03" — means almost nothing to a TB programme manager. Always
exponentiate (`exp(coef(...))`, or `broom::tidy(..., exponentiate =
TRUE)`) before presenting results, and say explicitly what the
exponentiated quantity is: an odds ratio, a rate ratio, or a cost ratio.
])

#agency-note([
CHEERS 2022 item 26 ("Characterising heterogeneity") and item 20 ("Study
parameters") both expect the statistical model underlying any
regression-derived parameter to be named explicitly in the report — not
just the resulting estimate. For a GLM, that means stating the family
and link function (e.g. "binomial GLM with logit link") alongside the
odds ratio or rate ratio, so a reviewer can judge whether the model
choice matched the outcome's distribution.
])

== 16.2 Mixed-effects and hierarchical models

The GLMs in §16.1 assume every observation is independent. That
assumption breaks the moment your data has structure: patients nested
within clinics, clinics nested within regions, or repeated HRQoL
measurements taken from the same patient over time. Patients treated at
the same clinic share a nurse, a supply chain, a local strain profile —
they are *more alike than two random patients*, and a plain GLM has no
way to represent that.

*Fixed effects* are the parameters you want to estimate and report: the
effect of regimen, of age, of baseline smear status — the things in
§16.1's `glm()` calls. *Random effects* represent variation across a
grouping factor (clinic, patient) that you want to account for, but
whose specific levels aren't individually of interest — you don't care
that Clinic 7's intercept is 0.3 higher than Clinic 2's, you care that
clinics vary, and you want your fixed-effect estimates and standard
errors to be correct given that they do.

Ignoring clustering and fitting a naive GLM when data is actually
hierarchical doesn't just bias your standard errors — it specifically
makes them too small, because the model treats twenty patients from one
clinic as twenty independent pieces of information when they're closer
to a handful.

```r
library(lme4)

# Toy multi-site TB dataset: patients nested within clinics
tb_multisite <- tibble::tribble(
  ~clinic_id, ~patient_id, ~regimen,    ~age, ~success,
  "A", 1,  "standard",  34, 1,
  "A", 2,  "standard",  45, 0,
  "A", 3,  "shortened", 29, 1,
  "B", 4,  "shortened", 51, 1,
  "B", 5,  "standard",  38, 0,
  "B", 6,  "shortened", 61, 0,
  "C", 7,  "shortened", 27, 1,
  "C", 8,  "standard",  42, 1,
  "C", 9,  "standard",  33, 0,
)

# Random intercept for clinic, fixed effects for regimen and age
fit_mixed <- glmer(
  success ~ regimen + age + (1 | clinic_id),
  family = binomial(link = "logit"),
  data   = tb_multisite
)

summary(fit_mixed)
broom.mixed::tidy(fit_mixed, effects = "fixed", exponentiate = TRUE, conf.int = TRUE)
```

`lme4::glmer()` is the binomial/Poisson/gamma-family counterpart of
`lme4::lmer()` (which fits continuous, Gaussian outcomes — the natural
choice for repeated HRQoL scores measured on the same patient over
time). The `(1 | clinic_id)` term is the random intercept: one baseline
log-odds per clinic, drawn from a shared normal distribution, rather
than one fixed-effect dummy per clinic eating up degrees of freedom.
`REML = TRUE` (the default for `lmer()`, though `glmer()` always uses
maximum likelihood) controls how the random-effect variance is
estimated — leave it at its default unless you have a specific reason
not to. `nlme::lme()` is an older alternative with the same core idea,
mainly still seen when you need its more flexible correlation-structure
syntax (e.g. for repeated-measures autocorrelation).

How much clustering is there? The *intraclass correlation coefficient*
(ICC) answers that: it's the proportion of total outcome variance
attributable to the grouping factor (clinic), versus variance between
patients within the same clinic. An ICC near 0 means clinics barely
differ and a plain GLM would have been fine; an ICC of 0.15 means a
meaningful share of outcome variation sits at the clinic level, and
ignoring it would understate your uncertainty.

A *random intercept* (`(1 | clinic_id)`) lets each clinic have its own
baseline outcome level. A *random slope* (`(1 + age | clinic_id)`) goes
further and lets the *effect* of a covariate — say, the age effect —
vary by clinic too, useful when you suspect, for instance, that older
patients do worse at some clinics but not others. Start with random
intercepts; add random slopes only when you have a substantive reason to
think an effect itself varies by group, since each additional
random-effects term costs you estimability, especially with as few
clusters as a multi-site TB programme typically has.

#agency-note([
NICE's Decision Support Unit technical support document on evidence
synthesis for clinical effectiveness (TSD 3) explicitly recommends a
random-effects (hierarchical) model over a fixed-effect pooling when
between-study — or, by direct analogy, between-clinic — heterogeneity is
plausible, rather than treating pooled homogeneity as a safe default
assumption.
])

== 16.3 Count data and zero-inflated models

Count outcomes show up constantly in TB programme data: hospitalisations
per patient-year, missed follow-up visits, adverse events reported per
participant. The instinct is to reach for Poisson regression. The
problem is that Poisson assumes the mean equals the variance, and real
programme data almost never behaves that politely — a few patients rack
up many events while most have none or one, so the variance outruns the
mean. This is overdispersion, and ignoring it gives you standard errors
that are too small and p-values that look better than they should.

#shiny-app-box("overdispersion_zero_inflation_visualizer", [Drag Poisson mean, NB dispersion, and structural-zero proportion sliders and watch a simulated count histogram morph between Poisson, NB, and zero-inflated shapes.])

The fix for plain overdispersion is the negative binomial model, fit
with `MASS::glm.nb()`. It has the same formula interface as `glm()` but
estimates an extra dispersion parameter instead of assuming it away:

```r
library(MASS)

fit_nb <- glm.nb(ae_count ~ arm + age + baseline_risk, data = tb_ae)
summary(fit_nb)
```

`glm.nb()` reports the usual coefficient table on the log scale
(exponentiate for rate ratios, same logic as Poisson), plus a `theta`
value — smaller `theta` means more overdispersion.

Overdispersion is one problem; *excess zeros* are a different one.
Suppose you're counting adverse events and most patients genuinely never
have one — not because of under-reporting, but because they simply
didn't experience an AE. A negative binomial model can stretch to
accommodate more zeros than Poisson expects, but when the zeros come
from a distinct process (a patient who could never have an AE vs. one
who could but didn't), you need a model that says so explicitly: a
zero-inflated model, fit with `pscl::zeroinfl()`.

```r
library(pscl)

fit_zinb <- zeroinfl(
  ae_count ~ arm + age | arm,
  data  = tb_ae,
  dist  = "negbin"
)
summary(fit_zinb)
```

The formula has two parts separated by `|`: the left side models the
count (how many events, given you're in the "can have events" group),
the right side models the probability of being a structural zero. `dist
= "negbin"` lets the count part also absorb ordinary overdispersion;
`dist = "poisson"` is the simpler default.

A closely related but conceptually different model is the *hurdle*
model, available via `pscl::hurdle()`. Zero-inflated and hurdle models
both have a two-part structure, but they answer different questions. A
zero-inflated model says some zeros are "structural" (could never have
had an event) and some are "sampling" zeros from the count process
itself — the two kinds of zero are mixed together. A hurdle model
instead says every subject first clears a hurdle (any events at all,
yes/no), and only those who clear it move to a truncated count model for
*how many*. For AE counts, zero-inflation is usually the more defensible
story (patients who were never going to have an AE vs. those who could
but didn't); hurdle models fit better when crossing from zero to one
event is genuinely a different mechanism from the counting process
above one.

#heor-practice([
A payer dossier for a new TB regimen reported adverse-event counts using
plain Poisson regression. A reviewer noted that over 60% of patients had
zero AEs and asked the sponsor to justify the distributional assumption.
Re-analysis with `pscl::zeroinfl()` separated "never going to have an
AE" patients from the count process for those who did, and the
treatment effect on AE *rate* (among patients who had any) held up — but
the original Poisson model had understated the uncertainty around it,
almost triggering a resubmission.
])

#pitfall([
Fitting plain Poisson regression to overdispersed or zero-heavy count
data is one of the most common silent errors in HEOR analysis. The point
estimates often look reasonable; it's the standard errors that are
wrong — usually too small — which inflates Type I error and can make a
null effect look significant. Always check the ratio of residual
deviance to degrees of freedom (well above 1 signals overdispersion) and
tabulate the proportion of zeros before trusting a Poisson model.
])

#difficult-terminology("Type I error")[
A Type I error is the statistical term for a "false positive": you
conclude there is a real effect or difference (e.g., a drug lowers
cost, or a treatment changes outcomes) when, in the underlying truth,
there is no such effect, and what you saw was just random noise in
your particular sample. The conventional threshold of $alpha = 0.05$
means you've agreed to accept a 5% chance of this kind of false alarm
whenever a true null effect is tested. The problem flagged in the
pitfall above is that bad standard errors (too small) make p-values
look smaller than they should, so you end up crying wolf more than 5%
of the time without realising it — the nominal 5% false-positive rate
quietly becomes something larger, like 15-20%, because the model is
overconfident about its own precision.
]

#difficult-terminology("residual deviance / degrees of freedom")[
These are two separate numbers that, together, give you a quick
diagnostic check. *Residual deviance* is a single number summarising
how far the model's fitted values are from the actual observed data —
think of it as a generalisation of "sum of squared errors" that works
for GLMs, not just ordinary linear regression; smaller is a better fit.
*Degrees of freedom* here is, roughly, the number of observations in
your dataset minus the number of parameters your model estimated — it
reflects how much independent information was left over after fitting.
For a well-behaved Poisson model, textbook theory says these two
numbers should come out roughly equal, so dividing deviance by degrees
of freedom should give something close to 1. If that ratio comes out
well above 1 (say, 3 or 5), it is a red flag that your data has more
variability than a plain Poisson distribution assumes — this is called
*overdispersion*, and it is exactly the kind of thing that inflates
Type I error as described above. In R, both numbers are printed
automatically at the bottom of `summary(my_glm_model)`, so the check
costs nothing beyond glancing at output you already have.
]

== 16.4 Quantile and ordinal regression

Chapter 9 made the case that cost data is skewed — a long right tail of
expensive patients pulls the mean around, which is why GLMs with a log
link or gamma family were preferred over OLS on raw costs. Quantile
regression takes a different route to the same problem: instead of
modelling the *mean* cost (transformed or not), it models a chosen
*percentile* of the cost distribution directly.

#shiny-app-box("quantile_regression_tau_slider", [Drag a tau slider and watch a quantile-regression fit move from the median toward the costly tail, diverging from the mean-based fit.])

This matters because the mean and the median (or the 90th percentile)
can tell different stories. A budget-holder asking "what does a typical
TB patient's length of stay cost?" wants the median. A capacity planner
asking "what should we provision for the costly tail?" wants the 90th or
95th percentile. Quantile regression, via `quantreg::rq()`, answers
either question in one formula-based call:

```r
library(quantreg)

# Median length of stay
fit_median <- rq(los ~ arm + age + comorbidity_score, data = tb_cost, tau = 0.5)

# 90th percentile length of stay — the costly tail
fit_q90 <- rq(los ~ arm + age + comorbidity_score, data = tb_cost, tau = 0.9)

summary(fit_median)
summary(fit_q90)
```

`tau` sets the quantile (0.5 is the median; any value in (0,1) is
valid). The coefficients are interpreted like linear regression
coefficients, but for that specific quantile — a coefficient from the
`tau = 0.9` model describes how a predictor shifts the *top* of the
distribution, which can differ meaningfully from its effect on the
median. This complements, rather than replaces, the Chapter 9 approach
to skewed cost data: use GLMs when you want a single mean-cost estimate
for a budget-impact model, and quantile regression when the question is
genuinely about a specific point in the distribution.

The second regression family here is for ordinal outcomes — Likert-scale
patient-reported outcomes (PROs), staged disease severity, anything with
ordered categories but no meaningful numeric distance between them.
Chapter 8 already introduced `MASS::polr()` for this, in the context of
mapping ordinal clinical descriptors to utility weights; the same
function applies directly to ordinal PRO analysis, so there's no need to
re-derive it here — see Chapter 8 for the syntax and interpretation of
the proportional-odds coefficients. An alternative with a richer set of
diagnostics and link-function options is `ordinal::clm()`, which uses
the same proportional-odds logic but is often preferred when you need
formal model comparison tools or non-logit links.

Both `polr()` and `clm()` rest on the *proportional-odds assumption*:
that the effect of each predictor is the same across every cut-point of
the ordinal scale (e.g. a treatment's effect on moving from "poor" to
"fair" is assumed equal to its effect moving from "good" to
"excellent"). This assumption is routinely *assumed* and rarely
*checked* in practice, which is a problem — it can fail, especially with
PRO scales that compress responses at one end.

#pitfall([
Proportional odds is a testable assumption, not a formality. A quick
check is to fit separate binary logistic models at each cut-point of the
ordinal outcome and see whether the coefficients for key predictors are
roughly stable across cut-points; a formal Brant-type test is also
commonly used, though it is not bundled directly into `MASS::polr()` and
typically requires a separate package or manual implementation. If the
assumption clearly fails, consider a partial proportional-odds model or
report cut-point-specific effects instead of a single pooled odds
ratio.
])

#difficult-terminology("Brant-type test")[
The proportional-odds model (used for ordinal outcomes — things with a
natural order but no fixed numeric scale, like a pain-severity rating
of none/mild/moderate/severe) makes a strong simplifying assumption:
that a predictor's effect is the *same* regardless of which cut-point
of the outcome you look at (e.g., "mild-or-worse vs. none" and
"severe vs. everything-else" are assumed to move by the same amount
for a one-unit change in the predictor). A Brant-type test is a formal
statistical check of that assumption — it compares the coefficients
estimated separately at each cut-point (as described in the paragraph
above) and produces a p-value testing whether those separate estimates
are statistically consistent with coming from one shared, constant
effect. A small p-value here is evidence the proportional-odds
assumption is shaky for at least one predictor, and you should consider
the alternatives mentioned above (a partial proportional-odds model, or
reporting cut-point-specific effects) rather than trusting a single
pooled odds ratio.
]

== 16.5 Machine learning for prediction and heterogeneity of treatment effect

Chapter 15 built the propensity-score and doubly-robust toolkit for
estimating an *average* treatment effect while adjusting for
confounding. Two questions that toolkit does not answer on its own: does
the treatment effect vary across patients, and which of many candidate
covariates actually matter? This section introduces the machine-learning
answers to both, kept deliberately narrow — one method per question, one
worked example each.

*Random forests for prediction.* `randomForest::randomForest()` and the
faster, more memory-efficient `ranger::ranger()` both fit ensembles of
decision trees for an outcome — useful when you want a flexible
prediction model (e.g. predicting 6-month treatment-failure risk from
baseline labs) without committing to a linear or logistic functional
form. Neither function, used this way, estimates a *treatment effect* —
they predict an outcome.

*Causal forests for treatment-effect heterogeneity.* To ask "does the
treatment effect itself vary by patient," the `grf` package's
`grf::causal_forest()` function grows a forest tuned specifically to
estimate individual-level treatment effects, not outcomes. It takes a
covariate matrix `X`, an outcome vector `Y`, and a treatment indicator
`W`, and returns per-observation treatment-effect estimates via
`predict()`. This is the ML-flexible cousin of Chapter 15's doubly-robust
estimators: where a DR estimator assumes a parametric (or semiparametric)
form for the propensity and outcome models, `causal_forest()` lets the
data determine, nonparametrically, *where* treatment effects are larger
or smaller — directly surfacing heterogeneity of treatment effect (HTE)
that a single DR average effect would hide.

```r
library(grf)

# X: baseline covariates, W: treatment (0/1), Y: outcome (e.g. treatment success)
cf <- causal_forest(X = as.matrix(tb_data[, c("age", "bmi", "baseline_chest_xray_score")]),
                     Y = tb_data$treatment_success,
                     W = tb_data$received_new_regimen)

# Per-patient estimated treatment effect
tau_hat <- predict(cf)$predictions
summary(tau_hat)
```

A rising spread in `tau_hat` across patients is evidence of HTE; `grf`
also provides `best_linear_projection()` and related diagnostics to
summarise *which* covariates drive it — useful for generating hypotheses
that a pre-specified subgroup analysis (§16.6) can then test formally.

#figure(
  image("../images/r_generated/ch16_causal_forest_hte.png", width: 85%),
  caption: [Distribution of per-patient estimated treatment effects (`tau_hat`) from `grf::causal_forest()` on a simulated TB-regimen dataset. The bimodal spread — one cluster near zero, another around 0.25-0.3 — is itself evidence of real heterogeneity: a single average effect (solid red line) would mask the fact that some patients benefit far more than others.]
) <fig-ch16-hte>

*LASSO and elastic net for variable selection.* When the candidate
covariate list is long relative to sample size — dozens of biomarkers,
comorbidity flags, or lab values — ordinary regression overfits.
`glmnet::glmnet(x, y, alpha = , lambda = )` fits penalised regression:
`alpha = 1` is the LASSO (shrinks many coefficients exactly to zero,
giving automatic variable selection), `alpha = 0` is ridge regression,
and values in between are the elastic net. `x` must be a numeric matrix
(not a formula/data-frame), and `lambda` controls penalty strength —
typically chosen by cross-validation with `cv.glmnet()` rather than set
by hand.

```r
library(glmnet)

x <- as.matrix(tb_data[, biomarker_cols])   # many candidate biomarkers
y <- tb_data$time_to_culture_conversion

fit <- cv.glmnet(x, y, alpha = 1)           # LASSO, lambda chosen by CV
coef(fit, s = "lambda.min")                  # non-zero coefficients = selected biomarkers
```

Use this as a screening step — to narrow forty biomarkers to five worth
carrying into a clinically-interpretable model — not as a replacement
for domain knowledge about which covariates are prognostic versus
effect-modifying (§16.6).

== 16.6 Subgroup analysis and effect modification

Subgroup analysis asks a simple question with a dangerous failure mode:
does the treatment effect differ between, say, HIV-co-infected and
HIV-negative TB patients? The question is legitimate. The danger is in
*how* it gets asked.

*Pre-specified versus exploratory.* A pre-specified subgroup analysis is
written into the statistical analysis plan before the data are
unblinded, naming the specific subgroups and the specific interaction
test, ideally with a stated biological or clinical rationale (ICH
E9(R1), already introduced in Chapter 7's estimand framework, requires
this kind of up-front specification for any subgroup finding intended to
support a treatment claim). An exploratory or post-hoc subgroup analysis
slices the data after the fact — by age, sex, region, baseline severity,
and whatever else is in the dataset — looking for "the subgroup where it
worked." Both have a place in a report, but only the first supports a
confirmatory claim.

#pitfall([
Testing treatment effects across many unplanned subgroups inflates the
false-positive rate the same way testing many outcomes does. Slice a
trial twenty different ways and, by chance alone, one or two subgroups
will show a "significant" interaction even when the true effect is
uniform. Label exploratory subgroup findings as hypothesis-generating,
not confirmatory, and do not let a favourable subgroup result rescue an
otherwise null overall result.
])

*Testing effect modification.* The formal test for whether a subgroup
modifies the treatment effect is an interaction term in a regression
model — not a pair of separate within-subgroup analyses. For a binary
outcome:

```r
fit <- glm(treatment_success ~ treatment * hiv_status + age + baseline_severity,
           data = tb_data, family = binomial())
summary(fit)   # coefficient on treatment:hiv_status is the test of effect modification
```

A significant `treatment:hiv_status` coefficient says the treatment
effect on the odds scale differs by HIV status; a non-significant one is
evidence *against* effect modification on that scale, though often
underpowered to detect it — subgroup interaction tests typically need
several times the sample size of the main-effect test.

*Displaying subgroup effects.* Once effect estimates are obtained within
each subgroup, the forest plot is the standard display — and the
mechanics are exactly the ones built in Chapter 11 for meta-analysis:
either a `ggplot2` point-and-error-bar plot, or `metafor::forest()`
applied to a set of subgroup-specific effect estimates and standard
errors in place of study-specific ones. No new plotting machinery is
needed here; only the question "study" versus "subgroup" changes.

#figure(
  image("../images/r_generated/ch16_subgroup_forest.png", width: 85%),
  caption: [A subgroup forest plot (ggplot2 point-and-error-bar, log odds-ratio scale) comparing the overall treatment effect against the HIV-positive and HIV-negative subgroups. The overlapping confidence intervals here would not meet a pre-specified threshold for a confirmed interaction — illustrating why the formal interaction test, not a pair of separate within-subgroup p-values, is the correct way to test effect modification.]
) <fig-ch16-subgroup-forest>

*Prognostic factor versus effect modifier, again.* Chapter 15 §15.3 drew
this distinction using a DAG: a prognostic factor predicts outcome
regardless of treatment, while an effect modifier changes the *size* of
the treatment effect itself, and only the latter justifies treatment
decisions that vary by subgroup. That distinction governs subgroup
analysis directly — a subgroup defined by a strong prognostic factor
(e.g. baseline disease severity) may show different *absolute* risks in
each arm without the treatment's relative effect differing at all.
Always check the interaction term before concluding that a subgroup's
apparently different results reflect true effect modification rather
than prognosis.

#difficult-terminology("DAG (directed acyclic graph)")[
A DAG is a diagram — boxes for variables, arrows for assumed
cause-and-effect — that makes your causal assumptions explicit and
checkable rather than leaving them implicit in your head. "Directed"
means every arrow has a direction (cause → effect, not just "these two
are associated"); "acyclic" means you can't follow the arrows in a loop
back to where you started (no variable can be its own cause, directly
or indirectly). For example, a simple DAG might show "disease severity
→ treatment choice" and "disease severity → outcome" and "treatment
choice → outcome": severity is a *confounder* here because it feeds
into both the thing you're choosing (treatment) and the thing you're
measuring (outcome), and you'd draw that structure before touching any
data, based on clinical knowledge. Epidemiologists and causal-inference
statisticians use DAGs precisely because they force you to commit, on
paper, to which variables you believe are confounders (common causes of
both exposure and outcome, which you must adjust for) versus which are
simply downstream consequences of treatment (which you must *not*
adjust for, since doing so can introduce bias rather than remove it).
You don't need to draw formal DAGs to use this book's methods, but
understanding that a DAG is simply "your causal assumptions, drawn out
and made explicit" demystifies why Chapter 15 leans on them so heavily.
]

#agency-note([
EMA's "Guideline on the investigation of subgroups in confirmatory
clinical trials" (EMA/CHMP/539146/2013) sets out regulatory expectations
for exactly this distinction: pre-specification, adequate power for
interaction tests, and caution against over-interpreting post-hoc
subgroup findings — the same principles argued for above, from the
regulator's side of the table.
])

Chapter 16 has moved from the single regression workhorses — linear,
logistic, Poisson/negative binomial, survival — through their
ML-flexible and heterogeneity-aware extensions. Part III's statistical
toolkit is now in place: estimating effects, adjusting for confounding,
pooling across studies, and characterising who responds differently.
Chapter 17 opens Part IV, Decision-Analytic Modelling, and shifts the
question from "what effect did we estimate" to "what should a health
system do about it" — starting with how to conceptualise a decision
model, choose a model type, and document its structure before a single
cost or probability is ever entered.
