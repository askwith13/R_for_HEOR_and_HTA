# Extracted from ch14_bayesian_methods.typ, lines 357-368
# Section: === Why this matters more as networks get more complex
# Chapter: 14

# Recall from Chapter 12: a gemtc NMA fit
library(gemtc)

# mcmc.list of relative-effect draws, one column per contrast
relative_effects <- relative.effect(nma_fit, t1 = "placebo")
re_samples <- as.matrix(relative_effects$samples)

# Each row is one joint posterior draw across every contrast --
# correlations between contrasts are preserved automatically
head(re_samples)
