# Extracted from ch12_itc_nma.typ, lines 199-215
# Section: === 12.3.3 Fitting the network: `netmeta()`
# Chapter: 12

net_tb <- netmeta(
  TE          = TE,
  seTE        = seTE,
  treat1      = treat1,
  treat2      = treat2,
  studlab     = studlab,
  data        = tb_pairs,
  sm          = "OR",
  common      = TRUE,
  random      = TRUE,
  reference.group = "C",
  details.chkmultiarm = TRUE
)

summary(net_tb)
