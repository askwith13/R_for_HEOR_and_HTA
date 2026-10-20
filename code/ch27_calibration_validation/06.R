# Extracted from ch27_calibration_validation.typ, lines 217-240
# Section: === Replication
# Chapter: 27

# At the top of the master analysis script, before any random draws:
set.seed(20240101)

# ... full PSA and base-case model run as built in Chapters 19 and 25 ...

# Save key outputs for later replication comparison
saveRDS(
  list(
    incr_cost  = incr_cost_base_case,   # expect -844.14
    incr_qaly  = incr_qaly_base_case,   # expect 0.1440
    incr_nmb   = incr_nmb_wtp_50k       # expect 8044
  ),
  file = "replication_reference_outputs.rds"
)

# On a second machine or fresh session, after rerunning the identical script:
reference <- readRDS("replication_reference_outputs.rds")
test_that("replicated run matches reference outputs exactly", {
  expect_equal(incr_cost_base_case, reference$incr_cost, tolerance = 1e-6)
  expect_equal(incr_qaly_base_case, reference$incr_qaly, tolerance = 1e-6)
  expect_equal(incr_nmb_wtp_50k, reference$incr_nmb, tolerance = 1e-6)
})
