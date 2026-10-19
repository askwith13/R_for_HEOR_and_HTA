# Extracted from ch09_costs_resource_use.typ, lines 24-38
# Section: == 9.1 Identifying, measuring and valuing resources
# Chapter: 9

library(tibble)
library(dplyr)

resource_use <- tribble(
  ~patient_id, ~health_state, ~item,              ~category,    ~quantity, ~unit,
  "TB001",     "on_treatment","xpert_test",       "diagnostic", 1,         "test",
  "TB001",     "on_treatment","fdc_regimen",       "drug",       6,         "month",
  "TB001",     "on_treatment","dot_visit",         "programmatic",24,       "visit",
  "TB002",     "retreatment", "culture_dst",       "diagnostic", 1,         "test",
  "TB002",     "retreatment", "second_line_regimen","drug",      8,         "month"
)

resource_use
