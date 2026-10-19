# Extracted from ch03_r_essentials.typ, lines 232-244
# Section: == 3.4 Writing functions, parameter lists and defensive programming
# Chapter: 3

run_model <- function(params) {
  stopifnot(
    is.list(params),
    is.numeric(params$p_progress),
    params$p_progress >= 0, params$p_progress <= 1,
    is.numeric(params$discount_rate),
    params$discount_rate >= 0, params$discount_rate < 1,
    params$horizon > 0
  )
  # ... model logic ...
}
