# Extracted from ch33_pro_preference_research.typ, lines 47-80
# Section: === Confirmatory factor analysis with `lavaan`
# Chapter: 33

library(lavaan)

set.seed(42)
n <- 300

# Two latent factors driving six observed Likert items (1-5 scale)
physical_f  <- rnorm(n)
emotional_f <- rnorm(n)

sim_item <- function(loading, factor_scores, noise_sd = 0.6) {
  raw <- loading * factor_scores + rnorm(n, sd = noise_sd)
  # discretise onto a 1-5 Likert scale
  pmin(pmax(round(raw + 3), 1), 5)
}

pro_data <- data.frame(
  p1 = sim_item(0.9, physical_f),
  p2 = sim_item(0.8, physical_f),
  p3 = sim_item(0.7, physical_f),
  e1 = sim_item(0.85, emotional_f),
  e2 = sim_item(0.75, emotional_f),
  e3 = sim_item(0.65, emotional_f)
)

# Hypothesised two-factor measurement model
pro_model <- '
  physical  =~ p1 + p2 + p3
  emotional =~ e1 + e2 + e3
'

fit <- cfa(model = pro_model, data = pro_data)
summary(fit, fit.measures = TRUE, standardized = TRUE)
