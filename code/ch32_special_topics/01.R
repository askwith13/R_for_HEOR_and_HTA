# Extracted from ch32_special_topics.typ, lines 48-96
# Section: == 32.1 Oncology: immuno-oncology, long-term survival and cure assumptions
# Chapter: 32

library(flexsurv)
library(flexsurvcure)
library(survival)

set.seed(32104)
n <- 250

# Simulate a cure fraction: ~30% of patients never experience
# the event and are administratively censored at end of follow-up;
# the remainder follow a Weibull hazard.
true_cure_fraction <- 0.30
is_cured <- rbinom(n, 1, true_cure_fraction)
followup_end <- 60  # months of trial follow-up

event_time <- ifelse(
  is_cured == 1,
  followup_end + 1,                      # cured: would never see the event
  rweibull(n, shape = 1.3, scale = 18)   # uncured: standard Weibull hazard
)

obs_time  <- pmin(event_time, followup_end)
event_ind <- as.numeric(event_time <= followup_end)

onc_data <- data.frame(time = obs_time, status = event_ind)

# A standard (non-cure) Weibull fit, as covered conceptually in Chapter 12,
# forces a single monotonic hazard through the whole curve:
fit_weibull <- flexsurvreg(
  Surv(time, status) ~ 1,
  data = onc_data,
  dist = "weibull"
)

# A mixture cure model explicitly separates a cured fraction from an
# uncured Weibull-distributed group:
fit_cure <- flexsurvcure(
  Surv(time, status) ~ 1,
  data = onc_data,
  dist = "weibull",
  mixture = TRUE,
  link = "logistic"
)

print(fit_cure)
# The fitted "theta" parameter is the estimated cure fraction, which can be
# compared against the simulated true_cure_fraction (0.30) as a sanity check,
# and against external long-term data where available.
