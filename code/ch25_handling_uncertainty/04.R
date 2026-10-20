# Extracted from ch25_handling_uncertainty.typ, lines 273-300
# Section: === Constructing the tornado diagram
# Chapter: 25

library(ggplot2)
library(dplyr)

owsa_results <- tibble::tribble(
  ~parameter,                              ~low,  ~high,
  "New-regimen cure probability",          3615,  11560,
  "p(Fail -> Death), shared",              6780,   9148,
  "Annual discount rate",                  8690,   7615,   # note: low bound gives HIGHER NMB here
  "New-regimen cost per cycle",            8458,   7631,
  "On-treatment utility, shared",          8365,   7723
) %>%
  mutate(
    swing = abs(high - low),
    parameter = forcats::fct_reorder(parameter, swing)   # sort by swing for the funnel shape
  )

base_nmb <- 8044

ggplot(owsa_results, aes(y = parameter)) +
  geom_segment(aes(x = pmin(low, high), xend = pmax(low, high), yend = parameter),
               linewidth = 8, colour = "#4477AA") +
  geom_vline(xintercept = base_nmb, linetype = "dashed", colour = "grey30") +
  labs(x = "Incremental net monetary benefit ($, λ = $50,000/QALY)",
       y = NULL,
       title = "Tornado diagram: one-way sensitivity analysis, New TB regimen vs SoC") +
  theme_minimal()
