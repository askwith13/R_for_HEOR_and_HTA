# Extracted from ch12_itc_nma.typ, lines 375-396
# Section: === multinma: a unified Stan-based alternative
# Chapter: 12

library(multinma)

network_ad <- set_agd_arm(
  data_long,
  study = study,
  trt = treatment,
  r = responders,
  n = sampleSize
)

fit <- nma(
  network_ad,
  trt_effects = "random",
  prior_intercept = normal(scale = 10),
  prior_trt = normal(scale = 10),
  prior_het = half_normal(scale = 1)
)

print(fit)
plot(relative_effects(fit))
