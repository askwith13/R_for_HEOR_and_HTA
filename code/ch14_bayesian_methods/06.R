# Extracted from ch14_bayesian_methods.typ, lines 271-280
# Section: === Why convergence is not optional
# Chapter: 14

library(bayesplot)
library(rstan)

fit <- stan(file = "nma_model.stan", data = stan_data,
            chains = 4, iter = 4000, warmup = 2000)

posterior_array <- as.array(fit)
mcmc_trace(posterior_array, pars = c("d[1]", "d[2]", "tau"))
