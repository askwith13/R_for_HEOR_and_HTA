# Extracted from ch21_microsimulation.typ, lines 103-112
# Section: == 21.3 Efficient implementation: vectorisation, data.table, parallel computing
# Chapter: 21

library(data.table)
dt <- as.data.table(patients)

# Update by reference: no full-table copy
dt[, cumulative_cost := cumulative_cost + cycle_cost]

# Fast grouped summary, e.g. mean cost by final state
dt[, .(mean_cost = mean(cumulative_cost)), by = final_state]
