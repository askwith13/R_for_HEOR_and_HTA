# Extracted from ch04_core_concepts.typ, lines 122-132
# Section: == 4.4 ICERs, net monetary benefit (NMB) and net health benefit (NHB)
# Chapter: 4

cost_new <- 1800 * 12   # simplified lifetime cost proxy, GBP
cost_comp <- 400 * 12
qaly_new <- 8.42
qaly_comp <- 8.14

delta_C <- cost_new - cost_comp
delta_E <- qaly_new - qaly_comp
icer <- delta_C / delta_E
icer
