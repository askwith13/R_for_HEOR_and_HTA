# Extracted from ch05_data_sources.typ, lines 505-518
# Section: == 5.6 Data quality checks (`pointblank`, `assertr`, `validate`)
# Chapter: 5

library(validate)

rules <- validator(
  cost_nonneg   = cost >= 0,
  qaly_bounded  = qaly >= 0 & qaly <= 1,
  strategy_set  = !is.na(strategy),
  followup_ok   = is.na(n_missing_followup) | n_missing_followup >= 0
)

out <- confront(cost_qaly_tbl, rules)
summary(out)
# sapply(out, function(x) sum(!x@expr)) # count fails per rule
