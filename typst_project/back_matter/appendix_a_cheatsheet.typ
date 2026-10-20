#import "../common.typ": *

= Appendix A. R Cheat Sheet for HEOR

This is a quick-reference index into functions and packages this book actually uses, organised by task rather than alphabetically -- intended as a fast lookup once you already know roughly what you are trying to do, not as a teaching text. Every function listed here is genuinely called somewhere in this book's worked examples; none is included on the strength of general reputation alone. See the cited chapter for the full worked context, arguments, and pitfalls -- this appendix deliberately does not repeat argument-by-argument documentation already covered there.

== Data import and cleaning

#ref-table(
  [Key functions for data import and cleaning (Chapters 2-7)],
  academic-table(
    columns: (1.6fr, 1.8fr, 1fr),
    align: (left, left, center),
    header: ([Function], [Package], [Chapter]),
    body: (
      [`read_csv()`, `read_excel()`], [readr, readxl], [5],
      [`read_sas()`, `read_dta()`, `read_spss()`], [haven], [5],
      [`dbConnect()`, `dbGetQuery()`], [DBI], [5],
      [`litsearchr()` workflow, `synthesisr`], [litsearchr, synthesisr], [6],
      [`PRISMA_data()`, `PRISMA_flowdiagram()`], [PRISMA2020], [6],
      [`mice()`, `complete()`], [mice], [7],
      [`gg_miss_var()`, `vis_miss()`], [naniar, visdat], [7],
      [`assert()`, `validate()`, `in_set()`], [assertr, validate], [5],
    ),
    footer: none,
  ),
)

== Utilities and costs

#ref-table(
  [Key functions for health-state utilities and costing (Chapters 8-9)],
  academic-table(
    columns: (1.6fr, 1.8fr, 1fr),
    align: (left, left, center),
    header: ([Function], [Package], [Chapter]),
    body: (
      [EQ-5D value-set scoring], [eq5d], [8],
      [beta regression for bounded utility data], [betareg], [8],
      [inflation/currency adjustment workflows], [base R + manual CPI tables], [9],
    ),
    footer: none,
  ),
)

== Survival analysis and evidence synthesis

#ref-table(
  [Key functions for survival analysis, meta-analysis and NMA (Chapters 10-14)],
  academic-table(
    columns: (1.6fr, 1.8fr, 1fr),
    align: (left, left, center),
    header: ([Function], [Package], [Chapter]),
    body: (
      [`Surv()`, `survfit()`, `coxph()`, `survSplit()`], [survival], [10],
      [`flexsurvreg()`, `flexsurvcure()`], [flexsurv, flexsurvcure], [10, 32],
      [`survfit2()` ggplot-native survival curves], [ggsurvfit], [10],
      [`segmented()` changepoint hazards], [segmented], [10],
      [`metafor()`/`rma()`, `meta::metagen()`], [metafor, meta], [11],
      [`netmeta()` frequentist NMA], [netmeta], [12],
      [`gemtc`, `multinma` Bayesian NMA], [gemtc, multinma], [12],
      [matching-adjusted indirect comparison helpers], [MAIC-style custom code], [13],
      [`brms()`, `rstan`, `rjags` Bayesian model fitting], [brms, rstan, rjags], [14],
    ),
    footer: none,
  ),
)

== Real-world evidence and causal inference

#ref-table(
  [Key functions for RWE, causal inference and regression (Chapters 15-16)],
  academic-table(
    columns: (1.6fr, 1.8fr, 1fr),
    align: (left, left, center),
    header: ([Function], [Package], [Chapter]),
    body: (
      [`matchit()`, `match.data()`], [MatchIt], [15, 35],
      [`weightit()`], [WeightIt], [15, 35],
      [`bal.tab()`, `love.plot()`], [cobalt], [15, 35],
      [DAG specification and plotting], [dagitty, ggdag], [15],
      [`ivreg()` instrumental variables], [ivreg], [15],
      [`AIPW()` doubly-robust estimation], [AIPW], [15],
      [difference-in-differences estimators], [did], [15],
      [E-value sensitivity analysis], [EValue], [15],
      [`glmnet()` regularised regression], [glmnet], [16],
      [`lme4::lmer()`/`glmer()` mixed-effects models], [lme4], [16],
      [`gam()` generalised additive models], [mgcv], [9, 26],
      [`causal_forest()` heterogeneous treatment effects], [grf], [16, 34],
    ),
    footer: none,
  ),
)

== Decision-analytic modelling

#ref-table(
  [Key functions for decision trees, Markov models and simulation (Chapters 17-24)],
  academic-table(
    columns: (1.6fr, 1.8fr, 1fr),
    align: (left, left, center),
    header: ([Function], [Package], [Chapter]),
    body: (
      [`rdecision` decision-tree classes], [rdecision], [18],
      [`heemod::run_model()` Markov cohort models], [heemod], [19],
      [`hesim` individual-level/PSM models], [hesim], [20, 21],
      [`mstate` multi-state model machinery], [mstate], [10],
      [`simmer()` discrete-event simulation], [simmer], [22],
      [`ode()` compartmental transmission models], [deSolve], [22],
      [`dampack` PSA/CEAC/VOI helpers], [dampack], [19, 25],
    ),
    footer: none,
  ),
)

== Uncertainty, validation and reporting

#ref-table(
  [Key functions for PSA, validation, and reproducible reporting (Chapters 25-30)],
  academic-table(
    columns: (1.6fr, 1.8fr, 1fr),
    align: (left, left, center),
    header: ([Function], [Package], [Chapter]),
    body: (
      [`SHELF` structured expert elicitation], [SHELF], [10, 14],
      [`testthat::test_that()`, `expect_equal()`], [testthat], [27],
      [`profvis()` code profiling], [profvis], [3],
      [`targets()`, `tar_target()`, `tar_make()`], [targets, tarchetypes], [28, 30],
      [`renv::init()`, `renv::snapshot()`], [renv], [2, 30],
      [Quarto/R Markdown rendering], [quarto], [28],
      [`flextable()`, `officer` Word/PowerPoint export], [flextable, officer], [28],
      [`gt()` publication-quality tables], [gt], [28],
      [`kableExtra()` table styling], [kableExtra], [28],
      [`shiny::shinyApp()`, reactive expressions], [shiny, bslib], [29],
    ),
    footer: none,
  ),
)

== Machine learning and emerging methods

#ref-table(
  [Key functions for ML and emerging methods (Chapter 34)],
  academic-table(
    columns: (1.6fr, 1.8fr, 1fr),
    align: (left, left, center),
    header: ([Function], [Package], [Chapter]),
    body: (
      [`randomForest()`, `importance()`], [randomForest], [34],
      [`ranger()`], [ranger], [34],
      [`xgboost()`], [xgboost], [34],
      [`cfa()` confirmatory factor analysis], [lavaan], [33],
      [`mirt()` item response theory], [mirt], [33],
    ),
    footer: none,
  ),
)

#heor-practice[
  This appendix lists functions, not a substitute for reading the chapter where each one is actually used. A function name alone tells you almost nothing about the arguments that matter for a correct HEOR analysis (discount timing conventions, half-cycle correction, censoring handling) -- treat this page as a fast way to recall which chapter to re-open, not as standalone documentation.
]
