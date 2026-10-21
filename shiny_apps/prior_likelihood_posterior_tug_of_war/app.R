library(shiny)
library(ggplot2)

# Prior-Likelihood-Posterior Tug-of-War
# Companion to Chapter 14, SS14.2: sliders for the Beta prior's alpha/beta
# and a new cohort's observed successes/total redraw prior density,
# likelihood, and the conjugate posterior with its 95% credible interval
# live -- the clearest way to make the prior-vs-data "tug-of-war" concrete.

ui <- fluidPage(
  titlePanel("Prior-Likelihood-Posterior Tug-of-War"),
  p("Companion app for Chapter 14, \u00a714.2 (Bayesian Methods for HEOR). ",
    "A Beta(\u03b1, \u03b2) prior for a probability parameter (e.g. treatment success) ",
    "is updated by newly observed data (s successes out of n). Because the ",
    "Beta distribution is conjugate to the Binomial likelihood, the posterior ",
    "is exactly Beta(\u03b1 + s, \u03b2 + n \u2212 s) \u2014 no MCMC required."),
  sidebarLayout(
    sidebarPanel(
      h4("Prior: Beta(\u03b1, \u03b2)"),
      sliderInput("alpha", "\u03b1 (prior pseudo-successes)", 0.5, 50, 5, step = 0.5),
      sliderInput("beta", "\u03b2 (prior pseudo-failures)", 0.5, 50, 5, step = 0.5),
      hr(),
      h4("New cohort data"),
      sliderInput("n_total", "n (total patients)", 1, 200, 30, step = 1),
      sliderInput("n_success", "s (observed successes)", 0, 200, 24, step = 1),
      helpText("s is automatically capped at n.")
    ),
    mainPanel(
      plotOutput("densityPlot", height = "420px"),
      h4("Posterior summary"),
      verbatimTextOutput("posteriorOut")
    )
  )
)

server <- function(input, output, session) {

  observeEvent(input$n_total, {
    if (input$n_success > input$n_total) {
      updateSliderInput(session, "n_success", value = input$n_total)
    }
  })

  s_capped <- reactive(min(input$n_success, input$n_total))

  post_alpha <- reactive(input$alpha + s_capped())
  post_beta <- reactive(input$beta + input$n_total - s_capped())

  output$densityPlot <- renderPlot({
    p_grid <- seq(0.001, 0.999, length.out = 500)
    prior_d <- dbeta(p_grid, input$alpha, input$beta)

    # Likelihood (binomial), rescaled to a comparable density-like curve for
    # visual overlay (not a true density, but conventional for this kind of plot)
    lik_raw <- dbinom(s_capped(), input$n_total, p_grid)
    lik_scaled <- lik_raw / max(lik_raw) * max(prior_d)

    post_d <- dbeta(p_grid, post_alpha(), post_beta())

    df <- data.frame(
      p = rep(p_grid, 3),
      density = c(prior_d, lik_scaled, post_d),
      curve = rep(c("Prior", "Likelihood (rescaled)", "Posterior"), each = length(p_grid))
    )
    df$curve <- factor(df$curve, levels = c("Prior", "Likelihood (rescaled)", "Posterior"))

    ggplot(df, aes(x = p, y = density, color = curve)) +
      geom_line(linewidth = 1.1) +
      scale_color_manual(values = c("Prior" = "#999999", "Likelihood (rescaled)" = "#d6604d",
                                     "Posterior" = "#2166ac")) +
      labs(x = "Probability (e.g. treatment success rate)", y = "Density",
           color = NULL, title = "Prior vs. likelihood vs. posterior") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$posteriorOut <- renderPrint({
    pa <- post_alpha(); pb <- post_beta()
    ci <- qbeta(c(0.025, 0.975), pa, pb)
    cat(sprintf("Prior:     Beta(%.1f, %.1f), mean = %.3f\n",
                input$alpha, input$beta, input$alpha / (input$alpha + input$beta)))
    cat(sprintf("Data:      %d successes out of %d (observed rate = %.3f)\n",
                s_capped(), input$n_total, s_capped() / input$n_total))
    cat(sprintf("Posterior: Beta(%.1f, %.1f), mean = %.3f\n", pa, pb, pa / (pa + pb)))
    cat(sprintf("95%% credible interval: %.3f to %.3f\n", ci[1], ci[2]))
  })
}

shinyApp(ui, server)
