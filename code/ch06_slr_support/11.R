# Extracted from ch06_slr_support.typ, lines 440-456
# Section: == 6.5 Risk of bias visualisation (`robvis`)
# Chapter: 6

robins_data <- tibble::tibble(
  Study = c("Mbeki2019", "Santos2021"),
  D1 = c("Low", "Moderate"),
  D2 = c("Moderate", "Low"),
  D3 = c("Low", "Low"),
  D4 = c("Serious", "Moderate"),
  D5 = c("Low", "Low"),
  D6 = c("Low", "Low"),
  D7 = c("Moderate", "Low"),
  Overall = c("Serious", "Moderate"),
  Weight = c(50, 50)
)

rob_traffic_light(data = robins_data, tool = "ROBINS-I")
rob_summary(data = robins_data, tool = "ROBINS-I", overall = TRUE)
