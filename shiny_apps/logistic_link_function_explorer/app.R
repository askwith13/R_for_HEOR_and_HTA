library(shiny)
library(ggplot2)

# Link-Function Explorer
# Companion to Chapter 16, SS16.1: sliders for a logistic regression's
# intercept and slope reshape the predicted-probability S-curve live, with
# a toggle between the link (log-odds) and response (probability) scale --
# illustrates why a raw GLM coefficient means nothing on its own until it's
# back-transformed through the inverse-link function.

ui <- fluidPage(
  titlePanel("Logistic Link-Function Explorer"),
  p("Companion app for Chapter 16, \u00a716.1 (Regression Models for HEOR Data). ",
    "A logistic regression's intercept (\u03b20) and slope (\u03b21) for a single ",
    "covariate reshape the predicted-probability curve live. Switch between ",
    "the LINK scale (log-odds, a straight line) and the RESPONSE scale ",
    "(probability, an S-curve) to see what 'linear in the link' really means."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("beta0", "Intercept (\u03b20, log-odds at x=0)", -5, 5, 0, step = 0.1),
      sliderInput("beta1", "Slope (\u03b21, log-odds per unit x)", -3, 3, 0.8, step = 0.05),
      radioButtons("scale", "Display scale",
                   choices = c("Response (probability)" = "response", "Link (log-odds)" = "link"),
                   selected = "response"),
      sliderInput("x_query", "Query point (x)", -10, 10, 0, step = 0.5)
    ),
    mainPanel(
      plotOutput("linkPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A logistic regression slope (\u03b21) is NOT a change in probability per unit x ",
        "\u2014 it is a constant change in LOG-ODDS per unit x. The same \u03b21 value produces ",
        "a steep probability change near p=0.5 but a nearly flat probability change near ",
        "p=0 or p=1. Compare the query point's marginal slope near x=0 (where \u03b20=0 means ",
        "p\u22480.5) against a query point far out in a tail \u2014 the same 1-unit change in x ",
        "produces very different changes in predicted probability depending on where you ",
        "start, even though the underlying log-odds change is identical everywhere.")
    )
  )
)

server <- function(input, output, session) {

  curve_data <- reactive({
    x <- seq(-10, 10, length.out = 200)
    log_odds <- input$beta0 + input$beta1 * x
    prob <- 1 / (1 + exp(-log_odds))
    data.frame(x = x, log_odds = log_odds, prob = prob)
  })

  output$linkPlot <- renderPlot({
    df <- curve_data()
    q_x <- input$x_query
    q_log_odds <- input$beta0 + input$beta1 * q_x
    q_prob <- 1 / (1 + exp(-q_log_odds))

    if (input$scale == "response") {
      ggplot(df, aes(x = x, y = prob)) +
        geom_line(color = "#2166ac", linewidth = 1.2) +
        geom_point(aes(x = q_x, y = q_prob), color = "#d6604d", size = 5) +
        geom_hline(yintercept = c(0, 1), linetype = "dotted", color = "grey60") +
        coord_cartesian(ylim = c(0, 1)) +
        labs(x = "Covariate (x)", y = "Predicted probability",
             title = "Response scale: predicted probability (S-curve)")
    } else {
      ggplot(df, aes(x = x, y = log_odds)) +
        geom_line(color = "#2166ac", linewidth = 1.2) +
        geom_point(aes(x = q_x, y = q_log_odds), color = "#d6604d", size = 5) +
        labs(x = "Covariate (x)", y = "Log-odds",
             title = "Link scale: log-odds (straight line)")
    } +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    q_x <- input$x_query
    q_log_odds <- input$beta0 + input$beta1 * q_x
    q_prob <- 1 / (1 + exp(-q_log_odds))
    # marginal effect on probability scale at this x: beta1 * p * (1-p)
    marginal_effect <- input$beta1 * q_prob * (1 - q_prob)
    sprintf(paste0("At x = %.1f: log-odds = %.2f, predicted probability = %.3f. A one-unit ",
                   "increase in x changes the log-odds by exactly \u03b21 = %.2f everywhere, but ",
                   "changes the PROBABILITY by only about %.3f at this specific point (steepest ",
                   "near p=0.5, flattest near p=0 or p=1) \u2014 the same coefficient, a different ",
                   "real-world effect size depending on where you are on the curve."),
            q_x, q_log_odds, q_prob, input$beta1, marginal_effect)
  })
}

shinyApp(ui, server)
