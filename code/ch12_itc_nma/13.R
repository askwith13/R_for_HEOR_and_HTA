# Extracted from ch12_itc_nma.typ, lines 540-549
# Section: === Interpreting shrinkage of heterogeneity and inconsistency
# Chapter: 12

# compare DIC and residual deviance between unadjusted and
# regression-adjusted models
summary(results_unadjusted)$DIC
summary(results_regression)$DIC

# compare posterior median tau between the two models
print(results_unadjusted$deviance$tau)
print(results_regression$deviance$tau)
