# Extracted from ch07_missing_data.typ, lines 212-230
# Section: == 7.5 Sensitivity analysis, including tipping-point and pattern-mixture approaches
# Chapter: 7

library(dplyr)

tipping_point <- function(data, deltas) {
  results <- vector("list", length(deltas))
  for (i in seq_along(deltas)) {
    d <- deltas[i]
    adjusted <- data |>
      mutate(success_adj = if_else(imputed & arm == "intervention",
                                    success - d, success))
    diff <- mean(adjusted$success_adj[adjusted$arm == "intervention"]) -
      mean(adjusted$success_adj[adjusted$arm == "control"])
    results[[i]] <- tibble(delta = d, risk_difference = diff)
  }
  bind_rows(results)
}

tipping_point(trial_data, deltas = seq(0, 0.30, by = 0.02))
