# Extracted from ch11_meta_analysis.typ, lines 280-294
# Section: == 11.6 Diagnostic test accuracy meta-analysis
# Chapter: 11

library(mada)

# dat has TP, FN, FP, TN counts for each study against the reference standard
fit <- reitsma(dat)        # dat needs columns named TP, FN, FP, TN
summary(fit)

# descriptive diagnostic stats (sens, spec, likelihood ratios) per study
desc <- madad(dat)
print(desc)

# SROC curve with confidence and prediction regions
plot(fit, sroc.type = "ruttergates")
points(fpr(desc), sens(desc), pch = 2)
