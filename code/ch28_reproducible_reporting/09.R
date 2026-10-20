# Extracted from ch28_reproducible_reporting.typ, lines 189-212
# Section: === Looping render calls to generate one report per scenario
# Chapter: 28

library(quarto)

scenarios <- data.frame(
  scenario_name = c("Base case", "Drug-resistant subgroup", "High drug price (+35%)"),
  wtp_threshold = c(50000, 50000, 50000),
  drug_price_multiplier = c(1.00, 1.00, 1.35)
)

for (i in seq_len(nrow(scenarios))) {
  scn <- scenarios[i, ]
  safe_name <- gsub("[^A-Za-z0-9]+", "_", scn$scenario_name)

  quarto_render(
    input = "tb_report.qmd",
    output_file = paste0("tb_report_", safe_name, ".html"),
    execute_params = list(
      scenario_name = scn$scenario_name,
      wtp_threshold = scn$wtp_threshold,
      drug_price_multiplier = scn$drug_price_multiplier
    )
  )
}
