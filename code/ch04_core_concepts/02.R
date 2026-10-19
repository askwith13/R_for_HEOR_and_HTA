# Extracted from ch04_core_concepts.typ, lines 87-98
# Section: == 4.3 QALYs, DALYs and life-years
# Chapter: 4

# Simple QALY calculation across two health states
time_in_full_health   <- 2.0   # years
utility_full_health   <- 1.0

time_in_impaired_state <- 3.0  # years
utility_impaired_state  <- 0.6

qalys <- time_in_full_health * utility_full_health +
         time_in_impaired_state * utility_impaired_state
qalys
