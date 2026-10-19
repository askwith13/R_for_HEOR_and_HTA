# Extracted from ch06_slr_support.typ, lines 105-139
# Section: == 6.2 Deduplication and screening workflows
# Chapter: 6

library(synthesisr)
library(dplyr)

# read_refs() handles RIS exports from PubMed, Embase, and Cochrane
pubmed_refs  <- read_refs("pubmed_export.ris")
embase_refs  <- read_refs("embase_export.ris")
cochrane_refs <- read_refs("cochrane_export.ris")

all_refs <- merge_columns(pubmed_refs, embase_refs, cochrane_refs) |>
  as_tibble()

# first pass: exact match on standardized title string
dup_exact <- find_duplicates(
  all_refs$title,
  method = "exact",
  to_lower = TRUE,
  rm_punctuation = TRUE
)

# second pass: fuzzy match on anything exact matching missed
dup_fuzzy <- find_duplicates(
  all_refs$title,
  method = "string_osa",
  to_lower = TRUE,
  rm_punctuation = TRUE,
  threshold = 7
)

all_refs_dedup <- all_refs |>
  mutate(dup_id = dup_fuzzy) |>
  extract_unique_references(dup_id)

nrow(all_refs) - nrow(all_refs_dedup)   # duplicates removed, for the PRISMA count
