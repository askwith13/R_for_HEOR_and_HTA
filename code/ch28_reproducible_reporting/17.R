# Extracted from ch28_reproducible_reporting.typ, lines 386-393
# Section: === Worked example: an ICER summary table
# Chapter: 28

library(knitr)
library(kableExtra)

kbl(icer_table, caption = "TB model: incremental cost-effectiveness results",
    digits = 4) |>
  kable_styling(full_width = FALSE, bootstrap_options = "striped")
