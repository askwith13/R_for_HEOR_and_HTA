# Extracted from ch11_meta_analysis.typ, lines 104-113
# Section: == 11.2 Heterogeneity and its quantification
# Chapter: 11

summary(m_bin)     # reports Q, tau^2, I^2, and their CIs alongside the pooled estimate
forest(m_bin,
       sortvar = TE,          # order studies by effect size
       prediction = TRUE)     # adds a prediction interval for a new study's true effect

# metafor equivalent
summary(fit_reml)
forest(fit_reml)
