# Extracted from ch10_survival_analysis.typ, lines 56-63
# Section: == 10.1 Kaplan-Meier and life tables
# Chapter: 10

library(ggsurvfit)

survfit2(Surv(time, status) ~ arm, data = trial_df) |>
  ggsurvfit() +
  add_confidence_interval() +
  add_risktable()
