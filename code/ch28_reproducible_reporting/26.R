# Extracted from ch28_reproducible_reporting.typ, lines 700-713
# Section: === Looping parameterised rendering across districts
# Chapter: 28

# equivalent for-loop version
for (i in seq_len(nrow(district_params))) {
  row <- district_params[i, ]
  quarto::quarto_render(
    input = "district_tb_report.qmd",
    execute_params = list(
      district = row$district,
      baseline_notifications = row$baseline_notifications
    ),
    output_file = row$output_file
  )
}
