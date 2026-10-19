# Extracted from ch15_rwe_causal_inference.typ, lines 518-530
# Section: === Interrupted time series (ITS)
# Chapter: 15

library(segmented)

its_base <- lm(success_rate ~ month, data = monthly_tb_outcomes)

its_seg <- segmented(
  its_base,
  seg.Z = ~ month,
  psi   = intervention_month        # known breakpoint: the rollout month
)
summary(its_seg)
slope(its_seg)         # slope before vs after the breakpoint
