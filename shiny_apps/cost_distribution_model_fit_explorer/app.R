library(shiny)
library(ggplot2)
library(dplyr)

# Cost Distribution & Model-Fit Explorer
# Companion to Chapter 9, SS9.3-9.4: sliders for zero-inflation
# probability, gamma shape/scale, and outlier probability/scale regenerate
# a simulated cost dataset live, updating the histogram and mean/median
# gap, overlaying OLS vs. gamma-GLM predicted means to show exactly
# when/how badly naive OLS misbehaves.

ui <- fluidPage(
  titlePanel("Cost Distribution & Model-Fit Explorer"),
  p("Companion app for Chapter 9, \u00a79.3\u20139.4 (Costs and Resource Use). A ",
    "simulated healthcare cost dataset -- zero-inflated, right-skewed ",
    "(gamma), with occasional extreme outliers -- is regenerated live. ",
    "Compare a naive OLS mean against a gamma-GLM fitted mean to see when ",
    "OLS starts to misbehave."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("zero_prob", "Proportion with zero cost", 0, 0.5, 0.15, step = 0.05),
      sliderInput("gamma_shape", "Gamma shape (higher = less skewed)", 0.5, 5, 1.2, step = 0.1),
      sliderInput("gamma_scale", "Gamma scale ($)", 500, 5000, 1500, step = 100),
      sliderInput("outlier_prob", "Proportion that are extreme outliers", 0, 0.1, 0.02, step = 0.005),
      sliderInput("outlier_mult", "Outlier cost multiplier", 5, 50, 15, step = 1)
    ),
    mainPanel(
      plotOutput("costHistPlot", height = "400px"),
      tableOutput("statsTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Healthcare cost data is almost always right-skewed with a long tail of expensive ",
        "patients, and a sample MEAN is extremely sensitive to even a small proportion of ",
        "extreme outliers -- the sample mean can shift substantially from increasing just ",
        "the outlier proportion by a point or two, while the MEDIAN barely moves. Push the ",
        "outlier proportion and multiplier up and watch the mean/median gap widen. In this ",
        "simplified intercept-only demo, OLS and gamma-GLM converge to a similar fitted ",
        "mean -- their real divergence only appears once covariates are added to the model, ",
        "where OLS on raw costs lets outlier-heavy subgroups distort coefficient estimates ",
        "while gamma-GLM's log-link structurally accommodates the skew throughout.")
    )
  )
)

server <- function(input, output, session) {

  cost_data <- reactive({
    set.seed(42)
    n <- 1000
    is_zero <- rbinom(n, 1, input$zero_prob)
    is_outlier <- rbinom(n, 1, input$outlier_prob)
    base_cost <- rgamma(n, shape = input$gamma_shape, scale = input$gamma_scale)
    cost <- ifelse(is_zero == 1, 0,
                    ifelse(is_outlier == 1, base_cost * input$outlier_mult, base_cost))
    data.frame(cost = cost)
  })

  fit_stats <- reactive({
    df <- cost_data()
    mean_cost <- mean(df$cost)
    median_cost <- median(df$cost)

    # OLS mean (trivially = sample mean for intercept-only model)
    ols_fit <- lm(cost ~ 1, data = df)
    ols_mean <- coef(ols_fit)[1]

    # Gamma GLM (add small constant to zeros since gamma requires positive values)
    df$cost_adj <- ifelse(df$cost == 0, 0.01, df$cost)
    gamma_fit <- tryCatch(
      glm(cost_adj ~ 1, data = df, family = Gamma(link = "log")),
      error = function(e) NULL
    )
    gamma_mean <- if (!is.null(gamma_fit)) exp(coef(gamma_fit)[1]) else NA

    list(mean_cost = mean_cost, median_cost = median_cost, ols_mean = ols_mean, gamma_mean = gamma_mean)
  })

  output$costHistPlot <- renderPlot({
    df <- cost_data()
    s <- fit_stats()
    ggplot(df, aes(x = cost)) +
      geom_histogram(bins = 50, fill = "#2166ac", alpha = 0.7) +
      geom_vline(xintercept = s$mean_cost, color = "#d6604d", linetype = "dashed", linewidth = 1) +
      geom_vline(xintercept = s$median_cost, color = "#2ca25f", linetype = "dashed", linewidth = 1) +
      labs(x = "Simulated healthcare cost ($)", y = "Number of patients",
           title = "Simulated cost distribution",
           subtitle = "Red dashed: mean. Green dashed: median.") +
      theme_minimal(base_size = 13)
  })

  output$statsTable <- renderTable({
    s <- fit_stats()
    data.frame(
      Statistic = c("Sample mean", "Sample median", "OLS fitted mean", "Gamma-GLM fitted mean"),
      Value = c(sprintf("$%.0f", s$mean_cost), sprintf("$%.0f", s$median_cost),
                sprintf("$%.0f", s$ols_mean), sprintf("$%.0f", s$gamma_mean))
    )
  })

  output$interpretation <- renderText({
    s <- fit_stats()
    gap <- s$mean_cost - s$median_cost
    gap_pct <- gap / s$median_cost * 100
    sprintf(paste0("Sample mean ($%.0f) exceeds the median ($%.0f) by $%.0f (%.0f%%) \u2014 a direct ",
                   "sign of right-skew driven by the outlier tail. For this simple intercept-",
                   "only comparison, OLS's and the gamma-GLM's fitted means both converge to ",
                   "roughly the sample mean ($%.0f) \u2014 the real divergence between the two ",
                   "methods shows up once covariates are added, where OLS on raw costs is ",
                   "pulled disproportionately by outlier-heavy subgroups while gamma-GLM's ",
                   "log-link structurally accommodates the skew."),
            s$mean_cost, s$median_cost, gap, gap_pct, s$gamma_mean)
  })
}

shinyApp(ui, server)
