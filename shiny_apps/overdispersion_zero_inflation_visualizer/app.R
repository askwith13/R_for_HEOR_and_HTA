library(shiny)
library(MASS)
library(pscl)
library(ggplot2)

# Overdispersion & Zero-Inflation Visualizer
# Companion to Chapter 16, SS16.3: sliders for Poisson mean, negative-
# binomial dispersion (theta), and proportion of structural zeros morph a
# simulated count histogram between Poisson/NB/zero-inflated shapes, with
# the residual-deviance/df ratio updating live.

ui <- fluidPage(
  titlePanel("Overdispersion & Zero-Inflation Visualizer"),
  p("Companion app for Chapter 16, \u00a716.3 (Regression Models for HEOR ",
    "Data). A simulated count outcome (e.g. hospitalizations per patient) ",
    "is generated from a chosen process -- Poisson, negative binomial, or ",
    "zero-inflated -- and fit with a Poisson GLM. Watch the residual-",
    "deviance/df ratio inflate as the true process departs further from ",
    "Poisson."),
  sidebarLayout(
    sidebarPanel(
      radioButtons("process", "True data-generating process",
                   choices = c("Poisson (no overdispersion)" = "poisson",
                               "Negative binomial (overdispersed)" = "nb",
                               "Zero-inflated Poisson" = "zip"),
                   selected = "poisson"),
      sliderInput("lambda", "Poisson mean (\u03bb)", 0.5, 8, 3, step = 0.5),
      conditionalPanel(
        condition = "input.process == 'nb'",
        sliderInput("theta", "NB dispersion (\u03b8, smaller = more overdispersed)", 0.3, 10, 1.5, step = 0.1)
      ),
      conditionalPanel(
        condition = "input.process == 'zip'",
        sliderInput("zi_prob", "Proportion of structural zeros", 0, 0.6, 0.3, step = 0.05)
      )
    ),
    mainPanel(
      plotOutput("countPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A plain Poisson GLM assumes variance equals the mean -- real count data (like ",
        "hospitalizations) is almost always overdispersed (variance > mean) or has more ",
        "zeros than Poisson predicts. Switch between the three processes with the SAME ",
        "mean \u03bb and watch the residual-deviance/df ratio climb well above 1 for NB and ",
        "ZIP data even though a Poisson model is still being fit \u2014 a ratio near 1 ",
        "indicates Poisson is adequate, well above 1 signals overdispersion/excess zeros ",
        "that should prompt switching to a negative-binomial or zero-inflated model, NOT ",
        "just reporting a Poisson result with an understated standard error.")
    )
  )
)

server <- function(input, output, session) {

  sim_data <- reactive({
    set.seed(123)
    n <- 500
    if (input$process == "poisson") {
      y <- rpois(n, lambda = input$lambda)
    } else if (input$process == "nb") {
      y <- rnbinom(n, mu = input$lambda, size = input$theta)
    } else {
      is_zero <- rbinom(n, 1, input$zi_prob)
      y <- ifelse(is_zero == 1, 0, rpois(n, lambda = input$lambda))
    }
    data.frame(y = y)
  })

  fit_diagnostics <- reactive({
    df <- sim_data()
    fit <- glm(y ~ 1, data = df, family = poisson())
    disp_ratio <- fit$deviance / fit$df.residual
    list(disp_ratio = disp_ratio, mean_y = mean(df$y), var_y = var(df$y), n_zero = sum(df$y == 0))
  })

  output$countPlot <- renderPlot({
    df <- sim_data()
    ggplot(df, aes(x = y)) +
      geom_bar(fill = "#2166ac") +
      labs(x = "Simulated count (e.g. hospitalizations)", y = "Number of patients",
           title = sprintf("Simulated count distribution: %s", switch(input$process,
                            poisson = "Poisson", nb = "Negative binomial", zip = "Zero-inflated Poisson"))) +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    d <- fit_diagnostics()
    fit_quality <- if (d$disp_ratio < 1.3) {
      "close to 1, suggesting Poisson's equal-mean-variance assumption is reasonably satisfied"
    } else if (d$disp_ratio < 2.5) {
      "noticeably above 1, suggesting mild overdispersion that a Poisson GLM understates"
    } else {
      "well above 1, indicating substantial overdispersion/excess zeros that a Poisson GLM cannot capture"
    }
    sprintf(paste0("Sample mean = %.2f, sample variance = %.2f (ratio = %.2f; Poisson implies this ",
                   "ratio should be \u22481). %d of 500 simulated patients have zero events. Fitting a ",
                   "Poisson GLM to this data gives a residual deviance/df ratio of %.2f, which is %s."),
            d$mean_y, d$var_y, d$var_y / d$mean_y, d$n_zero, d$disp_ratio, fit_quality)
  })
}

shinyApp(ui, server)
