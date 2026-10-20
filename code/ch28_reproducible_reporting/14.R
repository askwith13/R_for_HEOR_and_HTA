# Extracted from ch28_reproducible_reporting.typ, lines 327-337
# Section: === Worked example: an ICER summary table
# Chapter: 28

inc_cost <- -844.14
inc_qaly <- 0.1440
wtp      <- 50000

icer <- inc_cost / inc_qaly          # -844.14 / 0.1440
nmb  <- inc_qaly * wtp - inc_cost    # (0.1440 * 50000) - (-844.14)

icer   # -5862.083...
nmb    # 8044.14
