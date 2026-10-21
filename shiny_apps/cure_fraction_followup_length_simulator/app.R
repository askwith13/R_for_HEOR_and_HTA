library(shiny)
library(flexsurvcure)
library(flexsurv)
library(ggplot2)
library(survival)

# Cure-Fraction vs. Follow-up-Length Simulator
# Companion to Chapter 10, SS10.4: sliders for true simulated cure
# fraction and trial follow-up duration regenerate a censored cohort and
# refit a mixture cure model live, showing how short/administratively-
# censored follow-up can manufacture a spuriously large cure estimate
# indistinguishable from a genuine plateau.

ui <- fluidPage(
  titlePanel("Cure-Fraction vs. Follow-up-Length Simulator"),
  p("Companion app for Chapter 10, \u00a710.4 (Survival Analysis for ",
    "Economic Evaluation). A simulated 400-patient cohort has a TRUE cure ",
    "fraction (the proportion who never relapse); trial follow-up is ",
    "administratively censored at a chosen duration. A mixture cure model ",
    "(`flexsurvcure::flexsurvcure()`) is fit to the censored data and its ",
    "ESTIMATED cure fraction is compared against the true value."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("true_cure_fraction", "True cure fraction (simulated)", 0.1, 0.6, 0.35, step = 0.05),
      sliderInput("followup_duration", "Trial follow-up duration (months)", 12, 96, 36, step = 6),
      helpText("Relapse among the non-cured follows a Weibull hazard with ",
               "median relapse time ~18 months among those who will relapse.")
    ),
    mainPanel(
      plotOutput("cureePlot", height = "400px"),
      tableOutput("cureTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Short follow-up cannot distinguish between a GENUINE cure plateau and patients who ",
        "simply haven't relapsed YET -- a flattening Kaplan-Meier tail looks identical in ",
        "both cases until enough time has passed for the slow relapsers to show up. Push the ",
        "follow-up duration down to 12-18 months and watch the mixture cure model's estimated ",
        "cure fraction come out HIGHER than the true simulated value -- short administrative ",
        "censoring manufactures an apparent plateau from patients who simply haven't had time ",
        "to relapse, a bias that shrinks (but may not disappear) as follow-up lengthens.")
    )
  )
)

server <- function(input, output, session) {

  sim_data <- reactive({
    set.seed(42)
    n <- 400
    is_cured <- rbinom(n, 1, input$true_cure_fraction)
    # Non-cured patients relapse per a Weibull distribution; cured patients "never" relapse
    # (simulated as a very long time, effectively beyond any realistic horizon)
    relapse_time <- ifelse(is_cured == 1, 10000, rweibull(n, shape = 1.3, scale = 20))

    censor_time <- input$followup_duration
    observed_time <- pmin(relapse_time, censor_time)
    event <- as.integer(relapse_time <= censor_time)

    data.frame(time = observed_time, event = event, true_cured = is_cured)
  })

  cure_fit <- reactive({
    df <- sim_data()
    tryCatch({
      flexsurvcure(Surv(time, event) ~ 1, data = df, dist = "weibull", mixture = TRUE)
    }, error = function(e) NULL)
  })

  output$cureePlot <- renderPlot({
    df <- sim_data()
    fit <- cure_fit()
    req(!is.null(fit))

    km_fit <- survfit(Surv(time, event) ~ 1, data = df)
    km_df <- data.frame(time = km_fit$time, surv = km_fit$surv)

    t_grid <- seq(0.1, max(input$followup_duration * 1.5, 60), length.out = 200)
    pred <- summary(fit, t = t_grid, type = "survival", ci = FALSE)[[1]]

    ggplot() +
      geom_step(data = km_df, aes(x = time, y = surv), color = "grey50", linewidth = 0.8) +
      geom_line(data = pred, aes(x = time, y = est), color = "#2166ac", linewidth = 1.2) +
      geom_hline(yintercept = input$true_cure_fraction, linetype = "dotted", color = "#2ca25f", linewidth = 1) +
      geom_vline(xintercept = input$followup_duration, linetype = "dashed", color = "#d6604d") +
      labs(x = "Time (months)", y = "Relapse-free proportion",
           title = "KM curve, fitted mixture cure model, and true cure fraction",
           subtitle = "Green dotted: TRUE cure fraction. Red dashed: end of trial follow-up.") +
      theme_minimal(base_size = 13)
  })

  output$cureTable <- renderTable({
    df <- sim_data()
    fit <- cure_fit()
    req(!is.null(fit))
    est_cure <- fit$res["theta", "est"]
    true_cure <- input$true_cure_fraction
    data.frame(
      Metric = c("True cure fraction (simulated)", "Estimated cure fraction (mixture cure model)",
                 "Bias", "Actual relapses observed", "Actual censored"),
      Value = c(sprintf("%.3f", true_cure), sprintf("%.3f", est_cure),
                sprintf("%.3f", est_cure - true_cure), sum(df$event), sum(1 - df$event))
    )
  })

  output$interpretation <- renderText({
    fit <- cure_fit()
    req(!is.null(fit))
    est_cure <- fit$res["theta", "est"]
    true_cure <- input$true_cure_fraction
    bias <- est_cure - true_cure
    direction <- if (bias > 0.02) {
      "OVERESTIMATES the true cure fraction -- consistent with short follow-up manufacturing an apparent plateau"
    } else if (bias < -0.02) {
      "underestimates the true cure fraction in this run"
    } else {
      "closely matches the true cure fraction"
    }
    sprintf(paste0("At %d months' follow-up: true cure fraction = %.2f, estimated = %.3f ",
                   "(bias = %+.3f). This estimate %s."),
            input$followup_duration, true_cure, est_cure, bias, direction)
  })
}

shinyApp(ui, server)
