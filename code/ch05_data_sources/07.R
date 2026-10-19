# Extracted from ch05_data_sources.typ, lines 261-270
# Section: === Clinical trial and survey formats with `haven`
# Chapter: 5

library(dplyr)
library(haven)

survey_clean <- survey_dta |>
  mutate(
    wealth_quintile = as_factor(wealth_quintile),   # labels become factor levels
    age_years       = zap_labels(age_years)         # strip labels, keep plain numeric
  )
