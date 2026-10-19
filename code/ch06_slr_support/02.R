# Extracted from ch06_slr_support.typ, lines 65-87
# Section: == 6.1 Search strategy documentation
# Chapter: 6

library(litsearchr)

# naive_results is a data frame with title/abstract/keywords columns
# pulled from an initial scoping search
rakedkeywords <- extract_terms(
  text = paste(naive_results$title, naive_results$abstract),
  method = "fakerake",
  min_freq = 3,
  ngrams = TRUE,
  min_n = 1,
  max_n = 3
)

docs <- paste(naive_results$title, naive_results$abstract)
dfm  <- create_dfm(elements = docs, features = rakedkeywords)
g    <- create_network(search_dfm = dfm, min_studies = 3)

cutoff <- find_cutoff(g, method = "cumulative", percent = 0.80)
reduced_graph <- reduce_graph(g, cutoff_strength = cutoff[1])
search_terms  <- get_keywords(reduced_graph)
search_terms
