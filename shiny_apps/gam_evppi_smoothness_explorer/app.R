library(shiny)
library(mgcv)
library(ggplot2)

# GAM EVPPI Smoothness Explorer
# Companion to Chapter 26, SS26.3: a slider for mgcv::gam()'s k= basis
# dimension re-fits a GAM regression of incremental NMB on a single PSA
# parameter live, redrawing both the fitted smooth against the raw PSA
# scatter and the resulting EVPPI, showing under-fit vs. over-fit
# consequences.

ui <- fluidPage(
  titlePanel("GAM EVPPI Smoothness Explorer"),
  p("Companion app for Chapter 26, \u00a726.3 (Value of Information ",
    "Analysis). A simulated PSA (2,000 iterations) has incremental NMB ",
    "related to one parameter, `p_ontx_fail` (probability of on-",
    "treatment failure), via a genuinely non-linear (quadratic-ish) ",
    "relationship. A GAM regression smooths this relationship to compute ",
    "EVPPI. Drag the basis-dimension `k` slider and watch the fitted ",
    "curve go from under-fit (too smooth, misses real curvature) to ",
    "over-fit (too wiggly, chases noise) -- and watch the resulting ",
    "EVPPI number swing accordingly."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("k_basis", "GAM basis dimension (k)", 3, 40, 10, step = 1),
      helpText("This app fixes the basis dimension (unpenalized regression ",
               "spline, fx=TRUE) so k directly controls fit complexity. ",
               "mgcv's default REML smoothness selection (NOT used here, so ",
               "the raw effect of k is isolated) would typically land around ",
               "k=8-12 for this relationship.")
    ),
    mainPanel(
      plotOutput("gamPlot", height = "400px"),
      verbatimTextOutput("evppiOut"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "EVPPI estimated via a GAM regression is only as good as the smoothness choice: too few ",
        "basis functions (small k) UNDER-fits the real curvature in the NMB-vs-parameter ",
        "relationship, flattening the fitted curve and UNDERESTIMATING EVPPI (the fitted surface ",
        "explains less of the true variance than it should); too many basis functions (large k) ",
        "OVER-fits random Monte Carlo noise in the PSA sample, inflating the fitted curve's ",
        "apparent explanatory power and OVERESTIMATING EVPPI. `mgcv`'s REML-based automatic ",
        "smoothness selection (the package default, not manually set) exists precisely to avoid ",
        "having to guess k by eye the way this app lets you do.")
    )
  )
)

server <- function(input, output, session) {

  psa_data <- reactive({
    set.seed(2024)
    n <- 2000
    p_ontx_fail <- runif(n, 0.05, 0.6)
    true_nmb <- 20000 - 60000 * (p_ontx_fail - 0.3)^2 +
      4000 * sin(p_ontx_fail * 25) + rnorm(n, 0, 2000) # quadratic + fine wiggle + noise
    data.frame(p_ontx_fail = p_ontx_fail, nmb = true_nmb)
  })

  gam_fit <- reactive({
    df <- psa_data()
    k <- input$k_basis
    gam(nmb ~ s(p_ontx_fail, k = k, fx = TRUE), data = df, method = "GCV.Cp")
  })

  evppi_result <- reactive({
    df <- psa_data()
    fit <- gam_fit()
    fitted_nmb <- predict(fit)
    var_fitted <- var(fitted_nmb)
    var_total <- var(df$nmb)
    # EVPPI approximation: variance of the fitted (explained) NMB surface
    # relative to the overall NMB variance
    evppi <- max(var_fitted, 0)
    list(evppi = evppi, var_fitted = var_fitted, var_total = var_total,
         prop_explained = var_fitted / var_total)
  })

  output$gamPlot <- renderPlot({
    df <- psa_data()
    fit <- gam_fit()
    grid <- data.frame(p_ontx_fail = seq(min(df$p_ontx_fail), max(df$p_ontx_fail), length.out = 200))
    grid$fitted <- predict(fit, newdata = grid)

    ggplot() +
      geom_point(data = df, aes(x = p_ontx_fail, y = nmb), alpha = 0.15, color = "grey50") +
      geom_line(data = grid, aes(x = p_ontx_fail, y = fitted), color = "#2166ac", linewidth = 1.3) +
      labs(x = "p_ontx_fail", y = "Incremental NMB",
           title = sprintf("GAM fit at k = %d", input$k_basis)) +
      theme_minimal(base_size = 13)
  })

  output$evppiOut <- renderPrint({
    r <- evppi_result()
    cat(sprintf("Basis dimension k: %d\n", input$k_basis))
    cat(sprintf("Variance explained by fitted surface (proxy for EVPPI): %.0f\n", r$var_fitted))
    cat(sprintf("Total NMB variance: %.0f\n", r$var_total))
    cat(sprintf("Proportion of variance explained: %.1f%%\n", r$prop_explained * 100))
  })

  output$interpretation <- renderText({
    r <- evppi_result()
    k <- input$k_basis
    regime <- if (k <= 5) {
      "This is a LOW k, likely under-fitting the true curvature -- the fitted EVPPI proxy may understate the real value of information."
    } else if (k >= 25) {
      "This is a HIGH k, likely over-fitting Monte Carlo noise -- the fitted EVPPI proxy may overstate the real value of information."
    } else {
      "This k is in a moderate range, roughly balancing fit against noise."
    }
    sprintf(paste0("At k=%d: the GAM-fitted surface explains %.1f%% of total NMB variance ",
                   "(proxy EVPPI = %.0f). %s"),
            k, r$prop_explained * 100, r$var_fitted, regime)
  })
}

shinyApp(ui, server)
