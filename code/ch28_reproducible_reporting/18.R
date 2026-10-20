# Extracted from ch28_reproducible_reporting.typ, lines 415-434
# Section: === A consistent custom theme
# Chapter: 28

library(ggplot2)

theme_heor <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "grey88", linewidth = 0.3),
      axis.title = element_text(face = "bold"),
      plot.title = element_text(face = "bold", size = rel(1.1)),
      plot.subtitle = element_text(colour = "grey40"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold"),
      strip.background = element_rect(fill = "grey92", colour = NA),
      strip.text = element_text(face = "bold")
    )
}

theme_set(theme_heor())
