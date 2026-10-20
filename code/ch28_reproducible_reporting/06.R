# Extracted from ch28_reproducible_reporting.typ, lines 155-161
# Section: == 28.2 Parameterised reports
# Chapter: 28

#| label: calc-nmb

inc_cost <- -844.14 * params$drug_price_multiplier
inc_qaly <- 0.1440
nmb <- inc_qaly * params$wtp_threshold - inc_cost
