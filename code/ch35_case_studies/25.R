# Extracted from ch35_case_studies.typ, lines 834-838
# Section: === Checking covariate balance
# Chapter: 35

love.plot(m.out, binary = "std", thresholds = c(m = .1),
          var.order = "unadjusted",
          title = "Covariate balance before and after matching")
