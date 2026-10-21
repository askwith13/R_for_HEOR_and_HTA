library(shiny)
library(ggplot2)

# Threshold Sensitivity Dashboard
# Companion to Chapter 4, SS4.5: a WTP slider (lambda) spanning several
# real jurisdictional conventions (HTAIn/NICE/WHO-CHOICE-style GDP
# multiples) recomputes NMB and the cost-effective/not classification
# live for a fixed incremental cost/effect pair, with jurisdiction
# markers showing exactly where the decision flips.

ui <- fluidPage(
  titlePanel("WTP Threshold Sensitivity Dashboard"),
  p("Companion app for Chapter 4, \u00a74.5 (Core Concepts in Health ",
    "Economics). A fixed incremental cost and incremental QALY pair is ",
    "evaluated against a willingness-to-pay (WTP) threshold that you drag ",
    "across several real jurisdictional conventions -- watch the ",
    "cost-effective/not verdict flip exactly where the threshold crosses ",
    "the break-even ICER."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("delta_c", "Incremental cost (\u0394C)", 5000, 100000, 35000, step = 1000),
      sliderInput("delta_e", "Incremental QALYs (\u0394E)", 0.1, 2, 0.7, step = 0.05),
      sliderInput("wtp", "WTP threshold (\u03bb, $/QALY)", 0, 150000, 50000, step = 1000),
      helpText("Jurisdiction markers (illustrative): NICE lower bound ",
               "~$27,000 (\u00a320,000), NICE upper bound ~$41,000 (\u00a330,000), ",
               "WHO-CHOICE 1\u00d7GDP-per-capita style ~$75,000, 3\u00d7GDP-per-capita ",
               "style ~$225,000 (off-scale here), HTAIn illustrative ~$1,500.")
    ),
    mainPanel(
      plotOutput("thresholdPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "The exact same clinical trial and cost data can be 'cost-effective' under one ",
        "jurisdiction's WTP convention and 'not cost-effective' under another's \u2014 this is ",
        "not a flaw in the analysis, it reflects real differences in how much health ",
        "systems have decided they can afford to pay per QALY. Set \u0394C/\u0394E so the ICER ",
        "lands between the NICE upper bound and the WHO-CHOICE-style marker, and watch the ",
        "verdict genuinely differ by jurisdiction with not a single input number changed.")
    )
  )
)

server <- function(input, output, session) {

  jurisdictions <- data.frame(
    name = c("NICE lower", "NICE upper", "HTAIn (illustrative)", "WHO-CHOICE-style (1x GDPpc)"),
    threshold = c(27000, 41000, 1500, 75000)
  )

  results <- reactive({
    icer <- input$delta_c / input$delta_e
    nmb <- input$wtp * input$delta_e - input$delta_c
    list(icer = icer, nmb = nmb, cost_effective = nmb > 0)
  })

  output$thresholdPlot <- renderPlot({
    r <- results()
    wtp_grid <- seq(0, 150000, length.out = 200)
    nmb_grid <- wtp_grid * input$delta_e - input$delta_c

    ggplot(data.frame(wtp = wtp_grid, nmb = nmb_grid), aes(x = wtp, y = nmb)) +
      geom_line(color = "#2166ac", linewidth = 1.2) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
      geom_vline(xintercept = input$wtp, linetype = "dashed", color = "#d6604d") +
      geom_vline(data = jurisdictions, aes(xintercept = threshold), color = "grey50", linetype = "dotted") +
      geom_text(data = jurisdictions, aes(x = threshold, y = max(nmb_grid) * 0.9, label = name),
                angle = 90, vjust = -0.3, size = 3, color = "grey40") +
      labs(x = "WTP threshold ($/QALY)", y = "Net Monetary Benefit ($)",
           title = sprintf("NMB vs. WTP threshold (break-even ICER = $%s/QALY)",
                            format(round(r$icer), big.mark = ","))) +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    r <- results()
    verdict <- if (r$cost_effective) "COST-EFFECTIVE" else "NOT cost-effective"
    jur_verdicts <- sapply(seq_len(nrow(jurisdictions)), function(i) {
      th <- jurisdictions$threshold[i]
      ce <- th * input$delta_e - input$delta_c > 0
      sprintf("%s: %s", jurisdictions$name[i], if (ce) "yes" else "no")
    })
    sprintf(paste0("Break-even ICER = $%s/QALY. At your chosen WTP = $%s/QALY, NMB = $%s, so ",
                   "this is %s. Across the 4 illustrative jurisdiction markers: %s."),
            format(round(r$icer), big.mark = ","), format(input$wtp, big.mark = ","),
            format(round(r$nmb), big.mark = ","), verdict,
            paste(jur_verdicts, collapse = "; "))
  })
}

shinyApp(ui, server)
