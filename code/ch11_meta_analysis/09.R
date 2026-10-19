# Extracted from ch11_meta_analysis.typ, lines 348-355
# Section: == 11.7 Meta-analysis of proportions and rates
# Chapter: 11

library(metafor)

# dat has xi (events, e.g. resistant cases) and ni (total tested) per study
dat_logit <- escalc(measure = "PLO", xi = xi, ni = ni, data = dat)
res_logit <- rma(yi, vi, data = dat_logit, method = "REML")
predict(res_logit, transf = transf.ilogit)   # back-transform to a proportion
