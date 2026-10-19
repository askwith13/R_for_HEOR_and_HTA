# Extracted from ch15_rwe_causal_inference.typ, lines 622-657
# Section: == 15.8 Treatment switching and crossover adjustment (RPSFTM, IPCW)
# Chapter: 15

library(ipcwswitch)
library(survival)

# long_df: one row per patient-visit, with time-varying covariates
# (ecog_status, sputum_grade, weight_kg) measured at each visit, and
# a per-visit switch indicator
long_df <- ipcw.data(
  long_df,
  id.name     = "patient_id",
  tstart.name = "visit_start",
  tstop.name  = "visit_stop",
  event.name  = "event",
  bas.cov     = c("age", "baseline_ecog", "site"),
  dyn.cov     = c("ecog_status", "sputum_grade", "weight_kg"),
  switch.name = "switched_this_visit"
)

ipcw_weights <- ipcw.est(
  long_df,
  formula.denom = switched_this_visit ~ ecog_status + sputum_grade + weight_kg,
  formula.num   = switched_this_visit ~ 1,
  id.name = "patient_id", tstart.name = "visit_start", tstop.name = "visit_stop"
)

weighted_cox <- coxph(
  Surv(visit_start, visit_stop, event) ~ arm,
  data = long_df, weights = ipcw_weights$weights, cluster = patient_id
)
summary(weighted_cox)

# Always check the weight distribution before trusting the estimate
summary(ipcw_weights$weights)
hist(ipcw_weights$weights, breaks = 50,
     main = "IPCW weight distribution -- check for extreme tails")
