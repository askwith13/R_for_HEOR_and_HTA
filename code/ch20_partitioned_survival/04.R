# Extracted from ch20_partitioned_survival.typ, lines 128-141
# Section: == 20.6 Worked example: an oncology CEA
# Chapter: 20

library(flexsurv)

# Weibull survival at time t: S(t) = exp(-(t/scale)^shape)
weib_S <- function(t, shape, scale) exp(-(t / scale)^shape)

arms <- list(
  soc = list(pfs = c(shape = 1.2, scale = 1.0), os = c(shape = 1.1, scale = 2.0),
             cost_pfs = 3000, cost_prog = 2000, cost_death = 1000),
  new = list(pfs = c(shape = 1.2, scale = 1.5), os = c(shape = 1.1, scale = 2.5),
             cost_pfs = 5000, cost_prog = 2000, cost_death = 1000)
)
util_pfs <- 0.75; util_prog <- 0.55
