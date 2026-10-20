# Extracted from ch27_calibration_validation.typ, lines 165-179
# Section: === Unit test: transition matrix row-sums equal 1
# Chapter: 27

library(testthat)

# tm_soc is the 4x4 transition probability matrix for the SoC arm,
# built in Chapter 19 (rows: Well, Failed, Cured, Dead; same column order)
test_that("SoC transition matrix rows sum to 1", {
  row_sums <- rowSums(tm_soc)
  expect_equal(row_sums, rep(1, nrow(tm_soc)), tolerance = 1e-8)
})

test_that("New-regimen transition matrix rows sum to 1", {
  row_sums <- rowSums(tm_new)
  expect_equal(row_sums, rep(1, nrow(tm_new)), tolerance = 1e-8)
})
