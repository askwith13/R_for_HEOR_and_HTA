# Extracted from ch05_data_sources.typ, lines 29-47
# Section: == 5.1 Clinical trial data (CDISC SDTM/ADaM concepts)
# Chapter: 5

library(haven)
library(dplyr)

# Read an ADaM subject-level analysis dataset (ADSL) from SAS transport format
adsl <- read_xpt("adsl.xpt")

# ADSL carries one row per subject with population flags already derived
adsl_summary <- adsl |>
  filter(SAFFL == "Y") |>                 # safety population flag
  group_by(TRT01P) |>                     # planned treatment, ADaM naming convention
  summarise(
    n = n(),
    mean_age = mean(AGE, na.rm = TRUE),
    pct_female = mean(SEX == "F", na.rm = TRUE) * 100
  )

adsl_summary
