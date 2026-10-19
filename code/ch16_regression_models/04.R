# Extracted from ch16_regression_models.typ, lines 282-291
# Section: == 16.3 Count data and zero-inflated models
# Chapter: 16

library(pscl)

fit_zinb <- zeroinfl(
  ae_count ~ arm + age | arm,
  data  = tb_ae,
  dist  = "negbin"
)
summary(fit_zinb)
