# Extracted from ch11_meta_analysis.typ, lines 157-165
# Section: == 11.3 Publication bias and small-study effects
# Chapter: 11

# meta package
funnel(m_bin)
metabias(m_bin, method.bias = "linreg")   # Egger's regression test

# metafor package
funnel(fit_reml)
regtest(fit_reml, model = "lm")           # Egger's test equivalent
