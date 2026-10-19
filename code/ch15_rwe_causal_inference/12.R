# Extracted from ch15_rwe_causal_inference.typ, lines 406-415
# Section: === Instrumental variables
# Chapter: 15

library(ivreg)

iv_fit <- ivreg(
  culture_conversion_weeks ~ trt + age + bmi + hiv_status |     # structural equation
                              facility_rollout_quarter + age + bmi + hiv_status, # instruments + exogenous covariates
  data = tb_cohort
)
summary(iv_fit, diagnostics = TRUE)
