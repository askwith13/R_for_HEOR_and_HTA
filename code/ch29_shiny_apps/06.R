# Extracted from ch29_shiny_apps.typ, lines 245-253
# Section: == 29.4 Linking Shiny to the model engine and PSA outputs
# Chapter: 29

# run_markov_model() and compute_icer() are the pure functions from Ch. 17-20
deterministic_results <- reactive({
  run_markov_model(
    discount_rate = input$discount_rate,
    regimen       = input$regimen
  )
})
