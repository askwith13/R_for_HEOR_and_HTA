# Extracted from ch16_regression_models.typ, lines 494-498
# Section: == 16.6 Subgroup analysis and effect modification
# Chapter: 16

fit <- glm(treatment_success ~ treatment * hiv_status + age + baseline_severity,
           data = tb_data, family = binomial())
summary(fit)   # coefficient on treatment:hiv_status is the test of effect modification
