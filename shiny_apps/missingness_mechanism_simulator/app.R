library(shiny)
library(ggplot2)
library(dplyr)

# Missingness Mechanism Simulator
# Companion to Chapter 7, SS7.1: pick MCAR/MAR/MNAR and drag a slider
# controlling how strongly missingness depends on the utility value; the
# app regenerates the dataset live and shows a complete-case mean
# diverging from truth under MNAR but not MCAR.

ui <- fluidPage(
  titlePanel("Missingness Mechanism Simulator"),
  p("Companion app for Chapter 7, \u00a77.1 (Missing Data). A simulated ",
    "1000-patient utility dataset (true mean known exactly, since this is ",
    "a simulation) has values deleted according to a chosen mechanism -- ",
    "MCAR, MAR (depends on an observed covariate), or MNAR (depends on ",
    "the UNOBSERVED utility value itself). Watch the complete-case mean ",
    "diverge from the true mean only under MNAR."),
  sidebarLayout(
    sidebarPanel(
      radioButtons("mechanism", "Missingness mechanism",
                   choices = c("MCAR (completely at random)" = "mcar",
                               "MAR (depends on observed age)" = "mar",
                               "MNAR (depends on unobserved utility itself)" = "mnar"),
                   selected = "mcar"),
      sliderInput("missing_strength", "Strength of dependence (for MAR/MNAR)", 0, 3, 1.5, step = 0.1),
      sliderInput("missing_rate_target", "Overall target missingness rate", 0.1, 0.6, 0.3, step = 0.05)
    ),
    mainPanel(
      plotOutput("distPlot", height = "400px"),
      tableOutput("statsTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A complete-case analysis is UNBIASED under MCAR (missingness is pure noise, ",
        "unrelated to anything), approximately unbiased under MAR as long as the ",
        "MAR-driving covariate is properly adjusted for, but systematically BIASED under ",
        "MNAR -- because whether a value is missing depends on the value itself, no amount ",
        "of adjusting for observed covariates can fix it; this is precisely why MNAR is the ",
        "hardest missingness mechanism to handle and often requires explicit sensitivity ",
        "analysis (see the companion Tipping-Point app) rather than a single 'corrected' ",
        "estimate. Switch between mechanisms at the same missingness rate and watch the ",
        "complete-case mean drift only under MNAR.")
    )
  )
)

server <- function(input, output, session) {

  sim_data <- reactive({
    set.seed(321)
    n <- 1000
    true_utility <- rnorm(n, mean = 0.75, sd = 0.15)
    age <- rnorm(n, 55, 12)

    if (input$mechanism == "mcar") {
      missing_prob <- rep(input$missing_rate_target, n)
    } else if (input$mechanism == "mar") {
      # MAR: missingness depends on age (observed), not on utility itself
      age_z <- scale(age)[, 1]
      logit_p <- qlogis(input$missing_rate_target) + input$missing_strength * age_z
      missing_prob <- plogis(logit_p)
    } else {
      # MNAR: missingness depends on the UNOBSERVED utility value itself
      # (lower utility -> more likely missing, a common real scenario)
      utility_z <- scale(true_utility)[, 1]
      logit_p <- qlogis(input$missing_rate_target) - input$missing_strength * utility_z
      missing_prob <- plogis(logit_p)
    }

    is_missing <- rbinom(n, 1, missing_prob)
    observed_utility <- ifelse(is_missing == 1, NA, true_utility)

    data.frame(true_utility = true_utility, age = age, observed_utility = observed_utility,
               is_missing = is_missing)
  })

  output$distPlot <- renderPlot({
    df <- sim_data()
    true_mean <- mean(df$true_utility)
    cc_mean <- mean(df$observed_utility, na.rm = TRUE)

    ggplot(df, aes(x = true_utility, fill = factor(is_missing))) +
      geom_histogram(bins = 40, position = "identity", alpha = 0.6) +
      geom_vline(xintercept = true_mean, color = "black", linetype = "dashed", linewidth = 1) +
      geom_vline(xintercept = cc_mean, color = "#d6604d", linetype = "dashed", linewidth = 1) +
      scale_fill_manual(values = c("0" = "#2166ac", "1" = "grey70"),
                         labels = c("0" = "Observed", "1" = "Missing (true value shown for illustration)"),
                         name = NULL) +
      labs(x = "True utility value", y = "Count",
           title = sprintf("Who goes missing under %s", toupper(input$mechanism)),
           subtitle = "Black dashed: true population mean. Red dashed: complete-case mean.") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$statsTable <- renderTable({
    df <- sim_data()
    data.frame(
      Statistic = c("True mean (oracle)", "Complete-case mean", "Bias", "Actual missingness rate"),
      Value = c(sprintf("%.4f", mean(df$true_utility)),
                sprintf("%.4f", mean(df$observed_utility, na.rm = TRUE)),
                sprintf("%.4f", mean(df$observed_utility, na.rm = TRUE) - mean(df$true_utility)),
                sprintf("%.1f%%", mean(df$is_missing) * 100))
    )
  })

  output$interpretation <- renderText({
    df <- sim_data()
    true_mean <- mean(df$true_utility)
    cc_mean <- mean(df$observed_utility, na.rm = TRUE)
    bias <- cc_mean - true_mean
    bias_pct <- bias / true_mean * 100

    sprintf(paste0("Under %s at %.0f%% target missingness: true mean = %.4f, complete-case ",
                   "mean = %.4f (bias = %.4f, %.1f%%). %s"),
            toupper(input$mechanism), input$missing_rate_target * 100, true_mean, cc_mean, bias, bias_pct,
            if (abs(bias_pct) < 1) {
              "This mechanism's bias is negligible -- complete-case analysis is approximately safe here."
            } else {
              sprintf("This is a meaningful bias purely from WHO goes missing, not from how MUCH is missing.")
            })
  })
}

shinyApp(ui, server)
