# Extracted from ch16_regression_models.typ, lines 330-341
# Section: == 16.4 Quantile and ordinal regression
# Chapter: 16

library(quantreg)

# Median length of stay
fit_median <- rq(los ~ arm + age + comorbidity_score, data = tb_cost, tau = 0.5)

# 90th percentile length of stay — the costly tail
fit_q90 <- rq(los ~ arm + age + comorbidity_score, data = tb_cost, tau = 0.9)

summary(fit_median)
summary(fit_q90)
