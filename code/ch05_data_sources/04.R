# Extracted from ch05_data_sources.typ, lines 216-233
# Section: === Delimited and flat files with `readr`
# Chapter: 5

library(readr)

# Import quarterly unit-cost data exported from a costing database
unit_costs <- read_csv(
  "data/unit_costs_2023q4.csv",
  col_types = cols(
    facility_id   = col_character(),
    cost_centre   = col_character(),
    unit_cost_usd = col_double(),
    report_date   = col_date(format = "%Y-%m-%d")
  ),
  na = c("", "NA", "N/A", "-99")
)

problems(unit_costs)   # surfaces any parsing failures row-by-row
spec(unit_costs)       # the frozen column specification, paste into the script
