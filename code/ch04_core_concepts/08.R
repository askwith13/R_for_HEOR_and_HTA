# Extracted from ch04_core_concepts.typ, lines 339-361
# Section: == 4.8 Coding a first simple CEA in R
# Chapter: 4

# Step 3: remove simply dominated treatments ----------------------------
# A treatment is simply dominated if some cheaper treatment already
# delivers equal or greater QALYs. We flag and drop these before doing
# any incremental arithmetic at all.
remove_simple_dominance <- function(df) {
  df <- df |> arrange(cost)
  keep <- logical(nrow(df))
  best_qaly_so_far <- -Inf
  for (i in seq_len(nrow(df))) {
    if (df$qaly[i] > best_qaly_so_far) {
      keep[i] <- TRUE
      best_qaly_so_far <- df$qaly[i]
    } else {
      keep[i] <- FALSE   # cheaper option already matches/beats this QALY
    }
  }
  df |> filter(keep)
}

non_dominated <- remove_simple_dominance(ranked)
non_dominated
