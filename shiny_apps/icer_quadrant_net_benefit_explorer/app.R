library(shiny)
library(ggplot2)

# ICER Quadrant & Net Benefit Explorer
# Companion to Chapter 4, SS4.4: drag incremental cost and incremental
# effect sliders on the CE plane while a WTP slider sets the threshold;
# ICER, NMB, and NHB all recompute live and the quadrant is flagged --
# directly shows why a negative ICER alone is ambiguous (dominant vs.
# dominated) while NMB/NHB never are.

ui <- fluidPage(
  titlePanel("ICER Quadrant & Net Benefit Explorer"),
  p("Companion app for Chapter 4, \u00a74.4 (Core Concepts in Health Economics). ",
    "Drag the incremental cost (\u0394C) and incremental effect (\u0394E) of a new ",
    "treatment vs. standard of care anywhere on the cost-effectiveness plane, ",
    "and a willingness-to-pay threshold (\u03bb); ICER, Net Monetary Benefit (NMB), ",
    "and Net Health Benefit (NHB) all recompute live."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("delta_c", "Incremental cost (\u0394C)", -50000, 100000, 30000, step = 1000),
      sliderInput("delta_e", "Incremental QALYs (\u0394E)", -2, 2, 0.5, step = 0.05),
      sliderInput("wtp", "WTP threshold (\u03bb, $/QALY)", 0, 150000, 50000, step = 1000)
    ),
    mainPanel(
      plotOutput("cePlanePlot", height = "400px"),
      tableOutput("metricsTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A negative ICER is fundamentally ambiguous on its own \u2014 it can mean the new ",
        "treatment DOMINATES (cheaper AND more effective, quadrant SE) or is DOMINATED ",
        "(costlier AND less effective, quadrant NW). Drag \u0394E to a small negative value ",
        "while \u0394C stays negative, then drag \u0394C to a small positive value while \u0394E ",
        "stays negative \u2014 both give a negative ICER but mean the exact opposite thing. ",
        "NMB and NHB never have this ambiguity: their SIGN alone tells you whether the ",
        "new treatment is worth it at that WTP threshold, with no quadrant-lookup required.")
    )
  )
)

server <- function(input, output, session) {

  results <- reactive({
    dc <- input$delta_c
    de <- input$delta_e
    wtp <- input$wtp

    icer <- if (abs(de) > 1e-9) dc / de else NA
    nmb <- wtp * de - dc
    nhb <- de - dc / wtp

    quadrant <- if (dc <= 0 && de >= 0) {
      "SE: Dominant (cheaper, more effective)"
    } else if (dc >= 0 && de <= 0) {
      "NW: Dominated (costlier, less effective)"
    } else if (dc >= 0 && de >= 0) {
      "NE: Trade-off (costlier, more effective)"
    } else {
      "SW: Trade-off (cheaper, less effective)"
    }

    list(dc = dc, de = de, icer = icer, nmb = nmb, nhb = nhb, quadrant = quadrant, wtp = wtp)
  })

  output$cePlanePlot <- renderPlot({
    r <- results()
    cost_effective <- r$nmb > 0

    ggplot() +
      geom_hline(yintercept = 0, color = "grey50") +
      geom_vline(xintercept = 0, color = "grey50") +
      geom_abline(slope = r$wtp, intercept = 0, linetype = "dashed", color = "#2ca25f") +
      geom_point(aes(x = r$de, y = r$dc), size = 6,
                 color = if (cost_effective) "#2166ac" else "#d6604d") +
      coord_cartesian(xlim = c(-2, 2), ylim = c(-50000, 100000)) +
      labs(x = "Incremental QALYs (\u0394E)", y = "Incremental cost (\u0394C)",
           title = "Cost-effectiveness plane",
           subtitle = sprintf("Green dashed line: WTP threshold ($%s/QALY). Point color: %s",
                               format(r$wtp, big.mark = ","),
                               if (cost_effective) "cost-effective (blue)" else "not cost-effective (red)")) +
      theme_minimal(base_size = 13)
  })

  output$metricsTable <- renderTable({
    r <- results()
    data.frame(
      Metric = c("ICER ($/QALY)", "NMB ($)", "NHB (QALYs)", "Quadrant"),
      Value = c(
        if (is.na(r$icer)) "undefined (\u0394E \u2248 0)" else format(round(r$icer), big.mark = ","),
        format(round(r$nmb), big.mark = ","),
        sprintf("%.3f", r$nhb),
        r$quadrant
      )
    )
  })

  output$interpretation <- renderText({
    r <- results()
    verdict <- if (r$nmb > 0) "cost-effective" else "NOT cost-effective"
    icer_txt <- if (is.na(r$icer)) {
      "ICER is undefined since \u0394E is essentially zero"
    } else {
      sprintf("the ICER (%s$%s/QALY) %s", if (r$icer < 0) "-" else "", format(abs(round(r$icer)), big.mark = ","),
              if (r$icer < 0) "alone does NOT tell you which, without checking the quadrant" else "is compared against the WTP threshold")
    }
    sprintf(paste0("At \u0394C=$%s, \u0394E=%.2f: this is in the '%s' quadrant, and %s. NMB = $%s, so ",
                   "at this WTP threshold the new treatment is %s."),
            format(r$dc, big.mark = ","), r$de, r$quadrant, icer_txt,
            format(round(r$nmb), big.mark = ","), verdict)
  })
}

shinyApp(ui, server)
