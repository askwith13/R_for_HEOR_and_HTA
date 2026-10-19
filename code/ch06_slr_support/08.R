# Extracted from ch06_slr_support.typ, lines 350-365
# Section: == 6.4 Data extraction templates and extraction QA
# Chapter: 6

library(waldo)

reviewer_a <- readr::read_csv("extraction_reviewerA.csv")
reviewer_b <- readr::read_csv("extraction_reviewerB.csv")

# align rows on the natural key before comparing
reviewer_a <- reviewer_a %>% arrange(study_id, outcome_name)
reviewer_b <- reviewer_b %>% arrange(study_id, outcome_name)

discrepancies <- waldo::compare(
  reviewer_a, reviewer_b,
  tolerance = 1e-6              # ignore float noise, e.g. 0.980 vs 0.98
)
discrepancies
