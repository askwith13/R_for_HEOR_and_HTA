# Extracted from ch05_data_sources.typ, lines 387-398
# Section: === Practical R approaches
# Chapter: 5

library(tibble)

codebook <- tribble(
  ~variable,              ~label,                              ~type,       ~values,                              ~missing_codes,
  "patient_id",           "Unique patient identifier",          "character", NA,                                   NA,
  "txn_outcome",          "TB treatment outcome at 12 months",  "integer",   "1=Cured; 2=Completed; 3=Failed; 4=Died; 5=LTFU", "-99=Not applicable; -98=Unknown",
  "cost_per_episode_usd", "Total treatment cost, 2023 USD",     "double",    NA,                                   "-99=Not costed"
)

write_csv(codebook, "data/codebooks/tb_outcomes_codebook.csv")
