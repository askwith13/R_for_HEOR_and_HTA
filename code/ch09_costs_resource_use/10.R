# Extracted from ch09_costs_resource_use.typ, lines 325-349
# Section: == 9.5 Cost-of-illness and micro-costing studies
# Chapter: 9

library(dplyr)

# resource_items: one row per patient per resource event
# patient_id, episode_phase ("diagnosis","treatment","hospitalisation"),
# resource_item, quantity, unit_cost (from the Section 9.2 unit-cost table)

episode_cost <- resource_items |>
  mutate(item_cost = quantity * unit_cost) |>
  group_by(patient_id, episode_phase) |>
  summarise(phase_cost = sum(item_cost), .groups = "drop") |>
  tidyr::pivot_wider(
    names_from  = episode_phase,
    values_from = phase_cost,
    values_fill = 0
  ) |>
  mutate(total_episode_cost = diagnosis + treatment + hospitalisation)

episode_cost |>
  summarise(
    mean_cost   = mean(total_episode_cost),
    sd_cost     = sd(total_episode_cost),
    n_patients  = n()
  )
