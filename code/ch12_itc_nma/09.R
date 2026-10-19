# Extracted from ch12_itc_nma.typ, lines 359-365
# Section: === gemtc: the NICE DSU TSD 2 reference implementation
# Chapter: 12

result <- mtc.run(model, n.adapt = 5000, n.iter = 20000, thin = 10)

summary(result)
gemtc::forest(relative.effect(result, t1 = "A"))
gelman.diag(result)                 # convergence check, target < 1.05
