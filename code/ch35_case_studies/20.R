# Extracted from ch35_case_studies.typ, lines 701-717
# Section: === Computing year-by-year budget impact
# Chapter: 35

library(ggplot2)

bia_long <- data.frame(
  year = rep(years, 2),
  scenario = rep(c("Reference (oral only)", "New (with LAI uptake)"), each = n_years),
  cost = c(ref_total_cost, new_total_cost)
)

ggplot(bia_long, aes(x = year, y = cost / 1e6, colour = scenario)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  labs(x = "Year", y = "Total annual cost (millions LCU)",
       title = "Budget impact of LAI introduction: reference vs. new scenario",
       colour = NULL) +
  theme_minimal()
