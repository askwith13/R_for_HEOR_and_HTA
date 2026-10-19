# Extracted from ch15_rwe_causal_inference.typ, lines 72-111
# Section: == 15.2 Study design: cohort, case-control, target trial emulation
# Chapter: 15

library(tibble)
library(dplyr)

# A target trial protocol, specified as a structured object before any
# emulation code touches the observational extract. Writing this first
# is the TTE discipline, not an optional add-on.
target_trial_protocol <- tribble(
  ~component,            ~specification,
  "Eligibility",         "Adults starting first-line TB treatment, no prior TB Rx",
  "Treatment strategies","Bedaquiline-containing vs standard injectable-containing regimen",
  "Assignment",          "Hypothetical randomisation at treatment initiation",
  "Time zero",           "Date of first regimen dispense (must equal eligibility date)",
  "Outcome",             "WHO-defined treatment success at 6 months",
  "Causal contrast",     "Intention-to-treat and per-protocol effects",
  "Analysis",            "IPTW-adjusted Kaplan-Meier / Cox, with cloning-censoring-weighting for per-protocol"
)

print(target_trial_protocol, n = Inf)

# Emulating "time zero" correctly: every patient's follow-up clock
# starts at regimen initiation, not at diagnosis or enrolment
cohort <- tibble(
  patient_id   = 1:6,
  diagnosis_dt = as.Date(c("2022-01-05","2022-01-10","2022-02-01",
                            "2022-02-15","2022-03-01","2022-03-10")),
  regimen_start= as.Date(c("2022-01-07","2022-01-20","2022-02-02",
                            "2022-02-28","2022-03-01","2022-03-25")),
  regimen      = c("Bedaquiline","Injectable","Bedaquiline",
                    "Injectable","Bedaquiline","Injectable")
)

cohort <- cohort %>%
  mutate(
    lead_in_days = as.numeric(regimen_start - diagnosis_dt),
    time_zero    = regimen_start   # NOT diagnosis_dt -- avoids immortal time bias
  )

cohort
