# Extracted from ch13_population_adjusted.typ, lines 49-71
# Section: == 13.2 Matching-adjusted indirect comparison (MAIC)
# Chapter: 13

# Toy MAIC weight estimation via method of moments
# x: matrix of IPD covariates to match (e.g., age, baseline severity)
# target_means: named vector of AgD-trial reported means for the same covariates

Q <- function(alpha, z) {
  # z = x - target_means, centered IPD covariates
  sum(exp(z %*% alpha))
}

z <- scale(ipd[, c("age", "severity")], center = target_means, scale = FALSE)

fit <- optim(
  par = rep(0, ncol(z)),
  fn  = Q,
  z   = z,
  method = "BFGS"
)

alpha_hat <- fit$par
w <- exp(z %*% alpha_hat)        # odds-weights, one per IPD patient
w <- w / mean(w)                  # optional rescaling, mean weight = 1
