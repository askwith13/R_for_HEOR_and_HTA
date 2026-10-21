#import "../common.typ": *

= Chapter 34. Emerging Methods and the Future of HEOR in R

#learning-objectives((
  [Identify three genuine use cases for machine learning in HEOR -- heterogeneous treatment effect estimation, flexible survival-extrapolation benchmarking, and predictive risk modelling for patient targeting -- and explain why each differs from the parametric methods covered elsewhere in this book.],
  [Fit a random forest with randomForest::randomForest() to a simulated patient-level dataset, interpret its predictive accuracy and variable-importance output, and critically evaluate the ML-vs-HTA-transparency trade-off.],
  [Describe where large language models are genuinely being piloted in HEOR workflows (SLR screening triage, structured data extraction, R coding assistance), and apply the mandatory human-verification discipline required for each.],
  [Explain hallucination as the core LLM reliability risk, and design a verification workflow (source-quoting, dual review) that mitigates it.],
  [Distinguish a health-care "digital twin" from the microsimulation and DES models already covered in this book, and identify what genuinely differs (the data pipeline) versus what is marketing framing.],
  [Explain what synthetic data is, why it matters for HEOR reproducibility and rare-disease evidence generation, and why it cannot substitute for real patient-level evidence in an HTA submission.],
  [Describe the R Consortium's and ISPOR's Open-Source Models SIG's real roles in supporting open, transparent health-economic modelling, and connect this to the book's own transparency and licensing themes.],
  [Explain the living systematic review concept and its extension to living economic models, and evaluate the genuine governance and maintenance obstacles that currently limit living models to an aspiration rather than standard practice.],
))

== 34.1 Machine learning in HEOR

Every statistical method covered so far in this book -- generalised linear models in Chapter 16, parametric and spline-based survival models in Chapters 10, 12, and 32, doubly-robust causal-inference estimators in Chapter 15 -- shares a common feature: the analyst specifies the functional form (a linear predictor, a hazard shape, a propensity model) before fitting it to data. Machine learning (ML) methods flip that order. Instead of asking the analyst to pre-specify how covariates combine, algorithms such as random forests and gradient boosting let the data determine the shape of the relationship, searching over a very large and flexible space of possible patterns and only settling on the parts that genuinely improve predictive or causal accuracy. That flexibility is not a free upgrade -- it comes with real costs in interpretability and auditability, which is precisely why this book has, up to now, favoured transparent parametric and semiparametric methods for anything that touches a formal HTA submission. This section is about where that trade-off is worth making.

#shiny-app-box("random_forest_risk_threshold_explorer", [Drag the classification-probability cutoff and watch the confusion matrix and sensitivity/specificity trade-off shift live.])

ML earns its place in a HEOR workflow in three genuinely distinct situations, each different from "fit a slightly more flexible curve to the same old problem."

*Heterogeneous treatment effects.* Chapter 16 already introduced `grf::causal_forest()` as the tool for asking not "what is the average treatment effect" but "for which patients is the treatment effect larger or smaller." That machinery is not repeated here -- the point worth restating in this chapter's forward-looking frame is that causal forests are the clearest example of ML doing something a traditional regression genuinely cannot do well: searching, nonparametrically, across a high-dimensional covariate space for *where* treatment-effect heterogeneity lives, without the analyst having to guess the interaction terms in advance. In a world of increasingly stratified reimbursement (companion diagnostics, biomarker-defined subgroups, risk-based managed-entry agreements), this ability to let the data surface a subgroup the analyst did not think to pre-specify is operationally valuable -- and operationally risky, for reasons covered in Chapter 25's discussion of subgroup-finding and multiplicity.

*Flexible survival extrapolation.* Chapters 10, 12, and 32 built parametric (Weibull, log-normal, generalised gamma) and spline-based survival models precisely because HTA extrapolation beyond trial follow-up needs a *defensible* hazard shape -- one a reviewer can inspect, debate, and compare against external data. ML-based survival methods (random survival forests via `randomForest::randomForest()` with a `Surv()` response, or gradient-boosted survival models) do not replace that toolkit; they complement it. Their genuine value is as a flexible benchmark: fitting a random survival forest alongside the parametric candidates and checking whether its nonparametric hazard estimate tracks the chosen parametric curve, or diverges from it in a way that reveals the parametric form is missing real curvature in the data (a changing-shape hazard that a single Weibull cannot capture, for instance). Used this way, ML survival models are a *diagnostic* against the parametric extrapolation the submission will actually use, not a replacement for it -- a distinction worth stating explicitly to a reviewer, since presenting a black-box extrapolation as the base case invites exactly the scrutiny described in the pitfall box below.

*Predictive risk modelling for patient targeting.* The clearest everyday use of ML in applied HEOR work is prediction, not causal inference or extrapolation: given a set of baseline patient characteristics, which patients are likely to become high-cost, be readmitted, or fail first-line therapy? This is a genuinely different task from estimating an average treatment effect or a hazard ratio -- the goal is accurate *individual-level forecasting* to support operational decisions such as who to enrol in a care-management programme, not an unbiased estimate of a causal parameter. Random forests (`randomForest::randomForest()`, or the faster `ranger::ranger()` implementation) and gradient boosting (`xgboost::xgboost()`) are the standard workhorses for this task, because both build large numbers of simple decision trees and combine their predictions, which tends to produce good predictive accuracy on tabular health data without much manual feature engineering.

#heor-practice[
  A payer- or provider-side HEOR team asked to help design a care-management programme does not usually need a causal estimate at all -- it needs a *ranking*: which patients, among a large covered population, are most likely to generate high costs or avoidable admissions next year, so that a limited number of case-management slots can be targeted where they will do the most good. This is a pure prediction problem, and it is one of the few places in HEOR where a "black box" model's superior raw accuracy is often worth the interpretability it costs, because the model's output (a risk score used to rank and triage) does not itself need to be independently audited by a regulator the way a cost-effectiveness submission does.
]

The worked example below simulates a small patient-level dataset and fits a random forest to predict which patients will become high-cost in the following year -- the kind of binary risk-stratification task a care-management targeting exercise would actually run, using only base R plus `randomForest`, no `caret` or `tidymodels` wrapper required.

```r
set.seed(123)
n <- 600

# Simulate baseline covariates for a hypothetical insured population
age               <- round(rnorm(n, mean = 55, sd = 12))
n_comorbidities   <- rpois(n, lambda = 1.3)
prior_admissions  <- rpois(n, lambda = 0.6)
baseline_cost     <- rgamma(n, shape = 2, scale = 1500)

# True (unobserved, in real life) risk relationship generating next-year high-cost status
risk_score <- -4.2 + 0.02 * age + 0.55 * n_comorbidities +
  0.85 * prior_admissions + 0.00025 * baseline_cost
prob_high_cost <- 1 / (1 + exp(-risk_score))
high_cost_next_year <- rbinom(n, 1, prob_high_cost)

patient_data <- data.frame(
  age, n_comorbidities, prior_admissions, baseline_cost,
  high_cost_next_year = factor(high_cost_next_year, labels = c("No", "Yes"))
)

# 70/30 train-test split
train_idx <- sample(seq_len(n), size = 0.7 * n)
train <- patient_data[train_idx, ]
test  <- patient_data[-train_idx, ]

library(randomForest)
rf_model <- randomForest(
  high_cost_next_year ~ age + n_comorbidities + prior_admissions + baseline_cost,
  data = train, ntree = 500, importance = TRUE
)

pred_class <- predict(rf_model, newdata = test)
table(Predicted = pred_class, Actual = test$high_cost_next_year)
mean(pred_class == test$high_cost_next_year)   # overall test-set accuracy
importance(rf_model)                            # variable importance
```

On a simulated run of this code, the forest achieves roughly 78% accuracy on the held-out test set, and the variable-importance output ranks `n_comorbidities` and `prior_admissions` as the strongest predictors of next-year high-cost status -- which matches clinical intuition (patients with more comorbidities and recent admissions are more likely to be high-cost again) and is exactly the kind of sense-check an analyst should always run against a fitted ML model's output before trusting it operationally. `ranger::ranger()` fits the same type of model with a syntax close enough to `randomForest()` that switching between them mainly matters for speed on larger datasets; `xgboost::xgboost()` fits gradient-boosted trees instead of a random forest and typically needs the covariates pre-assembled into a numeric matrix rather than passed as a model formula, which is the main syntactic adjustment when moving from one package to the other.

#difficult-terminology("variable importance / SHAP values")[
  When a model like a random forest combines hundreds of individual decision trees, there is no single coefficient (unlike a logistic regression's odds ratio) that tells you "how much does this covariate matter." *Variable importance* is a family of post-hoc summary measures that try to answer that question anyway, typically by checking how much the model's accuracy drops if a given covariate's values are randomly shuffled (if shuffling `prior_admissions` badly damages predictions, the model was relying heavily on it) or by measuring how much a variable reduces prediction error on average across all the trees' splits (the `MeanDecreaseGini` / `MeanDecreaseAccuracy` columns `randomForest::importance()` returns). *SHAP values* (SHapley Additive exPlanations) are a more modern, mathematically grounded alternative, borrowed from cooperative game theory: for one specific patient's prediction, a SHAP value apportions "credit" for that individual prediction across each covariate, so you can say not just "comorbidity count matters a lot across the whole model" but "for this particular patient, their high prior-admission count pushed their predicted risk up by this much, while their younger age pulled it back down." Think of variable importance as a model-wide ranking (which ingredients matter most in the recipe, on average) and SHAP values as a per-dish breakdown (which ingredients made *this* dish turn out the way it did).
]

#pitfall[
  A random forest or gradient-boosted model that predicts patient-level outcomes well is not, by itself, an acceptable replacement for a transparent decision-analytic model in most HTA submission contexts. Chapter 27 covered why HTA bodies expect a model's structure, assumptions, and calculations to be inspectable and independently reproducible -- the ISPOR-SMDM Modeling Good Research Practices Task Force's transparency guidance exists precisely because a reviewer cannot sign off on a model they cannot audit. A fitted random forest with 500 trees, or a gradient-boosted ensemble with similarly many weak learners, has no equivalent to a Markov model's transition-probability table or a decision tree's branch structure that a reviewer can trace by hand. Variable importance plots and SHAP values (see above) genuinely help explain *what the model is doing*, but they are an approximation layered on top of the black box after the fact, not the box itself -- they do not make the underlying ensemble of hundreds of trees auditable in the way a transparent state-transition structure is. In practice, ML-based risk prediction is best positioned in a submission as a supporting analysis (e.g., justifying how a subgroup was identified for a separate cost-effectiveness analysis that itself uses a transparent model structure) rather than as the primary cost-effectiveness engine itself. Confirm the acceptability of any ML component directly against the specific HTA body's methods guidance before relying on it for a submission's base case -- do not assume a strong predictive accuracy number alone will satisfy a transparency requirement.
]

== 34.2 Large language models in HEOR workflows (SLR, extraction, coding assistance) and their validation

Large language models (LLMs) -- the technology behind tools such as ChatGPT, Claude, and similar systems -- generate fluent text by predicting, token by token, what is likely to come next given everything written so far, trained on vast quantities of text. They are not a statistical method for estimating a treatment effect or a cost-effectiveness ratio; they are a general-purpose language tool that HEOR teams have begun piloting for specific workflow tasks that are heavy on reading, writing, and pattern-matching text rather than on numerical estimation. As of this book's writing, three uses are common enough to be worth covering honestly, alongside the validation discipline that has to accompany every one of them.

*Systematic literature review (SLR) screening assistance.* Chapter 6 covered the mechanics of running a systematic literature review -- search strategy, PRISMA flow, dual independent screening. Title/abstract screening is the single most time-consuming manual step in that process, often running to several thousand records for a broad HTA-relevant review. LLM-assisted triage tools now exist that read a title and abstract and flag a likely include/exclude/uncertain classification against a reviewer's pre-specified eligibility criteria, which can meaningfully cut reviewer time on the clear-cut majority of records. The standard, and currently still the expected, practice is that this remains *triage, not decision*: a human reviewer -- or, per the dual-screening convention from Chapter 6, two independent human reviewers -- makes the actual final inclusion/exclusion call, with the LLM's suggestion treated as a prioritisation aid (e.g. surfacing the most likely false negatives for a second human look) rather than as the review's recorded decision.

*Structured data extraction from published reports.* A second emerging use is extracting structured values out of a published trial report's free text -- PICOS elements (Population, Intervention, Comparator, Outcome, Study design), baseline characteristics tables, or a specific numeric outcome value buried in a results paragraph -- into a structured table ready for a network meta-analysis dataset (Chapter 12) or an evidence table in a submission dossier. This is a genuinely useful acceleration of what is otherwise slow, error-prone manual re-typing, but the exact same transparency caution applies as to screening: every extracted value is a candidate error until a human has checked it against the source document, because the tasks where LLMs are most useful (dense numeric tables, inconsistent reporting formats across papers) are also the tasks where a plausible-but-wrong extracted number is hardest to spot by eye.

*Coding assistance for R-based HEOR models.* The third use is simply asking an LLM to help write, explain, or debug R code -- drafting a first pass at a Markov model's transition matrix construction, explaining an unfamiliar `survival::survreg()` error message, or suggesting a `ggplot2` fix for a stubborn axis-labelling problem. This is now a routine, everyday part of how a lot of applied R programming gets done, in HEOR and well beyond it -- and, stated plainly rather than hidden, is part of how this book's own worked examples and prose were developed and checked. It does not replace an analyst's judgment about whether a model's assumptions are appropriate or whether a line of code actually implements the health-economic logic intended; it accelerates the mechanical parts of getting syntax and boilerplate right, with the analyst still responsible for verifying that the generated code does what the task actually requires -- the same verification discipline Chapter 20's unit-testing material and Chapter 27's code-review practices already describe for any R code, LLM-assisted or not.

A short illustrative sketch of the kind of extraction task described above -- not an executable call, since this book cannot run a live LLM API from a static R chunk, but useful to see the shape of what a well-specified extraction request should look like:

```r
# Illustrative prompt-template structure for LLM-assisted PICOS extraction
# (not executed -- shown to illustrate the expected input/output contract)

extraction_prompt <- "
From the attached trial report text, extract the following fields
into a single-row data frame with these exact column names:
  study_id, population, intervention, comparator,
  primary_outcome, primary_outcome_value, primary_outcome_ci_lower,
  primary_outcome_ci_upper, sample_size_total

Rules:
- If a field cannot be found in the text, return NA for that field --
  never estimate, infer, or fabricate a value.
- Quote the exact source sentence used for each numeric field
  alongside the extracted value.
"
# A human reviewer then checks every extracted value and its quoted
# source sentence against the original PDF before the row enters
# the analysis dataset.
```

The instruction to return `NA` rather than guess, and to quote the source sentence behind every number, is doing real work in that template -- it is a direct, practical mitigation against the core risk described next.

#difficult-terminology("hallucination")[
  In the context of LLMs, a "hallucination" is not a visual or sensory experience -- it is the model generating a statement that is fluent, confident, and plausible-sounding, but factually wrong or entirely fabricated, with no signal in the model's output to distinguish it from a correct statement. Because an LLM is fundamentally predicting likely-sounding text rather than looking up or verifying facts, it can state a specific hazard ratio, a page number, a citation, or an extracted baseline mean that sounds exactly as confident and well-formatted as a correct one, while being invented. This is the single most important fact to understand about using LLMs for any extraction or screening task: fluency and correctness are not the same thing, and an LLM provides no built-in warning label distinguishing a genuine extracted value from a fabricated one. The practical analogy worth holding onto: a confident, well-spoken witness is not automatically a reliable one -- you still have to check their account against the original record.
]

#pitfall[
  Treating any LLM output -- a screening decision, an extracted numeric value, a generated citation, or a block of R code -- as ground truth without independent human verification is the single most consequential mistake a HEOR team can make when adopting these tools. The specific failure mode to design against is hallucination (see above): an LLM asked to extract a hazard ratio from a trial report can return a number that is close to, but subtly different from, the real reported value, formatted with exactly the same confidence as a correct extraction, and with no flag distinguishing the two. The current, defensible practice is to treat LLM output the same way Chapter 6 treats a single reviewer's screening decision in a review that is supposed to be dual-reviewed: a draft requiring independent confirmation, never a final answer on its own. For extraction tasks specifically, require the tool to quote its source text alongside every extracted value (as in the template above) so a human reviewer can check the quote against the original document in seconds rather than re-reading the whole paper; for screening, keep a human decision-maker on every borderline or include/exclude call; for code, run and test the generated code against known cases rather than trusting it because it looks syntactically correct.
]

An emerging, and currently still developing, methodological practice worth tracking is transparent disclosure of LLM assistance in a paper's or submission's methods section -- stating explicitly which steps used LLM assistance (e.g. "title/abstract screening triage was supported by an LLM-based classifier; all inclusion/exclusion decisions were made by two independent human reviewers blinded to the classifier's output") and what human verification step was applied to each. ISPOR and other HEOR professional bodies have begun actively discussing and publishing good-practice guidance on the use of AI and LLMs in health economics and outcomes research -- the exact scope and recommendations of that guidance are still evolving as of this book's writing, so rather than citing a specific document title here, the practical takeaway is to check ISPOR's current task force and good-practice-guidance output directly before finalising a submission's AI-disclosure language, since this is one of the fastest-moving areas of HEOR methodology and any citation risks being out of date by the time it is read.

#agency-note[
  Several national HTA bodies and methods groups have signalled, through conference presentations, methods panels, and emerging guidance discussions, active interest in how AI- and LLM-assisted evidence generation should be disclosed and evaluated in submissions -- but as of this book's writing, there is no single universally adopted standard specifying exactly what must be disclosed or how an HTA reviewer should weigh an LLM-assisted step. The safest working assumption for a submission team is maximal transparency: disclose every step where LLM assistance was used, describe the human verification applied at that step, and be prepared for a reviewer to ask about it directly -- treat non-disclosure, not disclosure, as the reputational risk.
]

== 34.3 Digital twins and synthetic data

#difficult-terminology("digital twin")[
  In engineering, a digital twin is a software model of a physical object (a jet engine, a wind turbine) that is continuously updated with sensor data from its real-world counterpart so the model's predictions stay matched to that specific object's behaviour. In health, the term has been borrowed to describe a simulated representation of a patient or patient population, ideally calibrated to that individual's (or cohort's) actual data, used to predict outcomes or test "what if" scenarios without intervening on the real patient.
]

The phrase "digital twin" has become common in health technology marketing over the past several years, and it is worth being honest, up front, about what it does and does not add to the modelling toolkit this book has already built. Strip away the branding and a health-care digital twin is, structurally, an individual-level simulation model: it represents a single (simulated) patient or a population of simulated patients, assigns parameters describing their disease trajectory, and projects outcomes forward under one or more scenarios. That is exactly the territory covered by the Markov cohort models of Chapter 19, the microsimulation approach of Chapter 21, and the discrete-event simulation (DES) models of Chapter 22. A microsimulation model that samples individual patient trajectories and updates risk based on accumulated history already behaves, mechanically, like a population of digital twins.

What distinguishes the more ambitious "digital twin" framings in the literature is less the modelling algorithm and more the *data pipeline* feeding it: a true digital twin aspires to be calibrated, continuously or near-continuously, to a specific patient's real-world data stream -- wearable sensor readings, repeated laboratory results, electronic health record updates -- so the simulated trajectory tracks that individual rather than representing an "average" patient drawn from population-level parameters. In principle, this lets a clinician or payer ask patient-specific counterfactual questions ("if this particular patient started treatment B instead of treatment A six months ago, where would their disease state be today?") with more individual fidelity than a cohort-level model can offer.

In practice, the term is used loosely and inconsistently across vendors, conference abstracts, and even peer-reviewed papers. Some "digital twin" studies are genuinely individually-calibrated, data-rich simulations updated against a live data feed. Many others are, on inspection, conventional microsimulation or DES models with no more individual-level calibration than models that have gone by less fashionable names for over a decade. As a reader of this book, you are already equipped to build the simulation engine underneath a digital twin claim -- the distinguishing, harder engineering problem is almost always the data infrastructure (consented, continuously updated, individual-level data access) rather than the statistical or simulation methodology itself. When you encounter a "digital twin" claim in a submission or a vendor pitch, the useful question to ask is not "is this a digital twin?" but "what real-world data stream, if any, is this calibrated to, how often is it updated, and how does that differ structurally from the microsimulation approach in Chapter 21?"

=== Synthetic data

#difficult-terminology("synthetic data")[
  Data generated by an algorithm -- typically a statistical or machine-learning model fitted to real patient data -- designed to reproduce the statistical patterns (distributions, correlations, event rates) of the original dataset, without any row in the synthetic dataset corresponding to a real, identifiable patient.
]

Synthetic data is a related but conceptually separate idea from digital twins, and the two are sometimes confused because both involve a "simulated patient." A digital twin aims to represent *one specific real patient or cohort* as faithfully as possible. Synthetic data aims to produce a dataset that looks statistically like a *real dataset*, without any individual row being traceable back to a real person -- the goal is population-level statistical fidelity combined with individual-level anonymity, not fidelity to any one patient.

This matters for HEOR for a specific, practical reason already touched on in Chapter 2 and running through Part VI's reproducibility theme: much of the patient-level data that underpins economic models -- clinical trial individual patient data (IPD), insurance claims, electronic health records -- cannot be shared outside the organisation that holds it, for privacy and governance reasons, even when sharing would let independent analysts reproduce or validate a submitted model. Synthetic data generation is one proposed answer: if a generative model can be fitted to the real, restricted dataset and used to produce a synthetic version with similar statistical properties, that synthetic version can sometimes be shared more freely (code, worked examples, methodology demonstrations) in place of the real data.

A second proposed use, conceptually related to the historical-control and single-arm methods discussed in Chapter 32 §32.2, is augmenting small or rare-disease datasets: where a genuine comparator arm is infeasible to recruit, a synthetic dataset generated from pooled historical sources is sometimes proposed as a way to construct an external control population, or to pad a small sample for more stable model-fitting.

Both uses deserve an honest caveat. Synthetic data, by construction, preserves the statistical properties of the data it was trained on -- it does not and cannot create new clinical information that was not already present (in some aggregate, redistributable form) in the source data. If the underlying real dataset has a biased case-mix, a coding error, or a spurious correlation, a generative model fitted to it will typically reproduce that bias or error in the synthetic output, often without any visible warning sign -- a problem sometimes described as the generative model "laundering" the original data's flaws into a dataset that looks clean and shareable. Synthetic data quality is also highly sensitive to the generative method and sample size used to fit it; a small, over-fitted generative model can produce synthetic data with implausible correlations or null variability in variables that should show real-world spread.

#pitfall[
  Synthetic data is a tool for *sharing and demonstrating methodology*, not a substitute for real patient-level evidence in an HTA submission. A synthetic dataset generated from a real clinical trial can support a public, reproducible walkthrough of your analysis code, but it must never be presented to a reimbursement agency as if it carries the same evidential weight as the real IPD or claims data that justified the submission's effectiveness or cost claims. Agencies evaluate the credibility of a clinical and economic case based on real patient evidence and its documented provenance; synthetic data has no independent evidentiary status of its own. If synthetic data is used anywhere in a submission pipeline (for example, to test or demonstrate the pipeline while the real data is embargoed), this must be disclosed explicitly and the real-data results reported as the actual basis for the decision.
]

A simple, honestly-scoped illustration: one of the most basic forms of "synthetic data" is simulating new observations from parametric distributions fitted to a real dataset's summary statistics, which preserves marginal distributions but -- unless done carefully -- can lose real correlation structure between variables.

```r
library(dplyr)

# Suppose `real_data` has columns `age` and `cost` from a real
# (here illustrative) patient-level dataset we cannot redistribute
set.seed(123)
real_data <- data.frame(
  age  = rnorm(200, mean = 62, sd = 11),
  cost = rgamma(200, shape = 2, rate = 1 / 4000)
)

# Fit simple parametric summaries via method of moments
age_mean   <- mean(real_data$age); age_sd <- sd(real_data$age)
cost_mean  <- mean(real_data$cost); cost_var <- var(real_data$cost)
cost_shape <- cost_mean^2 / cost_var
cost_rate  <- cost_mean / cost_var

# Generate a synthetic dataset matching those marginal distributions
n_synth <- nrow(real_data)
synthetic_data <- data.frame(
  age  = rnorm(n_synth, mean = age_mean, sd = age_sd),
  cost = rgamma(n_synth, shape = cost_shape, rate = cost_rate)
)
```

This naive approach reproduces each variable's marginal distribution reasonably well but, as written, samples `age` and `cost` independently -- so any real correlation between age and cost in the original data (older patients tending to cost more, say) is lost unless the generation step explicitly preserves the joint distribution (for example, via a fitted copula or a conditional model). More sophisticated synthetic data generation methods -- including machine-learning-based generative models -- attempt to preserve this joint structure, at the cost of additional complexity and additional scope for silently encoding the training data's biases. The principle to take away is not a specific package recommendation, but the general pattern: synthetic data is only as trustworthy as the fidelity of the generative process and the quality of the real data it was built from.

== 34.4 Open-source collaboration: the R Consortium, ISPOR's Open-Source Models SIG, and the HEOR R community

Much of this book's content -- the packages used throughout (`heemod`, `hesim`, `flexsurv`, `BCEA`, and the many others referenced since Chapter 1) -- exists because of a broader open-source R community that extends well beyond HEOR, but increasingly has organised sub-communities specifically focused on health-economic modelling. This section covers three related, real strands of that community: the R Consortium, ISPOR's Open-Source Models Special Interest Group, and the wider ecosystem of community-maintained HEOR packages.

=== The R Consortium

The R Consortium is a real organisation, operating under the Linux Foundation, that supports the R language and its surrounding ecosystem. Its general activities include funding infrastructure and package-development projects through grant programmes, and supporting R-related community events and working groups. It is not an HEOR-specific body -- its scope spans the entire R user base, from academic statistics to industrial data science -- but its work funding core R infrastructure (packaging tools, documentation systems, community infrastructure like R-Hub) indirectly benefits every domain, including HEOR, that depends on a healthy, well-maintained R package ecosystem. This book will not attempt to enumerate specific grant awards or dollar figures, since these details change over time and are best checked directly against the R Consortium's own published project listings if you need current specifics; the general point to take away is that CRAN's long-term health is not accidental -- it is sustained, in part, by organised, funded community effort of exactly this kind.

=== ISPOR's Open-Source Models Special Interest Group

ISPOR -- the professional society for health economics and outcomes research referenced throughout this book -- hosts a real Special Interest Group (SIG) focused on open-source models. Its general mission is to promote the development, use, and transparent review of health-economic models built in open-source tools, including R, as a counterpoint to the historically dominant closed, proprietary modelling environments (commercial Excel-based workbooks, licensed software such as TreeAge) that this book discussed in the open-source-versus-proprietary licensing comparison of Chapter 30 §30.7.

#agency-note[
  The rationale behind groups like ISPOR's Open-Source Models SIG connects directly to a theme introduced in this book's opening chapter and revisited in the model-validation discussion of Chapter 27: a model's credibility is strengthened, not weakened, when its internal logic can be inspected. A closed, licensed Excel macro or proprietary software black box can, in principle, be just as rigorously built as an open R script -- but it cannot be independently *read* by a reviewer the way open, version-controlled R source code can. Several HTA agencies and academic reviewers have, in recent years, shown a growing expectation that submitted models -- whatever language they are built in -- should be inspectable in enough detail for an independent analyst to trace how an input assumption flows through to a stated result. Building your models in the transparent, auditable style this book has taught (clear scripts, version control, documented assumptions, as discussed from Chapter 30 onward) positions you well for that expectation, regardless of which specific agency or jurisdiction you are submitting to.
]

As with the R Consortium, this book will not invent specific SIG meeting dates, membership figures, or named outputs that cannot be independently verified at time of writing; the durable fact worth retaining is that this SIG exists, has this stated general purpose, and represents organised professional recognition -- from within the HEOR field's own learned society -- that open-source modelling is a legitimate, actively promoted alternative to closed proprietary tools, not a fringe practice.

=== The wider HEOR-in-R ecosystem

Beyond these two formal organisations, the practical, everyday support structure for HEOR modelling in R is the CRAN ecosystem itself. CRAN maintains curated "Task Views" -- community-maintained guides collecting together packages relevant to a particular domain of statistical or applied work -- and while this book will not assert the existence of one specific, named Task View devoted exclusively to HEOR or health-economic modelling (check CRAN's current Task View listing directly, since this changes over time), CRAN does maintain Task Views covering adjacent, directly relevant domains such as survival analysis and clinical trial design, and the general CRAN package-review and maintenance infrastructure is what keeps packages like the ones used throughout this book -- `flexsurv` for parametric survival extrapolation (Chapters 10 and 12), `heemod` and `hesim` for cohort and individual-level economic modelling, `BCEA` for the cost-effectiveness-analysis outputs discussed earlier in the book -- actively maintained, documented, and checked for basic correctness on an ongoing basis.

The value of this community-maintained infrastructure to HTA submission work is not abstract. A package like `flexsurv` or `heemod` has had its core logic read, used, and (in many cases) reported on by a far larger number of independent users than any single in-house proprietary spreadsheet ever will be. When you build a submission model on these open, peer-used foundations and document your own code transparently in the style this book has advocated from Chapter 30 through the companion-repository discussion in that same Part, you are not just following good practice for its own sake -- you are tapping into a layer of community-level scrutiny of the underlying tools that closed, single-vendor software cannot offer in the same way.

== 34.5 Looking ahead: living models and living systematic reviews

#difficult-terminology("living systematic review")[
  A systematic review that is maintained as an ongoing process rather than a one-off project -- new studies are continuously (or on a short, regular cycle) searched for, screened, and incorporated into the review's synthesis as they are published, rather than the review being redone from scratch only every few years.
]

The living systematic review is a real, established methodology, developed and promoted in particular by Cochrane -- the international network behind many of the systematic review standards already discussed earlier in this book. The traditional systematic review model, in which a review team conducts a comprehensive literature search, synthesis, and publication, then leaves the review static until (perhaps years later) a full update is separately commissioned, has a structural weakness in fast-moving clinical areas: the evidence base can shift meaningfully in the interval between updates, leaving decision-makers relying on a synthesis that is, by the time they read it, already dated. The living systematic review model addresses this by building the updating process into the review's design from the outset -- a defined, recurring (sometimes monthly) search-and-screen cycle rather than a single search conducted once. Cochrane has formally recognised and supported this methodology for a subset of reviews, particularly in rapidly evolving clinical areas, though it remains more resource-intensive to sustain than a conventional one-off review and is applied selectively rather than universally.

=== Extending the idea to economic models

The logical extension of a living systematic review is a *living economic model*: an HTA model designed, from the outset, to be periodically or continuously re-run as new clinical evidence, new real-world outcomes data, or updated pricing and discount information becomes available -- rather than being built, submitted, and then left static as a one-time artefact until the next full re-submission is separately commissioned.

This idea connects directly back to infrastructure this book has already taught you to build. A model constructed as a reproducible, version-controlled `targets` pipeline, in the style introduced in Chapter 30 §30.4, is structurally almost exactly what a living model requires: input data and parameter sources are declared as explicit pipeline targets rather than hard-coded values, the dependency graph tells you precisely which downstream results need to be recomputed when an upstream input changes, and the whole analysis can be re-run end to end with a single command once new data lands. A well-engineered R pipeline is, in this sense, *better suited* to the living-model idea than a static Excel workbook, where updating even one input cell can require manually re-checking dozens of dependent formulas with no automated guarantee that every downstream calculation has actually been refreshed correctly.

#heor-practice[
  If you are building a model you expect to need updating -- for a product with an evolving real-world evidence programme, an actively recruiting trial with planned data cuts, or a therapeutic area with fast-moving comparator pricing -- invest in the pipeline discipline from Chapter 30 even if the first submission is a one-time event. The marginal cost of declaring your inputs and parameters as explicit, named pipeline targets rather than embedded constants is small at build time, and it is exactly what determines whether a future update is a same-day re-run or a multi-week re-build from memory of how the original model worked.
]

=== The practical gap between aspiration and practice

It would be dishonest to present living models as an established, routine practice at HTA agencies today -- they are not, and the gap between the technical feasibility this book has equipped you to build and the institutional practice of most agencies is genuinely large. Several practical obstacles remain largely unresolved:

- *Governance*: a static submitted model has a clear approval record -- it was reviewed, and a decision was made against that specific version. A living model raises an open question this book cannot resolve for you: who approves an updated model, and at what threshold of change does an update trigger a formal re-review by the agency, as opposed to being treated as routine maintenance the manufacturer can perform unilaterally? Most HTA processes are not currently built around continuously evolving submitted evidence.
- *Maintenance burden*: there is a real difference between a model designed to be re-run on a defined, periodic schedule (say, annually, aligned with a planned re-assessment) and one marketed as "continuously" updating. True continuous updating requires sustained data-pipeline maintenance, monitoring for upstream data changes, and ongoing analyst time that is easy to underestimate -- the computational re-run itself is often the cheapest part of the exercise.
- *Versioning and audit trail*: if a model's conclusions can change between one re-run and the next, a defensible audit trail of exactly which version produced which submitted number -- tying back to the version-control practices discussed in Chapter 30 -- becomes not a nice-to-have but a structural requirement.

None of this means the idea is not worth pursuing -- it is a genuinely promising direction, and the reproducible, pipelined modelling practice this book has taught throughout Part VI is the right foundation for it, should an agency or sponsor choose to adopt it. But it is fair to describe living economic models, at the time of writing, as more an aspiration under active discussion than a standard, agency-mandated practice.

Having now covered the full breadth of HEOR methods in R -- from foundational cost-effectiveness concepts through to these emerging, still-maturing frontiers -- the book turns, in its final chapter, to pulling the pieces together: Chapter 35 works through complete, end-to-end worked case studies, applying the methods built across this book to realistic HEOR and HTA problems from start to finish.
