# Extracted from ch13_population_adjusted.typ, lines 117-131
# Section: == 13.2 Matching-adjusted indirect comparison (MAIC)
# Chapter: 13

library(survival)

# Weighted Cox model using MAIC odds-weights as case weights
cox_fit <- coxph(
  Surv(time, event) ~ treatment,
  data    = ipd,
  weights = w          # odds-weights from the MAIC step above
)

summary(cox_fit)

# Weighted Kaplan-Meier for the matched IPD population
km_fit <- survfit(Surv(time, event) ~ treatment, data = ipd, weights = w)
