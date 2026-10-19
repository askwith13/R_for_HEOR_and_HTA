#import "../common.typ": *

= Chapter 8. Health-Related Quality of Life and Utilities

#learning-objectives((
  [Distinguish generic preference-based instruments (EQ-5D, SF-6D, HUI) from disease-specific instruments, and explain why HTA reference cases require the former for the primary QALY calculation.],
  [Score EQ-5D health-state profiles into utility indices using R's `eq5d` package and a correctly-chosen country value set.],
  [Build and validate a mapping (cross-walk) algorithm to predict EQ-5D-equivalent utilities from a disease-specific instrument.],
  [Analyse bounded, ceiling-spiked utility data with censored regression, beta regression, or finite mixture models rather than naive OLS.],
  [Apply utility decrements and age/sex-adjustment correctly within a decision-analytic model, and layer background mortality onto disease-specific mortality.],
  [Explain the three classic utility-elicitation methods — time trade-off, standard gamble, and discrete choice experiments — and how they underlie value-set construction.],
))

Chapter 7 closed by flagging that missing utility values are often a symptom of the instrument, elicitation method, and measurement timing chosen for a trial — this chapter picks that thread up directly and covers how utilities are measured, valued, and modelled in the first place.

== 8.1 Generic and disease-specific instruments (EQ-5D, SF-6D, HUI, etc.)

A utility, in the HEOR sense that Chapter 4 introduced, is a single number that expresses how good or bad a health state is, anchored so that 1 represents full health and 0 represents dead. States judged worse than death carry negative values, which is exactly why Chapter 7 flagged the UK EQ-5D-3L tariff's floor of roughly $-0.59$. Utilities exist to do one specific job: they are the weight multiplied by time to convert raw life-years into quality-adjusted life-years. A year spent at utility 0.7 contributes 0.7 QALYs; a year at utility 1.0 contributes a full QALY. Everything in this chapter is really about how that single number gets produced, and the honest limitations of the instruments that produce it.

The instruments used to generate utilities fall into two broad families. The first is the generic, preference-based, multi-attribute family. These describe health using a small number of dimensions that are meant to apply to essentially anyone, regardless of diagnosis, and each possible combination of dimension levels has (or can be assigned) a population-derived preference weight. EQ-5D is the dominant example. EQ-5D-3L covers five dimensions — mobility, self-care, usual activities, pain/discomfort, and anxiety/depression — each scored at one of three levels (no problems, some problems, extreme problems), giving $3^5 = 243$ possible health states. EQ-5D-5L uses the same five dimensions but expands each to five levels (no, slight, moderate, severe, extreme problems), giving $5^5 = 3125$ states and materially reducing ceiling effects at the "no problems" end. SF-6D is derived from the longer SF-36 or shorter SF-12 health-status questionnaires by selecting a subset of items that map onto six dimensions (physical functioning, role limitations, social functioning, pain, mental health, and vitality) and applying preference weights to that subset. HUI2 and HUI3, the Health Utilities Index instruments, use their own dimension sets — HUI3, the more commonly used of the two, covers vision, hearing, speech, ambulation, dexterity, emotion, cognition, and pain, each with multiple levels. All of these are "generic" in that the dimensions were chosen to be meaningful across disease areas, and all are "preference-based" in that someone, somewhere, ran a valuation study asking members of the public to trade off time or risk against being in a described health state, and used those responses to build the scoring weights — the value set or tariff that Section 8.2 unpacks.

The second family is disease-specific instruments: questionnaires built to capture the symptoms and functional domains that matter most within one condition. A TB treatment trial might use a TB-specific symptom and quality-of-life questionnaire tracking cough, sputum, fever, and treatment-related adverse effects; an oncology trial might use the EORTC QLQ-C30 or a tumour-specific module. These instruments are often considerably more sensitive to clinically meaningful change within the disease they were built for, because every item was chosen for its relevance to that condition, rather than for being a dimension that also has to make sense for, say, a hip-replacement patient or someone with depression.

This is precisely where the generic-versus-disease-specific trade-off becomes unavoidable for anyone doing HTA work. NICE's reference case, and comparable guidance under development for HTAIn, requires a generic preference-based instrument (EQ-5D specifically, for NICE) for the QALYs used in the base-case cost-effectiveness analysis. The reason is structural, not a matter of taste: resource-allocation bodies are routinely comparing a TB regimen against a cardiology intervention against an oncology drug, all competing for the same budget against the same willingness-to-pay threshold $lambda$. That comparison is only coherent if "1 QALY" means the same thing regardless of which disease produced it, and that requires a common, cross-disease utility currency — which is exactly what a generic preference-based instrument is designed to supply, and what a disease-specific instrument, by construction, is not. A disease-specific score has no population preference weighting behind it and no natural anchor at 0 = dead and 1 = full health; it cannot be substituted directly into a QALY calculation without some bridge back to a utility scale, which is the mapping (or "crosswalk") problem that Section 8.3 takes up.

The honest cost of this requirement is sensitivity. Because EQ-5D's five dimensions are broad and generic, a TB treatment effect that substantially reduces cough and sputum but leaves mobility, self-care, usual activities, pain, and anxiety largely unchanged may show little or no movement on EQ-5D, even though patients and clinicians would recognise a real improvement. This is a known, published limitation, not a flaw to paper over: trial teams frequently collect both a generic preference-based instrument (for the regulatory/HTA utility) and a disease-specific instrument (for clinical sensitivity and secondary endpoints) side by side, precisely because neither alone tells the whole story.

#heor-practice[When you see a trial report a large, clinically important improvement on a disease-specific QoL questionnaire alongside a flat or barely-moved EQ-5D utility, do not assume the EQ-5D data is wrong or the analyst mis-scored it. Check first whether the dimensions EQ-5D captures are the ones the disease actually affects — a TB regimen that resolves cough and fatigue but doesn't touch mobility or self-care can legitimately show a small EQ-5D gain despite a genuinely better patient experience. The instrument's breadth, not an error, is usually the explanation.]

== 8.2 Value sets and scoring in R (eq5d)

An EQ-5D questionnaire, on its own, only produces a health-state description — a short string of digits, one per dimension, recording the level the respondent selected. For EQ-5D-5L this looks like "11223": no problems with mobility, no problems with self-care, slight problems with usual activities, moderate pain/discomfort, moderate anxiety/depression. That string is not yet a utility. Turning it into a single number anchored at 1 (full health) and 0 (dead) requires a value set, often called a tariff: a table of preference weights, one for every possible combination of dimension levels, derived from a population valuation study. For the UK EQ-5D-3L value set, those weights came from a time trade-off (TTO) study fielded in a representative sample of the UK public, in which respondents were asked to trade years of life in an impaired health state against fewer years in full health; the EuroQol Group's EQ-5D-5L valuation protocol (covered in more depth in Section 8.6) extended this with a combined TTO and discrete choice experiment design. The crucial point is that a value set is country-specific: it reflects the preferences of the population it was elicited in, and different countries' general publics do not value the same health-state descriptions identically.

This is where the CRAN package `eq5d` (Craig, Pickard, and colleagues) becomes the practical tool. Its central function, `eq5d()`, takes a data frame of respondent-level dimension scores — the digit-per-dimension profile for either the 3L or 5L version — and an argument specifying which national value set to apply, returning a single utility index per respondent computed against that value set's published weights. The package bundles several countries' published value sets so that the same health-state profile can be scored consistently against, say, a UK tariff or a different country's tariff, without the analyst having to hand-code the weight lookup. (If you need the exact argument names and value-set codes, check `?eq5d` in your installed version rather than relying on a syntax from memory — argument spellings and the set of bundled countries have evolved across package releases.)

A toy workflow illustrates the shape of the task, independent of the exact argument names your installed version expects:

```r
library(eq5d)

# Toy EQ-5D-5L health state profiles: one row per patient,
# one column per dimension (mobility, self-care, usual activities,
# pain/discomfort, anxiety/depression), each scored 1-5.
health_states <- data.frame(
  MO = c(1, 2, 3),
  SC = c(1, 1, 2),
  UA = c(2, 2, 3),
  PD = c(2, 3, 4),
  AD = c(1, 2, 3)
)

# Conceptual scoring step: apply a named country value set to convert
# each row's digit profile into a utility index anchored at 1 = full
# health, 0 = dead. Consult ?eq5d in your installed version for the
# exact argument names/spelling before running this on real data.
# utilities <- eq5d(scores = health_states, version = "5L", country = "UK")
# utilities
```

The reason the country argument matters so much is not a technicality — it is a well-documented source of real HTA submission errors. A UK NICE submission scored against a US value set (or vice versa) will produce numerically different utilities for the identical health-state description, because the two populations' revealed preferences for, say, "extreme pain/discomfort" are not the same. NICE's reference case expects EQ-5D-3L scored with the UK value set specifically (with EQ-5D-5L data generally expected to be mapped onto the 3L value set per NICE's published position, rather than scored with an EQ-5D-5L value set directly) — using the wrong country's tariff, or the wrong version-to-value-set pairing, is a substantive methodological error, not a stylistic choice, and reviewers will query it.

This also bears directly on HTAIn's situation. India does not yet have as long-established and widely validated a national EQ-5D value set as the UK's; a UK-style TTO valuation study in a representative Indian population is a substantial undertaking that has only partially matured. In practice, analysts working on Indian HTA submissions have sometimes relied on a crosswalk or value-set transfer from another country (or a regional proxy) as a pragmatic substitute, flagging it explicitly as a limitation rather than treating it as equivalent to a locally-derived tariff. That gap — and what a defensible crosswalk does and doesn't justify — is exactly the kind of LMIC-relevant methods question worth tracking as India's own value-set work progresses.

#agency-note[NICE's "NICE health technology evaluations: the manual" (PMG36) sets out the reference-case preference for EQ-5D as the measure of health-related quality of life for the UK reference case, with EQ-5D-3L (UK value set) as the default and specific guidance on how EQ-5D-5L data should be handled in relation to it. If you are preparing a submission that leans on EQ-5D utilities, check the current PMG36 text directly rather than relying on a secondary summary — NICE's position on 5L-to-3L handling has been updated over time.]

== 8.3 Mapping algorithms (cross-walks and regression-based mapping)

Trials rarely collect every outcome measure an HTA body will eventually want. A pragmatic trial in TB treatment-shortening might collect a disease-specific symptom score or a clinical endpoint like time-to-culture-conversion; an oncology trial might collect FACT-G or an EORTC QLQ module. These instruments are excellent at detecting disease-specific change but they do not, by themselves, produce a generic preference-based utility value. An HTA reference case, however, almost always demands a utility anchored to a generic instrument such as EQ-5D, because that is what lets the QALY calculation sit on a common scale across disease areas and across submissions. When a trial has not collected EQ-5D at all, or has collected it too sparsely to be usable, the analyst is stuck with a dataset that has the clinical story but not the utility currency the model needs.

The standard fix is "mapping," sometimes called cross-walking. The logic is: find (or commission) an external dataset, ideally in a similar patient population, where both the disease-specific instrument and EQ-5D were administered to the same people at the same time. Fit a statistical model in that external dataset that predicts an EQ-5D-equivalent utility from the disease-specific scores. Then apply that fitted algorithm to the trial's disease-specific scores to generate predicted utilities for the economic model. The trial itself may never have asked a single EQ-5D question; the mapping algorithm substitutes for that missing measurement, provided the external dataset is a defensible match for the trial population and condition severity range.

There are two broad families of mapping approach, and the distinction matters for how much of EQ-5D's internal structure survives the exercise.

#list(
  [*Direct (response) mapping* models each EQ-5D dimension separately — for the 3L instrument, mobility, self-care, usual activities, pain/discomfort, and anxiety/depression, each with its own ordered response levels. Because the dimension responses are ordered categorical outcomes rather than continuous ones, this is typically done with multinomial or, more naturally given the ordering, proportional-odds ordinal regression — `MASS::polr()` is the standard base-R-adjacent tool for a single ordinal dimension, fit once per dimension against the predictors derived from the disease-specific instrument. The predicted dimension-level response profile for each respondent is then run back through the standard EQ-5D value set to produce a predicted utility. This route is more faithful to how EQ-5D utilities are actually constructed — it respects the fact that a utility index is a deterministic function of five discrete dimension responses, not a free-floating continuous number — but it means fitting and maintaining five separate models and then composing them correctly through the value set algebra.],
  [*Indirect (utility/value) mapping* skips the dimension-level detail entirely and regresses the EQ-5D utility index itself — the single number that comes out after the value set has already been applied — directly against the disease-specific scores, using ordinary regression methods such as `lm()` or a generalized linear model via `glm()`. This is markedly simpler to specify, fit, and report, and is the more common choice in practice precisely because of that simplicity. The cost is that it throws away the compositional structure of EQ-5D — two very different dimension profiles can map to the same utility value, and the model has no way to represent that heterogeneity or to use dimension-specific external information.],
)

Whichever family is chosen, the indirect route has a well-known statistical trap: fitting `lm()` directly to a continuous utility index via ordinary least squares is a common choice in the mapping literature but a theoretically poor one. EQ-5D utility values are not normally distributed — they are bounded above at 1.0 (full health), often have a visible spike or clustering of observations exactly at that ceiling, and are left-skewed with a long tail toward poor health states and, for 3L value sets, can take values below zero. OLS assumes none of that: it allows predicted values above 1.0 or in otherwise impossible regions, and its homoscedastic-normal-error assumption is a poor description of a variable with a boundary spike. This is exactly the motivation for the more careful bounded-outcome methods covered in SS8.4 — censored regression, beta regression, and mixture models — all of which are designed to respect the ceiling and the skew that OLS ignores.

#difficult-terminology("homoscedasticity")[
Homoscedasticity is the assumption, built into ordinary linear regression, that the "scatter" of errors around the fitted line is roughly the same size everywhere — whether you're predicting a utility of 0.9 or 0.3, the model assumes the typical prediction error is about the same magnitude. (Its opposite, *heteroscedasticity*, means the scatter changes depending on where you are on the scale.) A clinical analogy: imagine measuring blood pressure readings in a cuff that's equally noisy whether the true reading is 90 or 190 — that's homoscedastic. EQ-5D utility data violate this badly: close to the 1.0 ceiling, a large fraction of respondents report exactly full health, so the "noise" clusters tightly at that boundary, while scatter for people in poorer health states can be much wider. Fitting OLS anyway doesn't just produce a slightly-off standard error — the model is implicitly assuming a pattern of noise that the data visibly don't have, which is part of why beta regression and mixture models (built to handle changing variance near a boundary) are preferred for this kind of outcome.
]

A mapping algorithm is only as trustworthy as its out-of-sample performance, and this is where submissions are most often challenged. Fitting a model in the external dataset and reporting how well it fits that same data (in-sample R-squared, in-sample residuals) tells a reviewer almost nothing about how the algorithm will behave when applied to a different trial population. The expected standard is some form of cross-validation — holding out a fold of the external dataset, fitting on the remainder, predicting the held-out fold, and reporting the discrepancy, typically as mean absolute error (MAE) or root-mean-squared error, between predicted and observed EQ-5D utilities. Algorithms that perform well on average but poorly at the extremes of the health-state range (very good or very poor health, which is often exactly where trial arms diverge) deserve particular scrutiny, because that is precisely the region driving the incremental QALY gain the economic model is built to estimate.

== 8.4 Analysing utility data: censoring, bounded distributions, beta regression, mixture models

Once utility values are in hand — whether collected directly via EQ-5D in the trial or produced by a mapping algorithm as in SS8.3 — the temptation is to treat them like any other continuous outcome and reach for `lm()`. Resist that temptation. EQ-5D utility distributions have a shape that ordinary linear regression's assumptions do not describe well. Full health (utility = 1.0) is a genuinely common and clinically meaningful response, so in most patient samples there is a visible spike or clustering of observations exactly at 1.0 — a ceiling effect, not a coincidence of rounding. Below that ceiling, the remaining distribution is typically left-skewed, with a longer tail stretching toward poorer health states. For 3L-style value sets that permit utilities below zero (states considered worse than death), there can be a further discontinuity or secondary clustering near or below zero. A method that assumes symmetric, unbounded, constant-variance normal errors — exactly what OLS assumes — will routinely predict impossible values above 1.0, misrepresent the variance near the ceiling, and bias both point estimates and confidence intervals.

Three families of real, well-documented approaches handle this more honestly.

#list(
  [*Censored (Tobit-style) regression* treats the ceiling at 1.0 (and, where relevant, a floor) as genuine censoring rather than noise: the "true" underlying health preference may extend above 1.0 for some respondents, but the EQ-5D scale cannot record it, so observations piled at the boundary are modelled as censored rather than as ordinary data points. Two real CRAN packages implement this for utility-type data: `VGAM::vglm()`, which supports a tobit family among its very large catalogue of vector generalized linear/additive models, and the purpose-built `censReg` package, whose `censReg()` function fits Tobit-type censored regression with a syntax close to `lm()`/`glm()`. Either is a legitimate choice; `censReg()` is the more direct and commonly cited for univariate ceiling-censored utility outcomes.],
  [*Beta regression* exploits the fact that, apart from the boundary spikes, a utility index confined to (0, 1) looks much like a Beta-distributed variable — flexible enough to capture skew and heteroscedasticity that increases or decreases near the bounds. The practical obstacle is that the Beta distribution is defined on the *open* interval (0, 1), excluding the exact endpoints, while real utility data routinely contain exact 1s (and exact 0s for some value sets). The standard workaround is a small linear rescaling of the outcome before fitting — squeezing the data just inside (0, 1) — after which the `betareg` package's `betareg()` function fits the regression with a logit (or other) link on the mean and, optionally, a separate model for the precision/dispersion parameter.],
  [*Finite mixture models* take the ceiling spike seriously as a distinct subpopulation rather than an inconvenience to transform away: conceptually, the observed data are treated as a mixture of a point mass exactly at 1.0 (representing respondents in full health) and a continuous component, such as a Beta or truncated normal distribution, describing everyone else. The model estimates both the mixing proportion (what fraction of the sample sits at the ceiling) and the parameters of the continuous piece, which can better represent the genuinely bimodal-looking shape of utility data than beta regression alone. This is more involved to specify and fit; `flexmix` is a real CRAN package for finite mixture modelling in R and is a reasonable starting point if this route is pursued, though for most submissions a beta regression with a sensible rescaling is the practical default.],
)

A worked example with beta regression on a small toy EQ-5D-type dataset, illustrating the rescaling step and the model fit:

```r
library(betareg)

# toy utility data: mix of observations with a visible ceiling spike
set.seed(123)
n <- 200
age <- round(rnorm(n, 55, 12))
severity <- sample(c("mild", "moderate", "severe"), n, replace = TRUE,
                    prob = c(0.4, 0.4, 0.2))

# simulate utilities with ceiling clustering at 1.0
raw_utility <- pmin(1, rbeta(n, 6, 2) + ifelse(severity == "mild", 0.15, 0))

df <- data.frame(utility = raw_utility, age = age, severity = severity)

# betareg requires outcomes strictly inside (0, 1); rescale to avoid
# exact boundary values using the standard Smithson-Verkuilen transform
n_obs <- nrow(df)
df$utility_resc <- (df$utility * (n_obs - 1) + 0.5) / n_obs

fit_beta <- betareg(utility_resc ~ age + severity, data = df)
summary(fit_beta)

# predicted mean utilities on the original scale
df$pred_utility <- predict(fit_beta, type = "response")
```

The fitted coefficients are on the logit-of-the-mean scale, so they describe proportional shifts toward or away from full health rather than additive utility-point changes — a feature, not a bug, given the bounded outcome, but one that needs stating explicitly when results are reported to a non-technical HTA reviewer.

#difficult-terminology("logit link (in beta regression)")[
A "link function" is the piece of machinery that lets a regression model handle an outcome that isn't a plain, unbounded continuous number — it's a mathematical conversion applied before fitting, then reversed afterward for interpretation. The logit link specifically takes a value confined to (0, 1) — like a probability, or here a rescaled utility — and stretches it onto an unbounded scale running from minus infinity to plus infinity, via the formula $log(p / (1-p))$. Ordinary regression machinery, which is built to predict any real number, can then operate freely on that stretched scale without ever risking a prediction outside (0, 1); converting the fitted line's predictions back through the inverse logit guarantees every predicted value lands back between 0 and 1, no matter how extreme the predictors are. It's conceptually identical to the logistic regression you may already know from predicting a binary clinical outcome (e.g. mortality) — same transformation, same reason for using it (keeping predictions between 0 and 1) — just applied here to a continuous utility mean rather than a 0/1 outcome. The practical consequence, as the previous paragraph notes, is that beta-regression coefficients describe *proportional* movement toward or away from full health, not a fixed number of utility points per unit of the predictor — so a coefficient can't be read the same way an OLS coefficient would be.
]

Before any regression is reported, a submission should show the descriptive shape of the utility data the model is addressing — mean utility by subgroup alongside the proportion of observations sitting exactly at the ceiling, since that ceiling spike is the whole reason OLS was rejected in favour of beta regression:

#report-table(
  [Mean (SD) EQ-5D-type utility and ceiling-spike proportion by disease severity subgroup, toy dataset],
  academic-table(
    columns: (1.6fr, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    header: ([*Severity*], [*N*], [*Mean utility*], [*SD*], [*% at ceiling (= 1.0)*]),
    body: (
      [Mild], [71], [0.892], [0.114], [25.4%],
      [Moderate], [83], [0.719], [0.159], [0.0%],
      [Severe], [46], [0.752], [0.159], [0.0%],
    ),
    footer: (table.cell(colspan: 5)[*Total N = 200*],),
  ),
) <tab-ch08-utility-by-severity>

#pitfall[Fitting `lm()` directly to a raw EQ-5D utility index, or handing over a mapping algorithm built in SS8.3 without reporting its out-of-sample predictive performance, are two sides of the same error: both substitute a convenient method for a validated one. OLS on a ceiling-spiked, bounded outcome can predict utilities above 1.0 and will misstate uncertainty exactly where the incremental QALY calculation is most sensitive. A mapping algorithm reported only with in-sample fit statistics tells a reviewer nothing about how it behaves on a different trial population. Before either is used in a submission, show cross-validated performance — MAE or RMSE on held-out data for a mapping algorithm, and residual/ceiling diagnostics for a utility regression — not just a coefficient table.]

== 8.5 Utility decrements, age-adjusted utilities and background mortality

A *utility decrement* is the loss in health-state utility associated with a specific clinical event, adverse event, or disease complication, expressed relative to some baseline utility. For example, a grade 3-4 chemotherapy-related adverse event might carry a utility decrement of around -0.05 to -0.10, applied for the duration the event is assumed to affect the patient (often a single model cycle, sometimes longer for persistent toxicities). Rather than measuring these decrements directly in every trial — which would require administering EQ-5D or SF-6D specifically during the adverse event window, something many trials never do — modellers routinely pull decrements from the published literature. This is the same literature-as-data-source logic introduced in Chapter 5's discussion of secondary utility sources (SS5.3), operationalised through the systematic literature review methodology covered in Chapter 6: a systematic search identifies prior utility studies in the relevant condition, and the decrement estimates feed into the decision-analytic model as model inputs with their own uncertainty distributions, rather than being derived from the trial dataset at hand.

Within a decision-analytic model — the Markov cohort models and decision trees that Chapters 17-20 build out in full — decrements are combined with a baseline health-state utility in one of two ways:

#list(
  [*Additive*: utility = baseline utility + decrement (where the decrement is negative), e.g. 0.75 - 0.08 = 0.67 while the adverse event is active.],
  [*Multiplicative*: utility = baseline utility × (1 + proportional decrement), e.g. 0.75 × (1 - 0.10) = 0.675.],
)

Both are common in practice, and for a single decrement the numerical difference is often small. The choice matters more once several decrements, age-adjustments, and disease-progression utility changes are stacked across a long time horizon, as discussed below.

A related but distinct concept is *age-adjustment*. Health-state utility is not a fixed property of a diagnosis alone; a patient's rating of their own health, and the population reference values against which models are often calibrated, tend to decline with age even among people who are otherwise well. General-population EQ-5D normative (reference) data, published for many countries alongside the country-specific value-set studies discussed in SS8.3, report mean utility by age band and sex — typically declining from values close to 1 in young adults into the 0.7-0.8 range in the oldest age bands, with some variation by value set. This matters because a disease-specific "full health" utility estimated in, say, a trial population with a mean age of 45 should not simply be projected unchanged onto a modelled cohort that ages into its 70s and 80s over a long time horizon; doing so would imply a disease-free elderly cohort member is healthier than the general elderly population, which is implausible.

The conventional fix is a *multiplicative age/sex-adjustment*: the disease-specific utility is scaled by the ratio of the population norm utility at the cohort's current age/sex to a fixed reference (often the norm at trial baseline age, or simply applied as utility(disease) × norm(age, sex) / norm(baseline age, sex)). This keeps the disease utility anchored to how the general population's health is expected to decline, without requiring a separate age-specific disease-utility estimate for every cycle. A purely *additive* age adjustment (subtracting a fixed age-related decrement each cycle) is simpler to code but is more prone to producing negative or clearly implausible utilities once combined with several other additive decrements (treatment toxicity, disease progression, comorbidity) over a 20- or 30-year model horizon — there is no multiplicative floor stopping the cumulative subtraction from running arbitrarily low. Multiplicative approaches, by contrast, naturally compress toward (but rarely cross) zero, which is one reason HTA bodies and modellers often prefer them for long-horizon cohort models, alongside the practical argument that proportional age decline is closer to what the normative data actually show.

Background mortality is the other half of keeping a long-horizon Markov model plausible, and it connects directly to Chapter 4's treatment of discounting and half-cycle correction. A cohort trace needs an age- and sex-specific *all-cause* (background) mortality rate — typically sourced from a national life table — layered on top of any disease-specific mortality transition estimated from trial or registry data. Without this, the model would implicitly assume that a cohort member who survives the disease being modelled never dies of anything else, which overstates survival and therefore overstates total QALYs and costs accrued in later cycles. The half-cycle correction from Chapter 4 still applies here: since death (from either cause) is assumed to occur, on average, mid-cycle rather than precisely at cycle boundaries, failing to half-cycle-correct the mortality-driven QALY accrual introduces a small but systematic bias, compounding over discounted future cycles.

A simple illustration of an age-band multiplier applied to a toy disease utility:

```r
# toy age-band utility multipliers (illustrative, not a real norm dataset)
age_norms <- data.frame(
  age_band = c("18-44", "45-54", "55-64", "65-74", "75+"),
  norm_utility = c(0.93, 0.88, 0.83, 0.78, 0.72)
)

baseline_disease_utility <- 0.80   # disease-specific utility at trial baseline age
baseline_norm <- age_norms$norm_utility[age_norms$age_band == "45-54"]

age_adjust <- function(age_band, disease_utility = baseline_disease_utility) {
  norm_now <- age_norms$norm_utility[age_norms$age_band == age_band]
  disease_utility * (norm_now / baseline_norm)
}

sapply(age_norms$age_band, age_adjust)
```

The resulting age-banded utilities are exactly what belongs in a model-inputs table, since a reviewer needs to see the population norm, the derived multiplier, and the resulting age-adjusted disease utility side by side rather than re-deriving them from the code:

#report-table(
  [Multiplicative age-adjustment of a toy disease-specific utility (baseline 0.80 at age 45-54) against general-population EQ-5D norms],
  academic-table(
    columns: (1.2fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Age band*], [*Population norm utility*], [*Norm ratio vs. baseline band*], [*Age-adjusted disease utility*]),
    body: (
      [18-44], [0.93], [1.057], [0.846],
      [45-54 (baseline)], [0.88], [1.000], [0.800],
      [55-64], [0.83], [0.943], [0.754],
      [65-74], [0.78], [0.886], [0.709],
      [75+], [0.72], [0.818], [0.655],
    ),
    footer: (table.cell(colspan: 4)[Age-adjusted disease utility = baseline disease utility (0.80) × (norm utility at current age band / norm utility at baseline band). Norms are illustrative toy values, not a published national dataset.],),
  ),
) <tab-ch08-age-adjusted-utility>

This multiplicative rescaling ensures that as the modelled cohort ages into the "75+" band, its disease-specific utility is pulled down in proportion to the expected population-level decline, rather than being held artificially constant or subtracted down to an implausible floor.

== 8.6 Time trade-off, standard gamble and discrete choice experiments

The value sets and tariffs introduced in SS8.2 — the algorithms that convert an EQ-5D-5L or SF-6D health-state description into a single index utility — are not estimated from thin air. They are built from general-population preference elicitation exercises using one of a small number of classic methods, each asking respondents to make trade-offs that reveal how much they value one health state relative to another, or relative to death.

*Time Trade-Off (TTO)* is the method underlying the majority of existing EQ-5D value sets, including the original EQ-5D-3L sets and many EQ-5D-5L sets produced using the EuroQol Group's standard protocol. A respondent is asked to choose between living a fixed duration $T$ years in an impaired health state, versus living a shorter duration $x < T$ years in full health followed by death. The duration $x$ is varied (typically via an iterative "ping-pong" or titration procedure in a face-to-face interview) until the respondent is indifferent between the two options. At that indifference point, the utility of the impaired health state is simply $x/T$. TTO is relatively intuitive to administer — people readily grasp the idea of trading survival time for better health — but it is not strictly grounded in expected utility theory, since no uncertainty or gamble is involved; it is better thought of as a theoretically simpler, practically convenient elicitation task.

*Standard Gamble (SG)* is the method with the most direct theoretical grounding, rooted in von Neumann-Morgenstern expected utility theory. Here the respondent chooses between a certain outcome (living in the impaired health state for the remainder of life) and a gamble with probability $p$ of achieving full health and probability $1-p$ of immediate death. The probability $p$ is varied until the respondent is indifferent between the certain health state and the gamble; the utility of the health state is then read off directly as that indifference probability $p$. Because SG explicitly incorporates risk and is derived from axioms about rational choice under uncertainty, health economists have historically regarded it as the theoretically "purer" utility measure — though it is cognitively more demanding to administer, and respondents' answers can be sensitive to how probabilities are communicated, which is part of why TTO has been more widely adopted for large-scale value-set surveys.

*Discrete Choice Experiments (DCE)* take a different approach entirely. Rather than trading a single health state off against survival duration or a probability of death, respondents are shown repeated pairs (or sometimes larger sets) of hypothetical health-state profiles — each profile described by levels across the instrument's dimensions — and simply pick which of the two they prefer. No explicit trade-off against death or duration is built into any single choice task. Preference weights are instead recovered statistically from the pattern of choices across many respondents and many choice pairs, typically using a conditional logit or multinomial logit model that estimates how much each dimension level contributes to the probability of a profile being chosen. Because a DCE alone only yields utilities on an arbitrary scale anchored between the best and worst profiles shown, many modern value-set studies combine DCE with a smaller TTO or SG component (a "DCE with duration" or "DCE-TTO" hybrid design) specifically to anchor the resulting scale onto the conventional dead = 0, full health = 1 metric needed for QALY calculation. This hybrid DCE-based approach is the method underlying several of the newer EQ-5D-5L value sets, and it is a practical option increasingly considered where a country does not yet have its own long-established TTO-based value-set tradition to extend, since DCE fieldwork can be logistically lighter than face-to-face TTO interviewing at national scale.

#agency-note[When sourcing or reporting a country's EQ-5D value set methodology for an HTA submission, check the elicitation method and protocol version against the EuroQol Group's published EQ-5D-5L valuation protocol, and confirm the chosen value set matches the preference stated in the relevant reference-case guidance (for UK submissions, NICE's Health Technology Evaluations Manual sets out the expected utility value sourcing hierarchy) — do not assume a TTO-based and a DCE-based value set for the same instrument are numerically interchangeable.]

In R, DCE choice data — typically structured as matched sets of chosen/not-chosen profiles per respondent per task — can be analysed with the `mlogit` package, which fits multinomial and conditional logit models to this kind of panel choice data, or with `survival::clogit()` for a conditional logistic regression formulation when each choice set is treated as a matched stratum. Either route estimates a coefficient for each attribute level, which, once anchored and rescaled, becomes the attribute-level preference weight feeding into the value-set algorithm.

A value-set methodology section conventionally summarises the three elicitation methods side by side, since a reviewer needs to see at a glance which theoretical grounding, response burden, and anchoring approach underlies the tariff being used:

#ref-table(
  [Comparison of TTO, SG and DCE elicitation methods used in EQ-5D value-set construction],
  academic-table(
    columns: (1.4fr, 1.6fr, 1.2fr, 1.4fr),
    align: (left, left, left, left),
    header: ([*Method*], [*Elicited quantity*], [*Theoretical basis*], [*Anchoring to dead = 0*]),
    body: (
      [Time Trade-Off (TTO)], [Indifference duration $x$ in full health vs. $T$ years impaired], [Practical/intuitive, not expected-utility-theoretic], [Direct: $x/T$],
      [Standard Gamble (SG)], [Indifference probability $p$ of full health vs. death], [von Neumann-Morgenstern expected utility theory], [Direct: utility $= p$],
      [Discrete Choice Experiment (DCE)], [Choice between pairs of health-state profiles, no survival/death trade-off], [Random utility theory (McFadden)], [Indirect: requires a TTO/SG anchoring component],
    ),
    footer: none,
  ),
) <tab-ch08-elicitation-methods>

#difficult-terminology("random utility theory (McFadden)")[
Random utility theory is the statistical theory underlying discrete choice experiments (and much of modern choice modelling generally, including travel and marketing research — it's named after the economist Daniel McFadden, who won a Nobel Prize partly for this work). Its core idea: when a person chooses between two options (here, two hypothetical health-state profiles), each option has some "true," fixed underlying attractiveness to that person (its utility) — but on top of that, there's a random, unpredictable wobble in each specific choice, because people aren't perfectly consistent decision machines, moods vary, and attention lapses happen. No individual choice tells you much on its own, since you can't separate the "true" attractiveness from that day's wobble. But across hundreds of choices made by many respondents, the random wobbles average out, and statisticians can work backward from the *pattern* of choices to estimate how much each attribute (e.g. pain level, mobility limitation) contributes to overall attractiveness on average. This is exactly why a DCE needs many repeated choice tasks per respondent rather than a single question, unlike TTO or SG which can, in principle, extract a usable answer from one careful elicitation.
]

Utilities and costs are the two halves of the cost-per-QALY pair this book has worked with since Chapter 4's introduction of the WTP threshold; having now covered how the utility half is measured, valued and modelled, Chapter 9 turns to its counterpart — costs and resource use.
