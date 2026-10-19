# Extracted from ch15_rwe_causal_inference.typ, lines 197-213
# Section: === Matching with MatchIt
# Chapter: 15

library(MatchIt)
library(cobalt)

# tb_cohort: one row per patient, trt = 1 if new regimen, 0 if standard
m.out <- matchit(
  trt ~ age + bmi + hiv_status + smear_grade + district_urban,
  data   = tb_cohort,
  method = "nearest",      # nearest-neighbour matching
  distance = "glm",        # logistic-regression propensity score
  ratio  = 1,               # 1:1 matching
  caliper = 0.2             # max distance, in SD of logit(PS)
)

summary(m.out)              # balance before/after matching
matched_data <- match.data(m.out)   # retrieve matched sample with weights
