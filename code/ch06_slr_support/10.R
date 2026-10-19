# Extracted from ch06_slr_support.typ, lines 398-426
# Section: == 6.5 Risk of bias visualisation (`robvis`)
# Chapter: 6

library(robvis)
library(dplyr)

# RoB 2.0 for RCTs: one row per study, domains D1-D5, overall, then a
# final Weight column -- robvis expects the weight as the LAST column
rob2_data <- tibble::tibble(
  Study = c("Nguyen2021", "Alvarez2020", "Okafor2022"),
  D1 = c("Low", "Some concerns", "Low"),
  D2 = c("Low", "Low", "Some concerns"),
  D3 = c("Some concerns", "Low", "Low"),
  D4 = c("Low", "Low", "Low"),
  D5 = c("Low", "Some concerns", "Low"),
  Overall = c("Some concerns", "Some concerns", "Low"),
  Weight = c(33.3, 33.3, 33.3)
)

rob_traffic_light(
  data = rob2_data,
  tool = "ROB2",
  psize = 8
)

rob_summary(
  data = rob2_data,
  tool = "ROB2",
  overall = TRUE
)
