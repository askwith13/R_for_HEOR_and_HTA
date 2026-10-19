# Extracted from ch10_survival_analysis.typ, lines 539-553
# Section: === Background mortality as a plausibility bound
# Chapter: 10

library(readr)
library(dplyr)

life_table <- read_csv("national_life_table.csv")  # age, sex, qx (annual mortality prob.)

disease_hazard <- -log(1 - 0.08)
bg_hazard <- life_table |>
  filter(age == 70, sex == "female") |>
  pull(qx) |>
  (\(qx) -log(1 - qx))()

combined_hazard <- pmax(disease_hazard, bg_hazard)
combined_hazard
