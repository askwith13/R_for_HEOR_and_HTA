library(shiny)
library(ggplot2)
library(dplyr)

# Bootstrap Resampling Method Comparator
# Companion to Chapter 25, SS25.8: a toggle between "correct" (row-
# preserving) and "incorrect" (independent-column) bootstrap resampling,
# re-running B=500 replicates live on a simulated trial dataset and
# overlaying both resulting incremental-NMB distributions on one
# histogram -- makes the chapter's pitfall box viscerally obvious.

ui <- fluidPage(
  titlePanel("Bootstrap Resampling Method Comparator"),
  p("Companion app for Chapter 25, \u00a725.8 (Handling Uncertainty). A ",
    "simulated 200-patient trial has correlated cost and QALY outcomes ",
    "per patient (sicker patients cost more AND have fewer QALYs). ",
    "500-replicate bootstrap resampling is run two ways: CORRECTLY ",
    "(resampling whole patient ROWS, preserving the cost-QALY correlation ",
    "within each patient) and INCORRECTLY (resampling cost and QALY ",
    "columns INDEPENDENTLY, destroying that correlation)."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n_boot", "Number of bootstrap replicates (B)", 100, 1000, 500, step = 100),
      sliderInput("correlation", "True cost-QALY correlation (negative = sicker costs more, fewer QALYs)",
                  -0.9, 0, -0.6, step = 0.05),
      actionButton("rerun", "Re-run bootstrap", class = "btn-primary")
    ),
    mainPanel(
      plotOutput("bootstrapPlot", height = "400px"),
      tableOutput("sdTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Resampling cost and QALY columns INDEPENDENTLY destroys the real within-patient ",
        "correlation between them (sicker patients both cost more and have fewer QALYs). With ",
        "this realistic NEGATIVE cost-QALY correlation, breaking it by independent-column ",
        "resampling actually UNDERSTATES uncertainty (the incorrect SD comes out smaller, not ",
        "larger) -- because the correlation itself adds genuine variance to NMB (= WTP\u00d7QALY ",
        "\u2212 cost) that independent resampling erases. This is a more dangerous error than ",
        "simple over-dispersion: an incorrect bootstrap can produce an artificially NARROW, ",
        "falsely reassuring confidence interval. Push the correlation toward 0 and watch the ",
        "gap shrink or even reverse -- the direction and size of the bias depends on the real ",
        "correlation structure in the data, which is exactly why resampling must preserve it.")
    )
  )
)

server <- function(input, output, session) {

  base_cohort <- reactive({
    input$rerun # trigger re-simulation on button click
    set.seed(777 + input$rerun)
    n <- 200
    sigma <- matrix(c(1, input$correlation, input$correlation, 1), nrow = 2)
    draws <- MASS::mvrnorm(n, mu = c(0, 0), Sigma = sigma)
    cost <- 5000 + 2000 * draws[, 1]
    qaly <- 0.7 + 0.1 * draws[, 2]
    data.frame(cost = cost, qaly = qaly)
  })

  bootstrap_result <- reactive({
    df <- base_cohort()
    B <- input$n_boot
    n <- nrow(df)

    nmb_correct <- numeric(B)
    nmb_incorrect <- numeric(B)
    wtp <- 50000

    for (b in seq_len(B)) {
      # Correct: resample whole rows
      idx <- sample(seq_len(n), n, replace = TRUE)
      boot_correct <- df[idx, ]
      nmb_correct[b] <- wtp * mean(boot_correct$qaly) - mean(boot_correct$cost)

      # Incorrect: resample cost and qaly columns independently
      idx_cost <- sample(seq_len(n), n, replace = TRUE)
      idx_qaly <- sample(seq_len(n), n, replace = TRUE)
      nmb_incorrect[b] <- wtp * mean(df$qaly[idx_qaly]) - mean(df$cost[idx_cost])
    }

    list(nmb_correct = nmb_correct, nmb_incorrect = nmb_incorrect)
  })

  output$bootstrapPlot <- renderPlot({
    r <- bootstrap_result()
    df <- data.frame(
      nmb = c(r$nmb_correct, r$nmb_incorrect),
      method = rep(c("Correct (row-preserving)", "Incorrect (independent-column)"),
                    each = length(r$nmb_correct))
    )
    ggplot(df, aes(x = nmb, fill = method)) +
      geom_histogram(bins = 40, position = "identity", alpha = 0.6) +
      scale_fill_manual(values = c("Correct (row-preserving)" = "#2166ac",
                                    "Incorrect (independent-column)" = "#d6604d"), name = NULL) +
      labs(x = "Bootstrap incremental NMB", y = "Count",
           title = "Correct vs. incorrect bootstrap: incremental NMB distribution") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$sdTable <- renderTable({
    r <- bootstrap_result()
    sd_correct <- sd(r$nmb_correct)
    sd_incorrect <- sd(r$nmb_incorrect)
    pct_diff <- (sd_incorrect - sd_correct) / sd_correct * 100
    data.frame(
      Metric = c("SD (correct, row-preserving)", "SD (incorrect, independent-column)", "SD difference"),
      Value = c(sprintf("%.1f", sd_correct), sprintf("%.1f", sd_incorrect), sprintf("%+.1f%%", pct_diff))
    )
  })

  output$interpretation <- renderText({
    r <- bootstrap_result()
    sd_correct <- sd(r$nmb_correct)
    sd_incorrect <- sd(r$nmb_incorrect)
    pct_diff <- (sd_incorrect - sd_correct) / sd_correct * 100
    direction <- if (pct_diff < -2) {
      "UNDERSTATES true uncertainty -- a falsely narrow, overconfident interval"
    } else if (pct_diff > 2) {
      "overstates uncertainty -- an overly wide interval"
    } else {
      "is close to the correct method's spread in this run"
    }
    sprintf(paste0("At true cost-QALY correlation = %.2f, B=%d replicates: correct bootstrap SD = ",
                   "%.1f, incorrect (independent-column) bootstrap SD = %.1f (%+.1f%% vs. correct). ",
                   "With this realistic negative correlation, the incorrect method %s."),
            input$correlation, input$n_boot, sd_correct, sd_incorrect, pct_diff, direction)
  })
}

shinyApp(ui, server)
