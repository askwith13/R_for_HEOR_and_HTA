# Extracted from ch14_bayesian_methods.typ, lines 546-551
# Section: == 14.8 Bayesian health economic modelling workflows
# Chapter: 14

# Illustrative: checking convergence before using draws downstream
library(rstan)
print(fit_synthesis, pars = c("mu", "tau"))   # check Rhat, n_eff
rstan::traceplot(fit_synthesis, pars = c("mu", "tau"))
