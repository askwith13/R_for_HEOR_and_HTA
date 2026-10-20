# Extracted from ch32_special_topics.typ, lines 118-149
# Section: == 32.2 Rare diseases and ultra-orphan drugs
# Chapter: 32

library(survival)

# Tiny single-arm trial: n = 18 patients on the new ultra-orphan therapy
trial_data <- data.frame(
  time   = c(4, 7, 9, 11, 14, 15, 18, 20, 22, 25, 27, 30, 33, 36, 40, 44, 48, 52),
  status = c(1, 1, 1, 0,  1,  1,  0,  1,  1,  0,  1,  1,  0,  1,  0,  1,  0,  1),
  group  = "new_therapy"
)

# A small historical-control dataset, e.g. extracted from a disease
# registry describing outcomes under prior standard of care
historical_data <- data.frame(
  time   = c(2, 3, 5, 6, 8, 8, 10, 12, 13, 15, 16, 18, 19, 21, 23, 26, 28, 31),
  status = c(1, 1, 1, 1, 1, 1, 1,  1,  0,  1,  1,  0,  1,  1,  0,  1,  1,  1),
  group  = "historical_control"
)

combined <- rbind(trial_data, historical_data)
combined$group <- factor(combined$group, levels = c("historical_control", "new_therapy"))

fit <- survfit(Surv(time, status) ~ group, data = combined)
print(fit)

# An unadjusted Cox model gives a first-pass, honestly crude estimate of the
# association -- it does NOT control for the two groups potentially differing
# in age, disease severity, or era of care, which is exactly the limitation
# that a matching or Bayesian-borrowing approach would need to address before
# this comparison could support a cost-effectiveness claim.
cox_fit <- coxph(Surv(time, status) ~ group, data = combined)
summary(cox_fit)
