# 02_run_model.R
#
# Calls functions from R/ against data from data/, produces results
# in output/ (Chapter 2 SS2.2). Nothing in output/ is a source of
# truth -- it is always regenerable by re-running this script.

source("R/cost_functions.R")

# cleaned <- readr::read_csv("data/trial_extract_clean.csv")
# cleaned$total_cost <- value_resource_use(cleaned$quantity, cleaned$unit_cost)
# readr::write_csv(cleaned, "output/costed_results.csv")
