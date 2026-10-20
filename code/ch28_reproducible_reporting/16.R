# Extracted from ch28_reproducible_reporting.typ, lines 374-382
# Section: === Worked example: an ICER summary table
# Chapter: 28

library(flextable)

flextable(icer_table) |>
  flextable::colformat_double(j = "Cost", digits = 2) |>
  flextable::colformat_double(j = "QALY", digits = 4) |>
  flextable::set_caption("TB model: incremental cost-effectiveness results") |>
  flextable::autofit()
