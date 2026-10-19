# Extracted from ch04_core_concepts.typ, lines 433-445
# Section: == 4.8 Coding a first simple CEA in R
# Chapter: 4

library(dplyr)
library(tibble)

# Step 1: define the toy treatment data -------------------------------
treatments <- tibble(
  treatment = c("Standard Care", "Drug A", "Drug B", "Drug C"),
  cost      = c(1200,            4800,     5100,     9000),
  qaly      = c(0.62,            0.81,     0.74,     0.95)
)

treatments
