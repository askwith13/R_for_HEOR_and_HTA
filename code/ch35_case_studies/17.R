# Extracted from ch35_case_studies.typ, lines 579-610
# Section: === 35.3.5 First-order vs second-order uncertainty in practice
# Chapter: 35

run_arm_param <- function(N, frailty, screening, sens_preclin_crc,
                           p_preclin_to_clinical_base, cost_clinical_tx_yr,
                           p_clinical_crc_death_base) {
  # ... identical cycle loop to run_arm() above, but with these four arguments
  # substituted for their fixed base-case values ...
}

N_psa <- 20000; n_draws <- 40

# (A) First-order only: parameters fixed, only patient-level randomness varies
first_order_icers <- numeric(n_draws)
for (i in 1:n_draws) {
  frailty <- rlnorm(N_psa, meanlog = -0.5*0.6^2, sdlog = 0.6)
  rs <- run_arm_param(N_psa, frailty, TRUE,  0.95, 0.30, 9000, 0.22)
  rn <- run_arm_param(N_psa, frailty, FALSE, 0.95, 0.30, 9000, 0.22)
  first_order_icers[i] <- (rs["cost"] - rn["cost"]) / (rs["qaly"] - rn["qaly"])
}

# (B) Second-order: additionally resample structural parameters each draw
second_order_icers <- numeric(n_draws)
for (i in 1:n_draws) {
  frailty <- rlnorm(N_psa, meanlog = -0.5*0.6^2, sdlog = 0.6)
  sens_i <- rbeta(1, 95*4, 5*4)                                   # centred ~0.95
  p_pc_i <- rbeta(1, 30*6, 70*6)                                   # centred ~0.30
  cost_i <- rgamma(1, shape = (9000/900)^2, rate = 9000/900^2)     # mean 9000, sd ~900
  pcd_i  <- rbeta(1, 22*8, 78*8)                                   # centred ~0.22
  rs <- run_arm_param(N_psa, frailty, TRUE,  sens_i, p_pc_i, cost_i, pcd_i)
  rn <- run_arm_param(N_psa, frailty, FALSE, sens_i, p_pc_i, cost_i, pcd_i)
  second_order_icers[i] <- (rs["cost"] - rn["cost"]) / (rs["qaly"] - rn["qaly"])
}
