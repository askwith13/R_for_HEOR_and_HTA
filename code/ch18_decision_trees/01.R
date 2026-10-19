# Extracted from ch18_decision_trees.typ, lines 64-90
# Section: == 18.2 Building decision trees from scratch in R
# Chapter: 18

library(dplyr)

tb_tree <- tibble::tribble(
  ~strategy, ~outcome, ~p_disease, ~p_test, ~cost_test, ~cost_downstream, ~qaly,
  "Smear",   "TP",      0.30,       0.60,    5,          100,              0.95,
  "Smear",   "FN",      0.30,       0.40,    5,          300,              0.70,
  "Smear",   "FP",      0.70,       0.02,    5,          100,              0.90,
  "Smear",   "TN",      0.70,       0.98,    5,          0,                0.97,
  "Xpert",   "TP",      0.30,       0.90,    25,         100,              0.95,
  "Xpert",   "FN",      0.30,       0.10,    25,         300,              0.70,
  "Xpert",   "FP",      0.70,       0.04,    25,         100,              0.90,
  "Xpert",   "TN",      0.70,       0.96,    25,         0,                0.97
)

tb_tree <- tb_tree |>
  mutate(
    path_prob = p_disease * p_test,     # the branch-probability product
    cost      = cost_test + cost_downstream
  )

# sanity check: branch probabilities must sum to 1 within each strategy
tb_tree |>
  group_by(strategy) |>
  summarise(total_prob = sum(path_prob))
#> Smear: 1.000   Xpert: 1.000
