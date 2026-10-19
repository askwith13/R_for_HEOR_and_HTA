# Extracted from ch03_r_essentials.typ, lines 356-365
# Section: == 3.5 Performance: profiling, `Rcpp`, parallelisation (`future`, `furrr`)
# Chapter: 3

library(profvis)

profvis({
  results <- vector("list", 500)
  for (i in seq_len(500)) {
    results[[i]] <- run_markov_trace(params_list[[i]])
  }
})
