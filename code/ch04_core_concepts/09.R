# Extracted from ch04_core_concepts.typ, lines 365-389
# Section: == 4.8 Coding a first simple CEA in R
# Chapter: 4

# Step 4: check for extended dominance -----------------------------------
# A survivor of simple dominance can still be extendedly dominated if its
# ICER against the next-cheaper option exceeds its ICER against the
# next-more-expensive option (i.e. ICERs are not rising as cost rises).
check_extended_dominance <- function(df) {
  df <- df |>
    arrange(cost) |>
    mutate(
      icer_vs_prev = (cost - lag(cost)) / (qaly - lag(qaly))
    )

  repeat {
    icers <- df$icer_vs_prev
    violation <- which(icers < lag(icers))[1]  # ICER drops vs previous step
    if (is.na(violation) || length(violation) == 0) break
    df <- df |>
      filter(treatment != df$treatment[violation]) |>
      mutate(icer_vs_prev = (cost - lag(cost)) / (qaly - lag(qaly)))
  }
  df
}

frontier <- check_extended_dominance(non_dominated)
