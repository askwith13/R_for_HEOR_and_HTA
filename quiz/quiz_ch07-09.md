# Quiz Bank: Chapters 7–9

## Chapter 7: Missing Data

### Q091 [Easy] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Under Rubin's framework, which missing-data mechanism means the probability of a value being missing is pure noise, unrelated to both observed and unobserved data?
- A) MAR
- B) MCAR
- C) MNAR
- D) Informative censoring
**Answer:** B
**Explanation:** The chapter defines MCAR as missingness equivalent to "a coin flip applied independently to every record," unrelated to either observed or unobserved data.

### Q092 [Medium] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** A trial finds that non-response to a 12-week EQ-5D questionnaire is higher among patients who missed their clinic visit, and clinic attendance is associated with a *recorded* baseline severity score. What mechanism does this describe?
- A) MCAR, because the missingness pattern looks random
- B) MAR, because conditioning on the observed baseline severity explains the missingness
- C) MNAR, because the unobserved EQ-5D score itself drives missingness
- D) It cannot be classified without more statistical tests
**Answer:** B
**Explanation:** The chapter's worked example states that when missingness depends on an observed covariate (baseline severity) rather than the unobserved value itself, this is MAR.

### Q093 [Hard] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Why can MCAR, MAR, and MNAR never be distinguished using the observed data alone?
- A) Because R's `mice` package cannot compute the relevant test statistics
- B) Because the three mechanisms describe the behaviour of the *unobserved* values, and all three can produce an identical pattern of missing cells
- C) Because Little's MCAR test always returns a significant result on real data
- D) Because regulatory guidance forbids testing missingness mechanisms
**Answer:** B
**Explanation:** The text states these three scenarios "can produce an identical pattern of missing cells," and since the mechanism is a statement about unobserved values, it can never be confirmed or refuted by observed data alone.

### Q094 [Easy] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Which R package function implements Little's formal statistical test for the MCAR assumption?
- A) `visdat::vis_dat()`
- B) `naniar::gg_miss_upset()`
- C) `naniar::mcar_test()`
- D) `mice::pool()`
**Answer:** C
**Explanation:** `naniar::mcar_test()` implements Little's MCAR test, comparing means across missingness patterns to assess consistency with MCAR.

### Q095 [Medium] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** According to the chapter's pitfall note, what is the correct interpretation of a *non-significant* result from `mcar_test()`?
- A) It proves the data are MCAR and complete-case analysis is safe
- B) It only means the test found no evidence against MCAR; it is structurally blind to MNAR
- C) It confirms the data are MNAR
- D) It means multiple imputation is unnecessary
**Answer:** B
**Explanation:** The pitfall explicitly warns that a non-significant result "does not certify your data as MCAR" and that the test cannot detect MNAR, since missingness there depends on the unobserved value itself.

### Q096 [Medium] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Under what condition does the chapter consider complete-case (listwise deletion) analysis a defensible choice?
- A) Whenever more than 20% of data are missing
- B) Whenever a disease-specific instrument was used
- C) When missingness is genuinely MCAR and the proportion missing is small (under roughly 5%)
- D) Whenever the dataset includes cost and QALY variables
**Answer:** C
**Explanation:** The chapter states complete-case analysis is "a perfectly defensible choice" only when missingness is genuinely MCAR and the missing proportion is small, e.g. under 5%.

### Q097 [Hard] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Why does naive mean-imputation produce standard errors that are systematically too small?
- A) Because mean imputation always overestimates the true population mean
- B) Because filling every gap with the identical constant mechanically shrinks the completed dataset's variance, hiding the fact that each missing value was never truly known
- C) Because R's `mean()` function has a known numerical bug
- D) Because mean imputation only works for binary variables
**Answer:** B
**Explanation:** The chapter explains that filling gaps with the same `mean_fill` constant mechanically shrinks variance, so the resulting SE understates the true uncertainty of not knowing the missing values.

### Q098 [Medium] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** In `mice`, which imputation method is the default and generally preferred choice for continuous variables like cost or utility, and why?
- A) `"logreg"`, because it respects binary outcomes
- B) `"polyreg"`, because it models unordered categories
- C) `"pmm"` (predictive mean matching), because it imputes using observed donor values rather than inventing numbers outside the plausible range
- D) `"norm"`, because it always produces normally distributed imputations
**Answer:** C
**Explanation:** The text states PMM is the default and preferred for continuous variables precisely because it draws from observed donor values, keeping imputations within a plausible range.

### Q099 [Hard] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** In Rubin's rules for pooling multiply-imputed estimates, what does the "between-imputation variance" component capture that single imputation discards?
- A) The usual sampling variance from any one completed dataset
- B) How much the estimate itself varies depending on which imputed values happened to be drawn across the m datasets
- C) The measurement error of the original instrument
- D) The variance explained by the regression model's R-squared
**Answer:** B
**Explanation:** Between-imputation variance reflects how much estimates fluctuate across the m imputed datasets due to not knowing the true missing values — exactly the piece single imputation discards.

### Q100 [Medium] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Why is the degrees of freedom for a pooled multiple-imputation estimate often a non-whole number (e.g. 47.3) that is smaller than for a complete single dataset of the same size?
- A) It is a software rounding artifact with no statistical meaning
- B) It explicitly discounts for the extra uncertainty from not knowing the true missing values, especially when imputed datasets disagree with each other
- C) It reflects the number of variables in the dataset divided by the number of imputations
- D) `pool()` always sets degrees of freedom to m − 1
**Answer:** B
**Explanation:** The difficult-terminology box explains the fractional degrees of freedom is a deliberate penalty reflecting genuine extra uncertainty, growing larger (df shrinking more) as between-imputation disagreement increases.

### Q101 [Hard] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** In a tipping-point sensitivity analysis for a cost-effectiveness ICER, what does the analysis report?
- A) The exact p-value of the primary multiple imputation model
- B) The delta (offset) applied to imputed values at which the ICER crosses the willingness-to-pay threshold, interpreted against clinical plausibility
- C) The proportion of patients lost to follow-up
- D) The value of λ that should be used in all future analyses
**Answer:** B
**Explanation:** Tipping-point analysis systematically shifts imputed values by a delta and reports the delta at which the ICER crosses λ, with the clinical judgement of whether that delta is plausible determining the conclusion's robustness.

### Q102 [Hard] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** The chapter identifies two "additional headaches" that missing cost and QALY data bring beyond a simple missing covariate. What are they?
- A) Measurement error and recall bias
- B) Distributional shape (skewness, zero-inflation) and the bounded ([0,1]-ish) nature of utilities
- C) Sample size and statistical power
- D) Currency conversion and inflation adjustment
**Answer:** B
**Explanation:** Section 7.6 states cost data are right-skewed and zero-inflated, while utilities are bounded (e.g., floor near −0.59, ceiling at 1), both of which an unconstrained imputation model can violate.

### Q103 [Medium] [Image]
**Chapter(s):** 7 (Missing Data)
**Question:** IMAGE PLACEHOLDER: a `naniar::vis_miss()`-style heatmap of a trial economic dataset, rows clustered by missingness pattern, showing that patients missing their 12-week EQ-5D score are the same patients missing their 12-week cost record. What does this co-occurrence pattern most plausibly support?
- A) Independent MCAR noise in each column
- B) A shared-cause MAR or MNAR story rather than independent MCAR noise
- C) That the dataset should be discarded entirely
- D) That Little's MCAR test is unnecessary
**Answer:** B
**Explanation:** The chapter states that clustering of co-missing utility and cost variables in `naniar::vis_miss()` "would support a shared-cause MAR or MNAR story rather than independent MCAR noise in each column."

### Q104 [Easy] [Image]
**Chapter(s):** 7 (Missing Data)
**Question:** IMAGE PLACEHOLDER: a ranked bar chart showing the number of missing values per variable in a trial dataset, produced with one `naniar` function. Which function generates this specific plot?
- A) `naniar::gg_miss_upset()`
- B) `naniar::gg_miss_var()`
- C) `visdat::vis_dat()`
- D) `naniar::mcar_test()`
**Answer:** B
**Explanation:** `gg_miss_var()` "plots the number (or proportion) of missing values per variable as a simple ranked bar chart," described as the fastest way to triage which columns need scrutiny.

### Q105 [Hard] [Image]
**Chapter(s):** 7 (Missing Data)
**Question:** IMAGE PLACEHOLDER: an UpSet-style plot showing combinations of co-missing variables across a wide claims dataset with cost, utility, and comorbidity fields. The chapter recommends this plot type specifically for which situation?
- A) When there are fewer than two variables with missingness
- B) When you have more than two or three variables with missingness, where a pairwise correlation plot becomes unreadable
- C) Only when all variables are binary
- D) Only for datasets with exactly one missing variable
**Answer:** B
**Explanation:** `naniar::gg_miss_upset()` "goes further and shows... combinations of co-missing variables — essential once you have more than two or three variables with missingness."

## Chapter 8: Health-Related Quality of Life and Utilities

### Q106 [Easy] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** In the HEOR sense used throughout the book, a utility is anchored so that which two values represent full health and death respectively?
- A) 100 and 0
- B) 1 and 0
- C) 10 and −10
- D) 1 and −1
**Answer:** B
**Explanation:** The chapter states a utility is "a single number that expresses how good or bad a health state is, anchored so that 1 represents full health and 0 represents dead."

### Q107 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Why does NICE's reference case require a generic preference-based instrument like EQ-5D for the base-case QALY calculation rather than a disease-specific instrument?
- A) Disease-specific instruments are always more expensive to administer
- B) A common, cross-disease utility currency is needed so "1 QALY" means the same thing when comparing a TB regimen against a cardiology or oncology intervention competing for the same budget
- C) Disease-specific instruments cannot be scored by computer software
- D) NICE guidance bans disease-specific instruments from trials entirely
**Answer:** B
**Explanation:** The chapter explains resource-allocation bodies compare interventions across disease areas against one WTP threshold, which "is only coherent if '1 QALY' means the same thing regardless of which disease produced it" — requiring a common generic instrument.

### Q108 [Medium] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** What is the central function of the CRAN `eq5d` package used for?
- A) Fitting beta regression models to utility data
- B) Converting respondent-level EQ-5D dimension scores into a single utility index using a specified country's value set
- C) Performing Little's MCAR test on utility data
- D) Running discrete choice experiment conditional logit models
**Answer:** B
**Explanation:** `eq5d()` "takes a data frame of respondent-level dimension scores... and an argument specifying which national value set to apply, returning a single utility index."

### Q109 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Why does scoring the same EQ-5D health-state profile with a UK value set versus a US value set produce different utility numbers?
- A) The two countries' populations use different numbers of dimensions
- B) The two populations' revealed preferences for health-state descriptions (e.g. extreme pain/discomfort) are not identical, since value sets are country-specific
- C) The US value set has not been validated by the EuroQol Group
- D) US respondents are not asked time trade-off questions
**Answer:** B
**Explanation:** The chapter states value sets reflect the preferences of the population in which they were elicited, and "different countries' general publics do not value the same health-state descriptions identically."

### Q110 [Medium] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** What is the purpose of a "mapping" or "crosswalk" algorithm in utility estimation?
- A) To convert currency units between countries for cost reporting
- B) To predict an EQ-5D-equivalent utility from a disease-specific instrument score, using a model fit in an external dataset where both instruments were collected
- C) To impute missing baseline covariates in a regression model
- D) To test whether missingness is MCAR
**Answer:** B
**Explanation:** Mapping fits a statistical model in an external dataset with both instruments, then applies that algorithm to a trial's disease-specific scores to generate the utility currency the HTA model needs.

### Q111 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** What is the key difference between direct (response) mapping and indirect (utility/value) mapping?
- A) Direct mapping models each EQ-5D dimension separately via ordinal regression, then runs predictions through the value set; indirect mapping regresses the already-computed utility index directly against disease-specific scores
- B) Direct mapping is always more accurate and should be preferred universally
- C) Indirect mapping requires fitting five separate ordinal regression models
- D) Direct mapping cannot be validated by cross-validation
**Answer:** A
**Explanation:** Direct mapping models the five ordered dimension responses (e.g. via `MASS::polr()`) and composes through the value set; indirect mapping regresses the single utility index directly, losing EQ-5D's compositional structure.

### Q112 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Why is fitting `lm()` (OLS) directly to a raw EQ-5D utility index considered theoretically poor, despite being common in the mapping literature?
- A) `lm()` cannot run on data with more than 200 observations
- B) OLS allows predicted values above 1.0 or in otherwise impossible regions, and its homoscedastic-normal-error assumption misdescribes a boundary-spiked, skewed outcome
- C) OLS requires the outcome variable to be strictly binary
- D) R does not support linear regression on utility data
**Answer:** B
**Explanation:** The text states OLS "allows predicted values above 1.0" and its constant-variance normal-error assumption is "a poor description of a variable with a boundary spike," motivating beta regression, censored regression, or mixture models instead.

### Q113 [Medium] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Under a multiplicative age/sex-adjustment approach to disease-specific utility, why is this generally preferred over a purely additive adjustment in long-horizon cohort models?
- A) Multiplicative adjustments are easier to code than additive ones
- B) Multiplicative approaches naturally compress toward (but rarely cross) zero, avoiding the risk of implausible negative utilities after stacking many decrements over 20–30 years
- C) Additive adjustments cannot be implemented in R
- D) Multiplicative adjustment eliminates the need for background mortality data
**Answer:** B
**Explanation:** The chapter notes additive adjustment "is more prone to producing negative or clearly implausible utilities" over a long horizon, since "there is no multiplicative floor stopping the cumulative subtraction from running arbitrarily low."

### Q114 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Why must background (all-cause) mortality be layered onto disease-specific mortality in a long-horizon Markov model?
- A) Because disease-specific mortality data are never available
- B) Without it, the model implicitly assumes a cohort member who survives the modelled disease never dies of anything else, overstating survival, QALYs, and costs in later cycles
- C) Because NICE prohibits disease-specific mortality estimates
- D) Because background mortality replaces the need for discounting
**Answer:** B
**Explanation:** The chapter explains that omitting age/sex-specific all-cause mortality "overstates survival and therefore overstates total QALYs and costs accrued in later cycles."

### Q115 [Easy] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** In a Time Trade-Off (TTO) elicitation, if a respondent is indifferent between living T years in an impaired health state and living x years (x < T) in full health, how is the utility of the impaired state calculated?
- A) utility = T − x
- B) utility = x/T
- C) utility = T/x
- D) utility = 1 − (x/T)
**Answer:** B
**Explanation:** The chapter states "at that indifference point, the utility of the impaired health state is simply x/T."

### Q116 [Medium] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** In a Standard Gamble (SG) elicitation, what does the indifference probability p represent?
- A) The proportion of respondents who preferred the gamble
- B) The utility of the health state, read off directly as the probability of full health at which the respondent is indifferent between the certain health state and the gamble
- C) The probability that the respondent misunderstood the question
- D) The confidence interval width around the TTO estimate
**Answer:** B
**Explanation:** The text states "the utility of the health state is then read off directly as that indifference probability p" once the respondent is indifferent between the certain state and the gamble.

### Q117 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Why can a Discrete Choice Experiment (DCE) alone not directly produce utilities anchored at dead = 0 and full health = 1?
- A) DCE choice data cannot be analysed statistically
- B) DCE yields utilities only on an arbitrary scale anchored between the best and worst profiles shown, requiring a TTO/SG anchoring component to reach the dead=0/full-health=1 metric
- C) DCE requires face-to-face interviews that are logistically impossible
- D) DCE can only be used for disease-specific instruments
**Answer:** B
**Explanation:** The chapter states a DCE alone "only yields utilities on an arbitrary scale," so many value-set studies combine DCE with a TTO/SG component "specifically to anchor the resulting scale."

### Q118 [Medium] [Image]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** IMAGE PLACEHOLDER: a histogram of EQ-5D-type utility scores for a mild-severity subgroup, showing roughly 25% of observations piled exactly at 1.0 and a left-skewed spread below it, as summarised in the chapter's table "Mean (SD) EQ-5D-type utility and ceiling-spike proportion by disease severity subgroup." What does this ceiling spike primarily justify?
- A) Using ordinary least squares without modification
- B) Rejecting OLS in favour of methods such as beta regression, censored (Tobit) regression, or finite mixture models that respect the boundary and skew
- C) Discarding the mild-severity subgroup entirely
- D) Treating all utilities above 0.8 as missing data
**Answer:** B
**Explanation:** Section 8.4 states the visible ceiling spike at 1.0 is "the whole reason OLS was rejected in favour of beta regression," alongside censored regression and mixture models as alternatives.

### Q119 [Hard] [Image]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** IMAGE PLACEHOLDER: a line chart plotting general-population EQ-5D norm utility against age band (18–44 through 75+), declining from about 0.93 to 0.72, with a second line showing an age-adjusted disease-specific utility starting at 0.80 at age 45–54. According to the chapter's worked multiplicative age-adjustment, what is the age-adjusted disease utility at the 75+ band?
- A) 0.800 (unchanged)
- B) approximately 0.655
- C) approximately 0.72
- D) approximately 1.000
**Answer:** B
**Explanation:** The chapter's table computes 0.80 × (0.72/0.88) ≈ 0.655 as the age-adjusted disease utility in the 75+ band, following the multiplicative norm-ratio formula.

### Q120 [Medium] [Image]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** IMAGE PLACEHOLDER: a methods-section table comparing TTO, Standard Gamble, and DCE side by side on elicited quantity, theoretical basis, and anchoring to dead=0. Which method's theoretical basis is explicitly rooted in von Neumann–Morgenstern expected utility theory?
- A) Time Trade-Off (TTO)
- B) Standard Gamble (SG)
- C) Discrete Choice Experiment (DCE)
- D) Random utility theory does not apply to any of the three
**Answer:** B
**Explanation:** The chapter's comparison table lists SG's theoretical basis as "von Neumann-Morgenstern expected utility theory," distinguishing it from TTO (practical/intuitive) and DCE (random utility theory).

## Chapter 9: Costs and Resource Use

### Q121 [Easy] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** The chapter decomposes costing into three steps. What are they?
- A) Collection, cleaning, and reporting
- B) Identification, measurement, and valuation
- C) Discounting, inflation, and conversion
- D) Sampling, imputation, and pooling
**Answer:** B
**Explanation:** Section 9.1 states costing is "conventionally decomposed into three steps... identification... measurement... and valuation."

### Q122 [Medium] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** Why does the chapter recommend keeping quantity and unit cost as separate columns rather than pre-multiplying into a single "total cost" field?
- A) R cannot multiply two numeric columns together
- B) Separating them enables deterministic and probabilistic sensitivity analysis on unit cost or quantity independently, and re-valuation under a different country's cost list
- C) Total cost columns are not supported by `dplyr`
- D) Separate columns reduce the file size of the dataset
**Answer:** B
**Explanation:** The heor-practice note states keeping quantity and unit cost separate "is what allows deterministic sensitivity analysis on the unit cost alone, probabilistic sensitivity analysis... and re-valuation under a different country's cost list."

### Q123 [Hard] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** What is the common analyst error the chapter flags regarding unit costs from multiple facility types (e.g., district hospital vs. primary health centre)?
- A) Using INR instead of USD throughout
- B) Averaging the raw unit costs before joining to resource-use quantities, rather than averaging total costs or weighting by caseload
- C) Failing to round unit costs to the nearest integer
- D) Applying PPP conversion to unit costs instead of total costs
**Answer:** B
**Explanation:** The pitfall notes "averaging unit costs first silently assumes equal patient volume at each facility" — total costs should be averaged (or weighted by caseload) instead.

### Q124 [Medium] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** When inflating and currency-converting unit costs, what is the correct order of operations?
- A) Convert currency first, then inflate to a common price year
- B) Inflate to a common price year within the source currency first, then convert currency
- C) Order does not matter as long as both steps are eventually applied
- D) Apply PPP conversion twice to cancel out exchange-rate volatility
**Answer:** B
**Explanation:** The chapter states explicitly: "inflate to a common price year within the source currency first, then convert currency... second. Reversing the order mixes an inflation index computed in one currency with a conversion factor computed in another."

### Q125 [Medium] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** When is a PPP (purchasing power parity) conversion factor preferred over a nominal exchange rate for currency conversion?
- A) When comparing real resource burden across countries of different income levels, such as benchmarking an Indian TB-programme analysis against global literature unit costs
- B) Whenever reporting to a NICE-facing submission exclusively
- C) Only when converting from USD to EUR
- D) PPP should never be used in HEOR analyses
**Answer:** A
**Explanation:** The chapter states PPP conversion factors "are the standard choice when the purpose is comparing real resource burden across countries of different income levels," unlike nominal exchange rates which reflect market trading value.

### Q126 [Hard] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** What is the key geometric difference between how cost data and utility data violate OLS assumptions?
- A) Costs have a spike at a ceiling like utilities do
- B) Costs are bounded only below at 0 with no upper ceiling and heavy right tails (spike at the floor), while utilities are bounded on [0,1]-ish with a ceiling spike at 1
- C) Costs are always normally distributed while utilities are skewed
- D) There is no meaningful difference between the two data types
**Answer:** B
**Explanation:** The chapter states costs are "bounded only below at 0, have no natural upper ceiling, and the 'spike' sits at the floor," contrasting with utilities' two-sided [0,1] bound with a ceiling spike at 1.

### Q127 [Medium] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** Why does the chapter insist that structural zeros in cost data (e.g., no hospitalisation at all) should not be treated as missing data?
- A) Because R cannot represent zero values in a numeric vector
- B) Because the zeros represent genuine events that never happened, and treating them as missing (imputing or dropping) biases the estimate just as treating them as an ordinary low continuous value (e.g., plain log-OLS) does
- C) Because zero-cost patients should always be excluded from cost-effectiveness analysis
- D) Because structural zeros only occur in LMIC settings
**Answer:** B
**Explanation:** The chapter explicitly distinguishes these as "structural zeros (the event never happened), not missing data," warning that both imputing/dropping them and fitting a single continuous-only model are wrong.

### Q128 [Hard] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** Why does exponentiating a prediction from a model fit as `lm(log(cost) ~ ...)` fail to recover the arithmetic mean cost needed for an ICER?
- A) Exponentiation is mathematically undefined for cost data
- B) Exponentiating a log-OLS prediction recovers the median (geometric mean) on the original scale, not the arithmetic mean, which is what sums like total programme cost require
- C) `lm()` cannot fit models with a `log()` transformation applied to the outcome
- D) The arithmetic mean is always smaller than the geometric mean
**Answer:** B
**Explanation:** The pitfall states this "recovers the median (geometric mean)... not the arithmetic mean," and total cost/ICER calculations are built from sums requiring the arithmetic mean — hence the need for Duan's smearing estimator if working on the log scale.

### Q129 [Medium] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** What practical advantage does a gamma GLM with a log link have over a log-OLS model for cost data?
- A) It requires fewer observations to fit
- B) It models the mean of cost directly via the log link, exponentiated back by `type = "response"`, so no retransformation step or smearing correction is needed
- C) It eliminates the need to check for zero-cost patients
- D) It assumes constant variance just like OLS
**Answer:** B
**Explanation:** The chapter states the gamma GLM "models the mean of cost directly... so there is no retransformation step and no smearing correction needed," unlike log-OLS.

### Q130 [Easy] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** In a two-part (hurdle-style) model for zero-inflated costs, how is expected cost decomposed?
- A) E(cost) = mean(cost) × proportion of zeros
- B) E(cost | x) = P(cost > 0 | x) × E(cost | cost > 0, x)
- C) E(cost | x) = P(cost = 0 | x) + E(cost | cost > 0, x)
- D) E(cost | x) = median(cost) / variance(cost)
**Answer:** B
**Explanation:** The chapter states explicitly that two-part models "decompose expected cost cleanly as E(cost | x) = P(cost > 0 | x) × E(cost | cost > 0, x)."

### Q131 [Easy] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** What is the key distinction between prevalence-based and incidence-based cost-of-illness (COI) studies?
- A) Prevalence-based sums all costs in a defined period across everyone with the condition; incidence-based follows newly diagnosed patients over their full episode
- B) Prevalence-based only applies to LMICs; incidence-based only applies to high-income countries
- C) They are two names for the same methodology
- D) Incidence-based studies never use micro-costing
**Answer:** A
**Explanation:** The chapter defines prevalence-based COI as summing costs in a calendar period regardless of diagnosis timing, versus incidence-based COI following a cohort of newly diagnosed patients through their full episode.

### Q132 [Hard] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** Why is a naive mean of observed costs biased in a longitudinal study with censored (incomplete follow-up) patients?
- A) Because R's `mean()` function ignores NA values by default
- B) Because costs accrue over time, so a patient censored early has had less opportunity to accumulate cost than one followed to completion, making simple averaging conflate "cheap" with "short follow-up"
- C) Because censored patients always have zero cost
- D) Because censoring only affects QALYs, not costs
**Answer:** B
**Explanation:** The chapter explains that "simply summing observed costs without any time adjustment conflates 'this patient was cheap' with 'this patient was only followed for three weeks.'"

### Q133 [Hard] [Image]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** IMAGE PLACEHOLDER: a histogram of simulated TB programme cost data (n=1,200) as shown in the chapter's figure, showing a visible spike of zero-cost patients at the floor, a heavy right tail from rare catastrophic cases, and a mean well above the median. What is the primary modelling implication of this distributional signature?
- A) Ordinary least squares on raw cost is a poor default; gamma GLMs or two-part models are more appropriate
- B) The data should be discarded because it is simulated
- C) A simple t-test on raw cost is sufficient
- D) The zero-cost patients should be removed before any analysis
**Answer:** A
**Explanation:** The chapter states this is "exactly the pattern that makes 'fit OLS on raw cost' a poor default," motivating the gamma GLM and two-part model approaches of Section 9.4.

### Q134 [Medium] [Image]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** IMAGE PLACEHOLDER: the chapter's unit-cost reference table for a TB programme (item, unit cost, currency = INR, price year = 2023) as published alongside a costing analysis. Per CHEERS 2022 item 15, what must be reported alongside such a table?
- A) Only the total programme budget for the year
- B) The currency, price date, and the conversion method applied (nominal exchange rate or PPP) if costs were converted
- C) The number of patients enrolled in the trial
- D) The statistical software version used
**Answer:** B
**Explanation:** The chapter states CHEERS 2022 item 15 "requires explicit reporting of currency, price date, and the conversion method applied," directly alongside any cost table.

### Q135 [Hard] [Image]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** IMAGE PLACEHOLDER: the chapter's summary table comparing censored-cost-handling methods (naive mean, complete-case/drop censored, Lin et al.'s partitioned estimator, IPCW) by bias direction under informative follow-up. According to the table, which method is biased *upward* because it over-represents patients followed to completion?
- A) Lin et al.'s partitioned estimator
- B) Inverse-probability-of-censoring weighting (IPCW)
- C) Complete-case analysis (dropping censored patients)
- D) Naive mean of observed cost
**Answer:** C
**Explanation:** The table states complete-case analysis is "biased upward: discards exactly the shortest-followed patients, over-representing those followed to completion," unlike the naive mean (biased downward) or Lin's/IPCW (consistent under non-informative censoring).
