# Extracted from ch24_cba_dcea_ecea.typ, lines 384-412
# Section: === A toy two-subgroup worked example
# Chapter: 24

library(dplyr)

subgroups <- tibble::tibble(
  group           = c("Q1_most_deprived", "Q5_least_deprived"),
  n_patients      = c(1000, 1000),
  cost_per_pt     = c(2000, 2000),
  qaly_gain_pt    = c(0.12, 0.08),
  equity_weight   = c(1.5, 1.0)   # Q1 QALYs up-weighted 1.5x; Q5 left at 1.0
)

subgroups <- subgroups |>
  mutate(
    total_cost        = n_patients * cost_per_pt,
    total_qaly        = n_patients * qaly_gain_pt,
    weighted_qaly      = total_qaly * equity_weight
  )

total_cost          <- sum(subgroups$total_cost)
total_qaly          <- sum(subgroups$total_qaly)
total_weighted_qaly <- sum(subgroups$weighted_qaly)

icer_unweighted <- total_cost / total_qaly
icer_weighted   <- total_cost / total_weighted_qaly

subgroups
icer_unweighted   # cost per unweighted QALY
icer_weighted     # cost per equity-weighted QALY
