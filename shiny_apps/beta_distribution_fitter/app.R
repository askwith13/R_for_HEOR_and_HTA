library(shiny)
library(ggplot2)

# Beta Distribution Fitter
# Companion to Chapter 17, SS17.4: sliders for a trial's reported mean
# probability and 95% CI width recompute method-of-moments alpha/beta live
# and redraw the Beta density -- shows a tighter CI (bigger trial)
# concentrating the distribution vs. a wide CI (small arm) spreading it.

ui <- fluidPage(
  titlePanel("Beta Distribution Fitter"),
  p("Companion app for Chapter 17, \u00a717.4 (Principles of Decision ",
    "Modelling). A trial reports a probability with a 95% CI (e.g. ",
    "'cure rate 0.80, 95% CI 0.70-0.88'). Method-of-moments matching fits ",
    "a Beta(\u03b1,\u03b2) distribution with that same mean and approximate ",
    "variance, for use as a PSA input distribution. Drag the mean and CI ",
    "width and watch the fitted density reshape."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("mean_p", "Reported mean probability", 0.05, 0.95, 0.8, step = 0.01),
      sliderInput("ci_width", "95% CI width (upper \u2212 lower)", 0.02, 0.6, 0.18, step = 0.01),
      helpText("A narrow CI width implies a larger/more precise trial; a ",
               "wide CI width implies a smaller/less precise trial arm.")
    ),
    mainPanel(
      plotOutput("betaPlot", height = "400px"),
      tableOutput("paramsTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Method-of-moments Beta fitting from a reported mean and CI width is an ",
        "APPROXIMATION, not an exact inversion of the trial's true sampling distribution ",
        "-- it assumes the CI is reasonably symmetric and normal-ish on the probability ",
        "scale, which breaks down badly for probabilities very close to 0 or 1. Drag the ",
        "mean toward 0.05 or 0.95 while keeping a moderate CI width, and check whether the ",
        "implied alpha/beta still look sensible (both should stay comfortably positive and ",
        "not wildly asymmetric) \u2014 extreme probabilities are exactly where this ",
        "approximation is least trustworthy.")
    )
  )
)

server <- function(input, output, session) {

  beta_params <- reactive({
    p <- input$mean_p
    # Approximate SE from a 95% CI width assuming normal approximation:
    # width = 2 * 1.96 * SE => SE = width / 3.92
    se <- input$ci_width / 3.92
    var_p <- se^2

    # Method-of-moments Beta fit: alpha = p*(p*(1-p)/var - 1), beta = alpha*(1-p)/p
    common_term <- p * (1 - p) / var_p - 1
    alpha <- max(p * common_term, 0.01)
    beta_param <- max((1 - p) * common_term, 0.01)

    list(alpha = alpha, beta = beta_param, se = se, var_p = var_p)
  })

  output$betaPlot <- renderPlot({
    bp <- beta_params()
    x <- seq(0, 1, length.out = 500)
    y <- dbeta(x, bp$alpha, bp$beta)
    df <- data.frame(x = x, y = y)

    ggplot(df, aes(x = x, y = y)) +
      geom_line(color = "#2166ac", linewidth = 1.2) +
      geom_vline(xintercept = input$mean_p, linetype = "dashed", color = "#d6604d") +
      labs(x = "Probability", y = "Density",
           title = sprintf("Fitted Beta(%.2f, %.2f) distribution", bp$alpha, bp$beta),
           subtitle = "Dashed line: reported mean") +
      theme_minimal(base_size = 13)
  })

  output$paramsTable <- renderTable({
    bp <- beta_params()
    data.frame(
      Parameter = c("\u03b1 (alpha)", "\u03b2 (beta)", "Implied SE", "Effective sample size (\u03b1+\u03b2)"),
      Value = c(sprintf("%.2f", bp$alpha), sprintf("%.2f", bp$beta),
                sprintf("%.4f", bp$se), sprintf("%.1f", bp$alpha + bp$beta))
    )
  })

  output$interpretation <- renderText({
    bp <- beta_params()
    precision_desc <- if (bp$alpha + bp$beta > 50) {
      "a large, precise trial"
    } else if (bp$alpha + bp$beta > 15) {
      "a moderate-sized trial"
    } else {
      "a small or imprecise trial arm"
    }
    sprintf(paste0("Mean = %.2f, 95%% CI width = %.2f implies alpha = %.2f, beta = %.2f ",
                   "(effective sample size \u03b1+\u03b2 = %.1f). This Beta distribution's shape is ",
                   "consistent with %s \u2014 the narrower the original CI, the larger \u03b1+\u03b2 becomes ",
                   "and the more concentrated (peaked) the fitted density is around the mean."),
            input$mean_p, input$ci_width, bp$alpha, bp$beta, bp$alpha + bp$beta, precision_desc)
  })
}

shinyApp(ui, server)
