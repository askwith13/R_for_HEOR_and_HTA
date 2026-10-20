# Quiz Questions: Chapters 13–15

## Chapter 13: Population-Adjusted Indirect Comparisons

### Q181 [Easy] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** In the context of population-adjusted indirect comparisons, what distinguishes an "effect modifier" from a "prognostic factor"?
- A) A prognostic factor changes the relative treatment effect; an effect modifier shifts outcomes equally in both arms
- B) An effect modifier changes the relative treatment effect itself; a prognostic factor predicts outcome risk regardless of treatment, shifting both arms similarly
- C) There is no meaningful distinction; both terms describe the same statistical phenomenon
- D) A prognostic factor only matters in unanchored comparisons, while an effect modifier only matters in anchored comparisons
**Answer:** B
**Explanation:** The chapter defines a prognostic factor as one that shifts outcomes up or down similarly in both arms, while an effect modifier changes the treatment effect itself depending on the covariate's value (§13.1).

### Q182 [Medium] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** Why does imbalance in a pure prognostic factor NOT bias an anchored indirect comparison, while imbalance in an effect modifier does?
- A) Prognostic imbalance is always smaller in magnitude than effect-modifier imbalance
- B) Prognostic effects are differenced away on each side of the common comparator anchor before the two relative effects are compared, whereas effect-modifier imbalance means the two trials' relative effects estimate different quantities
- C) Prognostic factors cannot be measured in AgD trials, so they are irrelevant by definition
- D) Anchored comparisons never use any patient-level covariate information
**Answer:** B
**Explanation:** Per §13.1, within-trial contrasts cancel prognostic effects at the anchor, but effect-modifier imbalance means the two trials are not estimating the same relative-effect quantity, so the indirect comparison is biased.

### Q183 [Medium] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** How does MAIC's method-of-moments weighting mechanism determine the odds-weight $w_i = exp(z_i^T alpha)$ for each IPD patient?
- A) $\alpha$ is fit by maximum likelihood on the AgD trial's individual patient outcomes
- B) $\alpha$ is chosen so the weighted IPD sample's covariate means exactly equal the AgD trial's reported means
- C) $\alpha$ is set equal to the AgD trial's published hazard ratio
- D) $\alpha$ is estimated by a Cox model fit separately in each trial
**Answer:** B
**Explanation:** Per §13.2, $\alpha$ solves a convex method-of-moments problem so that the weighted IPD covariate means match the AgD trial's reported moments — no AgD individual patient data or outcomes are ever used.

### Q184 [Easy] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** What does the effective sample size (ESS) formula $\mathrm{ESS} = (\sum_i w_i)^2 / \sum_i w_i^2$ tell an analyst?
- A) The number of covariates successfully matched between trials
- B) How many unweighted patients would give the same amount of statistical information as the weighted sample
- C) The number of patients excluded from the IPD trial after matching
- D) The statistical power of the weighted Cox model
**Answer:** B
**Explanation:** §13.2 defines ESS as answering "how many unweighted patients would give this much statistical information," and a large drop from the original N signals that a few extreme weights dominate the estimate.

### Q185 [Medium] [Image]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** IMAGE PLACEHOLDER: a love plot showing absolute standardized mean differences (SMDs) between the IPD trial and the AgD trial's reported target, before (red) and after (green) MAIC odds-weighting, as in Figure @fig-ch13-maic-love-plot of §13.2. Based on the chapter's description of this figure, what should the SMD for every *matched* covariate equal after weighting?
- A) Approximately 0.5, representing moderate residual imbalance
- B) Exactly zero, by construction of the method-of-moments calibration
- C) A value depending on the covariate's correlation with the outcome
- D) It cannot be determined without knowing the ESS
**Answer:** B
**Explanation:** The chapter states that MAIC drives every *matched* covariate's SMD to exactly zero by construction; the real diagnostic concern is whether any *unmatched* effect modifier remains imbalanced.

### Q186 [Medium] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** An IPD trial starts with N = 400 patients. After MAIC weighting on two effect modifiers, the ESS is calculated as 120. What does this specific result imply, per the chapter's worked example?
- A) The MAIC weighting failed and must be re-estimated
- B) Roughly 70% of the effective statistical information was lost, likely because a handful of extreme weights dominate the result, widening the confidence interval beyond what N=400 would suggest
- C) The AgD trial's reported means were incorrect
- D) The weighted Cox model cannot be fit with this ESS
**Answer:** B
**Explanation:** §13.2's worked example explicitly states that ESS=120 from N=400 means roughly 70% of effective information was thrown away, flagging that a small number of extreme weights are carrying the estimate and that the CI will be wider than the nominal N suggests.

### Q187 [Easy] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** How does MAIC extend its reweighting logic to time-to-event (survival) outcomes?
- A) It requires an entirely new estimation framework distinct from the odds-weight calculation
- B) The same odds-weights $w_i$ are used as case weights in a weighted Kaplan–Meier curve and a weighted Cox model
- C) It converts survival times into binary outcomes before weighting
- D) It discards all weighting and refits an unweighted Cox model on the matched subset only
**Answer:** B
**Explanation:** Per §13.2, "MAIC's reweighting logic extends directly to survival outcomes by using the odds-weights $w_i$ as case weights in a weighted Kaplan–Meier curve and a weighted Cox model — no new estimation machinery is needed."

### Q188 [Hard] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** Why does the chapter recommend robust (sandwich-type) standard errors, rather than the naive weighted-Cox standard errors, when reporting a MAIC-weighted Cox model?
- A) Robust SEs are always smaller and make the result look more precise
- B) The weights themselves are estimated quantities with their own uncertainty, and ordinary Cox variance formulas do not account for that extra uncertainty, which would make the reported CI artificially narrow
- C) Robust SEs are required whenever the outcome is binary rather than time-to-event
- D) The `coxph()` function cannot compute naive standard errors when weights are supplied
**Answer:** B
**Explanation:** §13.2 explains that because the MAIC weights were themselves estimated in the matching step, naive Cox SEs ignore that added uncertainty, making the CI look falsely precise; `cluster()` or a full bootstrap over the weighting-plus-outcome pipeline are the standard fixes.

### Q189 [Easy] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** What is the fundamental mechanistic difference between MAIC and STC in how they address effect-modifier imbalance between an IPD trial and an AgD trial?
- A) MAIC reweights IPD patients to match the AgD trial's covariate moments; STC fits an outcome regression on the IPD trial and predicts the outcome at the AgD trial's reported covariate means
- B) MAIC and STC are mathematically identical procedures with different names
- C) MAIC requires AgD patient-level data; STC does not
- D) STC always requires fewer covariates than MAIC
**Answer:** A
**Explanation:** Per §13.3, "Where MAIC asks 'how do I reweight my patients to look like theirs?', STC asks 'what does my outcome model say would happen to a population with their average characteristics?'"

### Q190 [Hard] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** The chapter's worked simulation shows a treatment with a true, constant log-odds effect of 0.7 (true OR ≈ 2.0) across mild and severe-disease subgroups, with no real effect modification. Fitting a logistic regression recovers a conditional OR of about 1.98, but averaging predicted probabilities across the population and converting to an odds ratio gives a marginal OR of about 1.82. What does this gap illustrate?
- A) The logistic model was misspecified and needs a treatment-by-severity interaction term
- B) Non-collapsibility: conditional and marginal effects differ on the odds-ratio/hazard-ratio scale even when the model is perfectly specified, because odds ratios do not average the way risk differences do
- C) A coding error in the simulation that would disappear with a larger sample size
- D) Evidence that severity is a genuine effect modifier that must be included in the matching set
**Answer:** B
**Explanation:** §13.3 explicitly uses this simulation to demonstrate non-collapsibility: "Nothing is wrong with the model; odds ratios themselves simply don't average the way risk differences do" — this is why STC must simulate across the full covariate distribution rather than plug in means.

### Q191 [Medium] [Image]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** IMAGE PLACEHOLDER: a histogram of MAIC odds-weights for a 400-patient IPD trial matched on baseline ECOG status and prior-therapy count, as described in the §13.2 worked example, showing roughly 15 patients at the extreme ends of the covariate distribution receiving weights 8–12 times the mean weight while most patients are weighted near zero. What statistical consequence does this weight distribution most directly produce?
- A) A reduction in bias with no effect on precision
- B) An ESS substantially lower than the raw IPD sample size (illustratively ≈120 out of 400), because a small number of extreme weights dominate the weighted estimate
- C) An automatic violation of the proportional hazards assumption
- D) A requirement to switch from MAIC to ML-NMR
**Answer:** B
**Explanation:** The chapter's heor-practice box uses exactly this extreme-weight pattern to produce the illustrative ESS of 120 from N=400, explicitly linking a small number of highly weighted patients to large information loss (§13.2).

### Q192 [Medium] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** Why can't MAIC or STC be directly extended when a network contains three or more treatments with a mix of IPD and AgD-only trials?
- A) Both methods already handle arbitrary network sizes without modification
- B) Both operate structurally on exactly two trials (one IPD, one AgD) connected by a single comparison, so extending them to a network would require a separate MAIC/STC per AgD trial, losing internal consistency and a single coherent ranking
- C) AgD trials cannot be included in any network meta-analysis
- D) IPD trials are incompatible with Bayesian network meta-analysis software
**Answer:** B
**Explanation:** §13.4 states that MAIC and STC "share a structural limitation: both operate on exactly two trials... connected by a single comparison," and running separate pairwise analyses would throw away network internal consistency — the gap ML-NMR closes.

### Q193 [Hard] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** What is the role of `multinma::add_integration()` and Sobol' sequences in ML-NMR?
- A) They replace the need for any IPD trials in the network
- B) They generate structured (not purely random) sample points via a Gaussian copula from each AgD trial's reported covariate means, SDs, and correlations, so the individual-level model's predictions can be numerically integrated over that trial's covariate distribution rather than evaluated at a single mean
- C) They compute the R-hat convergence diagnostic for the ML-NMR model
- D) They convert AgD trials into IPD trials automatically
- **Answer:** B
**Explanation:** §13.4 explains that `add_integration()` builds Quasi-Monte Carlo integration points via a Gaussian copula and Sobol' sequences from each AgD study's covariate distribution, enabling numerical integration rather than STC's single-mean plug-in.

### Q194 [Medium] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** According to NICE DSU TSD 18, what is the stated rough method preference ordering among MAIC, STC, and ML-NMR, data permitting?
- A) MAIC > STC > ML-NMR, because MAIC is simplest to implement
- B) STC > MAIC > ML-NMR
- C) ML-NMR > STC > MAIC, because ML-NMR preserves network internal consistency and uses the full covariate distribution, while MAIC discards information via reweighting
- D) All three methods are considered equally preferable by TSD 18
**Answer:** C
**Explanation:** §13.5's agency-note states TSD 18's ordering is "roughly, ML-NMR > STC > MAIC," explicitly warning against choosing MAIC merely because it is simplest to implement.

### Q195 [Hard] [Image]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** IMAGE PLACEHOLDER: a schematic diagram/table comparing MAIC, STC, and ML-NMR across three dimensions — data requirement, key assumption, and typical use case — as summarized in the comparison table of §13.4. Which statement correctly characterizes the key assumption distinguishing MAIC from STC in this comparison?
- A) MAIC's validity rests on the weighting/matching model being correctly specified; STC's validity rests on the outcome regression model being correctly specified
- B) Both methods share an identical key assumption about outcome functional form
- C) MAIC assumes no effect modifiers exist; STC assumes all covariates are prognostic
- D) STC requires AgD trial covariate correlations; MAIC does not use AgD data at all
**Answer:** A
**Explanation:** The method-comparison table (tab-ch13-method-comparison) lists MAIC's key assumption as correct specification of the weighting/matching model including all relevant effect modifiers, and STC's as correct specification of the outcome regression model, including functional form and treatment-by-covariate interactions.

## Chapter 14: Bayesian Methods for HEOR

### Q196 [Easy] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** In the Bayesian framework introduced in §14.1, how does the posterior $p(\theta|y)$ relate to the prior $\pi(\theta)$ and likelihood $L(\theta|y)$?
- A) Posterior = Prior minus Likelihood
- B) Posterior is proportional to Likelihood times Prior
- C) Posterior equals the Prior whenever the sample size is large
- D) Posterior and Likelihood are mathematically identical concepts
**Answer:** B
**Explanation:** §14.1 states the core relationship analysts use day to day: "posterior ∝ likelihood × prior," with the denominator of Bayes' theorem simply rescaling the product to integrate to one.

### Q197 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** How does a Bayesian 95% credible interval differ in interpretation from a frequentist 95% confidence interval, per §14.1?
- A) They are identical in interpretation; only the computation method differs
- B) A credible interval is a direct probability statement that, given the data and prior, there is a 95% probability θ lies in the interval; a confidence interval is a statement about the long-run behavior of the estimation procedure
- C) A confidence interval is always narrower than a credible interval
- D) Credible intervals cannot be computed for continuous parameters
**Answer:** B
**Explanation:** The chapter contrasts the two directly: the frequentist CI describes repeated-sampling long-run coverage of a procedure, while the Bayesian credible interval is a direct probability statement about θ itself given the observed data and prior.

### Q198 [Easy] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** The chapter's TB treatment-success example uses an informative prior of Beta(150, 42). What is the source and interpretation of this prior, per §14.2?
- A) It is an arbitrary default with no clinical basis, chosen purely for mathematical convenience
- B) It encodes findings from a prior national TB survey (78% success), treated as 192 "pseudo-observations" carried forward rather than discarded
- C) It represents a completely flat, non-informative belief about treatment success
- D) It was derived directly from the new cohort's own observed data
**Answer:** B
**Explanation:** §14.2 explains that Beta(150,42) comes from a prior national TB survey finding 78% success, and using it as a prior "is not cheating — it is using the discipline's accumulated evidence," representing 192 pseudo-observations.

### Q199 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** A weakly informative Normal(0, 2.5) prior is placed on a log hazard ratio. What does this prior actually express, per §14.2?
- A) Strong certainty that the hazard ratio equals exactly 1
- B) That hazard ratios roughly between 0.007 and 150 are conceivable, ruling out numerically absurd values without favoring any particular plausible value
- C) Complete prior ignorance equivalent to a flat uniform prior on an unbounded scale
- D) That the hazard ratio must lie strictly between 0.5 and 2.0
**Answer:** B
**Explanation:** §14.2 states this prior "says hazard ratios somewhere between roughly 0.007 and 150 are conceivable, but a hazard ratio of a trillion is not," keeping the sampler well-behaved without pulling toward a specific value.

### Q200 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** Using the Beta-Binomial conjugate update in §14.2 with prior Beta(150, 42), and a new cohort of n=40 patients with y=34 successes, what is the resulting posterior distribution?
- A) Beta(34, 6)
- B) Beta(184, 48)
- C) Beta(150, 82)
- D) Beta(40, 34)
**Answer:** B
**Explanation:** The conjugate Beta-Binomial update gives $\alpha_\text{post} = \alpha_\text{prior} + y = 150+34=184$ and $\beta_\text{post} = \beta_\text{prior} + (n-y) = 42+6=48$, exactly as computed in §14.2's worked example.

### Q201 [Hard] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** Why does the chapter caution against reflexively choosing a "flat" or improper prior just to appear neutral, using the example of a Uniform(0,1000) prior on an odds ratio?
- A) Flat priors are computationally impossible to implement in Stan or JAGS
- B) A prior that is flat on one scale can be highly informative — and in a distorting way — on a transformed scale; a Uniform(0,1000) prior on an OR puts almost all its mass above an OR of 10, which is rarely a neutral starting point
- C) Flat priors always produce a biased posterior mean regardless of sample size
- D) Flat priors are only appropriate for binary outcomes, never continuous ones
**Answer:** B
**Explanation:** §14.2's pitfall box makes exactly this point: a seemingly neutral flat prior on an odds-ratio scale concentrates almost all its mass above OR=10, which is a strong and distorting assumption in practice.

### Q202 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** How does Hamiltonian Monte Carlo (HMC) improve on basic Metropolis-Hastings sampling, per §14.3?
- A) HMC eliminates the need for a prior distribution entirely
- B) HMC uses the gradient of the negative log-posterior to steer proposals toward high-density regions (like a particle rolling across an energy surface), enabling big, informed steps even in high dimensions, rather than wandering via small random proposals
- C) HMC only works for discrete parameters, unlike Metropolis-Hastings
- D) HMC always converges in exactly one iteration
**Answer:** B
**Explanation:** §14.3 describes HMC as treating the negative log-posterior as an energy surface and using its gradient to steer proposals, producing "big, informed steps even in high dimensions" versus Metropolis-Hastings' slow random perturbations.

### Q203 [Easy] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** What R-hat (Gelman-Rubin statistic) threshold does the chapter describe as the "traditional acceptable" value, versus the more conservative threshold increasingly expected by methodologically careful reviewers?
- A) Traditional: R-hat < 2.0; conservative: R-hat < 1.5
- B) Traditional: R-hat < 1.05; conservative: R-hat < 1.01
- C) Traditional: R-hat < 1.01; conservative: R-hat < 1.05
- D) There is no standard threshold; it depends entirely on the model
**Answer:** B
**Explanation:** §14.4 states "R-hat < 1.05 is the traditional 'acceptable' threshold... R-hat < 1.01 is the more conservative threshold recommended by newer Stan-ecosystem guidance."

### Q204 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** R-hat and effective sample size (ESS) are reported together in MCMC diagnostics. What distinct question does each answer, per §14.4?
- A) They answer the identical question and are reported together only for redundancy
- B) R-hat asks "have my chains converged to the same place?"; ESS asks "once converged, how much information do I actually have about this parameter?"
- C) R-hat measures model fit; ESS measures prior informativeness
- D) ESS is only relevant for JAGS models, while R-hat is only relevant for Stan models
**Answer:** B
**Explanation:** The chapter states explicitly that you "can have excellent R-hat with dismal ESS if chains converge quickly to the right region but then mix very slowly within it" — a common pattern for variance components in hierarchical NMA models.

### Q205 [Hard] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** What causes "divergent transitions" in Stan's HMC/NUTS sampler when fitting a hierarchical model with a funnel-shaped posterior (Neal's funnel), and what is the standard fix?
- A) Divergences are caused by too few MCMC chains; the fix is to run more chains
- B) The step size that works in the funnel's wide region is too large for its narrow neck, causing the sampler to "crash into the walls"; the standard fix is a non-centered parameterisation that expresses individual deviations as independent unit-scaled quantities multiplied by the variance parameter afterward
- C) Divergences only occur with vague priors and are fixed by switching to JAGS
- D) Divergences indicate the likelihood function was misspecified and cannot be fixed by reparameterisation
**Answer:** B
**Explanation:** §14.4's difficult-terminology box on Neal's funnel explains that a single step size cannot navigate both the funnel's wide and narrow regions, and that non-centered parameterisation "straightens the funnel out into geometry the sampler can explore efficiently."

### Q206 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** What is the purpose of a posterior predictive check (PPC), as distinct from a convergence diagnostic like R-hat?
- A) PPCs check whether the sampler worked; convergence diagnostics check whether the model is a good description of the data
- B) PPCs simulate new data from the fitted model's posterior and compare it to observed data to assess whether the model is a reasonable description of the data-generating process; convergence diagnostics only check whether the sampler worked
- C) PPCs and convergence diagnostics are interchangeable and test the same thing
- D) PPCs are only applicable to Bayesian network meta-analysis models, not simpler Bayesian regressions
**Answer:** B
**Explanation:** §14.4 states plainly: "Convergence diagnostics tell you whether your sampler worked. They say nothing about whether your model is any good. For that you need posterior predictive checks."

### Q207 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** Per §14.5–14.6, why can a Bayesian posterior sample be used directly as a PSA sample, with "no extra distribution-fitting step in between"?
- A) Because posterior draws are always normally distributed by the Central Limit Theorem
- B) Because each MCMC draw is already a complete, internally consistent joint sample across every parameter, preserving correlations that a separately-fitted distribution (e.g., refitting a normal to the posterior mean and SD) would discard
- C) Because PSA requires independent parameter draws, which posterior samples automatically provide
- D) Because Bayesian models never require probabilistic sensitivity analysis
**Answer:** B
**Explanation:** The chapter emphasizes that re-fitting a distribution to posterior summary statistics "throws away exactly the correlation structure that made the Bayesian synthesis worth doing" (§14.5), so the raw posterior draws are used as the PSA sample directly.

### Q208 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** In a SHELF (Sheffield Elicitation Framework) exercise, what is the key distinction between "the facilitator" and "the experts," per §14.7?
- A) The facilitator holds the relevant clinical/domain knowledge, while experts run the elicitation session
- B) The facilitator is a trained elicitation specialist with no personal stake in the parameter's value who runs the session without offering their own opinion; the experts are the substantive content specialists who hold domain knowledge but typically lack training in thinking probabilistically
- C) There is no meaningful distinction; both roles are performed by the same person in SHELF
- D) The facilitator always outranks the experts and makes the final numeric judgment alone
**Answer:** B
**Explanation:** §14.7 explicitly separates these roles: the facilitator counteracts cognitive biases and never offers their own opinion of the "right" answer, while experts hold the clinical knowledge but need help translating intuition into probabilistic quantiles.

### Q209 [Hard] [Image]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** IMAGE PLACEHOLDER: a `bayesplot::mcmc_trace()` plot showing 4 overlapping chains for parameters theta on the natural and logit scale, described in §14.4 as a "fat hairy caterpillar." What visual pattern indicates a healthy, well-mixed chain in this type of plot?
- A) Four bands that are clearly separated from one another with no overlap
- B) Four overlapping bands with no trend, no chain visibly separated from the others, and no long flat stretches where the sampler got stuck
- C) A single smooth, declining line with no fluctuation
- D) Bands that narrow progressively toward zero width over time
**Answer:** B
**Explanation:** The chapter describes a healthy trace plot as looking like "a 'fat hairy caterpillar' — four overlapping bands with no trend, no chain visibly separated from the others, and no long flat stretches where the sampler got stuck" (§14.4).

### Q210 [Medium] [Image]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** IMAGE PLACEHOLDER: a `bayesplot::ppc_dens_overlay()` plot comparing an observed outcome density to 50 posterior-predictive replicate densities, as in Figure @fig-ch14-ppc-dens-overlay of §14.4. What pattern in this figure would indicate the model fits well?
- A) Replicated curves showing a completely different mode than the observed data
- B) A tight bundle of replicated curves hugging the observed curve
- C) Replicated curves spread uniformly across the entire possible outcome range
- D) Exactly one replicated curve matching the observed data perfectly while all others diverge
**Answer:** B
**Explanation:** §14.4 states: "A model that fits well produces a tight bundle of replicated curves hugging the observed curve," while systematic misfit (wrong dispersion, skew, or mode) shows up as visibly diverging replicate curves.

### Q211 [Hard] [Image]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** IMAGE PLACEHOLDER: a `SHELF::plotfit()` figure overlaying fitted beta, normal, skew-normal, gamma, and log-normal distributions against three elicited quantiles (25th/50th/75th percentiles = 0.30/0.45/0.60) for a response-rate parameter, as in Figure @fig-ch14-shelf of §14.7. The normal/skew-normal families have the lowest least-squares (ssq) score, yet the chapter says the beta fit should be used instead. Why?
- A) The beta distribution always has the lowest ssq score mathematically
- B) The normal/skew-normal fits can assign positive density outside [0,1], which is nonsensical for a probability parameter; the beta fit respects the bounded support of the parameter being elicited despite its slightly higher ssq
- C) SHELF's software does not actually support fitting normal distributions
- D) The response rate parameter is not bounded, so any family is equally valid
**Answer:** B
**Explanation:** The figure caption explicitly states that although normal/skew-normal fits score lower ssq, they can assign density outside [0,1]; "the beta fit... is the one that should feed the prior, precisely because it respects the support of the parameter being elicited" (§14.7).

### Q212 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** Why does the chapter caution against thinning or subsampling a posterior sample (e.g., taking every 10th draw) before passing it into a decision model, per §14.5?
- A) Thinning is computationally impossible in R
- B) Thinning is usually unnecessary and can quietly reduce the effective precision of PSA results, unless autocorrelation diagnostics specifically indicate thinning is needed for storage reasons
- C) Thinning always introduces bias into the posterior mean
- D) Thinning is required by NICE DSU TSD 18 for every Bayesian PSA
**Answer:** B
**Explanation:** §14.5's pitfall box states thinning "is usually unnecessary and can quietly reduce the effective precision of your PSA results," and recommends passing the full post-warm-up sample through unless thinning is driven by genuine storage or autocorrelation concerns.

## Chapter 15: Real-World Evidence (RWE) and Causal Inference

### Q213 [Easy] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** What two-part test does the FDA's 2023 RWD guidance use to assess whether a real-world data source is fit for a regulatory decision, per §15.1?
- A) Cost and availability
- B) Relevance (right population, exposure, outcome, follow-up) and reliability (accurate, complete, traceable, with transparent provenance)
- C) Sample size and statistical power
- D) Randomization and blinding
**Answer:** B
**Explanation:** §15.1 states the FDA framework asks whether data is "relevant to the clinical question... and... reliable (accurate, complete, traceable, with transparent provenance)" — the EMA's DARWIN EU asks the same two questions in different words.

### Q214 [Medium] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** In the target trial emulation (TTE) example in §15.2, why is `time_zero` set to `regimen_start` rather than `diagnosis_dt`?
- A) Because diagnosis dates are never recorded in programme registers
- B) Because setting time zero correctly, so eligibility, exposure assignment, and follow-up all begin simultaneously, avoids immortal time bias — the opposite choice would inflate apparent drug benefit by crediting treatment-free follow-up time to the treated group
- C) Because regimen_start is always earlier than diagnosis_dt
- D) Because TTE requires excluding all patients with any lead-in time
**Answer:** B
**Explanation:** The chapter's code comment states explicitly "time_zero = regimen_start # NOT diagnosis_dt -- avoids immortal time bias," and the lead_in_days column is described as the audit diagnostic for exactly this risk (§15.2).

### Q215 [Easy] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** Which observational study design is described in §15.2 as "efficient for rare outcomes" but "acutely sensitive to how controls are selected"?
- A) Cohort design
- B) Case-control design
- C) Target trial emulation
- D) Regression discontinuity
**Answer:** B
**Explanation:** §15.2 states that case-control designs are "efficient for rare outcomes... but acutely sensitive to how controls are selected — control selection that does not mirror the case-generating mechanism produces selection bias that no amount of post-hoc adjustment repairs."

### Q216 [Medium] [Image]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** IMAGE PLACEHOLDER: a DAG with nodes regimen, success, hiv, nutrition, site_capacity, and urban as in §15.3, showing arrows success ← regimen, hiv, nutrition, site_capacity; regimen ← hiv, site_capacity; nutrition ← regimen; site_capacity ← urban. Running `dagitty::adjustmentSets()` on this graph with exposure=regimen and outcome=success returns which minimal sufficient adjustment set, and why is `nutrition` excluded?
- A) {hiv, nutrition, site_capacity}; nutrition is included because it predicts the outcome
- B) {hiv, site_capacity}; nutrition is excluded because it is a mediator (caused by regimen) on the causal pathway, and adjusting for it would block part of the regimen's true causal effect
- C) {urban}; urban is the only true confounder in this DAG
- D) The empty set {}; no adjustment is needed because this is a randomized comparison
**Answer:** B
**Explanation:** §15.3 states that running `adjustmentSets()` on this exact DAG "returns {hiv, site_capacity} as the minimal sufficient set... nutrition is correctly excluded because it is a mediator, not a confounder."

### Q217 [Easy] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** How is the propensity score $e(x)$ formally defined in §15.4, and what did Rosenbaum and Rubin establish about it?
- A) $e(x) = P(Y=1|X=x)$; it is sufficient to predict the outcome without any covariates
- B) $e(x) = P(T=1|X=x)$; conditioning on it is sufficient to balance observed confounders between treated and untreated groups, provided no unmeasured confounding
- C) $e(x)$ is the expected cost of treatment given covariates x
- D) $e(x)$ is only defined for randomized trials, not observational data
**Answer:** B
**Explanation:** §15.4 defines the propensity score as $e(x) = P(T=1|X=x)$ and states Rosenbaum and Rubin's insight that conditioning on it, rather than the full covariate vector, is sufficient to balance observed confounders given the no-unmeasured-confounding assumption.

### Q218 [Hard] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** In the §15.4 toy IPTW example (6 patients, treated outcomes Y=10,8,12 with PS=0.5,0.4,0.6 and control outcomes Y=4,6,2 with the same PS values), what is the IPTW estimate of the average treatment effect (ATE)?
- A) 0.0 weeks (no difference)
- B) 6.167 weeks (weighted treated mean 10.000 minus weighted control mean 3.833)
- C) 10.0 weeks
- D) 20.0 weeks
**Answer:** B
**Explanation:** Summing treated contributions (20+20+20)/6 = 10.000 and control contributions (8+10+5)/6 = 3.833 gives $\hat\tau_\text{IPTW} = 10.000 - 3.833 = 6.167$ weeks, exactly as computed by hand in §15.4.

### Q219 [Medium] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** What makes an Augmented Inverse Probability Weighting (AIPW) estimator "doubly robust," per §15.5?
- A) It requires both the propensity model and the outcome model to be correctly specified simultaneously, or the estimate is invalid
- B) The estimate stays consistent if *either* the propensity model or the outcome model is correctly specified, not necessarily both — a meaningfully weaker assumption than either method alone requires
- C) It doubles the sample size by bootstrapping twice
- D) It is robust only to missing data, not to confounding
**Answer:** B
**Explanation:** §15.5 states that doubly robust estimators "combine both models so the estimate stays consistent if *either* the propensity model or the outcome model is correctly specified — not necessarily both."

### Q220 [Hard] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** Why were g-methods (g-computation, marginal structural models via IPTW, g-estimation of structural nested models) developed specifically, per §15.5?
- A) To replace propensity score matching entirely in all observational studies
- B) To handle time-varying treatment and time-varying confounding, where today's treatment affects tomorrow's confounder, which in turn affects tomorrow's treatment decision — a treatment-confounder feedback loop that standard regression adjustment cannot handle without bias
- C) To eliminate the need for a DAG before fitting any model
- D) To correct for measurement error in the outcome variable only
**Answer:** B
**Explanation:** §15.5 states g-methods "were developed by James Robins specifically to handle *time-varying treatment and time-varying confounding*... a 'treatment-confounder feedback' loop that standard regression adjustment cannot handle without introducing bias."

### Q221 [Medium] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** When using `ivreg::ivreg()` with `diagnostics = TRUE`, what conventional threshold on the first-stage F-statistic flags a "weak instrument," per §15.6?
- A) F-statistic below roughly 10
- B) F-statistic above 100
- C) F-statistic exactly equal to 1
- D) There is no numerical threshold; it is purely a qualitative judgment
**Answer:** A
**Explanation:** §15.6 states "A first-stage F-statistic below roughly 10 is the conventional (if debated) threshold for flagging a 'weak instrument,' below which 2SLS estimates become unreliable and badly biased toward the plain OLS estimate."

### Q222 [Medium] [Image]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** IMAGE PLACEHOLDER: an `rdrobust::rdplot()` scatter plot of culture conversion time against CD4 count, with a vertical line at the policy cutoff CD4=200, showing a visible downward jump in outcome just below the cutoff as in Figure @fig-ch15-rd-plot of §15.6. To what population does the estimated effect at this cutoff apply, and what check should accompany it?
- A) The effect applies to the entire CD4 range from 0 to 600 and requires no further checks
- B) The effect is local — identified only for patients near CD4=200 and should not be extrapolated to patients far from it — and should be accompanied by a manipulation/density check (e.g., via the `rddensity` package) to confirm patients could not manipulate which side of the cutoff they landed on
- C) The effect applies only to patients with CD4 exactly equal to 0
- D) No check is needed because RD designs are immune to confounding by definition
**Answer:** B
**Explanation:** §15.6's pitfall box states RD estimates are "local" and should never be extrapolated far from the cutoff, and recommends the `rddensity` manipulation check to rule out patients gaming which side of the cutoff they land on.

### Q223 [Hard] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** Why does the chapter recommend `did::att_gt()` over a naive two-way fixed effects (TWFE) regression for difference-in-differences when treatment adoption is staggered across districts, per §15.7?
- A) TWFE cannot be computed in R for panel data
- B) Naive TWFE regression implicitly compares already-treated districts against each other as pseudo-controls under staggered adoption, producing the well-documented "negative weighting" bias; `att_gt()` estimates separate group-time average treatment effects and avoids this
- C) `att_gt()` is simpler to code and produces identical results to TWFE in all cases
- D) TWFE is only invalid for continuous outcomes, not binary ones
**Answer:** B
**Explanation:** §15.7 explains that under staggered rollout, naive TWFE "implicitly compares already-treated districts against each other as pseudo-controls," a bias documented by Goodman-Bacon and others, which `att_gt()`'s group-time ATT approach avoids.

### Q224 [Medium] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** An observational comparison of two TB regimens finds an odds ratio of 2.10 (95% CI 1.40–3.20) for treatment success, with an E-value of 3.64 for the point estimate and 2.13 for the CI limit closest to the null. How should these E-values be interpreted, per §15.9?
- A) The finding is fragile; almost any unmeasured confounder could explain it away
- B) An unmeasured confounder would need a fairly strong, double-sided association (risk-ratio scale) with both exposure and outcome to fully explain away the result, even at the more conservative CI-limit value of 2.13 — a relatively robust finding compared to, e.g., an E-value near 1.5
- C) E-values of this size indicate the study must have been randomized
- D) The E-value here proves no unmeasured confounder exists
**Answer:** B
**Explanation:** §15.9 states an E-value of 1.5 signals a fragile finding while an E-value of 8 signals robustness; the chapter's own worked table flags findings with CI-limit E-values around 2 as "reasonably robust," distinct from the more sensitive culture-conversion HR with CI-limit E-value 1.53.

### Q225 [Medium] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** Per §15.8 and NICE DSU TSD 16, what determines whether RPSFTM or IPCW is the more defensible method for adjusting survival estimates in the presence of treatment switching?
- A) RPSFTM is always preferred regardless of why switching occurred
- B) IPCW is favoured when switching is driven by observed, measured time-varying covariates (since it can model and reweight on them); RPSFTM is favoured when it is not, because it is robust to time-dependent confounding by design but relies on a strong common-treatment-effect assumption
- C) Both methods are interchangeable and TSD 16 expresses no preference
- D) IPCW should always be used because it requires no assumptions about switching
**Answer:** B
**Explanation:** §15.8 states TSD 16 "recommends which to use depending on whether switching is driven by observed time-varying covariates (favour IPCW) or not (favour RPSFTM)," noting RPSFTM's robustness to unmeasured time-dependent confounding comes at the cost of a strong common-effect assumption, while IPCW requires the switch-driving covariates to actually be measured.
</content>
