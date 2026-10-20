#import "../common.typ": *

= Chapter 15. Real-World Evidence (RWE) and Causal Inference

Chapter 14 worked with evidence you already trusted the structure of: trial data, pooled contrasts, a posterior you could carry straight into a decision model. This chapter asks a harder question. What if the evidence was never randomised — a TB programme register, an insurance claims database, a hospital's electronic health records? Can you still get a defensible causal answer?

Most of this chapter's methods are frequentist, by design and by convention. Chapter 14 already flagged RWE and causal inference as the one area where Bayesian methods are an occasional option, not the default. Propensity scores, doubly robust estimators, instrumental variables, difference-in-differences — these are overwhelmingly practiced and reported in a frequentist frame in the field itself, and this chapter follows that convention.

The chapter has four parts. §15.1-15.3 build the foundations: what makes data fit for purpose, which study design fits which question, and how a causal diagram makes your confounding assumptions explicit before you fit anything. §15.4-15.7 cover the core estimation toolkit for when you believe you have measured the relevant confounders: propensity scores, doubly robust estimators and g-methods, instrumental variables and regression discontinuity, and difference-in-differences/interrupted time series. §15.8-15.9 cover two problems that recur constantly in HTA submissions: adjusting for treatment switching, and quantifying how robust a finding is to confounders you could not measure. §15.10-15.11 close with infrastructure and design: the OHDSI/OMOP standard for multi-site data, and external/synthetic control arms for single-arm trials.

#learning-objectives((
  [Assess whether a real-world data source is fit for purpose using the FDA's relevance/reliability framework, and document that assessment before analysis begins],
  [Choose between a cohort, case-control, or target trial emulation design for a given RWE question, and explain how target trial emulation guards against immortal time and prevalent-user bias],
  [Build a directed acyclic graph (DAG) in `dagitty`/`ggdag`, distinguish confounders from mediators and colliders, and extract a minimal sufficient adjustment set programmatically rather than adjusting for every available covariate],
  [Implement propensity score matching, weighting, and balance diagnostics in R (`MatchIt`, `WeightIt`, `cobalt`), and compute an inverse-probability-weighted average treatment effect by hand to verify package output],
  [Explain why doubly robust estimators (AIPW) and g-methods relax the single-correct-model assumption of plain propensity-score or outcome-regression approaches, and when time-varying confounding requires g-methods specifically],
  [Apply instrumental variables (`ivreg`) and regression discontinuity (`rdrobust`) to recover causal effects under unmeasured confounding, and recognise the diagnostic checks (weak-instrument F-test, exclusion restriction plausibility, manipulation testing) each design requires],
  [Implement difference-in-differences correctly under staggered treatment adoption (`did::att_gt()`) rather than naive two-way fixed effects, and fit an interrupted time series model with `segmented` or an explicit level/slope-change specification],
  [Describe when and why treatment-switching adjustment (RPSFTM, IPCW) is needed in trials with crossover, and name NICE DSU TSD 16 as the governing methods reference],
  [Compute and interpret E-values (`EValue` package) as a standardised sensitivity measure for unmeasured confounding, and present them alongside point estimates rather than in isolation],
  [Describe the role of the OHDSI/OMOP Common Data Model and its R tooling (`DatabaseConnector`, `FeatureExtraction`, `CohortMethod`) in multi-site observational studies, and judge when that infrastructure is worth its complexity],
  [Construct a propensity-matched external control arm for a single-arm trial, and explain why temporal/era comparability is a distinct threat from baseline covariate imbalance],
))

== 15.1 Fit-for-purpose RWD and RWE frameworks

Every chapter so far in this book has worked from evidence that was, in some sense, handed to you: trial arms with randomised assignment, published hazard ratios, posterior distributions from a Bayesian network meta-analysis. From this chapter onward the ground shifts. Real-world data (RWD) — programme registers, insurance claims, electronic health records (EHRs), laboratory information systems, even the line-listings your national TB programme submits to WHO — were not collected to answer your causal question. They were collected to run a clinic, bill a payer, or satisfy a surveillance mandate. Turning that data into real-world evidence (RWE) fit for a regulatory or HTA decision requires you to be explicit about *why* the data exist, *whether* they can answer the question you are asking, and *what* bias they carry before a single regression line is fitted.

This is not a semantic nicety. The US FDA's 2023 guidance *"Real-World Data: Assessing Electronic Health Records and Medical Claims Data To Support Regulatory Decision-Making for Drug and Biological Products"* — part of the broader RWE framework the agency committed to under the 21st Century Cures Act — sets out a two-part test that has become the de facto global standard even outside the US: is the data *relevant* to the clinical question (right population, right exposure, right outcome, adequate follow-up), and is it *reliable* (accurate, complete, traceable, with transparent provenance)? The EMA's parallel work, coordinated through the Big Data Steering Group and operationalised in the *DARWIN EU* (Data Analysis and Real World Interrogation Network) initiative, asks the same two questions in different words: data quality and study design robustness. For a TB programme analyst, the practical translation is this — before you touch a single `dplyr` verb, you document where each variable in your dataset came from, how it was captured (clinician entry, lab interface, self-report), what fraction is missing and why, and whether the cohort you can assemble actually contains the exposure contrast (e.g., bedaquiline-containing vs injectable-containing regimen) and the outcome (culture conversion, treatment success, death) with enough precision to support inference.

A useful habit is to write a short *data provenance and fitness memo* before analysis begins — not after a reviewer asks for one. The memo should state the data source and update frequency, the target population and how your extract maps onto it, known structural gaps (e.g., private-sector treatment episodes missing from a public programme register), and the intended use of the evidence (safety signal, comparative effectiveness, HTA submission). This is the RWE-era equivalent of a statistical analysis plan, and regulators increasingly expect to see it.

```r
library(dplyr)
library(tibble)

# A minimal fitness-for-purpose checklist as a data frame -- the kind of
# artefact you would attach to an analysis plan or HTA dossier appendix
rwd_fitness_checklist <- tibble::tribble(
  ~domain,         ~question,                                              ~assessment,
  "Relevance",     "Does the population match the decision question?",     "Partial: public-sector only",
  "Relevance",     "Is exposure (regimen) captured with dates?",           "Yes, pharmacy dispense log",
  "Relevance",     "Is the outcome defined per WHO TB definitions?",       "Yes, treatment outcome registry",
  "Reliability",   "Is there a documented data dictionary?",               "Yes, v3.2",
  "Reliability",   "What proportion of key covariates are missing?",       "HIV status 4%, culture 11%",
  "Reliability",   "Is there an audit trail / source verification?",       "Partial: no routine monitoring"
)

print(rwd_fitness_checklist, n = Inf)
```

The point of such a table is not bureaucratic box-ticking. A "Partial" answer in the Relevance domain tells you, before you run a single model, that any effect estimate will generalise only to the public sector, and a "Partial" in Reliability tells you that missingness in HIV status is probably not completely at random and will need explicit handling (multiple imputation, inverse-probability weighting, or at minimum a sensitivity analysis) rather than a silent `na.omit()`.

#heor-practice[
When an RWE analysis is destined for a reimbursement dossier, align the fitness-for-purpose assessment with the specific decision-grade evidence standard the payer applies — in India, HTAIn's methods guidance and NICE's real-world evidence framework in the UK both now ask explicitly whether the RWD source could, in principle, have supported a trial-emulating analysis. Framing your memo in those terms early avoids a late-stage "why wasn't this a target trial emulation" review comment.
]

#pitfall[
Treating "more data" as a proxy for "better evidence" is one of the most common RWE errors. A claims database with five million patients but no reliable treatment-start date is less fit for a comparative-effectiveness question than a programme register of five thousand patients with verified regimen dates. Volume does not substitute for relevance and reliability — assess both before describing a data source as "big data."
]

== 15.2 Study design: cohort, case-control, target trial emulation

Once a data source clears the fitness-for-purpose bar, the next decision is architectural: what study design will let the data answer the causal question without manufacturing an answer that merely reflects who received the exposure in the first place? Three designs recur constantly in TB and infectious-disease RWE work, and each has a distinct bias profile.

A *cohort design* follows an exposed and an unexposed (or differently exposed) group forward from a defined start point to an outcome. It is intuitive and maps directly onto the trial structure you already know from earlier chapters, but its validity depends entirely on correctly defining "time zero" — the point at which eligibility, exposure assignment, and follow-up all begin simultaneously. Get this wrong (for example, by including follow-up time before a drug was actually started, or by selecting on survival to the point of exposure) and you reintroduce *immortal time bias*, a problem familiar from pharmacoepidemiology that inflates apparent drug benefit.

A *case-control design* samples cases of the outcome (e.g., treatment failure) and a comparison set of controls from the same source population, then looks backward at exposure. It is efficient for rare outcomes and is still common in TB drug-resistance surveillance, but it is acutely sensitive to how controls are selected — control selection that does not mirror the case-generating mechanism produces selection bias that no amount of post-hoc adjustment repairs.

The design that has reshaped how regulators and HTA bodies think about RWE over the past decade is *target trial emulation (TTE)*, formalised by Hernán and Robins (*"Using Big Data to Emulate a Target Trial When Comparing Adaptive, Dynamic Treatment Regimes"*, _American Journal of Epidemiology_, 2016, and elaborated in their freely available text _Causal Inference: What If_). The core discipline of TTE is simple to state and demanding to execute: before touching the observational data, write a protocol for the *hypothetical pragmatic randomised trial* you would run if you could — eligibility criteria, treatment strategies being compared, assignment procedure, start of follow-up, outcome, causal contrast of interest, and analysis plan. Only then do you specify how each protocol element is emulated in the observational data. This explicit target-trial protocol is what prevents two subtle, pervasive errors: immortal time bias (misaligned time zero) and *prevalent-user bias* (comparing new starters to patients already established on treatment, who have by definition survived early attrition).

```r
library(tibble)
library(dplyr)

# A target trial protocol, specified as a structured object before any
# emulation code touches the observational extract. Writing this first
# is the TTE discipline, not an optional add-on.
target_trial_protocol <- tribble(
  ~component,            ~specification,
  "Eligibility",         "Adults starting first-line TB treatment, no prior TB Rx",
  "Treatment strategies","Bedaquiline-containing vs standard injectable-containing regimen",
  "Assignment",          "Hypothetical randomisation at treatment initiation",
  "Time zero",           "Date of first regimen dispense (must equal eligibility date)",
  "Outcome",             "WHO-defined treatment success at 6 months",
  "Causal contrast",     "Intention-to-treat and per-protocol effects",
  "Analysis",            "IPTW-adjusted Kaplan-Meier / Cox, with cloning-censoring-weighting for per-protocol"
)

print(target_trial_protocol, n = Inf)

# Emulating "time zero" correctly: every patient's follow-up clock
# starts at regimen initiation, not at diagnosis or enrolment
cohort <- tibble(
  patient_id   = 1:6,
  diagnosis_dt = as.Date(c("2022-01-05","2022-01-10","2022-02-01",
                            "2022-02-15","2022-03-01","2022-03-10")),
  regimen_start= as.Date(c("2022-01-07","2022-01-20","2022-02-02",
                            "2022-02-28","2022-03-01","2022-03-25")),
  regimen      = c("Bedaquiline","Injectable","Bedaquiline",
                    "Injectable","Bedaquiline","Injectable")
)

cohort <- cohort %>%
  mutate(
    lead_in_days = as.numeric(regimen_start - diagnosis_dt),
    time_zero    = regimen_start   # NOT diagnosis_dt -- avoids immortal time bias
  )

cohort
```

The `lead_in_days` column is exactly the diagnostic you want in an audit: any patient with a long gap between diagnosis and regimen start who is nonetheless analysed as "exposed from diagnosis" is a walking immortal-time-bias case study. Setting `time_zero` to `regimen_start` and restricting eligibility to patients alive and in the cohort at that date is the whole trick — the rest of the per-protocol / intention-to-treat machinery (cloning, censoring, and inverse-probability-of-censoring weighting) builds directly on this correctly specified start point and is covered alongside the causal-inference workhorse models later in this chapter.

#heor-practice[
When drafting an RWE protocol for a regulatory or HTA submission, structure the methods section using the Hernán-Robins "specify target trial, then specify emulation" table explicitly — most reviewers trained in the FDA RWE framework or EMA's DARWIN EU studies now expect to see eligibility, treatment strategy, assignment, time zero, outcome, and analysis mapped side-by-side between the hypothetical trial and the observational emulation. A protocol that skips this mapping invites exactly the immortal-time and prevalent-user critiques described above.
]

#agency-note[
The FDA's 2021 draft guidance *"Considerations for the Design and Conduct of Externally Controlled Trials for Drug and Biological Products"*, together with the 2023 RWD/EHR-and-claims guidance under the agency's RWE Framework (per the 21st Century Cures Act §3022 mandate), explicitly references target trial emulation logic when assessing whether a non-interventional comparator arm is fit to support an effectiveness claim — sponsors are expected to pre-specify the emulated trial's eligibility, treatment strategies, and time-zero alignment before data extraction, mirroring Hernán and Robins' original 2016 _AJE_ framework.
]

== 15.3 Confounding and bias, with DAGs (`dagitty`, `ggdag`)

Study design controls *which* biases are structurally possible. It does not, by itself, tell you which variables you must adjust for to recover an unbiased causal effect. That is the job of a *directed acyclic graph (DAG)* — a transparent, falsifiable statement of your assumptions about how variables cause one another, drawn *before* you fit any model.

A DAG forces you to distinguish three structures that are easy to confuse in a results-driven rush to "adjust for everything available": *confounders* (common causes of exposure and outcome, which you must adjust for), *mediators* (on the causal pathway from exposure to outcome, which you must *not* adjust for if you want the total effect), and *colliders* (common effects of two variables, which adjusting for actively *induces* bias where none existed).

In a TB regimen-comparison example, HIV status plausibly affects both which regimen a clinician chooses and the probability of treatment success — a classic confounder. Nutritional status measured mid-treatment, however, may be partly a *consequence* of the regimen (some regimens cause more nausea and weight loss) and partly a cause of outcome — a mediator, and adjusting for it would bias the estimate of the regimen's total effect. Site-level treatment capacity might influence both which patients get referred there (a collider with other selection variables) and local reporting completeness. Getting this taxonomy right by eye, on a real dataset with a dozen covariates, is essentially impossible without a graph.

The R packages *dagitty* and *ggdag* let you encode these assumptions as code, visualise them, and — critically — ask the graph itself what the minimal sufficient adjustment set is, rather than adjusting for every variable in the extract "to be safe."

```r
library(dagitty)
library(ggdag)
library(ggplot2)

# Encode the causal structure with ggdag::dagify(); exposure/outcome
# arguments tell dagitty which nodes play which role
tb_dag <- ggdag::dagify(
  success ~ regimen + hiv + nutrition + site_capacity,
  regimen ~ hiv + site_capacity,
  nutrition ~ regimen,
  site_capacity ~ urban,
  exposure = "regimen",
  outcome  = "success",
  labels = c(
    regimen       = "Regimen",
    success       = "Tx success",
    hiv           = "HIV status",
    nutrition     = "Nutrition (mediator)",
    site_capacity = "Site capacity",
    urban         = "Urban site"
  )
)

# Visualise with ggdag() -- status highlights exposure/outcome nodes
ggdag::ggdag(tb_dag, text = FALSE, use_labels = "label") +
  ggdag::theme_dag()

# Ask dagitty for the minimal sufficient adjustment set directly
adj_sets <- dagitty::adjustmentSets(tb_dag, exposure = "regimen", outcome = "success")
adj_sets
```

Running `adjustmentSets()` on this graph returns `{hiv, site_capacity}` as the minimal sufficient set — both are common causes of regimen *and* success, so both must be adjusted for to block confounding. Critically, `nutrition` is correctly *excluded* because it is a mediator, not a confounder (adjusting for it would block part of the regimen's true causal effect), and `ggdag::ggdag_adjustment_set()` will highlight the same two-variable set visually, which is a useful sanity check to pair with the programmatic answer.

```r
# Visual confirmation of the same adjustment set
ggdag::ggdag_adjustment_set(tb_dag, exposure = "regimen", outcome = "success",
                             text = FALSE, use_labels = "label") +
  ggdag::theme_dag()
```

#figure(
  image("../images/r_generated/ch15_dag_tb_regimen.png", width: 100%),
  caption: [Left: the TB regimen confounding DAG as encoded by `dagify()`. Right: `ggdag_adjustment_set()`'s visual confirmation that `{hiv, site_capacity}` is the minimal sufficient adjustment set — both coloured red as "adjusted" — while `nutrition` (a mediator) is correctly left unadjusted.]
) <fig-ch15-dag>

Once the adjustment set is settled by the DAG rather than by convenience, the question of *how* to report the resulting observational comparison is itself standardised. The *STROBE statement* (Strengthening the Reporting of Observational Studies in Epidemiology) — and its TREND and RECORD extensions for routinely collected and non-randomised data respectively — specifies a 22-item checklist covering exactly the design, confounding, and bias elements this section has walked through: how participants were selected, how confounders were identified and measured, how missing data were handled, and how potential biases were addressed, mapped item-by-item into the manuscript or dossier. Treat the STROBE checklist as a drafting template, not a post-hoc audit — filling it in alongside the DAG and target-trial protocol from §15.2, rather than after the analysis is finished, will save you from discovering a reporting gap only when a reviewer asks for it.

A final methodological note before we move into estimation proper: almost everything in this chapter — DAG-based adjustment set selection, propensity scores, inverse-probability weighting, and the target trial emulation machinery — is conventionally executed in a *frequentist* framework, and that is the default throughout the rest of this chapter. Bayesian causal inference exists and is occasionally useful, particularly when you want to propagate structural uncertainty (e.g., over which DAG is correct) into the final effect estimate, or when borrowing external control information as in Chapter 14's evidence-synthesis methods — but it is the exception reached for deliberately, not the default starting point, in applied RWE work.

#pitfall[
The single most damaging confounding error in practice is *adjusting for a collider*. If site-level treatment capacity is a common effect of both urban location and regional funding allocation, and you include it in a regression "because it's available and correlated with outcome," you can *induce* a spurious association between regimen and outcome where the true DAG has none. Always draw the DAG and run `dagitty::adjustmentSets()` before selecting covariates — never adjust for a variable solely because it is statistically associated with the outcome in a univariate check.
]

== 15.4 Propensity scores: matching, weighting, stratification (`MatchIt`, `WeightIt`, `cobalt`)

The propensity score, formally $e(x) = P(T=1 mid X=x)$, is the probability that a unit receives treatment given its observed covariates. Rosenbaum and Rubin's foundational insight was that conditioning on $e(x)$ — rather than on the full covariate vector $X$ — is sufficient to balance observed confounders between treated and untreated groups, provided the no-unmeasured-confounding assumption holds. For a TB-programme analyst this matters concretely: when you compare patients who received a new short-course regimen against those who stayed on the standard regimen in routine programme data, the two groups almost never look alike at baseline. Patients prescribed the new regimen might be healthier, more urban, or diagnosed earlier. The propensity score collapses all of that imbalance into a single number you can match, weight, or stratify on.

Three workhorse strategies use the propensity score once it is estimated (almost always by logistic regression, though machine-learning propensity models are increasingly common):

- _Matching_ pairs each treated unit with one or more control units with similar propensity scores, discarding unmatched units.
- _Weighting_ (inverse probability of treatment weighting, IPTW) reweights the full sample so that the weighted covariate distributions are balanced, keeping all units.
- _Stratification_ bins units into propensity-score strata (commonly quintiles) and estimates effects within strata before pooling.

=== Matching with MatchIt

`MatchIt::matchit()` is the standard tool. It estimates (or accepts) propensity scores and performs the matching in one call.

```r
library(MatchIt)
library(cobalt)

# tb_cohort: one row per patient, trt = 1 if new regimen, 0 if standard
m.out <- matchit(
  trt ~ age + bmi + hiv_status + smear_grade + district_urban,
  data   = tb_cohort,
  method = "nearest",      # nearest-neighbour matching
  distance = "glm",        # logistic-regression propensity score
  ratio  = 1,               # 1:1 matching
  caliper = 0.2             # max distance, in SD of logit(PS)
)

summary(m.out)              # balance before/after matching
matched_data <- match.data(m.out)   # retrieve matched sample with weights
```

`method = "nearest"` with a caliper is a reasonable default for TB programme comparisons with moderate sample sizes; `method = "full"` (full matching) or `method = "optimal"` can reduce discarded units when treated and control covariate distributions overlap poorly. Always inspect `summary(m.out)` for the standardized mean differences (SMDs) before and after matching — SMDs below 0.1 for every covariate is the conventional threshold for "good balance."

=== Weighting with WeightIt

Weighting retains the full sample (useful when programme data is already scarce, as TB cohorts often are) at the cost of being more sensitive to extreme propensity scores.

```r
library(WeightIt)

w.out <- weightit(
  trt ~ age + bmi + hiv_status + smear_grade + district_urban,
  data     = tb_cohort,
  method   = "ps",          # logistic-regression propensity score
  estimand = "ATE"          # average treatment effect (use "ATT" for effect on treated only)
)

tb_cohort$iptw <- w.out$weights
summary(w.out)
```

`estimand = "ATE"` weights treated units by $1/e(x)$ and controls by $1/(1-e(x))$; `estimand = "ATT"` instead weights controls by $e(x)/(1-e(x))$ and leaves treated units at weight 1, targeting the effect in the treated population specifically — often the more policy-relevant estimand when the new regimen will only ever be rolled out to patients similar to those who already got it.

=== Checking balance with cobalt

`cobalt` is the standard companion package for producing balance diagnostics and the now-ubiquitous "Love plot."

```r
library(cobalt)

bal.tab(w.out, un = TRUE, m.threshold = 0.1)   # table: unadjusted vs weighted SMDs

love.plot(
  w.out,
  binary   = "std",
  thresholds = c(m = 0.1),
  abs      = TRUE,
  var.order = "unadjusted"
)
```

`bal.tab()` prints standardized mean differences (and variance ratios for continuous covariates) before (`un = TRUE`) and after weighting; `love.plot()` renders the now-standard dot plot with a vertical reference line at the balance threshold, letting you see at a glance whether every covariate crossed under 0.1 after weighting.

#figure(
  image("../images/r_generated/ch15_love_plot.png", width: 85%),
  caption: [A love plot for a toy TB cohort (n = 600): absolute standardized mean differences before (red) and after (teal) inverse-probability-of-treatment weighting. Every covariate, including the propensity score itself, collapses from well above the conventional 0.1 threshold (dashed line) to effectively zero after weighting.]
) <fig-ch15-love-plot>

=== A worked numeric example: IPTW ATE by hand

To make the weighting arithmetic concrete — and to leave you something you can reproduce by hand before trusting any package output — consider a toy cohort of six TB patients with *known* propensity scores (in practice these come from the logistic model; here they are given so the downstream arithmetic is fully verifiable).

#heor-practice[
*Toy IPTW calculation.* Treatment outcome $Y$ is, say, time-to-culture-conversion in weeks (lower is better).

#report-table(
  [Toy cohort for inverse-probability-of-treatment weighting],
  academic-table(
    columns: (auto, auto, auto, auto, 1.6fr),
    align: (left, center, right, right, right),
    header: ([*Patient*], [*Treated ($T$)*], [*Outcome ($Y$)*], [*PS* $e(x)$], [*IPTW contribution*]),
    body: (
      [1], [1], [10], [0.5], [$1 times 10 / 0.5 = 20$],
      [2], [1], [8],  [0.4], [$1 times 8 / 0.4 = 20$],
      [3], [1], [12], [0.6], [$1 times 12 / 0.6 = 20$],
      [4], [0], [4],  [0.5], [$1 times 4 / (1-0.5) = 8$],
      [5], [0], [6],  [0.4], [$1 times 6 / (1-0.4) = 10$],
      [6], [0], [2],  [0.6], [$1 times 2 / (1-0.6) = 5$],
    ),
    footer: none,
  )
) <tab-ch15-iptw>

The IPTW estimator of the ATE is
$ hat(tau)_"IPTW" = 1/n sum_i (T_i Y_i)/(e(x_i)) - 1/n sum_i ((1-T_i) Y_i)/(1-e(x_i)) $

Summing the treated contributions: $20 + 20 + 20 = 60$, divided by $n=6$ gives a weighted treated mean of $10.000$.
Summing the control contributions: $8 + 10 + 5 = 23$, divided by $n=6$ gives a weighted control mean of $3.833$.

$ hat(tau)_"IPTW" = 10.000 - 3.833 = 6.167 "weeks" $

Notice the coincidence built into this toy example — each treated patient's contribution is exactly 20 — which is intentional: it shows that when $T_i Y_i / e(x_i)$ is constant across treated units, the weighted mean equals that constant regardless of sample size, a useful sanity check when debugging your own `weightit()` output against a hand calculation on a small subset.
]

```r
# Reproduce the hand calculation in R
toy <- data.frame(
  T  = c(1,1,1,0,0,0),
  Y  = c(10,8,12,4,6,2),
  ps = c(0.5,0.4,0.6,0.5,0.4,0.6)
)
mean(toy$T * toy$Y / toy$ps) - mean((1 - toy$T) * toy$Y / (1 - toy$ps))
#> 6.166667
```

#pitfall[
Extreme propensity scores (close to 0 or 1) produce extreme weights, which can make the IPTW estimator wildly unstable — a single near-zero $e(x)$ in the denominator can dominate the entire estimate. Always plot the distribution of weights (`summary(w.out$weights)`, or a histogram) before trusting an ATE. Trimming (dropping units with $e(x)$ outside, say, $[0.05, 0.95]$) or using *stabilized* weights (multiplying by the marginal probability of treatment) are standard remedies — `WeightIt::weightit()` supports `stabilize = TRUE` directly.
]

== 15.5 Doubly robust estimators and g-methods

Matching and weighting both lean entirely on the propensity-score model being correctly specified. Outcome regression leans entirely on the outcome model being correctly specified instead. Each method has exactly one place it can go wrong, and no backup if it does.

*Doubly robust* (DR) estimators remove that single point of failure. They combine both models so the estimate stays consistent if *either* the propensity model or the outcome model is correctly specified — not necessarily both. That is a meaningfully weaker assumption than either method alone requires, which is why DR methods have become close to a default in contemporary RWE causal analyses, including in regulatory submissions.

The best-known DR estimator is Augmented Inverse Probability Weighting (AIPW):

$ hat(tau)_"AIPW" = 1/n sum_i [ (T_i (Y_i - hat(m)_1(X_i)))/(hat(e)(X_i)) - ((1-T_i)(Y_i - hat(m)_0(X_i)))/(1-hat(e)(X_i)) + hat(m)_1 (X_i) - hat(m)_0(X_i) ] $

where $hat(m)_1(X)$ and $hat(m)_0(X)$ are outcome-regression predictions under treatment and control respectively, and $hat(e)(X)$ is the propensity score. The first bracketed pair is an IPW-weighted *residual correction*; the last pair is the plain outcome-regression estimate. If the outcome model is right, the residuals average to roughly zero and the estimate reduces to the (correct) regression estimate; if the propensity model is right, the IPW terms correct any bias in a misspecified outcome model.

```r
library(AIPW)
library(SuperLearner)

aipw_fit <- AIPW::AIPW$new(
  Y          = tb_cohort$culture_conversion_weeks,
  A          = tb_cohort$trt,
  W          = tb_cohort[, c("age","bmi","hiv_status","smear_grade","district_urban")],
  Q.SL.library = c("SL.glm", "SL.mean"),   # outcome model learners
  g.SL.library = c("SL.glm", "SL.mean"),   # propensity model learners
  k_split    = 10,
  verbose    = TRUE
)
aipw_fit$fit()$summary()
```

A lighter-weight alternative that stays entirely inside the `WeightIt`/regression toolchain, suited for a quick DR check without pulling in `SuperLearner`, is to fit an outcome regression on the IPTW-weighted sample (the "weighted regression" or "doubly robust regression" trick):

```r
library(WeightIt)

tb_cohort$iptw <- weightit(
  trt ~ age + bmi + hiv_status + smear_grade + district_urban,
  data = tb_cohort, method = "ps", estimand = "ATE"
)$weights

dr_fit <- lm(
  culture_conversion_weeks ~ trt + age + bmi + hiv_status + smear_grade + district_urban,
  data    = tb_cohort,
  weights = iptw
)
coef(summary(dr_fit))["trt", ]
```

This weighted-regression approach is doubly robust in the sense described above whenever the outcome model is linear and additive in treatment; `AIPW` or `tmle`/`tmle3` give the fully general nonparametric version.

=== G-methods

_G-methods_ — g-computation (the g-formula), marginal structural models fit by IPTW, and g-estimation of structural nested models — were developed by James Robins specifically to handle *time-varying treatment and time-varying confounding*, the situation where today's treatment affects tomorrow's confounder, which in turn affects tomorrow's treatment decision (a "treatment-confounder feedback" loop that standard regression adjustment cannot handle without introducing bias). This is directly relevant to TB programmes: a patient's adherence this month influences next month's sputum-smear result, which influences whether the clinician escalates or de-escalates therapy next month.

#difficult-terminology("marginal structural models")[
A marginal structural model asks a very specific causal question: "what would the outcome look like, on average across the whole population, if everyone followed a particular treatment strategy over time?" — e.g. "everyone stays on the standard regimen for the full six months" versus "everyone is escalated to the stronger regimen as soon as smear status worsens." Normally you'd worry that patients who got escalated were sicker to begin with, confounding any simple comparison. Marginal structural models handle this not by adding the time-varying confounder (smear status) directly into the outcome model — which, with treatment-confounder feedback, can itself introduce bias — but by *reweighting* each patient at each time point using inverse-probability-of-treatment weights (IPTW), so that, after reweighting, treatment at each visit looks "as good as randomly assigned" with respect to the confounders measured up to that point. It's analogous to the reweighting trick in Chapter 13's MAIC, but applied across repeated time points within the same patients rather than across two separate trials.
]

#difficult-terminology("g-estimation of structural nested models")[
G-estimation is a different route to the same time-varying-confounding problem that marginal structural models address, but instead of reweighting patients, it directly asks: "by how much would this patient's observed outcome have differed, at each decision point, had their treatment at that point been different from what they actually received?" It builds a "structural nested model" — a set of equations describing, step by step, how each treatment decision nudges the final outcome — and searches (iteratively, via an estimating-equation algorithm) for the parameter values that make the adjusted, counterfactual outcomes look unrelated to the observed treatment history, after accounting for measured confounders. It's more computationally involved than IPTW-weighted marginal structural models and used less often in applied HEOR work, but it avoids some of the extreme-weight instability that can plague IPTW when treatment is very predictable from the confounders.
]

G-computation in its simplest (time-fixed) form is conceptually just: (1) fit an outcome model including treatment and confounders, (2) predict the outcome for every unit *as if* everyone had been treated, (3) predict again *as if* no one had been treated, (4) the ATE is the difference of the two averaged predictions.

```r
# Simple (time-fixed) g-computation "by hand"
outcome_model <- lm(
  culture_conversion_weeks ~ trt + age + bmi + hiv_status + smear_grade + district_urban,
  data = tb_cohort
)

d1 <- d0 <- tb_cohort
d1$trt <- 1          # counterfactual: everyone treated
d0$trt <- 0          # counterfactual: no one treated

g_ate <- mean(predict(outcome_model, newdata = d1)) -
         mean(predict(outcome_model, newdata = d0))
g_ate
```

For genuinely time-varying treatment and confounding — multiple visits per patient, each with its own treatment decision and intermediate outcomes — the `gfoRmula` package implements the full longitudinal g-formula with Monte Carlo simulation of counterfactual trajectories, and `ipw::ipwtm()` fits marginal structural models via time-varying IPTW. These are advanced tools; flag them as the next step once your TB programme data includes repeated visits with a feedback loop between adherence, smear results, and regimen changes, rather than reaching for them on a single cross-sectional comparison.

#agency-note[
The FDA's 2023 draft guidance *"Considerations for the Use of Real-World Data and Real-World Evidence to Support Regulatory Decision-Making for Drug and Biological Products"*, together with the companion *"Real-World Data: Assessing Registries to Support Regulatory Decision-Making for Drug and Biological Products"* guidance, explicitly discusses doubly robust estimation and g-methods as acceptable approaches for addressing time-varying confounding in RWE submissions, and cross-references the ICH E9(R1) estimands framework for specifying *which* causal estimand (treatment-policy, hypothetical, principal stratum, etc.) the g-method or DR estimator is meant to target before any model is fit. Before running an AIPW or g-computation analysis intended to support a regulatory or HTA submission, write down the estimand in ICH E9(R1) language first — the choice of estimand constrains which intercurrent-event handling strategy (and therefore which g-method variant) is defensible.
]

#difficult-terminology("ICH E9(R1) estimand strategies + intercurrent events")[
Before you can estimate a "treatment effect," you have to pin down exactly what question you're asking — and in a real trial or RWE study, things inevitably go wrong partway through: patients drop out, switch to rescue medication, or die before the planned follow-up ends. These mid-study complications are called *intercurrent events*. ICH E9(R1) is the international regulatory guideline that formalises five standard strategies for defining a meaningful "treatment effect" question in the presence of such events. *Treatment-policy* counts whatever happens to the patient regardless of adherence or switching (closest to "real-world" pragmatic effect). *Hypothetical* asks what would have happened if the intercurrent event hadn't occurred at all (e.g. if no one had been allowed to switch treatment). *Composite* folds the intercurrent event itself into the outcome definition (e.g. counting treatment switch as a treatment failure). *While-on-treatment* only asks about the period before the intercurrent event happened. *Principal stratum* restricts the question to the subgroup of patients who would not have experienced the intercurrent event under either treatment. None of these is universally "correct" — they answer genuinely different clinical questions, and the right strategy depends on what decision-makers actually need to know; the mistake to avoid is picking one implicitly, by whichever analysis method happens to be convenient, rather than choosing deliberately and stating it upfront.
]

== 15.6 Instrumental variables and regression discontinuity

Propensity-score and DR methods all assume *no unmeasured confounding*: every variable that affects both treatment assignment and the outcome is observed and included in the model. That assumption can fail badly in TB programme data — e.g., clinician "gut feel" about disease severity may drive both regimen choice and prognosis without appearing in any recorded field. Instrumental variables (IV) and regression discontinuity (RD) are the two classic quasi-experimental designs that can recover a causal effect *even in the presence of unmeasured confounding*, by exploiting a specific source of "as-good-as-random" variation in treatment.

=== Instrumental variables

An instrument $Z$ is a variable that (i) affects treatment $T$, (ii) affects the outcome $Y$ *only through* $T$ (the exclusion restriction), and (iii) is independent of unmeasured confounders. A classic TB-programme instrument is distance to the nearest facility offering the new diagnostic/regimen, or facility-level rollout timing driven by a supply allocation that is unrelated to individual patient severity: patients don't choose which facility rolled out first, but facility rollout strongly predicts whether an individual patient received the new regimen.

Two-stage least squares (2SLS) is the standard estimator, implemented identically in `ivreg::ivreg()` (from the `ivreg` package) and `AER::ivreg()` (an older alias from the Applied Econometrics with R package — both use the same `|`-separated formula syntax):

```r
library(ivreg)

iv_fit <- ivreg(
  culture_conversion_weeks ~ trt + age + bmi + hiv_status |     # structural equation
                              facility_rollout_quarter + age + bmi + hiv_status, # instruments + exogenous covariates
  data = tb_cohort
)
summary(iv_fit, diagnostics = TRUE)
```

The `diagnostics = TRUE` argument is essential: it reports the *weak-instrument (first-stage F) test*, the Wu-Hausman endogeneity test, and the Sargan over-identification test (when you have more instruments than endogenous regressors). A first-stage F-statistic below roughly 10 is the conventional (if debated) threshold for flagging a "weak instrument," below which 2SLS estimates become unreliable and badly biased toward the plain OLS estimate.

#difficult-terminology("endogeneity / endogenous variable")[
A variable is called "endogenous" when it isn't truly independent of the thing that's also driving the outcome — in plain terms, something else (often unmeasured) is influencing both the treatment a patient receives *and* their prognosis, so the treatment variable is partly a stand-in for that hidden factor rather than a clean, as-good-as-randomised input. Picture a clinician who informally senses a patient is sicker than any recorded field captures, and on that gut feeling escalates them to a stronger regimen: the regimen choice is now tangled up with unmeasured severity, and a plain regression of outcome on regimen will attribute some of that unmeasured severity's effect to the regimen itself, biasing the estimate. This is exactly the problem instrumental variables are built to sidestep, by finding a source of variation in treatment (the instrument) that isn't contaminated by that same hidden confounding.
]

#difficult-terminology("Wu-Hausman test")[
This test directly checks whether endogeneity is actually a real, practically important problem for your data, rather than something to worry about in the abstract. It compares the plain OLS regression estimate against the instrumental-variables (2SLS) estimate of the same effect: if treatment were not endogenous, the two should give similar answers (because OLS would already be unbiased, and IV would just be a noisier way of getting the same answer). A statistically significant Wu-Hausman result means the two estimates disagree by more than chance would explain — evidence that the plain OLS estimate is likely biased by unmeasured confounding, and that you should trust the instrumental-variables estimate instead, despite it usually having a wider confidence interval.
]

#difficult-terminology("Sargan (over-identification) test")[
This check is only possible when you have *more* instruments than strictly needed (e.g. two separate instruments for one endogenous treatment variable, when one would technically suffice) — hence "over-identified." The idea: if all your instruments are genuinely valid (each satisfying the exclusion restriction), then every possible combination of them should point to roughly the same causal effect. The Sargan test checks whether that's actually true, by seeing whether the instruments as a group produce internally consistent results. A significant Sargan test is a warning sign that at least one of your instruments may not be valid — though it can't tell you *which* one, only that something in the set is inconsistent with the others.
]

#report-table(
  [Illustrative IV diagnostics output structure from `summary(iv_fit, diagnostics = TRUE)`],
  academic-table(
    columns: (1.4fr, auto, auto, 2.4fr),
    align: (left, center, center, left),
    header: ([*Diagnostic*], [*df1*], [*df2*], [*Interpretation*]),
    body: (
      [Weak instruments], [1], [n-k], [F-stat $> 10$: instrument strong enough],
      [Wu-Hausman], [1], [n-k], [Significant: $T$ is endogenous, IV needed over OLS],
      [Sargan], [--], [--], [Only with more than 1 instrument; tests exclusion restriction],
    ),
    footer: none,
  )
) <tab-ch15-ivdiag>

#pitfall[
The exclusion restriction — that $Z$ affects $Y$ *only* through $T$ — is never fully testable from data alone and must be argued substantively. "Facility rollout timing" fails as an instrument if rollout was itself prioritized toward facilities with sicker patients (then it affects $Y$ directly through facility-level case mix, not only through individual treatment). Always describe, in words, the mechanism that could violate exclusion, and check whether it is institutionally plausible for your specific rollout — a statistically "strong" instrument (high first-stage F) with an implausible exclusion restriction is still a bad instrument.
]

=== Regression discontinuity

RD designs exploit a sharp, known threshold rule for assigning treatment: units just above the cutoff get treated, units just below do not, and — assumption-wise — units just either side of the cutoff are otherwise comparable. A natural TB-programme RD arises when national guidelines mandate the new regimen only for patients with a sputum bacterial load or a CD4 count below a specific cutoff; comparing outcomes for patients just above versus just below that cutoff approximates a local randomized experiment.

`rdrobust::rdrobust()` is the standard, well-validated implementation (local-polynomial estimation with automatic, data-driven bandwidth selection and robust bias-corrected confidence intervals):

```r
library(rdrobust)

rd_fit <- rdrobust(
  y = tb_cohort$culture_conversion_weeks,
  x = tb_cohort$cd4_count,
  c = 200                     # the policy cutoff: CD4 < 200 mandates new regimen
)
summary(rd_fit)

rdplot(
  y = tb_cohort$culture_conversion_weeks,
  x = tb_cohort$cd4_count,
  c = 200
)
```

`rdrobust()` reports three estimates (conventional, bias-corrected, and robust), and the robust bias-corrected confidence interval is the one you should report — it accounts for the fact that the optimal bandwidth for point estimation is not the optimal bandwidth for inference. `rdplot()` produces the canonical RD scatter-with-binned-means-and-fitted-lines figure that should accompany every RD analysis, so a reviewer can see the jump at the cutoff directly rather than trusting the number alone.

#figure(
  image("../images/r_generated/ch15_rd_plot.png", width: 85%),
  caption: [`rdrobust::rdplot()` output for the CD4-count RD example: culture conversion time against CD4 count, with the policy cutoff at CD4 = 200 marked by the vertical line. The fitted local-polynomial curves on either side show a visible downward jump just below the cutoff, where the new regimen becomes mandated.]
) <fig-ch15-rd-plot>

#pitfall[
RD estimates are *local*: the effect is identified only for patients near the cutoff (CD4 close to 200 in the example), and should never be extrapolated to patients far from it (e.g., CD4 of 50 or 600) without additional structural assumptions. Always run `rdrobust`'s built-in manipulation/density check (`rddensity` package) to confirm patients were not able to manipulate which side of the cutoff they landed on — in a TB programme, a clinician who knows the CD4 threshold and orders a repeat test for a borderline patient to secure the new regimen would silently invalidate the whole design.
]

== 15.7 Difference-in-differences and interrupted time series

The final pair of designs in this section uses *time* as the source of quasi-experimental leverage, comparing outcomes before and after an intervention, either against a comparison group that did not receive the intervention (difference-in-differences) or purely through the pre/post trajectory itself (interrupted time series).

=== Difference-in-differences (DiD)

Classic two-group, two-period DiD estimates the treatment effect as the difference in each group's own pre-to-post change:

$ hat(tau)_"DiD" = (overline(Y)_"treated, post" - overline(Y)_"treated, pre") - (overline(Y)_"control, post" - overline(Y)_"control, pre") $

This is naturally implemented as a two-way fixed effects (TWFE) regression with a treatment-by-post interaction term:

```r
did_fit <- lm(
  culture_conversion_weeks ~ treated_district * post_rollout + age + bmi,
  data = district_panel
)
summary(did_fit)
# coefficient on treated_district:post_rollout IS the DiD estimate
```

#difficult-terminology("two-way fixed effects (TWFE)")[
"Fixed effects" here just means: give every district its own intercept adjustment, and every time period its own intercept adjustment, so that each comparison is effectively made relative to that specific district's own average level and that specific period's own average level, rather than lumping everyone together on a single shared baseline. "Two-way" means both of those adjustments (district and time) are included simultaneously. Practically, this is a tidy way of controlling for anything constant about a district (e.g. its baseline healthcare infrastructure) and anything constant across districts within a time period (e.g. a national supply shortage that quarter) without having to measure and name those confounders explicitly — the fixed effects soak them up automatically. The catch, raised in the next paragraph, is that once treatment rolls out to different districts at different times (staggered adoption), this simple two-way structure starts implicitly comparing some already-treated districts against each other as if one were a valid "control" for the other, which can badly distort the estimated effect — hence the shift to purpose-built staggered-adoption estimators like `did::att_gt()`.
]

The identifying assumption is *parallel trends*: absent the intervention, the treated district(s) would have followed the same *trend* as the control district(s) — not the same level, just the same trajectory. This is checked, never assumed, by plotting pre-intervention outcome trends for both groups and/or by testing for pre-trend differences in an event-study specification (leads and lags of the treatment indicator).

```r
library(ggplot2)
ggplot(district_panel, aes(quarter, culture_conversion_weeks, color = treated_district)) +
  stat_summary(geom = "line") +
  geom_vline(xintercept = rollout_quarter, linetype = "dashed")
```

When rollout is *staggered* across many districts at different times — the realistic case for a phased national TB programme rollout — naïve TWFE regression is now well known to produce badly biased estimates (the "negative weighting" problem documented by Goodman-Bacon and others), because it implicitly compares already-treated districts against each other as pseudo-controls. The modern fix is the `did` package's group-time average treatment effects:

```r
library(did)

atts <- att_gt(
  yname    = "culture_conversion_weeks",
  tname    = "quarter",
  idname   = "district_id",
  gname    = "rollout_quarter",     # period each district FIRST adopted the new regimen (0/Inf for never-treated)
  data     = district_panel,
  control_group = "nevertreated"     # or "notyettreated"
)

agg_simple <- aggte(atts, type = "simple")   # single overall ATT
summary(agg_simple)

agg_dyn <- aggte(atts, type = "dynamic")     # event-study style, by time since rollout
ggdid(agg_dyn)
```

`att_gt()` estimates a separate average treatment effect for every (group, time) pair defined by *when* a district first adopted, then `aggte()` aggregates those into either a single summary number or a dynamic event-study plot, avoiding the staggered-adoption bias of plain TWFE entirely.

#figure(
  image("../images/r_generated/ch15_did_event_study.png", width: 85%),
  caption: [`did::ggdid()` output for a simulated staggered-rollout TB programme: group-time average treatment effects by quarters since rollout (negative x-axis = pre-treatment, positive = post). Pre-treatment estimates hover around zero with overlapping confidence intervals (supporting the parallel-trends assumption), while post-treatment estimates show a consistent negative effect on culture conversion time.]
) <fig-ch15-did-event-study>

#heor-practice[
*Practical rule of thumb.* If every treated unit in your rollout switched on the same calendar date (a single national go-live), plain TWFE DiD is fine. If adoption is staggered across districts/facilities — almost always true of a phased national rollout — default to `did::att_gt()` rather than TWFE, even if the TWFE coefficient "looks reasonable"; the bias from staggered TWFE can be large enough to flip the sign of the estimated effect.
]

=== Interrupted time series (ITS)

ITS designs use a *single* series — typically an aggregate programme-level outcome measured repeatedly over time, such as monthly treatment-success rate — and ask whether its level and/or slope changed at the moment of an intervention, with no separate control group required (though a control series strengthens inference considerably when available, turning ITS into a comparative/controlled ITS).

Segmented (piecewise) linear regression is the standard specification:

```r
library(segmented)

its_base <- lm(success_rate ~ month, data = monthly_tb_outcomes)

its_seg <- segmented(
  its_base,
  seg.Z = ~ month,
  psi   = intervention_month        # known breakpoint: the rollout month
)
summary(its_seg)
slope(its_seg)         # slope before vs after the breakpoint
```

Alternatively, when the breakpoint (intervention timing) is known with certainty — the far more common and more defensible case, since programme rollout dates are typically documented rather than estimated — fit the level-and-slope-change model directly rather than letting `segmented()` search for the breakpoint:

```r
monthly_tb_outcomes$post   <- as.integer(monthly_tb_outcomes$month >= intervention_month)
monthly_tb_outcomes$time_since <- pmax(0, monthly_tb_outcomes$month - intervention_month)

its_fit <- lm(
  success_rate ~ month + post + time_since,   # level-change (post) and slope-change (time_since) terms
  data = monthly_tb_outcomes
)
summary(its_fit)
# coefficient on "post" = immediate level change at intervention
# coefficient on "time_since" = change in slope after intervention
```

#pitfall[
Autocorrelation in time series residuals inflates apparent precision and will make an ITS effect look far more statistically significant than it is. Check residual autocorrelation (`acf(residuals(its_fit))`) and, if present, re-fit with Newey-West or autocorrelation-consistent standard errors (`lmtest::coeftest(its_fit, vcov = sandwich::NeweyWest(its_fit))`) rather than trusting the plain `lm()` standard errors. Also watch for seasonality in monthly programme data (e.g., a recurring dip around the monsoon season affecting case detection) being mistaken for an intervention effect if the breakpoint happens to coincide with a seasonal transition.
]

#agency-note[
NICE's *"NICE real-world evidence framework"* (2022) explicitly names difference-in-differences and interrupted time series among the quasi-experimental designs it considers acceptable supporting evidence for technology appraisals when randomized data are unavailable, provided the parallel-trends or pre-intervention-trend assumption is explicitly tested and reported, not merely asserted. When writing up a DiD or ITS analysis of programme data for an HTA submission, structure the results section around that framework's expectation: show the pre-period trend check first, then the point estimate, then a sensitivity analysis varying the comparison group or breakpoint specification.
]

== 15.8 Treatment switching and crossover adjustment (RPSFTM, IPCW)

Oncology and TB trials alike have a recurring headache: patients randomised to the control arm are allowed — often for good ethical reason — to cross over to the experimental treatment once they progress or fail first-line therapy. A placebo-controlled trial of a new multidrug-resistant (MDR-TB) regimen that permits crossover to the novel drug after treatment failure is common practice, and it is the right thing to do for patients. It is also a statistical headache for anyone trying to estimate what survival or treatment-success *would have been* had nobody switched — which is almost always the estimand a reimbursement body wants, because list prices and model structures are built around "control arm never gets the new drug."

A naive intention-to-treat (ITT) analysis of overall survival or time-to-cure under this design is unbiased for the policy actually implemented (randomise-and-allow-switch), but it systematically understates the treatment effect that would be observed under strict, no-crossover randomisation — which is usually the question of interest for a HEOR submission. HTA bodies increasingly expect sponsors to present both the ITT estimate and an adjusted estimate that attempts to remove the dilution caused by switching. The two workhorse methods are the *rank-preserving structural failure time model (RPSFTM)* and *inverse probability of censoring weights (IPCW)*.

RPSFTM assumes a common treatment effect multiplier $psi$ such that each patient's counterfactual "time off randomised arm's active treatment" is rescaled by $exp(psi)$, regardless of when the switch happened — it is a structural, not a regression, model, and it preserves the rank ordering of patients' latent event times under the null. It is robust to time-dependent confounding by design (it does not require measuring the confounders that triggered switching), but it depends on a strong "common treatment effect" assumption and performs poorly when switching is driven by severity that itself predicts the outcome independent of treatment. IPCW instead treats the problem as an informative-censoring problem: patients who switch are artificially censored at the time of switching, and the remaining follow-up is reweighted by the inverse probability of *not yet having switched*, conditional on time-varying prognostic covariates. IPCW requires you to have actually measured and modelled the covariates driving the switch — if an unmeasured factor (say, a clinician's informal read of deteriorating sputum smear trends) drives both switching and survival, IPCW is biased in the same direction as the naive analysis, only less so.

#agency-note[
The definitive methods reference here is the NICE Decision Support Unit's Technical Support Document on treatment switching, usually cited as NICE DSU TSD 16, "Adjusting Survival Time Estimates in the Presence of Treatment Switching" (Latimer and Abrams). It walks through RPSFTM, IPCW, and the two-stage estimation method with worked derivations and recommends which to use depending on whether switching is driven by observed time-varying covariates (favour IPCW) or not (favour RPSFTM), and under what circumstances neither is defensible. Any NICE submission involving crossover-adjusted survival should reference this TSD explicitly in the statistical analysis plan, not just cite the general RPSFTM/IPCW literature.
]

*RPSFTM in R.* There is a maintained CRAN package, `rpsftm` (Simon Bond), that implements the standard rank-preserving structural failure time model for a single survival endpoint with simple, one-way, timing-recorded switching. It is the right starting point and saves you from re-deriving the g-estimation search over $psi$ by hand. It does not, however, cover every design variant the literature discusses (e.g. two-way switching, re-switching, or models that jointly adjust multiple competing-risk endpoints) — for those you are back to hand-coding the structural model, in the same spirit as the hand-coded MAIC weighting discussed in Chapter 13. Treat `rpsftm` as a solid implementation of the textbook case, and verify its assumptions hold before trusting it on a more exotic design.

```r
library(rpsftm)
library(survival)

# df has: time (observed), event, arm (0=control,1=experimental),
# rx (proportion of follow-up time actually on experimental treatment),
# plus switching indicator baked into rx for control-arm switchers
fit_rpsftm <- rpsftm(
  Surv(time, event) ~ rand(arm, rx),
  data = df,
  censor_time = admin_censor_time,  # administrative censoring time per patient
  n_eval_z = 100
)

summary(fit_rpsftm)
# psi: the estimated causal log-time-ratio
# Recreate a counterfactual, switching-adjusted Kaplan-Meier using
# fit_rpsftm$Sstar (the re-derived "as randomised, no switching" times)
counterfactual_fit <- survfit(Surv(fit_rpsftm$Sstar, event) ~ arm, data = df)
plot(counterfactual_fit, col = c("grey40", "steelblue"), lwd = 2,
     xlab = "Time (months)", ylab = "Survival probability")
```

*IPCW in R.* The `ipcwswitch` package (Louis Y et al.) is a real, CRAN-maintained package built specifically for treatment-switching adjustment via IPCW, including time-varying confounder handling and the data-reshaping steps needed to go from clinical-trial-visit format to the long counting-process format the weighted Cox model needs. It is less of a one-line black box than `rpsftm`: expect to spend real effort specifying the switching model (what predicts switching at each visit) and checking weight stability before trusting the output.

```r
library(ipcwswitch)
library(survival)

# long_df: one row per patient-visit, with time-varying covariates
# (ecog_status, sputum_grade, weight_kg) measured at each visit, and
# a per-visit switch indicator
long_df <- ipcw.data(
  long_df,
  id.name     = "patient_id",
  tstart.name = "visit_start",
  tstop.name  = "visit_stop",
  event.name  = "event",
  bas.cov     = c("age", "baseline_ecog", "site"),
  dyn.cov     = c("ecog_status", "sputum_grade", "weight_kg"),
  switch.name = "switched_this_visit"
)

ipcw_weights <- ipcw.est(
  long_df,
  formula.denom = switched_this_visit ~ ecog_status + sputum_grade + weight_kg,
  formula.num   = switched_this_visit ~ 1,
  id.name = "patient_id", tstart.name = "visit_start", tstop.name = "visit_stop"
)

weighted_cox <- coxph(
  Surv(visit_start, visit_stop, event) ~ arm,
  data = long_df, weights = ipcw_weights$weights, cluster = patient_id
)
summary(weighted_cox)

# Always check the weight distribution before trusting the estimate
summary(ipcw_weights$weights)
hist(ipcw_weights$weights, breaks = 50,
     main = "IPCW weight distribution -- check for extreme tails")
```

#pitfall[
Both methods are routinely misapplied by running them once, reporting the single resulting hazard ratio, and moving on. Three checks are non-negotiable before you put an RPSFTM- or IPCW-adjusted estimate into a cost-effectiveness model: (1) for RPSFTM, inspect whether the "common treatment effect" assumption is remotely plausible — if switchers and non-switchers in the control arm look like different populations at baseline, it probably is not; (2) for IPCW, plot the weight distribution — a handful of weights above 10-20 means a handful of patients are silently driving the whole adjusted estimate, and the standard errors from a naive `coxph` call will be too small (use robust/cluster variance, as shown above); (3) for either method, report the ITT estimate alongside the adjusted one and let the HTA committee see both — presenting only the adjusted, larger effect without the unadjusted comparator reads as cherry-picking even when the adjustment is methodologically sound.
]

== 15.9 E-values and quantitative bias analysis

Every observational HEOR analysis — propensity-matched comparisons, instrumental variable estimates, even the RWE arm of an indirect comparison — rests on one untestable assumption: no unmeasured confounder is distorting the association. Quantitative bias analysis (QBA) asks that question explicitly and numerically: how strong would an unmeasured confounder have to be to explain away this result? The *E-value*, introduced by VanderWeele and Ding (2017), is the most widely adopted single-number answer. It is the minimum strength of association, on the risk-ratio scale, that an unmeasured confounder would need with *both* the exposure and the outcome — beyond the measured covariates — to fully explain away an observed association.

An E-value of 1.5 means a fairly weak unmeasured confounder could plausibly account for the whole effect — treat the finding as fragile. An E-value of 8 means an unmeasured confounder would need an implausibly strong, double-sided association to explain the result away — a much more robust finding. The appeal of the E-value in HEOR practice is that it converts a diffuse methodological worry ("but what about unmeasured confounding?") into a single number a non-statistician reviewer on an HTA committee can weigh against subject-matter plausibility: is it plausible that an unmeasured factor in this TB cohort — say, undocumented nutritional status or informal treatment adherence — has an association of that magnitude with both drug exposure and mortality? Often the answer is "no, that would be an extraordinarily strong confounder," which is reassuring; sometimes the answer is "yes, easily," which should make everyone more cautious about the point estimate.

The `EValue` package on CRAN (maintained by the original VanderWeele/Ding/Mathur group) implements the calculations directly, with functions tailored to each effect-measure scale, since the E-value formula differs depending on whether you start from a risk ratio, odds ratio, hazard ratio, or a continuous (OLS) effect size.

```r
library(EValue)

# Risk ratio example: an observational comparison found RR = 1.8 for
# default-vs-treatment-success, 95% CI 1.3 to 2.5, comparing two regimens
ev_rr <- evalues.RR(est = 1.8, lo = 1.3, hi = 2.5)
ev_rr

# Odds ratio from a logistic model of treatment success
ev_or <- evalues.OR(est = 2.1, lo = 1.4, hi = 3.2, rare = TRUE)
# rare = TRUE converts OR to an RR approximation when outcome prevalence < ~15%

# Hazard ratio from a Cox model of time-to-cure
ev_hr <- evalues.HR(est = 0.65, lo = 0.48, hi = 0.88, rare = FALSE)

# Continuous outcome (e.g. change in a quality-of-life score) from OLS
ev_ols <- evalues.OLS(
  est = 4.2, se = 1.1, sd = 9.8,  # coefficient, its SE, and outcome SD
  true = 0  # null value being tested against
)
```

Each call returns both the E-value for the point estimate and the E-value for the confidence-interval bound closest to the null — the second number is usually the more conservative, decision-relevant one, since it answers "how strong a confounder would be needed to make even the *most cautious* end of my interval non-significant?"

For a submission, it is worth tabulating E-values across the key endpoints and model specifications rather than reporting a single number in prose, so a reviewer can see at a glance which findings are robust and which are fragile.

#report-table(
  [E-values for key endpoints, illustrative MDR-TB regimen comparison],
  academic-table(
    columns: (1.8fr, 1.6fr, auto, auto),
    align: (left, left, right, right),
    header: ([*Endpoint*], [*Effect estimate*], [*E-value (point)*], [*E-value (CI limit)*]),
    body: (
      [Treatment success (OR)], [2.10 (1.40, 3.20)], [3.64], [2.13],
      [Time to culture conversion (HR)], [0.65 (0.48, 0.88)], [2.05], [1.53],
      [Grade 3+ adverse event (RR)], [1.80 (1.30, 2.50)], [3.00], [1.99],
      [Mean weight gain at 6mo (OLS)], [4.2 kg (SE 1.1)], [2.88], [1.86],
    ),
    footer: none,
  )
) <tab-ch15-evalues>

Reading that table, the treatment-success and adverse-event findings have reasonably robust E-values even at the conservative CI-limit end (around 2), while the culture-conversion hazard ratio's CI-limit E-value of 1.53 is the one worth flagging to the committee as more sensitive to unmeasured confounding than the headline point estimate suggests.

#heor-practice[
E-values do not replace a proper sensitivity analysis, and they say nothing about *whether* an unmeasured confounder of that strength actually exists — only about the magnitude required. Pair the E-value with a short qualitative argument grounded in the clinical setting: for a TB programme comparison, is there a plausible unmeasured factor (health-seeking behaviour, nutritional status, informal regimen substitution at peripheral facilities) that could realistically reach the required strength of association with both exposure and outcome? If a clinical co-author can confidently say "no candidate confounder in this setting is remotely that strong," the E-value becomes a persuasive robustness statement rather than a statistical decoration. If they hesitate, that hesitation is itself useful information for the write-up.
]

== 15.10 OHDSI/OMOP workflows in R

Most of this chapter has assumed you already have a tidy analysis-ready dataset — one row per patient, clean dates, a `survival::Surv()` object waiting to be fit. Real-world claims and EHR data almost never arrive that way, and a large, genuinely global effort has grown up around standardising how such data gets structured before analysis: the *Observational Health Data Sciences and Informatics (OHDSI)* collaborative and its *OMOP Common Data Model (CDM)*. If you ever work with a multi-country claims database, a hospital EHR warehouse, or a federated network study, there is a reasonable chance the data has already been (or will need to be) mapped into OMOP CDM — a standardised relational schema with fixed tables (`person`, `condition_occurrence`, `drug_exposure`, `visit_occurrence`, and so on) and standardised vocabularies (SNOMED, RxNorm, LOINC) so that analytic code written once can, in principle, run unchanged against a hospital database in Seoul and a claims database in the United States.

The OHDSI R ecosystem is built in layers, each with a genuinely maintained, actively developed package:

- `DatabaseConnector` handles the low-level connection to whatever RDBMS actually stores the OMOP CDM (PostgreSQL, SQL Server, Redshift, BigQuery, Oracle), abstracting away vendor-specific SQL dialects via SqlRender underneath.
- `FeatureExtraction` turns raw OMOP tables into analysis-ready covariate matrices — demographics, comorbidity flags, prior drug exposure counts — using pre-built "covariate settings" rather than hand-written SQL for every variable.
- `CohortMethod` runs the standard new-user comparative cohort design (think: a propensity-score-matched or -weighted comparison of two drug exposure cohorts) end to end, from cohort definition through outcome model fitting, following the OHDSI network-study conventions.

```r
library(DatabaseConnector)
library(FeatureExtraction)
library(CohortMethod)

connection_details <- createConnectionDetails(
  dbms             = "postgresql",
  server           = "cdm-server.example.org/omop_cdm",
  user             = Sys.getenv("OMOP_DB_USER"),
  password         = Sys.getenv("OMOP_DB_PASSWORD"),
  port             = 5432
)

# Define covariate settings: demographics + comorbidity history
covariate_settings <- createDefaultCovariateSettings(
  addDescendantsToExclude = TRUE
)

# Cohorts 1 (target drug) and 2 (comparator) must already exist as
# cohort_definition_id values in a cohort table built upstream
# (via ATLAS or hand-written cohort-definition SQL against OMOP tables)
cm_data <- getDbCohortMethodData(
  connectionDetails    = connection_details,
  cdmDatabaseSchema    = "omop_cdm",
  targetId             = 1,
  comparatorId         = 2,
  outcomeIds           = 3,     # e.g. treatment failure / default
  cohortDatabaseSchema = "results_schema",
  cohortTable          = "cohort",
  covariateSettings    = covariate_settings
)

ps_model <- createPs(cohortMethodData = cm_data)
matched_pop <- matchOnPs(ps_model, maxRatio = 1)

outcome_model <- fitOutcomeModel(
  population = matched_pop,
  cohortMethodData = cm_data,
  outcomeId = 3,
  modelType = "cox"
)
summary(outcome_model)
```

This is a substantial step up in infrastructure from the single-flat-file analyses elsewhere in this book, and it is worth being candid about when it is and is not the right tool. If you are running a one-off analysis of a single already-extracted dataset, standing up `DatabaseConnector`/`CohortMethod` against a live OMOP instance is almost certainly overkill — the earlier chapters' direct-dataframe workflows will get you to the same propensity-matched Cox model faster. The OHDSI stack earns its complexity when you need *reproducibility across sites* — a federated network study spanning several country-level TB or HIV surveillance databases, where the same analysis code genuinely has to run, unmodified, against structurally different source systems. Converting a bespoke national TB registry into OMOP CDM is itself a non-trivial ETL project (the OHDSI community's "Rabbit-in-a-Hat" / White Rabbit tooling helps, but mapping local vocabularies to standard concepts is still substantial domain work), so weigh that upfront cost against the actual need for cross-site standardisation before committing to it.

#pitfall[
A common mistake with `CohortMethod` output is treating the within-database, single-site effect estimate as automatically generalisable, simply because the pipeline *looks* standardised. OMOP CDM standardises the *data structure and vocabulary*, not the underlying population, prescribing patterns, or coding practices at each site. A network study pooling results across five databases still needs the same scrutiny of comparability, residual confounding, and effect heterogeneity across sites that any multi-country RWE synthesis would — the OHDSI tooling makes the mechanics of running the same analysis everywhere easy; it does not make the resulting estimates automatically poolable or automatically externally valid to a setting (such as a high-burden, low-resource TB programme) that may look nothing like the health systems contributing data to the source databases.
]

== 15.11 Using external control arms and synthetic control arms

Single-arm trials are increasingly common in rare-disease and some oncology development, and the logic extends naturally to settings like a novel TB regimen trial run under compassionate-use or expanded-access protocols, where randomising a concurrent control arm is ethically or operationally impractical. The regulatory and HTA question that follows is unavoidable: compared to what? An *external control arm (ECA)* answers that by assembling a comparator cohort from a source other than the trial itself — a registry, a previous trial's control arm, real-world claims or EHR data, or a historical cohort — and comparing the single-arm trial's outcomes against it. A *synthetic control arm* is a particular, more formal construction of an ECA: rather than simply selecting "similar" historical patients, it builds the comparator as a weighted combination of external units (and sometimes pre-treatment outcome trajectories) explicitly chosen so that the synthetic cohort's observed characteristics, and ideally its outcome trajectory, closely track what the trial's intervention arm looked like *before* treatment — the Abadie/Diamond/Hainmueller synthetic control method from econometrics, and its clinical adaptations, generalise the comparative-case-study idea to a clinical comparator.

Both approaches face the same fundamental threat that randomisation exists to neutralise: the external cohort was never subject to the same allocation mechanism as the trial arm, so any difference in outcomes is a tangle of true treatment effect and systematic differences in who ended up in which cohort — differences in era (standard of care drifts over a decade), in setting (a well-resourced referral hospital's historical cohort versus a multi-country trial's recruiting sites), in measurement (different diagnostic criteria, different definitions of "cure"), and in unmeasured patient selection (who gets referred, who gets excluded, who survives to be included in a registry at all). The statistical toolkit for narrowing that gap is the same one introduced in Chapter 12 for indirect comparisons — propensity score matching or weighting the external cohort to the trial population on measured baseline covariates — but it inherits the same core limitation: it can only balance what was actually measured comparably in both sources, and registry or claims data are rarely measured as rigorously or completely as a trial case report form.

```r
library(survival)
library(MatchIt)

# combined_df: trial arm (source == "trial") stacked with an external
# registry cohort (source == "registry"), harmonised on shared baseline
# covariates measured comparably in both sources
combined_df$is_trial <- as.integer(combined_df$source == "trial")

match_model <- matchit(
  is_trial ~ age + baseline_ecog + extent_of_disease + prior_regimens,
  data   = combined_df,
  method = "nearest",
  ratio  = 2  # up to 2 external controls matched per trial patient
)

matched_data <- match.data(match_model)

eca_fit <- coxph(
  Surv(time, event) ~ is_trial,
  data    = matched_data,
  weights = weights  # matching weights from MatchIt
)
summary(eca_fit)

# Always report the covariate balance achieved by the match before
# trusting the comparative estimate
summary(match_model)
```

Because no CRAN package markets itself specifically as "the synthetic control arm for clinical trials" tool, in practice sponsors either adapt general-purpose econometric synthetic control packages (such as `Synth` or the newer `tidysynth`, both built for panel-data comparative case studies rather than clinical cohorts and requiring real adaptation of the outcome-trajectory-matching logic) or build the weighting and balance-checking pipeline by hand from `MatchIt`, `WeightIt`, or `cobalt`, in much the same spirit as the hand-coded MAIC and the `rpsftm` edge cases discussed earlier. Do not expect to find a single, clinically-validated, point-and-click CRAN package that performs a defensible synthetic control arm construction end to end — the statistical judgment about covariate selection, era-matching, and outcome-trajectory comparability is the genuinely hard, non-automatable part of the exercise.

#agency-note[
The FDA's 2023 draft guidance, "Considerations for the Design and Conduct of Externally Controlled Trials for Drug and Biological Products," is the current authoritative regulatory reference on when an external control arm is an acceptable substitute for a concurrent randomised control, what data quality and comparability standards it expects of the external source, and how sponsors should pre-specify the analytic approach (propensity methods, sensitivity analyses for unmeasured confounding, and the role of E-values of the kind introduced in §15.9) before seeing outcome data. Any HEOR team proposing an external or synthetic control arm for a regulatory or HTA submission should read this guidance directly rather than relying on secondary summaries, since it is explicit about the scenarios (small, well-characterised natural history; large, unambiguous treatment effect) where FDA considers the design most defensible, and equally explicit about where it is skeptical.
]

#pitfall[
The single most common failure mode in external control arm analyses submitted for HTA review is presenting the propensity-matched comparison as if matching had resolved all comparability concerns, without separately addressing *temporal* comparability. A registry cohort treated five or ten years before the single-arm trial recruited is not just a different sample of patients — it reflects an entirely different standard of supportive care, diagnostic practice, and often a different definition of the outcome itself (TB treatment-success definitions, for instance, have shifted with WHO guideline revisions). Matching on measured baseline covariates does nothing to correct for era effects that operate through the *outcome-generating process* rather than through baseline patient characteristics. Always report the calendar period of both cohorts explicitly, justify why era drift is not expected to materially bias the comparison (or quantify how much it plausibly could, borrowing the E-value logic from §15.9), and treat any external-control-arm estimate as inherently more fragile than a concurrently randomised one when presenting it to a reimbursement committee.
]

Treatment switching, unmeasured confounding, federated OMOP networks, and external control arms all share a common thread: once you step outside a cleanly randomised, concurrently controlled trial, every causal estimate is only as credible as the assumptions propping it up, and this chapter's job has been to make those assumptions visible, testable where possible, and honestly reported where they are not. With that causal-inference foundation in place, Chapter 16 turns to the regression toolkit that sits on top of it — generalised linear models, mixed-effects models for clustered and longitudinal HEOR data, zero-inflated and hurdle models for cost and utilisation outcomes, quantile and ordinal regression for distributional and categorical endpoints, and machine-learning approaches to heterogeneous treatment effects and subgroup analysis — the modelling machinery that turns a defensible causal estimand into a defensible, decision-ready number.
