# Extracted from ch07_missing_data.typ, lines 304-313
# Section: == 7.7 Reporting missing data handling for HTA
# Chapter: 7

# Illustrative structure for the reporting paragraph's data
missingness_summary <- trial_data |>
  dplyr::group_by(arm) |>
  dplyr::summarise(
    n = dplyr::n(),
    n_missing_utility = sum(is.na(utility_6m)),
    pct_missing = round(100 * n_missing_utility / n, 1)
  )
