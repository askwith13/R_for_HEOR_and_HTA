# Extracted from ch28_reproducible_reporting.typ, lines 283-292
# Section: === Native editable Word and PowerPoint elements with officer/officedown
# Chapter: 28

library(officer)
library(flextable)

ft <- flextable(base_case) |>
  flextable::autofit()

ft   # printed inside an officedown Word chunk renders as a fully
     # native, directly editable Word table, not an embedded image
