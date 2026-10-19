# Extracted from ch19_markov_cohort.typ, lines 344-371
# Section: == 19.10 Worked example: a chronic-disease CEA
# Chapter: 19

# Base-R cohort trace with half-cycle-corrected discounting, following §19.5's pattern
run_chronic_model <- function(tm, cost_vec, util_vec, cycles = 20, r = 0.03) {
  trace <- matrix(0, nrow = cycles + 1, ncol = 3)
  trace[1, ] <- c(1, 0, 0)                 # start: 100% Well
  for (t in 2:(cycles + 1)) {
    trace[t, ] <- trace[t - 1, ] %*% tm
  }
  total_cost <- 0; total_qaly <- 0
  for (t in 1:cycles) {
    avg_occ <- (trace[t, ] + trace[t + 1, ]) / 2   # half-cycle correction
    disc <- 1 / (1 + r)^t
    total_cost <- total_cost + sum(avg_occ * cost_vec) * disc
    total_qaly <- total_qaly + sum(avg_occ * util_vec) * disc
  }
  list(trace = trace, cost = total_cost, qaly = total_qaly)
}

tm_soc <- matrix(c(0.80, 0.15, 0.05,
                    0.00, 0.85, 0.15,
                    0.00, 0.00, 1.00), nrow = 3, byrow = TRUE)
tm_dmt <- matrix(c(0.85, 0.10, 0.05,
                    0.00, 0.90, 0.10,
                    0.00, 0.00, 1.00), nrow = 3, byrow = TRUE)

res_soc <- run_chronic_model(tm_soc, c(500, 8000, 0), c(0.90, 0.60, 0))
res_dmt <- run_chronic_model(tm_dmt, c(3500, 11000, 0), c(0.90, 0.60, 0))
