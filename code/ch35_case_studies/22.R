# Extracted from ch35_case_studies.typ, lines 778-781
# Section: === Simulating an observational dataset with confounding
# Chapter: 35

naive_diff <- mean(dat$hba1c_change[dat$treat == 1]) -
                mean(dat$hba1c_change[dat$treat == 0])
