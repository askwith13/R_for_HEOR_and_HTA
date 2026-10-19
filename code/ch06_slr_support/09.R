# Extracted from ch06_slr_support.typ, lines 365-380
# Section: == 6.4 Data extraction templates and extraction QA
# Chapter: 6

joined <- inner_join(
  reviewer_a, reviewer_b,
  by = c("study_id", "outcome_name"),
  suffix = c("_A", "_B")
)

flagged <- joined %>%
  mutate(
    estimate_diff = abs(effect_estimate_A - effect_estimate_B),
    rob_mismatch  = rob_overall_A != rob_overall_B
  ) %>%
  filter(estimate_diff > 0.01 | rob_mismatch)

flagged %>% select(study_id, outcome_name, effect_estimate_A, effect_estimate_B, rob_overall_A, rob_overall_B)
