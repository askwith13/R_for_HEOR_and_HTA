# Extracted from ch10_survival_analysis.typ, lines 523-533
# Section: === Anchoring with external data
# Chapter: 10

library(readr)
library(dplyr)

external_km <- read_csv("registry_survival_5yr.csv")

model_est <- summary(aft_weibull, t = 60, type = "survival")[[1]]
external_est <- external_km |> filter(time_months == 60)

bind_rows(model = model_est, external = external_est)
