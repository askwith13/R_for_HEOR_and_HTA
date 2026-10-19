# Extracted from ch19_markov_cohort.typ, lines 213-232
# Section: == 19.6 Tunnel states and state residence time
# Chapter: 19

library(heemod)

# Illustrative: failure risk declining with cycles spent on treatment
f_fail_by_state_time <- function(state_time) {
  dplyr::case_when(
    state_time <= 1 ~ 0.12,   # cycle 1 on treatment: higher early-failure risk
    state_time == 2 ~ 0.08,   # cycle 2: matches the base-case §19.1-19.5 value
    state_time >= 3 ~ 0.04    # cycle 3+: lower residual risk
  )
}

tm_tunnel <- define_transition(
  state_names = c("OnTx", "Cured", "Fail", "Death"),
  C,    0.75,  state_time,  0.02,
  0,    1,     0,           0,
  0.60, 0,     C,           0.15,
  0,    0,     0,           1
)
