# Extracted from ch23_budget_impact.typ, lines 375-407
# Section: == 23.3 Building a budget impact model in R
# Chapter: 23

library(dplyr)

build_bia <- function(
    years          = 1:5,
    eligible_pop   = rep(10000, 5),
    uptake_share   = c(0.05, 0.15, 0.30, 0.45, 0.55),
    cost_soc       = 500,
    cost_new       = 2000,
    offset_new     = 300
) {
  tibble(
    year                = years,
    eligible_population = eligible_pop,
    uptake_share        = uptake_share
  ) %>%
    mutate(
      patients_on_new  = eligible_population * uptake_share,
      patients_on_soc  = eligible_population - patients_on_new,
      # net per-patient cost of the new drug after the hospitalization offset
      net_cost_new     = cost_new - offset_new,
      cost_new_mix     = patients_on_new * net_cost_new + patients_on_soc * cost_soc,
      cost_current_mix = eligible_population * cost_soc,
      budget_impact    = cost_new_mix - cost_current_mix
    ) %>%
    select(year, eligible_population, uptake_share, patients_on_new, patients_on_soc,
           cost_current_mix, cost_new_mix, budget_impact)
}

bia_base <- build_bia()
bia_base$cumulative_bi <- cumsum(bia_base$budget_impact)
bia_base
