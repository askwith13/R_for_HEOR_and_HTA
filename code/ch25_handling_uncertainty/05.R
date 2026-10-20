# Extracted from ch25_handling_uncertainty.typ, lines 327-362
# Section: == 25.3 Scenario analysis scripts
# Chapter: 25

state_names <- c("OnTx", "Cured", "Fail", "Death")

build_P <- function(p_ontx_cure, p_ontx_fail, p_ontx_death,
                     p_fail_retreat, p_fail_death, p_cured_death) {
  p_ontx_stay  <- 1 - p_ontx_cure - p_ontx_fail - p_ontx_death
  p_fail_stay  <- 1 - p_fail_retreat - p_fail_death
  p_cured_stay <- 1 - p_cured_death
  P <- matrix(
    c(p_ontx_stay,   p_ontx_cure, p_ontx_fail,    p_ontx_death,
      0,              p_cured_stay, 0,            p_cured_death,
      p_fail_retreat, 0,           p_fail_stay,    p_fail_death,
      0,              0,           0,              1),
    nrow = 4, byrow = TRUE, dimnames = list(state_names, state_names)
  )
  stopifnot(all(abs(rowSums(P) - 1) < 1e-9))  # same defensive check as §19.1/19.3
  P
}

# The model function: takes ONE named list of parameters, returns discounted
# total cost and QALYs -- exactly the signature a scenario-analysis wrapper needs.
run_tb_model <- function(params, n_cycles = 20, disc_rate = 0.01735) {
  P <- build_P(params$p_ontx_cure, params$p_ontx_fail, params$p_ontx_death,
               params$p_fail_retreat, params$p_fail_death, params$p_cured_death)
  costs <- c(params$cost_ontx, params$cost_cured, params$cost_fail, 0)
  utils <- c(params$u_ontx, params$u_cured, params$u_fail, 0)

  trace <- matrix(NA_real_, n_cycles + 1, 4)
  trace[1, ] <- c(1, 0, 0, 0)
  for (t in seq_len(n_cycles)) trace[t + 1, ] <- trace[t, ] %*% P

  disc <- (1 + disc_rate) ^ -(1:n_cycles)
  c(total_cost = sum((trace[-1, ] %*% costs) * disc),
    total_qaly = sum((trace[-1, ] %*% utils) * 0.5 * disc))  # 0.5 yr per 6-month cycle
}
