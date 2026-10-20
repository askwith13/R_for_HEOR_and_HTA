# Extracted from ch32_special_topics.typ, lines 215-236
# Section: == 32.5 Digital health technologies and AI-enabled interventions
# Chapter: 32

# Framing a digital triage tool's evaluation data: explicit comparator
# and model-version fields, not assumed constants. Illustrative/simulated.
library(dplyr)

triage_eval <- tibble::tibble(
  patient_id      = 1:6,
  arm             = c("app_triage", "app_triage", "nurse_telephone",
                      "nurse_telephone", "app_triage", "nurse_telephone"),
  model_version   = c("v1.2", "v1.2", NA, NA, "v1.3", NA),
  correct_triage  = c(TRUE, FALSE, TRUE, TRUE, TRUE, FALSE),
  time_to_advice_min = c(4, 6, 22, 19, 3, 25)
)

triage_eval %>%
  group_by(arm, model_version) %>%
  summarise(
    accuracy      = mean(correct_triage),
    mean_wait_min = mean(time_to_advice_min),
    .groups = "drop"
  )
