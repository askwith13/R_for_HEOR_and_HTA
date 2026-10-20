# Extracted from ch28_reproducible_reporting.typ, lines 450-459
# Section: === Colour-blind-safe palettes
# Chapter: 28

library(viridis)

ggplot(markov_trace, aes(x = cycle, y = proportion, colour = state)) +
  geom_line(linewidth = 0.9) +
  scale_colour_viridis_d(option = "D") +   # discrete scale, "viridis" option
  labs(x = "Cycle (months)", y = "Proportion of cohort",
       colour = "Health state",
       title = "Markov cohort trace: New-regimen arm")
