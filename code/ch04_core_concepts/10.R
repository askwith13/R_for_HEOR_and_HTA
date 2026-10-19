# Extracted from ch04_core_concepts.typ, lines 511-523
# Section: == 4.8 Coding a first simple CEA in R
# Chapter: 4

# Step 5: build the final frontier table of incremental results ---------
results <- frontier |>
  arrange(cost) |>
  mutate(
    incr_cost = cost - lag(cost),
    incr_qaly = qaly - lag(qaly),
    icer      = incr_cost / incr_qaly
  ) |>
  select(treatment, cost, qaly, incr_cost, incr_qaly, icer)

print(results, digits = 2)
