# Extracted from ch35_case_studies.typ, lines 658-678
# Section: === Computing year-by-year budget impact
# Chapter: 35

cost_oral_annual  <- 1450  # drug + routine monitoring, LCU per patient-year
cost_lai_annual   <- 5200  # drug + administration visits, LCU per patient-year
cost_relapse      <- 8600  # average cost of a relapse/hospitalisation episode
relapse_rate_oral <- 0.24  # annual relapse probability on oral therapy
relapse_rate_lai  <- 0.15  # lower relapse probability on LAI (adherence benefit)

# Reference scenario: entire eligible population on oral therapy
ref_drug_cost    <- eligible_pop * cost_oral_annual
ref_relapse_cost <- eligible_pop * relapse_rate_oral * cost_relapse
ref_total_cost   <- ref_drug_cost + ref_relapse_cost

# New scenario: mix of oral and LAI per the uptake trajectory
new_drug_cost    <- patients_oral_in_new_scn * cost_oral_annual +
                       patients_new * cost_lai_annual
new_relapse_cost <- patients_oral_in_new_scn * relapse_rate_oral * cost_relapse +
                       patients_new * relapse_rate_lai * cost_relapse
new_total_cost   <- new_drug_cost + new_relapse_cost

budget_impact <- new_total_cost - ref_total_cost
