# Extracted from ch15_rwe_causal_inference.typ, lines 643-663
# Section: == 15.9 E-values and quantitative bias analysis
# Chapter: 15

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
