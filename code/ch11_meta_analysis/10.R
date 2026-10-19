# Extracted from ch11_meta_analysis.typ, lines 359-363
# Section: == 11.7 Meta-analysis of proportions and rates
# Chapter: 11

dat_pft <- escalc(measure = "PFT", xi = xi, ni = ni, data = dat)
res_pft <- rma(yi, vi, data = dat_pft, method = "REML")
predict(res_pft, transf = transf.ipft.hm, ni = dat_pft$ni)  # back-transform
