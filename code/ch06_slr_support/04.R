# Extracted from ch06_slr_support.typ, lines 143-159
# Section: == 6.2 Deduplication and screening workflows
# Chapter: 6

library(dplyr)
library(irr)   # kappa2()

screening_log <- all_refs_dedup |>
  mutate(
    reviewer1_ti_ab = sample(c("include", "exclude"), n(), replace = TRUE, prob = c(0.3, 0.7)),
    reviewer2_ti_ab = sample(c("include", "exclude"), n(), replace = TRUE, prob = c(0.3, 0.7))
  )

kappa_result <- kappa2(screening_log[, c("reviewer1_ti_ab", "reviewer2_ti_ab")])
kappa_result$value   # Cohen's kappa for title/abstract agreement

conflicts <- screening_log |>
  filter(reviewer1_ti_ab != reviewer2_ti_ab)
nrow(conflicts)   # records requiring reconciliation discussion
