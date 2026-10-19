# Extracted from ch10_survival_analysis.typ, lines 376-381
# Section: == 10.6 Model selection: AIC/BIC, visual fit, clinical plausibility
# Chapter: 10

plot(fits$weibull, type = "survival")
lines(survfit(Surv(time, status) ~ 1, data = tb_followup), col = "grey40")

plot(fits$gompertz, type = "survival", t = seq(0, 240, by = 1))
