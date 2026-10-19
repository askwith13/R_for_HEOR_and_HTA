# Extracted from ch23_budget_impact.typ, lines 460-476
# Section: == 23.4 Scenario analyses
# Chapter: 23

# Scenario A: faster diffusion (e.g. a strong clinical-guideline endorsement)
bia_fast_uptake <- build_bia(
  uptake_share = c(0.10, 0.25, 0.40, 0.55, 0.65)
)

# Scenario B: managed-entry agreement - confidential 25% net price reduction
bia_mea <- build_bia(
  cost_new = 1500   # was 2000; offset_new stays at 300
)

scenarios <- bind_rows(
  bia_base        %>% mutate(scenario = "Base case"),
  bia_fast_uptake %>% mutate(scenario = "Faster uptake"),
  bia_mea         %>% mutate(scenario = "Managed-entry agreement")
)
