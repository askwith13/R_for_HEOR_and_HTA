# Extracted from ch35_case_studies.typ, lines 345-363
# Section: === Step (e): structural-uncertainty scenarios
# Chapter: 35

# Baseline comparator OS cumulative hazard (Weibull): H(t) = (t/scale)^shape
H_comp <- function(t) (t / scale_os_comp)^shape_os

# Time-varying HR: full effect (0.68) until month 24, linearly waning to 1.0 by month 36
hr_waning <- function(t) {
  ifelse(t <= 24, 0.68, ifelse(t >= 36, 1, 0.68 + (1 - 0.68) * (t - 24) / 12))
}

# New arm's cumulative hazard at time t = integral of hr_waning(u) against the
# baseline's cumulative-hazard increments, via fine-grained numerical integration
t_fine      <- seq(0, horizon_months, by = 0.1)
dH_comp_fine <- c(0, diff(H_comp(t_fine)))        # increments of baseline cum. hazard
H_new_fine  <- cumsum(hr_waning(t_fine) * dH_comp_fine)

# Interpolate the new arm's cumulative hazard back onto the model's monthly cycles
H_new_at_cycles <- approx(t_fine, H_new_fine, xout = cycles)$y
S_os_new_waning <- exp(-H_new_at_cycles)
