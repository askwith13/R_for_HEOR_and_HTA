# Extracted from ch14_bayesian_methods.typ, lines 211-233
# Section: == 14.3 MCMC with Stan, JAGS and brms
# Chapter: 14

library(brms)

tb_df <- data.frame(
  success = 34,
  total   = 40
)

fit_brms <- brm(
  success | trials(total) ~ 1,
  data   = tb_df,
  family = binomial(),
  prior  = set_prior("normal(0, 2.5)", class = "Intercept"),
  chains = 4,
  iter   = 2000,
  warmup = 1000,
  cores  = 4,
  seed   = 123
)

summary(fit_brms)
plot(fit_brms)
