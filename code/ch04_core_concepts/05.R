# Extracted from ch04_core_concepts.typ, lines 344-351
# Section: == 4.6 Perspective, time horizon, discounting and half-cycle correction
# Chapter: 4

discount_pv <- function(value, rate, year) {
  value / (1 + rate)^year
}

# A QALY gained in year 10, discounted at NICE's 3.5% rate
discount_pv(value = 1, rate = 0.035, year = 10)
