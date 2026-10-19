# Extracted from ch10_survival_analysis.typ, lines 274-291
# Section: == 10.5 Piecewise and landmark models
# Chapter: 10

library(survival)
library(flexsurv)

landmark_time <- 24  # months; chosen where KM data becomes sparse

fit_pw <- survival::survSplit(
  Surv(time, status) ~ .,
  data = tb_followup,
  cut = landmark_time,
  episode = "period"
)

fit_pw_exp <- survival::coxph(
  Surv(tstart, time, status) ~ strata(period),
  data = fit_pw
)
