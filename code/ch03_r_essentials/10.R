# Extracted from ch03_r_essentials.typ, lines 206-224
# Section: == 3.4 Writing functions, parameter lists and defensive programming
# Chapter: 3

model_params <- list(
  p_progress     = 0.15,
  p_death        = 0.05,
  cost_well      = 1200,
  cost_sick      = 8500,
  util_well      = 0.85,
  util_sick      = 0.55,
  discount_rate  = 0.035,
  horizon        = 10
)

run_model <- function(params) {
  stopifnot(is.list(params))
  with(params, {
    # model logic refers to p_progress, cost_sick, etc. by name
  })
}
