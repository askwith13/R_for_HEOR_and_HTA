# Extracted from ch35_case_studies.typ, lines 33-48
# Section: === Step (a): health states and the transition matrix
# Chapter: 35

states <- c("CKD3", "CKD4", "CKD5_predialysis", "Dialysis", "Dead")
n_states <- length(states)

## Annual transition probability matrix, standard of care (SoC)
tm_soc <- matrix(c(
  0.70, 0.18, 0.05, 0.02, 0.05,   # from CKD3
  0.00, 0.62, 0.22, 0.08, 0.08,   # from CKD4
  0.00, 0.00, 0.55, 0.30, 0.15,   # from CKD5_predialysis
  0.00, 0.00, 0.00, 0.78, 0.22,   # from Dialysis
  0.00, 0.00, 0.00, 0.00, 1.00    # from Dead (absorbing)
), nrow = n_states, byrow = TRUE,
   dimnames = list(states, states))

stopifnot(all(abs(rowSums(tm_soc) - 1) < 1e-9))
