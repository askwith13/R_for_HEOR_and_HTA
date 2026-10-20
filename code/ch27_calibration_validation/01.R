# Extracted from ch27_calibration_validation.typ, lines 28-47
# Section: === Random search
# Chapter: 27

set.seed(123)
n_draws <- 500
p_hidden_candidates <- runif(n_draws, min = 0.01, max = 0.30)

run_model_mortality <- function(p_hidden) {
  # run_tb_markov() is the Chapter 19 cohort model, extended to accept
  # the hidden parameter and return 5-year all-cause mortality under SoC
  result <- run_tb_markov(p_hidden = p_hidden, arm = "SoC", horizon_years = 5)
  result$mortality_5yr
}

predicted_mortality <- sapply(p_hidden_candidates, run_model_mortality)
target_mortality <- 0.32

# squared-error distance from target
sq_error <- (predicted_mortality - target_mortality)^2
best_idx <- which.min(sq_error)
p_hidden_best_rs <- p_hidden_candidates[best_idx]
