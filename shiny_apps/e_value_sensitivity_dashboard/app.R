library(shiny)
library(EValue)
library(ggplot2)

# E-value Sensitivity Dashboard
# Companion to Chapter 15, SS15.9: user inputs an observed effect estimate
# (RR/HR/OR) and its CI; the app live-computes the point-estimate and
# CI-limit E-values via EValue::evalues.RR()-style logic, with a fragile-
# vs-robust gauge -- turns a one-off unmeasured-confounding sensitivity
# calculation into an interactive what-if tool.

ui <- fluidPage(
  titlePanel("E-value Sensitivity Dashboard"),
  p("Companion app for Chapter 15, \u00a715.9 (Real-World Evidence and Causal ",
    "Inference). The E-value quantifies how strong unmeasured confounding ",
    "would need to be (on the risk-ratio scale, associated with both ",
    "exposure and outcome) to fully explain away an observed association. ",
    "Enter a risk ratio and 95% CI and watch the E-value for the point ",
    "estimate and for the CI limit closer to the null recompute live."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("rr_point", "Observed risk ratio (point estimate)", 0.2, 5, 1.8, step = 0.05),
      sliderInput("rr_lo", "95% CI lower bound", 0.1, 5, 1.2, step = 0.05),
      sliderInput("rr_hi", "95% CI upper bound", 0.2, 10, 2.7, step = 0.05),
      helpText("Lower bound should be below the point estimate, upper bound above it.")
    ),
    mainPanel(
      plotOutput("evaluePlot", height = "350px"),
      tableOutput("evalTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A large E-value does NOT prove there is no unmeasured confounding \u2014 it only ",
        "describes how strong such confounding would need to be to explain the finding ",
        "away. Whether that strength is 'plausible' is a substantive judgement about the ",
        "specific exposure and outcome, not something the E-value itself can answer. Drag ",
        "the CI lower bound toward 1.0 (the null) and watch the CI-limit E-value collapse ",
        "toward 1 even while the point-estimate E-value stays high \u2014 a reminder that an ",
        "association compatible with the null at its CI edge is fragile almost by ",
        "definition, regardless of the point estimate's own E-value.")
    )
  )
)

server <- function(input, output, session) {

  eval_result <- reactive({
    req(input$rr_lo < input$rr_point, input$rr_hi > input$rr_point)
    ev <- evalues.RR(est = input$rr_point, lo = input$rr_lo, hi = input$rr_hi)
    ev
  })

  output$evalTable <- renderTable({
    ev <- eval_result()
    df <- as.data.frame(ev)
    df <- cbind(Statistic = rownames(df), df)
    rownames(df) <- NULL
    df
  }, digits = 3)

  output$evaluePlot <- renderPlot({
    ev <- eval_result()
    df <- as.data.frame(ev)
    point_eval <- df["E-values", "point"]
    ci_eval <- df["E-values", "lower"]

    bars <- data.frame(
      type = factor(c("Point estimate", "CI limit (closer to null)"),
                     levels = c("Point estimate", "CI limit (closer to null)")),
      evalue = c(point_eval, ci_eval)
    )
    ggplot(bars, aes(x = type, y = evalue, fill = type)) +
      geom_col(width = 0.5) +
      geom_text(aes(label = sprintf("%.2f", evalue)), vjust = -0.5, size = 5) +
      geom_hline(yintercept = 1, linetype = "dashed", color = "grey40") +
      scale_fill_manual(values = c("Point estimate" = "#2166ac", "CI limit (closer to null)" = "#d6604d")) +
      labs(x = NULL, y = "E-value",
           title = "E-value: minimum confounding strength (RR scale) to explain away the finding") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "none")
  })

  output$interpretation <- renderText({
    ev <- eval_result()
    df <- as.data.frame(ev)
    point_eval <- df["E-values", "point"]
    ci_eval <- df["E-values", "lower"]
    robustness <- if (ci_eval < 1.25) {
      "FRAGILE -- a quite weak unmeasured confounder could explain away this finding entirely"
    } else if (ci_eval < 2) {
      "moderately robust"
    } else {
      "fairly robust -- would need a strong unmeasured confounder to fully explain away"
    }
    sprintf(paste0("Observed RR = %.2f (95%% CI %.2f\u2013%.2f). Point-estimate E-value = %.2f: an ",
                   "unmeasured confounder would need to be associated with BOTH exposure and ",
                   "outcome by at least this risk-ratio magnitude to fully explain the finding ",
                   "away. CI-limit E-value = %.2f (using the CI bound closest to the null). ",
                   "Overall robustness: %s."),
            input$rr_point, input$rr_lo, input$rr_hi, point_eval, ci_eval, robustness)
  })
}

shinyApp(ui, server)
