# Extracted from ch15_rwe_causal_inference.typ, lines 241-253
# Section: === Checking balance with cobalt
# Chapter: 15

library(cobalt)

bal.tab(w.out, un = TRUE, m.threshold = 0.1)   # table: unadjusted vs weighted SMDs

love.plot(
  w.out,
  binary   = "std",
  thresholds = c(m = 0.1),
  abs      = TRUE,
  var.order = "unadjusted"
)
