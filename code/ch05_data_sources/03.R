# Extracted from ch05_data_sources.typ, lines 155-171
# Section: == 5.3 Published literature as a data source
# Chapter: 5

library(tibble)
library(readr)

# A minimal structured extraction log for literature-derived
# model parameters -- auditable, reproducible, and easy to
# cross-check against a later formal SLR in Chapter 6
param_log <- tribble(
  ~parameter,            ~value, ~source_citation,                 ~source_type,       ~notes,
  "hr_pfs_drugA_vs_soc",   0.62, "Smith et al. 2021, NEJM",         "RCT publication",  "ITT population, 95% CI 0.48-0.80",
  "utility_progressed",   0.68, "Jones et al. 2019, Qual Life Res", "Utility study",    "EQ-5D-3L, UK value set",
  "cost_ae_grade3plus",   1450, "National tariff schedule 2023",   "Admin/tariff",      "2023 GBP, not inflated"
)

write_csv(param_log, "literature_parameter_log.csv")
param_log
