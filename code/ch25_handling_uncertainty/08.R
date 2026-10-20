# Extracted from ch25_handling_uncertainty.typ, lines 498-528
# Section: == 25.4 Probabilistic sensitivity analysis: choosing distributions
# Chapter: 25

n_psa <- 2000
set.seed(123)

psa_p_fail    <- rbeta(n_psa, shape1 = 8, shape2 = 92)
psa_cost_fail <- rgamma(n_psa, shape = shape, rate = rate)   # shape/rate from the hand-check above

psa_results <- matrix(NA_real_, n_psa, 2, dimnames = list(NULL, c("cost", "qaly")))
for (i in seq_len(n_psa)) {
  p <- base_params                          # from §25.3
  p$p_ontx_fail <- psa_p_fail[i]
  p$cost_fail   <- psa_cost_fail[i]
  psa_results[i, ] <- run_tb_model(p)
}

cat("Mean cost:", mean(psa_results[, "cost"]), " Mean QALY:", mean(psa_results[, "qaly"]), "\n")
# Mean cost: 956.17   Mean QALY: 6.5779 -- matches §25.3's base case (955.34 / 6.5795) to
# well within Monte Carlo noise, exactly as it should: PSA means should recover the base
# case when (as here) every sampled parameter's distribution is centred on its base-case value

# Convergence / Monte Carlo error check: running mean at increasing iteration counts
for (n in c(100, 500, 1000, 1500, 2000)) {
  cat("N=", n, " mean cost=", mean(psa_results[1:n, "cost"]),
      " mean qaly=", mean(psa_results[1:n, "qaly"]), "\n")
}
# N=  100  mean cost= 954.93  mean qaly= 6.5795
# N=  500  mean cost= 955.90  mean qaly= 6.5780
# N= 1000  mean cost= 956.22  mean qaly= 6.5783
# N= 1500  mean cost= 956.59  mean qaly= 6.5772
# N= 2000  mean cost= 956.17  mean qaly= 6.5779
