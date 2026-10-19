# Extracted from ch03_r_essentials.typ, lines 86-93
# Section: == 3.2 Data wrangling with `tidyverse` and `data.table`
# Chapter: 3

library(data.table)

patient_dt <- as.data.table(patient_data)
patient_dt[arm %in% c("Drug A", "Drug B"),
           .(mean_cost = mean(total_cost), n = .N),
           by = arm]
