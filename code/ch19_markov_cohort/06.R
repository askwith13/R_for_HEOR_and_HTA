# Extracted from ch19_markov_cohort.typ, lines 307-318
# Section: == 19.8 Probabilistic transition matrices (Dirichlet) and Cholesky decomposition
# Chapter: 19

library(dampack)

# Illustrative counts underlying the OnTx row: Cured / Fail / Death / OnTx (stay)
# (e.g. out of 100 patients starting a cycle On Treatment: 75 cured, 8 failed, 2 died,
#  with the remainder continuing on treatment -- counts need not match cycle fractions
#  exactly, they encode the *evidence strength* behind each cell)
alpha_ontx <- c(Cured = 75, Fail = 8, Death = 2, OnTx = 15)

psa_draws_ontx <- dampack::rdirichlet(n = 1000, alpha = alpha_ontx)
# each row of psa_draws_ontx sums to 1 by construction -- no post-hoc renormalisation needed
