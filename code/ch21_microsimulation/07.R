# Extracted from ch21_microsimulation.typ, lines 212-215
# Section: == 21.6 Using `hesim` for individual-level models
# Chapter: 21

utility_model <- create_StateVals(tbl = utility_tbl, n = 1000, hesim_data = hesim_dat)
cost_model    <- create_StateVals(tbl = cost_tbl,    n = 1000, hesim_data = hesim_dat)
