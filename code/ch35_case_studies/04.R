# Extracted from ch35_case_studies.typ, lines 90-109
# Section: === Step (c): attaching costs and utilities
# Chapter: 35

cost_state <- c(CKD3 = 1800, CKD4 = 3200, CKD5_predialysis = 6500,
                 Dialysis = 48000, Dead = 0)
util_state <- c(CKD3 = 0.82, CKD4 = 0.76, CKD5_predialysis = 0.68,
                 Dialysis = 0.60, Dead = 0)
drug_cost_new <- 2600   # annual add-on drug cost, new arm only, while alive

discounted_total <- function(trace, drug_add = 0) {
  disc_c <- 1 / (1 + discount_cost)^(0:horizon)
  disc_q <- 1 / (1 + discount_qaly)^(0:horizon)
  alive  <- 1 - trace[, "Dead"]
  cost_per_cycle <- trace %*% cost_state + drug_add * alive
  qaly_per_cycle <- trace %*% util_state
  list(cost = sum(cost_per_cycle * disc_c),
       qaly = sum(qaly_per_cycle * disc_q))
}

res_soc <- discounted_total(trace_soc, drug_add = 0)
res_new <- discounted_total(trace_new, drug_add = drug_cost_new)
