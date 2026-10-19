# Extracted from ch10_survival_analysis.typ, lines 461-467
# Section: === Covariates on the location/scale parameter
# Chapter: 10

adj_weibull <- flexsurvreg(
  Surv(time, status) ~ arm + age + ecog_ps,
  data = os_data,
  dist = "weibull"
)
