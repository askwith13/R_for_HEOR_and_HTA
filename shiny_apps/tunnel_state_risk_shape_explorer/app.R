library(shiny)
library(ggplot2)
library(dplyr)

# Tunnel-State Risk Shape Explorer
# Companion to Chapter 19, SS19.6: sliders set failure-risk at each
# tunnel sub-state (cycle 1, 2, 3+); flat vs. front-loaded time-since-
# entry-dependent occupancy traces and final cost/QALY totals plot side
# by side, showing why ignoring state-time biases short-vs-long-course
# comparisons.

ui <- fluidPage(
  titlePanel("Tunnel-State Risk Shape Explorer"),
  p("Companion app for Chapter 19, \u00a719.6 (Markov Cohort Models). A ",
    "'post-treatment' health state has a failure (relapse) risk that may ",
    "depend on how long a patient has been IN that state ('tunnel' ",
    "sub-states: cycle 1 since entry, cycle 2, cycle 3+), not just on ",
    "which state they're in. Compare a FLAT risk model (standard Markov, ",
    "memoryless) against a FRONT-LOADED tunnel model where risk is ",
    "highest right after entry and falls thereafter."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("flat_risk", "Flat model: constant per-cycle failure risk", 0.02, 0.3, 0.1, step = 0.01),
      hr(),
      h4("Tunnel model: risk by time-since-entry"),
      sliderInput("tunnel_risk_1", "Cycle 1 since entry", 0.02, 0.5, 0.25, step = 0.01),
      sliderInput("tunnel_risk_2", "Cycle 2 since entry", 0.02, 0.5, 0.12, step = 0.01),
      sliderInput("tunnel_risk_3plus", "Cycle 3+ since entry", 0.02, 0.5, 0.05, step = 0.01),
      sliderInput("n_cycles", "Total cycles to trace", 5, 20, 12, step = 1)
    ),
    mainPanel(
      plotOutput("tunnelPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A standard (memoryless) Markov model cannot represent risk that depends on how ",
        "long a patient has been in a state -- it can only use ONE fixed risk for 'in this ",
        "state', regardless of whether they just arrived or have been there for years. If ",
        "the TRUE risk is front-loaded (as relapse risk often genuinely is, immediately ",
        "after finishing treatment), fitting a single flat-risk model to match the overall ",
        "average will systematically misrepresent WHEN failures happen, which can bias any ",
        "comparison between a short-course and long-course treatment that puts patients ",
        "into this state at different rates over time -- tunnel states exist specifically to ",
        "fix this.")
    )
  )
)

server <- function(input, output, session) {

  occupancy_data <- reactive({
    n <- input$n_cycles

    # Flat model: constant hazard
    flat_occupancy <- numeric(n + 1)
    flat_occupancy[1] <- 1
    for (i in 2:(n + 1)) {
      flat_occupancy[i] <- flat_occupancy[i - 1] * (1 - input$flat_risk)
    }

    # Tunnel model: risk depends on time-since-entry (cycles since this cohort entered the state)
    tunnel_occupancy <- numeric(n + 1)
    tunnel_occupancy[1] <- 1
    for (i in 2:(n + 1)) {
      cycles_since_entry <- i - 1
      risk <- if (cycles_since_entry == 1) {
        input$tunnel_risk_1
      } else if (cycles_since_entry == 2) {
        input$tunnel_risk_2
      } else {
        input$tunnel_risk_3plus
      }
      tunnel_occupancy[i] <- tunnel_occupancy[i - 1] * (1 - risk)
    }

    data.frame(cycle = 0:n, flat = flat_occupancy, tunnel = tunnel_occupancy)
  })

  output$tunnelPlot <- renderPlot({
    df <- occupancy_data()
    df_long <- data.frame(
      cycle = rep(df$cycle, 2),
      proportion = c(df$flat, df$tunnel),
      model = rep(c("Flat (memoryless)", "Tunnel (time-since-entry-dependent)"), each = nrow(df))
    )
    ggplot(df_long, aes(x = cycle, y = proportion, color = model)) +
      geom_line(linewidth = 1.3) +
      geom_point(size = 2) +
      scale_color_manual(values = c("Flat (memoryless)" = "#d6604d",
                                     "Tunnel (time-since-entry-dependent)" = "#2166ac"), name = NULL) +
      labs(x = "Cycle", y = "Proportion remaining in state",
           title = "Occupancy trace: flat vs. tunnel-state risk models") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$interpretation <- renderText({
    df <- occupancy_data()
    final <- tail(df, 1)
    # Average per-cycle risk implied by flat model, for comparison to average tunnel risk
    n <- input$n_cycles
    avg_tunnel_risk <- (input$tunnel_risk_1 + input$tunnel_risk_2 + input$tunnel_risk_3plus * max(n - 2, 0)) / n

    sprintf(paste0("After %d cycles: flat model leaves %.1f%% of the cohort still in the state, ",
                   "vs. %.1f%% under the tunnel model. The flat model uses a single risk (%.2f) ",
                   "every cycle, while the tunnel model uses %.2f in cycle 1, %.2f in cycle 2, ",
                   "and %.2f from cycle 3 onward -- even if these averaged to the same overall ",
                   "risk, WHEN patients leave the state differs substantially between the two ",
                   "models, which matters for any cost/QALY calculation keyed to time-in-state."),
            n, final$flat * 100, final$tunnel * 100, input$flat_risk,
            input$tunnel_risk_1, input$tunnel_risk_2, input$tunnel_risk_3plus)
  })
}

shinyApp(ui, server)
