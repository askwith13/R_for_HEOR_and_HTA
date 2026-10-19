# Extracted from ch06_slr_support.typ, lines 303-340
# Section: == 6.4 Data extraction templates and extraction QA
# Chapter: 6

library(tibble)
library(dplyr)

extraction_template <- tibble(
  study_id        = character(),  # e.g. "Nguyen2021"
  reviewer_id     = character(),  # who extracted this row
  population      = character(),
  intervention    = character(),
  comparator      = character(),
  outcome_name    = character(),  # e.g. "treatment_success"
  outcome_timepoint = character(),
  effect_measure  = character(),  # "RR", "OR", "HR", "MD"
  effect_estimate = double(),
  ci_lower        = double(),
  ci_upper        = double(),
  n_intervention  = integer(),
  n_comparator    = integer(),
  rob_domain_1    = character(), # e.g. randomisation process
  rob_domain_2    = character(),
  rob_overall     = character(), # "Low", "Some concerns", "High"
  notes           = character()
)

# one extracted row, reviewer A
extraction_template <- extraction_template %>%
  add_row(
    study_id = "Nguyen2021", reviewer_id = "RA",
    population = "Adults, drug-sensitive PTB",
    intervention = "4-month regimen", comparator = "6-month regimen",
    outcome_name = "treatment_success", outcome_timepoint = "end_of_treatment",
    effect_measure = "RR", effect_estimate = 0.98,
    ci_lower = 0.92, ci_upper = 1.04,
    n_intervention = 310, n_comparator = 308,
    rob_domain_1 = "Low", rob_domain_2 = "Some concerns",
    rob_overall = "Some concerns", notes = "ITT analysis used"
  )
