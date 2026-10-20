# Extracted from ch25_handling_uncertainty.typ, lines 793-803
# Section: === From scenario analysis to model averaging
# Chapter: 25

w_4state <- 0.6
w_3state <- 0.4

nmb_4state <- 8044.05    # book's base case, §25.2-25.3
nmb_3state <- 5357.89    # worked in this section

nmb_averaged <- w_4state * nmb_4state + w_3state * nmb_3state
nmb_averaged
# 0.6 * 8044.05 + 0.4 * 5357.89 = 4826.43 + 2143.16 = 6969.59
