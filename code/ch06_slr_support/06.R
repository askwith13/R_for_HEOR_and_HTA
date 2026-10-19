# Extracted from ch06_slr_support.typ, lines 243-250
# Section: == 6.3 PRISMA flow diagrams in R
# Chapter: 6

exclusion_reasons <- tibble::tibble(
  reason = c("Wrong population", "No cost outcome",
             "Conference abstract only", "Duplicate publication"),
  n = c(7, 6, 4, 2)
)
sum(exclusion_reasons$n)   # must equal full_text_excluded above -- reconcile if not
