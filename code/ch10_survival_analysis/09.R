# Extracted from ch10_survival_analysis.typ, lines 226-234
# Section: == 10.4 Mixture-cure and non-mixture cure models
# Chapter: 10

fit_mix_cov <- flexsurvcure(
  Surv(time, status) ~ arm,
  data = tb_followup,
  dist = "weibull",
  mixture = TRUE,
  anc = list(shape = ~ arm)
)
