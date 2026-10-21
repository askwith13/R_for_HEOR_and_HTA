library(shiny)
library(ggplot2)
library(dplyr)

# Diagnostic Tree ICER Dashboard
# Companion to Chapter 18, SS18.1-18.2: sliders for TB prevalence, each
# test's sensitivity/specificity, and costs of tests/outcomes recompute
# the rollback expected cost/QALYs for both diagnostic strategies
# (smear-only vs. Xpert MTB/RIF) live, with the ICER and a CE-plane point
# updating instantly.

run_tree <- function(prevalence, sens, spec, test_cost, fp_cost, fn_cost, tp_cost, tn_cost,
                      fp_qaly, fn_qaly, tp_qaly, tn_qaly) {
  p_tp <- prevalence * sens
  p_fn <- prevalence * (1 - sens)
  p_fp <- (1 - prevalence) * (1 - spec)
  p_tn <- (1 - prevalence) * spec

  exp_cost <- test_cost + p_tp * tp_cost + p_fn * fn_cost + p_fp * fp_cost + p_tn * tn_cost
  exp_qaly <- p_tp * tp_qaly + p_fn * fn_qaly + p_fp * fp_qaly + p_tn * tn_qaly

  list(exp_cost = exp_cost, exp_qaly = exp_qaly,
       p_tp = p_tp, p_fn = p_fn, p_fp = p_fp, p_tn = p_tn)
}

ui <- fluidPage(
  titlePanel("Diagnostic Tree ICER Dashboard"),
  p("Companion app for Chapter 18, \u00a718.1\u201318.2 (Decision Trees). Two TB ",
    "diagnostic strategies -- smear microscopy (cheaper, lower sensitivity) ",
    "vs. Xpert MTB/RIF (costlier, higher sensitivity) -- are compared via ",
    "expected-value rollback. Every slider recomputes both strategies' ",
    "expected cost/QALYs and the resulting ICER live."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("prevalence", "TB prevalence in tested population", 0.05, 0.6, 0.30, step = 0.01),
      hr(),
      h4("Smear microscopy"),
      sliderInput("smear_sens", "Sensitivity", 0.4, 0.95, 0.65, step = 0.01),
      sliderInput("smear_spec", "Specificity", 0.8, 1.0, 0.98, step = 0.005),
      sliderInput("smear_cost", "Test cost", 1, 30, 5, step = 1),
      hr(),
      h4("Xpert MTB/RIF"),
      sliderInput("xpert_sens", "Sensitivity", 0.4, 0.99, 0.90, step = 0.01),
      sliderInput("xpert_spec", "Specificity", 0.8, 1.0, 0.98, step = 0.005),
      sliderInput("xpert_cost", "Test cost", 5, 60, 15, step = 1),
      hr(),
      h4("Outcome costs and QALYs (shared across strategies)"),
      sliderInput("tp_cost", "Cost if correctly started on treatment (TP)", 50, 500, 150, step = 10),
      sliderInput("fn_cost", "Cost if missed (FN, presents later, sicker)", 100, 1500, 500, step = 25),
      sliderInput("fp_cost", "Cost if treated unnecessarily (FP)", 50, 500, 150, step = 10),
      sliderInput("tp_qaly", "QALY if correctly started on treatment (TP)", 0.5, 1, 0.93, step = 0.01),
      sliderInput("fn_qaly", "QALY if missed (FN)", 0.2, 0.9, 0.70, step = 0.01)
    ),
    mainPanel(
      fluidRow(
        column(6, h4("Results"), tableOutput("resultsTable")),
        column(6, h4("ICER"), verbatimTextOutput("icerOut"))
      ),
      plotOutput("treePlanePlot", height = "350px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "The relative value of a more sensitive (but costlier) test depends ",
        "heavily on disease prevalence. Drag prevalence down toward 0.10 \u2014 at ",
        "low prevalence, most tested patients are truly negative, so Xpert's ",
        "sensitivity advantage applies to a small fraction of the population and ",
        "may not justify its extra cost. Drag prevalence up toward 0.50 and watch ",
        "the case for Xpert strengthen. A single ICER calculated at one assumed ",
        "prevalence should never be generalised to a setting with a very ",
        "different prevalence without re-running the tree.")
    )
  )
)

server <- function(input, output, session) {

  smear <- reactive({
    run_tree(input$prevalence, input$smear_sens, input$smear_spec, input$smear_cost,
              fp_cost = input$fp_cost, fn_cost = input$fn_cost, tp_cost = input$tp_cost, tn_cost = 0,
              fp_qaly = 0.85, fn_qaly = input$fn_qaly, tp_qaly = input$tp_qaly, tn_qaly = 1.0)
  })
  xpert <- reactive({
    run_tree(input$prevalence, input$xpert_sens, input$xpert_spec, input$xpert_cost,
              fp_cost = input$fp_cost, fn_cost = input$fn_cost, tp_cost = input$tp_cost, tn_cost = 0,
              fp_qaly = 0.85, fn_qaly = input$fn_qaly, tp_qaly = input$tp_qaly, tn_qaly = 1.0)
  })

  output$resultsTable <- renderTable({
    data.frame(
      Strategy = c("Smear", "Xpert"),
      `Expected cost` = c(smear()$exp_cost, xpert()$exp_cost),
      `Expected QALYs` = c(smear()$exp_qaly, xpert()$exp_qaly),
      check.names = FALSE
    )
  }, digits = 4)

  output$icerOut <- renderPrint({
    dc <- xpert()$exp_cost - smear()$exp_cost
    dq <- xpert()$exp_qaly - smear()$exp_qaly
    if (abs(dq) < 1e-9) {
      cat("Incremental QALYs ~ 0: ICER undefined\n")
    } else {
      cat(sprintf("Incremental cost:  %.2f\n", dc))
      cat(sprintf("Incremental QALYs: %.5f\n", dq))
      cat(sprintf("ICER:              %.2f per QALY\n", dc / dq))
      if (dc < 0 && dq > 0) cat("Xpert dominates Smear (cheaper AND more effective)\n")
      if (dc > 0 && dq < 0) cat("Xpert is dominated by Smear (costlier AND less effective)\n")
    }
  })

  output$treePlanePlot <- renderPlot({
    dc <- xpert()$exp_cost - smear()$exp_cost
    dq <- xpert()$exp_qaly - smear()$exp_qaly
    df <- data.frame(x = dq, y = dc)
    ggplot(df, aes(x = x, y = y)) +
      geom_point(size = 5, color = "#2166ac") +
      geom_hline(yintercept = 0, linetype = "dashed") +
      geom_vline(xintercept = 0, linetype = "dashed") +
      labs(x = "Incremental QALYs (Xpert \u2212 Smear)", y = "Incremental cost (Xpert \u2212 Smear)",
           title = "Cost-effectiveness plane") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    s <- smear(); x <- xpert()
    dc <- x$exp_cost - s$exp_cost
    dq <- x$exp_qaly - s$exp_qaly
    sprintf(paste0("At %.0f%% prevalence, Xpert catches %.1f%% of true cases (TP rate) vs. ",
                   "smear's %.1f%% \u2014 a gap of %.1f percentage points that translates to %.4f ",
                   "incremental QALYs at an incremental cost of %.2f, giving an ICER of %.0f per QALY."),
            input$prevalence * 100, x$p_tp / input$prevalence * 100, s$p_tp / input$prevalence * 100,
            (x$p_tp - s$p_tp) / input$prevalence * 100, dq, dc,
            if (abs(dq) > 1e-9) dc / dq else NA)
  })
}

shinyApp(ui, server)
