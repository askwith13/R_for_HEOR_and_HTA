# Extracted from ch30_r_packages_pipelines.typ, lines 160-171
# Section: == 30.4 Pipelines with `targets` and `renv`
# Chapter: 30

# _targets.R (illustrative)
library(targets)

list(
  tar_target(raw_data, read_patient_data("data/raw_cohort.csv")),
  tar_target(clean_data, clean_cohort(raw_data)),
  tar_target(calibrated_params, calibrate_model(clean_data)),
  tar_target(psa_results, run_psa(calibrated_params, n_sims = 10000)),
  tar_target(ceac_plot, make_ceac(psa_results))
)
