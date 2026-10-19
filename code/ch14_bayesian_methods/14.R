# Extracted from ch14_bayesian_methods.typ, lines 555-561
# Section: == 14.8 Bayesian health economic modelling workflows
# Chapter: 14

# Illustrative: extracting posterior draws as PSA inputs
library(rstan)
draws <- rstan::extract(fit_synthesis)
# draws$mu, draws$tau (etc.) are now vectors of length n_draws,
# ready to be looped through a cost-effectiveness model row by row
