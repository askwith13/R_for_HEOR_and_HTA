library(shiny)
library(ggplot2)
library(dplyr)

# Covariate Re-Centering Explorer
# Companion to Chapter 12, SS12.6: a slider moves the covariate value at
# which a regression-adjusted network estimate is evaluated, sliding
# continuously between "network-mean" and "target-population" estimates
# -- a real linear meta-regression fit, re-evaluated at each requested
# covariate value.

ui <- fluidPage(
  titlePanel("Covariate Re-Centering Explorer"),
  p("Companion app for Chapter 12, \u00a712.6 (Indirect and Mixed Treatment ",
    "Comparisons). A simulated network meta-regression relates a ",
    "treatment effect (log hazard ratio) to a single effect-modifying ",
    "covariate (baseline disease severity). The regression is naturally ",
    "centred on the network's own mean covariate value. Drag the slider ",
    "to re-evaluate the regression-adjusted treatment effect at a ",
    "DIFFERENT covariate value -- e.g. your own, sicker, target ",
    "population -- and watch the estimate (and its CI) shift away from ",
    "the network-mean estimate."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("target_severity", "Target population's mean baseline severity (0-10 scale)",
                  0, 10, 5, step = 0.1),
      helpText("The network's own mean severity is marked with a dashed ",
               "vertical line on the plot. The network-mean estimate is ",
               "a special case of this app at that exact value.")
    ),
    mainPanel(
      plotOutput("regressionPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A network-mean-centred regression estimate silently assumes YOUR target population has ",
        "the same average covariate value as the trials in the network -- if your population is ",
        "systematically sicker (or healthier) than the network average, reporting the network-",
        "mean estimate as if it applies to your population understates (or overstates) the true ",
        "effect. Drag the slider away from the network mean and watch both the point estimate ",
        "AND the confidence interval widen -- re-centred estimates are inherently less precise ",
        "the further you extrapolate from where the trial data actually sit.")
    )
  )
)

server <- function(input, output, session) {

  # Simulate a network of trials with varying baseline severity and
  # effect-modified treatment effect (steeper benefit at higher severity)
  network_data <- reactive({
    set.seed(99)
    n_trials <- 15
    severity <- runif(n_trials, 2, 8)
    true_slope <- -0.15
    true_intercept <- -0.3
    log_hr <- true_intercept + true_slope * (severity - mean(severity)) + rnorm(n_trials, 0, 0.1)
    se <- runif(n_trials, 0.08, 0.2)
    data.frame(severity = severity, log_hr = log_hr, se = se)
  })

  fit_model <- reactive({
    df <- network_data()
    lm(log_hr ~ severity, data = df, weights = 1 / se^2)
  })

  output$regressionPlot <- renderPlot({
    df <- network_data()
    fit <- fit_model()
    network_mean <- mean(df$severity)
    target <- input$target_severity

    severity_grid <- seq(0, 10, length.out = 200)
    pred <- predict(fit, newdata = data.frame(severity = severity_grid), se.fit = TRUE)
    pred_df <- data.frame(severity = severity_grid, fit = pred$fit,
                           lower = pred$fit - 1.96 * pred$se.fit,
                           upper = pred$fit + 1.96 * pred$se.fit)

    target_pred <- predict(fit, newdata = data.frame(severity = target), se.fit = TRUE)

    ggplot() +
      geom_ribbon(data = pred_df, aes(x = severity, ymin = lower, ymax = upper), fill = "#2166ac", alpha = 0.15) +
      geom_line(data = pred_df, aes(x = severity, y = fit), color = "#2166ac", linewidth = 1) +
      geom_point(data = df, aes(x = severity, y = log_hr), size = 2, color = "grey40") +
      geom_vline(xintercept = network_mean, linetype = "dashed", color = "grey50") +
      geom_point(aes(x = target, y = target_pred$fit), color = "#d6604d", size = 6) +
      annotate("text", x = network_mean + 0.1, y = max(pred_df$upper), label = "Network mean", hjust = 0, size = 3.5) +
      labs(x = "Baseline disease severity", y = "Regression-adjusted log hazard ratio",
           title = "Network meta-regression: treatment effect vs. covariate value") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    df <- network_data()
    fit <- fit_model()
    network_mean <- mean(df$severity)
    target <- input$target_severity
    target_pred <- predict(fit, newdata = data.frame(severity = target), se.fit = TRUE)
    network_pred <- predict(fit, newdata = data.frame(severity = network_mean), se.fit = TRUE)

    sprintf(paste0("At target severity = %.1f (network mean = %.1f): regression-adjusted log HR = ",
                   "%.3f (95%% CI width %.3f), vs. the network-mean estimate of %.3f (CI width %.3f). ",
                   "%s"),
            target, network_mean, target_pred$fit, 2 * 1.96 * target_pred$se.fit,
            network_pred$fit, 2 * 1.96 * network_pred$se.fit,
            if (abs(target - network_mean) > 2) {
              "This is a substantial extrapolation from the network's own covariate range -- notice how much wider the CI has become."
            } else {
              "This is close to the network's own covariate range, so the CI widening is modest."
            })
  })
}

shinyApp(ui, server)
