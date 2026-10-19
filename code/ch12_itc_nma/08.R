# Extracted from ch12_itc_nma.typ, lines 346-353
# Section: === gemtc: the NICE DSU TSD 2 reference implementation
# Chapter: 12

model <- mtc.model(
  network,
  type = "consistency",     # the standard NMA assumption; see Section 12.5
  linearModel = "random",   # random-effects; "fixed" for common-effect
  n.chain = 4
)
