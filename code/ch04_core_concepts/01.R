# Extracted from ch04_core_concepts.typ, lines 36-47
# Section: == 4.1 Costs, effects and the opportunity cost of health care
# Chapter: 4

# Illustrating opportunity cost with a fixed budget
budget <- 10e6               # fixed annual budget, GBP 10m
cost_per_qaly_drugA <- 20000  # technology A
cost_per_qaly_drugB <- 12000  # displaced alternative use of the same money

qalys_A <- budget / cost_per_qaly_drugA
qalys_B <- budget / cost_per_qaly_drugB

qalys_A; qalys_B
qalys_B - qalys_A   # health forgone by funding A instead of B
