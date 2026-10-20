# Extracted from ch35_case_studies.typ, lines 807-810
# Section: === Checking covariate balance
# Chapter: 35

bal_tab_match  <- bal.tab(m.out, un = TRUE, stats = "mean.diffs")
bal_tab_weight <- bal.tab(w.out, un = TRUE, stats = "mean.diffs")
