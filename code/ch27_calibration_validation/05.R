# Extracted from ch27_calibration_validation.typ, lines 187-205
# Section: === Extreme-value test
# Chapter: 27

test_that("certain mortality (p = 1) drives survivors to zero after cycle 1", {
  tm_extreme <- tm_soc
  # Force the Well-on-treatment row to transition to Dead with certainty.
  # Column order: Well, Failed, Cured, Dead
  tm_extreme["Well", ] <- c(0, 0, 0, 1)

  result_extreme <- run_tb_markov_matrix(
    transition_matrix = tm_extreme,
    starting_state    = "Well",
    horizon_years      = 5
  )

  # After the very first cycle, zero cohort members remain alive in any
  # non-Dead state, by construction of the forced transition above.
  survivors_after_cycle_1 <- sum(result_extreme$trace[2, c("Well", "Failed", "Cured")])
  expect_equal(survivors_after_cycle_1, 0, tolerance = 1e-10)
})
