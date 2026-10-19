# Extracted from ch14_bayesian_methods.typ, lines 144-173
# Section: == 14.3 MCMC with Stan, JAGS and brms
# Chapter: 14

library(rstan)

stan_code <- "
data {
  int<lower=0> n;      // number of patients
  int<lower=0> y;      // number of successes
}
parameters {
  real<lower=0, upper=1> theta;   // treatment success probability
}
model {
  theta ~ beta(2, 2);    // weakly informative prior
  y ~ binomial(n, theta);
}
"

stan_data <- list(n = 40, y = 34)

fit_stan <- stan(
  model_code = stan_code,
  data       = stan_data,
  chains     = 4,
  iter       = 2000,
  warmup     = 1000,
  seed       = 123
)

print(fit_stan, probs = c(0.025, 0.5, 0.975))
