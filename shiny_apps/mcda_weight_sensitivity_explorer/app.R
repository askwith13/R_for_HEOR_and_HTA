library(shiny)
library(ggplot2)
library(dplyr)

# MCDA Weight Sensitivity Explorer
# Companion to Chapter 24, SS24.4: four sliders (one per criterion,
# constrained to sum to 1) re-run a mcda_weighted_score()-style function
# live against a three-drug example, instantly re-ranking the drugs and
# showing how close the ranking is to flipping.

ui <- fluidPage(
  titlePanel("MCDA Weight Sensitivity Explorer"),
  p("Companion app for Chapter 24, \u00a724.4 (Cost-Benefit, Distributional ",
    "and Extended Cost-Effectiveness Analysis). Three drugs are scored on ",
    "4 criteria (efficacy, safety, severity-of-condition-treated, ",
    "economic value), each 0-10. Drag the 4 criterion weights (which ",
    "auto-normalise to sum to 1) and watch the weighted ranking update ",
    "live -- directly operationalizes the chapter's pitfall box that ",
    "every MCDA result should be accompanied by a weight-sensitivity ",
    "analysis."),
  sidebarLayout(
    sidebarPanel(
      h4("Criterion weights (raw sliders, auto-normalised to sum to 1)"),
      sliderInput("w_efficacy", "Efficacy", 0, 10, 4, step = 0.5),
      sliderInput("w_safety", "Safety", 0, 10, 3, step = 0.5),
      sliderInput("w_severity", "Severity of condition treated", 0, 10, 2, step = 0.5),
      sliderInput("w_economic", "Economic value", 0, 10, 1, step = 0.5),
      verbatimTextOutput("normalizedWeights")
    ),
    mainPanel(
      tableOutput("scoresTable"),
      plotOutput("rankPlot", height = "350px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A single MCDA ranking, reported with one fixed set of weights, hides how much the ",
        "weight CHOICE itself is driving the result. Try moving from 'efficacy-dominant' ",
        "weighting (efficacy slider high, others low) to 'economic-value-dominant' weighting ",
        "-- if the top-ranked drug changes, the committee's final decision depends critically ",
        "on a largely subjective weight-elicitation exercise, not purely on the underlying ",
        "clinical/economic evidence. Every MCDA report should show this kind of weight-",
        "sensitivity exploration, not just the single base-case ranking.")
    )
  )
)

# Fixed criterion scores for 3 drugs (0-10 scale)
drug_scores <- data.frame(
  drug = c("Drug A", "Drug B", "Drug C"),
  efficacy = c(8, 6, 7),
  safety = c(5, 9, 6),
  severity = c(7, 7, 9),
  economic = c(4, 7, 5)
)

server <- function(input, output, session) {

  normalized_weights <- reactive({
    raw <- c(efficacy = input$w_efficacy, safety = input$w_safety,
             severity = input$w_severity, economic = input$w_economic)
    if (sum(raw) == 0) raw <- rep(1, 4)
    raw / sum(raw)
  })

  output$normalizedWeights <- renderPrint({
    w <- normalized_weights()
    cat("Normalised weights (sum to 1):\n")
    for (nm in names(w)) cat(sprintf("  %s: %.3f\n", nm, w[nm]))
  })

  mcda_scores <- reactive({
    w <- normalized_weights()
    drug_scores$weighted_score <- w["efficacy"] * drug_scores$efficacy +
      w["safety"] * drug_scores$safety +
      w["severity"] * drug_scores$severity +
      w["economic"] * drug_scores$economic
    drug_scores[order(-drug_scores$weighted_score), ]
  })

  output$scoresTable <- renderTable({
    df <- mcda_scores()
    df$rank <- seq_len(nrow(df))
    df[, c("rank", "drug", "efficacy", "safety", "severity", "economic", "weighted_score")]
  }, digits = 3)

  output$rankPlot <- renderPlot({
    df <- mcda_scores()
    df$drug <- factor(df$drug, levels = rev(df$drug))
    ggplot(df, aes(x = weighted_score, y = drug, fill = drug)) +
      geom_col(width = 0.5) +
      geom_text(aes(label = sprintf("%.2f", weighted_score)), hjust = -0.2, size = 5) +
      labs(x = "Weighted MCDA score", y = NULL, title = "Current ranking") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "none")
  })

  output$interpretation <- renderText({
    df <- mcda_scores()
    top_drug <- df$drug[1]
    gap_1_2 <- df$weighted_score[1] - df$weighted_score[2]
    w <- normalized_weights()
    dominant_criterion <- names(w)[which.max(w)]
    sprintf(paste0("With weights (efficacy=%.2f, safety=%.2f, severity=%.2f, economic=%.2f), ",
                   "'%s' is currently ranked first, by a margin of %.2f points over second place. ",
                   "The dominant criterion in this weighting is '%s'. %s"),
            w["efficacy"], w["safety"], w["severity"], w["economic"], top_drug, gap_1_2, dominant_criterion,
            if (gap_1_2 < 0.5) "This is a NARROW margin -- the ranking is sensitive to small weight changes." else "This is a comfortable margin -- the ranking is relatively robust to small weight changes.")
  })
}

shinyApp(ui, server)
