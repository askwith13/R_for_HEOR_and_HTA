# Extracted from ch24_cba_dcea_ecea.typ, lines 603-631
# Section: == 24.4 Multi-criteria decision analysis (MCDA) in R
# Chapter: 24

library(dplyr)

mcda_weighted_score <- function(scores, weights) {
  # scores:  a named list/data frame of criterion scores per alternative
  # weights: a named numeric vector of criterion weights, must sum to 1
  stopifnot(abs(sum(weights) - 1) < 1e-8)

  scores %>%
    rowwise() %>%
    mutate(
      weighted_sum = sum(c_across(names(weights)) * weights[names(weights)]),
      weighted_product = prod(c_across(names(weights))^weights[names(weights)])
    ) %>%
    ungroup()
}

weights <- c(efficacy = 0.35, safety = 0.25, severity = 0.20, economic = 0.20)

drug_scores <- tibble::tribble(
  ~drug,     ~efficacy, ~safety, ~severity, ~economic,
  "Drug A",  80,        70,      60,        50,
  "Drug B",  60,        90,      60,        70,
  "Drug C",  90,        50,      80,        40
)

mcda_result <- mcda_weighted_score(drug_scores, weights)
mcda_result %>% arrange(desc(weighted_sum))
