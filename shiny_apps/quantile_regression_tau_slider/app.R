library(shiny)
library(quantreg)
library(ggplot2)

# Quantile Regression Tau Slider
# Companion to Chapter 16, SS16.4: a tau slider re-fits quantreg::rq() live
# on simulated right-skewed cost/LOS data and redraws the fitted quantile
# line against the scatter -- shows the median and 90th-percentile
# ('costly tail') estimates diverging as severity increases.

set.seed(7)
n <- 400
severity <- runif(n, 0, 10)
# Right-skewed cost with heteroscedasticity: variance grows with severity
base_cost <- 500 + 300 * severity
cost <- base_cost + rgamma(n, shape = 2, rate = 2 / (100 + 50 * severity))
df_data <- data.frame(severity = severity, cost = cost)

ui <- fluidPage(
  titlePanel("Quantile Regression Tau Slider"),
  p("Companion app for Chapter 16, \u00a716.4 (Regression Models for HEOR Data). ",
    "A simulated 400-patient cohort's cost grows with illness severity, with ",
    "the spread of cost ALSO growing (heteroscedasticity) -- a realistic ",
    "cost-data pattern. Drag \u03c4 (tau) and watch quantreg::rq() re-fit a ",
    "different quantile of the cost distribution live."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("tau", "Quantile (\u03c4)", 0.1, 0.9, 0.5, step = 0.05),
      helpText("\u03c4 = 0.5 is the median. \u03c4 = 0.9 targets the 90th percentile -- ",
               "the costly tail of high-severity, high-cost patients.")
    ),
    mainPanel(
      plotOutput("qrPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "An OLS (mean) regression line describes the AVERAGE patient at each severity ",
        "level, but says nothing about how much more volatile cost becomes for severe ",
        "patients. Drag \u03c4 from 0.1 to 0.9 and watch the fitted line's SLOPE steepen, not ",
        "just its height shift \u2014 this means the gap between a typical patient's cost and ",
        "a costly-tail patient's cost widens with severity, a pattern a single mean-based ",
        "regression line cannot represent at all, even though it may fit the average well.")
    )
  )
)

server <- function(input, output, session) {

  fit <- reactive({
    rq(cost ~ severity, tau = input$tau, data = df_data)
  })

  output$qrPlot <- renderPlot({
    f <- fit()
    pred_df <- data.frame(severity = seq(0, 10, length.out = 100))
    pred_df$cost <- predict(f, newdata = pred_df)

    # Also overlay median and 90th percentile fits for context
    fit_median <- rq(cost ~ severity, tau = 0.5, data = df_data)
    fit_90 <- rq(cost ~ severity, tau = 0.9, data = df_data)
    ref_df <- data.frame(severity = seq(0, 10, length.out = 100))
    ref_df$median_pred <- predict(fit_median, newdata = ref_df)
    ref_df$p90_pred <- predict(fit_90, newdata = ref_df)

    ggplot() +
      geom_point(data = df_data, aes(x = severity, y = cost), alpha = 0.3, color = "grey50") +
      geom_line(data = ref_df, aes(x = severity, y = median_pred), color = "grey60", linetype = "dotted", linewidth = 0.8) +
      geom_line(data = ref_df, aes(x = severity, y = p90_pred), color = "grey60", linetype = "dotted", linewidth = 0.8) +
      geom_line(data = pred_df, aes(x = severity, y = cost), color = "#2166ac", linewidth = 1.5) +
      labs(x = "Illness severity score", y = "Cost ($)",
           title = sprintf("Quantile regression fit at \u03c4 = %.2f", input$tau),
           subtitle = "Dotted grey lines: median (\u03c4=0.5) and 90th percentile (\u03c4=0.9) for reference") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    f <- fit()
    coefs <- coef(f)
    intercept <- coefs[1]
    slope <- coefs[2]

    fit_median <- rq(cost ~ severity, tau = 0.5, data = df_data)
    fit_90 <- rq(cost ~ severity, tau = 0.9, data = df_data)
    median_slope <- coef(fit_median)[2]
    p90_slope <- coef(fit_90)[2]

    sprintf(paste0("At \u03c4 = %.2f: fitted cost = $%.0f + $%.0f per severity point. For comparison, ",
                   "the median (\u03c4=0.5) slope is $%.0f/point while the 90th-percentile (\u03c4=0.9) slope ",
                   "is $%.0f/point \u2014 %.0f%% steeper. This means a one-point increase in severity ",
                   "raises the TYPICAL patient's cost by a certain amount, but raises the ",
                   "COSTLY-TAIL patient's cost by substantially more."),
            input$tau, intercept, slope, median_slope, p90_slope,
            (p90_slope - median_slope) / median_slope * 100)
  })
}

shinyApp(ui, server)
