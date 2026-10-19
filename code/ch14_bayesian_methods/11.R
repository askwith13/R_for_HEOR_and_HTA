# Extracted from ch14_bayesian_methods.typ, lines 407-447
# Section: === Posterior draws as PSA input: the direct pipeline
# Chapter: 14

library(dplyr)

# re_samples: posterior draws of relative treatment effect from gemtc/NMA (14.5)
# n_psa draws, one row per PSA iteration, columns are contrasts

n_psa <- nrow(re_samples)

# Other model inputs can also come from posteriors -- e.g. a Bayesian
# survival model's posterior draws of a hazard ratio, or simple
# independent draws if those parameters weren't modelled jointly
cost_psa    <- rgamma(n_psa, shape = 20, rate = 20 / 3500)
utility_psa <- rbeta(n_psa, shape1 = 40, shape2 = 10)

psa_results <- vector("list", n_psa)

for (i in seq_len(n_psa)) {
  log_hr <- re_samples[i, "d.placebo.treatment"]

  qalys_treatment <- simulate_qalys(hr = exp(log_hr), utility = utility_psa[i])
  cost_treatment  <- simulate_costs(hr = exp(log_hr), unit_cost = cost_psa[i])

  psa_results[[i]] <- data.frame(
    iteration = i,
    nmb_treatment = 30000 * qalys_treatment - cost_treatment,
    nmb_control   = 30000 * simulate_qalys(hr = 1, utility = utility_psa[i]) -
                     simulate_costs(hr = 1, unit_cost = cost_psa[i])
  )
}

psa_df <- bind_rows(psa_results)

# Expected net monetary benefit per strategy, and probability treatment
# is cost-effective at this threshold
psa_df |>
  summarise(
    E_nmb_treatment = mean(nmb_treatment),
    E_nmb_control   = mean(nmb_control),
    prob_ce         = mean(nmb_treatment > nmb_control)
  )
