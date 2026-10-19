# Extracted from ch12_itc_nma.typ, lines 713-721
# Section: == 12.8 Ranking, SUCRA and rankograms
# Chapter: 12

library(netmeta)

rank_tb <- netrank(net_tb, small.values = "good")   # P-scores, as in §12.3.5
rankogram_tb <- rankogram(net_tb, nsim = 10000, small.values = "good")

plot(rankogram_tb)
print(rankogram_tb$ranking.matrix)
