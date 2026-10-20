# Extracted from ch28_reproducible_reporting.typ, lines 103-118
# Section: === A worked example: rendering an HEOR summary report
# Chapter: 28

#| label: tbl-base-case
#| tbl-cap: "Base-case incremental results, New-regimen vs SoC"

library(gt)

base_case <- data.frame(
  Arm = c("SoC", "New-regimen", "Incremental"),
  Cost = c(5000.00, 4155.86, -844.14),
  QALY = c(3.210, 3.354, 0.1440)
)

gt(base_case) |>
  fmt_currency(columns = Cost, currency = "USD") |>
  fmt_number(columns = QALY, decimals = 4)
