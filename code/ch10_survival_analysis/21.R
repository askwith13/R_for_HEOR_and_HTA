# Extracted from ch10_survival_analysis.typ, lines 592-615
# Section: === Data preparation and fitting with `mstate`
# Chapter: 10

library(mstate)
library(survival)

tmat <- transMat(
  x = list(
    c(2, 4),     # from Treatment success: to Failure, or Death
    c(3, 4),     # from Failure: to Retreatment, or Death
    c(4),        # from Retreatment: to Death
    c()          # Death is absorbing
  ),
  names = c("TxSuccess", "Failure", "Retreat", "Death")
)

msdat <- msprep(
  time  = cbind(tx_success_time, failure_time, retreat_time, death_time),
  status = cbind(tx_success_status, failure_status, retreat_status, death_status),
  data  = tb_cohort,
  trans = tmat
)

cox_trans <- coxph(Surv(Tstart, Tstop, status) ~ strata(trans), data = msdat)
msf <- msfit(cox_trans, trans = tmat)
