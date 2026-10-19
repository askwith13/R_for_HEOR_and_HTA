# Extracted from ch20_partitioned_survival.typ, lines 92-104
# Section: == 20.4 Modelling with `hesim`, `flexsurv` and custom code
# Chapter: 20

# fit_pfs, fit_os are flexsurvreg objects (Section 20.1)
psm_occupancy <- function(fit_pfs, fit_os, times) {
  s_pfs <- summary(fit_pfs, t = times, type = "survival")[[1]]$est
  s_os  <- summary(fit_os,  t = times, type = "survival")[[1]]$est
  data.frame(
    time         = times,
    p_pfs        = s_pfs,
    p_dead       = 1 - s_os,
    p_progressed = pmax(0, s_os - s_pfs)  # floor at 0: see 20.5
  )
}
