# Extracted from ch06_slr_support.typ, lines 22-44
# Section: == 6.1 Search strategy documentation
# Chapter: 6

library(tibble)
library(readr)
library(dplyr)

search_log <- tibble(
  database     = c("PubMed", "Embase", "Cochrane CENTRAL"),
  platform     = c("PubMed.gov", "Ovid", "Cochrane Library"),
  search_string = c(
    '("tuberculosis"[MeSH] OR "TB"[tiab]) AND ("economic evaluation"[tiab] OR "cost-effectiveness"[tiab])',
    'exp Tuberculosis/ AND (economic evaluation/ OR "cost effectiveness".ti,ab.)',
    'tuberculosis AND (cost-effectiveness OR "economic evaluation"):ti,ab,kw'
  ),
  date_from    = as.Date(c("2010-01-01", "2010-01-01", "2010-01-01")),
  date_to      = as.Date(rep("2024-06-30", 3)),
  date_run     = as.Date(rep(Sys.Date(), 3)),
  n_hits       = c(1842, 1365, 211),
  limits       = c("English; Humans", "English; Humans", "English")
)

write_csv(search_log, "search_strategy_log.csv")
search_log
