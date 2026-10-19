# Extracted from ch23_budget_impact.typ, lines 174-189
# Section: === Eligible population
# Chapter: 23

library(dplyr)

# illustrative cascade - every number here is a placeholder to be
# replaced with payer-specific epidemiological and administrative data
population_cascade <- tibble::tibble(
  step = c("covered_lives", "disease_prevalence", "diagnosed",
           "meets_label_criteria", "eligible_for_new_intervention"),
  proportion_of_prior_step = c(1, 0.02, 0.80, 0.60, 0.90)
)

population_cascade <- population_cascade |>
  mutate(cumulative_proportion = cumprod(proportion_of_prior_step))

population_cascade
