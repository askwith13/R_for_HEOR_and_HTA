# Extracted from ch26_voi.typ, lines 121-143
# Section: == 26.1 Concepts: EVPI, EVPPI, EVSI and ENBS
# Chapter: 26

# Continuing directly from Chapter 25 §25.4's psa_results structure.
# Here psa_results carries both regimens' per-iteration total cost and
# QALYs (columns cost_new, qaly_new, cost_soc, qaly_soc), built the same
# way as §25.4's single-arm loop, just run for both arms per iteration.

wtp <- 50000  # same WTP threshold as Chapter 25's base case

nmb_new <- wtp * psa_results[, "qaly_new"] - psa_results[, "cost_new"]
nmb_soc <- wtp * psa_results[, "qaly_soc"] - psa_results[, "cost_soc"]

mean_nmb_new <- mean(nmb_new)
mean_nmb_soc <- mean(nmb_soc)

# Net benefit of committing to the single best strategy in expectation:
nb_fixed_choice <- max(mean_nmb_new, mean_nmb_soc)

# Net benefit of an oracle who picks the best strategy FOR EACH draw:
nb_perfect_info <- mean(pmax(nmb_new, nmb_soc))

evpi <- nb_perfect_info - nb_fixed_choice
cat("EVPI per patient at WTP =", wtp, ":", evpi, "\n")
