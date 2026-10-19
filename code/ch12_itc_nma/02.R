# Extracted from ch12_itc_nma.typ, lines 165-187
# Section: === 12.3.2 Preparing contrast-level data: `pairwise()`
# Chapter: 12

library(netmeta)

# Arm-level extraction: one row per trial arm
tb_arms <- data.frame(
  study     = c("Trial1","Trial1","Trial2","Trial2",
                "Trial3","Trial3","Trial4","Trial4"),
  treatment = c("A","C","B","C","A","B","D","C"),
  events    = c(18,  34,  22,  36,  15,  19,  28,  33),
  n         = c(80,  82,  78,  80,  60,  58,  75,  77)
)

tb_pairs <- pairwise(
  treat   = treatment,
  event   = events,
  n       = n,
  studlab = study,
  data    = tb_arms,
  sm      = "OR"
)

head(tb_pairs)
