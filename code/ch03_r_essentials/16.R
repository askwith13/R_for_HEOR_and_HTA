# Extracted from ch03_r_essentials.typ, lines 434-441
# Section: == 3.6 Dates, durations and time-to-event data (`lubridate`)
# Chapter: 3

library(lubridate)

enrol_date <- ymd("2021-03-14")
visit_date <- dmy("14/03/2021")

as.Date("2021-03-14")  # base R equivalent, but order must match exactly
