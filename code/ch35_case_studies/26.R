# Extracted from ch35_case_studies.typ, lines 842-848
# Section: === Estimating the treatment effect
# Chapter: 35

match_model <- lm(hba1c_change ~ treat, data = matched_dat, weights = weights)
match_est   <- coef(summary(match_model))["treat", ]

w_model <- lm(hba1c_change ~ treat, data = dat, weights = w.out$weights)
w_est   <- coef(summary(w_model))["treat", ]
