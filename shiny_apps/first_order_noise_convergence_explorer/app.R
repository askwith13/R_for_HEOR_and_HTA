library(shiny)
library(ggplot2)

# First-Order Noise Convergence Explorer
# Companion to Chapter 21, SS21.4: a slider for N (number of simulated
# patients, log scale) re-runs a fixed-parameter microsimulation twice
# with two independent patient cohorts of that size and live-plots the gap
# between the two runs' headline outputs shrinking as N grows -- makes the
# first-order-vs-second-order distinction directly visible.

simulate_cohort <- function(n, seed) {
  set.seed(seed)
  # Fixed, true parameters (shared across both runs -- only sampling noise differs)
  util_mean <- 0.75
  cost_mean <- 4000
  age <- rnorm(n, 60, 10)
  cost <- rgamma(n, shape = 2, scale = cost_mean / 2) + age * 10
  util <- pmin(pmax(rnorm(n, util_mean, 0.1), 0), 1)
  list(mean_cost = mean(cost), mean_util = mean(util))
}

ui <- fluidPage(
  titlePanel("First-Order Noise Convergence Explorer"),
  p("Companion app for Chapter 21, \u00a721.4 (Individual-Level State-",
    "Transition Models). A fixed-parameter microsimulation is run TWICE ",
    "with two independently sampled patient cohorts of size N; as N grows, ",
    "the gap between the two runs' headline outputs (mean cost, mean ",
    "utility) should shrink -- pure first-order (sampling) noise, not a ",
    "real disagreement about the underlying model."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("log_n", "Patients per run (N), log scale", 2, 4.7, 3, step = 0.1),
      verbatimTextOutput("nOut")
    ),
    mainPanel(
      plotOutput("convergencePlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "First-order (sampling) noise from too few simulated patients can look exactly like ",
        "genuine second-order (parameter/structural) uncertainty if N is too small -- both ",
        "produce variation in a model's output, but first-order noise is an artifact of ",
        "under-sampling, not a real feature of the decision problem, and should be reduced by ",
        "simply running more patients, not treated as a finding to report. Drag N from ~100 ",
        "up to ~50,000 and watch the gap between the two runs collapse toward zero -- any gap ",
        "remaining at very high N is more likely to reflect genuine structural choices, not ",
        "simulation noise.")
    )
  )
)

server <- function(input, output, session) {

  n_patients <- reactive({
    round(10^input$log_n)
  })

  output$nOut <- renderPrint({
    cat("N =", n_patients(), "patients per run\n")
  })

  convergence_data <- reactive({
    n <- n_patients()
    run1 <- simulate_cohort(n, seed = 101)
    run2 <- simulate_cohort(n, seed = 202)
    list(run1 = run1, run2 = run2,
         gap_cost = abs(run1$mean_cost - run2$mean_cost),
         gap_util = abs(run1$mean_util - run2$mean_util))
  })

  gap_trajectory <- reactive({
    n_grid <- round(10^seq(2, 4.7, length.out = 20))
    gaps <- sapply(n_grid, function(n) {
      r1 <- simulate_cohort(n, seed = 101)
      r2 <- simulate_cohort(n, seed = 202)
      abs(r1$mean_cost - r2$mean_cost)
    })
    data.frame(n = n_grid, gap = gaps)
  })

  output$convergencePlot <- renderPlot({
    traj <- gap_trajectory()
    current_n <- n_patients()
    current_gap <- convergence_data()$gap_cost

    ggplot(traj, aes(x = n, y = gap)) +
      geom_line(color = "grey60", linewidth = 0.8) +
      geom_point(color = "grey60", size = 2) +
      geom_point(aes(x = current_n, y = current_gap), color = "#d6604d", size = 6) +
      scale_x_log10() +
      labs(x = "N (patients per run, log scale)", y = "Gap between two runs' mean cost ($)",
           title = "First-order noise shrinks as N grows",
           subtitle = "Red point: current slider setting") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    d <- convergence_data()
    n <- n_patients()
    sprintf(paste0("At N = %s patients per run: Run 1 mean cost = $%.0f, Run 2 mean cost = $%.0f ",
                   "(gap = $%.0f, %.1f%% of the mean). Run 1 mean utility = %.4f, Run 2 = %.4f ",
                   "(gap = %.4f). Both runs use the IDENTICAL true parameters -- any gap here is ",
                   "pure sampling noise from only having N patients, not a real disagreement."),
            format(n, big.mark = ","), d$run1$mean_cost, d$run2$mean_cost, d$gap_cost,
            d$gap_cost / mean(c(d$run1$mean_cost, d$run2$mean_cost)) * 100,
            d$run1$mean_util, d$run2$mean_util, d$gap_util)
  })
}

shinyApp(ui, server)
