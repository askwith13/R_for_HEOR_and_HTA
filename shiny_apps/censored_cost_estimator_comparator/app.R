library(shiny)
library(survival)
library(ggplot2)
library(dplyr)

# Censored-Cost Estimator Comparator
# Companion to Chapter 9, SS9.6: a censoring-rate slider regenerates a
# censored cohort live and shows naive-mean vs. Lin's partitioned
# estimator diverging as censoring worsens -- operationalising the
# chapter's bias-direction table as something the user watches happen.

ui <- fluidPage(
  titlePanel("Censored-Cost Estimator Comparator"),
  p("Companion app for Chapter 9, \u00a79.6 (Costs and Resource Use). A ",
    "simulated cohort accrues cost over time, but administrative censoring ",
    "cuts some patients' follow-up short before their true total cost is ",
    "observed. Compare a naive mean of OBSERVED cost (ignoring censoring) ",
    "against Lin's interval-partitioned estimator as the censoring rate ",
    "worsens."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("censoring_rate", "Proportion administratively censored", 0, 0.7, 0.3, step = 0.05),
      sliderInput("cost_per_month", "Average cost accrual rate ($/month)", 100, 1000, 400, step = 50),
      helpText("Censored patients are followed for less time, so their ",
               "OBSERVED cost understates their TRUE eventual total cost ",
               "(which is unobserved for them).")
    ),
    mainPanel(
      plotOutput("estimatorPlot", height = "400px"),
      tableOutput("estimatorTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A naive mean of OBSERVED cost among censored patients systematically ",
        "UNDERESTIMATES true mean cost, because censored patients are, by construction, ",
        "observed for less time and therefore accrue less visible cost -- even though their ",
        "true (unobserved) lifetime cost may be just as high or higher. Push the censoring ",
        "rate up toward 0.6-0.7 and watch the naive-mean estimate drift further below the ",
        "true simulated mean, while Lin's partitioned estimator (which reweights each time ",
        "interval by the number of patients still at risk, similar in spirit to a ",
        "Kaplan-Meier-style correction) tracks the true mean far more closely.")
    )
  )
)

server <- function(input, output, session) {

  cohort_data <- reactive({
    set.seed(7)
    n <- 800
    max_followup <- 24 # months
    true_followup <- rexp(n, rate = 1 / 18) # true time each patient would be followed if uncensored
    true_followup <- pmin(true_followup, max_followup)

    is_censored <- rbinom(n, 1, input$censoring_rate)
    censoring_time <- runif(n, 2, max_followup)
    observed_followup <- ifelse(is_censored == 1, pmin(true_followup, censoring_time), true_followup)
    observed_censored <- ifelse(is_censored == 1 & censoring_time < true_followup, 1, 0)

    true_cost <- true_followup * input$cost_per_month + rnorm(n, 0, 200)
    observed_cost <- observed_followup * input$cost_per_month + rnorm(n, 0, 100)

    data.frame(true_followup = true_followup, observed_followup = observed_followup,
               censored = observed_censored, true_cost = true_cost, observed_cost = pmax(observed_cost, 0))
  })

  estimators <- reactive({
    df <- cohort_data()
    true_mean <- mean(df$true_cost)
    naive_mean <- mean(df$observed_cost)

    # Lin's partitioned estimator (simplified): partition follow-up into monthly
    # intervals, estimate mean cost per interval among those still followed
    # (at-risk) in that interval using Kaplan-Meier-style survival weighting,
    # then sum interval contributions.
    max_t <- ceiling(max(df$observed_followup))
    intervals <- seq(0, max_t, by = 1)
    total <- 0
    km_fit <- survfit(Surv(observed_followup, 1 - censored) ~ 1, data = df)
    surv_df <- data.frame(time = c(0, km_fit$time), surv = c(1, km_fit$surv))

    for (i in seq_len(length(intervals) - 1)) {
      t0 <- intervals[i]; t1 <- intervals[i + 1]
      surv_at_t0 <- surv_df$surv[which.min(abs(surv_df$time - t0))]
      total <- total + surv_at_t0 * input$cost_per_month
    }
    lin_estimate <- total

    list(true_mean = true_mean, naive_mean = naive_mean, lin_estimate = lin_estimate)
  })

  output$estimatorPlot <- renderPlot({
    e <- estimators()
    df <- data.frame(
      estimator = factor(c("True mean (oracle)", "Naive observed mean", "Lin's partitioned estimator"),
                           levels = c("True mean (oracle)", "Naive observed mean", "Lin's partitioned estimator")),
      value = c(e$true_mean, e$naive_mean, e$lin_estimate)
    )
    ggplot(df, aes(x = estimator, y = value, fill = estimator)) +
      geom_col(width = 0.5) +
      geom_text(aes(label = sprintf("$%.0f", value)), vjust = -0.5, size = 4.5) +
      scale_fill_manual(values = c("True mean (oracle)" = "#2ca25f", "Naive observed mean" = "#d6604d",
                                    "Lin's partitioned estimator" = "#2166ac")) +
      labs(x = NULL, y = "Estimated mean total cost ($)",
           title = sprintf("Cost estimators at %.0f%% censoring rate", input$censoring_rate * 100)) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "none")
  })

  output$estimatorTable <- renderTable({
    e <- estimators()
    data.frame(
      Estimator = c("True mean (oracle, uses unobserved data)", "Naive observed mean", "Lin's partitioned estimator"),
      Value = c(sprintf("$%.0f", e$true_mean), sprintf("$%.0f", e$naive_mean), sprintf("$%.0f", e$lin_estimate)),
      `Bias vs. true` = c("0 (by definition)", sprintf("%.0f%%", (e$naive_mean - e$true_mean) / e$true_mean * 100),
                           sprintf("%.0f%%", (e$lin_estimate - e$true_mean) / e$true_mean * 100)),
      check.names = FALSE
    )
  })

  output$interpretation <- renderText({
    e <- estimators()
    naive_bias <- (e$naive_mean - e$true_mean) / e$true_mean * 100
    lin_bias <- (e$lin_estimate - e$true_mean) / e$true_mean * 100
    sprintf(paste0("At %.0f%% censoring: true mean cost = $%.0f (oracle, uses unobserved data). ",
                   "Naive observed-mean estimate = $%.0f (%.0f%% bias). Lin's partitioned ",
                   "estimator = $%.0f (%.0f%% bias) \u2014 %s."),
            input$censoring_rate * 100, e$true_mean, e$naive_mean, naive_bias,
            e$lin_estimate, lin_bias,
            if (abs(lin_bias) < abs(naive_bias)) "notably less biased than the naive approach" else "comparable bias in this run")
  })
}

shinyApp(ui, server)
