# Extracted from ch03_r_essentials.typ, lines 411-418
# Section: == 3.5 Performance: profiling, `Rcpp`, parallelisation (`future`, `furrr`)
# Chapter: 3

library(future)
library(furrr)

plan(multisession, workers = 4)

psa_results <- future_map(psa_param_draws, run_model, .progress = TRUE)
