# Extracted from ch34_emerging_methods.typ, lines 34-70
# Section: == 34.1 Machine learning in HEOR
# Chapter: 34

set.seed(123)
n <- 600

# Simulate baseline covariates for a hypothetical insured population
age               <- round(rnorm(n, mean = 55, sd = 12))
n_comorbidities   <- rpois(n, lambda = 1.3)
prior_admissions  <- rpois(n, lambda = 0.6)
baseline_cost     <- rgamma(n, shape = 2, scale = 1500)

# True (unobserved, in real life) risk relationship generating next-year high-cost status
risk_score <- -4.2 + 0.02 * age + 0.55 * n_comorbidities +
  0.85 * prior_admissions + 0.00025 * baseline_cost
prob_high_cost <- 1 / (1 + exp(-risk_score))
high_cost_next_year <- rbinom(n, 1, prob_high_cost)

patient_data <- data.frame(
  age, n_comorbidities, prior_admissions, baseline_cost,
  high_cost_next_year = factor(high_cost_next_year, labels = c("No", "Yes"))
)

# 70/30 train-test split
train_idx <- sample(seq_len(n), size = 0.7 * n)
train <- patient_data[train_idx, ]
test  <- patient_data[-train_idx, ]

library(randomForest)
rf_model <- randomForest(
  high_cost_next_year ~ age + n_comorbidities + prior_admissions + baseline_cost,
  data = train, ntree = 500, importance = TRUE
)

pred_class <- predict(rf_model, newdata = test)
table(Predicted = pred_class, Actual = test$high_cost_next_year)
mean(pred_class == test$high_cost_next_year)   # overall test-set accuracy
importance(rf_model)                            # variable importance
