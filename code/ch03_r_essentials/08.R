# Extracted from ch03_r_essentials.typ, lines 199-212
# Section: == 3.3 Functional programming with `purrr` and vectorization
# Chapter: 3

visit_counts <- c(4, 5, 6)
cost_per_visit <- c(185.50, 185.50, 200.00)

map2_dbl(visit_counts, cost_per_visit, ~ .x * .y * 250)

param_grid <- list(
  cost_visit  = c(185.50, 200.00, 220.00),
  visits      = c(4, 5, 6),
  n_patients  = c(250, 250, 300)
)

pmap_dbl(param_grid, calc_total_cost)
