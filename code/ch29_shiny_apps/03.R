# Extracted from ch29_shiny_apps.typ, lines 137-144
# Section: == 29.2 Designing a user interface for non-programmers
# Chapter: 29

tooltip(
  sliderInput("wtp", "Willingness-to-pay threshold", 20000, 100000, 50000),
  "The maximum amount a payer is willing to spend to gain one additional
   quality-adjusted life year (QALY). NICE typically references
   £20,000-£30,000 per QALY; other agencies use different thresholds."
)
