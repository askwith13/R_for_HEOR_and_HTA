# 01_clean_data.R
#
# Reads from data-raw/ (never edited by hand), writes a cleaned,
# analysis-ready dataset to data/ (Chapter 2 SS2.2). This script
# should run top-to-bottom on a clean machine and reproduce data/
# byte-for-byte.

library(dplyr)
library(readr)

# raw <- read_csv("data-raw/trial_extract.csv")
# cleaned <- raw |> filter(!is.na(outcome)) |> mutate(across(where(is.character), trimws))
# write_csv(cleaned, "data/trial_extract_clean.csv")
