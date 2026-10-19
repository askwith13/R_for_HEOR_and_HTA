# Extracted from ch10_survival_analysis.typ, lines 299-308
# Section: == 10.5 Piecewise and landmark models
# Chapter: 10

tail_data <- subset(tb_followup, time > landmark_time)

fit_tail <- flexsurvspline(
  Surv(time, status) ~ 1,
  data = tb_followup,
  k = 1,
  scale = "hazard"
)
