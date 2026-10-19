# Extracted from ch05_data_sources.typ, lines 112-133
# Section: == 5.2 Registries, claims, electronic health records and surveys
# Chapter: 5

library(dplyr)
library(purrr)

# Generic first-pass profiling for a real-world data extract,
# whether claims, EHR, or registry sourced
profile_source_data <- function(df) {
  map_dfr(names(df), function(col) {
    x <- df[[col]]
    tibble(
      variable = col,
      pct_missing = round(mean(is.na(x)) * 100, 1),
      n_distinct = n_distinct(x, na.rm = TRUE),
      type = class(x)[1]
    )
  }) |>
    arrange(desc(pct_missing))
}

claims_profile <- profile_source_data(claims_extract)
head(claims_profile, 10)
