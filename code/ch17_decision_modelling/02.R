# Extracted from ch17_decision_modelling.typ, lines 155-176
# Section: == 17.4 Parameter taxonomy and distributions
# Chapter: 17

# Method-of-moments beta fit from a trial's reported mean and 95% CI
mean_p <- 0.85
ci_lower <- 0.80
ci_upper <- 0.90

se_p <- (ci_upper - ci_lower) / (2 * 1.96)
var_p <- se_p^2

common_term <- (mean_p * (1 - mean_p) / var_p) - 1
alpha_p <- mean_p * common_term
beta_p  <- (1 - mean_p) * common_term

alpha_p  # 165.68
beta_p   #  29.24

# Check: does Beta(alpha_p, beta_p) reproduce the mean and SE we started with?
fitted_mean <- alpha_p / (alpha_p + beta_p)
fitted_var  <- (alpha_p * beta_p) / ((alpha_p + beta_p)^2 * (alpha_p + beta_p + 1))
fitted_mean          # 0.85 -- matches
sqrt(fitted_var)     # 0.0255 -- matches se_p
