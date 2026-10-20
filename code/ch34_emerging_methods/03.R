# Extracted from ch34_emerging_methods.typ, lines 164-187
# Section: === Synthetic data
# Chapter: 34

library(dplyr)

# Suppose `real_data` has columns `age` and `cost` from a real
# (here illustrative) patient-level dataset we cannot redistribute
set.seed(123)
real_data <- data.frame(
  age  = rnorm(200, mean = 62, sd = 11),
  cost = rgamma(200, shape = 2, rate = 1 / 4000)
)

# Fit simple parametric summaries via method of moments
age_mean   <- mean(real_data$age); age_sd <- sd(real_data$age)
cost_mean  <- mean(real_data$cost); cost_var <- var(real_data$cost)
cost_shape <- cost_mean^2 / cost_var
cost_rate  <- cost_mean / cost_var

# Generate a synthetic dataset matching those marginal distributions
n_synth <- nrow(real_data)
synthetic_data <- data.frame(
  age  = rnorm(n_synth, mean = age_mean, sd = age_sd),
  cost = rgamma(n_synth, shape = cost_shape, rate = cost_rate)
)
