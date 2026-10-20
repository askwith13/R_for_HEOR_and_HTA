# Extracted from ch26_voi.typ, lines 503-535
# Section: == 26.3 Efficient EVPPI via regression and GAM approximations
# Chapter: 26

library(mgcv)

# psa_df: one row per PSA iteration (Chapter 25 §25.4's n_psa = 2000 draws),
# with the sampled parameter of interest and the resulting incremental NMB
# at the chosen WTP, carried over unchanged from §25.4-§25.5.
psa_df <- data.frame(
  p_ontx_fail = psa_p_fail,         # the parameter we want EVPPI for
  inmb        = inmb                # incremental NMB per draw, from §25.5
)

# Fit a smooth (not forced-linear) regression of incremental NMB on the
# parameter of interest. s() requests a GAM smooth term; k is left to
# mgcv's default automatic smoothness selection (REML) rather than
# hand-chosen, per the pitfall below.
gam_fit <- gam(inmb ~ s(p_ontx_fail), data = psa_df, method = "REML")

# Fitted values: the GAM's estimate of E[incremental NMB | p_ontx_fail]
# at each PSA draw's own sampled p_ontx_fail value.
fitted_inmb <- predict(gam_fit)

# EVPPI from fitted values, using the SAME EVPI-style logic as §26.1-26.2,
# just applied to the fitted (conditional-mean) values instead of the raw
# per-draw incremental NMB. Working directly from incremental NMB (New
# minus SoC), the reference point for "no information" is zero rather than
# a second strategy's own NMB:
#   - "perfect information about p_ontx_fail alone" -> decide using the
#     fitted conditional mean at each draw's own p_ontx_fail value
#   - "fixed choice" -> decide using the single overall mean fitted value
evppi_fail <- mean(pmax(fitted_inmb, 0)) - max(mean(fitted_inmb), 0)

cat("Illustrative EVPPI for p_ontx_fail:", evppi_fail, "\n")
