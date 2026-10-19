# Extracted from ch19_markov_cohort.typ, lines 253-272
# Section: == 19.7 Age-dependent transitions and background mortality
# Chapter: 19

library(heemod)

# Illustrative life-table lookup keyed on model_time (age = start_age + model_time)
background_mortality <- function(model_time, start_age = 45) {
  age <- start_age + model_time
  dplyr::case_when(
    age < 50 ~ 0.01,
    age < 65 ~ 0.03,
    TRUE     ~ 0.08
  )
}

# Combine via additive hazards, cycle length = 0.5 years (6-month cycles)
p_combined_death <- function(p_disease, model_time) {
  h_disease <- -log(1 - p_disease)
  h_bg      <- -log(1 - background_mortality(model_time))
  1 - exp(-(h_disease + h_bg))
}
