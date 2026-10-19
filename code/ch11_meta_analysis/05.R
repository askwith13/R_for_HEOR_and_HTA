# Extracted from ch11_meta_analysis.typ, lines 155-159
# Section: == 11.3 Publication bias and small-study effects
# Chapter: 11

tf <- trimfill(m_bin)
summary(tf)
funnel(tf)   # visualize imputed studies alongside observed ones
