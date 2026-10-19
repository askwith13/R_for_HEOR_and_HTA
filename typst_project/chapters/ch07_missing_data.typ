#import "../common.typ": *

= Chapter 7. Missing Data

#learning-objectives((
  [Distinguish MCAR, MAR, and MNAR missing-data mechanisms and explain why the distinction cannot be confirmed from observed data alone.],
  [Use `naniar` and `visdat` to visualise and audit missingness patterns before choosing a handling strategy.],
  [Explain why complete-case analysis and single imputation understate uncertainty, and when each is defensible.],
  [Perform multiple imputation with `mice` (and know when to reach for `Amelia` or `missForest` instead), pooling estimates correctly via Rubin's rules.],
  [Conduct tipping-point and pattern-mixture sensitivity analyses to stress-test conclusions against departures from MAR.],
  [Handle the distinctive challenges of missing cost and QALY data — skewness, bounds, and informative dropout.],
  [Report missing-data handling for an HTA submission in line with CHEERS 2022 and ICH E9(R1) expectations.],
))

Chapter 6 closed by building a reproducible evidence pool from the published literature; this chapter turns to a problem that shows up just as often in the primary trial, registry, or claims dataset itself — not every cell in that dataset is filled in, and what you do about the gaps can change a cost-effectiveness conclusion as much as any modelling choice later in this book.

== 7.1 Mechanisms: MCAR, MAR, MNAR

Every HEOR analysis built on trial or real-world data eventually runs into the same quiet problem: some values are simply not there. A patient skips a follow-up visit, a claims extract has a null cost field for a quarter, an EQ-5D questionnaire comes back with three dimensions ticked and two left blank. Before you can decide what to do about it — delete the rows, impute them, or model around them — you need a working theory of *why* the data are missing. Donald Rubin's 1976 framework gives the vocabulary for that theory, and it remains the backbone of every modern missing-data guideline used in health technology assessment.

Rubin defined three mechanisms by asking whether the probability that a value is missing depends on the data itself:

#list(
  [*MCAR (Missing Completely At Random)*: the probability of a value being missing is unrelated to both the observed and the unobserved data. Missingness is pure noise — equivalent to a coin flip applied independently to every record.],
  [*MAR (Missing At Random)*: the probability of a value being missing depends only on the *observed* data (other variables you have recorded), not on the missing value itself, once you condition on what you observed.],
  [*MNAR (Missing Not At Random)*: the probability of a value being missing depends on the *unobserved* value itself, even after conditioning on everything you did observe.],
)

Take a concrete HEOR example and carry it through all three mechanisms: a randomised trial collects EQ-5D-5L questionnaires at 12 weeks to feed a QALY calculation for the economic model, and 15% of participants have a missing follow-up questionnaire.

- If non-response is driven by a random administrative failure — a clinic forgot to mail the form to a random subset of participants regardless of their health status, treatment arm, age, or anything else — that is MCAR. The missing 15% are, in expectation, a random sample of the full cohort, and a complete-case analysis (simply dropping those rows) is unbiased, if inefficient.
- If non-response is higher among patients who missed their clinic visit, and clinic attendance is itself associated with baseline disease severity that you *recorded* at randomisation, then conditioning on baseline severity (which you have) explains the missingness pattern. That is MAR: missingness depends on an observed covariate, not on the unobserved EQ-5D score itself once severity is accounted for.
- If, instead, patients skip the questionnaire specifically *because* their health has deteriorated and they no longer feel well enough to complete it — and that deterioration is not fully captured by anything else in your dataset — then missingness depends on the very value that is missing. That is MNAR, and no amount of conditioning on the data you do have will fix it, because the unobserved health state itself is the driver.

The uncomfortable truth is that these three scenarios can produce an *identical* pattern of missing cells in your dataset. Nothing in the observed rows and columns tells you which story is true — MCAR, MAR, and MNAR are all consistent with the same table of 1s and 0s marking which values are missing. The mechanism is a statement about the *unobserved* values, so it can never be confirmed or refuted by the observed data alone. You can test whether missingness is associated with observed covariates (which can rule out some forms of MCAR, see `mcar_test()` in Section 7.2), but you can never test whether missingness depends on the unobserved value itself — by definition, you do not have that value to check against. The choice between MAR and MNAR is ultimately a domain-knowledge argument, not a statistical result, and should be defended with clinical reasoning (do sicker patients plausibly drop out more?) rather than a p-value.

This matters enormously for HEOR because the three mechanisms license completely different analytic responses:

#list(
  [Under *MCAR*, a complete-case analysis is unbiased — you lose precision (wider confidence intervals around your ICER) but not accuracy. This is the only mechanism under which "just drop the missing rows" is statistically defensible, and it is rarely plausible for anything beyond trivial administrative dropout.],
  [Under *MAR*, complete-case analysis is generally biased, but multiple imputation (MI) — drawing plausible values conditional on the observed covariates, as implemented in `mice` or `missForest` — recovers unbiased estimates, because MAR is precisely the assumption that licenses those methods. Most routine MI practice in trial-based cost-effectiveness analysis implicitly assumes MAR.],
  [Under *MNAR*, no standard imputation model will save you, because the imputation itself needs to encode a mechanism you cannot verify. The accepted response is either explicit mechanism modelling — selection models (a joint model for the outcome and the missingness indicator) or pattern-mixture models (fitting separate outcome models within each missingness pattern and specifying how they differ) — or, more commonly in practice, a structured sensitivity analysis that varies the assumed severity of MNAR departure and reports how the ICER moves.],
)

In practice, no HEOR dataset wears a label saying which mechanism generated it. The discipline is to state your assumption explicitly, justify it with clinical and operational knowledge of why the data went missing, and then stress-test the conclusion against alternative, less convenient assumptions — which is exactly where Section 7.2's exploratory tools and later chapters' sensitivity-analysis techniques come in.

== 7.2 Exploring missingness (naniar, visdat, Shiny-based explorers)

Before choosing an imputation strategy or defending a mechanism assumption, you need to actually look at your missingness — not just count NAs with `colSums(is.na(df))`, but see where they fall, whether they cluster by variable, by patient, by visit, or by arm, and whether they co-occur in patterns that hint at a shared cause. The `naniar` and `visdat` packages, both built around tidyverse conventions, turn this into a few lines of code rather than a manual audit, and they should be a standard first step on any trial or claims extract destined for a cost-effectiveness model.

`visdat::vis_dat()` gives an overview of an entire data frame in one plot: each column is a vertical strip, coloured by data type (character, numeric, logical), with missing cells picked out distinctly, so you immediately see whether missingness is concentrated in a few columns (say, a late-added quality-of-life variable) or scattered everywhere. `visdat::vis_miss()` narrows this to missingness specifically, shading missing cells and printing the percentage missing per column, which is often the single most useful diagnostic plot to drop into an analysis log.

`naniar` extends this considerably. `naniar::vis_miss()` produces a similar heatmap-style plot but adds clustering options so that rows with similar missingness patterns are grouped together — useful for spotting whether, for instance, patients missing a 12-week EQ-5D are disproportionately the same patients missing a 12-week cost record, which would support a shared-cause MAR or MNAR story rather than independent MCAR noise in each column. `naniar::gg_miss_var()` plots the number (or proportion) of missing values per variable as a simple ranked bar chart, which is the fastest way to triage which columns deserve the most scrutiny. `naniar::gg_miss_upset()` goes further and shows an UpSet-style plot of *combinations* of co-missing variables — essential once you have more than two or three variables with missingness, where a simple pairwise correlation plot becomes unreadable. For a formal (if limited) statistical check, `naniar::mcar_test()` implements Little's MCAR test, which assesses whether the observed pattern of missingness is consistent with MCAR by comparing means across missingness patterns; a significant result lets you rule out MCAR, but — consistent with Section 7.1 — a non-significant result does not prove MCAR, it only fails to contradict it, and the test says nothing about MAR versus MNAR.

A worked illustration, using a hypothetical trial-based economic dataset with utility (EQ-5D index) and healthcare cost columns:

```r
library(tidyverse)
library(naniar)
library(visdat)

# trial_econ: one row per patient, with baseline and 12-week
# utility scores, and total healthcare cost over follow-up
trial_econ <- read_csv("trial_econ_extract.csv")

# Overview of variable types and missingness across the frame
vis_dat(trial_econ)

# Missingness-focused heatmap, clustered by pattern
vis_miss(trial_econ, cluster = TRUE)

# Which variables carry the most missingness?
gg_miss_var(trial_econ, facet = trial_arm)

# Do utility and cost missingness co-occur?
gg_miss_upset(trial_econ)

# Formal test of the MCAR assumption (Little's test)
mcar_test(trial_econ %>% select(utility_12wk, total_cost, baseline_utility))
```

The `facet = trial_arm` argument to `gg_miss_var()` is worth dwelling on: splitting missingness summaries by randomised arm is one of the simplest and most informative checks available in a trial context, because differential missingness between arms (more dropout on the active treatment, say, due to side effects) is a strong, visually obvious signal against MCAR and a prompt to think hard about MAR versus MNAR before modelling.

For datasets too large or too wide for a single static plot — a claims warehouse with hundreds of cost and utilisation fields, for example — static `vis_miss()` heatmaps become hard to read. R's Shiny framework is commonly used to wrap these same `naniar`/`visdat` summaries into an interactive explorer: a reactive app where an analyst filters by site, time window, or variable subgroup and regenerates the missingness plot on demand, rather than pre-generating dozens of static figures. This is a thin application layer over the same underlying functions shown above, not a different statistical method, but it materially speeds up the exploratory phase on large real-world evidence extracts.

#pitfall[A non-significant result from `mcar_test()` does not certify your data as MCAR — it only means the test found no evidence against it. Little's test checks whether missingness correlates with *observed* variables; it is structurally blind to MNAR, where missingness depends on the unobserved value itself. Treating a passed MCAR test as licence for a complete-case analysis is one of the most common silent sources of bias in HEOR cost-effectiveness write-ups.]

#agency-note[When documenting missing-data handling in a trial-based economic evaluation for a submission, ground your approach in Faria, Gomes, Epstein & White's "A Guide to Handling Missing Data in Cost-Effectiveness Analysis Conducted Within Randomised Controlled Trials" (PharmacoEconomics, 2014) — a widely cited, methodologically detailed guide that walks through exactly this mechanism-first, exploratory-then-sensitivity-analysis workflow and is the standard reference HTA reviewers expect to see cited.]

== 7.3 Complete-case versus imputation

The simplest response to missing data is to ignore it: keep only the rows with no missing values and analyse those as if they were the whole dataset. This is complete-case analysis, also called listwise deletion, and it is the default behaviour of most R modelling functions (`lm()`, `glm()`, `t.test()` all silently drop incomplete rows unless told otherwise). Its appeal is honesty of a kind — every value that enters the analysis was actually observed, nothing is fabricated — and under one specific condition it is a perfectly defensible choice: when missingness is genuinely MCAR (missing completely at random, SS7.1) and the proportion missing is small, say under 5%. Under true MCAR, the complete cases are a random subsample of the full cohort, so estimates remain unbiased; the only cost is a loss of statistical power from the smaller sample size.

That caveat matters because the cost is rarely "only" power. Two failure modes deserve attention. First, even under MCAR, if a non-trivial fraction of records is missing — 20%, 30%, sometimes more for a patient-reported utility instrument like the EQ-5D at follow-up visits — complete-case analysis can discard a third or more of a trial's data, inflating standard errors and widening confidence intervals around the ICER to the point of uselessness, even though the point estimate itself stays unbiased. Second, and more insidious, if missingness is MAR or MNAR (SS7.1), dropping incomplete rows does not merely cost power — it introduces bias, silently. If patients with worse quality of life are systematically more likely to skip the utility questionnaire (plausibly MNAR), the complete-case subsample overrepresents healthier patients, and the estimated mean QALY is biased upward. No warning is printed; `lm()` will fit happily and report a confidence interval that looks perfectly respectable while being centred on the wrong number.

A step up from deletion is single imputation: filling in each missing value with one plausible number and then analysing the completed dataset as though it had been fully observed all along. Common variants include mean or median imputation (replace missing cost or utility values with the column mean/median) and last-observation-carried-forward (LOCF), common in longitudinal cost-effectiveness follow-up, which carries a patient's last recorded value forward to fill subsequent missing visits. Both are easy to implement and both are dangerous for the same underlying reason: they treat a *guess* as if it were *data*. Once the gaps are filled with a single fabricated number, every downstream standard error, confidence interval, and p-value is computed under the pretence that all values were actually measured. The uncertainty introduced by the act of guessing never enters the calculation, so standard errors come out systematically too small and confidence intervals too narrow — the analysis reports more confidence in the result than the data actually support.

The following toy example makes this concrete using the cost/QALY tibble convention from Chapter 4. Twenty patients' utility values are simulated, 30% are set missing, and we compare the standard error of the mean utility under naive mean-imputation against the standard error obtained via proper multiple imputation (introduced in SS7.4).

```r
library(tidyverse)
library(mice)

set.seed(2024)
n <- 20
truth <- tibble(
  patient_id = 1:n,
  utility = rnorm(n, mean = 0.75, sd = 0.10)
)

# Introduce MAR-ish missingness: lower utility more likely to be missing
obs <- truth |>
  mutate(
    miss_prob = plogis(-3 + 4 * (0.80 - utility)),
    utility_obs = if_else(runif(n) < miss_prob, NA_real_, utility)
  )

# --- Naive mean imputation ---
mean_fill <- mean(obs$utility_obs, na.rm = TRUE)
naive <- obs |> mutate(utility_imp = if_else(is.na(utility_obs), mean_fill, utility_obs))

se_naive <- sd(naive$utility_imp) / sqrt(n)
cat("Naive mean-imputation SE:", round(se_naive, 4), "\n")

# --- Proper multiple imputation (mice), previewed from SS7.4 ---
imp <- mice(obs |> select(utility_obs), m = 20, method = "pmm", maxit = 5,
            printFlag = FALSE, seed = 2024)
fits <- with(imp, t.test(utility_obs))
pooled <- pool(fits)
cat("Multiply-imputed pooled SE:", round(summary(pooled)$std.error, 4), "\n")
```

Running this comparison typically shows the naive mean-imputation standard error noticeably smaller than the mice-pooled standard error, because filling every gap with the identical constant `mean_fill` mechanically shrinks the completed dataset's variance and hides the fact that the true value of each missing observation was never actually known. LOCF carries an analogous problem in longitudinal cost data: carrying forward a value assumes no change occurred, which both biases trends (toward flat trajectories) and understates variability.

#pitfall[A standard error computed on a singly-imputed dataset answers the question "how uncertain would I be if these fabricated values were real?" — not "how uncertain am I, given that I had to fabricate them?" The two numbers are not the same, and the gap is exactly the imputation uncertainty that single-imputation methods discard.]

The motivation for SS7.4 follows directly: we want a method that fills in plausible values *and* propagates the extra uncertainty from not knowing those values into the final standard errors. That is precisely what multiple imputation, combined via Rubin's rules, is built to do.

== 7.4 Multiple imputation (mice, Amelia, missForest)

Multiple imputation solves the understated-uncertainty problem of SS7.3 by refusing to commit to a single guess. Instead of filling each missing cell once, it creates several complete versions of the dataset — typically `m = 5` to `m = 50` — each with its own plausible, independently drawn set of imputed values, drawing on the observed relationships between variables. The analysis of interest (a mean, a regression, an ICER) is then run separately on every imputed dataset, and the `m` results are combined using Rubin's rules, which pool the point estimates by simple averaging and pool the standard errors by combining two components: the *within-imputation* variance (the usual sampling variance you would get from any one completed dataset) and the *between-imputation* variance (how much the estimate itself jumps around depending on which imputed values happened to be drawn). That between-imputation term is exactly the piece that single imputation discards, and is why multiply-imputed standard errors are honest about missing-data uncertainty in a way mean-imputation or LOCF never can be.

The workhorse R package for this is `mice` ("Multivariate Imputation by Chained Equations"). The core function, `mice()`, imputes one variable at a time conditional on all the others, cycling through variables for several iterations (`maxit`) and repeating the whole process `m` times to produce `m` independent completed datasets. The `method` argument lets you choose an imputation model per variable type: `"pmm"` (predictive mean matching) is the default and generally preferred choice for continuous variables like cost or utility, because it imputes using *observed* donor values rather than inventing numbers outside the plausible range; `"logreg"` handles binary variables (e.g. treatment response yes/no); `"polyreg"` handles unordered categorical variables (e.g. disease stage categories).

```r
library(tidyverse)
library(mice)

set.seed(42)
heor_data <- tibble(
  patient_id = 1:40,
  treatment  = rep(c("A", "B"), each = 20),
  cost       = rnorm(40, mean = 1200, sd = 300),
  qaly       = rnorm(40, mean = 0.70, sd = 0.08)
)

# Inject missingness into cost and qaly
heor_miss <- heor_data |>
  mutate(
    cost = if_else(runif(40) < 0.25, NA_real_, cost),
    qaly = if_else(runif(40) < 0.20, NA_real_, qaly)
  )

imp <- mice(
  heor_miss |> select(cost, qaly, treatment),
  m = 10, method = c(cost = "pmm", qaly = "pmm", treatment = ""),
  maxit = 5, printFlag = FALSE, seed = 42
)

# Inspect one completed dataset
completed_1 <- complete(imp, action = 1)

# Fit the model of interest on every imputed dataset, then pool per Rubin's rules
fit <- with(imp, lm(qaly ~ treatment + cost))
pooled_fit <- pool(fit)
summary(pooled_fit)
```

`summary(pooled_fit)` returns the pooled coefficient estimates together with standard errors, degrees of freedom, and p-values that already incorporate both within- and between-imputation variance — these are the numbers that belong in a report, not the output of any single `complete()`d dataset taken in isolation. The same pattern (`with()` then `pool()`) applies equally to pooling a simple mean utility, a regression-adjusted cost difference, or an ICER-contributing coefficient, as long as the estimator produces a coefficient and standard error that `pool()` can combine.

The conventional way to report `mice::pool()` output is a coefficient table carrying the pooled estimate, its standard error, a 95% confidence interval, and the fraction of missing information (FMI) per coefficient — FMI quantifies how much the uncertainty around that specific coefficient is inflated by the missingness, which a bare point estimate cannot convey on its own:

#report-table(
  [Pooled multiple-imputation regression coefficients (Rubin's rules) for `qaly ~ treatment + cost`, m = 10 imputations],
  academic-table(
    columns: (1.3fr, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    header: ([*Term*], [*Estimate*], [*SE*], [*95% CI*], [*FMI*]),
    body: (
      [Intercept], [0.612], [0.041], [0.531, 0.693], [0.18],
      [treatment (B vs. A)], [0.034], [0.019], [-0.004, 0.071], [0.22],
      [cost], [-0.00004], [0.00002], [-0.00008, 0.00000], [0.31],
    ),
    footer: (table.cell(colspan: 5)[Estimates, SEs and 95% CIs are pooled across m = 10 imputed datasets via Rubin's rules; FMI (fraction of missing information) is highest for the `cost` coefficient, consistent with cost carrying the larger share of injected missingness in this toy example.],),
  ),
) <tab-ch07-mi-pooled-coefficients>

#heor-practice[When reporting a cost-effectiveness analysis built on multiply-imputed data, state `m` (the number of imputations), the imputation method per variable, and the pooled standard errors explicitly in your methods section — reviewers increasingly expect this, and NICE/ISPOR-aligned reporting checklists treat undisclosed single imputation or unexplained listwise deletion as a methodological red flag.]

`mice` is not the only option, and two alternatives are worth knowing when to reach for. `Amelia` (package `Amelia`, function `amelia()`) uses an EM-with-bootstrapping (EMB) algorithm assuming multivariate normality, and is particularly well suited to time-series or longitudinal panel data — it has built-in support for time and cross-sectional ID arguments that `mice` lacks, making it a natural choice for multi-wave follow-up cost diaries. `missForest` (package `missForest`, function `missForest()`) takes a completely different, nonparametric approach: it iteratively imputes missing values using random forests grown on the other variables, which makes it robust to nonlinear relationships and naturally handles mixed continuous/categorical data without needing separate method specifications per variable type — genuinely convenient for messy real-world HEOR datasets with a tangle of cost, utility, comorbidity, and categorical variables together.

The convenience of `missForest` comes with a real limitation, though: it produces a single completed dataset per run, not naturally plural imputations in the Rubin's-rules sense, so the standard between/within-imputation variance decomposition that `mice`'s `pool()` performs does not apply in the same way. Running `missForest` multiple times with different seeds and attempting to combine the results post hoc is an active area of methodological debate, not an out-of-the-box solved problem the way `mice::pool()` is. For an analysis whose final deliverable is a pooled standard error destined for a cost-effectiveness acceptability curve or a confidence interval around an ICER, `mice` (or `Amelia` for longitudinal structures) remains the better-supported choice; `missForest` is better reserved for exploratory imputation or as a preprocessing step feeding a single downstream prediction model, where you are less dependent on a correctly propagated variance estimate.

== 7.5 Sensitivity analysis, including tipping-point and pattern-mixture approaches

Multiple imputation under the missing-at-random assumption, as covered in SS7.4, produces a single headline estimate and a confidence interval that already account for imputation uncertainty. It is tempting to treat that output as the final word. It is not. Recall from SS7.1 that MCAR, MAR, and MNAR cannot be distinguished using the observed data alone — the very information that would tell you whether the unseen values differ systematically from the seen ones is, by definition, unseen. Multiple imputation by chained equations assumes MAR conditional on the variables in the imputation model. That assumption is plausible, sometimes highly plausible, but it is never verifiable from the dataset in front of you. Any analysis that stops after reporting "MI point estimate, MI confidence interval" without asking "what if the missing values are systematically worse (or better) than what the model predicted" is incomplete. Sensitivity analysis is the second half of a credible missing-data analysis, not an optional appendix.

Tipping-point analysis is the most direct way to operationalise this concern, and it is intuitive enough to explain to a clinical reviewer without a statistics background. The idea: take your primary imputation model's results, then systematically shift the imputed values for one or more groups by a fixed offset (often called delta), re-run the analysis, and see how extreme that offset has to become before your conclusion reverses. If a trivially small, clinically implausible delta is enough to flip the conclusion, your result is fragile. If only an extreme, clinically implausible delta would flip it, your result is robust to departures from MAR.

Concretely, suppose a trial comparing a new TB regimen against standard of care has missing six-month treatment-success outcomes, imputed under MAR, and the base-case result favours the new regimen. A tipping-point loop varies a delta applied only to the imputed (not observed) values in the intervention arm, recomputing the between-arm difference at each delta:

```r
library(dplyr)

tipping_point <- function(data, deltas) {
  results <- vector("list", length(deltas))
  for (i in seq_along(deltas)) {
    d <- deltas[i]
    adjusted <- data |>
      mutate(success_adj = if_else(imputed & arm == "intervention",
                                    success - d, success))
    diff <- mean(adjusted$success_adj[adjusted$arm == "intervention"]) -
      mean(adjusted$success_adj[adjusted$arm == "control"])
    results[[i]] <- tibble(delta = d, risk_difference = diff)
  }
  bind_rows(results)
}

tipping_point(trial_data, deltas = seq(0, 0.30, by = 0.02))
```

The same logic extends to cost-effectiveness: apply a delta to imputed QALYs (or to imputed costs) before recomputing the ICER, and report the delta at which the ICER crosses the willingness-to-pay threshold lambda established in Chapter 4. The statistical output of this loop is only half the job — the other half is a clinical judgement call: is a delta of 0.02 in treatment-success probability, or 0.05 QALYs, something that a clinician or patient-representative would consider plausible given what is known about why patients dropped out? If the tipping delta is clinically absurd, the primary conclusion stands on solid ground. If it is well within the range of plausible informative dropout, the conclusion is fragile and should be reported as such.

#report-table(
  [Tipping-point sensitivity analysis: six-month treatment-success risk difference (intervention minus control) as the delta applied to imputed intervention-arm successes increases, TB regimen trial],
  academic-table(
    columns: (1.2fr, auto, auto),
    align: (left, right, left),
    header: ([*Delta applied to imputed values*], [*Risk difference*], [*Favours*]),
    body: (
      [0.00 (base case, MAR)], [+18.0 pp], [Intervention],
      [0.05], [+13.0 pp], [Intervention],
      [0.10], [+8.0 pp], [Intervention],
      [0.15], [+3.0 pp], [Intervention],
      [~0.17 (tipping point)], [0.0 pp], [Neutral],
      [0.20], [-2.0 pp], [Control],
      [0.25], [-7.0 pp], [Control],
      [0.30], [-12.0 pp], [Control],
    ),
    footer: (table.cell(colspan: 3)[*Interpretation:* the conclusion favouring the intervention is robust unless imputed successes in the intervention arm are overstated by roughly 0.17 or more — a departure from MAR that clinical reviewers judged implausible given the dropout reasons recorded.],),
  ),
) <tab-ch07-tipping-point>

`mice` supports this kind of delta-adjustment directly: after generating imputations under MAR, you can post-process the imputed (but not observed) values in each completed dataset by adding a fixed offset before pooling, which is exactly the tipping-point mechanic above applied across multiply-imputed datasets rather than a single completed dataset.

Pattern-mixture models offer a complementary, more structural way to think about departures from MAR. Rather than imputing a single plausible value and then perturbing it, a pattern-mixture approach stratifies the data by missingness pattern — for example, "completed all follow-up," "dropped out after visit 2," "dropped out after visit 4" — and allows each pattern to have its own outcome distribution. You then combine these pattern-specific distributions into an overall estimate using explicit, stated assumptions about what the missing-pattern groups' outcomes would have looked like had they been observed. Those assumptions are where the scientific judgement lives: you might assume patients who dropped out track the same trajectory as similar patients still in follow-up (akin to assuming MAR within the model), or you might assume they track the trajectory of patients in the control arm from that point forward (a "jump to reference" assumption), or that their outcomes would have worsened faster than observed completers (a "placebo-based" or worsening assumption suited to safety concerns).

This reference-based family of assumptions is precisely the territory covered by `rbmi`, a CRAN package developed for reference-based multiple imputation in clinical trials, built to implement exactly this kind of pattern-mixture reasoning — imputing missing values for a given patient according to the trajectory of a specified reference arm or reference pattern rather than that patient's own arm, as a formal sensitivity check against informative dropout. Rather than naming specific `rbmi` functions here, the conceptual takeaway for an HEOR analyst is this: pattern-mixture and reference-based MI let you ask "what is the most defensible pessimistic (or optimistic) story about why these data are missing, and how much does the answer change under that story?" — which is a different and complementary question to the tipping-point analysis's "how far would the data need to be wrong before the conclusion flips?" A submission that reports both together is materially more convincing than one relying on MAR imputation alone.

== 7.6 Missing data in cost and QALY data

Everything in SS7.1-7.5 applies to missing data of any kind, but cost and QALY data bring two additional headaches that a simple missing covariate — say, a baseline lab value — does not.

The first is distributional shape. Healthcare cost data are notoriously right-skewed and often zero-inflated: most patients incur modest costs, a small number incur very large costs (a hospitalisation, a surgical complication), and some incur essentially zero cost in a given period (no healthcare contact at all). Missingness in cost data is rarely "random noise around the mean" — a missing cost record for a patient who was lost to follow-up after an uneventful visit looks nothing like a missing cost record for a patient who disappeared from the dataset immediately before an expensive hospitalisation. Naive mean imputation — filling every missing cost with the sample mean — is especially dangerous here because it does two things at once: it ignores the skew (replacing a potentially very high or very low true value with a moderate average), and it artificially shrinks the variance of the cost distribution, which then distorts downstream statistics like confidence intervals around incremental cost. The problem compounds with health-state-related dropout: patients who leave a trial because their condition is deteriorating are disproportionately likely to have missing late-stage cost and utility data, and deteriorating health plausibly correlates with higher resource use (more hospital contact) or, in some systems, reduced contact (patients too unwell to attend). Either way the missingness is informative — a form of MNAR — and treating it as MCAR by simply dropping or mean-filling those records biases the cost-effectiveness result in an unpredictable direction.

QALYs and the utility weights that compose them bring a second, structural constraint: utilities are bounded, typically on a scale from a negative value (states considered worse than death) up to 1 (full health), and that boundedness has to be respected by any imputation procedure. An imputation model built carelessly — for instance, a linear regression imputing utility values without constraint — can happily generate an imputed utility of 1.08 or produce an imputed cost that is negative, both of which are nonsensical and will silently corrupt a downstream QALY or ICER calculation if not caught.

The practical implication is that multiple imputation for cost and QALY data must be done on the natural scale appropriate to each variable, with constraints enforced rather than assumed away. `mice` supports exactly this kind of post-processing: imputed values for a given variable can be bounded, for example clamping imputed utilities to the plausible range before they are carried into the pooled dataset, or ensuring imputed costs cannot fall below zero. Some analysts additionally transform cost data (for example, imputing on a log scale and back-transforming) to better respect the skew described above, provided the back-transformation and any associated bias correction are documented.

```r
library(mice)

imp <- mice(trial_data, m = 20, method = c(cost = "pmm", utility = "pmm"),
            seed = 123)

# Post-process: clamp imputed utilities to the valid range and
# ensure imputed costs are non-negative
imp_clamped <- imp
for (i in seq_len(imp$m)) {
  comp <- complete(imp, i)
  comp$utility <- pmin(pmax(comp$utility, -0.59), 1)
  comp$cost <- pmax(comp$cost, 0)
  imp_clamped$imp$utility[[i]] <- comp$utility[is.na(trial_data$utility)]
  imp_clamped$imp$cost[[i]] <- comp$cost[is.na(trial_data$cost)]
}
```

#pitfall[Mean-imputing missing costs or utilities, or imputing them with an unconstrained model that ignores the [0,1]-ish bound on utilities and the non-negativity of costs, will silently distort the pooled cost and QALY estimates that feed into every downstream ICER calculation — always impute on the natural, bounded scale and sanity-check the completed dataset's range before proceeding.]

This matters directly for the cost/QALY tibble pipeline introduced in Chapter 4: the `treatment`/`cost`/`qaly` tibble that later feeds dominance pruning and ICER computation is exactly the kind of dataset where undetected missing-data mishandling upstream becomes invisible downstream. A dominance-pruning step applied to a tibble built from carelessly mean-imputed costs will happily prune strategies and rank the remainder with complete confidence, with no visible trace that the input costs were distorted. Any analyst building that pipeline from trial or registry data with incomplete cost or utility records should treat the imputation step as upstream quality control for the entire economic model, not as a mechanical pre-processing formality.

== 7.7 Reporting missing data handling for HTA

A technically sound missing-data analysis that is reported badly is, from an HTA reviewer's perspective, close to useless — the reviewer cannot assess what they cannot see. CHEERS 2022, already cited in Chapter 3 in connection with its item on methods-reporting detail, contains a specific checklist item requiring transparent reporting of how missing data were handled, and that item is the natural anchor for what a submission needs to include on this topic.

At minimum, a submission should report four things. First, the amount and pattern of missingness, broken down by study arm or group, not just as an aggregate percentage — a 10% missingness rate split evenly across arms tells a very different story from 2% missing in one arm and 18% in the other. This is where the visualisation tools from SS7.2 (`naniar`, `visdat`) earn their keep as reporting aids, not just exploratory ones: a simple missingness-by-arm table or plot communicates more to a reviewer in seconds than a paragraph of prose. Second, the assumed missing-data mechanism and the justification for that assumption — stating "we assumed data were missing at random conditional on baseline severity, treatment arm, and visit number" is a reportable, falsifiable claim; stating "data were assumed missing at random" with no stated conditioning variables is not. Third, the primary analysis method, stated with enough specificity to be reproducible: for example, "missing six-month utility values were handled using multiple imputation by chained equations with m = 50 imputations, imputing conditional on baseline EQ-5D, age, treatment arm, and disease severity, with Rubin's rules used to pool estimates." Fourth, and often the most neglected, the sensitivity analyses performed and their result — specifically whether the tipping-point delta needed to overturn the primary conclusion was judged clinically plausible or implausible, and whether any pattern-mixture or reference-based alternative assumptions (SS7.5) changed the headline cost-effectiveness conclusion.

A useful discipline is to draft this reporting as a short, self-contained paragraph the moment the imputation and sensitivity analyses are finalised, rather than reconstructing it from memory at submission-writing time:

```r
# Illustrative structure for the reporting paragraph's data
missingness_summary <- trial_data |>
  dplyr::group_by(arm) |>
  dplyr::summarise(
    n = dplyr::n(),
    n_missing_utility = sum(is.na(utility_6m)),
    pct_missing = round(100 * n_missing_utility / n, 1)
  )
```

#report-table(
  [Missing-data summary for the primary six-month utility endpoint, by randomised arm],
  academic-table(
    columns: (1.4fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Arm*], [*N randomised*], [*N missing utility (6m)*], [*% missing*]),
    body: (
      [Intervention], [120], [22], [18.3],
      [Control], [118], [9], [7.6],
      [Overall], [238], [31], [13.0],
    ),
    footer: (table.cell(colspan: 4)[Mechanism assumed: MAR, conditional on baseline EQ-5D, age, treatment arm, and disease severity. The pronounced imbalance between arms (18.3% vs 7.6%) is itself evidence against MCAR and motivates the tipping-point sensitivity analysis in @tab-ch07-tipping-point.],),
  ),
) <tab-ch07-missingness-by-arm>

Beyond CHEERS 2022, the ICH E9(R1) addendum on estimands and sensitivity analysis in clinical trials is the relevant reference for how intercurrent events — treatment discontinuation, rescue medication, death before an outcome can be assessed — and the missing data they generate should be framed from the outset of trial design, not patched on after the fact during analysis. ICH E9(R1)'s estimand framework asks the analyst to specify, before unblinding, how intercurrent events will be handled conceptually (treatment-policy, hypothetical, composite, while-on-treatment, or principal-stratum strategies), which in turn determines what the "right" missing-data assumption and primary analysis even are. An HTA submission that can point to a pre-specified estimand strategy, consistent with ICH E9(R1), alongside a CHEERS-compliant missing-data reporting paragraph, presents a far more defensible evidentiary package than one where the missing-data method appears to have been chosen after seeing which approach gave the most favourable result.

#agency-note[CHEERS 2022 requires explicit reporting of the amount, pattern, and handling of missing data as part of a health economic evaluation, and ICH E9(R1) requires that intercurrent events and their associated missing-data handling strategy be specified in relation to a pre-defined estimand; together they are the two reference points an HTA-facing missing-data section should be written against.]

Missing utility values are not only a missing-data problem — they are frequently a symptom of exactly the population, instrument, and measurement-timing choices that Chapter 8 addresses directly: how utilities are elicited, which instrument captures them, and how those choices interact with trial dropout. The next chapter turns to health-related quality of life and utility measurement in full.
