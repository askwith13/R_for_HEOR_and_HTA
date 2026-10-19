# Extracted from ch13_population_adjusted.typ, lines 147-165
# Section: == 13.3 Simulated treatment comparison (STC)
# Chapter: 13

# Outcome regression model on the IPD trial, including a
# treatment x covariate interaction to capture effect modification
stc_fit <- glm(
  outcome ~ treatment * age + treatment * severity,
  data   = ipd,
  family = binomial()
)

# Predict the treatment effect at the AgD trial's reported means
newdata <- data.frame(
  treatment = c(0, 1),
  age       = target_means["age"],
  severity  = target_means["severity"]
)

preds <- predict(stc_fit, newdata = newdata, type = "link")
stc_log_odds_ratio <- preds[2] - preds[1]
