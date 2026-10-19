# Extracted from ch20_partitioned_survival.typ, lines 38-46
# Section: == 20.2 Building PSMs from survival extrapolations
# Chapter: 20

library(flexsurv)

# Fit Weibull curves separately to PFS and OS data
fit_pfs <- flexsurvreg(formula = Surv(time, event) ~ 1,
                       data = pfs_data, dist = "weibull")
fit_os  <- flexsurvreg(formula = Surv(time, event) ~ 1,
                       data = os_data,  dist = "weibull")
