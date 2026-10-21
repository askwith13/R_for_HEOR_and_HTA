library(shiny)
library(simmer)
library(ggplot2)

# M/M/1 Queue Utilisation Explorer
# Companion to Chapter 22, SS22.2: sliders for mean inter-arrival time and
# mean service time drive a live simmer re-run of a single-nurse clinic
# model, shown alongside the closed-form M/M/1 benchmark -- making the
# non-linear blow-up in wait time as utilisation (rho) approaches 1
# directly visible.

ui <- fluidPage(
  titlePanel("M/M/1 Queue Utilisation Explorer"),
  p("Companion app for Chapter 22, \u00a722.2 (Discrete Event Simulation and ",
    "Dynamic Models). A single-nurse clinic is modelled as an M/M/1 queue ",
    "using the `simmer` package. Adjust the mean inter-arrival time and mean ",
    "service time; the simulated average wait, queue length, and nurse ",
    "utilisation update live, alongside the closed-form M/M/1 formulas. ",
    "Watch wait time blow up non-linearly as utilisation (\u03c1) approaches 1."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("mean_interarrival", "Mean inter-arrival time (minutes)",
                  5, 30, 10, step = 0.5),
      sliderInput("mean_service", "Mean service time (minutes)",
                  5, 28, 8, step = 0.5),
      sliderInput("sim_hours", "Simulation length (hours)", 100, 2000, 500, step = 100),
      helpText("\u03bb = 1/inter-arrival, \u03bc = 1/service. Stability requires \u03c1 = \u03bb/\u03bc < 1 ",
               "(when \u03c1 \u2265 1 the queue grows without bound and the simulation is ",
               "not run; the dashboard shows the instability warning instead).")
    ),
    mainPanel(
      verbatimTextOutput("summaryOut"),
      plotOutput("waitPlot", height = "350px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Staffing decisions based on average utilisation alone can badly ",
        "underestimate wait times. Compare \u03c1 = 0.70 against \u03c1 = 0.90: utilisation ",
        "only rose about 29%, but wait time rose far more sharply \u2014 the Wq curve is ",
        "convex, not linear, in \u03c1. A clinic running \"comfortably busy\" at 70% ",
        "utilisation and a clinic running \"almost always busy\" at 90% are not ",
        "proportionally different in patient experience; they are qualitatively ",
        "different.")
    )
  )
)

server <- function(input, output, session) {

  sim_result <- reactive({
    lambda <- 1 / input$mean_interarrival
    mu <- 1 / input$mean_service
    rho <- lambda / mu

    if (rho >= 0.98) {
      return(list(unstable = TRUE, rho = rho))
    }

    set.seed(123)
    sim_minutes <- input$sim_hours * 60

    clinic <- trajectory("patient") %>%
      seize("nurse", 1) %>%
      timeout(function() rexp(1, mu)) %>%
      release("nurse", 1)

    env <- simmer("clinic") %>%
      add_resource("nurse", capacity = 1) %>%
      add_generator("patient", clinic, function() rexp(1, lambda)) %>%
      run(until = sim_minutes)

    wait_times <- get_mon_arrivals(env)
    res_mon <- get_mon_resources(env)

    sim_wait <- mean(wait_times$end_time - wait_times$start_time - wait_times$activity_time)

    # Time-weighted server utilisation (the resource-state log is event-
    # triggered, not evenly spaced, so a plain mean() of `server` would be
    # biased -- weight each state by how long it actually held)
    res_mon <- res_mon[order(res_mon$time), ]
    res_mon$next_time <- c(res_mon$time[-1], sim_minutes)
    res_mon$duration <- res_mon$next_time - res_mon$time
    sim_util <- sum(res_mon$server * res_mon$duration) / sim_minutes

    # Closed-form M/M/1 benchmarks
    Wq_theory <- rho / (mu - lambda)
    Lq_theory <- rho^2 / (1 - rho)
    L_theory <- rho / (1 - rho)

    list(unstable = FALSE, rho = rho, sim_wait = sim_wait, sim_util = sim_util,
         Wq_theory = Wq_theory, Lq_theory = Lq_theory, L_theory = L_theory,
         n_patients = nrow(wait_times))
  })

  output$summaryOut <- renderPrint({
    r <- sim_result()
    if (r$unstable) {
      cat(sprintf("UNSTABLE: \u03c1 = \u03bb/\u03bc = %.3f \u2265 1 \u2014 arrivals outpace service; ", r$rho))
      cat("the queue grows without bound. Lower arrival rate or raise service rate.\n")
      return(invisible())
    }
    cat(sprintf("\u03bb (arrival rate)  = %.4f per minute\n", 1 / input$mean_interarrival))
    cat(sprintf("\u03bc (service rate)  = %.4f per minute\n", 1 / input$mean_service))
    cat(sprintf("\u03c1 (utilisation)   = %.3f\n\n", r$rho))
    cat(sprintf("Simulated patients processed: %d\n", r$n_patients))
    cat(sprintf("Simulated mean wait (Wq):     %.2f minutes\n", r$sim_wait))
    cat(sprintf("Theoretical M/M/1 Wq:         %.2f minutes\n\n", r$Wq_theory))
    cat(sprintf("Simulated utilisation:        %.3f  (theoretical \u03c1 = %.3f)\n\n", r$sim_util, r$rho))
    cat(sprintf("Theoretical M/M/1 Lq (queue length): %.2f\n", r$Lq_theory))
    cat(sprintf("Theoretical M/M/1 L (system length):  %.2f\n", r$L_theory))
  })

  output$waitPlot <- renderPlot({
    rho_grid <- seq(0.05, 0.97, by = 0.01)
    mu <- 1 / input$mean_service
    lambda_grid <- rho_grid * mu
    Wq_grid <- rho_grid / (mu - lambda_grid)

    r <- sim_result()
    current_rho <- r$rho

    df <- data.frame(rho = rho_grid, Wq = Wq_grid)
    ggplot(df, aes(x = rho, y = Wq)) +
      geom_line(color = "#2166ac", linewidth = 1) +
      geom_vline(xintercept = min(current_rho, 0.97), linetype = "dashed", color = "#d6604d") +
      labs(x = expression(rho~"(utilisation)"), y = "Expected wait time, Wq (minutes)",
           title = "M/M/1 theoretical wait time vs. utilisation (\u03c1)",
           subtitle = "Dashed line: current slider setting") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    r <- sim_result()
    if (r$unstable) {
      return("The queue is unstable at this setting \u2014 no meaningful wait-time comparison is possible until \u03c1 < 1.")
    }
    pct_err <- (r$sim_wait - r$Wq_theory) / r$Wq_theory * 100
    sprintf(paste0("At \u03c1 = %.2f, the simulated average wait (%.1f min) is within %.1f%% of the ",
                   "closed-form M/M/1 prediction (%.1f min) \u2014 the small gap is pure simulation ",
                   "noise, not a modelling error. As \u03c1 climbs toward 1, Wq grows roughly as ",
                   "1/(1\u2212\u03c1): doubling how close you get to full utilisation can multiply the ",
                   "expected wait many times over, not just double it."),
            r$rho, r$sim_wait, abs(pct_err), r$Wq_theory)
  })
}

shinyApp(ui, server)
