# Extracted from ch10_survival_analysis.typ, lines 658-684
# Section: === Using `IPDfromKM`
# Chapter: 10

library(IPDfromKM)

# Step 1: digitize the curve (coordinates read from the published figure,
# e.g. via a digitizer such as WebPlotDigitizer or Engauge)
preprocessed <- getpoints(
  dat     = digitized_coordinates,
  tot.events = NULL,
  trisk   = risk_table_times,
  nrisk.data = risk_table_numbers
)

# Step 2: getIPD() runs the Guyot et al. algorithm to back-calculate
# individual event/censoring times consistent with both the digitized
# curve and the risk table
reconstructed <- getIPD(
  prep    = preprocessed,
  armID   = 1,
  tot.events = NULL
)

ipd_fit <- flexsurv::flexsurvreg(
  survival::Surv(time, status) ~ 1,
  data = reconstructed$IPD,
  dist = "weibull"
)
