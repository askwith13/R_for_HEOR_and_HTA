# Extracted from ch09_costs_resource_use.typ, lines 365-388
# Section: == 9.6 Handling censored cost data
# Chapter: 9

library(survival)
library(dplyr)

# cohort: one row per patient
#   time_obs   - time followed (to cost cut-off, death, loss-to-follow-up)
#   cost_obs   - total cost accrued up to time_obs
#   event      - 1 = fully observed / died (not censored), 0 = censored

# Step 1: KM estimate of the CENSORING distribution -- flip the event indicator
cens_fit <- survfit(Surv(time_obs, 1 - event) ~ 1, data = cohort)

# Step 2: censoring survival probability just before each patient's own time
G_at <- summary(cens_fit, times = cohort[["time_obs"]], extend = TRUE)[["surv"]]

cohort <- cohort |>
  mutate(
    G_hat   = pmax(G_at, 0.01),         # guard against near-zero denominators
    ipcw_wt = event / G_hat             # zero weight for censored patients
  )

ipcw_mean_cost <- with(cohort, sum(ipcw_wt * cost_obs) / sum(ipcw_wt))
ipcw_mean_cost
