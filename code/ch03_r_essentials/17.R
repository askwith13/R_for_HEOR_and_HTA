# Extracted from ch03_r_essentials.typ, lines 449-451
# Section: == 3.6 Dates, durations and time-to-event data (`lubridate`)
# Chapter: 3

time_to_progression <- difftime(progression_date, enrol_date, units = "days")
