# Extracted from ch05_data_sources.typ, lines 486-511
# Section: == 5.6 Data quality checks (`pointblank`, `assertr`, `validate`)
# Chapter: 5

library(pointblank)
library(dplyr)

# cost_qaly_tbl: one row per treatment arm, as used in Ch.4's
# dominance pipeline (cost, qaly, strategy columns)
cost_qaly_tbl <- tibble::tibble(
  strategy = c("Standard care", "New regimen", "Combination"),
  cost     = c(1200, 1850, -340),     # note the impossible negative cost
  qaly     = c(0.72, 0.81, 1.04),     # note the impossible utility > 1
  n_missing_followup = c(0, 3, NA)
)

agent <- create_agent(
  tbl = cost_qaly_tbl,
  label = "Cost-QALY QA before dominance analysis"
) |>
  col_vals_gte(columns = cost, value = 0) |>
  col_vals_lte(columns = qaly, value = 1) |>
  col_vals_gte(columns = qaly, value = 0) |>
  col_vals_not_null(columns = c(strategy, cost, qaly)) |>
  interrogate()

agent
# plot/export: get_agent_report(agent, display_table = FALSE)
