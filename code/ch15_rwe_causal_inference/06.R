# Extracted from ch15_rwe_causal_inference.typ, lines 221-233
# Section: === Weighting with WeightIt
# Chapter: 15

library(WeightIt)

w.out <- weightit(
  trt ~ age + bmi + hiv_status + smear_grade + district_urban,
  data     = tb_cohort,
  method   = "ps",          # logistic-regression propensity score
  estimand = "ATE"          # average treatment effect (use "ATT" for effect on treated only)
)

tb_cohort$iptw <- w.out$weights
summary(w.out)
