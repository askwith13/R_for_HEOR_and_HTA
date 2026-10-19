# Extracted from ch15_rwe_causal_inference.typ, lines 133-164
# Section: == 15.3 Confounding and bias, with DAGs (`dagitty`, `ggdag`)
# Chapter: 15

library(dagitty)
library(ggdag)
library(ggplot2)

# Encode the causal structure with ggdag::dagify(); exposure/outcome
# arguments tell dagitty which nodes play which role
tb_dag <- ggdag::dagify(
  success ~ regimen + hiv + nutrition + site_capacity,
  regimen ~ hiv + site_capacity,
  nutrition ~ regimen,
  site_capacity ~ urban,
  exposure = "regimen",
  outcome  = "success",
  labels = c(
    regimen       = "Regimen",
    success       = "Tx success",
    hiv           = "HIV status",
    nutrition     = "Nutrition (mediator)",
    site_capacity = "Site capacity",
    urban         = "Urban site"
  )
)

# Visualise with ggdag() -- status highlights exposure/outcome nodes
ggdag::ggdag(tb_dag, text = FALSE, use_labels = "label") +
  ggdag::theme_dag()

# Ask dagitty for the minimal sufficient adjustment set directly
adj_sets <- dagitty::adjustmentSets(tb_dag, exposure = "regimen", outcome = "success")
adj_sets
