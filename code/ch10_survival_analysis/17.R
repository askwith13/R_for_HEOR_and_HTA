# Extracted from ch10_survival_analysis.typ, lines 475-482
# Section: === Covariates on ancillary (shape) parameters
# Chapter: 10

shape_fit <- flexsurvreg(
  Surv(time, status) ~ arm,
  anc = list(shape = ~ arm),
  data = os_data,
  dist = "weibull"
)
