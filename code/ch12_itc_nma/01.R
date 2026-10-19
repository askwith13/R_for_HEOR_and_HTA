# Extracted from ch12_itc_nma.typ, lines 92-120
# Section: === 12.2.3 Worked example: TB regimen comparison
# Chapter: 12

bucher_itc <- function(d_AC, se_AC, d_BC, se_BC, scale = c("log", "natural")) {
  scale <- match.arg(scale)
  d_AB  <- d_AC - d_BC
  se_AB <- sqrt(se_AC^2 + se_BC^2)
  ci_lo <- d_AB - 1.96 * se_AB
  ci_hi <- d_AB + 1.96 * se_AB

  if (scale == "natural") {
    out <- data.frame(
      estimate = exp(d_AB),
      ci_lower = exp(ci_lo),
      ci_upper = exp(ci_hi)
    )
  } else {
    out <- data.frame(
      estimate = d_AB,
      ci_lower = ci_lo,
      ci_upper = ci_hi
    )
  }
  out
}

# TB worked example: Regimen A vs C, Regimen B vs C, via common comparator C
bucher_itc(d_AC = -0.52, se_AC = 0.18, d_BC = -0.28, se_BC = 0.21, scale = "natural")
#>    estimate  ci_lower ci_upper
#> 1 0.7866279 0.4575463 1.351880
