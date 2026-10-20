# Extracted from ch31_agency_requirements.typ, lines 70-89
# Section: == 31.3 HTA in India: HTAIn, the Indian reference case, and Ayushman Bharat PM-JAY
# Chapter: 31

# Example: parameterising a cost input by data-source scenario
# rather than hard-coding a single "the" unit cost -- a pattern
# that matters more for India-facing models than UK ones, given
# the wider spread across public, private, and PM-JAY tariffs.
# run_cea_model() is the same pure cost-effectiveness function
# from Chapters 17-27, re-parameterised, not a new model.
unit_cost_scenarios <- list(
  pmjay_tariff      = 4200,   # PM-JAY empanelled package rate (INR)
  public_tertiary   = 6800,   # observed public tertiary hospital cost
  private_estimate  = 15500   # published private-sector cost estimate
)

run_scenario <- function(unit_cost, ...) {
  # same model function as the base case, just re-parameterised
  run_cea_model(unit_cost = unit_cost, ...)
}

results <- lapply(unit_cost_scenarios, run_scenario)
