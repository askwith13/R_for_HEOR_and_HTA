# Extracted from ch03_r_essentials.typ, lines 478-484
# Section: == 3.7 Debugging and error handling
# Chapter: 3

run_model <- function(params) {
  browser()  # execution pauses here; inspect `params` interactively
  variance <- compute_variance(params)
  sqrt(variance)
}
