# Extracted from ch25_handling_uncertainty.typ, lines 183-211
# Section: === Worked example: one-way sensitivity analysis on the TB regimen-choice model
# Chapter: 25

owsa_bounds <- list(
  cure_prob   = list(lo = 0.70, hi = 0.90),   # New-regimen cure probability p(OnTx->Cured)
  fail_die    = list(lo = 0.10, hi = 0.20),   # shared p(Fail->Death)
  disc_rate   = list(lo = 0.015, hi = 0.05),  # annual discount rate
  drug_cost   = list(lo = 1200, hi = 2400),   # New-regimen on-treatment cost per cycle
  ontx_util   = list(lo = 0.55, hi = 0.75)    # shared on-treatment utility (both arms)
)

ann_to_cycle <- function(r_annual) (1 + r_annual)^0.5 - 1

owsa_cure_prob <- sapply(owsa_bounds$cure_prob, function(v)
  incremental_nmb(soc_base, modifyList(new_base, list(p_ontx_cured = v, p_ontx_fail = 0.05))))

owsa_fail_die <- sapply(owsa_bounds$fail_die, function(v)
  incremental_nmb(modifyList(soc_base, list(p_fail_die = v)),
                   modifyList(new_base, list(p_fail_die = v))))

owsa_disc_rate <- sapply(owsa_bounds$disc_rate, function(v)
  incremental_nmb(modifyList(soc_base, list(r = ann_to_cycle(v))),
                   modifyList(new_base, list(r = ann_to_cycle(v)))))

owsa_drug_cost <- sapply(owsa_bounds$drug_cost, function(v)
  incremental_nmb(soc_base, modifyList(new_base, list(cost_ontx = v))))

owsa_ontx_util <- sapply(owsa_bounds$ontx_util, function(v)
  incremental_nmb(modifyList(soc_base, list(util_ontx = v)),
                   modifyList(new_base, list(util_ontx = v))))
