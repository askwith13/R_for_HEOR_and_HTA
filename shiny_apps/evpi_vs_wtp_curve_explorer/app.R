library(shiny)
library(ggplot2)

# EVPI-vs-WTP Curve Explorer
# Companion to Chapter 26, SS26.1-26.2: a WTP-threshold slider re-runs
# calculate_evpi() live against a PSA sample, redrawing the EVPI-vs-WTP
# curve and marking where the current slider value sits -- demonstrating
# that EVPI peaks near the WTP at which the CEAC crosses 50%.

set.seed(777)
n_psa <- 2000
# Synthetic PSA sample: incremental cost and QALY draws with some
# correlation and a decision that genuinely flips sign across a plausible
# WTP range, so EVPI is non-trivial (not always ~0).
p_fail_draws <- rbeta(n_psa, 15, 85)
inc_cost <- 8000 + (p_fail_draws - 0.15) * 20000 + rnorm(n_psa, 0, 1500)
inc_qaly <- 0.15 - (p_fail_draws - 0.15) * 0.5 + rnorm(n_psa, 0, 0.04)

calculate_evpi <- function(wtp, inc_cost, inc_qaly) {
  nmb <- wtp * inc_qaly - inc_cost
  # EVPI = E[max(0, NMB)] - max(0, E[NMB])
  mean(pmax(0, nmb)) - max(0, mean(nmb))
}

ui <- fluidPage(
  titlePanel("EVPI-vs-WTP Curve Explorer"),
  p("Companion app for Chapter 26, \u00a726.1\u201326.2 (Value of Information Analysis). ",
    "Uses the same fixed n = 2000 PSA sample across every slider position ",
    "(only the WTP threshold changes) to isolate how the decision's net ",
    "monetary benefit uncertainty, not new randomness, drives EVPI. Drag ",
    "the threshold and watch EVPI rise and fall \u2014 it typically peaks near ",
    "the WTP at which the CEAC crosses 50%."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("wtp", "Willingness-to-pay threshold ($/QALY)",
                  0, 150000, 50000, step = 1000),
      verbatimTextOutput("evpiOut")
    ),
    mainPanel(
      plotOutput("evpiCurvePlot", height = "350px"),
      plotOutput("ceacComparePlot", height = "300px")
    )
  )
)

server <- function(input, output, session) {

  wtp_grid <- seq(0, 150000, by = 2000)

  evpi_curve <- reactive({
    sapply(wtp_grid, function(w) calculate_evpi(w, inc_cost, inc_qaly))
  })

  ceac_curve <- reactive({
    sapply(wtp_grid, function(w) mean((w * inc_qaly - inc_cost) > 0))
  })

  current_evpi <- reactive(calculate_evpi(input$wtp, inc_cost, inc_qaly))

  output$evpiOut <- renderPrint({
    cat(sprintf("EVPI at WTP = $%s/QALY:\n$%.2f per patient\n",
                format(input$wtp, big.mark = ","), current_evpi()))
  })

  output$evpiCurvePlot <- renderPlot({
    df <- data.frame(wtp = wtp_grid, evpi = evpi_curve())
    peak_wtp <- df$wtp[which.max(df$evpi)]

    ggplot(df, aes(x = wtp, y = evpi)) +
      geom_line(color = "#2166ac", linewidth = 1) +
      geom_vline(xintercept = input$wtp, linetype = "dashed", color = "#d6604d") +
      geom_point(data = data.frame(wtp = input$wtp, evpi = current_evpi()),
                 aes(x = wtp, y = evpi), color = "#d6604d", size = 3) +
      geom_vline(xintercept = peak_wtp, linetype = "dotted", color = "grey40") +
      annotate("text", x = peak_wtp, y = max(df$evpi) * 1.05,
               label = sprintf("Peak EVPI near $%s", format(round(peak_wtp, -3), big.mark = ",")),
               size = 3.3, hjust = 0.5, color = "grey30") +
      labs(x = "WTP threshold ($/QALY)", y = "EVPI (per patient)",
           title = "Expected Value of Perfect Information vs. WTP threshold") +
      theme_minimal(base_size = 13)
  })

  output$ceacComparePlot <- renderPlot({
    df <- data.frame(wtp = wtp_grid, ceac = ceac_curve())
    ggplot(df, aes(x = wtp, y = ceac)) +
      geom_line(color = "#2ca25f", linewidth = 1) +
      geom_hline(yintercept = 0.5, linetype = "dotted", color = "grey40") +
      geom_vline(xintercept = input$wtp, linetype = "dashed", color = "#d6604d") +
      coord_cartesian(ylim = c(0, 1)) +
      labs(x = "WTP threshold ($/QALY)", y = "P(cost-effective)",
           title = "CEAC (for comparison): EVPI tends to peak where this crosses 0.5") +
      theme_minimal(base_size = 13)
  })
}

shinyApp(ui, server)
