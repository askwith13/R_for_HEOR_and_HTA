# Extracted from ch15_rwe_causal_inference.typ, lines 362-376
# Section: === G-methods
# Chapter: 15

# Simple (time-fixed) g-computation "by hand"
outcome_model <- lm(
  culture_conversion_weeks ~ trt + age + bmi + hiv_status + smear_grade + district_urban,
  data = tb_cohort
)

d1 <- d0 <- tb_cohort
d1$trt <- 1          # counterfactual: everyone treated
d0$trt <- 0          # counterfactual: no one treated

g_ate <- mean(predict(outcome_model, newdata = d1)) -
         mean(predict(outcome_model, newdata = d0))
g_ate
