# Extracted from ch16_regression_models.typ, lines 179-205
# Section: == 16.2 Mixed-effects and hierarchical models
# Chapter: 16

library(lme4)

# Toy multi-site TB dataset: patients nested within clinics
tb_multisite <- tibble::tribble(
  ~clinic_id, ~patient_id, ~regimen,    ~age, ~success,
  "A", 1,  "standard",  34, 1,
  "A", 2,  "standard",  45, 0,
  "A", 3,  "shortened", 29, 1,
  "B", 4,  "shortened", 51, 1,
  "B", 5,  "standard",  38, 0,
  "B", 6,  "shortened", 61, 0,
  "C", 7,  "shortened", 27, 1,
  "C", 8,  "standard",  42, 1,
  "C", 9,  "standard",  33, 0,
)

# Random intercept for clinic, fixed effects for regimen and age
fit_mixed <- glmer(
  success ~ regimen + age + (1 | clinic_id),
  family = binomial(link = "logit"),
  data   = tb_multisite
)

summary(fit_mixed)
broom.mixed::tidy(fit_mixed, effects = "fixed", exponentiate = TRUE, conf.int = TRUE)
