# Extracted from ch12_itc_nma.typ, lines 602-649
# Section: === Single-study building block with flexsurv, and the bespoke network step
# Chapter: 12

library(flexsurv)
library(survival)

# Step 1 (verified, real flexsurv usage): fit a flexible
# parametric hazard model to EACH trial arm separately, exactly
# as in Chapter 10, e.g. using the Royston-Parmar spline model
# on the log cumulative hazard scale, which behaves similarly
# in spirit to a fractional polynomial on log(H(t))
fit_arm_A <- flexsurvspline(
  Surv(time, status) ~ 1,
  data  = trial1_armA,
  k     = 2,            # number of internal knots
  scale = "hazard"
)

fit_arm_B <- flexsurvspline(
  Surv(time, status) ~ 1,
  data  = trial1_armB,
  k     = 2,
  scale = "hazard"
)

# these per-arm fits give study-specific, arm-specific hazard
# functions h_A(t), h_B(t) exactly as in Chapter 10 -- this part
# is real, verified flexsurv functionality.

# Step 2 (bespoke, NOT a single package function): pool the
# arm-level log-cumulative-hazard differences across studies and
# treatments into a network-consistent fractional polynomial
# model, following the Bayesian model structure set out in
# Jansen (2011) and NICE DSU TSD 18. Conceptually:
#
#   for each study i, each arm k:
#     log(H_ik(t)) ~ mu_i + sum_j beta_{j,trt(k)} * f_j(t)
#     beta_{j,trt(k)} ~ Normal(d_{j,trt(k)}, sigma_j^2)   [study-level RE]
#     d_{j,k} are the network's basic parameters for FP term j,
#     treatment k, estimated jointly across the whole network
#     (random-effects consistency model, as in sections 12.2-12.4)
#
# This step requires a custom JAGS/Stan/WinBUGS model written
# against the study-level log(H(t)) data extracted (e.g. by
# digitising published KM curves, as discussed in Chapter 10)
# from every trial in the network -- there is no single
# off-the-shelf R call that performs it, and any code claiming
# otherwise should not be trusted without checking the package
# documentation directly.
