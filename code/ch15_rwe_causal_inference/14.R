# Extracted from ch15_rwe_causal_inference.typ, lines 467-474
# Section: === Difference-in-differences (DiD)
# Chapter: 15

did_fit <- lm(
  culture_conversion_weeks ~ treated_district * post_rollout + age + bmi,
  data = district_panel
)
summary(did_fit)
# coefficient on treated_district:post_rollout IS the DiD estimate
