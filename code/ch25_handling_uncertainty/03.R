# Extracted from ch25_handling_uncertainty.typ, lines 240-250
# Section: === Worked example: two-way sensitivity analysis
# Chapter: 25

cure_grid <- c(0.70, 0.80, 0.90)
cost_grid <- c(1200, 1800, 2400)

twsa_grid <- outer(cure_grid, cost_grid, function(cure, cost) {
  mapply(function(c, k)
    incremental_nmb(soc_base, modifyList(new_base, list(p_ontx_cured = c, p_ontx_fail = 0.05, cost_ontx = k))),
    cure, cost)
})
dimnames(twsa_grid) <- list(cure = cure_grid, cost = cost_grid)
