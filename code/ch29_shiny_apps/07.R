# Extracted from ch29_shiny_apps.typ, lines 257-304
# Section: == 29.4 Linking Shiny to the model engine and PSA outputs
# Chapter: 29

ui <- page_navbar(
  title = "TB model PSA explorer",
  nav_panel("PSA results",
    sidebarLayout(
      sidebarPanel(
        numericInput("n_psa", "Number of PSA iterations", 1000),
        numericInput("wtp", "WTP threshold ($/QALY)", 50000),
        actionButton("run_psa", "Run model", class = "btn-primary")
      ),
      mainPanel(
        plotOutput("ce_plane"),
        plotOutput("ceac_plot")
      )
    )
  )
)

server <- function(input, output, session) {

  psa_results <- eventReactive(input$run_psa, {
    # run_psa() is the pure PSA engine built in Ch. 23-26;
    # it returns a data frame with one row per Monte Carlo draw
    run_psa(n_draws = input$n_psa, wtp = input$wtp)
  })

  output$ce_plane <- renderPlot({
    req(psa_results())
    draws <- psa_results()
    ggplot(draws, aes(x = d_qaly, y = d_cost)) +
      geom_point(alpha = 0.3) +
      geom_hline(yintercept = 0, linetype = "dashed") +
      geom_vline(xintercept = 0, linetype = "dashed") +
      labs(x = "Incremental QALYs", y = "Incremental cost ($)",
           title = "Cost-effectiveness plane")
  })

  output$ceac_plot <- renderPlot({
    req(psa_results())
    ceac_data <- build_ceac(psa_results(), wtp_range = seq(0, 100000, 1000))
    ggplot(ceac_data, aes(x = wtp, y = prob_cost_effective)) +
      geom_line() +
      labs(x = "Willingness-to-pay threshold ($/QALY)",
           y = "Probability cost-effective",
           title = "Cost-effectiveness acceptability curve")
  })
}
