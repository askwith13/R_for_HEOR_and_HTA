# Extracted from ch10_survival_analysis.typ, lines 39-44
# Section: == 10.1 Kaplan-Meier and life tables
# Chapter: 10

library(survival)

fit <- survfit(Surv(time, status) ~ arm, data = trial_df)
summary(fit)
