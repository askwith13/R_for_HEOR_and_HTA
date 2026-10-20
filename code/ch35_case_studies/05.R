# Extracted from ch35_case_studies.typ, lines 115-119
# Section: === Step (d): the ICER
# Chapter: 35

inc_cost <- res_new$cost - res_soc$cost   # 44941.18
inc_qaly <- res_new$qaly - res_soc$qaly   # 1.5589
icer <- inc_cost / inc_qaly               # 28829.00
