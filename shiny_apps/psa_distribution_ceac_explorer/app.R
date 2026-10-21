library(shiny)
library(ggplot2)
library(dplyr)

# PSA Distribution & CEAC Explorer
# Companion to Chapter 25, SS25.4-25.5: sliders for the willingness-to-pay
# threshold and the assumed evidence strength behind a Beta-distributed
# failure probability re-run an n=2000 PSA loop live, redrawing the CE
# plane, CEAC, and incremental-NMB histogram together.

run_psa <- function(n_draws, p_fail_mean, p_fail_ess, cost_mean, cost_sd,
                     qaly_mean, qaly_sd) {
  # Beta parameterised by mean and effective sample size (pseudo-count)
  alpha <- p_fail_mean * p_fail_ess
  beta <- (1 - p_fail_mean) * p_fail_ess
  p_fail_draws <- rbeta(n_draws, alpha, beta)

  # Incremental cost: driven partly by the failure-probability draw (more
  # failures -> more retreatment cost) plus independent noise
  inc_cost <- cost_mean + (p_fail_draws - p_fail_mean) * 20000 + rnorm(n_draws, 0, cost_sd)
  inc_qaly <- qaly_mean - (p_fail_draws - p_fail_mean) * 0.5 + rnorm(n_draws, 0, qaly_sd)

  data.frame(inc_cost = inc_cost, inc_qaly = inc_qaly, p_fail = p_fail_draws)
}

ui <- fluidPage(
  titlePanel("PSA Distribution & CEAC Explorer"),
  p("Companion app for Chapter 25, \u00a725.4\u201325.5 (Handling Uncertainty). ",
    "A probabilistic sensitivity analysis (n = 2000 draws) propagates ",
    "uncertainty in a Beta-distributed failure probability through to ",
    "incremental cost and QALYs. Drag the WTP threshold across the CE plane ",
    "and watch the CEAC's reading at that exact threshold move with it."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("wtp", "Willingness-to-pay threshold ($/QALY)",
                  0, 150000, 50000, step = 1000),
      hr(),
      sliderInput("p_fail_mean", "Assumed failure probability (mean)",
                  0.01, 0.5, 0.15, step = 0.01),
      sliderInput("p_fail_ess", "Evidence strength (effective sample size / pseudo-count)",
                  5, 500, 50, step = 5),
      helpText("Higher ESS = a larger underlying trial behind the failure-",
               "probability estimate = a tighter Beta distribution."),
      actionButton("resim", "Re-run PSA (new random seed)")
    ),
    mainPanel(
      fluidRow(
        column(6, plotOutput("cePlanePlot", height = "350px")),
        column(6, plotOutput("ceacPlot", height = "350px"))
      ),
      plotOutput("nmbHist", height = "300px"),
      verbatimTextOutput("summaryOut"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "P(cost-effective) at a single WTP threshold is NOT the same question as ",
        "\"is the mean NMB positive?\" \u2014 with a skewed PSA cloud, a point estimate's ",
        "NMB can be positive while fewer than half the draws are, or vice versa. ",
        "Check the CEAC panel, not just the summary numbers, before reporting a ",
        "single P(cost-effective) figure in isolation.")
    )
  )
)

server <- function(input, output, session) {

  seed_val <- reactiveVal(2025)
  observeEvent(input$resim, { seed_val(seed_val() + 1) })

  psa_data <- reactive({
    input$resim
    set.seed(seed_val())
    run_psa(2000, input$p_fail_mean, input$p_fail_ess,
            cost_mean = 8000, cost_sd = 1500, qaly_mean = 0.15, qaly_sd = 0.04)
  })

  output$cePlanePlot <- renderPlot({
    df <- psa_data()
    df$nmb_positive <- (input$wtp * df$inc_qaly - df$inc_cost) > 0
    ggplot(df, aes(x = inc_qaly, y = inc_cost, color = nmb_positive)) +
      geom_point(alpha = 0.4, size = 1.2) +
      geom_abline(slope = input$wtp, intercept = 0, linetype = "dashed", color = "black") +
      scale_color_manual(values = c("TRUE" = "#2166ac", "FALSE" = "#d6604d"),
                          labels = c("TRUE" = "Cost-effective", "FALSE" = "Not cost-effective"),
                          name = NULL) +
      labs(x = "Incremental QALYs", y = "Incremental cost",
           title = sprintf("CE plane at WTP = $%s/QALY", format(input$wtp, big.mark = ","))) +
      theme_minimal(base_size = 12) +
      theme(legend.position = "top")
  })

  output$ceacPlot <- renderPlot({
    df <- psa_data()
    wtp_grid <- seq(0, 150000, by = 2000)
    ceac <- sapply(wtp_grid, function(w) mean((w * df$inc_qaly - df$inc_cost) > 0))
    ceac_df <- data.frame(wtp = wtp_grid, prob = ceac)
    current_prob <- mean((input$wtp * df$inc_qaly - df$inc_cost) > 0)

    ggplot(ceac_df, aes(x = wtp, y = prob)) +
      geom_line(color = "#2166ac", linewidth = 1) +
      geom_vline(xintercept = input$wtp, linetype = "dashed", color = "#d6604d") +
      geom_point(data = data.frame(wtp = input$wtp, prob = current_prob),
                 aes(x = wtp, y = prob), color = "#d6604d", size = 3) +
      coord_cartesian(ylim = c(0, 1)) +
      labs(x = "WTP threshold ($/QALY)", y = "P(cost-effective)",
           title = "Cost-effectiveness acceptability curve (CEAC)") +
      theme_minimal(base_size = 12)
  })

  output$nmbHist <- renderPlot({
    df <- psa_data()
    df$nmb <- input$wtp * df$inc_qaly - df$inc_cost
    ggplot(df, aes(x = nmb)) +
      geom_histogram(bins = 40, fill = "#2166ac", alpha = 0.7) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "#d6604d") +
      geom_vline(xintercept = mean(df$nmb), color = "black") +
      labs(x = "Incremental Net Monetary Benefit", y = "Count",
           title = sprintf("Incremental NMB distribution at WTP = $%s",
                            format(input$wtp, big.mark = ","))) +
      theme_minimal(base_size = 12)
  })

  output$summaryOut <- renderPrint({
    df <- psa_data()
    nmb <- input$wtp * df$inc_qaly - df$inc_cost
    cat(sprintf("Mean incremental cost:  %.2f\n", mean(df$inc_cost)))
    cat(sprintf("Mean incremental QALYs: %.4f\n", mean(df$inc_qaly)))
    cat(sprintf("Mean incremental NMB at WTP=$%s: %.2f\n",
                format(input$wtp, big.mark = ","), mean(nmb)))
    cat(sprintf("P(cost-effective) at this WTP: %.1f%%\n", mean(nmb > 0) * 100))
  })

  output$interpretation <- renderText({
    df <- psa_data()
    nmb <- input$wtp * df$inc_qaly - df$inc_cost
    p_ce <- mean(nmb > 0) * 100
    mean_nmb <- mean(nmb)
    agree <- (mean_nmb > 0 && p_ce > 50) || (mean_nmb < 0 && p_ce < 50)
    agreement_txt <- if (agree) {
      "consistent with"
    } else {
      "NOT fully consistent with (a sign of real skew in the PSA cloud)"
    }
    sprintf(paste0("At WTP = $%s/QALY, %.1f%% of the %d PSA draws fall above the dashed ",
                   "WTP line (cost-effective). The mean NMB ($%.0f) is %s that ",
                   "percentage \u2014 when the two disagree, it signals the underlying cost/QALY ",
                   "distribution is meaningfully skewed, not symmetric."),
            format(input$wtp, big.mark = ","), p_ce, nrow(df), mean_nmb, agreement_txt)
  })
}

shinyApp(ui, server)
