# Extracted from ch14_bayesian_methods.typ, lines 318-324
# Section: === Posterior predictive checks
# Chapter: 14

library(bayesplot)

y_rep <- posterior_predict(fit)  # or extract manually from Stan output

ppc_dens_overlay(y = observed_outcomes, yrep = y_rep[1:50, ])
