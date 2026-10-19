# Extracted from ch03_r_essentials.typ, lines 75-82
# Section: == 3.2 Data wrangling with `tidyverse` and `data.table`
# Chapter: 3

library(tidyverse)

patient_data |>
  filter(arm %in% c("Drug A", "Drug B")) |>
  group_by(arm) |>
  summarise(mean_cost = mean(total_cost), n = n())
