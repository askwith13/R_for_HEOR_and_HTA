# Extracted from ch05_data_sources.typ, lines 220-235
# Section: === Spreadsheets with `readxl`
# Chapter: 5

library(readxl)

# List sheets before committing to one
excel_sheets("data/registry_extract_2023.xlsx")

registry_raw <- read_excel(
  "data/registry_extract_2023.xlsx",
  sheet = "Enrolment",
  range = "A3:N850",        # skip title rows and a trailing totals row
  col_types = c("text", "text", "date", "numeric", "text",
                "numeric", "numeric", "text", "text", "text",
                "numeric", "text", "text", "numeric"),
  na = c("", "NA", "Not recorded")
)
