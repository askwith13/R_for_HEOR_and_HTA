# Extracted from ch10_survival_analysis.typ, lines 432-447
# Section: === When PH fails: alternative hazard structures
# Chapter: 10

library(flexsurv)

aft_weibull <- flexsurvreg(
  Surv(time, status) ~ arm,
  data = os_data,
  dist = "weibull"
)

spline_fit <- flexsurvspline(
  Surv(time, status) ~ arm,
  data = os_data,
  k = 1,
  scale = "hazard"
)
