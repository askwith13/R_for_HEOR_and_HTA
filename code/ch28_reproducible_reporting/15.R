# Extracted from ch28_reproducible_reporting.typ, lines 341-355
# Section: === Worked example: an ICER summary table
# Chapter: 28

library(gt)

icer_table <- data.frame(
  Arm = c("SoC", "New-regimen", "Incremental"),
  Cost = c(5000.00, 4155.86, -844.14),
  QALY = c(3.2100, 3.3540, 0.1440),
  check.names = FALSE
)

gt(icer_table) |>
  fmt_currency(columns = Cost, currency = "USD") |>
  fmt_number(columns = QALY, decimals = 4) |>
  tab_header(title = "TB model: incremental cost-effectiveness results")
