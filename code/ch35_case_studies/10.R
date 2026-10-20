# Extracted from ch35_case_studies.typ, lines 266-295
# Section: === Step (c): partitioning into health states and attaching costs/utilities
# Chapter: 35

horizon_months <- 120
cycles <- 0:horizon_months
disc_vec <- 1 / (1.03)^(cycles / 12)

partition <- function(arm) {
  s_pfs <- S_pfs(cycles, arm)
  s_os  <- pmax(S_os(cycles, arm), s_pfs)   # OS survival >= PFS survival
  pre_prog  <- s_pfs
  post_prog <- pmax(s_os - s_pfs, 0)
  dead      <- 1 - s_os
  data.frame(month = cycles, pre_prog = pre_prog, post_prog = post_prog, dead = dead)
}

part_comp <- partition("comp")
part_new  <- partition("new")

cost_pre_prog  <- 2400; cost_post_prog <- 3100; cost_terminal <- 9500
drug_cost_new  <- 6800   # new agent's own monthly drug cost, pre-progression only
util_pre_prog  <- 0.78;  util_post_prog <- 0.62

cost_qaly <- function(part, drug_month = 0) {
  incident_deaths <- pmax(c(0, diff(part$dead)), 0)
  cost_month <- part$pre_prog * (cost_pre_prog + drug_month) +
                part$post_prog * cost_post_prog +
                incident_deaths * cost_terminal
  qaly_month <- (part$pre_prog * util_pre_prog + part$post_prog * util_post_prog) / 12
  list(cost = sum(cost_month * disc_vec), qaly = sum(qaly_month * disc_vec))
}
