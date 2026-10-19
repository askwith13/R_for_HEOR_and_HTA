# Extracted from ch03_r_essentials.typ, lines 383-386
# Section: == 3.6 Dates, durations and time-to-event data (`lubridate`)
# Chapter: 3

progression_interval <- interval(enrol_date, progression_date)
time_length(progression_interval, unit = "months")
