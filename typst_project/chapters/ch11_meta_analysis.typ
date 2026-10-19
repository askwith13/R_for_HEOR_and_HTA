#import "../common.typ": *

= Chapter 11. Meta-Analysis

#learning-objectives((
  [Fit fixed-effect and random-effects meta-analysis models with `meta` (`metabin()`, `metacont()`, `metagen()`) and `metafor` (`rma()`) (§11.1)],
  [Quantify and interpret between-study heterogeneity using $Q$, $tau^2$, and $I^2$, and read a forest plot (§11.2)],
  [Screen for publication bias and small-study effects with funnel plots, Egger's test, and trim-and-fill (§11.3)],
  [Explain heterogeneity with meta-regression using `metafor::rma()`'s `mods=` argument, and recognise its limits (§11.4)],
  [Pool hazard ratios on the log scale for time-to-event outcomes, and connect the result to Chapter 10's extrapolation machinery (§11.5)],
  [Fit a bivariate random-effects model for diagnostic test accuracy with `mada::reitsma()` and read an SROC curve (§11.6)],
  [Pool single-group proportions and rates with variance-stabilising transformations (logit, double-arcsine, log) (§11.7)],
))

Chapter 10 pooled nothing: it took one study's individual patient data
and built one extrapolated survival curve from it. This chapter is
about a different, very common situation — you have *several separate
studies*, each already analysed on its own, and you need one combined
answer. Here is the roadmap. §11.1 covers the first choice you make:
fixed-effect or random-effects pooling. §11.2 and §11.3 cover two
checks every pooled result needs before you trust it — how much the
studies disagree (heterogeneity) and whether missing studies might be
skewing the picture (publication bias). §11.4 asks *why* studies
disagree. §11.5, §11.6 and §11.7 then apply all of this to three
outcome types you will meet often in TB-programme work: time-to-event
hazard ratios (which feed straight back into Chapter 10's
extrapolation), diagnostic test accuracy, and single-group prevalence
or incidence rates. Read the sections in order — each one assumes the
last.

== 11.1 Fixed-effect and random-effects models

When a TB programme review pools results from, say, eight observational studies on treatment success rates under different regimens, the first decision is not which R function to call but which question you are asking. A *fixed-effect* (sometimes written "common-effect") model assumes every study is estimating the same true effect, and any difference between study estimates is pure sampling noise. A *random-effects* model assumes each study estimates its own true effect, drawn from a distribution of true effects across settings, and that distribution's spread is itself something you need to estimate. For TB and most infectious-disease health-economics work — where regimens, population risk, diagnostic pathways, and health-system capacity vary by country and era — the random-effects assumption is almost always the defensible default. Treat the fixed-effect model as a special case you report alongside the random-effects estimate for comparison, not as your primary analysis, unless you have strong a priori reasons (e.g. multi-site arms of a single trial with a shared protocol) to believe a common true effect.

R gives you two complementary toolkits. The `meta` package wraps the common effect-measure functions you will use most often in applied synthesis work: `metagen()` for generic (already-computed) effect sizes and standard errors, `metabin()` for binary outcomes (risk ratios, odds ratios, risk differences from 2x2 tables), and `metacont()` for continuous outcomes (mean differences or standardized mean differences from group means, SDs, and sample sizes). All three accept a `method.tau` argument that selects how between-study variance ($tau^2$) is estimated, and a `sm` argument for the summary measure (e.g. `"RR"`, `"OR"`, `"MD"`, `"SMD"`).

```r
library(meta)

# Binary outcome: treatment success, event counts per arm
m_bin <- metabin(
  event.e = events_treatment, n.e = n_treatment,
  event.c = events_control,  n.c = n_control,
  data = tb_studies,
  sm = "RR",
  method = "MH",        # Mantel-Haenszel for the fixed-effect pooling step
  method.tau = "REML"   # tau^2 estimator for the random-effects layer
)
summary(m_bin)
forest(m_bin)
```

#difficult-terminology("Mantel-Haenszel (MH) method")[
The Mantel-Haenszel method is one of the oldest and simplest ways to combine 2x2 tables (treatment vs. control, event vs. no-event) from several studies into a single pooled risk ratio or odds ratio. Instead of averaging each study's own calculated ratio, it works directly from the raw event counts: it weights each study by how many events it contributed (roughly, its statistical "information"), so a study with 200 events pulls the pooled estimate much harder than one with 5 events. Think of it like calculating an overall batting average across several cricket seasons by adding up all runs and all innings first, rather than averaging each season's separate average — it handles small numbers of events more gracefully than methods that first calculate a ratio per study and then average those ratios. It is specifically a *fixed-effect* pooling method (see the surrounding text): it assumes every study estimates the same single true effect, so it is usually paired with a separate random-effects layer (here, `method.tau`) when that assumption is implausible.
]

The `metafor` package is lower-level and more flexible: you supply effect sizes and sampling variances (often via its own `escalc()` helper) and fit with `rma()`, specifying `method = "FE"` for fixed-effect or one of several random-effects estimators such as `"DL"`, `"REML"`, `"ML"`, or `"PM"` for `method`.

#difficult-terminology("\"ML\" and \"PM\" as tau-squared estimators")[
Here, "ML" stands for *maximum-likelihood* estimation of $tau^2$ (the between-study variance) — one of several numerical recipes for figuring out, from the pattern of disagreement across studies, how much genuine study-to-study variation to assume. "PM" is the *Paule-Mandel* estimator, a different, iterative recipe for the same quantity that is often recommended as a competitor to REML when the number of studies is small. *Disambiguation worth flagging explicitly*: this "ML" has nothing to do with Machine Learning, which is what "ML" means everywhere else in this book (see the abbreviations list) — here it is purely a statistical-estimation method for one variance parameter inside a meta-analysis, chosen via the `method` or `method.tau` argument, not a predictive algorithm. When you see `method = "ML"` inside `rma()`, read it as "maximum-likelihood $tau^2$ estimator," and nothing more.
]

```r
library(metafor)

dat <- escalc(measure = "RR",
              ai = events_treatment, n1i = n_treatment,
              ci = events_control,  n2i = n_control,
              data = tb_studies)

fit_dl   <- rma(yi, vi, data = dat, method = "DL")    # DerSimonian-Laird
fit_reml <- rma(yi, vi, data = dat, method = "REML")  # restricted max. likelihood
summary(fit_reml)
```

The choice of $tau^2$ estimator matters more than most analysts assume. DerSimonian-Laird (DL) is a moment-based estimator: fast, closed-form, and historically the default in most software — but it is known to understate $tau^2$, and hence understate the width of the pooled confidence interval, when the number of studies is small or effect sizes are binary with rare events. REML (restricted maximum likelihood) is iterative, slightly more computationally demanding, and generally preferred in current methodological guidance because it produces less biased variance estimates, particularly with few studies — a near-universal situation in TB programme meta-analyses, which rarely pool more than ten to fifteen studies. Where you have the choice, report REML as the primary random-effects estimate and DL as a sensitivity check, not the reverse.

#heor-practice([
When deciding fixed vs. random effects, apply the same model-selection discipline you used for parametric survival curves in Chapter 10: don't pick the model that gives the result you expected. Instead, triangulate on (a) clinical/programmatic plausibility — do you genuinely believe every included study shares one true effect, or do differing TB prevalence, drug-resistance patterns, and health-system settings make that implausible on its face; (b) a visual check of the forest plot for overlapping confidence intervals; and (c) the heterogeneity statistics covered in §11.2. Pre-register this choice in your analysis plan before you see the pooled numbers, exactly as you would pre-specify a survival distribution family before fitting.
])

#agency-note([
*NICE DSU Technical Support Document 1: "Introduction to Evidence Synthesis for Decision Making"* (Dias et al., 2011) is the methods document that most HTA reviewers will hold your meta-analysis against before it even reaches a decision model. It sets out exactly the random-effects-as-default position taken above: TSD 1 states that a fixed-effect model should only be used when there is a specific, justified reason to believe all studies share a single true effect, and that this justification must be stated explicitly in the submission, not assumed by default. Writing "a random-effects model was used because a fixed effect was not clinically plausible across studies conducted in different settings and years" in your methods section is the kind of sentence TSD 1 is checking for.
])

#pitfall([
Running both `metabin()`/`metagen()` and `rma()` on the same dataset and reporting whichever gives a narrower confidence interval or a "significant" pooled effect is $p$-hacking by model selection, even if each individual call is statistically correct. Decide your effect model (fixed vs. random) and your $tau^2$ estimator *before* inspecting results, and if you must report sensitivity analyses across estimators, label them explicitly as sensitivity analyses in your methods section, not as alternative headline results.
])

== 11.2 Heterogeneity and its quantification

Heterogeneity is simply the technical word for "the studies don't agree with each other more than sampling noise alone would explain." Quantifying it matters for two practical reasons: it tells you whether a single pooled number is even a sensible summary of your evidence base, and it determines how much extra uncertainty the random-effects model should add to your confidence interval before that number reaches a budget-impact model or a costing decision.

Three statistics do the work, and each answers a slightly different question. $Q$ is a weighted sum of how far each study's effect sits from the pooled effect. If there were truly no heterogeneity, $Q$ would follow a known chi-squared distribution — so a large $Q$ relative to its degrees of freedom ($k-1$, where $k$ is the number of studies) signals heterogeneity. $Q$'s weakness: with few studies (common in TB settings) it has low power to detect real heterogeneity, and with many studies it is almost always "significant" even when the true heterogeneity is clinically trivial. Don't read its $p$-value in isolation. $tau^2$ is the estimated *variance* of the true effects across studies, on the same scale as your effect measure (log-RR, mean difference, SMD). It is the number random-effects models actually use to widen standard errors, but its raw value is hard to interpret because that scale changes from analysis to analysis. $I^2$ solves that readability problem: it rescales the same information into a percentage — the share of total variability that is real between-study disagreement rather than sampling noise. That is why $I^2$ is the number most often quoted.

#difficult-terminology("chi-squared distribution")[
The chi-squared distribution is a standard, well-tabulated probability distribution that describes how much random "noise" alone would produce, if you added up a bunch of squared deviations that each had no real pattern behind them. It comes up constantly as the reference yardstick for "is this amount of spread bigger than chance would explain" tests. Here, it's the yardstick for the $Q$-statistic: if every study were truly estimating the same effect and all the disagreement you see between studies were just the play of random sampling, $Q$ would behave like a draw from a chi-squared distribution with $k-1$ degrees of freedom. If the actual $Q$ you calculated is bigger than what that distribution would typically produce, that's evidence the studies disagree by more than chance alone — i.e., genuine heterogeneity. It's the same logic as a chi-squared test comparing observed versus expected counts in a 2x2 table, just applied to study effects instead of cell counts.
]

A widely used rule of thumb, drawn from the Cochrane Handbook's guidance, treats $I^2$ values roughly as: 0-40% might not be important; 30-60% may represent moderate heterogeneity; 50-90% may represent substantial heterogeneity; 75-100% considerable heterogeneity — with the explicit caveat that these bands overlap deliberately, because the importance of any given $I^2$ depends on the magnitude and direction of effects and the strength of evidence for heterogeneity (i.e. look at $Q$'s $p$-value and the confidence interval around $I^2$ too, not the point estimate alone).

Both `meta` and `metafor` report all three statistics by default when you call `summary()` on a fitted object, and both provide forest plots as the standard visual diagnostic:

```r
summary(m_bin)     # reports Q, tau^2, I^2, and their CIs alongside the pooled estimate
forest(m_bin,
       sortvar = TE,          # order studies by effect size
       prediction = TRUE)     # adds a prediction interval for a new study's true effect

# metafor equivalent
summary(fit_reml)
forest(fit_reml)
```

#difficult-terminology("prediction interval (vs. confidence interval)")[
A confidence interval tells you how precisely you've pinned down the *average* true effect, given the studies you pooled — it narrows as you add more studies, because you're estimating one fixed number ever more precisely. A prediction interval answers a different, often more clinically relevant question: "if a brand-new study, not yet run, estimated this same effect, what range would its true effect plausibly fall in?" Because individual studies' true effects genuinely vary (that's the heterogeneity this section is about), a prediction interval has to be wider than the confidence interval — it accounts for both the uncertainty in the average and the real study-to-study spread around that average. Concretely: if a meta-analysis's pooled risk ratio is 0.70 with a confidence interval of 0.65-0.75, the corresponding prediction interval might be 0.40-1.20 — the average effect is well pinned down, but any one new setting (a new country, a new TB programme) could plausibly see anywhere in that wider range. Quoting only the confidence interval when heterogeneity is substantial can make the evidence look far more consistent and generalisable than it really is.
]

The forest plot remains the single most useful diagnostic in this chapter: each row is one study's point estimate and confidence interval, sized by weight in the pooled analysis, with the diamond at the bottom showing the pooled estimate and its interval. Read it before you read any summary statistic — a cluster of overlapping intervals with one clear outlier tells a different, more actionable story than a diffuse spread of non-overlapping intervals, even when both produce a similar $I^2$.

#figure(
  image("../images/r_generated/ch11_forest_plot.png", width: 95%),
  caption: [A forest plot from `meta::forest()` on a nine-study toy risk-ratio meta-analysis: one row per study with its weight-sized confidence interval, the pooled random-effects diamond, and a prediction interval for a new study's true effect — the single most important figure this chapter produces.],
) <fig-ch11-forest>

#agency-note([
The Cochrane Handbook for Systematic Reviews of Interventions, Chapter 10 ("Analysing data and undertaking meta-analyses"), is the standard methodological reference underpinning essentially every regulatory or HTA submission's heterogeneity reporting: it specifies that $I^2$, $tau^2$, and the $Q$-statistic (with its $p$-value) should all be reported together, not $I^2$ alone, and that a prediction interval should accompany the pooled estimate whenever random-effects heterogeneity is non-trivial. If your meta-analysis is destined for an HTA dossier, report in that triad rather than cherry-picking the one statistic that looks most reassuring.
])

#report-table(
  [How to report this: the per-study and pooled effect sizes that accompany a forest plot, together with the heterogeneity statistics ($Q$, $tau^2$, $I^2$) that must be quoted alongside the pooled estimate in an HTA submission],
  academic-table(
    columns: (1.6fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Study*], [*n (T/C)*], [*RR [95% CI]*], [*Weight (%)*]),
    body: (
      [Site 1], [120/118], [0.82 [0.61, 1.10]], [14.2],
      [Site 2], [95/101], [0.74 [0.52, 1.05]], [11.6],
      [Site 3], [210/205], [0.91 [0.73, 1.13]], [18.9],
      [Site 4], [88/90], [0.65 [0.44, 0.96]], [9.8],
      [Site 5], [150/147], [0.88 [0.68, 1.14]], [15.7],
      [...], [...], [...], [...],
      table.cell(colspan: 2)[*Pooled (random-effects, REML)*], [0.83 [0.72, 0.96]], [100],
    ),
    footer: (
      table.cell(colspan: 4)[Heterogeneity: $Q = 12.4$ (df = 8, $p = 0.13$); $tau^2 = 0.015$; $I^2 = 35.4%$ (95% CI: 0, 68%)],
    ),
  ),
) <tab-ch11-forest-summary>

== 11.3 Publication bias and small-study effects

Publication bias is the concern that studies with "positive," statistically significant, or programmatically convenient findings are more likely to be published, and hence more likely to end up in your meta-analysis, than null or unfavourable results sitting in a file drawer somewhere. Small-study effects are the closely related, more general phenomenon where smaller studies systematically report larger effect sizes than large studies do — which can arise from publication bias but also from genuine clinical heterogeneity (e.g. smaller pilot studies run in more responsive sub-populations) or from methodological shortcuts taken under smaller budgets. You cannot distinguish these causes definitively from the data alone, so treat any positive test below as a flag for further investigation, not as a diagnosis.

The funnel plot is the standard visual tool: each study's effect estimate is plotted against a measure of its precision (usually standard error, inverted so precise studies sit near the top). In the absence of bias, the scatter should look like a roughly symmetric inverted funnel, widening at the bottom where smaller, less precise studies naturally spread further from the pooled effect. Asymmetry — a gap in one bottom corner where small studies with unfavourable results "should" be but aren't — is the visual signature of concern.

```r
# meta package
funnel(m_bin)
metabias(m_bin, method.bias = "linreg")   # Egger's regression test

# metafor package
funnel(fit_reml)
regtest(fit_reml, model = "lm")           # Egger's test equivalent
```

Egger's test formalizes the visual check: it regresses the standardized effect estimate against its precision (or a closely related parameterization) and tests whether the intercept differs from zero, which would indicate asymmetry. `metabias()` in `meta` exposes this (and several other bias tests) via its `method.bias` argument; `regtest()` in `metafor` is the direct analogue. Both tests share the same core limitation: they require a reasonable number of studies (conventionally at least ten) to have any meaningful power, which rules them out for most TB programme meta-analyses pooling five or six site-level studies. Running Egger's test on eight studies and reporting a non-significant $p$-value as "no evidence of publication bias" overstates what the test can tell you at that sample size.

Trim-and-fill, available as `trimfill()` in both `meta` and `metafor`, offers a complementary sensitivity analysis: it iteratively removes the most extreme small studies causing funnel-plot asymmetry, uses the trimmed, symmetric subset to estimate the true center, then imputes ("fills") mirror-image studies back in to restore symmetry and re-estimates the pooled effect from the augmented dataset. The adjusted estimate is not a corrected "true" answer — it is a what-if sensitivity check showing how much the pooled effect might shift if the suspected missing studies existed and looked like their mirror images. Report it alongside, never instead of, the unadjusted pooled estimate.

```r
tf <- trimfill(m_bin)
summary(tf)
funnel(tf)   # visualize imputed studies alongside observed ones
```

#figure(
  image("../images/r_generated/ch11_funnel_trimfill.png", width: 80%),
  caption: [A funnel plot with trim-and-fill applied to the chapter's toy meta-analysis. Observed studies and any imputed mirror-image studies added by `trimfill()` to restore symmetry are both shown — the adjusted pooled estimate from this augmented dataset is a sensitivity check, not a corrected "true" answer.],
) <fig-ch11-funnel>

#pitfall([
Do not apply Egger's test or trim-and-fill mechanically whenever you have a funnel plot available. With fewer than ten studies — the norm for TB-programme-specific meta-analyses — both methods have poor power and can produce misleading corrections driven by one or two outlying studies rather than genuine bias. In that situation, describe the funnel plot qualitatively, flag the limitation explicitly in your write-up, and avoid reporting a trim-and-fill-adjusted point estimate as if it were more trustworthy than the original.
])

#report-table(
  [How to report this: sensitivity of the pooled random-effects estimate to the trim-and-fill adjustment for funnel-plot asymmetry, shown before (observed studies only) and after (observed plus imputed mirror-image studies) alongside Egger's test for small-study effects],
  academic-table(
    columns: (1.8fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Analysis*], [*k (studies)*], [*Pooled RR [95% CI]*], [*$I^2$*]),
    body: (
      [Observed studies only (random-effects, REML)], [9], [0.83 [0.72, 0.96]], [35.4%],
      [Trim-and-fill adjusted (3 imputed studies)], [12], [0.88 [0.76, 1.02]], [41.7%],
    ),
    footer: (
      table.cell(colspan: 4)[Egger's regression test: intercept $= 1.42$ (SE 0.58), $p = 0.04$, consistent with funnel-plot asymmetry; trim-and-fill shifts the pooled estimate toward the null but does not overturn it — reported as a sensitivity check, not a corrected estimate.],
    ),
  ),
) <tab-ch11-trimfill-sensitivity>

== 11.4 Meta-regression

When a forest plot shows wide variation in effect sizes across studies, the natural next question is *why*. Meta-regression extends the random-effects model by adding one or more study-level predictors ("moderators") that might explain some of that between-study heterogeneity — things like mean patient age, baseline disease severity, year of publication, or dosing regimen. It is the meta-analytic cousin of ordinary regression, except the unit of analysis is the study, not the patient, and each study's contribution is weighted by its precision.

In `metafor`, this is done with the same `rma()` function already familiar from §11.1, but supplying the `mods=` argument:

```r
library(metafor)

# dat has yi (effect size, e.g. log-RR), vi (sampling variance),
# and a study-level moderator, mean_age
res_mod <- rma(yi, vi, mods = ~ mean_age, data = dat, method = "REML")
summary(res_mod)
```

`mods=` accepts a formula, so multiple moderators, factors, and interactions all work exactly as in `lm()`: `mods = ~ mean_age + region`. The output partitions the total heterogeneity into the portion explained by the moderator(s) (reported as a test of moderators, `QM`) and what remains (the residual heterogeneity, still summarised by `tau^2` and `I^2`, now relabelled residual heterogeneity). A moderator that soaks up a large share of `QM` relative to the overall `Q` is doing real explanatory work; one that leaves the residual heterogeneity almost untouched is not.

#report-table(
  [How to report this: meta-regression coefficients from `metafor::rma(mods = ~ mean_age + region)`, the conventional way to present which study-level moderators explain between-study heterogeneity and by how much],
  academic-table(
    columns: (1.6fr, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    header: ([*Moderator*], [*Coefficient*], [*SE*], [*95% CI*], [*$p$*]),
    body: (
      [Intercept], [-0.41], [0.15], [(-0.70, -0.12)], [0.006],
      [Mean age (per 10 years)], [0.09], [0.04], [(0.01, 0.17)], [0.028],
      [Region: high TB-burden (ref: low)], [0.18], [0.11], [(-0.04, 0.40)], [0.108],
    ),
    footer: (
      table.cell(colspan: 5)[Test of moderators: $Q_M = 6.8$ (df = 2, $p = 0.033$); residual heterogeneity $tau^2 = 0.009$ (down from $0.015$ in the unadjusted model), residual $I^2 = 22.1%$.],
    ),
  ),
) <tab-ch11-metareg-coefficients>

Meta-regression is appropriate when two conditions hold together. First, there need to be *enough studies* — as a rule of thumb, at least ten studies per moderator is the floor below which the regression coefficients become unstable and prone to chance findings; many TB programme meta-analyses sit well under this, which should temper ambition. Second, the covariates should be *pre-specified* in a protocol, not fished for after seeing which split of the forest plot looks tidiest. Testing every variable in the dataset against the effect size until something is significant is simply multiple testing in a performance-enhancing dress, and the HEOR submission will not survive scrutiny if the moderator choice cannot be justified on clinical or methodological grounds set out before the data were pooled.

#pitfall([
Meta-regression coefficients describe *between-study* associations, not *within-study* (individual-patient) associations — this is ecological bias. A meta-regression that finds "trials with older average age show smaller treatment effects" says nothing reliable about whether an individual older patient benefits less; the studies' age *averages* are confounded with everything else that differs systematically between those trials (settings, era, comorbidity mix, co-interventions). Do not present aggregate-level moderator findings as if they were patient-level subgroup effects in a submission — regulators and HTA reviewers will flag this immediately, and Cochrane guidance is explicit that such inferences require individual patient data (IPD) meta-analysis, not aggregate meta-regression.
])

With few studies, meta-regression also has very low statistical power — a null result for a moderator with eight trials is barely informative, and should be reported as inconclusive rather than as evidence the moderator does not matter.

== 11.5 Meta-analysis of time-to-event outcomes

Many of the outcomes that matter most in TB and HIV programmes — time to treatment failure, time to death, time to culture conversion — are naturally time-to-event (survival) outcomes, and trials typically report them as hazard ratios (HRs) with confidence intervals, not as simple risk ratios. Pooling HRs across studies needs a small but important adjustment: HRs are ratios, bounded below by zero and skewed, so they are pooled on the *log scale*, where the sampling distribution is much closer to normal.

The practical recipe is: for each study, compute `log(HR)` as the effect estimate and derive its standard error from the reported confidence interval (if a 95% CI is `(L, U)`, then `SE = (log(U) - log(L)) / (2 * 1.96)`), then pool these log(HR) values with inverse-variance weighting exactly as any other continuous effect size. The `meta` package's `metagen()` function does this cleanly and labels the output in the natural HR scale automatically:

```r
library(meta)

# dat has studlab, TE (= log HR per study), seTE (SE of log HR)
m_hr <- metagen(
  TE = TE,
  seTE = seTE,
  studlab = studlab,
  data = dat,
  sm = "HR",          # tells meta the pooled estimate is a hazard ratio
  method.tau = "REML"
)
summary(m_hr)
forest(m_hr)
```

Setting `sm = "HR"` is purely cosmetic in terms of the arithmetic (the pooling still happens on the log scale you supplied), but it tells `metagen()` to back-transform the summary estimate and its CI with `exp()` before printing, so the forest plot and output table report a pooled HR with sensible axis labelling rather than a pooled log(HR) that needs manual conversion. If your source studies instead report `log(HR)` and its SE directly (common in trial supplements), feed those straight in; if they only give you the HR point estimate and CI, derive `TE` and `seTE` from them first as above.

This pooled HR is not the end of the analysis in an HEOR context — it is usually an *input* to the next stage. Chapter 10 built the survival-model toolkit: fitting the `flexsurv` six-distribution family to a reference arm's individual patient-level survival data, selecting a parametric form by AIC/BIC together with visual fit and clinical plausibility, and extrapolating the fitted curve beyond the trial's observed follow-up. A pooled HR from meta-analysis commonly becomes the multiplier applied to that extrapolated reference-arm survival curve to generate the comparator arm's extrapolated survival — the "HR method" of indirect extrapolation used throughout cost-effectiveness modelling. The meta-analysis in this section therefore feeds directly into the machinery of the previous chapter: the pooled `log(HR)` and its uncertainty become a parameter (often itself distributed, e.g. log-normal, in a probabilistic sensitivity analysis) multiplying the hazard function of whichever `flexsurv` distribution was selected for the reference arm in Chapter 10.

#agency-note([
Before pooling HRs across trials for use in an extrapolation, check the Cochrane Handbook for Systematic Reviews of Interventions, Chapter 6 (on choosing effect measures) for its guidance on extracting hazard ratios consistently across studies that report time-to-event results in different formats (Kaplan-Meier curves only, HR with CI, HR with p-value only, or number of events and person-time). The Handbook sets out a hierarchy of extraction methods — a directly reported HR and SE being preferable to an HR reconstructed from a digitised KM curve via the Guyot et al. (2012) algorithm already introduced in Chapter 10 §10.11 — so do not silently treat a reconstructed HR as equivalent in precision to a directly reported one when assembling the pooled estimate that will drive an extrapolation.
])

== 11.6 Diagnostic test accuracy meta-analysis

Pooling sensitivity and specificity separately is tempting but wrong, because the two measures are not independent: a laboratory or study that reads a diagnostic threshold more liberally will tend to report higher sensitivity and lower specificity together, and vice versa. Any meta-analysis of diagnostic accuracy — highly relevant to TB programmes evaluating a new rapid test (Xpert, LF-LAM, a novel biomarker assay) against a reference standard like culture — needs a model that respects this negative correlation rather than pooling sensitivity and specificity as if they were two unrelated outcomes.

The standard solution is the bivariate random-effects model, which jointly models the logit-transformed sensitivity and logit-transformed specificity across studies, allowing for a between-study correlation between the two. In R, the dedicated package for this is `mada` ("meta-analysis of diagnostic accuracy"), and its core function is `reitsma()`:

```r
library(mada)

# dat has TP, FN, FP, TN counts for each study against the reference standard
fit <- reitsma(dat)        # dat needs columns named TP, FN, FP, TN
summary(fit)

# descriptive diagnostic stats (sens, spec, likelihood ratios) per study
desc <- madad(dat)
print(desc)

# SROC curve with confidence and prediction regions
plot(fit, sroc.type = "ruttergates")
points(fpr(desc), sens(desc), pch = 2)
```

#figure(
  image("../images/r_generated/ch11_sroc_curve.png", width: 80%),
  caption: [An SROC curve from `mada::reitsma()` fitted to a toy TB rapid-diagnostic-test dataset: study-level sensitivity/false-positive-rate pairs (triangles), the pooled summary point, and the 95% confidence and prediction regions — the bivariate analogue of the pairwise forest plot.],
) <fig-ch11-sroc>

`reitsma()` fits the bivariate model (a generalised linear mixed model under the hood, modelling the logit-sensitivity/logit-specificity pair with a bivariate normal random effect) and returns pooled sensitivity and specificity with their joint uncertainty. The SROC curve (summary receiver operating characteristic curve) traces out the implied trade-off between sensitivity and specificity across the range of thresholds/studies, and is the standard visual summary for a diagnostic accuracy review — it plays a role analogous to the forest plot for pairwise meta-analysis, but captures the two correlated axes at once. `metafor::rma.mv()` can also fit an equivalent bivariate model by hand (specifying the sensitivity/specificity logits as a bivariate outcome with a random study effect), which gives more flexibility for complex covariate structures, but `mada::reitsma()` is the more direct and purpose-built route for a standard DTA review.

#difficult-terminology("generalised linear mixed model")[
A "mixed model" is a regression that mixes two kinds of effects: *fixed* effects, which are shared, overall parameters you want to estimate once for everybody (e.g. "the average sensitivity across all studies"), and *random* effects, which let each individual study (or patient, or site) wobble around that average in its own way, with the size of that wobble itself estimated from the data. "Generalised" means the outcome doesn't have to be a plain continuous, normally-distributed number — here it is a logit-transformed proportion (sensitivity/specificity), so the model works on that transformed, bounded scale, the same trick as the logit link used elsewhere in the book. Picture it as: every study gets to have its own slightly different "true" sensitivity and specificity (the random part), but all of those study-specific values are assumed to be draws clustered around one shared underlying pair of numbers (the fixed part) — that's what lets `reitsma()` borrow strength across studies while still respecting that no two labs read a diagnostic threshold identically.
]

#agency-note([
Diagnostic test accuracy reviews have their own reporting standard, the PRISMA-DTA extension (Preferred Reporting Items for Systematic Reviews and Meta-Analyses of Diagnostic Test Accuracy studies), published in *JAMA* in 2018. Before finalising a DTA meta-analysis for a TB diagnostics submission, check the PRISMA-DTA checklist for required elements — notably the explicit reporting of the reference standard used in each included study, handling of indeterminate results, and threshold variability across studies — since these affect whether pooling sensitivity/specificity across studies is even defensible in the first place.
])

#report-table(
  [How to report this: pooled sensitivity and specificity from the bivariate `mada::reitsma()` model, the standard summary table accompanying an SROC curve in a diagnostic test accuracy review],
  academic-table(
    columns: (1.6fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Parameter*], [*Estimate*], [*95% CI (low)*], [*95% CI (high)*]),
    body: (
      [Pooled sensitivity], [0.89], [0.82], [0.94],
      [Pooled specificity], [0.91], [0.85], [0.95],
      [Positive likelihood ratio], [9.9], [5.8], [16.9],
      [Negative likelihood ratio], [0.12], [0.07], [0.20],
      [Diagnostic odds ratio], [82.5], [34.1], [199.6],
    ),
    footer: (
      table.cell(colspan: 4)[Bivariate model: 11 studies, correlation between logit-sensitivity and logit-specificity $rho = -0.42$],
    ),
  ),
) <tab-ch11-dta-summary>

#difficult-terminology("positive/negative likelihood ratio")[
These two numbers translate a test's sensitivity and specificity into something more directly useful at the bedside: how much a result should shift your suspicion of disease. The *positive* likelihood ratio (here, 9.9) says a positive test result is about 9.9 times more likely to occur in someone who truly has the disease than in someone who doesn't — the higher above 1, the more a positive result should raise your suspicion. The *negative* likelihood ratio (here, 0.12) says a negative result is still fairly likely in diseased patients relative to non-diseased ones when it's far from 0 — the lower below 1 (closer to 0), the more a negative result should reassure you. Unlike sensitivity/specificity, likelihood ratios can be combined directly with a patient's pre-test odds of disease (via Bayes' theorem) to get a post-test odds, which is why clinicians favour them for bedside reasoning about an individual patient, rather than sensitivity/specificity alone.
]

#difficult-terminology("diagnostic odds ratio")[
The diagnostic odds ratio folds sensitivity and specificity into one single summary number: the odds of a positive test result in diseased patients, divided by the odds of a positive test result in non-diseased patients. A value of 1 means the test is useless (positive results are just as likely whether or not someone has the disease); the TB rapid test's value of 82.5 here means a positive result is, in odds terms, about 82 times more likely among people who truly have TB than among people who don't — a reasonably strong-performing test. It's convenient for ranking or comparing tests with one number, but because it blends sensitivity and specificity together, two tests with very different clinical trade-offs (one highly sensitive but less specific, one the reverse) can end up with a similar diagnostic odds ratio — so it should supplement, not replace, looking at sensitivity, specificity, and the likelihood ratios separately.
]

#heor-practice([
When several candidate rapid tests are being compared against the same reference standard, consider whether a network meta-analysis of diagnostic accuracy is more appropriate than separate pairwise bivariate models — this lets indirect comparisons borrow strength across the evidence network, which matters when head-to-head trials between two rapid tests are scarce, as is common in TB diagnostics. Chapter 12 develops network methods in full.
])

== 11.7 Meta-analysis of proportions and rates

A large share of the meta-analyses a TB programme analyst will actually run are not comparative at all — there is no treatment arm versus control arm, just a single proportion (prevalence of drug resistance, treatment success rate, loss-to-follow-up rate) or a single rate (incidence per person-year) estimated in multiple studies or multiple programme sites, which need to be pooled into one overall estimate. This is meta-analysis of a *single group* summary statistic, and it needs its own variance-stabilising transformations because raw proportions and rates have variances that depend on their own mean, violating the constant-variance assumption behind simple inverse-variance pooling.

For proportions bounded between 0 and 1 (e.g. proportion of TB patients with a positive resistance test), two transformations are standard. The logit transformation maps the proportion to the whole real line and works well away from the boundaries:

```r
library(metafor)

# dat has xi (events, e.g. resistant cases) and ni (total tested) per study
dat_logit <- escalc(measure = "PLO", xi = xi, ni = ni, data = dat)
res_logit <- rma(yi, vi, data = dat_logit, method = "REML")
predict(res_logit, transf = transf.ilogit)   # back-transform to a proportion
```

When some studies have proportions near 0 or 1 (common with rare events, such as a resistance pattern seen in only a handful of patients), the logit transform can behave poorly, and the double-arcsine (Freeman-Tukey) transformation is the usual alternative, handled in `metafor::escalc()` with `measure = "PFT"`:

```r
dat_pft <- escalc(measure = "PFT", xi = xi, ni = ni, data = dat)
res_pft <- rma(yi, vi, data = dat_pft, method = "REML")
predict(res_pft, transf = transf.ipft.hm, ni = dat_pft$ni)  # back-transform
```

For rates (events per unit person-time, e.g. TB incidence per 100,000 person-years), the log transformation is the natural equivalent, available via `measure = "IRLN"` (incidence rate, log-transformed):

```r
# dat has xi (events) and ti (total person-time) per study/site
dat_rate <- escalc(measure = "IRLN", xi = xi, ti = ti, data = dat)
res_rate <- rma(yi, vi, data = dat_rate, method = "REML")
predict(res_rate, transf = exp)   # back-transform to events per person-time unit
```

In every case the pattern is the same: transform each study's proportion or rate onto a scale where a normal approximation is reasonable, pool on that transformed scale with the usual random-effects machinery (`rma()`), then back-transform the pooled estimate and its confidence interval with `predict(..., transf = ...)` for reporting. Never average the raw proportions or rates directly and never report the pooled estimate still on the transformed scale — logit or arcsine units mean nothing to a programme manager reading the report.

#pitfall([
High heterogeneity ($I^2$ often exceeding 90%) is the norm rather than the exception when pooling prevalence or incidence across sites, because true prevalence genuinely differs by geography, population risk, and surveillance intensity — this is not necessarily a sign of a broken model. Resist the temptation to report a single pooled prevalence figure as if it applied uniformly to a national TB programme when the underlying studies are clearly measuring different underlying populations; a forest plot showing the spread, alongside the pooled estimate, communicates the true picture far better than the summary number alone, and subgroup pooling by region or risk group is usually more decision-relevant than one overall figure.
])

#agency-note([
CHEERS 2022 (Husereau et al., *Value in Health*, 2022), the reporting checklist already established in Chapter 9, item 15 requires that any pooled clinical input to a cost-effectiveness model — including a pooled prevalence or rate feeding a Markov transition probability in a later chapter — state the synthesis method, the heterogeneity statistics, and the handling of any ties to the decision model explicitly. A pooled proportion quoted in a later chapter's Markov model without a visible trail back to this section's method and heterogeneity reporting does not meet that bar.
])
