# Extracted from ch15_rwe_causal_inference.typ, lines 456-471
# Section: === Regression discontinuity
# Chapter: 15

library(rdrobust)

rd_fit <- rdrobust(
  y = tb_cohort$culture_conversion_weeks,
  x = tb_cohort$cd4_count,
  c = 200                     # the policy cutoff: CD4 < 200 mandates new regimen
)
summary(rd_fit)

rdplot(
  y = tb_cohort$culture_conversion_weeks,
  x = tb_cohort$cd4_count,
  c = 200
)
