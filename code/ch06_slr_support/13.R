# Extracted from ch06_slr_support.typ, lines 509-531
# Section: == 6.6 Text mining and ML-assisted screening
# Chapter: 6

library(quanteda)

corp <- corpus(abstracts, text_field = "abstract", docid_field = "study_id")
dfm_abs <- corp %>%
  tokens(remove_punct = TRUE) %>%
  tokens_remove(stopwords("en")) %>%
  dfm()

# relevance proxy: count of protocol-defined key terms per abstract
key_terms <- c("tuberculosis", "rifapentine", "regimen", "relapse", "treatment")
relevance_score <- dfm_abs %>%
  dfm_select(pattern = key_terms) %>%
  rowSums()

screening_order <- tibble::tibble(
  study_id = docnames(dfm_abs),
  relevance_score = relevance_score
) %>%
  arrange(desc(relevance_score))

screening_order
