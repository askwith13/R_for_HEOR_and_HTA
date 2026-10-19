# Extracted from ch10_survival_analysis.typ, lines 67-72
# Section: == 10.1 Kaplan-Meier and life tables
# Chapter: 10

library(survminer)

ggsurvplot(fit, data = trial_df, risk.table = TRUE,
           conf.int = TRUE, pval = TRUE)
