# Extracted from ch14_bayesian_methods.typ, lines 500-517
# Section: == 14.7 Expert elicitation methods (SHELF)
# Chapter: 14

library(SHELF)

# Example: an expert has given judgements for a response-rate
# parameter as quantiles: 25th percentile = 0.30, median = 0.45,
# 75th percentile = 0.60
my_probs <- c(0.25, 0.5, 0.75)
my_vals  <- c(0.30, 0.45, 0.60)

fit <- SHELF::fitdist(vals = my_vals, probs = my_probs,
                       lower = 0, upper = 1)

# Inspect which parametric family fits best
fit$ssq

# Visualise the fitted distribution(s) against the elicited points
SHELF::plotfit(fit, lp = TRUE)
