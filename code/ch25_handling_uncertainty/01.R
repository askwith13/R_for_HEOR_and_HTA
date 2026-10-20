# Extracted from ch25_handling_uncertainty.typ, lines 131-177
# Section: === Worked example: one-way sensitivity analysis on the TB regimen-choice model
# Chapter: 25

run_tb_model <- function(p_ontx_fail, p_ontx_cured,
                          cost_ontx, cost_cured = 50, cost_fail = 4000,
                          util_ontx, util_cured = 0.90, util_fail = 0.40,
                          p_fail_retx = 0.60, p_fail_die = 0.15, p_cured_die = 0.01,
                          r = 0.01735, cycles = 20) {
  p_ontx_die  <- 0.02
  p_ontx_stay <- 1 - p_ontx_cured - p_ontx_fail - p_ontx_die
  stopifnot(p_ontx_stay >= 0)

  P <- matrix(c(
    p_ontx_stay,   p_ontx_cured, p_ontx_fail,               p_ontx_die,
    0,             1 - p_cured_die, 0,                      p_cured_die,
    p_fail_retx,   0,            1 - p_fail_retx - p_fail_die, p_fail_die,
    0,             0,            0,                          1
  ), nrow = 4, byrow = TRUE)
  stopifnot(all(abs(rowSums(P) - 1) < 1e-9))

  trace <- matrix(0, nrow = cycles + 1, ncol = 4)
  trace[1, ] <- c(1, 0, 0, 0)
  for (t in seq_len(cycles)) trace[t + 1, ] <- trace[t, ] %*% P

  cost_vec <- c(cost_ontx, cost_cured, cost_fail, 0)
  util_vec <- c(util_ontx, util_cured, util_fail, 0)
  total_cost <- 0; total_qaly <- 0
  for (t in seq_len(cycles)) {
    avg_occ <- (trace[t, ] + trace[t + 1, ]) / 2       # half-cycle correction
    disc <- 1 / (1 + r)^t
    total_cost <- total_cost + sum(avg_occ * cost_vec) * disc
    total_qaly <- total_qaly + sum(avg_occ * util_vec) * disc
  }
  list(cost = total_cost, qaly = total_qaly)
}

soc_base <- list(p_ontx_fail = 0.08, p_ontx_cured = 0.75, cost_ontx = 2500, util_ontx = 0.65)
new_base <- list(p_ontx_fail = 0.05, p_ontx_cured = 0.80, cost_ontx = 1800, util_ontx = 0.65)

WTP <- 50000

incremental_nmb <- function(soc_args, new_args) {
  soc <- do.call(run_tb_model, soc_args)
  new <- do.call(run_tb_model, new_args)
  WTP * (new$qaly - soc$qaly) - (new$cost - soc$cost)
}

base_nmb <- incremental_nmb(soc_base, new_base)   # $8,044 (independently verified in Python)
