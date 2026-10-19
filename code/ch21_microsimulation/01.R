# Extracted from ch21_microsimulation.typ, lines 49-57
# Section: == 21.2 Patient heterogeneity and history dependence
# Chapter: 21

# Simulate baseline covariates for n patients
n <- 10000
patients <- data.frame(
  id = 1:n,
  age = rnorm(n, mean = 62, sd = 9),
  comorbidity_score = rpois(n, lambda = 1.4)
)
