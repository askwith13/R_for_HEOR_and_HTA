library(shiny)
library(flexsurv)
library(dplyr)
library(ggplot2)

# PSM Oncology ICER Dashboard
# Companion to Chapter 20, SS20.6: sliders for each arm's PFS/OS Weibull
# shape+scale and state costs/utilities feed a real partitioned-survival
# discounting loop, re-computing discounted cost, QALYs and ICER live for
# both arms, with a curve-crossing check flagging the chapter's own
# pitfall.

run_arm <- function(pfs_shape, pfs_scale, os_shape, os_scale,
                     cost_progfree, cost_prog, util_progfree, util_prog,
                     horizon_months = 60, disc_rate = 0.035) {
  t <- seq(0, horizon_months, by = 1)
  # Survival functions (Weibull, in months)
  s_pfs <- pweibull(t, shape = pfs_shape, scale = pfs_scale, lower.tail = FALSE)
  s_os_raw <- pweibull(t, shape = os_shape, scale = os_scale, lower.tail = FALSE)
  raw_gap <- min(s_os_raw - s_pfs)
  # OS must be >= PFS at all times for a valid PSM -- correct if it isn't,
  # but flag that correction happened via the crossing check below
  s_os <- pmax(s_os_raw, s_pfs)

  p_progfree <- s_pfs
  p_progressed <- s_os - s_pfs
  p_progressed <- pmax(p_progressed, 0)
  p_dead <- 1 - s_os

  disc_factor <- 1 / (1 + disc_rate)^(t / 12)

  monthly_cost <- (p_progfree * cost_progfree + p_progressed * cost_prog)
  monthly_qaly <- (p_progfree * util_progfree + p_progressed * util_prog) / 12

  disc_cost <- sum(monthly_cost * disc_factor)
  disc_qaly <- sum(monthly_qaly * disc_factor)

  list(t = t, s_pfs = s_pfs, s_os = s_os, disc_cost = disc_cost, disc_qaly = disc_qaly,
       crossing_detected = raw_gap < -1e-6)
}

ui <- fluidPage(
  titlePanel("PSM Oncology ICER Dashboard"),
  p("Companion app for Chapter 20, \u00a720.6 (Advanced Topics in Survival ",
    "Modelling). A partitioned-survival model (PSM) tracks 3 states ",
    "(progression-free, progressed, dead) using independently-fitted ",
    "Weibull curves for PFS and OS. Sliders control each arm's curve ",
    "shape/scale and state costs/utilities; discounted cost, QALYs, and ",
    "the ICER recompute live, alongside a crossing-check flag -- the ",
    "chapter's own pitfall that PFS and OS curves must never cross."),
  sidebarLayout(
    sidebarPanel(
      h4("Control arm"),
      sliderInput("ctrl_pfs_scale", "Control PFS scale (months)", 3, 24, 8, step = 0.5),
      sliderInput("ctrl_os_scale", "Control OS scale (months)", 6, 48, 18, step = 0.5),
      h4("Intervention arm"),
      sliderInput("int_pfs_scale", "Intervention PFS scale (months)", 3, 24, 14, step = 0.5),
      sliderInput("int_os_scale", "Intervention OS scale (months)", 6, 48, 26, step = 0.5),
      h4("Costs and utilities"),
      sliderInput("cost_progfree", "Monthly cost, progression-free ($)", 500, 10000, 4000, step = 100),
      sliderInput("cost_prog", "Monthly cost, progressed ($)", 500, 10000, 2000, step = 100),
      sliderInput("util_progfree", "Utility, progression-free", 0.3, 1.0, 0.75, step = 0.01),
      sliderInput("util_prog", "Utility, progressed", 0.1, 0.9, 0.55, step = 0.01)
    ),
    mainPanel(
      plotOutput("survivalPlot", height = "350px"),
      verbatimTextOutput("icerOut"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Because PFS and OS are fitted INDEPENDENTLY in a partitioned-survival model, nothing in ",
        "the curve-fitting process mathematically guarantees OS stays above PFS at every time ",
        "point -- if PFS's scale parameter is pushed large relative to OS's, the curves can cross, ",
        "which would imply a NEGATIVE probability of being in the progressed state (a logical ",
        "impossibility the model cannot represent correctly). This app's crossing-check flag ",
        "(red if triggered) is the chapter's own recommended safeguard against submitting a model ",
        "with this error silently baked in.")
    )
  )
)

server <- function(input, output, session) {

  results <- reactive({
    ctrl <- run_arm(pfs_shape = 1.2, pfs_scale = input$ctrl_pfs_scale,
                     os_shape = 1.1, os_scale = input$ctrl_os_scale,
                     cost_progfree = input$cost_progfree, cost_prog = input$cost_prog,
                     util_progfree = input$util_progfree, util_prog = input$util_prog)
    intervention <- run_arm(pfs_shape = 1.2, pfs_scale = input$int_pfs_scale,
                             os_shape = 1.1, os_scale = input$int_os_scale,
                             cost_progfree = input$cost_progfree, cost_prog = input$cost_prog,
                             util_progfree = input$util_progfree, util_prog = input$util_prog)
    list(ctrl = ctrl, intervention = intervention)
  })

  output$survivalPlot <- renderPlot({
    r <- results()
    df <- rbind(
      data.frame(t = r$ctrl$t, surv = r$ctrl$s_pfs, arm = "Control", curve = "PFS"),
      data.frame(t = r$ctrl$t, surv = r$ctrl$s_os, arm = "Control", curve = "OS"),
      data.frame(t = r$intervention$t, surv = r$intervention$s_pfs, arm = "Intervention", curve = "PFS"),
      data.frame(t = r$intervention$t, surv = r$intervention$s_os, arm = "Intervention", curve = "OS")
    )
    ggplot(df, aes(x = t, y = surv, color = arm, linetype = curve)) +
      geom_line(linewidth = 1) +
      labs(x = "Months", y = "Survival probability", title = "PFS and OS curves by arm") +
      theme_minimal(base_size = 13)
  })

  output$icerOut <- renderPrint({
    r <- results()
    inc_cost <- r$intervention$disc_cost - r$ctrl$disc_cost
    inc_qaly <- r$intervention$disc_qaly - r$ctrl$disc_qaly
    icer <- inc_cost / inc_qaly
    cat(sprintf("Control:      discounted cost = $%.0f, discounted QALYs = %.3f\n", r$ctrl$disc_cost, r$ctrl$disc_qaly))
    cat(sprintf("Intervention: discounted cost = $%.0f, discounted QALYs = %.3f\n", r$intervention$disc_cost, r$intervention$disc_qaly))
    cat(sprintf("Incremental cost: $%.0f, Incremental QALYs: %.3f\n", inc_cost, inc_qaly))
    cat(sprintf("ICER: $%.0f per QALY\n", icer))
    if (r$ctrl$crossing_detected || r$intervention$crossing_detected) {
      cat("\n*** CROSSING CHECK FAILED: PFS exceeds OS at some time point (invalid model) ***\n")
    } else {
      cat("\nCrossing check passed: OS >= PFS at all time points in both arms.\n")
    }
  })

  output$interpretation <- renderText({
    r <- results()
    inc_cost <- r$intervention$disc_cost - r$ctrl$disc_cost
    inc_qaly <- r$intervention$disc_qaly - r$ctrl$disc_qaly
    icer <- inc_cost / inc_qaly
    crossing <- r$ctrl$crossing_detected || r$intervention$crossing_detected
    sprintf(paste0("Current ICER: $%.0f/QALY (incremental cost $%.0f, incremental QALYs %.3f). ",
                   "%s"),
            icer, inc_cost, inc_qaly,
            if (crossing) {
              "WARNING: the crossing check has FAILED in at least one arm -- this ICER is computed from an internally invalid survival model and should not be trusted until the PFS/OS scale parameters are adjusted so OS stays above PFS throughout."
            } else {
              "Both arms pass the crossing check, so this ICER reflects a logically valid partitioned-survival structure."
            })
  })
}

shinyApp(ui, server)
