# Extracted from ch10_survival_analysis.typ, lines 611-621
# Section: === Parametric extrapolation of transition-specific hazards with `flexsurv`
# Chapter: 10

library(flexsurv)

transition_fits <- lapply(1:3, function(k) {
  flexsurvreg(
    Surv(Tstart, Tstop, status) ~ 1,
    data = subset(msdat, trans == k),
    dist = "weibull"
  )
})
