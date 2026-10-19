# Extracted from ch15_rwe_causal_inference.typ, lines 33-50
# Section: == 15.1 Fit-for-purpose RWD and RWE frameworks
# Chapter: 15

library(dplyr)
library(tibble)

# A minimal fitness-for-purpose checklist as a data frame -- the kind of
# artefact you would attach to an analysis plan or HTA dossier appendix
rwd_fitness_checklist <- tibble::tribble(
  ~domain,         ~question,                                              ~assessment,
  "Relevance",     "Does the population match the decision question?",     "Partial: public-sector only",
  "Relevance",     "Is exposure (regimen) captured with dates?",           "Yes, pharmacy dispense log",
  "Relevance",     "Is the outcome defined per WHO TB definitions?",       "Yes, treatment outcome registry",
  "Reliability",   "Is there a documented data dictionary?",               "Yes, v3.2",
  "Reliability",   "What proportion of key covariates are missing?",       "HIV status 4%, culture 11%",
  "Reliability",   "Is there an audit trail / source verification?",       "Partial: no routine monitoring"
)

print(rwd_fitness_checklist, n = Inf)
