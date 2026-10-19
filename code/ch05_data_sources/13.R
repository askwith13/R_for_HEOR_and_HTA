# Extracted from ch05_data_sources.typ, lines 451-468
# Section: === Practical R approaches
# Chapter: 5

library(labelled)

# Attach value labels directly to a vector, SAS/SPSS style
txn_outcome <- labelled(
  c(1, 2, 3, 1, 4, 5),
  labels = c(Cured = 1, Completed = 2, Failed = 3, Died = 4, "Lost to follow-up" = 5)
)

var_label(txn_outcome) <- "TB treatment outcome at 12 months"

# Generate a human-readable summary straight from the labelled vector
look_for(txn_outcome)        # one-line variable summary with label and value range
val_labels(txn_outcome)      # the full code -> label mapping

# Convert to factor for modelling, keeping only the chosen labels as levels
txn_outcome_factor <- to_factor(txn_outcome)
