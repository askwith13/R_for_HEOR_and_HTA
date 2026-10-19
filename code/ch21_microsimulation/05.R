# Extracted from ch21_microsimulation.typ, lines 203-218
# Section: == 21.6 Using `hesim` for individual-level models
# Chapter: 21

library(hesim)

hesim_dat <- hesim_data(
  strategies = data.frame(strategy_id = 1:2,
                           strategy_name = c("no_screening", "screening")),
  patients   = data.frame(patient_id = 1:1000,
                           age        = patient_age,
                           risk       = patient_risk),
  states     = data.frame(state_id = 1:4,
                           state_name = c("undetected", "detected",
                                           "cured", "death"))
)

input_data <- expand(hesim_dat, by = c("strategies", "patients"))
