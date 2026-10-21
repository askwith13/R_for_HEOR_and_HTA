library(shiny)
library(ggplot2)
library(dplyr)

# Validation Rule Threshold Tuner
# Companion to Chapter 5, SS5.6: sliders set bounds for each data-
# validation rule on a simulated cost_qaly_tbl extract; pass/fail
# counts update live, showing how loosening/tightening a rule changes
# what gets flagged.

ui <- fluidPage(
  titlePanel("Validation Rule Threshold Tuner"),
  p("Companion app for Chapter 5, \u00a75.6 (Data Import, Cleaning and ",
    "Validation). A simulated `cost_qaly_tbl` extract (500 patient ",
    "records) is checked against 3 validation rules: a plausible cost ",
    "range, a plausible QALY range, and a maximum relative change ",
    "between baseline and follow-up utility. Drag each rule's bounds and ",
    "watch the pass/fail counts and the flagged-record table update ",
    "live -- directly demonstrates the trade-off between a strict rule ",
    "(catches more genuine errors but also more false positives) and a ",
    "loose rule (misses real errors to avoid false positives)."),
  sidebarLayout(
    sidebarPanel(
      h4("Rule 1: plausible annual cost range"),
      sliderInput("cost_range", "Cost ($)", 0, 50000, c(500, 20000), step = 500),
      h4("Rule 2: plausible QALY range"),
      sliderInput("qaly_range", "QALY (per cycle)", 0, 1, c(0.1, 0.95), step = 0.01),
      h4("Rule 3: maximum plausible utility change (baseline to follow-up)"),
      sliderInput("max_util_change", "Max |delta utility|", 0, 1, 0.4, step = 0.01)
    ),
    mainPanel(
      plotOutput("validationPlot", height = "350px"),
      tableOutput("flaggedTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "There is no single 'correct' validation threshold -- tightening a rule to catch more ",
        "genuine data errors ALWAYS also flags more legitimate-but-unusual records as false ",
        "positives, and loosening it to reduce false positives ALWAYS lets more genuine errors ",
        "through silently. Watch the flagged-record count as you drag a rule's bounds: there is no ",
        "setting that minimizes both false positives and false negatives simultaneously -- the ",
        "'right' threshold depends on which error type costs more in your specific analysis, a ",
        "judgement call the rule's bounds alone cannot make for you.")
    )
  )
)

server <- function(input, output, session) {

  simulated_data <- reactive({
    set.seed(42)
    n <- 500
    cost <- rlnorm(n, meanlog = log(8000), sdlog = 0.6)
    qaly <- rbeta(n, 6, 2) # mostly high, plausible utilities
    baseline_util <- rbeta(n, 5, 3)
    followup_util <- pmin(pmax(baseline_util + rnorm(n, 0.05, 0.25), 0), 1)
    # Inject a handful of deliberate genuine errors for realism
    error_idx <- sample(seq_len(n), 15)
    cost[error_idx[1:5]] <- cost[error_idx[1:5]] * 20 # data-entry extra zero
    qaly[error_idx[6:10]] <- qaly[error_idx[6:10]] * -1 # sign flip error
    followup_util[error_idx[11:15]] <- 1 - followup_util[error_idx[11:15]] # transcription flip

    data.frame(id = seq_len(n), cost = cost, qaly = qaly,
               baseline_util = baseline_util, followup_util = followup_util,
               delta_util = followup_util - baseline_util)
  })

  validation_result <- reactive({
    df <- simulated_data()
    df$rule1_fail <- df$cost < input$cost_range[1] | df$cost > input$cost_range[2]
    df$rule2_fail <- df$qaly < input$qaly_range[1] | df$qaly > input$qaly_range[2]
    df$rule3_fail <- abs(df$delta_util) > input$max_util_change
    df$any_fail <- df$rule1_fail | df$rule2_fail | df$rule3_fail
    df
  })

  output$validationPlot <- renderPlot({
    df <- validation_result()
    counts <- data.frame(
      rule = c("Rule 1: cost range", "Rule 2: QALY range", "Rule 3: utility change", "Any rule failed"),
      fails = c(sum(df$rule1_fail), sum(df$rule2_fail), sum(df$rule3_fail), sum(df$any_fail))
    )
    ggplot(counts, aes(x = rule, y = fails, fill = rule)) +
      geom_col() +
      geom_text(aes(label = fails), vjust = -0.3, size = 5) +
      labs(x = NULL, y = "Records flagged", title = "Validation rule flag counts (out of 500 records)") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "none", axis.text.x = element_text(angle = 15, hjust = 1))
  })

  output$flaggedTable <- renderTable({
    df <- validation_result()
    flagged <- df[df$any_fail, c("id", "cost", "qaly", "delta_util")]
    head(flagged[order(-abs(flagged$delta_util)), ], 10)
  }, digits = 2)

  output$interpretation <- renderText({
    df <- validation_result()
    total_flagged <- sum(df$any_fail)
    sprintf(paste0("With current thresholds (cost %s, QALY %s, max |delta util| %.2f): ",
                   "%d of 500 records (%.1f%%) fail at least one rule. Rule 1 flags %d, Rule 2 ",
                   "flags %d, Rule 3 flags %d. Tighten any single rule and watch its own flag ",
                   "count rise -- but also check whether the newly-flagged records look like ",
                   "genuine errors or just unusual-but-valid patients."),
            paste0("$", format(input$cost_range[1], big.mark=","), "-$", format(input$cost_range[2], big.mark=",")),
            paste0(input$qaly_range[1], "-", input$qaly_range[2]), input$max_util_change,
            total_flagged, total_flagged / 5,
            sum(df$rule1_fail), sum(df$rule2_fail), sum(df$rule3_fail))
  })
}

shinyApp(ui, server)
