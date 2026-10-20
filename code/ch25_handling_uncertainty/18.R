# Extracted from ch25_handling_uncertainty.typ, lines 879-910
# Section: === The non-parametric bootstrap
# Chapter: 25

# ---- Step 2: non-parametric bootstrap, B = 2000 replicates ----
B <- 2000
n_new <- nrow(trial_new)
n_soc <- nrow(trial_soc)

boot_inc_cost <- numeric(B)
boot_inc_qaly <- numeric(B)
boot_nmb      <- numeric(B)
wtp <- 50000

for (b in seq_len(B)) {
  # resample WHOLE ROWS, with replacement, independently per arm --
  # this is what preserves each patient's own cost-QALY pairing
  idx_new <- sample(seq_len(n_new), n_new, replace = TRUE)
  idx_soc <- sample(seq_len(n_soc), n_soc, replace = TRUE)

  boot_new <- trial_new[idx_new, ]
  boot_soc <- trial_soc[idx_soc, ]

  d_cost <- mean(boot_new$cost) - mean(boot_soc$cost)
  d_qaly <- mean(boot_new$qaly) - mean(boot_soc$qaly)

  boot_inc_cost[b] <- d_cost
  boot_inc_qaly[b] <- d_qaly
  boot_nmb[b]      <- d_qaly * wtp - d_cost
}

mean(boot_nmb)
quantile(boot_nmb, c(0.025, 0.975))
mean(boot_nmb > 0)   # bootstrap estimate of P(New is cost-effective at this WTP)
