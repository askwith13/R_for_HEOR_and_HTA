# Extracted from ch05_data_sources.typ, lines 243-257
# Section: === Clinical trial and survey formats with `haven`
# Chapter: 5

library(haven)

# SAS transport/dataset file (common for SDTM/ADaM exchange)
adsl <- read_sas("data/adsl.sas7bdat")

# Stata .dta (e.g. a DHS-derived household dataset)
survey_dta <- read_dta("data/hh_survey_2022.dta")

# SPSS .sav
qol_spss <- read_sav("data/qol_followup.sav")

# Inspect preserved labelling
attributes(survey_dta$wealth_quintile)
