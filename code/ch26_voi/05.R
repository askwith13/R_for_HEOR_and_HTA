# Extracted from ch26_voi.typ, lines 847-861
# Section: == 26.5 Value of implementation
# Chapter: 26

# Illustrative value-of-implementation calculation, 5-year linear ramp to 80%
years          <- 1:5
terminal_uptake <- 0.80
eligible_per_yr <- 10000
inmb_per_patient <- 8044.05

uptake_y <- terminal_uptake * (years / 5)        # linear ramp, 16/32/48/64/80%
gap_y    <- 1 - uptake_y
patients_not_switched <- eligible_per_yr * gap_y
value_lost_per_year   <- patients_not_switched * inmb_per_patient

total_value_of_implementation <- sum(value_lost_per_year)
total_value_of_implementation
