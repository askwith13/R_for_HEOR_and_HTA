# Extracted from ch09_costs_resource_use.typ, lines 119-128
# Section: == 9.2 Unit costs and inflation or currency conversion (PPP adjustments)
# Chapter: 9

costed_reported <- costed |>
  mutate(
    total_cost_2024_inr = inflate_cost(total_cost_local, cost_year, 2024, cpi_india),
    total_cost_2024_intl_usd = to_intl_dollars(total_cost_2024_inr, 2024,
                                                ppp_factor_inr_per_intl_dollar)
  )

costed_reported
