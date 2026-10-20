# Extracted from ch25_handling_uncertainty.typ, lines 845-875
# Section: === The non-parametric bootstrap
# Chapter: 25

set.seed(321)

# ---- Step 1: simulate an illustrative patient-level trial dataset ----
# n = 150 per arm. A latent patient-level "engagement" factor links cost
# and QALY WITHIN each patient -- the within-patient correlation a real
# trial dataset would also show (commonly in the opposite direction:
# sicker patients cost more and do worse), but the mechanics of
# preserving that correlation in the bootstrap are identical either way.
simulate_arm <- function(n, mean_qaly_base, cost_base, qaly_slope, cost_slope) {
  engagement <- rnorm(n, 0, 1)
  qaly <- mean_qaly_base + qaly_slope * engagement + rnorm(n, 0, 0.04)
  qaly <- pmin(pmax(qaly, 0.1), 1.0)
  cost_mean <- pmax(cost_base + cost_slope * engagement, 200)
  cost <- rgamma(n, shape = 6, scale = cost_mean / 6)   # right-skewed
  data.frame(qaly = qaly, cost = cost)
}

trial_new <- simulate_arm(150, mean_qaly_base = 0.72, cost_base = 3200,
                           qaly_slope = 0.10, cost_slope = 700)
trial_soc <- simulate_arm(150, mean_qaly_base = 0.68, cost_base = 3000,
                           qaly_slope = 0.10, cost_slope = 700)

cor(trial_new$cost, trial_new$qaly)   # within-patient correlation, New arm
cor(trial_soc$cost, trial_soc$qaly)   # within-patient correlation, SoC arm

inc_cost_obs <- mean(trial_new$cost) - mean(trial_soc$cost)
inc_qaly_obs <- mean(trial_new$qaly) - mean(trial_soc$qaly)
icer_obs <- inc_cost_obs / inc_qaly_obs
nmb_obs  <- inc_qaly_obs * 50000 - inc_cost_obs
