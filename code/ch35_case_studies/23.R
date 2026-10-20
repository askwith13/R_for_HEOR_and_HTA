# Extracted from ch35_case_studies.typ, lines 787-801
# Section: === Estimating propensity scores: matching and weighting
# Chapter: 35

library(MatchIt)
library(WeightIt)
library(cobalt)

ps_formula <- treat ~ age + bmi + hba1c_base + egfr + cv_disease

# 1:1 nearest-neighbour matching on the logit propensity score, caliper 0.2 SD
m.out <- matchit(ps_formula, data = dat, method = "nearest",
                  distance = "glm", caliper = 0.2)
matched_dat <- match.data(m.out)

# Inverse-probability-of-treatment weighting (ATT) as a cross-check
w.out <- weightit(ps_formula, data = dat, method = "glm", estimand = "ATT")
