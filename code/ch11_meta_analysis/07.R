# Extracted from ch11_meta_analysis.typ, lines 250-264
# Section: == 11.5 Meta-analysis of time-to-event outcomes
# Chapter: 11

library(meta)

# dat has studlab, TE (= log HR per study), seTE (SE of log HR)
m_hr <- metagen(
  TE = TE,
  seTE = seTE,
  studlab = studlab,
  data = dat,
  sm = "HR",          # tells meta the pooled estimate is a hazard ratio
  method.tau = "REML"
)
summary(m_hr)
forest(m_hr)
