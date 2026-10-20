# Extracted from ch29_shiny_apps.typ, lines 547-597
# Section: == 29.8 Case study: a transparent, reviewable submission-ready model app
# Chapter: 29

server <- function(input, output, session) {

  psa_results <- eventReactive(input$run_psa, {
    validate(
      need(input$tx_success_prob > 0 && input$tx_success_prob <= 1,
           "Treatment success probability must be between 0 and 1."),
      need(input$relapse_rate >= 0 && input$relapse_rate <= 0.5,
           "Relapse rate must be between 0 and 0.5."),
      need(input$discount_rate >= 0 && input$discount_rate <= 10,
           "Discount rate must be between 0% and 10%."),
      need(input$n_psa >= 100, "Use at least 100 PSA iterations.")
    )

    log_event(session$token, "run_psa",
               sprintf("tx_success=%s; relapse=%s; discount=%s; wtp=%s; n_psa=%s",
                       input$tx_success_prob, input$relapse_rate,
                       input$discount_rate, input$wtp, input$n_psa))

    run_tb_markov_psa(
      tx_success_prob = input$tx_success_prob,
      relapse_rate    = input$relapse_rate,
      discount_rate   = input$discount_rate / 100,
      n_psa           = input$n_psa
    )
  })

  output$ce_plane <- renderPlot(plot_ce_plane(psa_results(), wtp = input$wtp))
  output$ceac     <- renderPlot(plot_ceac(psa_results()))
  output$icer_summary <- renderText(summarise_icer(psa_results()))

  output$download_report <- downloadHandler(
    filename = function() paste0("tb_erg_report_", Sys.Date(), ".docx"),
    content = function(file) {
      log_event(session$token, "download_report", "triggered")
      quarto::quarto_render(
        input = "erg_report.qmd",
        output_file = basename(file),
        execute_params = list(
          tx_success_prob = input$tx_success_prob,
          relapse_rate    = input$relapse_rate,
          discount_rate   = input$discount_rate,
          wtp             = input$wtp,
          n_psa           = input$n_psa
        )
      )
      file.copy(basename(file), file, overwrite = TRUE)
    }
  )
}
