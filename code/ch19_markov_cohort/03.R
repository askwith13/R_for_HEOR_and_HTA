# Extracted from ch19_markov_cohort.typ, lines 157-168
# Section: == 19.4 Using heemod, hesim and dampack
# Chapter: 19

# Illustrative sketch only -- architecture, not a complete runnable model
hesim_dat <- hesim_data(
  strategies = data.frame(strategy_id = 1:2),
  patients   = data.frame(patient_id = 1:100),
  states     = data.frame(state_id = 1:3, state_name = c("OnTx", "Cured", "Fail"))
)
tp_params <- define_tparams({
  list(tpmatrix = tpmatrix(...))   # references draws/covariates
})
cohort_model <- create_CohortDtstm(define_model(tparams_def = tp_params), hesim_dat)
