# Extracted from ch04_core_concepts.typ, lines 230-235
# Section: == 4.4 ICERs, net monetary benefit (NMB) and net health benefit (NHB)
# Chapter: 4

lambda <- 20000   # GBP per QALY, illustrative threshold
nmb <- delta_E * lambda - delta_C
nhb <- delta_E - delta_C / lambda
nmb; nhb
