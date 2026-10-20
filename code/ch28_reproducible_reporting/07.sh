# Extracted from ch28_reproducible_reporting.typ, lines 169-173
# Section: === Rendering a single parameterised report
# Chapter: 28

quarto render tb_report.qmd \
  --execute-params params.yml \
  --output tb_report_resistant_subgroup.html
