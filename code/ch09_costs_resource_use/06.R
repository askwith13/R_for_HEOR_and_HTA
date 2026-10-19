# Extracted from ch09_costs_resource_use.typ, lines 158-189
# Section: == 9.3 Cost data features: skewness, zero-inflation, heavy tails
# Chapter: 9

library(tidyverse)

set.seed(9340)
n <- 1200

# Simulate a TB cohort: ~30% zero-cost (no qualifying resource use),
# positive costs right-skewed (gamma), with a few heavy-tail outliers.
zero_flag  <- rbinom(n, 1, prob = 0.30)
base_cost  <- rgamma(n, shape = 1.4, scale = 180)       # typical positive costs
outlier    <- rbinom(n, 1, prob = 0.02) * rgamma(n, shape = 2, scale = 4000)  # rare catastrophic cases
cost <- ifelse(zero_flag == 1, 0, base_cost + outlier)

tb_costs <- tibble(
  patient_id = seq_len(n),
  regimen    = sample(c("first_line", "mdr_regimen"), n, replace = TRUE, prob = c(0.85, 0.15)),
  age        = round(rnorm(n, 38, 13)),
  cost       = cost
)

tb_costs |>
  summarise(
    n_patients   = n(),
    pct_zero     = mean(cost == 0) * 100,
    mean_cost    = mean(cost),
    median_cost  = median(cost),
    sd_cost      = sd(cost),
    skewness     = mean((cost - mean(cost))^3) / sd(cost)^3,
    p95          = quantile(cost, 0.95),
    max_cost     = max(cost)
  )
