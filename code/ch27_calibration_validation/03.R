# Extracted from ch27_calibration_validation.typ, lines 131-143
# Section: == 27.2 Cross-validation of model structure
# Chapter: 27

# Model was calibrated only against the 5-year target from cohort 1 (27.1).
# Now check an out-of-sample prediction against cohort 2's independent data,
# which was never used anywhere in the calibration step above.
predicted_3yr_mortality <- run_tb_markov(
  p_hidden     = p_hidden_calibrated,
  arm          = "SoC",
  horizon_years = 3
)$mortality_5yr   # function returns cumulative mortality at the requested horizon

held_out_target <- 0.21
cross_val_gap <- predicted_3yr_mortality - held_out_target
