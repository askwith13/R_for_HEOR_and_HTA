# Extracted from ch35_case_studies.typ, lines 636-650
# Section: === Defining the eligible population and uptake trajectory
# Chapter: 35

set.seed(3501)

years <- 2026:2030
n_years <- length(years)

# Eligible population: slow regional growth
eligible_pop <- round(18400 * (1.015)^(0:(n_years - 1)))

# Uptake (market share) of the new LAI, ramping to a plateau
uptake_new <- c(0.04, 0.10, 0.17, 0.23, 0.27)

patients_new             <- round(eligible_pop * uptake_new)
patients_oral_in_new_scn <- eligible_pop - patients_new
