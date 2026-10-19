# Extracted from ch11_meta_analysis.typ, lines 192-199
# Section: == 11.4 Meta-regression
# Chapter: 11

library(metafor)

# dat has yi (effect size, e.g. log-RR), vi (sampling variance),
# and a study-level moderator, mean_age
res_mod <- rma(yi, vi, mods = ~ mean_age, data = dat, method = "REML")
summary(res_mod)
