#' Example reusable function: cost-of-illness unit-cost valuation
#'
#' Reusable functions used by more than one analysis script belong
#' here (Chapter 2 SS2.2), loaded via source() or, for larger
#' projects, packaged with devtools::load_all(). This avoids
#' copy-pasted logic drifting out of sync across scripts.
#'
#' @param quantity numeric vector of resource-use quantities
#' @param unit_cost numeric vector of unit costs (same length as quantity)
#' @return numeric vector of total costs
value_resource_use <- function(quantity, unit_cost) {
  quantity * unit_cost
}
