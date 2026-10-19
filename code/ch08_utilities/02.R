# Extracted from ch08_utilities.typ, lines 101-126
# Section: == 8.4 Analysing utility data: censoring, bounded distributions, beta regression, mixture models
# Chapter: 8

library(betareg)

# toy utility data: mix of observations with a visible ceiling spike
set.seed(123)
n <- 200
age <- round(rnorm(n, 55, 12))
severity <- sample(c("mild", "moderate", "severe"), n, replace = TRUE,
                    prob = c(0.4, 0.4, 0.2))

# simulate utilities with ceiling clustering at 1.0
raw_utility <- pmin(1, rbeta(n, 6, 2) + ifelse(severity == "mild", 0.15, 0))

df <- data.frame(utility = raw_utility, age = age, severity = severity)

# betareg requires outcomes strictly inside (0, 1); rescale to avoid
# exact boundary values using the standard Smithson-Verkuilen transform
n_obs <- nrow(df)
df$utility_resc <- (df$utility * (n_obs - 1) + 0.5) / n_obs

fit_beta <- betareg(utility_resc ~ age + severity, data = df)
summary(fit_beta)

# predicted mean utilities on the original scale
df$pred_utility <- predict(fit_beta, type = "response")
