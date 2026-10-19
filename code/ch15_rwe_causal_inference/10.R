# Extracted from ch15_rwe_causal_inference.typ, lines 338-352
# Section: == 15.5 Doubly robust estimators and g-methods
# Chapter: 15

library(WeightIt)

tb_cohort$iptw <- weightit(
  trt ~ age + bmi + hiv_status + smear_grade + district_urban,
  data = tb_cohort, method = "ps", estimand = "ATE"
)$weights

dr_fit <- lm(
  culture_conversion_weeks ~ trt + age + bmi + hiv_status + smear_grade + district_urban,
  data    = tb_cohort,
  weights = iptw
)
coef(summary(dr_fit))["trt", ]
