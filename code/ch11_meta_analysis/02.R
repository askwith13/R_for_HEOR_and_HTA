# Extracted from ch11_meta_analysis.typ, lines 63-74
# Section: == 11.1 Fixed-effect and random-effects models
# Chapter: 11

library(metafor)

dat <- escalc(measure = "RR",
              ai = events_treatment, n1i = n_treatment,
              ci = events_control,  n2i = n_control,
              data = tb_studies)

fit_dl   <- rma(yi, vi, data = dat, method = "DL")    # DerSimonian-Laird
fit_reml <- rma(yi, vi, data = dat, method = "REML")  # restricted max. likelihood
summary(fit_reml)
