# Extracted from ch29_shiny_apps.typ, lines 150-158
# Section: == 29.2 Designing a user interface for non-programmers
# Chapter: 29

accordion(
  accordion_panel(
    "Advanced model settings",
    numericInput("psa_draws", "Number of PSA iterations", 1000),
    numericInput("half_cycle_corr", "Half-cycle correction", 0.5)
  )
)
