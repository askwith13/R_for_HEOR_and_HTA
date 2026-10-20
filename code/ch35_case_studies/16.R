# Extracted from ch35_case_studies.typ, lines 539-549
# Section: === 35.3.4 Running the base case
# Chapter: 35

res_screen   <- run_arm(N, frailty, screening = TRUE)
res_noscreen <- run_arm(N, frailty, screening = FALSE)

mean_cost_screen   <- mean(res_screen$cost);   mean_qaly_screen   <- mean(res_screen$qaly)
mean_cost_noscreen <- mean(res_noscreen$cost); mean_qaly_noscreen <- mean(res_noscreen$qaly)

inc_cost <- mean_cost_screen - mean_cost_noscreen
inc_qaly <- mean_qaly_screen - mean_qaly_noscreen
icer     <- inc_cost / inc_qaly
