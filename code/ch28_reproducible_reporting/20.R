# Extracted from ch28_reproducible_reporting.typ, lines 465-475
# Section: === Colour-blind-safe palettes
# Chapter: 28

library(colorspace)

p <- ggplot(ce_plane, aes(incr_cost, incr_qaly, colour = arm)) +
  geom_point(size = 2) +
  scale_colour_viridis_d()

# quick single-simulation preview of how the plot's colours look
# under a deuteranopia (red-green) colour-vision simulation
simulate_cvd(c("#440154", "#21918c", "#fde725"), deutan(1))
