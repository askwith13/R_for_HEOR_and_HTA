library(shiny)
library(flexsurv)
library(ggplot2)
library(survival)

# Spline Knot-Count Explorer
# Companion to Chapter 10, SS10.3: a knot-count slider (k=0-3) for
# flexsurvspline() live-refits against a simulated KM curve within the
# trial period and updates an AIC/BIC readout, showing more knots always
# reduce in-sample AIC while risking an erratic extrapolated tail.

set.seed(99)
n <- 250
true_shape <- 1.3
true_scale <- 15
event_time <- rweibull(n, shape = true_shape, scale = true_scale)
censor_time <- runif(n, 10, 24) # trial follow-up censoring
time_obs <- pmin(event_time, censor_time)
status <- as.integer(event_time <= censor_time)
sim_df <- data.frame(time = time_obs, status = status)

ui <- fluidPage(
  titlePanel("Spline Knot-Count Explorer"),
  p("Companion app for Chapter 10, \u00a710.3 (Survival Analysis for ",
    "Economic Evaluation). A restricted cubic spline survival model ",
    "(`flexsurv::flexsurvspline()`) is re-fit live as you change the ",
    "number of internal knots (k). Watch AIC/BIC keep improving with more ",
    "knots in-sample, while the extrapolated tail beyond the trial ",
    "follow-up becomes visibly less smooth."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("k", "Number of internal knots (k)", 0, 3, 1, step = 1),
      sliderInput("extrap_horizon", "Extrapolation horizon (same time units as trial)", 24, 80, 50, step = 2),
      helpText("k=0 is equivalent to a Weibull model. Each additional knot ",
               "adds flexibility (and fitted parameters).")
    ),
    mainPanel(
      plotOutput("splinePlot", height = "400px"),
      tableOutput("fitTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "More spline knots mean more fitted parameters, which structurally can only improve ",
        "(never worsen) the raw log-likelihood -- but AIC/BIC penalize that extra flexibility, ",
        "so a higher-k model is NOT guaranteed to win on AIC/BIC despite its better ",
        "log-likelihood, and winning on AIC/BIC in-sample is still no guarantee of a sensible ",
        "EXTRAPOLATION beyond the trial. The monotonicity check below flags if/when a given ",
        "knot count produces an implausible non-monotonic tail (survival briefly rising) at ",
        "the chosen extrapolation horizon -- whether this actually happens depends on the ",
        "specific data and horizon, which is itself the point: a higher-k fit that looks fine ",
        "at one horizon can misbehave at a longer one, so always check the FULL intended ",
        "extrapolation range, not just whichever AIC number is lowest in-sample.")
    )
  )
)

server <- function(input, output, session) {

  spline_fit <- reactive({
    tryCatch({
      flexsurvspline(Surv(time, status) ~ 1, data = sim_df, k = input$k, scale = "hazard")
    }, error = function(e) NULL)
  })

  output$splinePlot <- renderPlot({
    fit <- spline_fit()
    req(!is.null(fit))

    t_grid <- seq(0.1, input$extrap_horizon, length.out = 300)
    pred <- summary(fit, t = t_grid, type = "survival", ci = FALSE)[[1]]

    km_fit <- survfit(Surv(time, status) ~ 1, data = sim_df)
    km_df <- data.frame(time = km_fit$time, surv = km_fit$surv)

    ggplot() +
      geom_step(data = km_df, aes(x = time, y = surv), color = "grey50", linewidth = 0.8) +
      geom_line(data = pred, aes(x = time, y = est), color = "#2166ac", linewidth = 1.2) +
      geom_vline(xintercept = max(sim_df$time), linetype = "dashed", color = "#d6604d") +
      labs(x = "Time", y = "Survival probability",
           title = sprintf("Spline fit with k=%d knots", input$k),
           subtitle = "Grey step: KM curve. Dashed line: end of observed follow-up.") +
      theme_minimal(base_size = 13)
  })

  output$fitTable <- renderTable({
    fit <- spline_fit()
    req(!is.null(fit))
    data.frame(
      Metric = c("Number of knots (k)", "Number of parameters", "AIC", "Log-likelihood"),
      Value = c(as.character(input$k), as.character(length(fit$coefficients)),
                sprintf("%.2f", AIC(fit)), sprintf("%.2f", fit$loglik))
    )
  })

  output$interpretation <- renderText({
    fit <- spline_fit()
    req(!is.null(fit))

    # Check for non-monotonicity in the extrapolated tail (beyond observed follow-up)
    t_tail <- seq(max(sim_df$time), input$extrap_horizon, length.out = 100)
    pred_tail <- summary(fit, t = t_tail, type = "survival", ci = FALSE)[[1]]
    is_monotonic <- all(diff(pred_tail$est) <= 1e-6)

    sprintf(paste0("With k=%d knots: AIC = %.1f, log-likelihood = %.1f, %d fitted parameters. ",
                   "Beyond the observed follow-up (t > %.1f), the extrapolated survival curve is ",
                   "%s. Log-likelihood always improves (or stays flat) with more knots, but AIC/",
                   "BIC can go either way once the parameter-count penalty is applied."),
            input$k, AIC(fit), fit$loglik, length(fit$coefficients), max(sim_df$time),
            if (is_monotonic) "smoothly monotonic (plausible)" else "NON-monotonic (survival briefly rises) -- a red flag for extrapolation")
  })
}

shinyApp(ui, server)
