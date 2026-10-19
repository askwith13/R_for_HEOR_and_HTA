# Extracted from ch20_partitioned_survival.typ, lines 145-171
# Section: == 20.6 Worked example: an oncology CEA
# Chapter: 20

run_arm <- function(a, n_cycles = 20, cycle_len = 0.5, r = 0.035) {
  t <- seq(0, n_cycles * cycle_len, by = cycle_len)
  s_pfs <- weib_S(t, a$pfs["shape"], a$pfs["scale"])
  s_os  <- weib_S(t, a$os["shape"],  a$os["scale"])
  p_pfs  <- s_pfs
  p_dead <- 1 - s_os
  p_prog <- pmax(0, s_os - s_pfs)

  total_cost <- 0; total_qaly <- 0
  for (i in 2:length(t)) {
    df <- (1 + r)^(-(t[i-1] + t[i]) / 2)       # mid-cycle discount factor
    avg_pfs  <- (p_pfs[i-1]  + p_pfs[i])  / 2
    avg_prog <- (p_prog[i-1] + p_prog[i]) / 2
    new_deaths <- p_dead[i] - p_dead[i-1]
    cyc_cost <- avg_pfs * a$cost_pfs + avg_prog * a$cost_prog +
                new_deaths * a$cost_death
    cyc_qaly <- (avg_pfs * util_pfs + avg_prog * util_prog) * cycle_len
    total_cost <- total_cost + cyc_cost * df
    total_qaly <- total_qaly + cyc_qaly * df
  }
  c(cost = total_cost, qaly = total_qaly)
}

res <- sapply(arms, run_arm)
res
