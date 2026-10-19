# Extracted from ch09_costs_resource_use.typ, lines 103-115
# Section: == 9.2 Unit costs and inflation or currency conversion (PPP adjustments)
# Chapter: 9

ppp_factor_inr_per_intl_dollar <- c(
  "2022" = 22.9, "2023" = 23.5, "2024" = 24.1  # illustrative; source from World Bank ICP data
)

to_intl_dollars <- function(cost_local, year, ppp_lookup) {
  cost_local / ppp_lookup[[as.character(year)]]
}

# Convert the inflated 2024 INR cost to international dollars for cross-country comparison
cost_2024_inr <- inflate_cost(500, 2019, 2024, cpi_india)
to_intl_dollars(cost_2024_inr, 2024, ppp_factor_inr_per_intl_dollar)
