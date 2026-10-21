library(shiny)
library(ggplot2)

# Discounting & Half-Cycle Correction Comparator
# Companion to Chapter 19, SS19.5: a discount-rate slider and a
# beginning/end/half-cycle-corrected toggle recompute total discounted
# QALYs/costs live from a fixed cycle stream, turning the trapezoidal-
# averaging explanation into a visible before/after comparison.

ui <- fluidPage(
  titlePanel("Discounting & Half-Cycle Correction Comparator"),
  p("Companion app for Chapter 19, \u00a719.5 (Markov Cohort Models). A ",
    "fixed 10-cycle state-occupancy stream (annual cycles) is valued ",
    "three ways: assuming state occupancy is counted at the BEGINNING of ",
    "each cycle, at the END of each cycle, or with the standard ",
    "half-cycle correction (the trapezoidal average of beginning and ",
    "end). Compare the resulting discounted QALY totals live."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("discount_rate", "Annual discount rate", 0, 0.08, 0.035, step = 0.005),
      sliderInput("decay_rate", "Per-cycle survival decay rate (illustrative cohort)", 0.02, 0.2, 0.08, step = 0.01),
      radioButtons("correction", "Valuation convention",
                   choices = c("Beginning-of-cycle" = "beginning",
                               "End-of-cycle" = "end",
                               "Half-cycle corrected (trapezoidal)" = "half_cycle"),
                   selected = "half_cycle")
    ),
    mainPanel(
      plotOutput("discountPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Beginning-of-cycle valuation systematically OVER-estimates total QALYs (assumes ",
        "everyone who will eventually transition out of a state was there for the FULL ",
        "cycle), while end-of-cycle valuation systematically UNDER-estimates it (assumes ",
        "no one was there until the very end) -- the half-cycle correction splits the ",
        "difference via trapezoidal averaging, which is why it's the standard convention. ",
        "The gap between beginning- and end-of-cycle totals is largest precisely when the ",
        "cohort is declining fastest (high decay rate) -- push the decay rate up and watch ",
        "the three methods' totals spread further apart.")
    )
  )
)

server <- function(input, output, session) {

  trace_data <- reactive({
    n_cycles <- 10
    occupancy <- exp(-input$decay_rate * (0:n_cycles)) # proportion still in the health state
    data.frame(cycle = 0:n_cycles, occupancy = occupancy)
  })

  discounted_totals <- reactive({
    df <- trace_data()
    r <- input$discount_rate
    n_cycles <- max(df$cycle)

    # Beginning-of-cycle: value cycle i's occupancy at the START (cycle i itself)
    beginning_total <- sum(df$occupancy[1:n_cycles] / (1 + r)^(0:(n_cycles - 1)))

    # End-of-cycle: value cycle i's occupancy at the END (cycle i+1)
    end_total <- sum(df$occupancy[2:(n_cycles + 1)] / (1 + r)^(1:n_cycles))

    # Half-cycle corrected: trapezoidal average of beginning and end for each cycle
    half_cycle_total <- sum(
      (df$occupancy[1:n_cycles] + df$occupancy[2:(n_cycles + 1)]) / 2 / (1 + r)^((0:(n_cycles - 1)) + 0.5)
    )

    list(beginning = beginning_total, end = end_total, half_cycle = half_cycle_total)
  })

  output$discountPlot <- renderPlot({
    d <- discounted_totals()
    df <- data.frame(
      method = factor(c("Beginning-of-cycle", "End-of-cycle", "Half-cycle corrected"),
                        levels = c("Beginning-of-cycle", "Half-cycle corrected", "End-of-cycle")),
      total = c(d$beginning, d$end, d$half_cycle)
    )
    df <- df[match(c("Beginning-of-cycle", "Half-cycle corrected", "End-of-cycle"), df$method), ]

    ggplot(df, aes(x = method, y = total, fill = method)) +
      geom_col(width = 0.5) +
      geom_text(aes(label = sprintf("%.3f", total)), vjust = -0.5, size = 5) +
      scale_fill_manual(values = c("Beginning-of-cycle" = "#d6604d",
                                    "Half-cycle corrected" = "#2166ac",
                                    "End-of-cycle" = "#2ca25f")) +
      labs(x = NULL, y = "Discounted total (cycle-weighted life-years in this state)",
           title = "Discounted totals under three valuation conventions") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "none")
  })

  output$interpretation <- renderText({
    d <- discounted_totals()
    gap <- d$beginning - d$end
    gap_pct <- gap / d$half_cycle * 100
    current_val <- switch(input$correction, beginning = d$beginning, end = d$end, half_cycle = d$half_cycle)
    sprintf(paste0("Beginning-of-cycle total = %.4f, end-of-cycle total = %.4f, half-cycle ",
                   "corrected total = %.4f. The gap between beginning and end (%.4f, %.1f%% of ",
                   "the corrected total) reflects pure valuation-timing choice, not a real ",
                   "difference in the underlying cohort trace -- it grows with the decay rate ",
                   "because faster-declining cohorts spend less time in the state than ",
                   "beginning-of-cycle assumes, and more than end-of-cycle assumes."),
            d$beginning, d$end, d$half_cycle, gap, gap_pct)
  })
}

shinyApp(ui, server)
