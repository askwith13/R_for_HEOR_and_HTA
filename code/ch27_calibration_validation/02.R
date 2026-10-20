# Extracted from ch27_calibration_validation.typ, lines 63-80
# Section: === Nelder-Mead optimization
# Chapter: 27

objective_fn <- function(p_hidden) {
  # optim() with Nelder-Mead can propose a value outside [0,1]; guard it
  p_hidden <- min(max(p_hidden, 0.001), 0.999)
  predicted <- run_model_mortality(p_hidden)
  (predicted - target_mortality)^2
}

fit <- optim(
  par    = 0.15,              # starting guess for p_hidden
  fn     = objective_fn,
  method = "Nelder-Mead",
  control = list(reltol = 1e-8)
)

p_hidden_calibrated <- fit$par
calibration_sq_error <- fit$value
