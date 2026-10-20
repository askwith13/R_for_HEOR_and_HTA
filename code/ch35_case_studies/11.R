# Extracted from ch35_case_studies.typ, lines 303-310
# Section: === Step (d): the ICER
# Chapter: 35

res_comp <- cost_qaly(part_comp, drug_month = 0)                 # cost 49509.59, qaly 0.8587
res_new  <- cost_qaly(part_new,  drug_month = drug_cost_new)      # cost 123375.89, qaly 1.0886

inc_cost <- res_new$cost - res_comp$cost   # 73866.30
inc_qaly <- res_new$qaly - res_comp$qaly   # 0.2299
icer <- inc_cost / inc_qaly                # 321271.05
