library(shiny)
library(ggplot2)

# Threshold Analysis Breakeven Calculator
# Companion to Chapter 25, SS25.6: sliders for incremental QALY gain and
# the WTP threshold recompute the breakeven total cost live, solving
# backward through the ICER formula for one unknown parameter.

ui <- fluidPage(
  titlePanel("Threshold Analysis Breakeven Calculator"),
  p("Companion app for Chapter 25, \u00a725.6 (Handling Uncertainty). ",
    "Threshold analysis solves the ICER formula BACKWARD for one unknown ",
    "parameter, holding the others fixed, to find the value at which a ",
    "treatment exactly breaks even against a willingness-to-pay (WTP) ",
    "threshold. Drag the incremental QALY gain and WTP threshold sliders ",
    "and watch the breakeven total incremental cost recompute instantly."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("inc_qaly", "Incremental QALY gain (new regimen vs. comparator)", 0.01, 3, 0.5, step = 0.01),
      sliderInput("wtp", "Willingness-to-pay threshold ($/QALY)", 10000, 150000, 50000, step = 1000),
      numericInput("actual_cost", "Your actual expected incremental cost ($, optional, for comparison)", value = 20000, min = 0)
    ),
    mainPanel(
      plotOutput("breakevenPlot", height = "380px"),
      verbatimTextOutput("breakevenOut"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Threshold analysis answers 'what value of this ONE parameter makes the ICER exactly equal ",
        "the threshold' -- it does NOT tell you whether that breakeven value is realistic, or ",
        "whether a DIFFERENT parameter (e.g. the QALY gain, held fixed here) is the one actually ",
        "uncertain in practice. Reporting only 'the price must be below $X' without stating which ",
        "parameter you solved for and which you held fixed can mislead a reader into thinking it's ",
        "a complete answer, when it is really a single what-if slice through a multi-parameter ",
        "uncertainty space.")
    )
  )
)

server <- function(input, output, session) {

  breakeven <- reactive({
    input$wtp * input$inc_qaly
  })

  output$breakevenPlot <- renderPlot({
    qaly_grid <- seq(0.01, 3, length.out = 100)
    breakeven_grid <- input$wtp * qaly_grid
    df <- data.frame(qaly = qaly_grid, cost = breakeven_grid)

    p <- ggplot(df, aes(x = qaly, y = cost)) +
      geom_line(color = "#2166ac", linewidth = 1.2) +
      geom_point(data = data.frame(qaly = input$inc_qaly, cost = breakeven()),
                 aes(x = qaly, y = cost), color = "#d6604d", size = 6) +
      labs(x = "Incremental QALY gain", y = "Breakeven total incremental cost ($)",
           title = sprintf("Breakeven cost line at WTP = $%s/QALY", format(input$wtp, big.mark = ","))) +
      theme_minimal(base_size = 13)

    if (!is.na(input$actual_cost) && input$actual_cost >= 0) {
      p <- p + geom_hline(yintercept = input$actual_cost, linetype = "dashed", color = "grey40") +
        annotate("text", x = 0.05, y = input$actual_cost, label = "Your actual cost", hjust = 0, vjust = -0.5, size = 3.5)
    }
    p
  })

  output$breakevenOut <- renderPrint({
    be <- breakeven()
    cat(sprintf("Incremental QALY gain: %.2f\n", input$inc_qaly))
    cat(sprintf("WTP threshold: $%s/QALY\n", format(input$wtp, big.mark = ",")))
    cat(sprintf("Breakeven total incremental cost: $%s\n", format(round(be), big.mark = ",")))
    if (!is.na(input$actual_cost)) {
      cat(sprintf("Your actual expected cost: $%s\n", format(input$actual_cost, big.mark = ",")))
      cat(if (input$actual_cost <= be) "=> Cost-effective at this threshold (actual cost is below breakeven)\n"
          else "=> NOT cost-effective at this threshold (actual cost exceeds breakeven)\n")
    }
  })

  output$interpretation <- renderText({
    be <- breakeven()
    margin <- if (!is.na(input$actual_cost)) be - input$actual_cost else NA
    sprintf(paste0("At %.2f incremental QALYs and a $%s/QALY threshold, the regimen breaks even at ",
                   "a total incremental cost of $%s. %s"),
            input$inc_qaly, format(input$wtp, big.mark = ","), format(round(be), big.mark = ","),
            if (!is.na(margin)) {
              sprintf("Your stated actual cost of $%s leaves a margin of $%s %s the breakeven point.",
                      format(input$actual_cost, big.mark = ","), format(round(abs(margin)), big.mark = ","),
                      if (margin >= 0) "below" else "above")
            } else "")
  })
}

shinyApp(ui, server)
