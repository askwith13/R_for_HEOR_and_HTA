# Extracted from ch28_reproducible_reporting.typ, lines 536-560
# Section: === Building a checklist-tracking table in R
# Chapter: 28

library(tibble)
library(dplyr)

cheers_checklist <- tribble(
  ~item, ~topic,                                  ~report_section,
  1,     "Title identifies economic evaluation",   "Title page",
  2,     "Structured abstract",                     "Abstract",
  6,     "Study population",                        "Methods - Target population",
  9,     "Model-based economic evaluation details", "Methods - Markov model structure",
  13,    "Discount rate",                            "Methods - Discounting",
  15,    "Synthesis of effect estimates",           "Methods - Evidence synthesis (ch. 11)",
  18,    "Characterising heterogeneity",             "Methods - Subgroup analysis",
  20,    "Statistical analysis methods",             "Methods - Regression analysis (ch. 16)",
  23,    "Base-case results",                        "Results - Base-case ICER",
  24,    "Uncertainty characterisation",             "Results - PSA / sensitivity analysis",
  26,    "Statistical analysis results",             "Results - Regression output (ch. 16)",
  28,    "Funding source",                           "Declarations"
)

# flag items not yet mapped to any section -- a living to-do list
cheers_checklist %>%
  filter(report_section == "") %>%
  select(item, topic)
