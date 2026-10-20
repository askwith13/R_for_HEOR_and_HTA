# Extracted from ch30_r_packages_pipelines.typ, lines 105-126
# Section: == 30.3 Documentation with `roxygen2` and `pkgdown`
# Chapter: 30

#' Run a cohort Markov model
#'
#' Simulates a cohort through a specified Markov state structure for a
#' given time horizon, returning per-cycle state occupancy and discounted
#' costs and QALYs.
#'
#' @param trans_matrix A square numeric matrix of transition probabilities.
#' @param cycle_length Numeric, length of one model cycle in years.
#' @param n_cycles Integer, number of cycles to simulate.
#' @param discount_rate Numeric, annual discount rate applied to costs
#'   and outcomes (default 0.035).
#'
#' @return A data frame with one row per cycle, giving state occupancy,
#'   discounted costs, and discounted QALYs.
#'
#' @export
run_markov_model <- function(trans_matrix, cycle_length, n_cycles,
                              discount_rate = 0.035) {
  # model logic here
}
