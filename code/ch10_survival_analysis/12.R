# Extracted from ch10_survival_analysis.typ, lines 320-332
# Section: == 10.6 Model selection: AIC/BIC, visual fit, clinical plausibility
# Chapter: 10

fits <- list(
  exp      = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "exp"),
  weibull  = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "weibull"),
  gompertz = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "gompertz"),
  llogis   = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "llogis"),
  lnorm    = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "lnorm"),
  gengamma = flexsurvreg(Surv(time, status) ~ 1, data = tb_followup, dist = "gengamma")
)

sapply(fits, AIC)
sapply(fits, BIC)
