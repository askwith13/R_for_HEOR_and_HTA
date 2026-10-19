# Extracted from ch16_regression_models.typ, lines 519-527
# Section: == 16.5 Machine learning for prediction and heterogeneity of treatment effect
# Chapter: 16

library(glmnet)

x <- as.matrix(tb_data[, biomarker_cols])   # many candidate biomarkers
y <- tb_data$time_to_culture_conversion

fit <- cv.glmnet(x, y, alpha = 1)           # LASSO, lambda chosen by CV
coef(fit, s = "lambda.min")                  # non-zero coefficients = selected biomarkers
