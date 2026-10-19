# Extracted from ch11_meta_analysis.typ, lines 367-372
# Section: == 11.7 Meta-analysis of proportions and rates
# Chapter: 11

# dat has xi (events) and ti (total person-time) per study/site
dat_rate <- escalc(measure = "IRLN", xi = xi, ti = ti, data = dat)
res_rate <- rma(yi, vi, data = dat_rate, method = "REML")
predict(res_rate, transf = exp)   # back-transform to events per person-time unit
