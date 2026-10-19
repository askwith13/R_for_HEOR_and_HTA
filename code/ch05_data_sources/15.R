# Extracted from ch05_data_sources.typ, lines 535-546
# Section: == 5.6 Data quality checks (`pointblank`, `assertr`, `validate`)
# Chapter: 5

library(assertr)
library(dplyr)

cost_qaly_tbl |>
  verify(nrow(cost_qaly_tbl) > 0) |>
  assert(within_bounds(0, 1), qaly) |>
  assert(within_bounds(0, Inf), cost) |>
  assert(not_na, strategy, cost, qaly) |>
  # only rows that pass all assertions reach the dominance step
  arrange(cost)
