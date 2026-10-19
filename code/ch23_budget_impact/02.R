# Extracted from ch23_budget_impact.typ, lines 293-323
# Section: === Uptake and diffusion over the time horizon
# Chapter: 23

library(dplyr)
library(ggplot2)

years <- 1:5
peak_share <- 0.35   # terminal market share captured by the new intervention

# linear ramp-up: equal increments each year up to peak_share by year 5
linear_uptake <- seq(from = peak_share / 5, to = peak_share, length.out = 5)

# logistic (S-shaped) diffusion: slow start, faster middle, levelling off
# k controls steepness, t0 the inflection year
logistic_uptake <- function(t, peak, k = 1.2, t0 = 2.5) {
  peak / (1 + exp(-k * (t - t0)))
}

uptake_curves <- tibble::tibble(
  year = years,
  linear = linear_uptake,
  logistic = logistic_uptake(years, peak = peak_share)
)

uptake_curves |>
  tidyr::pivot_longer(cols = c(linear, logistic),
                       names_to = "curve", values_to = "market_share") |>
  ggplot(aes(x = year, y = market_share, colour = curve)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(x = "Year of horizon", y = "New intervention market share",
       title = "Illustrative uptake curves over a 5-year BIA horizon")
