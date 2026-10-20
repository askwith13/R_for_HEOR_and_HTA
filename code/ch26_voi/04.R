# Extracted from ch26_voi.typ, lines 701-718
# Section: === Moment-matching
# Chapter: 26

# Illustrative moment-matching EVSI for p_ontx_fail, n = 200 future patients
a_prior <- 8; b_prior <- 92
n_future <- 200
r_expected <- n_future * (a_prior / (a_prior + b_prior))  # expected failures

var_prior <- (a_prior * b_prior) /
  ((a_prior + b_prior)^2 * (a_prior + b_prior + 1))

a_post <- a_prior + r_expected
b_post <- b_prior + (n_future - r_expected)
var_post <- (a_post * b_post) /
  ((a_post + b_post)^2 * (a_post + b_post + 1))

frac_reduced <- 1 - var_post / var_prior
evppi_full   <- 900     # illustrative, from the §26.3 GAM regression
evsi_n200    <- evppi_full * frac_reduced
