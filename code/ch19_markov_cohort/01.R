# Extracted from ch19_markov_cohort.typ, lines 58-90
# Section: == 19.3 Building a Markov model in base R (matrix-based approach)
# Chapter: 19

# Four states, in a fixed order used throughout the chapter
state_names <- c("OnTx", "Cured", "Fail", "Death")

# Transition matrix: rows = "from", columns = "to"
P <- matrix(
  c(0.15, 0.75, 0.08, 0.02,   # from OnTx
    0.00, 0.99, 0.00, 0.01,   # from Cured
    0.60, 0.00, 0.25, 0.15,   # from Fail
    0.00, 0.00, 0.00, 1.00),  # from Death (absorbing)
  nrow = 4, byrow = TRUE,
  dimnames = list(state_names, state_names)
)

# Defensive check: every row must sum to exactly 1
stopifnot(all(abs(rowSums(P) - 1) < 1e-9))

# Initial state-occupancy vector: whole cohort starts On Treatment
init <- c(OnTx = 1, Cured = 0, Fail = 0, Death = 0)

n_cycles <- 20  # 20 six-month cycles = 10 years

# Trace matrix: rows = cycles 0..n_cycles, columns = states
trace <- matrix(NA_real_, nrow = n_cycles + 1, ncol = 4,
                 dimnames = list(0:n_cycles, state_names))
trace[1, ] <- init

for (t in seq_len(n_cycles)) {
  trace[t + 1, ] <- trace[t, ] %*% P
}

round(trace[c(1, 6, 11, 21), ], 4)  # cycles 0, 5, 10, 20
