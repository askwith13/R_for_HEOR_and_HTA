# Extracted from ch15_rwe_causal_inference.typ, lines 534-545
# Section: === Interrupted time series (ITS)
# Chapter: 15

monthly_tb_outcomes$post   <- as.integer(monthly_tb_outcomes$month >= intervention_month)
monthly_tb_outcomes$time_since <- pmax(0, monthly_tb_outcomes$month - intervention_month)

its_fit <- lm(
  success_rate ~ month + post + time_since,   # level-change (post) and slope-change (time_since) terms
  data = monthly_tb_outcomes
)
summary(its_fit)
# coefficient on "post" = immediate level change at intervention
# coefficient on "time_since" = change in slope after intervention
