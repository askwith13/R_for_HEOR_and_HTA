# Extracted from ch10_survival_analysis.typ, lines 144-150
# Section: == 10.3 Flexible and spline-based models
# Chapter: 10

library(flexsurv)

fit_spline0 <- flexsurvspline(Surv(time, status) ~ arm, data = trial_df, k = 0)
fit_spline1 <- flexsurvspline(Surv(time, status) ~ arm, data = trial_df, k = 1)
fit_spline2 <- flexsurvspline(Surv(time, status) ~ arm, data = trial_df, k = 2)
