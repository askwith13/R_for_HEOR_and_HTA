library(shiny)
library(ggplot2)
library(dplyr)

# Equity-Weighted ICER Explorer
# Companion to Chapter 24, SS24.2: sliders for each subgroup's QALY gain
# and an adjustable equity weight for the most-deprived group re-run a toy
# two-subgroup equity-weighted ICER calculation live, plotting both ICERs
# side by side and on a simplified equity-impact-plane quadrant chart.

ui <- fluidPage(
  titlePanel("Equity-Weighted ICER Explorer"),
  p("Companion app for Chapter 24, \u00a724.2 (Cost-Benefit, Distributional and ",
    "Extended Cost-Effectiveness Analysis). A toy two-subgroup comparison ",
    "(a more-deprived group and a less-deprived group) shows how applying an ",
    "equity weight to the more-deprived group's QALY gain can change the ",
    "overall cost-effectiveness verdict without changing any clinical data."),
  sidebarLayout(
    sidebarPanel(
      h4("Fixed inputs"),
      sliderInput("inc_cost", "Incremental cost (both groups combined)",
                  10000, 200000, 60000, step = 5000),
      hr(),
      h4("Subgroup QALY gains"),
      sliderInput("qaly_deprived", "QALY gain, most-deprived group", 0.5, 5, 2.0, step = 0.1),
      sliderInput("qaly_less_deprived", "QALY gain, least-deprived group", 0.5, 5, 1.0, step = 0.1),
      hr(),
      sliderInput("equity_weight", "Equity weight for most-deprived group's QALYs",
                  1.0, 3.0, 1.5, step = 0.1),
      helpText("A weight of 1.0 = standard unweighted CEA. Weights above 1.0 ",
               "give extra value to QALY gains in the more-deprived group, ",
               "per NICE's own published willingness to consider severity/ ",
               "equity weighting in specific circumstances.")
    ),
    mainPanel(
      plotOutput("equityPlanePlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Equity weighting is a value judgement layered on top of the clinical ",
        "evidence, not a statistical correction. The weighted ICER can look ",
        "more favourable purely because of the chosen weight, with nothing in ",
        "the underlying trial data having changed. Any equity-weighted analysis ",
        "should always be reported alongside the unweighted base case, with the ",
        "weight's source and magnitude explicitly justified \u2014 never presented ",
        "as the only result.")
    )
  )
)

server <- function(input, output, session) {

  results <- reactive({
    total_qaly_unweighted <- input$qaly_deprived + input$qaly_less_deprived
    icer_unweighted <- input$inc_cost / total_qaly_unweighted

    total_qaly_weighted <- input$qaly_deprived * input$equity_weight + input$qaly_less_deprived
    icer_weighted <- input$inc_cost / total_qaly_weighted

    list(icer_unweighted = icer_unweighted, icer_weighted = icer_weighted,
         total_qaly_unweighted = total_qaly_unweighted,
         total_qaly_weighted = total_qaly_weighted)
  })

  output$equityPlanePlot <- renderPlot({
    r <- results()
    df <- data.frame(
      type = factor(c("Unweighted", "Equity-weighted"), levels = c("Unweighted", "Equity-weighted")),
      icer = c(r$icer_unweighted, r$icer_weighted)
    )
    ggplot(df, aes(x = type, y = icer, fill = type)) +
      geom_col(width = 0.5) +
      geom_text(aes(label = sprintf("$%s/QALY", format(round(icer), big.mark = ","))),
                vjust = -0.5, size = 4.5) +
      scale_fill_manual(values = c("Unweighted" = "#999999", "Equity-weighted" = "#2166ac")) +
      labs(x = NULL, y = "ICER ($/QALY)",
           title = "Unweighted vs. equity-weighted ICER") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "none")
  })

  output$interpretation <- renderText({
    r <- results()
    pct_change <- (r$icer_weighted - r$icer_unweighted) / r$icer_unweighted * 100
    sprintf(paste0("Unweighted ICER: $%s/QALY. Equity-weighted ICER (deprived group's QALYs ",
                   "counted %.1f\u00d7): $%s/QALY \u2014 a %.1f%% change, purely from the weighting ",
                   "choice, with no change to the underlying trial data. The more of the ",
                   "total QALY gain sits in the deprived group (currently %.0f%% of the ",
                   "unweighted total), the bigger this effect."),
            format(round(r$icer_unweighted), big.mark = ","), input$equity_weight,
            format(round(r$icer_weighted), big.mark = ","), pct_change,
            input$qaly_deprived / r$total_qaly_unweighted * 100)
  })
}

shinyApp(ui, server)
