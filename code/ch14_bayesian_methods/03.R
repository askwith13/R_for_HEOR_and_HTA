# Extracted from ch14_bayesian_methods.typ, lines 177-207
# Section: == 14.3 MCMC with Stan, JAGS and brms
# Chapter: 14

library(rjags)
library(coda)

jags_code <- "
model {
  theta ~ dbeta(2, 2)
  y ~ dbin(theta, n)
}
"
writeLines(jags_code, con = "beta_binom.jags")

jags_data <- list(n = 40, y = 34)

jags_mod <- jags.model(
  file     = "beta_binom.jags",
  data     = jags_data,
  n.chains = 4,
  n.adapt  = 1000
)

update(jags_mod, n.iter = 1000)   # burn-in

fit_jags <- coda.samples(
  jags_mod,
  variable.names = "theta",
  n.iter         = 2000
)

summary(fit_jags)
