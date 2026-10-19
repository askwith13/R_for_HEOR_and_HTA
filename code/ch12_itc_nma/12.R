# Extracted from ch12_itc_nma.typ, lines 500-532
# Section: === Mechanics in gemtc
# Chapter: 12

library(gemtc)

# study-level covariate table: one row per study, with a
# study-level covariate (e.g. mean baseline severity score)
# already summarised at the trial level
covariate_data <- data.frame(
  study    = c("TrialA", "TrialB", "TrialC", "TrialD", "TrialE"),
  baseline_severity = c(0.41, 0.52, 0.38, 0.60, 0.47)
)

# network object as in section 12.2, then merge in the covariate
network <- mtc.network(
  data.ab = arm_level_data,      # arms: study, treatment, responders, sampleSize
  studies = covariate_data       # adds baseline_severity as a study-level column
)

# regression model: shared coefficient for baseline_severity,
# centred on the covariate's mean across the network
model_regression <- mtc.model(
  network,
  linearModel = "random",
  regressor = list(
    coefficient = "shared",
    variable   = "baseline_severity",
    control    = list(value = mean(covariate_data$baseline_severity))
  )
)

results_regression <- mtc.run(model_regression, n.adapt = 5000,
                               n.iter = 20000, thin = 10)
summary(results_regression)
