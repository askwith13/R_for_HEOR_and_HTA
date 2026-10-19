# R for Health Economics and Outcomes Research (HEOR) and Health Technology Assessment (HTA)

## Proposed Table of Contents

---

## Front Matter

- Foreword
- Preface: why R for HEOR and HTA, who this book is for, how to use it
- Companion website, code repository and data sets
- Conventions, package versions and reproducibility notes

---

## PART I: FOUNDATIONS

### Chapter 1. Introduction to HEOR and HTA

1.1 What HEOR is and what it is not

1.2 The HTA ecosystem
- NICE, CADTH, PBAC, IQWiG/G-BA, HAS, ICER, HTAIn (India), and other agencies
- EU Joint Clinical Assessments (EU HTA Regulation)

1.3 Evidence needs across the product lifecycle

1.4 Typical deliverables
- Global value dossiers, economic models, budget impact models, systematic literature reviews, NMAs, RWE studies, payer submissions

1.5 Why R: the case for open-source and reproducible HEOR
- R versus Excel, TreeAge, SAS and Python
- Regulatory and agency acceptance of R-based models

1.6 Where R fits in the HEOR workflow

### Chapter 2. Setting Up an R Environment for HEOR

2.1 Installing R, RStudio/Positron and Quarto

2.2 Project structure for HEOR analyses

2.3 Package management with `renv`

2.4 Version control with Git and GitHub

2.5 Working with Stan, JAGS and C++ toolchains

2.6 Containers (Docker) for reproducible models

2.7 Recommended package ecosystem (overview map)

### Chapter 3. R Essentials for Health Economists

3.1 Data structures: vectors, lists, data frames and tibbles, arrays and matrices

3.2 Data wrangling with `tidyverse` and `data.table`

3.3 Functional programming with `purrr` and vectorization

3.4 Writing functions, parameter lists and defensive programming

3.5 Performance: profiling, `Rcpp`, parallelisation (`future`, `furrr`)

3.6 Dates, durations and time-to-event data (`lubridate`)

3.7 Debugging and error handling

### Chapter 4. Core Concepts in Health Economics (with R Illustrations)

4.1 Costs, effects and the opportunity cost of health care

4.2 Types of economic evaluation
- CMA, CEA, CUA, CBA and cost-consequence analysis

4.3 QALYs, DALYs and life-years

4.4 ICERs, net monetary benefit (NMB) and net health benefit (NHB)

4.5 Willingness-to-pay thresholds, including country-specific and LMIC thresholds

4.6 Perspective, time horizon, discounting and half-cycle correction

4.7 Dominance, extended dominance and the efficiency frontier

4.8 Coding a first simple CEA in R

---

## PART II: DATA FOR HEOR

### Chapter 5. Data Sources and Data Management

5.1 Clinical trial data (CDISC SDTM/ADaM concepts)

5.2 Registries, claims, electronic health records and surveys

5.3 Published literature as a data source

5.4 Importing data: `readr`, `readxl`, `haven`, `DBI`, APIs

5.5 Data dictionaries, metadata and codebooks

5.6 Data quality checks (`pointblank`, `assertr`, `validate`)

5.7 Data governance, privacy and de-identification

### Chapter 6. Systematic Literature Review (SLR) Support in R

6.1 Search strategy documentation

6.2 Deduplication and screening workflows

6.3 PRISMA flow diagrams in R

6.4 Data extraction templates and extraction QA

6.5 Risk of bias visualisation (`robvis`)

6.6 Text mining and ML-assisted screening

### Chapter 7. Missing Data

7.1 Mechanisms: MCAR, MAR, MNAR

7.2 Exploring missingness (`naniar`, `visdat`, Shiny-based explorers)

7.3 Complete-case versus imputation

7.4 Multiple imputation (`mice`, `Amelia`, `missForest`)

7.5 Sensitivity analysis, including tipping-point and pattern-mixture approaches

7.6 Missing data in cost and QALY data

7.7 Reporting missing data handling for HTA

### Chapter 8. Health-Related Quality of Life and Utilities

8.1 Generic and disease-specific instruments (EQ-5D, SF-6D, HUI, etc.)

8.2 Value sets and scoring in R (`eq5d`)

8.3 Mapping algorithms (cross-walks and regression-based mapping)

8.4 Analysing utility data: censoring, bounded distributions, beta regression, mixture models

8.5 Utility decrements, age-adjusted utilities and background mortality

8.6 Time trade-off, standard gamble and discrete choice experiments

### Chapter 9. Costs and Resource Use

9.1 Identifying, measuring and valuing resources

9.2 Unit costs and inflation or currency conversion (PPP adjustments)

9.3 Cost data features: skewness, zero-inflation, heavy tails

9.4 Regression models for costs: GLMs, two-part models, gamma models

9.5 Cost-of-illness and micro-costing studies

9.6 Handling censored cost data

---

## PART III: STATISTICAL METHODS FOR EVIDENCE SYNTHESIS AND ANALYSIS

### Chapter 10. Survival Analysis for Economic Evaluation

10.1 Kaplan-Meier and life tables (`survival`, `ggsurvfit`, `survminer`)

10.2 Parametric models (`flexsurv`)
- Exponential, Weibull, Gompertz, log-logistic, log-normal and generalised gamma

10.3 Flexible and spline-based models

10.4 Mixture-cure and non-mixture cure models (`flexsurvcure`)

10.5 Piecewise and landmark models

10.6 Model selection: AIC/BIC, visual fit, clinical plausibility

10.7 Proportional hazards diagnostics and non-PH alternatives

10.8 Covariate-adjusted and treatment-effect-specific models

10.9 Extrapolation: external data, background mortality, expert elicitation

10.10 Competing risks and multi-state models (`mstate`, `flexsurv`)

10.11 Reconstructing individual patient data from published Kaplan-Meier curves (`IPDfromKM`)

10.12 Reporting extrapolation following NICE DSU TSD 14 and 21

### Chapter 11. Meta-Analysis

11.1 Fixed-effect and random-effects models (`meta`, `metafor`)

11.2 Heterogeneity and its quantification

11.3 Publication bias and small-study effects

11.4 Meta-regression

11.5 Meta-analysis of time-to-event outcomes

11.6 Diagnostic test accuracy meta-analysis

11.7 Meta-analysis of proportions and rates

### Chapter 12. Indirect Treatment Comparisons and Network Meta-Analysis

12.1 Why indirect comparison is needed

12.2 Bucher method

12.3 Frequentist NMA (`netmeta`)

12.4 Bayesian NMA (`gemtc`, `multinma`, `bnma`)

12.5 Consistency and inconsistency assessment (node-splitting, design-by-treatment)

12.6 Network meta-regression

12.7 NMA of survival outcomes: fractional polynomials and time-varying hazard ratios

12.8 Ranking, SUCRA and rankograms

12.9 Reporting per NICE DSU TSD 2, ISPOR and PRISMA-NMA

### Chapter 13. Population-Adjusted Indirect Comparisons

13.1 When population adjustment is needed

13.2 Matching-adjusted indirect comparison (MAIC)
- Weighting, effective sample size, handling time-to-event outcomes

13.3 Simulated treatment comparison (STC)

13.4 Multilevel network meta-regression (ML-NMR)

13.5 Limitations, assumptions and agency expectations (NICE DSU TSD 18)

### Chapter 14. Bayesian Methods for HEOR

14.1 Bayesian thinking for decision makers

14.2 Priors: informative, weakly informative and vague priors

14.3 MCMC with Stan, JAGS and `brms`

14.4 Diagnostics: convergence, effective sample size, posterior predictive checks

14.5 Bayesian evidence synthesis

14.6 Bayesian decision analysis

14.7 Expert elicitation methods (SHELF)

14.8 Bayesian health economic modelling workflows

### Chapter 15. Real-World Evidence (RWE) and Causal Inference

15.1 Fit-for-purpose RWD and RWE frameworks

15.2 Study design: cohort, case-control, target trial emulation

15.3 Confounding and bias, with DAGs (`dagitty`, `ggdag`)

15.4 Propensity scores: matching, weighting, stratification (`MatchIt`, `WeightIt`, `cobalt`)

15.5 Doubly robust estimators and g-methods

15.6 Instrumental variables and regression discontinuity

15.7 Difference-in-differences and interrupted time series

15.8 Treatment switching and crossover adjustment (RPSFTM, IPCW)

15.9 E-values and quantitative bias analysis

15.10 OHDSI/OMOP workflows in R

15.11 Using external control arms and synthetic control arms

### Chapter 16. Regression Models for HEOR Data

16.1 Generalised linear models

16.2 Mixed-effects and hierarchical models

16.3 Count data and zero-inflated models

16.4 Quantile and ordinal regression

16.5 Machine learning for prediction and heterogeneity of treatment effect

16.6 Subgroup analysis and effect modification

---

## PART IV: DECISION-ANALYTIC MODELLING

### Chapter 17. Principles of Decision Modelling

17.1 Model conceptualisation and problem scoping

17.2 Choosing a model type

17.3 Structural assumptions and model diagrams (`DiagrammeR`)

17.4 Parameter taxonomy and distributions

17.5 Model documentation and transparency

17.6 Modelling workflow in R: inputs → engine → outputs → reporting

17.7 Good practice guidelines (ISPOR-SMDM, NICE reference case)

### Chapter 18. Decision Trees

18.1 Structure and expected-value calculations

18.2 Building decision trees from scratch in R

18.3 Using `rdecision`

18.4 Short-term models for screening, diagnostics and acute care

18.5 Combining a decision tree with a long-term Markov model

### Chapter 19. Markov Cohort Models

19.1 States, transitions and cycles

19.2 Time-homogeneous and time-dependent transition matrices

19.3 Building a Markov model in base R (matrix-based approach)

19.4 Using `heemod`, `hesim` and `dampack`

19.5 Applying costs and QALYs, discounting and half-cycle correction

19.6 Tunnel states and state residence time

19.7 Age-dependent transitions and background mortality

19.8 Probabilistic transition matrices (Dirichlet) and Cholesky decomposition

19.9 Calibration and validation

19.10 Worked example: a chronic-disease CEA

### Chapter 20. Partitioned Survival Models

20.1 Structure and when it is appropriate

20.2 Building PSMs from survival extrapolations

20.3 Treatment waning and relative-effect assumptions

20.4 Modelling with `hesim`, `flexsurv` and custom code

20.5 Limitations compared with state-transition models

20.6 Worked example: an oncology CEA

### Chapter 21. Individual-Level State-Transition Models (Microsimulation)

21.1 When microsimulation is needed

21.2 Patient heterogeneity and history dependence

21.3 Efficient implementation: vectorisation, `data.table`, parallel computing

21.4 First-order versus second-order Monte Carlo uncertainty

21.5 Common random numbers

21.6 Using `hesim` for individual-level models

21.7 Worked example: a screening programme

### Chapter 22. Discrete Event Simulation and Dynamic Models

22.1 Concepts: events, queues, resources and attributes

22.2 DES with `simmer`

22.3 Competing events and time-to-event sampling

22.4 Infectious disease transmission models
- Compartmental models (SIR/SEIR) with `deSolve`
- Agent-based models and `EpiModel`
- Linking transmission models to economic evaluation

22.5 Choosing between Markov, DES and dynamic models

22.6 Worked example: a vaccination or TB intervention model

### Chapter 23. Budget Impact Analysis

23.1 Purpose and ISPOR guidance

23.2 Population, uptake and market-share structure

23.3 Building a budget impact model in R

23.4 Scenario analyses

23.5 Presenting results to payers

### Chapter 24. Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis

24.1 Monetary valuation of health

24.2 Distributional CEA and equity weighting

24.3 Extended CEA: financial risk protection

24.4 Multi-criteria decision analysis (MCDA) in R

24.5 Severity modifiers, value-based pricing and managed entry agreements

---

## PART V: UNCERTAINTY, VALUE OF INFORMATION AND MODEL VALIDATION

### Chapter 25. Handling Uncertainty

25.1 Types of uncertainty: parameter, structural, methodological and heterogeneity

25.2 Deterministic sensitivity analysis: one-way, two-way, tornado plots

25.3 Scenario analysis scripts

25.4 Probabilistic sensitivity analysis (PSA)
- Choosing distributions: beta, gamma, lognormal, Dirichlet, multivariate normal
- Correlated parameters
- Number of iterations and Monte Carlo error

25.5 Visualising uncertainty: CE plane, CEAC, CEAF, NMB distributions (`BCEA`, `dampack`)

25.6 Threshold analysis

25.7 Structural uncertainty and model averaging

25.8 Analysing patient-level cost-effectiveness trial data and bootstrapping

### Chapter 26. Value of Information Analysis

26.1 Concepts: EVPI, EVPPI, EVSI and ENBS

26.2 Computing EVPI and EVPPI (`BCEA`, `voi`)

26.3 Efficient EVPPI via regression and GAM approximations

26.4 EVSI: moment-matching, importance sampling, Gaussian approximation

26.5 Value of implementation

26.6 Using VOI to design research and prioritise data collection

### Chapter 27. Model Calibration, Validation and Quality Assurance

27.1 Calibration methods: random search, Nelder-Mead, Bayesian calibration, ABC, IMIS

27.2 Cross-validation of model structure

27.3 Verification: unit testing with `testthat`, extreme-value tests, replication

27.4 Validation frameworks (AdViSHE, TECH-VER, ISPOR-SMDM)

27.5 Code review and peer review practices

27.6 Face validity, internal, cross and external validity

---

## PART VI: REPORTING, COMMUNICATION AND DEPLOYMENT

### Chapter 28. Reproducible Reporting

28.1 Quarto and R Markdown for HEOR reports

28.2 Parameterised reports

28.3 Producing Word, PDF, HTML and PowerPoint outputs

28.4 Publication-ready tables (`gt`, `gtsummary`, `flextable`, `kableExtra`)

28.5 Publication-ready graphics (`ggplot2` themes, colour-blind-safe palettes)

28.6 CHEERS 2022 reporting checklist implementation

28.7 Automating dossier and submission appendices

28.8 Automating routine reports across programmes or districts

### Chapter 29. Interactive Models and Web Applications with Shiny

29.1 Shiny fundamentals for model front-ends

29.2 Designing a user interface for non-programmers

29.3 Modular Shiny with `golem` and `rhino`

29.4 Linking Shiny to the model engine and PSA outputs

29.5 Downloadable reports and audit trails

29.6 Deployment: shinyapps.io, Posit Connect, Docker, servers

29.7 Security, validation and agency expectations for web-based models

29.8 Case study: a transparent, reviewable submission-ready model app

### Chapter 30. R Packages and Pipelines for Model Development

30.1 Why package your model

30.2 Package structure with `usethis` and `devtools`

30.3 Documentation with `roxygen2` and `pkgdown`

30.4 Pipelines with `targets` and `renv`

30.5 Continuous integration with GitHub Actions

30.6 Sharing models with HTA agencies and reviewers

30.7 Open-source model licensing and the open-source HEOR movement

---

## PART VII: HTA IN PRACTICE

### Chapter 31. Agency Requirements and Reference Cases

31.1 NICE: reference case, DSU technical support documents, and submission templates

31.2 CADTH, PBAC, ICER, G-BA/IQWiG and HAS

31.3 HTA in India: HTAIn, the Indian reference case, and Ayushman Bharat PM-JAY

31.4 HTA in LMICs: iDSI reference case, thresholds and capacity

31.5 Comparing evidence requirements across agencies

31.6 Responding to technical engagement and evidence review group critiques with R

### Chapter 32. Special Topics

32.1 Oncology: immuno-oncology, long-term survival and cure assumptions

32.2 Rare diseases and ultra-orphan drugs

32.3 Vaccines and public health programmes

32.4 Diagnostics, screening and medical devices

32.5 Digital health technologies and AI-enabled interventions

32.6 Gene and cell therapies and outcome-based agreements

32.7 Infectious diseases and TB: programmatic and cascade-of-care models

32.8 Health systems modelling and resource allocation

### Chapter 33. Patient-Reported Outcomes and Preference Research

33.1 PRO analysis and psychometrics in R (`lavaan`, `mirt`)

33.2 Minimal clinically important differences

33.3 Discrete choice experiments (`mlogit`, `apollo`, `logitr`)

33.4 Best-worst scaling and conjoint analysis

### Chapter 34. Emerging Methods and the Future of HEOR in R

34.1 Machine learning in HEOR

34.2 Large language models in HEOR workflows (SLR, extraction, coding assistance) and their validation

34.3 Digital twins and synthetic data

34.4 Open-source collaboration: the R Consortium, ISPOR open-source models SIG and the HEOR R community

34.5 Looking ahead: living models and living systematic reviews

---

## PART VIII: CASE STUDIES

### Chapter 35. End-to-End Worked Case Studies

35.1 Case study A: a Markov model CEA for a chronic disease

35.2 Case study B: an oncology partitioned survival model with NMA inputs

35.3 Case study C: a microsimulation of a screening programme

35.4 Case study D: a budget impact model and Shiny application

35.5 Case study E: an RWE comparative effectiveness study with propensity scoring

35.6 Case study F: a TB programme cost-effectiveness analysis for an LMIC setting

---

## Back Matter

- **Appendix A.** R cheat sheet for HEOR (key functions and packages)
- **Appendix B.** Statistical distributions commonly used in HEOR, with parameterisation guides
- **Appendix C.** Template R project structure and model scripts
- **Appendix D.** CHEERS 2022, ISPOR and NICE checklists mapped to R workflows
- **Appendix E.** Glossary of HEOR and HTA terms
- **Appendix F.** Data sets used in the book
- **Appendix G.** Solutions to exercises
- **References**
- **Index**

---

## Suggested Features Within Each Chapter

- Learning objectives at the start
- "HEOR in practice" boxes with real-world submission examples
- "Common pitfalls" and "Agency perspective" callouts
- Reproducible code with a companion repository
- Exercises with solutions
- Package spotlights and further reading
