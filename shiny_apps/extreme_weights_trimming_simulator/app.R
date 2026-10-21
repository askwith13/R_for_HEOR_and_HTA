library(shiny)
library(WeightIt)
library(ggplot2)
library(dplyr)

# Extreme Weights & Trimming Simulator
# Companion to Chapter 15, SS15.4: a propensity-score trimming-bounds
# slider over a simulated cohort live-redraws the IPTW weight distribution
# and recomputes the ATE, showing extreme weights dominate before trimming
# and stabilize after.

ui <- fluidPage(
  titlePanel("Extreme Weights & Trimming Simulator"),
  p("Companion app for Chapter 15, \u00a715.4 (Real-World Evidence and ",
    "Causal Inference). A simulated 600-patient observational cohort has ",
    "treatment assignment confounded by a covariate; inverse-probability-",
    "of-treatment weights (IPTW, via `WeightIt::weightit()`) are computed, ",
    "then trimmed at a chosen propensity-score percentile bound. Watch ",
    "the weight distribution and the estimated average treatment effect ",
    "(ATE) stabilize as trimming tightens."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("trim_bound", "Trimming bounds (propensity score percentile)",
                  0, 0.15, 0, step = 0.01),
      helpText("0 = no trimming. 0.15 = trim the most extreme 15% at each ",
               "tail of the propensity-score distribution.")
    ),
    mainPanel(
      plotOutput("weightPlot", height = "400px"),
      tableOutput("ateTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A small number of patients with extreme propensity scores (very unlikely to receive ",
        "the treatment they actually got, or vice versa) can receive enormous IPTW weights, ",
        "letting a handful of unusual patients dominate the entire weighted estimate -- this ",
        "is the same instability problem that MAIC's effective-sample-size collapse ",
        "illustrates (see the companion MAIC app). Trimming removes these extreme-weight ",
        "patients but changes WHICH population the estimate describes (trimming narrows ",
        "inference to patients with a realistic chance of receiving either treatment) -- it ",
        "is a genuine bias-variance trade-off, not a free stabilization.")
    )
  )
)

server <- function(input, output, session) {

  sim_data <- reactive({
    set.seed(11)
    n <- 600
    confounder <- rnorm(n, 0, 1)
    # True propensity depends strongly on the confounder (creates extreme PS values)
    logit_ps <- 0.3 + 2.0 * confounder
    true_ps <- plogis(logit_ps)
    treatment <- rbinom(n, 1, true_ps)
    # True outcome: genuine treatment effect of +2, plus confounder effect
    true_ate <- 2.0
    outcome <- 10 + true_ate * treatment + 3 * confounder + rnorm(n, 0, 2)

    data.frame(confounder = confounder, treatment = treatment, outcome = outcome, true_ps = true_ps)
  })

  weighting_result <- reactive({
    df <- sim_data()
    w_fit <- weightit(treatment ~ confounder, data = df, method = "glm", estimand = "ATE")
    df$weight <- w_fit$weights
    df$ps <- w_fit$ps

    lo <- quantile(df$ps, input$trim_bound)
    hi <- quantile(df$ps, 1 - input$trim_bound)
    df$trimmed <- df$ps < lo | df$ps > hi

    df_use <- df[!df$trimmed, ]
    # Weighted ATE via weighted means
    treated_mean <- weighted.mean(df_use$outcome[df_use$treatment == 1], df_use$weight[df_use$treatment == 1])
    control_mean <- weighted.mean(df_use$outcome[df_use$treatment == 0], df_use$weight[df_use$treatment == 0])
    ate_est <- treated_mean - control_mean

    list(df = df, df_use = df_use, ate_est = ate_est, n_trimmed = sum(df$trimmed),
         max_weight = max(df_use$weight), true_ate = 2.0)
  })

  output$weightPlot <- renderPlot({
    r <- weighting_result()
    ggplot(r$df_use, aes(x = weight)) +
      geom_histogram(bins = 40, fill = "#2166ac") +
      labs(x = "IPTW weight", y = "Number of patients",
           title = sprintf("IPTW weight distribution after trimming (%d of %d patients removed)",
                            r$n_trimmed, nrow(r$df))) +
      theme_minimal(base_size = 13)
  })

  output$ateTable <- renderTable({
    r <- weighting_result()
    data.frame(
      Metric = c("True ATE (oracle)", "Estimated ATE (IPTW)", "Bias", "Max weight (after trimming)",
                 "Patients trimmed"),
      Value = c(sprintf("%.3f", r$true_ate), sprintf("%.3f", r$ate_est),
                sprintf("%.3f", r$ate_est - r$true_ate), sprintf("%.2f", r$max_weight),
                sprintf("%d of %d", r$n_trimmed, nrow(r$df)))
    )
  })

  output$interpretation <- renderText({
    r <- weighting_result()
    bias <- r$ate_est - r$true_ate
    sprintf(paste0("At trimming bound = %.0f%%: %d of %d patients trimmed, maximum remaining ",
                   "weight = %.2f. Estimated ATE = %.3f (true simulated ATE = %.3f, bias = ",
                   "%+.3f). %s"),
            input$trim_bound * 100, r$n_trimmed, nrow(r$df), r$max_weight, r$ate_est, r$true_ate, bias,
            if (input$trim_bound == 0) {
              "With no trimming, a small number of extreme-propensity patients can dominate the weighted estimate."
            } else {
              "Trimming removes the most extreme-propensity patients, stabilizing the weight distribution at the cost of narrowing which population this estimate describes."
            })
  })
}

shinyApp(ui, server)
