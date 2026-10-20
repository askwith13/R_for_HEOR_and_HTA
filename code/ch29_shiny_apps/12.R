# Extracted from ch29_shiny_apps.typ, lines 472-490
# Section: == 29.7 Security, validation and agency expectations for web-based models
# Chapter: 29

output$icer_result <- renderText({
  req(input$wtp, input$discount_rate)

  validate(
    need(input$discount_rate >= 0 && input$discount_rate <= 0.1,
         "Discount rate must be between 0% and 10%."),
    need(input$wtp > 0,
         "Willingness-to-pay threshold must be a positive number."),
    need(input$n_psa >= 100,
         "Please run at least 100 PSA iterations for a stable estimate.")
  )

  icer <- run_markov_model(wtp = input$wtp,
                            discount_rate = input$discount_rate,
                            n_psa = input$n_psa)
  scales::dollar(icer)
})
