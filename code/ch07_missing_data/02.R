# Extracted from ch07_missing_data.typ, lines 100-131
# Section: == 7.3 Complete-case versus imputation
# Chapter: 7

library(tidyverse)
library(mice)

set.seed(2024)
n <- 20
truth <- tibble(
  patient_id = 1:n,
  utility = rnorm(n, mean = 0.75, sd = 0.10)
)

# Introduce MAR-ish missingness: lower utility more likely to be missing
obs <- truth |>
  mutate(
    miss_prob = plogis(-3 + 4 * (0.80 - utility)),
    utility_obs = if_else(runif(n) < miss_prob, NA_real_, utility)
  )

# --- Naive mean imputation ---
mean_fill <- mean(obs$utility_obs, na.rm = TRUE)
naive <- obs |> mutate(utility_imp = if_else(is.na(utility_obs), mean_fill, utility_obs))

se_naive <- sd(naive$utility_imp) / sqrt(n)
cat("Naive mean-imputation SE:", round(se_naive, 4), "\n")

# --- Proper multiple imputation (mice), previewed from SS7.4 ---
imp <- mice(obs |> select(utility_obs), m = 20, method = "pmm", maxit = 5,
            printFlag = FALSE, seed = 2024)
fits <- with(imp, t.test(utility_obs))
pooled <- pool(fits)
cat("Multiply-imputed pooled SE:", round(summary(pooled)$std.error, 4), "\n")
