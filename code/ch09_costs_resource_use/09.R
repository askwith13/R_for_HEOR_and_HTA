# Extracted from ch09_costs_resource_use.typ, lines 281-291
# Section: === Smooths and flexible mean functions
# Chapter: 9

library(mgcv)

fit_gam <- gam(
  cost ~ regimen + s(age),
  family = Gamma(link = "log"),
  data   = pos_costs
)
summary(fit_gam)
plot(fit_gam, pages = 1)
