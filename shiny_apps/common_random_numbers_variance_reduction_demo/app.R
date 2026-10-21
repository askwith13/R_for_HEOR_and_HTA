library(shiny)
library(ggplot2)

# Common Random Numbers Variance-Reduction Demo
# Companion to Chapter 21, SS21.5: a toggle switches between
# independent-random-draws and common-random-numbers (CRN) simulation of
# the same two-arm comparison; the simulated distribution of the
# incremental QALY difference across repeated runs visibly narrows
# under CRN.

ui <- fluidPage(
  titlePanel("Common Random Numbers Variance-Reduction Demo"),
  p("Companion app for Chapter 21, \u00a721.5 (Monte Carlo Simulation ",
    "Fundamentals). A toy two-arm comparison simulates a QALY outcome for ",
    "each of 200 patients per arm, repeated across many independent ",
    "simulation runs. Each run's incremental QALY (treatment minus ",
    "control) is recorded. Toggle between independent random draws ",
    "(each arm uses its OWN separate random stream) and common random ",
    "numbers (CRN, both arms use the SAME underlying random stream, only ",
    "shifted by the treatment effect) and watch the spread of the ",
    "incremental-QALY distribution across runs."),
  sidebarLayout(
    sidebarPanel(
      radioButtons("method", "Simulation method",
                   choices = c("Independent random draws" = "independent",
                               "Common random numbers (CRN)" = "crn"),
                   selected = "independent"),
      sliderInput("n_runs", "Number of simulation runs", 100, 2000, 500, step = 100),
      sliderInput("treatment_effect", "True treatment effect (QALY gain)", 0, 0.5, 0.1, step = 0.01)
    ),
    mainPanel(
      plotOutput("incQalyPlot", height = "380px"),
      verbatimTextOutput("sdOut"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "With independent random draws, each arm's simulated noise is UNCORRELATED, so the ",
        "variance of their DIFFERENCE is the SUM of both arms' individual variances -- the worst ",
        "case for precision. Common random numbers deliberately correlates the noise between arms ",
        "(using the same underlying random draws, only shifted), so when you take the difference, ",
        "much of that shared noise CANCELS OUT, shrinking the variance of the incremental estimate ",
        "for the same number of simulation runs. CRN is 'free' variance reduction -- it requires no ",
        "extra computation, only a different random-number-generation strategy -- yet many PSA ",
        "implementations never use it.")
    )
  )
)

server <- function(input, output, session) {

  simulate_runs <- reactive({
    n_runs <- input$n_runs
    n_patients <- 200
    treatment_effect <- input$treatment_effect
    method <- input$method

    inc_qaly <- numeric(n_runs)
    for (r in seq_len(n_runs)) {
      if (method == "crn") {
        base_draws <- rnorm(n_patients, mean = 0.7, sd = 0.15) # shared random stream
        idio_noise_c <- rnorm(n_patients, 0, 0.03) # small idiosyncratic noise, not shared
        idio_noise_t <- rnorm(n_patients, 0, 0.03)
        qaly_control <- base_draws + idio_noise_c
        qaly_treatment <- base_draws + treatment_effect + idio_noise_t # same shared noise, shifted
      } else {
        qaly_control <- rnorm(n_patients, mean = 0.7, sd = 0.15)
        qaly_treatment <- rnorm(n_patients, mean = 0.7 + treatment_effect, sd = 0.15) # independent noise
      }
      inc_qaly[r] <- mean(qaly_treatment) - mean(qaly_control)
    }
    inc_qaly
  })

  output$incQalyPlot <- renderPlot({
    inc_qaly <- simulate_runs()
    df <- data.frame(inc_qaly = inc_qaly)
    ggplot(df, aes(x = inc_qaly)) +
      geom_histogram(bins = 40, fill = if (input$method == "crn") "#2166ac" else "#d6604d", alpha = 0.7) +
      geom_vline(xintercept = input$treatment_effect, linetype = "dashed", color = "black") +
      labs(x = "Simulated incremental QALY (across runs)", y = "Count",
           title = sprintf("Distribution of incremental QALY across %d runs (%s)",
                            input$n_runs, if (input$method == "crn") "CRN" else "independent draws")) +
      theme_minimal(base_size = 13)
  })

  output$sdOut <- renderPrint({
    inc_qaly <- simulate_runs()
    cat(sprintf("Method: %s\n", if (input$method == "crn") "Common random numbers" else "Independent random draws"))
    cat(sprintf("SD of incremental QALY across runs: %.5f\n", sd(inc_qaly)))
    cat(sprintf("Mean incremental QALY across runs: %.5f (true value: %.2f)\n", mean(inc_qaly), input$treatment_effect))
  })

  output$interpretation <- renderText({
    inc_qaly <- simulate_runs()
    sd_current <- sd(inc_qaly)
    sprintf(paste0("With %s and %d runs, the simulated incremental QALY has SD = %.5f across runs. ",
                   "Switch the method toggle (keeping runs and effect fixed) to directly compare -- ",
                   "CRN's SD should be MUCH smaller than independent draws' SD, because CRN cancels ",
                   "the shared noise between arms instead of letting it accumulate in the difference."),
            if (input$method == "crn") "common random numbers" else "independent draws",
            input$n_runs, sd_current)
  })
}

shinyApp(ui, server)
