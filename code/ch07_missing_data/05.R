# Extracted from ch07_missing_data.typ, lines 274-290
# Section: == 7.6 Missing data in cost and QALY data
# Chapter: 7

library(mice)

imp <- mice(trial_data, m = 20, method = c(cost = "pmm", utility = "pmm"),
            seed = 123)

# Post-process: clamp imputed utilities to the valid range and
# ensure imputed costs are non-negative
imp_clamped <- imp
for (i in seq_len(imp$m)) {
  comp <- complete(imp, i)
  comp$utility <- pmin(pmax(comp$utility, -0.59), 1)
  comp$cost <- pmax(comp$cost, 0)
  imp_clamped$imp$utility[[i]] <- comp$utility[is.na(trial_data$utility)]
  imp_clamped$imp$cost[[i]] <- comp$cost[is.na(trial_data$cost)]
}
