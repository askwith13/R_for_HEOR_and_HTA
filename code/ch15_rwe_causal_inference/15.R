# Extracted from ch15_rwe_causal_inference.typ, lines 506-511
# Section: === Difference-in-differences (DiD)
# Chapter: 15

library(ggplot2)
ggplot(district_panel, aes(quarter, culture_conversion_weeks, color = treated_district)) +
  stat_summary(geom = "line") +
  geom_vline(xintercept = rollout_quarter, linetype = "dashed")
