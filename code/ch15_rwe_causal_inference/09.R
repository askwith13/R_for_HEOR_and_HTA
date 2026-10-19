# Extracted from ch15_rwe_causal_inference.typ, lines 320-334
# Section: == 15.5 Doubly robust estimators and g-methods
# Chapter: 15

library(AIPW)
library(SuperLearner)

aipw_fit <- AIPW::AIPW$new(
  Y          = tb_cohort$culture_conversion_weeks,
  A          = tb_cohort$trt,
  W          = tb_cohort[, c("age","bmi","hiv_status","smear_grade","district_urban")],
  Q.SL.library = c("SL.glm", "SL.mean"),   # outcome model learners
  g.SL.library = c("SL.glm", "SL.mean"),   # propensity model learners
  k_split    = 10,
  verbose    = TRUE
)
aipw_fit$fit()$summary()
