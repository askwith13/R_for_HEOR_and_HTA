# Extracted from ch12_itc_nma.typ, lines 270-281
# Section: === 12.3.6 Full pairwise results: `netleague()`
# Chapter: 12

league_tb <- netleague(
  net_tb,
  common = FALSE,
  random = TRUE,
  seq    = rank_tb,
  ci     = TRUE,
  digits = 2
)

league_tb
