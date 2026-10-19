# Extracted from ch03_r_essentials.typ, lines 488-500
# Section: == 3.7 Debugging and error handling
# Chapter: 3

psa_results <- vector("list", n_iterations)

for (i in seq_len(n_iterations)) {
  psa_results[[i]] <- tryCatch(
    run_model(psa_param_draws[[i]]),
    error = function(e) {
      message(sprintf("Iteration %d failed: %s", i, conditionMessage(e)))
      NA
    }
  )
}
