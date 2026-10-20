# Extracted from ch35_case_studies.typ, lines 142-166
# Section: === Step (e): probabilistic sensitivity analysis
# Chapter: 35

n_sim <- 2000
psa <- matrix(NA, n_sim, 2, dimnames = list(NULL, c("inc_cost", "inc_qaly")))

for (s in 1:n_sim) {
  rr_draw   <- exp(rnorm(1, log(0.72), 0.08))        # lognormal around point estimate
  rr_draw   <- min(max(rr_draw, 0.4), 1.1)
  cost_draw <- cost_state * rlnorm(n_states, 0, 0.1); cost_draw["Dead"] <- 0
  util_draw <- pmin(util_state * rnorm(n_states, 1, 0.05), 1); util_draw["Dead"] <- 0
  drug_draw <- drug_cost_new * rlnorm(1, 0, 0.1)

  tm_new_s <- tm_soc
  for (i in 1:(n_states - 1)) {
    move_idx <- setdiff(which(seq_len(n_states) > i), i)
    reduced  <- tm_soc[i, move_idx] * rr_draw
    delta    <- sum(tm_soc[i, move_idx]) - sum(reduced)
    tm_new_s[i, move_idx] <- reduced
    tm_new_s[i, i] <- tm_soc[i, i] + delta
  }

  r_soc <- discounted_total(run_trace(tm_soc), 0)
  r_new <- discounted_total(run_trace(tm_new_s), drug_draw)
  psa[s, ] <- c(r_new$cost - r_soc$cost, r_new$qaly - r_soc$qaly)
}
