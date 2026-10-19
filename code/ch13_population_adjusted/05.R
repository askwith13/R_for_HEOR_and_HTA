# Extracted from ch13_population_adjusted.typ, lines 214-240
# Section: == 13.4 Multilevel network meta-regression (ML-NMR)
# Chapter: 13

library(multinma)

# Network combining IPD and AgD-only trials, as in Ch.12 §12.4
net <- combine_network(
  set_ipd(ipd_trial, study = study, trt = trt, y = outcome,
          trt_class = NULL),
  set_agd_arm(agd_trials, study = study, trt = trt,
              r = events, n = n)
)

# Supply numerical integration points for each AgD trial's
# covariate distribution -- consult the current multinma
# documentation for the exact distribution-argument syntax,
# which has evolved across package versions.
net_int <- add_integration(
  net,
  age = distr(qnorm, mean = age_mean, sd = age_sd),
  ecog = distr(qbern, prob = ecog_prop)
)

# Fit the regression model with effect-modifier interactions
ml_nmr_fit <- nma(net_int,
                   trt_effects = "fixed",
                   regression = ~ age + ecog,
                   class_interactions = "common")
