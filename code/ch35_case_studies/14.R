# Extracted from ch35_case_studies.typ, lines 427-437
# Section: === 35.3.2 Patient heterogeneity via a frailty multiplier
# Chapter: 35

set.seed(20351)

N         <- 200000   # patients per arm
n_cycles  <- 40        # annual cycles, ages 50-89
start_age <- 50

# Lognormal frailty, mean approximately 1 across the cohort
frailty_sd <- 0.6
frailty <- rlnorm(N, meanlog = -0.5 * frailty_sd^2, sdlog = frailty_sd)
