# Extracted from ch15_rwe_causal_inference.typ, lines 293-302
# Section: === A worked numeric example: IPTW ATE by hand
# Chapter: 15

# Reproduce the hand calculation in R
toy <- data.frame(
  T  = c(1,1,1,0,0,0),
  Y  = c(10,8,12,4,6,2),
  ps = c(0.5,0.4,0.6,0.5,0.4,0.6)
)
mean(toy$T * toy$Y / toy$ps) - mean((1 - toy$T) * toy$Y / (1 - toy$ps))
#> 6.166667
