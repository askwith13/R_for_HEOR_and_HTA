# Extracted from ch24_cba_dcea_ecea.typ, lines 673-710
# Section: == 24.5 Severity modifiers, value-based pricing, and managed entry agreements
# Chapter: 24

# Illustrative NICE-style severity-modifier calculation and its effect
# on a submitted ICER -- not a real appraisal, parameters chosen for
# the worked example only.

qale_general_population <- 20.4    # expected remaining QALYs, matched age/sex
qale_with_condition     <- 4.2     # expected remaining QALYs under current NHS care

absolute_shortfall     <- qale_general_population - qale_with_condition
proportional_shortfall <- absolute_shortfall / qale_general_population

severity_weight <- function(abs_shortfall, prop_shortfall) {
  # Table 6.1, NICE health technology evaluations manual (PMG36), 2022
  if (prop_shortfall >= 0.95 || abs_shortfall >= 18) {
    1.7
  } else if (prop_shortfall >= 0.85 || abs_shortfall >= 12) {
    1.2
  } else {
    1
  }
}

w <- severity_weight(absolute_shortfall, proportional_shortfall)

incremental_cost <- 2400   # $ per patient
incremental_qaly <- 0.08   # unweighted QALY gain per patient

icer_unweighted <- incremental_cost / incremental_qaly
icer_weighted   <- incremental_cost / (incremental_qaly * w)

list(
  absolute_shortfall = absolute_shortfall,
  proportional_shortfall = round(proportional_shortfall, 3),
  severity_weight = w,
  icer_unweighted = icer_unweighted,
  icer_weighted = icer_weighted
)
