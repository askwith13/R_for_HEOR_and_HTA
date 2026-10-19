# Extracted from ch11_meta_analysis.typ, lines 37-51
# Section: == 11.1 Fixed-effect and random-effects models
# Chapter: 11

library(meta)

# Binary outcome: treatment success, event counts per arm
m_bin <- metabin(
  event.e = events_treatment, n.e = n_treatment,
  event.c = events_control,  n.c = n_control,
  data = tb_studies,
  sm = "RR",
  method = "MH",        # Mantel-Haenszel for the fixed-effect pooling step
  method.tau = "REML"   # tau^2 estimator for the random-effects layer
)
summary(m_bin)
forest(m_bin)
