# Extracted from ch16_regression_models.typ, lines 92-124
# Section: == 16.1 Generalised linear models
# Chapter: 16

library(dplyr)
library(broom)

# Toy multi-site TB treatment-outcome dataset
tb_outcomes <- tibble::tribble(
  ~patient_id, ~regimen,    ~age, ~baseline_smear, ~success,
  1,           "standard",  34,   "positive",      1,
  2,           "standard",  45,   "positive",      0,
  3,           "shortened", 29,   "negative",      1,
  4,           "shortened", 51,   "positive",      1,
  5,           "standard",  38,   "negative",      0,
  6,           "shortened", 61,   "positive",      0,
  7,           "shortened", 27,   "negative",      1,
  8,           "standard",  42,   "positive",      1
)

fit_logit <- glm(
  success ~ regimen + age + baseline_smear,
  family = binomial(link = "logit"),
  data   = tb_outcomes
)

# Tabulate coefficients, odds ratios and confidence intervals
broom::tidy(fit_logit, exponentiate = TRUE, conf.int = TRUE)

# Predicted probability of success for a new patient
predict(
  fit_logit,
  newdata = tibble::tibble(regimen = "shortened", age = 40, baseline_smear = "positive"),
  type    = "response"
)
