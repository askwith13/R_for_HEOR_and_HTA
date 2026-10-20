# Extracted from ch25_handling_uncertainty.typ, lines 548-553
# Section: == 25.5 Visualising uncertainty: CE plane, CEAC, CEAF, NMB distributions
# Chapter: 25

library(ggplot2)

# psa_df: one row per PSA iteration, columns delta_cost and delta_qaly
# (incremental cost/QALY of the new regimen minus the standard-regimen comparator)
