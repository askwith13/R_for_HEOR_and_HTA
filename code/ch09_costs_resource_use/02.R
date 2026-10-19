# Extracted from ch09_costs_resource_use.typ, lines 44-59
# Section: == 9.1 Identifying, measuring and valuing resources
# Chapter: 9

unit_costs <- tribble(
  ~item,                ~unit_cost_local, ~currency, ~cost_year,
  "xpert_test",          800,              "INR",     2023,
  "fdc_regimen",         450,              "INR",     2023,
  "dot_visit",           150,              "INR",     2023,
  "culture_dst",         1200,             "INR",     2023,
  "second_line_regimen", 3200,             "INR",     2023
)

costed <- resource_use |>
  left_join(unit_costs, by = "item") |>
  mutate(total_cost_local = quantity * unit_cost_local)

costed
