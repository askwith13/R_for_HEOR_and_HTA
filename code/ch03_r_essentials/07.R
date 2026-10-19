# Extracted from ch03_r_essentials.typ, lines 178-195
# Section: == 3.3 Functional programming with `purrr` and vectorization
# Chapter: 3

library(purrr)

scenarios <- list(
  base_case  = list(cost_visit = 185.50, visits = 4, n_patients = 250),
  high_cost  = list(cost_visit = 240.00, visits = 4, n_patients = 250),
  high_util  = list(cost_visit = 185.50, visits = 7, n_patients = 250)
)

calc_total_cost <- function(params) {
  params$cost_visit * params$visits * params$n_patients
}

total_costs <- map_dbl(scenarios, calc_total_cost)
total_costs
#>  base_case  high_cost  high_util
#>     185500     240000     324625
