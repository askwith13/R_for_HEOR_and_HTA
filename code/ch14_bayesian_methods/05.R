# Extracted from ch14_bayesian_methods.typ, lines 253-258
# Section: === Why convergence is not optional
# Chapter: 14

library(coda)

# mcmc.list object from gemtc, rjags, or similar
gelman.diag(mcmc_samples, multivariate = FALSE)
