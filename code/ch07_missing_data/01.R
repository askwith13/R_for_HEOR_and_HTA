# Extracted from ch07_missing_data.typ, lines 57-80
# Section: == 7.2 Exploring missingness (naniar, visdat, Shiny-based explorers)
# Chapter: 7

library(tidyverse)
library(naniar)
library(visdat)

# trial_econ: one row per patient, with baseline and 12-week
# utility scores, and total healthcare cost over follow-up
trial_econ <- read_csv("trial_econ_extract.csv")

# Overview of variable types and missingness across the frame
vis_dat(trial_econ)

# Missingness-focused heatmap, clustered by pattern
vis_miss(trial_econ, cluster = TRUE)

# Which variables carry the most missingness?
gg_miss_var(trial_econ, facet = trial_arm)

# Do utility and cost missingness co-occur?
gg_miss_upset(trial_econ)

# Formal test of the MCAR assumption (Little's test)
mcar_test(trial_econ %>% select(utility_12wk, total_cost, baseline_utility))
