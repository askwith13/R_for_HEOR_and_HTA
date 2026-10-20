# Extracted from ch25_handling_uncertainty.typ, lines 669-684
# Section: == 25.6 Threshold analysis
# Chapter: 25

cost_comp  <- 955.3441    # discounted total cost, standard regimen (base case, §25.3)
qaly_comp  <- 6.579512    # discounted total QALYs, standard regimen (base case, §25.3)
qaly_gain  <- 0.15        # incremental QALYs of the 4-month regimen vs standard (illustrative)
wtp        <- 50000       # willingness-to-pay threshold, $/QALY

cost_threshold <- cost_comp + wtp * qaly_gain
cost_threshold
# [1] 8455.344

# Verification: plug the threshold cost back into the ICER formula and confirm
# it reproduces exactly the WTP threshold used to derive it
icer_check <- (cost_threshold - cost_comp) / qaly_gain
icer_check
# [1] 50000   -- confirms the algebra: at this cost, the ICER sits exactly on WTP
