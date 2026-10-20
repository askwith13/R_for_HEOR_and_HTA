# Extracted from ch28_reproducible_reporting.typ, lines 640-646
# Section: === Structuring the dossier as child documents
# Chapter: 28

quarto::quarto_render(
  input = "dossier_parent.qmd",
  execute_params = list(country = "India", perspective = "societal"),
  output_file = "dossier_india_societal.pdf"
)
