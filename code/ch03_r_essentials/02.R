# Extracted from ch03_r_essentials.typ, lines 32-39
# Section: == 3.1 Data structures: vectors, lists, data frames and tibbles, arrays and matrices
# Chapter: 3

params <- list(
  costs = list(drugA = 1200, drugB = 980, monitoring = 150),
  utilities = list(well = 0.85, sick = 0.55, dead = 0),
  discount_rate = 0.035
)
params$costs$drugA
