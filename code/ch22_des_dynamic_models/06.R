# Extracted from ch22_des_dynamic_models.typ, lines 338-349
# Section: == 22.6 Worked example: a TB screening/preventive-therapy intervention model
# Chapter: 22

cost_per_case        <- 1500   # USD, illustrative TB treatment cost per active case
qaly_loss_per_case    <- 0.15  # illustrative QALY loss per active TB episode
cost_per_covered      <- 8     # USD, illustrative programme cost per person covered
coverage              <- 0.7
n_covered             <- N0 * coverage

cost_averted_treatment <- cases_averted * cost_per_case
qaly_gained             <- cases_averted * qaly_loss_per_case
intervention_cost       <- n_covered * cost_per_covered
net_budget_impact       <- intervention_cost - cost_averted_treatment
