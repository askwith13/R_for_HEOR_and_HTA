# Extracted from ch17_decision_modelling.typ, lines 88-113
# Section: == 17.3 Structural assumptions and model diagrams
# Chapter: 17

library(DiagrammeR)

tb_model_diagram <- grViz("
digraph tb_markov_structure {

  graph [layout = dot, rankdir = LR]
  node [shape = box, style = filled, fontname = Helvetica]

  OnTx    [label = 'On Treatment',      fillcolor = lightblue]
  Cured   [label = 'Cured',             fillcolor = lightgreen]
  Fail    [label = 'Treatment Failure', fillcolor = lightsalmon]
  Death   [label = 'Death',             fillcolor = grey85]

  OnTx  -> Cured  [label = 'treatment success']
  OnTx  -> Fail   [label = 'treatment failure']
  Fail  -> OnTx   [label = 're-registration']

  OnTx  -> Death  [label = 'mortality']
  Cured -> Death  [label = 'mortality']
  Fail  -> Death  [label = 'mortality']
}
")

tb_model_diagram
