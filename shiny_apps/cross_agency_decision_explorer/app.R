library(shiny)
library(ggplot2)

# Cross-Agency Decision Explorer
# Companion to Chapter 31, SS31.5: pick an HTA agency and vary an ICER
# value; the app shows live whether that ICER falls below/above each
# agency's stated or inferred WTP threshold -- making visible that the
# same ICER can be acceptable in one jurisdiction and inconclusive or
# unacceptable in another.

agency_thresholds <- data.frame(
  agency = c("NICE (England)", "CADTH (Canada)", "PBAC (Australia)",
             "ICER (USA, value framework)", "HTAIn (India)", "IQWiG/G-BA (Germany)"),
  threshold_low = c(20000, 50000, 30000, 100000, 1000, NA),
  threshold_high = c(30000, 50000, 60000, 150000, 1500, NA),
  uses_fixed_threshold = c(TRUE, TRUE, FALSE, TRUE, TRUE, FALSE),
  note = c(
    "Standard range; higher acceptable for end-of-life/highly specialised tech",
    "Single reference value commonly cited",
    "No single published number; implicit range from past decisions",
    "Value-based pricing benchmark, not a binding cutoff",
    "India's HTAIn proposes per-capita-GDP-linked range (illustrative)",
    "No cost-effectiveness threshold used by design -- efficiency frontier approach instead"
  )
)

ui <- fluidPage(
  titlePanel("Cross-Agency Decision Explorer"),
  p("Companion app for Chapter 31, \u00a731.5 (Agency Requirements and Reference ",
    "Cases). Pick an ICER value and see, live, whether it would clear each ",
    "HTA agency's stated or inferred willingness-to-pay threshold -- the ",
    "same number can mean a very different verdict depending on which ",
    "agency is reading it."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("icer", "ICER ($/QALY)", 0, 200000, 45000, step = 1000),
      helpText("Note: IQWiG/G-BA deliberately uses no single cost-effectiveness ",
               "threshold -- shown as 'no fixed threshold by design', not a ",
               "missing data point.")
    ),
    mainPanel(
      plotOutput("agencyPlot", height = "400px"),
      tableOutput("agencyTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "There is no single 'cost-effective' verdict that travels across jurisdictions ",
        "-- the same ICER can clear NICE's threshold comfortably while failing CADTH's, ",
        "or vice versa, and some agencies (IQWiG/G-BA) do not use a fixed threshold at ",
        "all, making 'is it cost-effective' the wrong question to ask of their process. ",
        "Drag the ICER to $45,000 and compare NICE (likely acceptable) against ICER-USA's ",
        "framework (likely below its own, much higher, threshold) -- global trial evidence ",
        "does not imply a global reimbursement verdict.")
    )
  )
)

server <- function(input, output, session) {

  verdicts <- reactive({
    icer <- input$icer
    agency_thresholds$verdict <- mapply(function(low, high, uses_fixed) {
      if (!uses_fixed || is.na(low)) {
        "No fixed threshold by design"
      } else if (icer <= low) {
        "Cost-effective"
      } else if (icer <= high) {
        "Borderline / case-by-case"
      } else {
        "Not cost-effective at standard threshold"
      }
    }, agency_thresholds$threshold_low, agency_thresholds$threshold_high, agency_thresholds$uses_fixed_threshold)
    agency_thresholds
  })

  output$agencyPlot <- renderPlot({
    df <- verdicts()
    df_plot <- df[!is.na(df$threshold_low), ]
    df_plot$agency <- factor(df_plot$agency, levels = rev(df_plot$agency))

    ggplot(df_plot) +
      geom_segment(aes(x = threshold_low, xend = threshold_high, y = agency, yend = agency),
                   linewidth = 8, color = "#9ecae1") +
      geom_vline(xintercept = input$icer, linetype = "dashed", color = "#d6604d", linewidth = 1) +
      labs(x = "WTP threshold range ($/QALY)", y = NULL,
           title = "Agency WTP threshold ranges vs. current ICER",
           subtitle = "Dashed red line: your chosen ICER. Blue bars: each agency's threshold range.") +
      theme_minimal(base_size = 13)
  })

  output$agencyTable <- renderTable({
    df <- verdicts()
    data.frame(Agency = df$agency, Verdict = df$verdict, Note = df$note)
  })

  output$interpretation <- renderText({
    df <- verdicts()
    n_ce <- sum(df$verdict == "Cost-effective")
    n_not <- sum(df$verdict == "Not cost-effective at standard threshold")
    n_border <- sum(df$verdict == "Borderline / case-by-case")
    sprintf(paste0("At ICER = $%s/QALY: %d of the 6 listed agencies/frameworks would likely call ",
                   "this cost-effective, %d borderline, %d not cost-effective at their standard ",
                   "threshold, and the remaining agency (IQWiG/G-BA) would not frame the question ",
                   "this way at all. The same clinical and economic evidence can legitimately ",
                   "receive different reimbursement decisions in different jurisdictions."),
            format(input$icer, big.mark = ","), n_ce, n_border, n_not)
  })
}

shinyApp(ui, server)
