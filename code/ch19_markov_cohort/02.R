# Extracted from ch19_markov_cohort.typ, lines 124-151
# Section: == 19.4 Using heemod, hesim and dampack
# Chapter: 19

library(heemod)

tm <- define_transition(
  state_names = c("OnTx", "Resolved"),
  C,    0.85,   # from OnTx: fill-in remainder, then 0.85 to Resolved
  0,    C       # from Resolved: 0 back to OnTx, remainder (1) stays
)

s_ontx <- define_state(cost = 500, utility = 0.65)
s_resolved <- define_state(cost = 50, utility = 0.90)

strat <- define_strategy(
  transition = tm,
  OnTx = s_ontx,
  Resolved = s_resolved
)

res <- run_model(
  strat,
  parameters = define_parameters(),
  init = c(1, 0),
  cycles = 20,
  method = "life-table",
  cost = cost,
  effect = utility
)
