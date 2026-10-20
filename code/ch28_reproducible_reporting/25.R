# Extracted from ch28_reproducible_reporting.typ, lines 672-696
# Section: === Looping parameterised rendering across districts
# Chapter: 28

library(purrr)
library(quarto)

district_params <- tibble::tribble(
  ~district,    ~baseline_notifications, ~output_file,
  "Nashik",      2400,                    "report_nashik.pdf",
  "Nagpur",      3100,                    "report_nagpur.pdf",
  "Thane",       4800,                    "report_thane.pdf",
  "Pune Rural",  2950,                    "report_pune_rural.pdf"
)

# purrr::pwalk() calls a function once per row, passing each column as a
# named argument -- here, into quarto_render()'s params and output_file
pwalk(district_params, function(district, baseline_notifications, output_file) {
  quarto::quarto_render(
    input = "district_tb_report.qmd",
    execute_params = list(
      district = district,
      baseline_notifications = baseline_notifications
    ),
    output_file = output_file
  )
})
