# Extracted from ch16_regression_models.typ, lines 416-427
# Section: == 16.5 Machine learning for prediction and heterogeneity of treatment effect
# Chapter: 16

library(grf)

# X: baseline covariates, W: treatment (0/1), Y: outcome (e.g. treatment success)
cf <- causal_forest(X = as.matrix(tb_data[, c("age", "bmi", "baseline_chest_xray_score")]),
                     Y = tb_data$treatment_success,
                     W = tb_data$received_new_regimen)

# Per-patient estimated treatment effect
tau_hat <- predict(cf)$predictions
summary(tau_hat)
