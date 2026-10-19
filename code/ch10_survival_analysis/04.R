# Extracted from ch10_survival_analysis.typ, lines 91-100
# Section: == 10.2 Parametric models
# Chapter: 10

library(flexsurv)

fit_exp      <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "exp")
fit_weibull  <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "weibull")
fit_gompertz <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "gompertz")
fit_llogis   <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "llogis")
fit_lnorm    <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "lnorm")
fit_gengamma <- flexsurvreg(Surv(time, status) ~ arm, data = trial_df, dist = "gengamma")
