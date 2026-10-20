# Extracted from ch28_reproducible_reporting.typ, lines 731-741
# Section: === Scheduling the pipeline for recurring reporting
# Chapter: 28

# sketch of a _targets.R structure -- illustrative, not a tested pipeline
library(targets)
library(tarchetypes)

list(
  tar_target(district_data, load_district_notifications()),
  tar_target(fitted_model, fit_markov_model(district_data)),
  tar_render(district_report, "district_tb_report.qmd")
)
