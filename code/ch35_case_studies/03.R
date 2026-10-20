# Extracted from ch35_case_studies.typ, lines 69-84
# Section: === Step (b): cohort simulation with discounting
# Chapter: 35

horizon <- 25
discount_cost <- 0.03
discount_qaly <- 0.03

run_trace <- function(tm) {
  trace <- matrix(0, nrow = horizon + 1, ncol = n_states,
                   dimnames = list(0:horizon, states))
  trace[1, ] <- c(1, 0, 0, 0, 0)
  for (t in 1:horizon) trace[t + 1, ] <- trace[t, ] %*% tm
  trace
}

trace_soc <- run_trace(tm_soc)
trace_new <- run_trace(tm_new)
