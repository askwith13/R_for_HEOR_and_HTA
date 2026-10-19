# Extracted from ch12_itc_nma.typ, lines 418-431
# Section: === Node-splitting: direct vs indirect evidence on one edge
# Chapter: 12

library(gemtc)

splits <- mtc.nodesplit(
  network,
  linearModel = "random",
  n.adapt = 5000,
  n.iter = 20000,
  thin = 10
)

summary(splits)
plot(splits)
