# Extracted from ch07_missing_data.typ, lines 145-177
# Section: == 7.4 Multiple imputation (mice, Amelia, missForest)
# Chapter: 7

library(tidyverse)
library(mice)

set.seed(42)
heor_data <- tibble(
  patient_id = 1:40,
  treatment  = rep(c("A", "B"), each = 20),
  cost       = rnorm(40, mean = 1200, sd = 300),
  qaly       = rnorm(40, mean = 0.70, sd = 0.08)
)

# Inject missingness into cost and qaly
heor_miss <- heor_data |>
  mutate(
    cost = if_else(runif(40) < 0.25, NA_real_, cost),
    qaly = if_else(runif(40) < 0.20, NA_real_, qaly)
  )

imp <- mice(
  heor_miss |> select(cost, qaly, treatment),
  m = 10, method = c(cost = "pmm", qaly = "pmm", treatment = ""),
  maxit = 5, printFlag = FALSE, seed = 42
)

# Inspect one completed dataset
completed_1 <- complete(imp, action = 1)

# Fit the model of interest on every imputed dataset, then pool per Rubin's rules
fit <- with(imp, lm(qaly ~ treatment + cost))
pooled_fit <- pool(fit)
summary(pooled_fit)
