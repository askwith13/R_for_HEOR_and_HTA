# Quiz: Chapters 25-27 (Q361-Q405)

## Chapter 25: Handling Uncertainty

### Q361 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** According to the ISPOR-SMDM Task Force-6 taxonomy (Briggs, Weinstein et al.), which of the following is explicitly described as *not* a form of uncertainty at all?
- A) Parameter uncertainty
- B) Structural uncertainty
- C) Heterogeneity
- D) Methodological uncertainty
**Answer:** C
**Explanation:** The chapter states heterogeneity is "the one that is *not* uncertainty at all" — it reflects real, explainable variation across patient subgroups, not imprecision in an estimate, and should be handled via subgroup analysis rather than folded into a PSA distribution.

### Q362 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the TB model's one-way sensitivity analysis (§25.2), why is the discount rate varied in *both* arms simultaneously, rather than only in the New arm?
- A) Because the discount rate is the most influential parameter overall
- B) Because it is a shared biological/convention quantity that does not plausibly differ by which regimen a patient is on
- C) Because `optim()` requires symmetric parameter changes
- D) Because the discount rate only affects the SoC arm's cost calculations
**Answer:** B
**Explanation:** The text explains that parameters like the discount rate, p(Fail→Death), and on-treatment utility are shared quantities that genuinely apply identically to both arms, whereas cure probability and drug cost are specific to the regimen being evaluated; varying a shared parameter in only one arm manufactures an artificial incremental difference.

### Q363 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the worked tornado diagram example, the discount rate's "low" bound (1.5%) produces a *higher* incremental NMB (\$8,690) than its "high" bound (5%, \$7,615). What is the correct explanation given in the text?
- A) A coding error in the discount formula that was never corrected
- B) Lower discount rates increase future QALY gains' value disproportionately relative to up-front costs, since Cured-state QALYs accrue mostly in later cycles
- C) The New regimen's cost structure is inversely related to the discount rate
- D) Discount rates only affect costs, not QALYs, in this model
**Answer:** B
**Explanation:** The text notes that a lower discount rate means future QALY gains (reached mainly in later cycles via the Cured state) are discounted less, boosting their value — which is exactly why tornado-plotting code must use `pmin()`/`pmax()` rather than assuming "low parameter value always gives the low bar end."

### Q364 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What is the primary reason net monetary benefit (NMB) is preferred over the ICER as the outcome plotted in a tornado diagram?
- A) NMB is always a larger number, making bars easier to see
- B) NMB is a ratio and therefore more interpretable
- C) The ICER is a ratio that can behave discontinuously (jumping from very large positive to very large negative) when the denominator changes sign, while NMB is a smooth linear combination
- D) NMB does not require a willingness-to-pay threshold
**Answer:** C
**Explanation:** The chapter's difficult-terminology box explains that ICERs misbehave when incremental QALY gain is near zero or changes sign, while NMB (λ×QALY − Cost) has no such discontinuity since it's a linear combination, not a ratio.

### Q365 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What distinguishes a scenario analysis from a one-way sensitivity analysis?
- A) Scenario analysis uses random draws from distributions; one-way sensitivity analysis does not
- B) Scenario analysis varies one named, coherent bundle of simultaneous parameter changes motivated by a real-world narrative, while one-way sensitivity analysis moves exactly one parameter at a time to isolate its individual influence
- C) Scenario analysis is only used for structural uncertainty
- D) One-way sensitivity analysis always produces more scenarios than scenario analysis
- **Answer:** B
**Explanation:** The text explicitly distinguishes the two: a scenario ("optimistic," "pessimistic") bundles several simultaneous changes under one narrative, whereas a one-way sensitivity analysis isolates a single parameter's influence, holding everything else at base case.

### Q366 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In R's `modifyList()`-based scenario engine, what is the key benefit of specifying only the parameters a scenario actually changes, rather than copy-pasting a whole parameter list per scenario?
- A) It runs the model faster
- B) It automatically adjusts the willingness-to-pay threshold
- C) Every scenario automatically tracks later base-case revisions for everything it did not explicitly override, avoiding stale hand-edited values
- D) It eliminates the need for a base case at all
**Answer:** C
**Explanation:** The heor-practice box warns that copy-pasting entire parameter lists risks leaving stale values when the base case is later revised; `modifyList()` with minimal overrides guarantees unchanged parameters always inherit the current base case.

### Q367 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Which probability distribution is the standard convention for PSA sampling of a single transition probability such as `p_ontx_fail`?
- A) Normal distribution
- B) Dirichlet distribution
- C) Beta distribution, because it is bounded on [0,1] and its parameters can be read directly as pseudo-counts of success/failure
- D) Uniform distribution
**Answer:** C
**Explanation:** §25.4 states that any probability or proportion parameter is bounded 0-1 and the Beta(a,b) distribution is standard precisely because it shares that bound by construction, with a and b readable as pseudo-counts.

### Q368 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Why is the Dirichlet distribution, rather than independent Beta draws per cell, required for sampling a whole row of a transition matrix in PSA?
- A) The Dirichlet distribution runs faster in R
- B) A transition-matrix row is a vector of probabilities constrained to sum to exactly 1, which independent per-cell Beta draws would violate
- C) Dirichlet distributions are easier to parameterise than Beta distributions
- D) Transition matrices cannot use Beta distributions at all
**Answer:** B
**Explanation:** The chapter explains that a transition-matrix row is not a single bounded scalar but a vector constrained to sum to 1, and the Dirichlet is the multivariate generalisation of Beta that respects this sum-to-one structural constraint.

### Q369 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Why does naively applying a normal distribution to a probability parameter in PSA constitute a dangerous pitfall?
- A) Normal distributions are computationally expensive
- B) A normal distribution can sample a negative "probability" or one exceeding 1 — syntactically valid but nonsensical once fed into a transition matrix, and may go unnoticed if the parameter's influence on the ICER is modest
- C) Normal distributions cannot be used in R's `rnorm()` function
- D) Normal distributions always produce biased mean estimates
- **Answer:** B
**Explanation:** The pitfall box warns explicitly that a normal distribution applied to a bounded probability parameter can produce out-of-range draws that are numerically valid but meaningless, and such errors can go unnoticed for a long time if the parameter's influence is modest.

### Q370 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What does a "convergence check" in PSA assess, and what signals that enough iterations have been run?
- A) Whether the transition matrix rows sum to 1; signalled by zero rounding error
- B) Monte Carlo error via a running summary statistic (e.g. mean incremental cost); signalled by the running estimate no longer changing by a practically meaningful amount as more iterations are added
- C) Whether the model crashes; signalled by no error messages
- D) The correlation between cost and QALY parameters; signalled by a correlation near zero
**Answer:** B
**Explanation:** The chapter describes tracking a running summary statistic across increasing iteration counts and looking for the diminishing-returns point where Monte Carlo error has shrunk below the precision the decision needs — illustrated by the TB model's running mean stabilising by N=1000-1500.

### Q371 [Medium] [Image]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** IMAGE PLACEHOLDER: a tornado diagram of one-way sensitivity analysis on incremental NMB for the New TB regimen vs SoC, bars sorted by swing width descending, as in §25.2 / fig-ch25-tornado. Based on the chapter's reported swing values, which parameter's bar should appear widest (at the top) of the tornado diagram?
- A) Annual discount rate
- B) New-regimen cost per cycle
- C) New-regimen cure probability p(OnTx→Cured)
- D) On-treatment utility, shared
**Answer:** C
**Explanation:** The chapter's OWSA table reports a swing of \$7,945 for cure probability, dwarfing the discount rate (\$1,076), drug cost (\$827), and utility (\$642) swings by a factor of three or more, so it occupies the top (widest) bar.

### Q372 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What is the purpose of a two-way sensitivity analysis that a pair of separate one-way analyses cannot reveal?
- A) It runs faster than two one-way analyses combined
- B) It reveals whether a joint, simultaneous combination of two pessimistic (or optimistic) parameter values flips the decision, which separate one-at-a-time analyses on each parameter cannot show
- C) It replaces the need for a tornado diagram
- D) It only works for parameters measured in dollars
**Answer:** B
**Explanation:** The text explains that two separate one-way analyses could each look reassuring individually while hiding an unfavourable joint corner of the parameter space — exactly what the two-way grid (cure probability × cost) is designed to check.

### Q373 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the cost-effectiveness acceptability curve (CEAC), what does a value near 1 at a given willingness-to-pay (WTP) threshold mean?
- A) The intervention is almost never cost-effective at that threshold
- B) The intervention is cost-effective in nearly every simulated PSA draw at that threshold
- C) The PSA has not converged
- D) The ICER equals exactly the WTP threshold
**Answer:** B
**Explanation:** The chapter defines the CEAC as, for each WTP value k, the proportion of PSA draws with positive incremental NMB at that threshold; a value near 1 means the intervention comes out favoured in nearly all draws.

### Q374 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What distinguishes the cost-effectiveness acceptability frontier (CEAF) from an ordinary CEAC when three or more strategies are compared?
- A) The CEAF is simply the CEAC of the most expensive strategy
- B) The CEAF traces, at each WTP threshold, the acceptability value of whichever strategy currently has the highest probability of being optimal — an upper envelope across all strategies' curves, which can switch strategy as the threshold moves
- C) The CEAF ignores willingness-to-pay thresholds entirely
- D) The CEAF is only valid for exactly two strategies
**Answer:** B
**Explanation:** The difficult-terminology box explains that with 3+ strategies the decision shifts to "which strategy is most likely optimal," and the CEAF is the composite upper envelope of each strategy's own CEAC, computed by BCEA's `multi.ce()`.

### Q375 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the threshold analysis worked example (§25.6), what quantity is being solved for, and using what approach?
- A) The exact willingness-to-pay threshold at which two different models agree, found via grid search
- B) The maximum total discounted cost ("breakeven price") the new regimen could have and still be cost-effective at a stated WTP, solved algebraically by rearranging the ICER formula
- C) The number of PSA iterations needed for convergence, found via simulation
- D) The optimal number of health states in the Markov model, found via AIC
**Answer:** B
**Explanation:** The chapter rearranges ICER = WTP into cost_new = cost_comp + WTP × (qaly_new − qaly_comp), directly extending Chapter 24's value-based-pricing relationship, to solve algebraically for the breakeven cost (\$8,455.34 in the worked example).

### Q376 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Why does the chapter caution against treating a threshold analysis result as a fixed, settled truth?
- A) Threshold analyses are always wrong by construction
- B) The breakeven number holds every other parameter at its base-case value, so it inherits all the same base-case uncertainty that PSA quantifies — it should be reported alongside a PSA, not as a replacement for one
- C) Threshold analysis cannot be computed in R
- D) WTP thresholds change every year automatically
**Answer:** B
**Explanation:** The pitfall box explains that the breakeven number will itself shift if the comparator's own cost or QALY estimate moves, so threshold analysis answers "breakeven at the point-estimate base case" while PSA/CEAC answers how confident to be once uncertainty is accounted for.

### Q377 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the structural uncertainty worked example, collapsing the 4-state TB model into a 3-state model (removing the explicit Fail state) changed the incremental NMB from \$8,044.05 to \$5,357.89. What does the chapter say this demonstrates?
- A) The 3-state structure is simply wrong and should never be reported
- B) The direction of the conclusion (New preferred) is robust across both structures, but the magnitude is not — the simpler structure understates New's advantage because it removes the costly, low-utility Fail state that New's lower failure probability most benefits from avoiding
- C) Structural uncertainty is identical to parameter uncertainty
- D) Model averaging is mandatory whenever two structures disagree
**Answer:** B
**Explanation:** The text states that under both structures New is cheaper and more effective (robust direction), but the magnitude is not robust because collapsing Fail removes the costly/low-utility state from the ledger for both arms, understating the advantage New gains from its lower failure rate.

### Q378 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Why does model averaging combine NMB values across structures rather than ICER values, per §25.7?
- A) ICERs cannot be computed for multiple structures
- B) NMB is a linear combination of cost and effect and therefore behaves additively under weighted combination, whereas an ICER is a ratio of two uncertain quantities and ratios do not average sensibly
- C) NMB values are always positive, making averaging easier
- D) ICERs require a willingness-to-pay threshold but NMB does not
**Answer:** B
**Explanation:** The chapter explicitly states that NMB is a single linear combination of cost and effect, so a weighted sum of NMBs is itself a meaningful NMB, whereas an ICER's ratio nature makes weighted averaging not meaningful — this is why the worked example averages NMB, not ICER.

### Q379 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Per Bojke, Claxton, Sculpher and Palmer (2009), cited in §25.7, under what condition should candidate model structures NOT be combined via model averaging?
- A) When both structures use the same discount rate
- B) When the structures do not share comparators, the time horizon, the outcome definition, and the discount rate — e.g. one uses a 10-year horizon and QALYs while another uses a lifetime horizon and life-years
- C) When fewer than three structures are being compared
- D) When expert elicitation was not used to derive the weights
**Answer:** B
**Explanation:** The pitfall box states that model averaging only makes sense when structures answer the same decision question with genuinely comparable outputs; mismatched horizons or outcome definitions make a weighted average a blend of two different questions, not a defensible estimate.

### Q380 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the §25.8 patient-level trial bootstrap, why must the resampling draw whole *rows* (patient cost-and-QALY pairs together) rather than resampling the cost column and QALY column independently?
- A) Resampling rows is computationally faster in R
- B) Independent column resampling breaks the within-patient correlation between cost and QALY, which the pitfall demonstrates inflated the bootstrap NMB standard deviation by roughly 17% and produced an artificially wider, wrong sampling distribution
- C) R's `sample()` function cannot resample two columns at once
- D) Row-wise resampling is only needed when sample sizes exceed 1,000
**Answer:** B
**Explanation:** The pitfall explicitly quantifies the consequence: resampling columns independently rather than row-wise inflated the bootstrap NMB standard deviation from \$530.72 to \$619.18 (~17%) and widened the 95% interval, because it destroys genuine within-patient cost-QALY correlation.

### Q381 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What is the fundamental difference between the non-parametric bootstrap (§25.8) and the parametric PSA approach used earlier in the chapter?
- A) The bootstrap requires fewer than 100 iterations; PSA requires thousands
- B) PSA assumes a distributional form (Beta, Gamma, Normal) fit to parameters; the non-parametric bootstrap makes no such assumption and instead resamples the actual observed trial data with replacement
- C) The bootstrap can only be applied to cost data, never QALYs
- D) PSA is used only for structural uncertainty, the bootstrap only for parameter uncertainty
**Answer:** B
**Explanation:** The difficult-terminology box explains that parametric methods (like PSA) assume a distributional form and estimate its parameters, while the non-parametric bootstrap treats the observed sample as a stand-in for the population and estimates a sampling distribution purely by resampling.

### Q382 [Easy] [Image]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** IMAGE PLACEHOLDER: a cost-effectiveness plane scatter plot of 2,000 PSA draws (incremental QALY on x-axis, incremental cost on y-axis) with a dotted willingness-to-pay line through the origin, as in §25.5 / fig-ch25-ce-plane. What does a PSA draw falling *below* the dotted WTP line on this plane represent?
- A) A draw where the new strategy is dominated
- B) A draw where the new strategy is cost-effective at that WTP threshold (positive incremental NMB)
- C) A draw with zero incremental QALYs
- D) A draw that should be excluded as an outlier
**Answer:** B
**Explanation:** The WTP line through the origin divides the plane into "cost-effective" (below the line, where cost is less than WTP times QALY gain) and "not cost-effective" (above it) regions for every draw simultaneously.

### Q383 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What is the standard distribution choice for cost parameters in PSA, and why?
- A) Beta, because costs are bounded between 0 and 1
- B) Normal, because costs are symmetric around their mean
- C) Gamma or lognormal, because costs can never be negative and are typically right-skewed with a long tail of high-cost patients
- D) Uniform, because the plausible cost range is usually unknown
**Answer:** C
**Explanation:** §25.4 states costs can never be negative and are empirically right-skewed, so Gamma and lognormal — both non-negative, right-skewed distributions — are the standard choices, with Gamma fully specified via method-of-moments from a mean and SE.

---

## Chapter 26: Value of Information Analysis

### Q384 [Easy] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What does the Expected Value of Perfect Information (EVPI) represent, per the "two crystal balls" analogy in §26.1?
- A) The cost of running a specific future clinical trial
- B) The dollar value of upgrading from the current PSA's distribution of plausible values to certain knowledge of every parameter's true value before deciding
- C) The probability that the current decision is correct
- D) The variance of the incremental NMB distribution
**Answer:** B
**Explanation:** The difficult-terminology box frames EVPI as the expected gain, averaged over every possible true parameter combination, from always getting to make the fully-informed choice instead of committing to one fixed choice today — "a ceiling, not a forecast."

### Q385 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** Which formula correctly represents EVPI as given in §26.1?
- A) EVPI = E_θ[max_d NB(d,θ)] − max_d E_θ[NB(d,θ)]
- B) EVPI = max_d NB(d,θ) − E_θ[NB(d,θ)]
- C) EVPI = Var(NB) / n
- D) EVPI = E_θ[NB(d,θ)] × P(d is optimal)
**Answer:** A
**Explanation:** The chapter gives EVPI as the expected net benefit of an oracle who picks the best strategy for each draw, minus the net benefit of committing to the single best strategy in expectation — exactly E_θ[max_d NB(d,θ)] − max_d E_θ[NB(d,θ)], which is always ≥ 0.

### Q386 [Easy] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** In the worked six-draw illustrative EVPI example (§26.1), what was the computed EVPI per patient at WTP = \$50,000?
- A) \$0 (no value to further information)
- B) \$8,044.05 (equal to the base-case incremental NMB)
- C) \$858.33
- D) \$299,325
**Answer:** C
**Explanation:** Averaging the "best for this draw" NMB column gives \$300,183.33, versus the fixed-choice value of \$299,325 (always choosing New); the difference, EVPI, is \$858.33 per patient.

### Q387 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** Why can EVPI be computed directly from existing PSA draws with "no new simulation at all," according to §26.1-26.2?
- A) EVPI only requires knowing the mean of the PSA distribution, not individual draws
- B) EVPI only needs the per-iteration cost and QALY values already produced by the PSA, reused to form NMB for each strategy and compared draw-by-draw
- C) EVPI is a fixed theoretical constant independent of data
- D) R's `optim()` function computes EVPI automatically
**Answer:** B
**Explanation:** The chapter states EVPI is computed by re-using the per-iteration cost and QALY values from the existing `psa_results` structure, comparing nmb_new and nmb_soc draw-by-draw with no additional model runs required.

### Q388 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** According to §26.2, what shape does EVPI typically follow as a function of the willingness-to-pay (WTP) threshold, and why?
- A) It increases monotonically with WTP with no peak
- B) It is constant across all WTP values
- C) It is low at very low and very high WTP (where the decision is nearly unanimous across draws) and peaks near the WTP where the CEAC crosses 50%, i.e. where the decision is closest to a coin-flip
- D) It decreases monotonically with WTP, reaching zero at high thresholds only
**Answer:** C
**Explanation:** The chapter explains that at extreme WTP values the "right" decision is clear-cut across nearly every draw so EVPI is near zero, while EVPI peaks near the WTP at which the CEAC is closest to 50% — the point where draws are most evenly split.

### Q389 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What is the key difference between EVPI and EVPPI?
- A) EVPPI is always larger than EVPI
- B) EVPI resolves uncertainty in all parameters at once; EVPPI resolves uncertainty in only one parameter (or a chosen subset), leaving the rest exactly as uncertain as before
- C) EVPPI requires no PSA draws at all, unlike EVPI
- D) EVPI applies only to costs, EVPPI only to QALYs
**Answer:** B
**Explanation:** The chapter states EVPPI is a strictly smaller quantity than EVPI (resolving one parameter can never be worth more than resolving everything), and it is the quantity relevant for prioritising which specific future study to fund.

### Q390 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** Why does naive EVPPI estimation require a "nested" simulation that is far more computationally expensive than EVPI?
- A) EVPPI requires re-fitting the PSA distributions from scratch
- B) For each of many candidate values of the parameter of interest (outer loop), a full inner-loop PSA over every other parameter must be re-run to estimate conditional expected net benefit — e.g. 1,000 outer × 1,000 inner draws yields a million model evaluations for one parameter's EVPPI
- C) EVPPI can only be computed using Bayesian MCMC
- D) EVPPI requires collecting new patient-level trial data before any calculation can begin
**Answer:** B
**Explanation:** The chapter explicitly describes this nested structure and gives the million-evaluation example, contrasting it with EVPI's zero-additional-model-runs requirement, which motivates the regression-based shortcut in §26.3.

### Q391 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What statistical insight underlies Strong, Oakley and Brennan's (2014) regression-based EVPPI approach described in §26.3?
- A) EVPI only ever needed the expected net benefit conditional on a given value, which can be estimated by regression (e.g. a GAM) directly on existing PSA draws rather than by brute-force nested simulation
- B) Regression models are faster to fit than Markov models
- C) GAMs eliminate the need for willingness-to-pay thresholds
- D) Linear regression is always sufficient, so GAMs are unnecessary
**Answer:** A
**Explanation:** The chapter describes this as "a clever piece of statistical judo": since the conditional expectation nested simulation estimates the hard way is exactly what a regression's fitted value estimates by construction, fitting a GAM to existing PSA draws gets the same quantity with zero additional model runs.

### Q392 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** Why is a Generalized Additive Model (GAM), rather than ordinary linear regression, the standard tool for the EVPPI regression step?
- A) GAMs always run faster than linear models
- B) The true relationship between a parameter like `p_ontx_fail` and net monetary benefit is not guaranteed to be a straight line; a GAM fits a flexible smooth curve that can bend to follow genuine curvature while a straight line cannot
- C) Linear regression cannot be used with `mgcv`
- D) GAMs do not require a smoothness penalty
**Answer:** B
**Explanation:** The difficult-terminology box explains that NMB might rise steeply then flatten with respect to the failure probability, a shape a straight line cannot follow but a GAM's flexible smooth term (`s(x)` in `mgcv::gam()`) can.

### Q393 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What is the predictable bias direction when `mgcv`'s smoothness parameter `k` is set too small versus too large in a GAM-based EVPPI calculation, per the §26.3 pitfall?
- A) Too small k overstates EVPPI; too large k understates it
- B) Too small k forces an overly rigid fit that smooths real curvature away as noise, understating EVPPI; too large k lets the curve chase sampling noise as if it were a real relationship, overstating EVPPI
- C) Both too-small and too-large k always overstate EVPPI
- D) The value of k has no effect on the EVPPI estimate, only on computation time
**Answer:** B
**Explanation:** The pitfall explicitly states: too small a k understates EVPPI by smoothing away genuine relationship as noise; too large a k overstates EVPPI by letting the curve fit sampling noise as if it were a real signal — the defence is REML-based automatic smoothness selection plus visual diagnostic checking.

### Q394 [Medium] [Image]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** IMAGE PLACEHOLDER: a GAM fit diagnostic scatter plot of raw PSA draws with the mgcv::gam() fitted smooth curve (red) overlaid against p_ontx_fail and incremental NMB, as in §26.3 / fig-ch26-gam-diagnostic. What EVPPI value for `p_ontx_fail` does the chapter report from running this fit on the actual PSA draws?
- A) \$120.00
- B) \$4.00
- C) \$847.01
- D) \$30,000,000
**Answer:** C
**Explanation:** The figure caption states that running the GAM fit on the actual PSA draws gives an EVPPI for p_ontx_fail of \$847.01, close to and independently confirming the \$900 illustrative figure used in worked examples elsewhere in the chapter.

### Q395 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What concrete, policy-relevant question does EVSI (Expected Value of Sample Information) answer that EVPPI cannot?
- A) What is the most we should ever pay to resolve all parameter uncertainty?
- B) What would a specific, real, finite proposed study of a given sample size actually be worth, as opposed to the idealised infinite-sample thought experiment EVPPI represents?
- C) Which model structure is more clinically plausible?
- D) What is the base-case ICER of the decision problem?
**Answer:** B
**Explanation:** §26.4 states EVSI asks what a specific, finite study (e.g. n=200 patients) would actually be worth, which is exactly what a research funder needs, whereas EVPPI is an idealised "what if we knew this parameter perfectly" thought experiment.

### Q396 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** In the moment-matching approach to EVSI (§26.4), what statistical identity is exploited to avoid simulating hypothetical future datasets?
- A) The central limit theorem
- B) The law of total variance: Var(θ) = E[Var(θ|data)] + Var(E[θ|data]), which allows the expected posterior variance reduction from a given sample size to be derived without simulating a single hypothetical patient
- C) Bayes' theorem applied directly to the ICER
- D) The delta method for standard errors
**Answer:** B
**Explanation:** The difficult-terminology box explains that moment-matching uses the law of total variance to estimate the second term (how much the central estimate moves) from existing PSA samples and back out the expected leftover posterior variance by subtraction, with no simulated patients needed.

### Q397 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** In the Beta-Binomial moment-matching worked example for `p_ontx_fail` ~ Beta(8,92), what fraction of the prior variance is expected to be resolved by a future trial of n=200 patients?
- A) About 95.2%
- B) About 33.3%
- C) About 66.4%
- D) About 100%
**Answer:** C
**Explanation:** The chapter computes the expected posterior variance after observing ~16 failures in 200 patients (Beta(24,276)) and finds the reduction is roughly 0.000729 to 0.0002445, about 66.4% of the original variance — closely matching the "effective sample size" heuristic of 1 − 100/300 ≈ 66.7%.

### Q398 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What is the key assumption and main risk of the Gaussian approximation approach to EVSI described in §26.4?
- A) It assumes net benefit is normally distributed, which is fast and convenient but can be materially wrong when net benefit is skewed or multimodal, such as from a rare high-cost failure branch
- B) It requires simulating thousands of hypothetical datasets, making it the slowest of the three EVSI methods
- C) It can only be used for binary outcome parameters
- D) It is only valid when EVPPI equals zero
**Answer:** A
**Explanation:** The chapter states the Gaussian approximation is the fastest of the three approaches but its normality assumption can be misleading for skewed or multimodal net-benefit distributions, such as the TB model's rare high-cost failure branch — best paired with a visual check.

### Q399 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What is the Expected Net Benefit of Sampling (ENBS), and what counter-intuitive finding does the ENBS worked example (comparing a 200-patient vs 2,000-patient trial) illustrate?
- A) ENBS = EVSI × trial cost; the finding is that larger trials always have higher ENBS
- B) ENBS = EVSI − trial cost; the finding is that a larger, more expensive study can have a lower — even negative — ENBS than a smaller, cheaper study targeting the same parameter, due to diminishing returns in variance reduction
- C) ENBS = EVPPI / trial cost; the finding is that ENBS is always positive if EVPPI is positive
- D) ENBS is identical to EVPI once trial costs are included
**Answer:** B
**Explanation:** The worked example gives ENBS of \$29,950,000 for the small (n=200, \$50,000 cost) trial versus −\$2,150,000 for the large (n=2,000, \$45M cost) trial — the large trial's EVSI gain (\$12.85M) doesn't cover its \$44.95M cost premium, a genuinely non-obvious VOI output.

### Q400 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What question does the Value of Implementation (EVI), introduced in §26.5, answer that is fundamentally different from EVPI, EVPPI, EVSI, and ENBS?
- A) How much would it cost to run a larger confirmatory trial?
- B) How much is it costing a health system that an already-correct decision isn't yet being fully carried out in practice, due to slow real-world adoption — independent of any remaining parameter uncertainty
- C) Which model structure best fits the calibration target?
- D) How many PSA iterations are needed for convergence?
**Answer:** B
**Explanation:** The difficult-terminology box contrasts information-focused VOI ("might the decision be wrong?") with implementation-focused VOI ("is the correct decision actually being carried out?") — EVI quantifies the aggregate foregone benefit from the gap between a guideline being issued and full real-world uptake.

### Q401 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** In the §26.5 worked value-of-implementation example (5-year linear ramp to 80% terminal uptake, 10,000 eligible patients/year, \$8,044.05 incremental NMB/patient), what was the total value-of-implementation figure over the 5-year horizon?
- A) \$16,088,100
- B) \$67,570,020
- C) \$209,145,300
- D) \$8,044.05
**Answer:** C
**Explanation:** Summing the value lost per year across years 1-5 (8,400/6,800/5,200/3,600/2,000 un-switched patients each multiplied by the \$8,044.05 per-patient NMB) gives a total of \$209,145,300, undiscounted, over the ramp-up horizon.

### Q402 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** Per the pitfall in §26.4, why can EVSI be close to zero even for a large, well-funded proposed trial?
- A) Large trials always have EVSI of zero by statistical definition
- B) EVSI is a property of the specific proposed study, not just the parameter; a trial that re-measures a parameter whose EVPPI is already near zero, or that targets a parameter the decision barely responds to, can have near-zero EVSI regardless of sample size
- C) EVSI can only be positive for trials under 500 patients
- D) Large trials automatically have negative ENBS
**Answer:** B
**Explanation:** The pitfall states this exact point: no amount of additional precision on an already-unimportant parameter changes the decision, so even a trial of several thousand patients can have EVSI near zero if badly targeted — exactly the finding VOI exists to catch before money is committed.

### Q403 [Easy] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** In §26.6's illustrative EVPPI ranking across four TB model parameters, which parameter had the highest EVPPI and was therefore flagged as the strongest candidate for a dedicated trial?
- A) Discount rate (\$4/patient)
- B) Cost of a failure event, `cost_fail` (\$120/patient)
- C) On-treatment health-state utility (\$340/patient)
- D) On-treatment failure probability, `p_ontx_fail` (\$900/patient)
**Answer:** D
**Explanation:** The illustrative ranking table shows p_ontx_fail with the highest EVPPI (\$900/patient), flagged "High — strong candidate for a dedicated trial," versus the discount rate's negligible \$4/patient despite being just as contested in seminars.

---

## Chapter 27: Model Calibration, Validation and Quality Assurance

### Q404 [Easy] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What is a "calibration target" as defined in §27.1?
- A) The parameter value an analyst hopes to obtain from optimisation
- B) An external, independently-measured outcome (e.g. a registry's reported mortality rate) that the model should be able to reproduce if its hidden parameters are set correctly, ideally from a different data source than whatever built the rest of the model
- C) The willingness-to-pay threshold used in PSA
- D) The seed value used in `set.seed()` for reproducibility
**Answer:** B
**Explanation:** The difficult-terminology box uses the "fitting a key to a lock" analogy: the target is fixed and known, calibration tries parameter values until the model's output matches it, and the target should come from a different data source or the exercise merely confirms the model reproduces its own inputs.

### Q405 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Why is random search calibration described as inefficient for models with more than a few unknown parameters?
- A) R's `runif()` function is slow for more than one parameter
- B) The number of draws needed to maintain the same coverage grows exponentially with the number of parameters — the "curse of dimensionality"
- C) Random search cannot be parallelized
- D) Random search always gets stuck in local optima
**Answer:** B
**Explanation:** The chapter explicitly states random search is easy to parallelize and avoids local optima, but with five or more unknown parameters the same grid density becomes computationally prohibitive due to the curse of dimensionality — with only one parameter, 500 draws is already overkill.

### Q406 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What numerical method does R's `optim()` with `method = "Nelder-Mead"` use to find the calibrated parameter value, and why is it suited to this TB model calibration?
- A) Gradient descent using analytic derivatives of the Markov transition probabilities
- B) A "simplex" of trial points that iteratively reflects, expands, or shrinks toward better-performing points, without needing calculus derivatives — suited here because the model output from discrete Markov cycles is not a smooth analytic function of p_hidden
- C) Exhaustive grid search over all possible parameter combinations
- D) Markov Chain Monte Carlo sampling from a posterior distribution
**Answer:** B
**Explanation:** The difficult-terminology box describes Nelder-Mead's "foggy valley" analogy — a simplex of trial points converging toward the minimum — and explains it is preferred here because it does not require the function to be differentiable, unlike gradient-based methods.

### Q407 [Easy] [Image]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** IMAGE PLACEHOLDER: a scatter plot of 500 random-search p_hidden candidates against their squared distance from the 32% mortality target, with a red point marking the best random-search draw and a dashed green line marking the Nelder-Mead result, as in §27.1 / fig-ch27-calibration-landscape. What converged value does the dashed green line mark?
- A) 0.32
- B) 0.15
- C) 0.084
- D) 0.01
**Answer:** C
**Explanation:** The figure caption states the dashed green line marks the Nelder-Mead-converged value of 0.084, visibly sitting near the bottom of the response curve that random search also explored.

### Q408 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Per the §27.1 pitfall, why is a single calibration target considered a "weak test"?
- A) Single targets always produce biologically implausible parameter values
- B) If p_hidden is calibrated only to match one target, many different combinations of other model parameters could also have been adjusted to hit that same number — the calibration is underdetermined and may be compensating for an error elsewhere in the model
- C) A single target cannot be expressed as a percentage
- D) Single-target calibration always requires Bayesian methods
**Answer:** B
**Explanation:** The pitfall explicitly states the calibration is underdetermined with just one target, and recommends calibrating against multiple independent targets simultaneously and checking the parameter set reproduces all of them, not just the one checked.

### Q409 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What key advantage does Bayesian calibration have over random search or Nelder-Mead point-estimate calibration?
- A) It always converges faster than Nelder-Mead
- B) It produces a full posterior distribution over the calibrated parameter, naturally capturing calibration uncertainty that flows through to more honest downstream cost-effectiveness uncertainty, rather than treating the calibrated value as known with certainty
- C) It does not require specifying a prior
- D) It eliminates the need for a calibration target entirely
**Answer:** B
**Explanation:** The chapter states that Bayesian calibration treats p_hidden as a random variable with a prior updated to a posterior, capturing calibration uncertainty that propagates downstream, unlike plain optimization which implicitly treats the point estimate as certain.

### Q410 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** How does Approximate Bayesian Computation (ABC) handle calibration when the likelihood function is too complex or expensive to write down explicitly?
- A) It derives a closed-form likelihood using the delta method
- B) It repeatedly draws candidate parameters from the prior, runs the full simulation, and keeps only draws whose simulated outcome is close enough to the observed target, treating surviving draws as an approximate posterior
- C) It requires converting all parameters to the log scale first
- D) It only works when the prior is uniform
**Answer:** B
**Explanation:** The difficult-terminology box explains ABC's "many physical keys" analogy: draws producing simulated outcomes within an acceptable distance of the target are kept, others rejected, and the surviving set approximates the posterior without ever formally computing a likelihood.

### Q411 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What advantage does Incremental Mixture Importance Sampling (IMIS) have over naive ABC rejection sampling?
- A) IMIS requires no prior distribution at all
- B) IMIS iteratively builds a mixture of distributions concentrated around regions of parameter space that fit well in earlier iterations, progressively focusing sampling effort — reaching a usable posterior with far fewer total model runs than naive rejection ABC
- C) IMIS always produces a single point estimate rather than a distribution
- D) IMIS does not require any model runs at all
**Answer:** B
**Explanation:** The chapter describes IMIS as sample-efficient because it starts like ABC but progressively concentrates sampling toward well-fitting regions rather than searching the whole prior space with equal density throughout.

### Q412 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** In §27.2, why can a model that is beautifully calibrated to match every target perfectly still be structurally wrong?
- A) Calibration automatically fixes any structural error present in the model
- B) Calibration can mask structural error by forcing a fit of a single parameter to the target; the model could have the wrong number of health states, wrong transitions, or inappropriate cycle length while still hitting the calibration target
- C) Perfect calibration is mathematically impossible, so this scenario cannot occur
- D) Structural errors only manifest in microsimulation, not cohort models
**Answer:** B
**Explanation:** §27.2 opens by distinguishing calibration ("what parameter value fits the target?") from structural cross-validation ("is this the right model structure?"), noting calibration can force a fit and mask a genuinely wrong model shape.

### Q413 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** In the §27.2 cross-validation worked example, the TB model (calibrated only to cohort 1's 5-year mortality of 32%) is checked against cohort 2's independent 3-year mortality of 21%. What does a close match between the predicted and held-out values provide evidence of?
- A) That the calibration target was chosen correctly by definition
- B) That the model's structure — not just the single calibrated parameter — captures the underlying disease process reasonably well, because it generalizes to data it never saw during fitting
- C) That no further validation is needed
- D) That the discount rate was set correctly
**Answer:** B
**Explanation:** The chapter states that if the predicted 3-year mortality comes out close to the held-out 21% target, that is reassuring evidence the model's structure generalizes, because the held-out cohort's data was never used anywhere in the calibration step.

### Q414 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Per the §27.2 pitfall, what condition must hold for a structural cross-validation "held-out" check to be genuinely informative?
- A) The held-out data must come from exactly the same patients as the training data
- B) The held-out data must be genuinely independent of whatever was used to build the model's structural assumptions in the first place — not overlapping patients or already-known information from the model's design phase
- C) The held-out data must always be larger than the training data
- D) The held-out check only needs to use the same outcome measure, regardless of data source
**Answer:** B
**Explanation:** The pitfall warns that if both the training target and the "held-out" check come from the same registry, overlapping patients, or were already known during the model's structural design phase, the check is not really independent and will look falsely reassuring.

### Q415 [Easy] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What is the distinction drawn in §27.3 between calibration/cross-validation and "verification"?
- A) Verification is a subset of calibration
- B) Verification asks whether the code correctly implements the intended model, independent of any external calibration target — a model can be perfectly calibrated by chance while still containing a coding error
- C) Verification only applies to microsimulation models
- D) Verification and calibration are synonymous terms for the same activity
**Answer:** B
**Explanation:** The chapter states a model can be perfectly calibrated to a real-world target purely by chance while still containing a coding error (e.g. a transition matrix whose rows don't sum to 1), and verification catches this by testing the code's internal logic rather than external fit.

### Q416 [Easy] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** In the `testthat` unit test for transition matrix row-sums, why is `tolerance = 1e-8` used rather than requiring an exact match to 1?
- A) To make the test pass regardless of the matrix's correctness
- B) Floating-point arithmetic rarely produces an exact 1.000000000 when probabilities are summed, so a strict comparison would fail correct code due to rounding noise, while 1e-8 is tight enough to catch genuine errors (e.g. a row summing to 0.95)
- C) Because R's `rowSums()` function is inherently imprecise above 1e-8
- D) Because the TB model has exactly 8 health states
**Answer:** B
**Explanation:** The text explains this exact rationale: a tolerance of 1e-8 tolerates harmless floating-point noise while still catching a genuine row-sum error such as a row summing to 0.95 from an omitted transition.

### Q417 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Why does the extreme-value test in §27.3 set the "Well" state's mortality probability to exactly 1, and why is this described as a stronger test than setting a cost parameter to zero?
- A) Because p=1 mortality is clinically realistic for TB patients
- B) The model's behaviour at p=1 is mathematically determinate (zero survivors after cycle 1), so any deviation reveals a bug; a zero-cost test is weaker because many cost structures trivially "pass" (total cost zero) without exercising meaningful logic
- C) Setting mortality to 1 is required by `testthat` syntax
- D) Zero-cost tests always fail regardless of correctness
**Answer:** B
**Explanation:** The pitfall explains that extreme-value tests are informative only when the extreme value is mathematically determinate and forces the test to exercise meaningful model logic; a transition probability of exactly 1 forces a specific, checkable cohort trace, unlike a trivially uninformative zero-cost test.

### Q418 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What distinct class of error does a "replication" check (§27.3) catch that unit tests do not?
- A) Logical errors in the transition matrix construction
- B) Platform-dependent behaviour, uncontrolled randomness, or silent dependency on the state of a previous script run — caught by confirming identical code, seed, and inputs produce identical numeric output across machines/sessions
- C) Errors in the willingness-to-pay threshold selection
- D) Errors only present in Bayesian calibration workflows
**Answer:** B
**Explanation:** The chapter explains replication confirms identical code/seed/inputs give identical output across machines or sessions, catching package version differences, unfixed random seeds, or hidden dependency on prior script state — a different error class than unit tests target.

### Q419 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What does the AdViSHE framework's "Implementation validation" domain correspond to, per the §27.4 reference table?
- A) Whether the model structure is a sensible representation of the disease
- B) The verification question from §27.1-27.3 — whether the model runs correctly, free of mechanical errors — treated as one domain among several rather than the whole of validation
- C) Whether the model has had independent peer review
- D) Whether parameter sources are appropriate
**Answer:** B
**Explanation:** The chapter explicitly states AdViSHE's Implementation validation domain is "essentially the verification question from 27.1-27.3," and that AdViSHE treats it as one domain among several rather than the whole of validation.

### Q420 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** According to §27.4, how does Eddy, Hollingworth, Caro, Tsevat, McDonald and Wong's (2012) ISPOR-SMDM Task Force-7 report further subdivide "validation," beyond the verification/validation split?
- A) Into cost validation and effect validation
- B) Into face validity, internal validity, cross-validation, and external (predictive) validity
- C) Into Bayesian and frequentist validation
- D) Into single-parameter and multi-parameter validation
**Answer:** B
**Explanation:** The chapter states Task Force-7 separates validation into face validity, internal validity (verification, in their terminology), cross-validation, and external (predictive) validity — the taxonomy that structures §27.6.

### Q421 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What is "second-modeler black-box replication," described in §27.5, and why is it considered strong evidence?
- A) A second analyst reviews the original code line by line looking for bugs
- B) A second analyst, given only the same inputs/assumptions/target outputs but deliberately NOT the original code, builds an independent implementation from scratch — matching results is strong evidence largely immune to a shared coding error since the implementations share no code
- C) An automated CI pipeline that reruns the same code on a different server
- D) A peer reviewer's qualitative judgment on whether the model "looks right"
**Answer:** B
**Explanation:** The chapter explicitly distinguishes this from a pull-request code review: the second analyst does not see the original code, so a matching ICER from the independent build is strong operational-validation evidence immune to a shared implementation error.

### Q422 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Per the §27.5 pitfall, why is a "green CI badge" (all `testthat` checks passing) not equivalent to genuine human code review?
- A) CI tests are always slower than human review
- B) CI tests only catch what someone thought to test for and say nothing about whether a change is clinically or economically sensible; human review catches conceptual/judgment errors no automated test anticipated
- C) CI badges only apply to Python code, not R
- D) CI pipelines cannot check transition matrix row-sums
**Answer:** B
**Explanation:** The pitfall states directly that CI catches mechanical regressions but says nothing about clinical/economic sensibility, and warns not to let a green CI badge substitute for a human reviewer reading the diff and rationale.

### Q423 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What is the key terminological trap flagged in §27.6 regarding "cross-validation"?
- A) Cross-validation always requires a minimum sample size of 1,000
- B) The term is a naming collision: the statistical/ML sense (splitting one dataset into folds to estimate out-of-sample predictive performance, Chapter 16) differs structurally from the health-economic-modeling sense (comparing one entire decision model's outputs against other, separately built models of the same problem, with no data-splitting involved)
- C) Cross-validation in health economics always uses k=10 folds
- D) Cross-validation is only valid for microsimulation models, not cohort models
**Answer:** B
**Explanation:** The difficult-terminology box explicitly warns of this naming collision and instructs readers to infer which sense is meant from context — a statistics chapter means the ML sense, a model-validation chapter (like Ch.27) means the model-comparison sense.

### Q424 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** In the §27.6 illustrative external-validity worked example, the TB Markov model predicts 78% 10-year survival for the New regimen, while an illustrative real-world cohort observed 74%. What is the relative (percentage) difference between these figures, as computed in the text?
- A) 4%
- B) 5.41%
- C) 78%
- D) 0.54%
**Answer:** B
**Explanation:** The chapter computes (78−74)/74 × 100 ≈ 5.41%, alongside the absolute difference of 4 percentage points — demonstrating the exact calculation an external-validity exercise performs.

### Q425 [Easy] [Image]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** IMAGE PLACEHOLDER: a bar or point comparison chart showing model-predicted (78%) vs illustrative observed (74%) 10-year survival for the New regimen, as in §27.6 / fig-ch27-external-validity. What caution does the chapter attach to this comparison, per the accompanying pitfall?
- A) The comparison proves the model is definitively correct
- B) A single cohort's outcome is one noisy data point; close agreement could be coincidental and disagreement could reflect a differing real-world population rather than a flawed model — external validity checks are evidence to weigh, not a verdict to declare
- C) External validity checks should replace all other forms of validation
- D) The 4-percentage-point gap definitively proves the model is flawed
**Answer:** B
**Explanation:** The pitfall explicitly warns not to treat a close match as proof of correctness or a gap as proof of flaw, since a single cohort comparison is one noisy data point — evidence to weigh, not a verdict to declare from one comparison.

### Q426 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Per §27.6, why is "face validity" described as necessary but not sufficient on its own for establishing model credibility?
- A) Because face validity requires statistical hypothesis testing
- B) Face validity is a qualitative, expert-judgment check of whether the model's structure looks plausible without running any numbers; an implausible structure isn't worth validating numerically, but a structurally sensible model can still produce numerically wrong outputs
- C) Because face validity can only be assessed after external validity
- D) Because face validity requires access to patient-level trial data
- **Answer:** B
**Explanation:** The difficult-terminology box states face validity is "the simplest and least rigorous form of validation" — a necessary first filter, since an implausible structure isn't worth numerically validating, but insufficient alone because a plausible-looking structure can still yield wrong outputs.
