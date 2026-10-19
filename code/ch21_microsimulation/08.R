# Extracted from ch21_microsimulation.typ, lines 219-228
# Section: == 21.6 Using `hesim` for individual-level models
# Chapter: 21

ictstm <- IndivCtstm$new(trans_model   = trans_model,
                          utility_model = utility_model,
                          cost_models   = list(cost_model))

ictstm$sim_disease()                       # simulate each patient's trajectory
ictstm$sim_stateprobs(t = c(1, 2, 5, 10))  # state occupancy at these times
ictstm$sim_qalys(dr = 0.035)               # discounted QALYs per patient
ictstm$sim_costs(dr = 0.035)               # discounted costs per patient
