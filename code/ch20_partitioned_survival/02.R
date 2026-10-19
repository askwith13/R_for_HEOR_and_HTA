# Extracted from ch20_partitioned_survival.typ, lines 50-62
# Section: == 20.2 Building PSMs from survival extrapolations
# Chapter: 20

times <- seq(0, 60, by = 1)  # months

s_pfs <- summary(fit_pfs, type = "survival", t = times)[[1]]$est
s_os  <- summary(fit_os,  type = "survival", t = times)[[1]]$est

occupancy <- data.frame(
  time         = times,
  p_pfs        = s_pfs,
  p_progressed = s_os - s_pfs,
  p_dead       = 1 - s_os
)
