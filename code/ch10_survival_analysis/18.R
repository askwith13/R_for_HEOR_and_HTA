# Extracted from ch10_survival_analysis.typ, lines 506-509
# Section: === Treatment-effect-specific extrapolation
# Chapter: 10

newdat <- data.frame(arm = c("control", "treatment"), age = 60, ecog_ps = 1)
summary(shape_fit, newdata = newdat, t = seq(0, 60, by = 1), type = "survival")
