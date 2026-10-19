# Extracted from ch06_slr_support.typ, lines 484-505
# Section: == 6.6 Text mining and ML-assisted screening
# Chapter: 6

library(tidytext)
library(dplyr)

abstracts <- tibble::tibble(
  study_id = c("S1", "S2", "S3"),
  abstract = c(
    "Randomized trial of four-month rifapentine-based regimen for pulmonary TB.",
    "Cohort study assessing cardiovascular risk in diabetic patients.",
    "Treatment success and relapse rates in short-course TB chemotherapy."
  )
)

tidy_abstracts <- abstracts %>%
  unnest_tokens(word, abstract) %>%
  anti_join(stop_words, by = "word")

term_freq <- tidy_abstracts %>%
  count(word, sort = TRUE)

term_freq %>% head(10)
