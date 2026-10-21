library(shiny)
library(ggplot2)

# Extreme-Value Test Sandbox
# Companion to Chapter 27, SS27.3: a slider setting the "Well-on-
# treatment to Dead" transition probability anywhere from 0 to 1 (not
# just the extreme 0/1 values the chapter's own test uses) live-
# recomputes and plots the resulting cohort survival trace.

ui <- fluidPage(
  titlePanel("Extreme-Value Test Sandbox"),
  p("Companion app for Chapter 27, \u00a727.3 (Model Calibration, ",
    "Validation and Quality Assurance). An extreme-value test sets a ",
    "model parameter to a mathematically predictable boundary value ",
    "(e.g. a transition probability of exactly 0 or 1) and checks the ",
    "model's output matches the predictable extreme -- a core model-",
    "verification technique. This app lets you drag the 'Well-on-",
    "treatment to Dead' transition probability anywhere from 0 to 1, ",
    "not just the two extremes, so you can watch the cohort trace ",
    "degrade CONTINUOUSLY toward each predictable boundary."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("p_death", "Monthly 'Well-on-treatment \u2192 Dead' transition probability", 0, 1, 0.02, step = 0.01),
      sliderInput("n_cycles", "Number of monthly cycles to trace", 12, 120, 60, step = 6),
      helpText("At p=0, nobody should ever leave the Well-on-treatment ",
               "state (everyone alive at month N). At p=1, everyone ",
               "should be dead after exactly 1 cycle. Drag between these ",
               "extremes and watch the cohort trace degrade smoothly.")
    ),
    mainPanel(
      plotOutput("tracePlot", height = "380px"),
      verbatimTextOutput("extremeCheckOut"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Checking a model ONLY at its mathematically predictable extremes (p=0 and p=1) is a ",
        "minimal, necessary verification step -- it is NOT sufficient to confirm the model behaves ",
        "sensibly at realistic intermediate values. A model can pass both extreme-value tests ",
        "perfectly while still having a bug that only manifests at, say, p=0.3 (e.g. an off-by-one ",
        "error in cycle indexing, or a rounding issue that only accumulates visibly over many ",
        "cycles at a moderate transition rate). Extreme-value testing is the FIRST verification ",
        "step, not the only one.")
    )
  )
)

server <- function(input, output, session) {

  trace_data <- reactive({
    p <- input$p_death
    n_cycles <- input$n_cycles
    well <- numeric(n_cycles + 1)
    dead <- numeric(n_cycles + 1)
    well[1] <- 1
    dead[1] <- 0
    for (t in 2:(n_cycles + 1)) {
      moved <- well[t - 1] * p
      well[t] <- well[t - 1] - moved
      dead[t] <- dead[t - 1] + moved
    }
    data.frame(cycle = 0:n_cycles, well = well, dead = dead)
  })

  output$tracePlot <- renderPlot({
    df <- trace_data()
    df_long <- data.frame(
      cycle = rep(df$cycle, 2),
      proportion = c(df$well, df$dead),
      state = rep(c("Well-on-treatment", "Dead"), each = nrow(df))
    )
    ggplot(df_long, aes(x = cycle, y = proportion, color = state)) +
      geom_line(linewidth = 1.3) +
      scale_color_manual(values = c("Well-on-treatment" = "#2166ac", "Dead" = "#d6604d")) +
      ylim(0, 1) +
      labs(x = "Monthly cycle", y = "Cohort proportion",
           title = sprintf("Cohort trace at p(death) = %.2f", input$p_death)) +
      theme_minimal(base_size = 13)
  })

  output$extremeCheckOut <- renderPrint({
    df <- trace_data()
    p <- input$p_death
    final_well <- tail(df$well, 1)
    final_dead <- tail(df$dead, 1)
    cat(sprintf("At p = %.2f, after %d cycles: Well-on-treatment = %.4f, Dead = %.4f\n",
                p, input$n_cycles, final_well, final_dead))
    if (p == 0) {
      cat(sprintf("EXTREME-VALUE CHECK (p=0): expected Well=1.0000 exactly -- %s\n",
                   if (abs(final_well - 1) < 1e-9) "PASSED" else "FAILED"))
    } else if (p == 1) {
      cat(sprintf("EXTREME-VALUE CHECK (p=1): expected Dead=1.0000 after cycle 1 -- %s\n",
                   if (abs(final_dead - 1) < 1e-9) "PASSED" else "FAILED"))
    } else {
      cat("(Drag the slider to exactly 0 or 1 to trigger an extreme-value check.)\n")
    }
  })

  output$interpretation <- renderText({
    df <- trace_data()
    p <- input$p_death
    final_well <- tail(df$well, 1)
    theoretical_well <- (1 - p)^input$n_cycles
    sprintf(paste0("At p=%.2f over %d cycles: simulated Well-on-treatment proportion = %.4f, ",
                   "theoretical (1-p)^cycles = %.4f (should match exactly, since this is a simple ",
                   "geometric decay with no competing risks). %s"),
            p, input$n_cycles, final_well, theoretical_well,
            if (p %in% c(0, 1)) "This is one of the two mathematically predictable extremes." else "This is an intermediate value -- the trace should still match the closed-form geometric decay exactly, since the model has no other sources of error at this scale.")
  })
}

shinyApp(ui, server)
