# Extracted from ch23_budget_impact.typ, lines 552-571
# Section: == 23.5 Presenting results to payers
# Chapter: 23

library(ggplot2)
library(tidyr)

plot_data <- bia_base %>%
  mutate(cumulative_bi = cumsum(budget_impact)) %>%
  select(year, budget_impact, cumulative_bi) %>%
  pivot_longer(cols = c(budget_impact, cumulative_bi),
               names_to = "measure", values_to = "amount")

ggplot(plot_data, aes(x = year, y = amount, fill = measure)) +
  geom_col(data = . %>% filter(measure == "budget_impact"), position = "identity") +
  geom_line(data = . %>% filter(measure == "cumulative_bi"),
            aes(y = amount, group = 1), color = "black", linewidth = 1) +
  geom_point(data = . %>% filter(measure == "cumulative_bi"), size = 2) +
  scale_y_continuous(labels = scales::dollar) +
  labs(x = "Year", y = "Budget impact (USD)",
       title = "Annual vs. cumulative budget impact, base case") +
  theme_minimal()
