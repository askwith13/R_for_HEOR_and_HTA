# Extracted from ch15_rwe_causal_inference.typ, lines 168-173
# Section: == 15.3 Confounding and bias, with DAGs (`dagitty`, `ggdag`)
# Chapter: 15

# Visual confirmation of the same adjustment set
ggdag::ggdag_adjustment_set(tb_dag, exposure = "regimen", outcome = "success",
                             text = FALSE, use_labels = "label") +
  ggdag::theme_dag()
