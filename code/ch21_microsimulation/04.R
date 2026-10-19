# Extracted from ch21_microsimulation.typ, lines 118-123
# Section: == 21.3 Efficient implementation: vectorisation, data.table, parallel computing
# Chapter: 21

library(parallel)
psa_results <- mclapply(1:n_psa, function(i) {
  run_one_psa_sample(seed = i)
}, mc.cores = detectCores() - 1)
