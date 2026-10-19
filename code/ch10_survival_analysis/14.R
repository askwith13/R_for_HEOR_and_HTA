# Extracted from ch10_survival_analysis.typ, lines 405-412
# Section: === Testing the proportional hazards assumption
# Chapter: 10

library(survival)

cox_fit <- coxph(Surv(time, status) ~ arm + age + ecog_ps, data = os_data)
zph_test <- cox.zph(cox_fit)
zph_test
plot(zph_test, var = "arm")
