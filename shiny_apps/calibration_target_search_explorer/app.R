library(shiny)
library(ggplot2)

# Calibration Target Search Explorer
# Companion to Chapter 27, SS27.1: a slider for the calibration target
# value (e.g. a registry's 5-year mortality rate) live-reruns an optim()
# Nelder-Mead search for a hidden model parameter and redraws both the
# random-search scatter and the converged value -- shows how sensitive
# the calibrated parameter is to the exact target chosen.

simulate_5yr_mortality <- function(p_hidden) {
  # A toy structural model: hidden annual transition probability p_hidden
  # drives a simple 5-year survival calculation
  annual_survival <- 1 - p_hidden
  1 - annual_survival^5 # 5-year mortality
}

ui <- fluidPage(
  titlePanel("Calibration Target Search Explorer"),
  p("Companion app for Chapter 27, \u00a727.1 (Model Calibration, ",
    "Validation and Quality Assurance). A structural model has a hidden ",
    "annual transition probability (p_hidden) that is NOT directly ",
    "observable, but the model's 5-year mortality OUTPUT can be compared ",
    "against a real-world registry target. Drag the target value and ",
    "watch `optim()`'s Nelder-Mead search re-converge on a different ",
    "calibrated p_hidden each time."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("target_mortality", "Registry 5-year mortality target", 0.1, 0.6, 0.32, step = 0.01),
      helpText("The illustrative base case uses a 32% target. Drag it to ",
               "see how much the calibrated p_hidden moves for a given ",
               "change in target.")
    ),
    mainPanel(
      plotOutput("calibrationPlot", height = "400px"),
      verbatimTextOutput("calibrationOut"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A calibration target itself has uncertainty (a registry's reported 32% mortality ",
        "rate is an ESTIMATE, not a known-exact fact) -- yet calibration exercises often ",
        "treat the target as a single fixed point without propagating that target's own ",
        "confidence interval through to the calibrated parameter. Drag the target across a ",
        "plausible range (say, a registry's own 95% CI) and watch how much the calibrated ",
        "p_hidden moves -- if it moves substantially, the final model's results inherit all ",
        "of that target uncertainty, which a single-point calibration silently hides.")
    )
  )
)

server <- function(input, output, session) {

  calibration_result <- reactive({
    target <- input$target_mortality

    objective <- function(p_hidden) {
      if (p_hidden <= 0 || p_hidden >= 1) return(1e6)
      (simulate_5yr_mortality(p_hidden) - target)^2
    }

    fit <- optim(0.07, objective, method = "Brent", lower = 0.001, upper = 0.5)

    # Random search scatter for visualization
    set.seed(42)
    search_p <- runif(200, 0.001, 0.5)
    search_obj <- sapply(search_p, objective)

    list(p_hidden = fit$par, converged_value = simulate_5yr_mortality(fit$par),
         search_p = search_p, search_obj = search_obj, target = target)
  })

  output$calibrationPlot <- renderPlot({
    r <- calibration_result()
    df <- data.frame(p = r$search_p, obj = r$search_obj)
    ggplot(df, aes(x = p, y = obj)) +
      geom_point(alpha = 0.4, color = "grey60") +
      geom_vline(xintercept = r$p_hidden, linetype = "dashed", color = "#d6604d", linewidth = 1) +
      scale_y_log10() +
      labs(x = "Candidate p_hidden", y = "Objective (squared error, log scale)",
           title = "Random search scatter and optim() convergence",
           subtitle = sprintf("Converged p_hidden = %.4f (dashed red line)", r$p_hidden)) +
      theme_minimal(base_size = 13)
  })

  output$calibrationOut <- renderPrint({
    r <- calibration_result()
    cat(sprintf("Target 5-year mortality: %.3f\n", r$target))
    cat(sprintf("Calibrated p_hidden:     %.5f\n", r$p_hidden))
    cat(sprintf("Model output at this p_hidden: %.5f (should match target)\n", r$converged_value))
  })

  output$interpretation <- renderText({
    r <- calibration_result()
    # Compare to a +/- 0.02 perturbation to show sensitivity
    target_lo <- max(r$target - 0.02, 0.11)
    objective_lo <- function(p_hidden) (simulate_5yr_mortality(p_hidden) - target_lo)^2
    fit_lo <- optim(0.07, objective_lo, method = "Brent", lower = 0.001, upper = 0.5)
    sensitivity <- abs(r$p_hidden - fit_lo$par) / 0.02

    sprintf(paste0("At target = %.2f: calibrated p_hidden = %.4f. A \u00b10.02 change in the target ",
                   "moves the calibrated p_hidden by about %.5f per 0.01 change in target -- this ",
                   "sensitivity means any uncertainty in the registry's own reported mortality ",
                   "rate directly propagates into uncertainty about the hidden parameter, which ",
                   "then propagates into every downstream model result."),
            r$target, r$p_hidden, sensitivity * 0.01)
  })
}

shinyApp(ui, server)
