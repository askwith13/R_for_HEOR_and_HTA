# Extracted from ch18_decision_trees.typ, lines 94-109
# Section: == 18.2 Building decision trees from scratch in R
# Chapter: 18

ev <- tb_tree |>
  group_by(strategy) |>
  summarise(
    ev_cost = sum(path_prob * cost),
    ev_qaly = sum(path_prob * qaly)
  )
ev
#> strategy ev_cost ev_qaly
#> Smear      60.40 0.93302
#> Xpert      63.80 0.95454

icer <- diff(ev$ev_cost) / diff(ev$ev_qaly)
icer
#> [1] 157.99...
