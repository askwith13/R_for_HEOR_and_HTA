# Extracted from ch15_rwe_causal_inference.typ, lines 569-590
# Section: == 15.8 Treatment switching and crossover adjustment (RPSFTM, IPCW)
# Chapter: 15

library(rpsftm)
library(survival)

# df has: time (observed), event, arm (0=control,1=experimental),
# rx (proportion of follow-up time actually on experimental treatment),
# plus switching indicator baked into rx for control-arm switchers
fit_rpsftm <- rpsftm(
  Surv(time, event) ~ rand(arm, rx),
  data = df,
  censor_time = admin_censor_time,  # administrative censoring time per patient
  n_eval_z = 100
)

summary(fit_rpsftm)
# psi: the estimated causal log-time-ratio
# Recreate a counterfactual, switching-adjusted Kaplan-Meier using
# fit_rpsftm$Sstar (the re-derived "as randomised, no switching" times)
counterfactual_fit <- survfit(Surv(fit_rpsftm$Sstar, event) ~ arm, data = df)
plot(counterfactual_fit, col = c("grey40", "steelblue"), lwd = 2,
     xlab = "Time (months)", ylab = "Survival probability")
