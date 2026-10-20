# Extracted from ch35_case_studies.typ, lines 52-63
# Section: === Step (a): health states and the transition matrix
# Chapter: 35

rr_progression <- 0.72
tm_new <- tm_soc
for (i in 1:(n_states - 1)) {
  move_idx <- setdiff(which(seq_len(n_states) > i), i)   # worse states + death, excluding self
  reduced  <- tm_soc[i, move_idx] * rr_progression
  delta    <- sum(tm_soc[i, move_idx]) - sum(reduced)     # probability mass "saved"
  tm_new[i, move_idx] <- reduced
  tm_new[i, i] <- tm_soc[i, i] + delta                     # saved mass stays in current state
}
stopifnot(all(abs(rowSums(tm_new) - 1) < 1e-9))
