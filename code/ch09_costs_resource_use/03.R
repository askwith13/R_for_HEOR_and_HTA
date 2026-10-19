# Extracted from ch09_costs_resource_use.typ, lines 88-99
# Section: == 9.2 Unit costs and inflation or currency conversion (PPP adjustments)
# Chapter: 9

inflate_cost <- function(cost, cost_year, target_year, cpi) {
  # cpi: named vector or lookup keyed by year, e.g. cpi["2023"], cpi["2024"]
  cost * (cpi[[as.character(target_year)]] / cpi[[as.character(cost_year)]])
}

cpi_india <- c("2019" = 100, "2020" = 106, "2021" = 112,
               "2022" = 121, "2023" = 128, "2024" = 134)

# Example: inflate a 2019 unit cost to 2024 prices
inflate_cost(cost = 500, cost_year = 2019, target_year = 2024, cpi = cpi_india)
