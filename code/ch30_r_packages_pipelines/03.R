# Extracted from ch30_r_packages_pipelines.typ, lines 79-83
# Section: == 30.2 Package structure with `usethis` and `devtools`
# Chapter: 30

usethis::use_r("run_markov_model")   # creates R/run_markov_model.R
usethis::use_testthat()              # sets up tests/testthat/ structure
usethis::use_package("dplyr")        # adds dplyr to DESCRIPTION's Imports
