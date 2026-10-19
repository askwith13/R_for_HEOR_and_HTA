# Extracted from ch15_rwe_causal_inference.typ, lines 785-813
# Section: == 15.11 Using external control arms and synthetic control arms
# Chapter: 15

library(survival)
library(MatchIt)

# combined_df: trial arm (source == "trial") stacked with an external
# registry cohort (source == "registry"), harmonised on shared baseline
# covariates measured comparably in both sources
combined_df$is_trial <- as.integer(combined_df$source == "trial")

match_model <- matchit(
  is_trial ~ age + baseline_ecog + extent_of_disease + prior_regimens,
  data   = combined_df,
  method = "nearest",
  ratio  = 2  # up to 2 external controls matched per trial patient
)

matched_data <- match.data(match_model)

eca_fit <- coxph(
  Surv(time, event) ~ is_trial,
  data    = matched_data,
  weights = weights  # matching weights from MatchIt
)
summary(eca_fit)

# Always report the covariate balance achieved by the match before
# trusting the comparative estimate
summary(match_model)
