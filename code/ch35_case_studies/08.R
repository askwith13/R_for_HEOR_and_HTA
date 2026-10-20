# Extracted from ch35_case_studies.typ, lines 215-230
# Section: === Step (a): fitting parametric curves to comparator patient-level data
# Chapter: 35

library(flexsurv)
library(survival)

set.seed(4102)
n_pts <- 400
pfs_time_raw <- rweibull(n_pts, shape = 1.3, scale = 7.5)
os_time_raw  <- pmax(pfs_time_raw, rweibull(n_pts, shape = 1.15, scale = 14.0))
admin_censor <- 36
pfs_time  <- pmin(pfs_time_raw, admin_censor); pfs_event <- as.numeric(pfs_time_raw <= admin_censor)
os_time   <- pmin(os_time_raw,  admin_censor); os_event  <- as.numeric(os_time_raw  <= admin_censor)
ipd <- data.frame(pfs_time, pfs_event, os_time, os_event)

fit_pfs_comp <- flexsurvreg(Surv(pfs_time, pfs_event) ~ 1, data = ipd, dist = "weibull")
fit_os_comp  <- flexsurvreg(Surv(os_time,  os_event)  ~ 1, data = ipd, dist = "weibull")
