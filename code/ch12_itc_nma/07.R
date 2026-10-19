# Extracted from ch12_itc_nma.typ, lines 317-332
# Section: === gemtc: the NICE DSU TSD 2 reference implementation
# Chapter: 12

library(gemtc)

# Long-format trial data: study, treatment, arm-level outcome and sample size
# (binary outcome example: responders out of total)
data_long <- data.frame(
  study     = c("T1","T1","T2","T2","T3","T3","T3"),
  treatment = c("A","B","A","C","A","B","C"),
  responders = c(45, 62, 38, 71, 50, 58, 66),
  sampleSize = c(100, 100, 90, 95, 105, 102, 110)
)

network <- mtc.network(data.ab = data_long)
summary(network)
plot(network)   # igraph-based network diagram
