# Extracted from ch25_handling_uncertainty.typ, lines 728-759
# Section: === Two structures for the same decision problem
# Chapter: 25

# ---- Structure A: the book's running 4-state model (recap, §25.2-25.3) ----
# States, in order: OnTx, Cured, Fail, Death
build_trans_4state <- function(cure, fail, cost_ontx) {
  p_fail_death  <- 0.15
  p_fail_ontx   <- 0.60
  p_cured_death <- 0.01
  matrix(c(
    1 - cure - fail - 0.02, cure,               fail,                          0.02,
    0,                       1 - p_cured_death,  0,                             p_cured_death,
    p_fail_ontx,             0,                  1 - p_fail_ontx - p_fail_death, p_fail_death,
    0,                       0,                  0,                             1
  ), nrow = 4, byrow = TRUE)
}

# ---- Structure B: collapsed 3-state model ----
# States, in order: OnTx, Cured, Death
# "Fail" is removed as a distinct state: a cycle's worth of failure risk
# routes straight into an increased chance of death from On Treatment,
# and the Fail-state cost ($4,000/cycle) and utility (0.40) are never
# accrued separately in this structure.
build_trans_3state <- function(cure, fail, cost_ontx) {
  p_fail_death <- 0.15     # death risk conditional on failing, applied directly
  p_cured_death <- 0.01
  death_from_fail <- fail * p_fail_death
  matrix(c(
    1 - cure - death_from_fail, cure,               death_from_fail,
    0,                           1 - p_cured_death,  p_cured_death,
    0,                           0,                  1
  ), nrow = 3, byrow = TRUE)
}
