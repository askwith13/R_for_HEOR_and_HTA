# Extracted from ch10_survival_analysis.typ, lines 196-218
# Section: == 10.4 Mixture-cure and non-mixture cure models
# Chapter: 10

library(flexsurvcure)
library(flexsurv)
library(survival)

# Mixture cure model: S(t) = pi + (1 - pi) * S_u(t)
fit_mix <- flexsurvcure(
  Surv(time, status) ~ 1,
  data = tb_followup,
  dist = "weibull",
  mixture = TRUE
)

# Non-mixture cure model: S(t) = pi ^ (1 - S_u(t))
fit_nmix <- flexsurvcure(
  Surv(time, status) ~ 1,
  data = tb_followup,
  dist = "weibull",
  mixture = FALSE
)

fit_mix
