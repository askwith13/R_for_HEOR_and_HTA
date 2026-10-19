# Extracted from ch12_itc_nma.typ, lines 669-677
# Section: == 12.8 Ranking, SUCRA and rankograms
# Chapter: 12

rank_probs <- rank.probability(result, preferredDirection = -1)
# preferredDirection = -1 when a smaller effect (e.g. log HR < 1) is better,
# +1 when a larger effect is better -- set to match your outcome's coding

print(rank_probs)
sucra(rank_probs)
plot(rank_probs)   # rankogram: stacked probability of each rank, per treatment
