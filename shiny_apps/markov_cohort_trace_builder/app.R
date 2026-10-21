library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)

# Markov Cohort Trace Builder
# Companion to Chapter 19, SS19.1 & 19.3: sliders for each outbound
# transition probability (stay-probability auto-computed to sum to 1)
# redraw the 20-cycle state-occupancy trace live, making visible how small
# transition-probability changes compound over many cycles.

state_names <- c("Healthy", "Sick", "Dead")
n_cycles <- 20

build_trace <- function(p_h_to_s, p_h_to_d, p_s_to_d, p_s_to_h) {
  p_h_to_h <- 1 - p_h_to_s - p_h_to_d
  p_s_to_s <- 1 - p_s_to_d - p_s_to_h

  trans_matrix <- matrix(c(
    p_h_to_h, p_h_to_s, p_h_to_d,
    p_s_to_h, p_s_to_s, p_s_to_d,
    0, 0, 1
  ), nrow = 3, byrow = TRUE)

  trace <- matrix(0, nrow = n_cycles + 1, ncol = 3)
  trace[1, ] <- c(1, 0, 0) # start: 100% Healthy

  for (cyc in 2:(n_cycles + 1)) {
    trace[cyc, ] <- trace[cyc - 1, ] %*% trans_matrix
  }

  df <- as.data.frame(trace)
  names(df) <- state_names
  df$cycle <- 0:n_cycles
  list(df = df, matrix = trans_matrix, valid = all(p_h_to_h >= 0, p_s_to_s >= 0))
}

ui <- fluidPage(
  titlePanel("Markov Cohort Trace Builder"),
  p("Companion app for Chapter 19, \u00a719.1 & 19.3 (Markov Cohort Models). ",
    "A 3-state model (Healthy/Sick/Dead) over 20 cycles. Drag each outbound ",
    "transition probability; the stay-in-state probability is auto-computed ",
    "so each row sums to exactly 1, and the cohort-occupancy trace redraws ",
    "live."),
  sidebarLayout(
    sidebarPanel(
      h4("From Healthy"),
      sliderInput("p_h_to_s", "P(Healthy \u2192 Sick)", 0, 0.5, 0.1, step = 0.01),
      sliderInput("p_h_to_d", "P(Healthy \u2192 Dead)", 0, 0.2, 0.02, step = 0.005),
      hr(),
      h4("From Sick"),
      sliderInput("p_s_to_d", "P(Sick \u2192 Dead)", 0, 0.5, 0.1, step = 0.01),
      sliderInput("p_s_to_h", "P(Sick \u2192 Healthy, recovery)", 0, 0.5, 0.15, step = 0.01),
      verbatimTextOutput("matrixOut")
    ),
    mainPanel(
      plotOutput("tracePlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A seemingly small per-cycle transition probability can compound into a large ",
        "cumulative effect over many cycles \u2014 because each cycle's outcome feeds into the ",
        "next cycle's starting distribution, the effect is multiplicative, not additive. ",
        "Try raising P(Healthy\u2192Sick) by just 0.05 and compare the cycle-20 'Dead' ",
        "proportion against the baseline \u2014 the difference is usually far larger than a ",
        "naive 'per-cycle probability times number of cycles' estimate would suggest, ",
        "because more cycles are spent exposed to the Sick state's own higher death risk.")
    )
  )
)

server <- function(input, output, session) {

  trace_result <- reactive({
    build_trace(input$p_h_to_s, input$p_h_to_d, input$p_s_to_d, input$p_s_to_h)
  })

  output$matrixOut <- renderPrint({
    r <- trace_result()
    cat("Transition matrix (rows sum to 1):\n")
    m <- round(r$matrix, 3)
    rownames(m) <- state_names
    colnames(m) <- state_names
    print(m)
  })

  output$tracePlot <- renderPlot({
    r <- trace_result()
    df_long <- pivot_longer(r$df, cols = all_of(state_names), names_to = "state", values_to = "proportion")
    df_long$state <- factor(df_long$state, levels = state_names)

    ggplot(df_long, aes(x = cycle, y = proportion, fill = state)) +
      geom_area(alpha = 0.8) +
      scale_fill_manual(values = c("Healthy" = "#2ca25f", "Sick" = "#fdae61", "Dead" = "#555555")) +
      labs(x = "Cycle", y = "Proportion of cohort", fill = NULL,
           title = "Cohort state-occupancy trace over 20 cycles") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$interpretation <- renderText({
    r <- trace_result()
    final <- r$df[nrow(r$df), ]
    sprintf(paste0("After 20 cycles: %.1f%% Healthy, %.1f%% Sick, %.1f%% Dead. Starting from ",
                   "100%% Healthy, these per-cycle probabilities (P(Healthy\u2192Sick)=%.2f, ",
                   "P(Healthy\u2192Dead)=%.3f, P(Sick\u2192Dead)=%.2f, P(Sick\u2192Healthy)=%.2f) compound ",
                   "cycle over cycle to produce this cumulative distribution \u2014 a direct ",
                   "multiplication of the transition matrix 20 times, not a simple sum."),
            final$Healthy * 100, final$Sick * 100, final$Dead * 100,
            input$p_h_to_s, input$p_h_to_d, input$p_s_to_d, input$p_s_to_h)
  })
}

shinyApp(ui, server)
