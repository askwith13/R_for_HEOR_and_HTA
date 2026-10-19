# Extracted from ch06_slr_support.typ, lines 199-239
# Section: == 6.3 PRISMA flow diagrams in R
# Chapter: 6

library(PRISMA2020)
library(dplyr)

prisma_counts <- data.frame(
  stage = c(
    "database_results", "duplicates_removed",
    "records_screened", "records_excluded",
    "full_text_retrieved", "full_text_excluded",
    "studies_included"
  ),
  n = c(
    nrow(all_refs),                     # 3,418 identified
    nrow(all_refs) - nrow(all_refs_dedup),  # duplicates removed
    nrow(all_refs_dedup),               # screened at title/abstract
    sum(screening_log$reviewer1_ti_ab == "exclude" &
          screening_log$reviewer2_ti_ab == "exclude"),
    42,                                  # sent to full-text review
    19,                                  # excluded at full-text, reasons below
    23                                   # final included studies
  )
)

# PRISMA_data() expects its own template row-name structure (stage
# names in column 1, counts in column "n") -- PRISMA2020_data(data) was
# a typo for the real exported function PRISMA_data(data)
data <- PRISMA_data(prisma_counts)
plot <- PRISMA_flowdiagram(
  data,
  interactive = FALSE,
  previous = FALSE,
  other = FALSE,
  fontsize = 12,
  title_colour = "steelblue"
)

# PRISMA2020 has no PRISMA_save(); save a ggplot/DiagrammeR-style object
# with DiagrammeRsvg + rsvg, the package's own documented export route
svg_code <- DiagrammeRsvg::export_svg(plot)
rsvg::rsvg_svg(charToRaw(svg_code), file = "prisma_flow.svg")
