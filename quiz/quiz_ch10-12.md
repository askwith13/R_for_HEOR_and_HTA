# Quiz Questions: Chapters 10-12

## Chapter 10: Survival Analysis for Economic Evaluation

### Q136 [Easy] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** What does the hazard function describe, as distinguished from the Kaplan-Meier survival probability?
- A) The cumulative fraction of patients who have died since the start of follow-up
- B) The instantaneous risk of the event happening right now, given survival to this point
- C) The total number of patients still enrolled in the trial
- D) The proportion of patients censored before the end of follow-up
**Answer:** B
**Explanation:** The chapter's speedometer-vs-odometer analogy makes this explicit: survival probability is a cumulative, backward-looking summary, while the hazard is a forward-looking, instantaneous rate re-calculated continuously as time passes.

### Q137 [Easy] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** In `survival::survfit(Surv(time, status) ~ arm, data = trial_df)`, what does the `~ arm` term accomplish?
- A) It converts the survival times to a parametric distribution
- B) It stratifies the Kaplan-Meier curve by treatment arm
- C) It applies inverse-probability-of-censoring weights
- D) It fits a Cox proportional hazards model instead of a KM curve
**Answer:** B
**Explanation:** §10.1 states the `~ arm` term stratifies the KM curve by treatment arm, which is essential since HEOR work usually compares extrapolated survival between an intervention and a comparator.

### Q138 [Easy] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** Which of the six standard parametric distributions fitted with `flexsurvreg()` assumes a constant hazard over time?
- A) Gompertz
- B) Exponential
- C) Log-logistic
- D) Generalised gamma
**Answer:** B
**Explanation:** §10.2 describes the exponential distribution as having a constant hazard, one parameter, and being "almost never plausible for a chronic disease but a useful lower-bound sanity check."

### Q139 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** According to the chapter's pitfall in §10.2, why is comparing AIC/BIC across the six standard parametric distributions insufficient on its own for choosing an extrapolation model?
- A) AIC/BIC cannot be computed for distributions with more than two parameters
- B) AIC/BIC only measure fit within the observed data range and say nothing about divergence once extrapolated
- C) AIC and BIC always select the same model, so comparing both is redundant
- D) AIC/BIC require the proportional hazards assumption to hold
**Answer:** B
**Explanation:** The chapter warns that two distributions can have near-identical AIC within a trial's follow-up window yet diverge wildly once projected over a longer horizon, so the extrapolated curve must always be plotted and checked separately.

### Q140 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** In `flexsurv::flexsurvspline()`, what does setting `k = 0` internal knots produce?
- A) An error, since at least one knot is required
- B) A model equivalent to one of the standard parametric families (e.g. Weibull-equivalent on the hazard scale)
- C) A non-parametric Kaplan-Meier estimate
- D) A mixture cure model with zero cure fraction
**Answer:** B
**Explanation:** §10.3 explains that `k = 0` collapses the Royston-Parmar spline to a standard parametric family depending on the `scale=` argument, defaulting to the Weibull-equivalent on the hazard scale, making it a useful flexibility baseline.

### Q141 [Hard] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** In a mixture cure model fitted with `flexsurvcure(mixture = TRUE)`, how is overall survival S(t) structured?
- A) S(t) = π^(1 − S_u(t)), where π is the cure fraction
- B) S(t) = π + (1 − π) × S_u(t), where π is the cure fraction and S_u(t) is the uncured-group survival
- C) S(t) is identical to the ordinary Weibull survival function
- D) S(t) = π × S_u(t), ignoring the uncured subgroup entirely
**Answer:** B
**Explanation:** §10.4 gives the mixture-cure structure explicitly as S(t) = π + (1 − π)S_u(t): a cured fraction with survival fixed at 1 forever, blended with an uncured fraction following the chosen parametric distribution. (The π^(1−S_u(t)) form is the non-mixture structure instead.)

### Q142 [Hard] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** The chapter's pitfall on cure models warns that a fitted cure fraction can be spuriously inflated. What is the single most common cause it identifies?
- A) Using the non-mixture rather than mixture cure structure
- B) Fitting the uncured population with a log-normal distribution instead of Weibull
- C) Short or administratively-censored follow-up that makes the KM curve flatten near the end for reasons unrelated to true biological cure
- D) Omitting covariates from the `anc` argument
**Answer:** C
**Explanation:** The pitfall explicitly states that short or administratively-censored follow-up is the single most common cause of a spuriously large cure estimate, because censoring can flatten the KM curve in the same visual way genuine cure would.

### Q143 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** What is the defining feature of a "landmark" extrapolation approach described in §10.5?
- A) It uses only parametric curves for the entire observed and extrapolated period
- B) It uses the empirical Kaplan-Meier estimate for the observed trial duration, then splices in a parametric/spline extrapolation only beyond a chosen landmark time
- C) It fits a single Weibull curve across both the active-treatment and surveillance phases
- D) It requires reconstructing individual patient data from a published curve
- E) (not applicable)
**Answer:** B
**Explanation:** The chapter describes the landmark approach as trusting the real, observed KM curve for as long as good data exist, then handing off to a fitted parametric curve only for the unobserved tail beyond that point.

### Q144 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** Per the piecewise-model pitfall in §10.5, how should cut-points for a piecewise/landmark model ideally be chosen?
- A) By testing many cut-points and selecting the one with the best-looking kink in the KM curve
- B) By maximizing I-squared across candidate cut-points
- C) Pre-specified from a clinical rationale, such as the end of a fixed treatment course or a protocol-defined visit
- D) Automatically, using the AIC-minimizing time point from `flexsurvspline()`
**Answer:** C
**Explanation:** The pitfall equates eyeballing the KM curve for the best-looking kink with moving a regression breakpoint until R² improves — a multiple-comparisons problem — and recommends pre-specified clinical cut-points instead.

### Q145 [Easy] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** What does `survival::cox.zph()` test?
- A) Whether the Kaplan-Meier curve differs significantly between arms
- B) Whether the scaled Schoenfeld residuals from a fitted Cox model are correlated with time
- C) Whether a cure fraction is statistically supported
- D) Whether two parametric distributions have equivalent AIC
**Answer:** B
**Explanation:** §10.7 states `cox.zph()` tests whether scaled Schoenfeld residuals are correlated with time; under the proportional hazards assumption, residuals should fluctuate randomly around zero, while a trend indicates a time-varying effect.

### Q146 [Hard] [Image]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** IMAGE PLACEHOLDER: a chart showing the observed Kaplan-Meier curve (black step function) with all six standard parametric families (exponential, Weibull, Gompertz, log-logistic, log-normal, generalised gamma) overlaid within the trial follow-up window, closely clustering together, as in the figure referenced in §10.2. Based on the chapter's text accompanying this figure, why might such visual clustering within the observed window be misleading for model selection?
- A) It proves all six distributions are equally valid for any extrapolation horizon
- B) The divergence between distributions that matters for extrapolation typically only becomes visible once curves are projected beyond the observed data
- C) It shows that the Kaplan-Meier estimator is invalid once six parametric curves are fitted
- D) It means the log-likelihood cannot be computed for any of the six models
**Answer:** B
**Explanation:** The figure caption in §10.2 notes that within the trial's follow-up window the fits visually cluster close to the KM curve and each other, but the divergence that matters for extrapolation only becomes visible once the curves are projected beyond the observed data.

### Q147 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** In the context of competing risks, what is the key practical advantage of the subdistribution (Fine-Gray) hazard over the cause-specific hazard for a cost-effectiveness model?
- A) It is easier to compute by hand
- B) It directly models the cumulative incidence function — the actual probability mass flowing into each state in the presence of competing risks
- C) It eliminates the need for a transition matrix in `mstate`
- D) It assumes competing events never occur
**Answer:** B
**Explanation:** §10.10 explains the subdistribution hazard keeps patients who had a competing event in the risk set and directly models the cumulative incidence function, which is usually the quantity a cost-effectiveness model needs rather than a hypothetical cause-specific rate.

### Q148 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** What critical extra ingredient, beyond a digitized Kaplan-Meier curve, does the Guyot et al. (2012) IPD-reconstruction algorithm require?
- A) A pre-fitted Weibull model
- B) The numbers-at-risk table printed beneath the curve
- C) A multi-state transition matrix
- D) The original patient-level trial protocol
**Answer:** B
**Explanation:** §10.11 states the numbers-at-risk table beneath the curve is "the critical extra ingredient the original KM figure alone does not give you," anchoring how many individuals are censored versus experiencing events between risk-table intervals.

### Q149 [Hard] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** According to §10.12, what distinguishes NICE DSU TSD 21 from TSD 14?
- A) TSD 21 replaces TSD 14 entirely and makes the six standard parametric distributions obsolete
- B) TSD 21 extends TSD 14 by covering flexible spline-based (Royston-Parmar) models and cure models, which the standard six-distribution family cannot represent
- C) TSD 21 only applies to diagnostic test accuracy studies
- D) TSD 21 is concerned exclusively with proportional hazards testing
**Answer:** B
**Explanation:** The chapter describes TSD 21 as extending TSD 14's logic by covering Royston-Parmar spline models and cure models — structural assumptions, like a cured fraction, that none of TSD 14's six standard distributions can represent.

### Q150 [Easy] [Image]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** IMAGE PLACEHOLDER: a Kaplan-Meier curve plotted against a chosen parametric fit (Gompertz), solid where fitted to real trial-period data and dashed where it is pure extrapolation beyond a 36-month follow-up window, with a vertical dotted line marking the trial's end, as described in the §10.1 figure. What does everything to the right of the vertical dotted line represent?
- A) Additional observed trial data not yet included in the KM curve
- B) A model assumption rather than an observation, which should be labelled as such in any submission
- C) Background general-population mortality only
- D) Data that failed the proportional hazards test
**Answer:** B
**Explanation:** The figure caption explicitly states that everything to the right of the trial's end marker "is a model assumption, not an observation, and should be labelled as such in any submission."

## Chapter 11: Meta-Analysis

### Q151 [Easy] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** What key assumption distinguishes a fixed-effect (common-effect) meta-analysis model from a random-effects model?
- A) Fixed-effect models require binary outcomes, random-effects models require continuous outcomes
- B) A fixed-effect model assumes every study estimates the same true effect, while a random-effects model assumes each study estimates its own true effect drawn from a distribution of effects
- C) Fixed-effect models always produce narrower confidence intervals and are therefore preferred
- D) Random-effects models cannot be fitted with the `meta` package
**Answer:** B
**Explanation:** §11.1 states the fixed-effect model assumes all studies share one true effect with differences being pure sampling noise, while the random-effects model assumes each study's true effect is drawn from a distribution of true effects across settings.

### Q152 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** Why does the chapter recommend REML over DerSimonian-Laird (DL) as the primary τ² estimator in most HEOR meta-analyses?
- A) DL cannot be computed in R
- B) REML is a closed-form, non-iterative method while DL requires numerical optimization
- C) DL is known to understate τ² — and hence understate the confidence interval width — with few studies or rare binary events, while REML produces less biased variance estimates in that situation
- D) REML always produces statistically significant pooled effects
**Answer:** C
**Explanation:** §11.1 explains DL tends to understate τ² (and CI width) with small numbers of studies or rare events, while REML is generally preferred because it produces less biased variance estimates, particularly with few studies — a common situation in TB meta-analyses.

### Q153 [Easy] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** Which statistic rescales the information in Q and τ² into a percentage representing the share of total variability due to real between-study disagreement rather than sampling noise?
- A) I²
- B) The p-value from Egger's test
- C) SUCRA
- D) The diagnostic odds ratio
**Answer:** A
**Explanation:** §11.2 describes I² as solving the readability problem of τ² by rescaling the same information into a percentage of total variability attributable to genuine between-study disagreement, which is why I² is the most frequently quoted heterogeneity statistic.

### Q154 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** How does a prediction interval differ from a confidence interval around a pooled random-effects estimate?
- A) A prediction interval is always narrower because it only concerns one future study
- B) A prediction interval accounts for both uncertainty in the average effect and genuine study-to-study variation, so it is wider than the confidence interval
- C) A confidence interval and prediction interval are mathematically identical under random effects
- D) A prediction interval is only defined for fixed-effect models
**Answer:** B
**Explanation:** §11.2 explains that because individual studies' true effects genuinely vary, the prediction interval — answering what range a brand-new study's true effect would plausibly fall in — must be wider than the confidence interval, which only reflects precision of the average.

### Q155 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** What does asymmetry in a funnel plot (a gap in one bottom corner) visually suggest?
- A) That the random-effects model fits better than the fixed-effect model
- B) Possible publication bias or small-study effects, where smaller studies with unfavourable results may be missing
- C) That the I² statistic has been miscalculated
- D) That the pooled estimate must be discarded entirely
**Answer:** B
**Explanation:** §11.3 describes asymmetry — a gap where small, unfavourable-result studies "should" be but aren't — as the visual signature of concern for publication bias or small-study effects.

### Q156 [Hard] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** According to §11.3's pitfall, why is it problematic to run Egger's test or trim-and-fill mechanically whenever a funnel plot is available?
- A) These methods only work for continuous outcomes
- B) With fewer than ten studies (common in TB-programme meta-analyses), both methods have poor power and can produce misleading corrections driven by one or two outlying studies
- C) Egger's test cannot be computed in either the `meta` or `metafor` package
- D) Trim-and-fill always increases, never decreases, the pooled estimate
**Answer:** B
**Explanation:** The pitfall states that with fewer than ten studies, both Egger's test and trim-and-fill have poor power and can produce misleading corrections, so the funnel plot should instead be described qualitatively with the limitation flagged.

### Q157 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** In `metafor::rma()`, what does the `mods=` argument enable?
- A) Specification of the summary measure (RR, OR, MD, SMD)
- B) Addition of study-level moderators (predictors) to explain between-study heterogeneity, i.e. meta-regression
- C) Selection between fixed- and random-effects pooling
- D) Back-transformation of pooled proportions to the natural scale
**Answer:** B
**Explanation:** §11.4 describes `mods=` as accepting a formula of study-level moderators (e.g. mean age, region) to explain heterogeneity, partitioning total heterogeneity into the portion explained by moderators (QM) and residual heterogeneity.

### Q158 [Hard] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** What is "ecological bias" in the context of meta-regression, as warned about in §11.4's pitfall?
- A) Bias caused by excluding environmental/geographic covariates from the model
- B) The error of interpreting a between-study (aggregate-level) association as if it were a within-study (patient-level) association
- C) Bias arising only when fewer than ten studies are pooled
- D) A bias specific to double-arcsine transformed proportions
**Answer:** B
**Explanation:** The pitfall explains that meta-regression coefficients describe between-study associations, so a finding like "trials with older average age show smaller effects" says nothing reliable about whether an individual older patient benefits less — conflating the two is ecological bias.

### Q159 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** Why must hazard ratios be pooled on the log scale rather than their natural scale, per §11.5?
- A) Because `metagen()` only accepts log-transformed inputs
- B) Because HRs are ratios bounded below by zero and skewed, while the log scale is much closer to a normal distribution, suitable for inverse-variance pooling
- C) Because NICE DSU TSD 14 requires it as a reporting formality
- D) Because the log scale eliminates the need for standard errors
**Answer:** B
**Explanation:** §11.5 states that HRs are pooled on the log scale "where the sampling distribution is much closer to normal," since HRs themselves are bounded below by zero and skewed.

### Q160 [Hard] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** Why is pooling sensitivity and specificity separately considered wrong in a diagnostic test accuracy meta-analysis (§11.6)?
- A) Sensitivity and specificity cannot both be estimated from the same 2x2 table
- B) The two measures are not independent — a study reading a threshold more liberally will tend to show higher sensitivity and lower specificity together, so their negative correlation must be modelled jointly
- C) `mada::reitsma()` only accepts one of the two measures as input
- D) Sensitivity and specificity have different units and cannot be compared
**Answer:** B
**Explanation:** The chapter explains sensitivity and specificity move together depending on threshold choice, so a bivariate random-effects model that respects this negative correlation (via `reitsma()`) is needed rather than pooling each measure as if independent.

### Q161 [Medium] [Image]
**Chapter(s):** 11 — Meta-Analysis
**Question:** IMAGE PLACEHOLDER: a forest plot from `meta::forest()` showing nine studies with weight-sized confidence intervals, a pooled random-effects diamond at the bottom, and a prediction interval, as described in the §11.2 figure. What is the single most useful diagnostic purpose of this plot, according to the chapter text?
- A) It replaces the need to calculate I² or τ²
- B) It should be read before any summary statistic, because a cluster of overlapping intervals with one clear outlier tells a different, more actionable story than a diffuse spread of non-overlapping intervals, even with similar I²
- C) It only shows statistical significance, not effect direction
- D) It is used exclusively for diagnostic test accuracy reviews
**Answer:** B
**Explanation:** §11.2 states the forest plot "remains the single most useful diagnostic in this chapter" and should be read before any summary statistic for exactly the reason given in option B.

### Q162 [Medium] [Image]
**Chapter(s):** 11 — Meta-Analysis
**Question:** IMAGE PLACEHOLDER: an SROC (summary receiver operating characteristic) curve from `mada::reitsma()`, showing study-level sensitivity/false-positive-rate pairs as triangles plus a pooled summary point with 95% confidence and prediction regions, as in the §11.6 figure. What role does the SROC curve play in a diagnostic test accuracy review?
- A) It is the diagnostic analogue of the funnel plot for assessing publication bias
- B) It is the bivariate analogue of the forest plot, tracing the implied sensitivity/specificity trade-off while capturing the two correlated axes at once
- C) It shows only the pooled diagnostic odds ratio
- D) It replaces the need for a bivariate random-effects model
**Answer:** B
**Explanation:** §11.6 explicitly describes the SROC curve as "the bivariate analogue of the forest plot" for pairwise meta-analysis, capturing the correlated sensitivity/specificity axes simultaneously.

### Q163 [Easy] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** Which transformation is recommended in §11.7 when pooling proportions that include studies with values near 0 or 1 (e.g. rare resistance patterns)?
- A) Logit transformation
- B) Log transformation
- C) Double-arcsine (Freeman-Tukey) transformation
- D) Z-transformation
**Answer:** C
**Explanation:** The chapter states that when some studies have proportions near 0 or 1, the logit transform can behave poorly, and the double-arcsine (Freeman-Tukey) transformation — `measure = "PFT"` in `escalc()` — is the usual alternative.

### Q164 [Hard] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** According to §11.7's pitfall, why might very high I² (often exceeding 90%) when pooling prevalence or incidence across sites not necessarily indicate a broken model?
- A) High I² in proportion meta-analyses is always a software calculation error
- B) True prevalence genuinely differs by geography, population risk, and surveillance intensity, so a single pooled figure may misrepresent genuinely different underlying populations
- C) I² cannot be computed for log-transformed rates
- D) High I² only occurs with the double-arcsine transformation
**Answer:** B
**Explanation:** The pitfall explains that high heterogeneity is the norm rather than the exception in prevalence/incidence pooling because true prevalence genuinely differs across settings — this reflects real variation, not necessarily model failure.

### Q165 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** What does NICE DSU TSD 1 (Dias et al., 2011), referenced in §11.1, state about the choice between fixed-effect and random-effects models?
- A) A fixed-effect model should be the default unless random effects are statistically significant
- B) A fixed-effect model should only be used when there is a specific, justified reason to believe all studies share a single true effect, which must be stated explicitly
- C) Random-effects models are prohibited in HTA submissions
- D) The choice should be made after inspecting which model gives a narrower confidence interval
**Answer:** B
**Explanation:** The agency-note in §11.1 states TSD 1 takes the random-effects-as-default position, requiring explicit justification whenever a fixed-effect model is used instead.

## Chapter 12: Indirect Treatment Comparisons and Network Meta-Analysis

### Q166 [Easy] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** Why is a "naive" indirect comparison (comparing absolute outcomes from two unrelated trials directly) considered invalid?
- A) It requires a Bayesian framework that most software cannot run
- B) It destroys randomisation protection and is highly vulnerable to confounding by differences in baseline risk, trial era, region, and outcome definition between the two trials
- C) It can only be used for continuous outcomes, not binary ones
- D) It always produces narrower confidence intervals than anchored comparisons
**Answer:** B
**Explanation:** §12.1's pitfall states naive indirect comparison destroys randomisation and is vulnerable to confounding from differing baseline risk, era, region and outcome definitions, and is explicitly flagged as invalid by NICE DSU TSD 2.

### Q167 [Easy] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** In the Bucher method, if trial 1 gives an A-vs-C estimate and trial 2 gives a B-vs-C estimate, how is the indirect A-vs-B estimate calculated?
- A) By multiplying the two hazard ratios
- B) By subtracting the B-vs-C estimate from the A-vs-C estimate on the treatment-effect scale
- C) By averaging the two estimates
- D) By taking the geometric mean of the two confidence intervals
**Answer:** B
**Explanation:** §12.2 gives the Bucher formula d̂(AB) = d̂(AC) − d̂(BC): if A is better than C by d̂(AC) and B is better than C by d̂(BC), then A is better than B by their difference.

### Q168 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** In the Bucher method, how is the variance of the indirect A-vs-B estimate calculated from the two independent trial variances?
- A) Var(AB) = Var(AC) − Var(BC)
- B) Var(AB) = Var(AC) + Var(BC)
- C) Var(AB) = Var(AC) × Var(BC)
- D) Var(AB) = max(Var(AC), Var(BC))
**Answer:** B
**Explanation:** §12.2.2 explains the variances add, not subtract, because the two trials are statistically independent; Var(X−Y) = Var(X) + Var(Y) for independent variables, since the minus sign affects the expectation but not the variance.

### Q169 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What is the "similarity" or "transitivity" assumption that the Bucher method relies on?
- A) That all trials must use the exact same sample size
- B) That trial 1 and trial 2 must be similar enough in all effect modifiers that their respective C arms can be treated as exchangeable
- C) That the outcome must be measured on a log scale
- D) That both trials must have been published in the same year
**Answer:** B
**Explanation:** §12.2.4 defines transitivity as requiring the two trials be similar enough in everything that could modify the relative treatment effect, so the C arm in trial 1 can be treated as exchangeable with the C arm in trial 2.

### Q170 [Easy] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What format does `netmeta()` expect its input data to be in?
- A) Arm-based, one row per treatment arm
- B) Contrast-based, one row per treatment comparison per study
- C) Wide format, one column per study
- D) Raw patient-level individual data only
**Answer:** B
**Explanation:** §12.3.2 states `netmeta()` expects contrast-based data (one row per comparison per study), and the companion function `pairwise()` converts arm-level extractions into this format.

### Q171 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What does the `reference.group` argument in `netmeta()` control?
- A) Which treatment's data is excluded from the analysis
- B) Which treatment all relative effects in the summary output are reported against
- C) Whether the model is fixed-effect or random-effects
- D) The summary measure used (OR, RR, HR)
**Answer:** B
**Explanation:** §12.3.3 explains `reference.group` fixes which treatment all relative effects are reported against, so setting it to the standard-of-care makes the output read naturally as "each regimen vs standard of care."

### Q172 [Hard] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** Why do most Bayesian NMA packages (`gemtc`, `multinma`) require at least 4 MCMC chains, per the convergence pitfall in §12.4?
- A) Four chains is a regulatory requirement under NICE DSU TSD 2
- B) A Rhat near 1.00 only shows chains have mixed with each other, not that the full posterior has been explored; dispersed starting values in multiple chains guard against chains converging together on similarly wrong values
- C) Fewer than 4 chains cannot be run in JAGS
- D) Four chains are needed to compute SUCRA values
**Answer:** B
**Explanation:** The pitfall warns Rhat near 1.00 is not a complete convergence check, particularly for the heterogeneity parameter τ, and that running multiple chains from dispersed starting values is the standard safeguard against chains getting "stuck at similar but wrong values together."

### Q173 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What is the key practical difference that lets `multinma` combine evidence that `gemtc` typically cannot in the same network?
- A) `multinma` can use JAGS while `gemtc` cannot
- B) `multinma` accepts individual patient data (IPD), aggregate data (AgD), or a mixture of both within the same network
- C) `multinma` does not require any prior specification
- D) `multinma` only supports binary outcomes
**Answer:** B
**Explanation:** §12.4 states `multinma`'s main practical advantage over `gemtc` is accepting IPD, AgD, or a mixture within the same network, relevant when a submission combines a trial with patient-level access and comparator trials known only from aggregate results.

### Q174 [Hard] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What is the essential difference between node-splitting and the design-by-treatment interaction test for assessing network consistency (§12.5)?
- A) Node-splitting is global across the whole network, while design-by-treatment interaction tests only one edge at a time
- B) Node-splitting tests one specific comparison at a time for direct-vs-indirect agreement, while design-by-treatment interaction is a global test across the whole network's design structure
- C) They are mathematically identical tests implemented in different packages
- D) Node-splitting can only be run in `netmeta`, and design-by-treatment interaction only in `gemtc`
**Answer:** B
**Explanation:** §12.5 describes node-splitting as a local method examining one edge at a time, while design-by-treatment interaction testing is the standard global method testing consistency across the whole network simultaneously — they are complementary, not competing.

### Q175 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** According to the pitfall in §12.5, what does a non-significant node-split p-value on every edge of a network fail to guarantee?
- A) That the network has enough studies to compute I²
- B) That the network is free of inconsistency, since node-splitting can miss patterns of inconsistency spread diffusely across the network rather than concentrated on one comparison
- C) That the common-effect model is preferred over random-effects
- D) That SUCRA values can be validly computed
**Answer:** B
**Explanation:** The pitfall explicitly warns that a node-split p-value comfortably above 0.05 on every edge does not mean the network is free of inconsistency, because diffuse inconsistency spread across the network is exactly what the global design-by-treatment test is built to catch.

### Q176 [Hard] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** Per §12.7, why is a constant (proportional-hazards) hazard ratio often the wrong assumption for an oncology survival network?
- A) Oncology trials never report hazard ratios
- B) Immunotherapies and targeted agents commonly show hazard ratios that are far from 1 early on and move toward 1 or cross over late, violating a constant-HR assumption
- C) The flexsurv package cannot fit hazard ratios for oncology data
- D) NICE DSU TSD 18 prohibits the use of hazard ratios in networks
**Answer:** B
**Explanation:** The chapter explains that hazard ratios in oncology trials are frequently far from 1 early (while treatment effect is building or early toxicity dominates) and move toward 1 or cross over late, which the proportional-hazards NMA's constant-HR assumption cannot represent.

### Q177 [Hard] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What does the chapter's pitfall in §12.7 state about implementing the full Jansen (2011) / TSD 18 fractional polynomial NMA of survival curves in R?
- A) It is fully implemented as a single function in the `flexsurv` package
- B) There is no widely adopted, actively maintained CRAN package implementing the full method end-to-end; it is genuinely bespoke analysis typically built in a Bayesian framework (WinBUGS/JAGS/Stan)
- C) It is implemented identically in both `gemtc` and `netmeta`
- D) It requires no Bayesian modelling at all, only `flexsurvspline()`
**Answer:** B
**Explanation:** The pitfall explicitly states there is no widely adopted CRAN package implementing the full multi-arm, multi-study fractional polynomial NMA end-to-end, and that any code presenting a single named function as doing this whole job should be treated with suspicion.

### Q178 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What is SUCRA, as introduced in §12.8?
- A) A test statistic for publication bias in networks
- B) A single number between 0 and 1 summarising the full distribution of a treatment's rank across MCMC iterations, with 1 meaning certain to be best
- C) A measure of between-study heterogeneity specific to Bayesian NMA
- D) The Bayesian equivalent of Egger's test
**Answer:** B
**Explanation:** §12.8 defines SUCRA (Surface Under the Cumulative RAnking curve) as a single number between 0 and 1 summarising each treatment's rank distribution from the MCMC sample, where 1 means certain to be best and 0 certain to be worst.

### Q179 [Medium] [Image]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** IMAGE PLACEHOLDER: a network geometry diagram from `netgraph()` showing four treatment nodes (A, B, C, D) connected by edges of varying thickness proportional to the number of studies, with C sitting at the network's hub, as in the §12.3.4 figure. What question does inspecting this network geometry answer that a numerical summary table does not?
- A) The exact pooled odds ratio for every pairwise comparison
- B) Whether the network is a simple star, a connected loop allowing consistency checks, or contains a treatment connected only through one thin edge — and whether every treatment of interest is even connected to the network at all
- C) The exact value of τ² for the random-effects model
- D) The DIC value comparing fixed vs random effects models
**Answer:** B
**Explanation:** §12.3.4 states that reviewing the network geometry reveals whether the structure is a simple star, a connected loop, or has a thinly-connected treatment, and makes visible whether every treatment of interest is even connected to the network through shared comparators at all.

### Q180 [Hard] [Image]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** IMAGE PLACEHOLDER: a rankogram showing stacked probability bars for four treatments (A, B, C, D) across possible rank positions (1=best to 4=worst), derived from 10,000 simulated draws of a fitted `netmeta` random-effects model, as in the §12.8 figure. What critical caveat does the chapter's pitfall attach to interpreting a treatment's high SUCRA or P-score shown by such a rankogram?
- A) Rankograms cannot be produced for frequentist NMA models
- B) A treatment can carry the top rank while its credible/confidence interval overlaps substantially with lower-ranked treatments, meaning the ranking should never be presented without the underlying effect estimates and their uncertainty
- C) Rankograms are only valid when all comparisons in the network are direct, not indirect
- D) SUCRA and P-score always disagree with each other in the same network
**Answer:** B
**Explanation:** §12.8's pitfall explicitly warns that a high rank with a wide, overlapping interval usually reflects a thinly-evidenced comparison rather than a clinically meaningful difference, and a ranking metric should never be presented without the accompanying forest-plot or league-table uncertainty.
