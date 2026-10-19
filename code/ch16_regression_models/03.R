# Extracted from ch16_regression_models.typ, lines 262-267
# Section: == 16.3 Count data and zero-inflated models
# Chapter: 16

library(MASS)

fit_nb <- glm.nb(ae_count ~ arm + age + baseline_risk, data = tb_ae)
summary(fit_nb)
