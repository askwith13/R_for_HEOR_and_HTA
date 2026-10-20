# Extracted from ch28_reproducible_reporting.typ, lines 489-500
# Section: === Saving at print resolution
# Chapter: 28

ggsave(
  filename = "figures/markov_trace_newregimen.png",
  plot     = last_plot(),
  width    = 16, height = 10, units = "cm",
  dpi      = 300
)

# vector output for a journal that accepts PDF or EPS figures
ggsave("figures/markov_trace_newregimen.pdf",
       width = 16, height = 10, units = "cm")
