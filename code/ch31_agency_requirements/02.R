# Extracted from ch31_agency_requirements.typ, lines 177-205
# Section: == 31.6 Responding to technical engagement and evidence review group critiques with R
# Chapter: 31

# Base-case PSA/ICER run (original discount rate, e.g. 3.5%)
# run_tb_model() is the same pure TB Markov PSA function built
# across Chapters 17-27 and packaged in Chapter 30 -- not redefined
# here, called with its existing argument interface.
base_case <- run_tb_model(
  n_sim      = 10000,
  disc_rate  = 0.035,
  disc_costs = 0.035,
  disc_qalys = 0.035
)
# base_case$icer gives the committee's reference ICER,
# built on incr_cost = -844.14, incr_qaly = 0.1440

# ERG technical-engagement request: "please rerun at 6% discounting"
erg_scenario <- run_tb_model(
  n_sim      = 10000,
  disc_rate  = 0.06,
  disc_costs = 0.06,
  disc_qalys = 0.06
)

# Compare ICERs and re-render the Quarto evidence report (Ch.28)
# with the new scenario slotted in as an additional results section
quarto::quarto_render(
  "tb_model_report.qmd",
  execute_params = list(scenario = "erg_discount_6pct")
)
