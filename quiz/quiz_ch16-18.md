# Quiz Questions: Chapters 16-18

## Chapter 16: Regression Models for HEOR Data

### Q226 [Easy] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** In the generalised linear model (GLM) framework, what are the three ingredients that define a GLM?
- A) A sample size, a significance level, and a p-value
- B) A distribution from the exponential family, a linear predictor, and a link function
- C) A training set, a test set, and a validation set
- D) A fixed effect, a random effect, and an interaction term
**Answer:** B
**Explanation:** The chapter states a GLM has three ingredients: a distribution for the outcome from the exponential family, a linear predictor (η = β0 + β1x1 + ...), and a link function connecting the two (g(μ) = η).

### Q227 [Easy] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** Which family/link combination does the chapter recommend for binary outcomes like treatment success or mortality?
- A) Gamma family with a log link
- B) Poisson family with a log link
- C) Binomial family with a logit link
- D) Gaussian family with an identity link
**Answer:** C
**Explanation:** The chapter states binary outcomes use the binomial family with a logit link — logistic regression — because the logit link keeps predicted probabilities between 0 and 1.

### Q228 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** Why does the chapter recommend negative binomial regression as the "safer default in practice" over Poisson regression for TB programme count data?
- A) Negative binomial models are always faster to fit in R
- B) Poisson regression cannot handle a log link function
- C) TB programme count data is almost always overdispersed (variance exceeds the mean), violating Poisson's equal mean-variance assumption
- D) Negative binomial regression does not require the `glm()` function
**Answer:** C
**Explanation:** The text explains that count outcomes like hospitalisations are almost always overdispersed in real programme data, and Poisson's assumption that mean equals variance is routinely violated, making negative binomial the safer default.

### Q229 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** What is the single most common GLM reporting error the chapter warns against in its pitfall box?
- A) Forgetting to set `family = ` in `glm()`
- B) Reporting raw link-scale coefficients (e.g. log-odds) unchanged instead of exponentiating them
- C) Using `lme4` instead of `glm()`
- D) Fitting a Poisson model to continuous outcome data
**Answer:** B
**Explanation:** The pitfall box states that a GLM's raw coefficients live on the link scale (e.g. log-odds for logistic models), and reporting them unchanged means almost nothing to a stakeholder; coefficients must always be exponentiated before presenting results.

### Q230 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** In `lme4::glmer(success ~ regimen + age + (1 | clinic_id), family = binomial())`, what does the `(1 | clinic_id)` term represent?
- A) A fixed effect of clinic on the outcome
- B) A random intercept, giving each clinic its own baseline log-odds drawn from a shared normal distribution
- C) An interaction term between clinic and regimen
- D) A quantile regression term set to the median
- E) (not applicable)
**Answer:** B
**Explanation:** The chapter describes `(1 | clinic_id)` as the random intercept: one baseline log-odds per clinic drawn from a shared normal distribution, rather than a fixed-effect dummy per clinic.

### Q231 [Hard] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** What does the intraclass correlation coefficient (ICC) measure in a mixed-effects model, and what does an ICC near 0 imply?
- A) The correlation between two fixed-effect covariates; near 0 means multicollinearity is absent
- B) The proportion of total outcome variance attributable to the grouping factor (e.g. clinic); near 0 means clinics barely differ and a plain GLM would have been fine
- C) The strength of the treatment effect; near 0 means the drug has no effect
- D) The goodness-of-fit of the model; near 0 means a perfect fit
**Answer:** B
**Explanation:** The chapter defines ICC as the proportion of total outcome variance attributable to the grouping factor versus variance between patients within the same clinic, and states an ICC near 0 means clinics barely differ and a plain GLM would have been fine.

### Q232 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** Ignoring clustering and fitting a naive GLM to hierarchical data primarily causes which problem?
- A) Standard errors become too small, because clustered observations are treated as more independent than they are
- B) Coefficients become biased toward zero
- C) The model fails to converge
- D) Standard errors become too large, making true effects look non-significant
**Answer:** A
**Explanation:** The text states that ignoring clustering "specifically makes [standard errors] too small, because the model treats twenty patients from one clinic as twenty independent pieces of information when they're closer to a handful."

### Q233 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** What is the key conceptual difference between a zero-inflated model and a hurdle model for count data with excess zeros?
- A) Zero-inflated models mix two kinds of zeros (structural and sampling); hurdle models treat crossing from zero to any event as a separate mechanism from the counting process above one
- B) Hurdle models can only be fit with Poisson, zero-inflated models only with negative binomial
- C) There is no real difference; they are two names for the same model
- D) Zero-inflated models require continuous outcomes, hurdle models require binary outcomes
**Answer:** A
**Explanation:** The chapter explains that a zero-inflated model mixes "structural" zeros (could never have an event) with ordinary sampling zeros, while a hurdle model treats clearing the zero/any-event hurdle as a distinct first step before a truncated count model for how many events occur.

### Q234 [Hard] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** In the `pscl::zeroinfl()` formula `ae_count ~ arm + age | arm`, what does the right-hand side of the `|` model?
- A) The dispersion parameter theta
- B) The probability of being a structural zero
- C) The count of events among those who could never have one
- D) The confidence interval for the rate ratio
**Answer:** B
**Explanation:** The chapter states the formula has two parts separated by `|`: the left side models the count given membership in the "can have events" group, and the right side models the probability of being a structural zero.

### Q235 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** A capacity planner asks "what should we provision for the costly tail of length-of-stay?" Which R approach from the chapter directly answers this, and how?
- A) `glm.nb()`, by estimating an extra dispersion parameter
- B) `quantreg::rq()` with `tau = 0.9`, modelling the 90th percentile of the cost distribution directly
- C) `MASS::polr()`, by modelling ordered categories
- D) `grf::causal_forest()`, by estimating heterogeneous treatment effects
**Answer:** B
**Explanation:** The chapter explains that quantile regression via `quantreg::rq()` models a chosen percentile directly, and gives the example that a capacity planner asking about the costly tail wants the 90th or 95th percentile, achieved by setting `tau = 0.9`.

### Q236 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** What is the "proportional-odds assumption" underlying both `MASS::polr()` and `ordinal::clm()`?
- A) That every predictor must be binary
- B) That the sample size is large enough for asymptotic normality
- C) That the effect of each predictor is the same across every cut-point of the ordinal scale
- D) That residual deviance equals degrees of freedom
**Answer:** C
**Explanation:** The chapter defines the proportional-odds assumption as the effect of each predictor being the same across every cut-point of the ordinal scale, e.g. a treatment's effect moving "poor" to "fair" is assumed equal to its effect moving "good" to "excellent."

### Q237 [Hard] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** What distinguishes `grf::causal_forest()` from `randomForest::randomForest()` or `ranger::ranger()` as used in this chapter?
- A) Causal forests cannot use continuous covariates
- B) Random forests estimate individual-level treatment effects; causal forests only predict outcomes
- C) Causal forests are grown specifically to estimate individual-level treatment effects given covariates X, outcome Y, and treatment indicator W, whereas plain random forests just predict an outcome without estimating a treatment effect
- D) There is no meaningful difference between the two approaches
**Answer:** C
**Explanation:** The chapter states that `randomForest()`/`ranger()` predict an outcome and do not estimate a treatment effect, while `grf::causal_forest()` is tuned specifically to estimate individual-level treatment effects from X, Y, and W.

### Q238 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** In `glmnet::glmnet(x, y, alpha = , lambda = )`, what does setting `alpha = 1` versus `alpha = 0` correspond to?
- A) `alpha = 1` is ridge regression; `alpha = 0` is LASSO
- B) `alpha = 1` is LASSO, shrinking many coefficients exactly to zero; `alpha = 0` is ridge regression
- C) Both settings are identical and only affect computation speed
- D) `alpha = 1` fits a Poisson model; `alpha = 0` fits a Gaussian model
**Answer:** B
**Explanation:** The chapter states `alpha = 1` is the LASSO (shrinks many coefficients exactly to zero for automatic variable selection), `alpha = 0` is ridge regression, and values in between are the elastic net.

### Q239 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** According to the chapter, what is the correct way to formally test for effect modification (a treatment effect that differs by subgroup)?
- A) Compare two separate within-subgroup p-values
- B) Fit an interaction term (e.g. `treatment * hiv_status`) in a single regression model
- C) Run a t-test comparing the two subgroup means
- D) Compute the ICC for the subgroup variable
**Answer:** B
**Explanation:** The chapter explicitly states that the formal test for effect modification is an interaction term in a regression model — not a pair of separate within-subgroup analyses — illustrated with `treatment * hiv_status`.

### Q240 [Hard] [Image]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** IMAGE PLACEHOLDER: a histogram showing the distribution of per-patient estimated treatment effects (tau_hat) from `grf::causal_forest()`, bimodal with one cluster near zero and another around 0.25-0.3, with a solid red vertical line marking the single average effect, as described in §16.5's figure. What does the bimodal spread in this figure demonstrate?
- A) The causal forest model has failed to converge and should be refit
- B) Evidence of real heterogeneity of treatment effect — a single average effect (the red line) would mask that some patients benefit far more than others
- C) That the treatment has no effect on any patient
- D) That the sample size was too small to estimate tau_hat reliably
**Answer:** B
**Explanation:** The figure caption states the bimodal spread — one cluster near zero, another around 0.25-0.3 — is itself evidence of real heterogeneity, since a single average effect line would mask that some patients benefit far more than others.

## Chapter 17: Principles of Decision Modelling

### Q241 [Easy] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** What does the PICOTS framework add to the four core framing terms (population, comparators, perspective, time horizon) already introduced in Chapter 4?
- A) It replaces perspective and time horizon entirely with new terms
- B) It splits "comparators" into intervention vs. comparator and adds outcomes, timing, and setting as explicit fields
- C) It is used only for Markov models, not decision trees
- D) It is a statistical test for model fit
**Answer:** B
**Explanation:** The chapter describes PICOTS as extending PICO for economic evaluation, splitting "comparators" into intervention vs. comparator and adding outcomes, timing, and setting as explicit fields to the same four ideas from §4.6.

### Q242 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** In the TB regimen PICOTS example, why is "Timing" (follow-up to 12 months post-treatment-completion) explicitly distinguished from the model's "time horizon"?
- A) They are actually the same concept and the distinction is just terminology
- B) Timing describes the follow-up window of the evidence informing the model, while the time horizon is how far forward the model itself projects, which may need to extend well beyond 12 months
- C) Timing refers only to calendar dates, while time horizon refers only to discount rates
- D) Time horizon is always shorter than the evidence's follow-up timing
**Answer:** B
**Explanation:** The chapter explicitly notes that PICOTS "Timing" describes the evidence's follow-up window, while the time horizon is a separate modelling choice about how far forward the model projects, possibly well beyond 12 months to capture downstream relapse and retreatment costs.

### Q243 [Easy] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** What is the purpose of a "model concept document" per the chapter?
- A) To store the final R code for the model
- B) To let clinical and economic stakeholders sign off on the decision question before anyone invests time building the answer
- C) To replace the need for a PSA (probabilistic sensitivity analysis)
- D) To document only the discount rate used
**Answer:** B
**Explanation:** The chapter states the model concept document's purpose is to let stakeholders sign off on the question before anyone invests time building the answer, listing the decision problem, PICOTS elements, intended model type, data sources, and audience.

### Q244 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** Per the five questions in §17.2 for choosing a model type, which model type is favoured when "a patient's future risk depends on their individual history... in a way a cohort-level model cannot capture"?
- A) Decision tree
- B) Markov cohort model
- C) Partitioned survival model
- D) Individual-level (microsimulation) model
**Answer:** D
**Explanation:** The chapter's fourth question explicitly states that dependence on individual history (time already in a state, prior treatment lines, accumulated events) favours individual-level microsimulation modelling (Chapter 21).

### Q245 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** Applying the five model-type questions to the TB regimen example (on treatment, cured, failed, relapsed, retreatment, death states with cycling), which model type does the chapter conclude is the natural choice?
- A) Decision tree, because it's a one-off decision
- B) Partitioned survival model, because of oncology-style survival curves
- C) Markov cohort model, because the disease has discrete, recurring states that patients can cycle between
- D) Discrete event simulation, because of resource constraints
**Answer:** C
**Explanation:** The heor-practice box concludes that "Question 2 dominates" for the TB regimen example — discrete, clinically meaningful recurring states with cycling (failure leads back to retreatment) — making a Markov cohort model the natural choice, built in Chapter 19.

### Q246 [Hard] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** Which model type does the chapter identify as "the only model type in Part IV that routinely models resource constraints explicitly"?
- A) Decision tree
- B) Markov cohort model
- C) Individual-level microsimulation
- D) Discrete event simulation
**Answer:** D
**Explanation:** The fifth model-choice question states that shared, limited resources, queues, or patient interactions favour discrete event simulation (ch. 22), described as "the only model type in Part IV that routinely models resource constraints explicitly."

### Q247 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** In §17.3, which of the following is NOT one of the three structural-assumption questions the chapter says come up in almost every state-transition model?
- A) Can patients move backward between states?
- B) Is there a tunnel state?
- C) What happens at the end of the model's time horizon?
- D) What discount rate should be applied to future costs?
**Answer:** D
**Explanation:** The three structural-assumption questions listed are about backward movement, tunnel states, and what happens at the end of the time horizon; discount rate is not among them (it is covered elsewhere in the book, e.g. Chapter 4/22).

### Q248 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** What R package and function does §17.3 use to render a model structure diagram, and what underlying graph language does it use?
- A) `ggplot2::ggplot()`, using grid graphics
- B) `DiagrammeR::grViz()`, using the DOT graph description language (Graphviz)
- C) `igraph::plot.igraph()`, using adjacency matrices
- D) `heemod::plot_model()`, using YAML
**Answer:** B
**Explanation:** The chapter states the `DiagrammeR` package's `grViz()` function renders diagrams written in the DOT graph description language, the same language used by Graphviz, well suited to drawing health-state diagrams.

### Q249 [Hard] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** Why does the chapter recommend the Beta distribution (rather than the Normal) for transition probabilities in PSA?
- A) Beta distributions are computationally faster to sample in R
- B) A Normal distribution can return draws below 0 or above 1, producing a model error or nonsensical result, while Beta is bounded on [0, 1]
- C) Beta distributions always have a smaller variance than Normal distributions
- D) NICE requires Beta distributions by regulation regardless of parameter type
**Answer:** B
**Explanation:** The heor-practice box explains that a transition probability must stay between 0 and 1 in every PSA draw; a Normal distribution can violate this bound, whereas the Beta distribution is defined on [0, 1] and matches the binomial likelihood typically generating the estimate.

### Q250 [Hard] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** In the worked method-of-moments beta-fitting example (mean 0.85, 95% CI 0.80-0.90), what are the resulting approximate alpha and beta shape parameters?
- A) alpha ≈ 0.85, beta ≈ 0.15
- B) alpha ≈ 29.24, beta ≈ 165.68
- C) alpha ≈ 165.68, beta ≈ 29.24
- D) alpha ≈ 1.96, beta ≈ 0.0255
**Answer:** C
**Explanation:** The worked R example computes alpha_p ≈ 165.68 and beta_p ≈ 29.24, and the check confirms Beta(165.68, 29.24) reproduces a mean of 0.85 and SE of 0.0255, matching the trial's reported CI.

### Q251 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** According to the chapter's parameter taxonomy, what distribution is conventionally used for relative treatment effects such as hazard ratios in PSA?
- A) Beta on the probability scale
- B) Dirichlet
- C) Normal on the log scale (e.g. log hazard ratio), matching the scale of the meta-analytic standard error
- D) Gamma on the raw hazard-ratio scale
**Answer:** C
**Explanation:** The chapter states relative treatment effects usually use a normal distribution on the log scale, because that is the scale on which the meta-analytic standard error from Chapters 11-12 was estimated.

### Q252 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** What is the key distinction the chapter draws between a technical model documentation (TMD) report and the executable R model code?
- A) The TMD is optional while the code is mandatory for NICE submissions
- B) A commented script explains *how* the model computes, while the TMD explains *why* it is built the way it is, for a reader who may never open the script
- C) The TMD only covers costs, while the code covers everything else
- D) There is no meaningful distinction; either can substitute for the other
**Answer:** B
**Explanation:** The chapter states documentation and code are not substitutes for each other: a commented script explains how the model computes, while the TMD report explains why it is built the way it is, for a reader who may never open the script.

### Q253 [Easy] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** What are the four layers the chapter recommends for organising an R decision-model project (§17.6)?
- A) Data, Code, Tests, Documentation
- B) Inputs, Engine, Results, Reporting
- C) Population, Intervention, Comparator, Outcome
- D) Scoping, Structure, Parameters, Validation
**Answer:** B
**Explanation:** The chapter describes an architecture of four layers — an inputs layer, an engine layer, a results layer, and a reporting layer — each doing one job and talking to the next through a clean interface.

### Q254 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** Which CRAN package does the chapter name as implementing the inputs/engine/output architecture specifically for Markov cohort models, covered properly in Chapter 19?
- A) `rdecision`
- B) `heemod`
- C) `DiagrammeR`
- D) `quantreg`
**Answer:** B
**Explanation:** The chapter states that `heemod` is a mature CRAN package that implements exactly this inputs/engine/output separation for Markov cohort models, while `hesim` does something similar across a broader range of model types including partitioned survival.

### Q255 [Hard] [Image]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** IMAGE PLACEHOLDER: a left-to-right DiagrammeR/Graphviz DOT diagram with boxes "On Treatment" (light blue), "Cured" (light green), "Treatment Failure" (light salmon), and "Death" (grey), with arrows labelled "treatment success," "treatment failure," "re-registration" (Fail back to On Treatment), and three "mortality" arrows into Death from every other state, as rendered by `grViz()` in §17.3. Which structural-assumption answer is directly visible in this diagram?
- A) The model uses a tunnel state for a fixed treatment course length
- B) Patients can move backward between states (Fail -> OnTx via re-registration) and Death is absorbing and reachable from every other state
- C) The model has a societal perspective
- D) The time horizon is lifetime
**Answer:** B
**Explanation:** The chapter states the diagram already answers two of the three structural questions visibly: backward movement exists (`Fail -> OnTx`) and death is absorbing and reachable from everywhere, with no tunnel state in this simplified version.

## Chapter 18: Decision Trees

### Q256 [Easy] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** What are the three node types in a decision tree, and their typical shapes?
- A) Decision (square), chance (circle), terminal (triangle/end of branch)
- B) Root (diamond), leaf (circle), branch (square)
- C) Input (hexagon), process (rectangle), output (oval)
- D) Strategy (triangle), state (square), transition (circle)
**Answer:** A
**Explanation:** The chapter states every tree has three kinds of nodes: a decision node (drawn as a square, the strategy choice), a chance node (a circle, where nature decides the outcome), and a terminal node (a triangle or end of branch, carrying the accumulated payoffs).

### Q257 [Easy] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** In the TB diagnostic worked example, what is the TB prevalence among symptomatic presenters used in the branch-probability calculations?
- A) 0.10
- B) 0.30
- C) 0.60
- D) 0.98
**Answer:** B
**Explanation:** The chapter states "Among symptomatic presenters, TB prevalence is p = 0.30," which is used to compute the disease-status branch of both the smear and Xpert trees.

### Q258 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** What sensitivity and specificity values does the chapter assign to the Xpert MTB/RIF algorithm?
- A) Sensitivity 0.60, specificity 0.98
- B) Sensitivity 0.90, specificity 0.96
- C) Sensitivity 0.96, specificity 0.90
- D) Sensitivity 0.30, specificity 0.70
**Answer:** B
**Explanation:** The chapter states Xpert has sensitivity 0.90 and specificity 0.96, compared with smear microscopy's sensitivity 0.60 and specificity 0.98.

### Q259 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** What does the "rollback" (or "folding back") algorithm do in decision tree analysis?
- A) It randomly samples branch probabilities for a Monte Carlo simulation
- B) It works from the terminal nodes backward, replacing branches below each chance node with their probability-weighted average payoff until only the decision node remains
- C) It reverses the order of strategies in the output table
- D) It discounts future costs and QALYs to present value
**Answer:** B
**Explanation:** The chapter defines rollback/folding back as working from terminal nodes backward, replacing branches below a chance node with their probability-weighted average payoff, repeating until one EV per strategy remains at the decision node.

### Q260 [Hard] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** Based on the worked hand-calculation in §18.1, what are the expected cost and expected QALYs for the Smear-only strategy?
- A) $63.80 and 0.95454
- B) $60.40 and 0.93302
- C) $5.00 and 0.97000
- D) $158.00 and 1.00000
**Answer:** B
**Explanation:** The chapter's worked calculation sums 0.18×105 + 0.12×305 + 0.014×105 + 0.686×5 = $60.40 for expected cost, and 0.18×0.95 + 0.12×0.70 + 0.014×0.90 + 0.686×0.97 = 0.93302 for expected QALYs for Smear-only.

### Q261 [Hard] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** What is the approximate ICER of Xpert MTB/RIF versus Smear-only testing, per the chapter's worked example, and what does it imply?
- A) Approximately $158 per QALY gained; cheap insurance against missed diagnoses at almost any plausible willingness-to-pay threshold
- B) Approximately $3.40 per QALY gained; dominated by Smear-only
- C) Approximately $63.80 per QALY gained; too expensive to adopt
- D) Approximately $1580 per QALY gained; borderline cost-effective
**Answer:** A
**Explanation:** The chapter computes ICER = (63.80 - 60.40) / (0.95454 - 0.93302) ≈ $158 per QALY gained, and states this is "cheap insurance against missed diagnoses by almost any plausible willingness-to-pay threshold."

### Q262 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** Why does the chapter caution in its §18.1 pitfall box against pricing a diagnostic test only by sensitivity and specificity?
- A) Sensitivity and specificity are always reported incorrectly in published studies
- B) Prevalence sets how often the TP/FN branches versus FP/TN branches are even reached, so the same test's value changes dramatically with the underlying disease prevalence
- C) Specificity does not matter for cost calculations
- D) Sensitivity and specificity cannot be combined with cost data mathematically
**Answer:** B
**Explanation:** The pitfall box states that prevalence sets how often you reach the TP/FN branches versus FP/TN branches, so a highly sensitive test saves far more QALYs at high prevalence than at low prevalence — rerunning the tree at p=0.10 would move the ICER.

### Q263 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** In the §18.2 tidy-data-frame implementation, what R expression directly computes the rollback (expected value) once `path_prob` has been calculated?
- A) `mean(path_prob + cost)`
- B) `sum(path_prob * cost)` / `sum(path_prob * qaly)`, grouped by strategy
- C) `lm(cost ~ path_prob)`
- D) `t.test(cost, qaly)`
**Answer:** B
**Explanation:** The chapter states that with `path_prob` computed, the rollback is one `summarise()` call computing `ev_cost = sum(path_prob * cost)` and `ev_qaly = sum(path_prob * qaly)`, grouped by strategy — a direct translation of the hand arithmetic.

### Q264 [Hard] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** In `rdecision`, which three R6 node classes does the chapter introduce, and what does each represent?
- A) `RootNode`, `BranchNode`, `LeafNode` — representing start, middle, and end of any tree
- B) `DecisionNode` (root-level choice), `ChanceNode` (nature decides), `LeafNode` (terminal outcome carrying utility/cost)
- C) `InputNode`, `EngineNode`, `OutputNode` — representing the four-layer workflow from Chapter 17
- D) `StateNode`, `TransitionNode`, `CycleNode` — used only for Markov models
**Answer:** B
**Explanation:** The chapter introduces `DecisionNode` (the root-level choice point, e.g. "which algorithm?"), `ChanceNode` (a point where nature decides), and `LeafNode` (a terminal outcome carrying an incremental utility and cost).

### Q265 [Hard] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** In `rdecision`, what does setting `p = NA_real_` for one `Reaction` out of a `ChanceNode` accomplish?
- A) It causes the tree to fail evaluation until a numeric probability is supplied
- B) The package fills that probability in at evaluation time as one minus the sum of the other reactions from that same chance node, enforcing that branch probabilities sum to 1
- C) It tells `rdecision` to use a Dirichlet prior for that branch
- D) It marks that branch as a tunnel state
**Answer:** B
**Explanation:** The chapter explains that leaving one reaction's probability as `p = NA_real_` is idiomatic `rdecision` convention; the package fills it in at evaluation time as one minus the sum of the other reactions from that chance node, a built-in version of the "sum to 1" check.

### Q266 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** According to §18.3, what does `rdecision` buy over the from-scratch §18.2 data-frame approach, beyond identical arithmetic?
- A) Faster CPU execution only
- B) Repeatable evaluation over resampled inputs for PSA, graphical rendering of the tree structure for submission dossiers, and native cost/effect tracking enabling direct ICER/NMB extraction
- C) The ability to model Markov transitions directly within the same tree object
- D) Automatic discounting of future costs
**Answer:** B
**Explanation:** The chapter lists three benefits: `evaluate()` can be re-run over resampled parameters for PSA, the tree can be rendered graphically for a submission appendix, and cost/effect as native node attributes let ICER/NMB come directly out of `evaluate()`'s output.

### Q267 [Easy] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** What is the chapter's recommended practice for validating an `rdecision`-built tree against the hand/data-frame version?
- A) Discard the hand-rolled version once the package version is built
- B) Keep the hand-rolled §18.2 version in the repository as an independent cross-check, confirming both agree to the last rupee and fourth decimal of a QALY
- C) Only trust the `rdecision` version since it is peer-reviewed software
- D) Re-derive the ICER formula from scratch each time
**Answer:** B
**Explanation:** The heor-practice box recommends keeping the hand-rolled version as an independent cross-check, running both on the same inputs and confirming expected costs and QALYs agree to the last rupee and fourth decimal of a QALY.

### Q268 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** Per §18.4, which criterion from Chapter 17 §17.2 determines when a decision tree (rather than a Markov model) is the right tool?
- A) The availability of individual patient-level data
- B) The one-off/short-horizon test: consequences resolve within a single episode of care with no need to track recurring health states over months or years
- C) Whether resource constraints like queues are present
- D) Whether the outcome is continuous or binary
**Answer:** B
**Explanation:** The chapter restates the §17.2 criterion by name: a tree suits a question when consequences resolve within a single episode of care with no need to track a cohort moving between recurring health states over time; crossing into cycling states moves you into Markov territory.

### Q269 [Hard] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** In §18.5, what specifically "crosses the interface" when a decision tree hands off to a downstream Markov model?
- A) The full patient-level dataset used to build the tree
- B) A vector of state-occupancy probabilities: the probability mass arriving at each leaf node becomes the initial occupancy of the corresponding Markov starting state at cycle zero
- C) The tree's R6 class objects directly, reused as Markov nodes
- D) Only the aggregate ICER value
**Answer:** B
**Explanation:** The chapter is explicit that what crosses the interface is "not patients, not probabilities-as-abstractions, but a vector of state-occupancy probabilities" — each leaf's arriving probability mass becomes the initial occupancy of the corresponding Markov state at time 0.

### Q270 [Hard] [Image]
**Chapter(s):** 18 (Decision Trees)
**Question:** IMAGE PLACEHOLDER: a decision-tree diagram as in §18.1, with a square decision node "Algorithm" branching into "Smear" and "Xpert," each leading to a circular chance node for disease status (TB/No TB), then a second circular chance node for test result, ending in four triangular terminal nodes per strategy labelled TP, FN, FP, TN with attached cost and QALY payoffs. Which node type carries the accumulated cost and QALY payoffs in this diagram?
- A) The decision node (square)
- B) The first chance node (disease status)
- C) The terminal node (triangle / end of branch) — e.g. TP, FN, FP, TN
- D) The second chance node (test result)
**Answer:** C
**Explanation:** The chapter defines the terminal node as carrying the payoffs — here a cost and a QALY value — accumulated by the time that path is reached, as seen in the TP/FN/FP/TN outcomes of the TB diagnostic tree.
