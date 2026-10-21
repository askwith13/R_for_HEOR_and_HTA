library(shiny)
library(ggplot2)
library(dplyr)

# Toy Regimen ICER Explorer
# Companion to Chapter 17, SS17.6: sliders for cost_drug and p_cure for
# Regimen A/B feed the chapter's own skeletal run_model() function; the
# ICER/NMB table recalculates live as any input varies -- a minimal
# demonstration of why separating inputs/engine/results layers matters.

run_model <- function(cost_drug, p_cure, cost_relapse = 5000, qaly_cured = 1.0, qaly_relapse = 0.6) {
  exp_cost <- cost_drug + (1 - p_cure) * cost_relapse
  exp_qaly <- p_cure * qaly_cured + (1 - p_cure) * qaly_relapse
  list(cost = exp_cost, qaly = exp_qaly)
}

ui <- fluidPage(
  titlePanel("Toy Regimen ICER Explorer"),
  p("Companion app for Chapter 17, \u00a717.6 (Principles of Decision ",
    "Modelling). The chapter's own skeletal `run_model()` function -- ",
    "separated cleanly into inputs/engine/results layers -- is fed live ",
    "slider values for Regimen A and Regimen B's drug cost and cure ",
    "probability, with the ICER/NMB table recalculating on every change."),
  sidebarLayout(
    sidebarPanel(
      h4("Regimen A"),
      sliderInput("cost_a", "Drug cost (Regimen A)", 100, 5000, 800, step = 50),
      sliderInput("p_cure_a", "Cure probability (Regimen A)", 0.3, 0.95, 0.65, step = 0.01),
      hr(),
      h4("Regimen B"),
      sliderInput("cost_b", "Drug cost (Regimen B)", 100, 5000, 2200, step = 50),
      sliderInput("p_cure_b", "Cure probability (Regimen B)", 0.3, 0.95, 0.85, step = 0.01),
      hr(),
      sliderInput("wtp", "WTP threshold ($/QALY)", 0, 100000, 50000, step = 1000)
    ),
    mainPanel(
      tableOutput("resultsTable"),
      plotOutput("cePlot", height = "350px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Separating a model into distinct inputs/engine/results layers (exactly what ",
        "`run_model()` does here) isn't just tidy code style -- it's what makes an app like ",
        "this one possible at all. Because `run_model()` takes cost_drug and p_cure as plain ",
        "arguments rather than hard-coded values, every slider move here is simply a fresh ",
        "function call with new inputs, with zero duplicated logic between the base case and ",
        "any sensitivity scenario. A model where inputs are hard-coded inline cannot be ",
        "explored this way without copy-pasting and editing code for every scenario.")
    )
  )
)

server <- function(input, output, session) {

  results <- reactive({
    a <- run_model(input$cost_a, input$p_cure_a)
    b <- run_model(input$cost_b, input$p_cure_b)
    dc <- b$cost - a$cost
    dq <- b$qaly - a$qaly
    icer <- if (abs(dq) > 1e-9) dc / dq else NA
    nmb_a <- input$wtp * a$qaly - a$cost
    nmb_b <- input$wtp * b$qaly - b$cost
    list(a = a, b = b, dc = dc, dq = dq, icer = icer, nmb_a = nmb_a, nmb_b = nmb_b)
  })

  output$resultsTable <- renderTable({
    r <- results()
    data.frame(
      Regimen = c("A", "B"),
      `Expected cost` = c(r$a$cost, r$b$cost),
      `Expected QALYs` = c(r$a$qaly, r$b$qaly),
      NMB = c(r$nmb_a, r$nmb_b),
      check.names = FALSE
    )
  }, digits = 2)

  output$cePlot <- renderPlot({
    r <- results()
    df <- data.frame(regimen = c("A", "B"), cost = c(r$a$cost, r$b$cost), qaly = c(r$a$qaly, r$b$qaly))
    ggplot(df, aes(x = qaly, y = cost, label = regimen)) +
      geom_point(size = 6, color = c("#2166ac", "#d6604d")) +
      geom_text(vjust = -1, size = 5) +
      geom_segment(aes(x = r$a$qaly, y = r$a$cost, xend = r$b$qaly, yend = r$b$cost),
                   linetype = "dashed", color = "grey50") +
      labs(x = "Expected QALYs", y = "Expected cost", title = "Regimen A vs. B") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    r <- results()
    verdict <- if (!is.na(r$icer)) {
      if (r$dc < 0 && r$dq > 0) "B dominates A (cheaper AND more effective)"
      else if (r$dc > 0 && r$dq < 0) "B is dominated by A (costlier AND less effective)"
      else sprintf("ICER of B vs. A = $%.0f/QALY, %s at the chosen WTP",
                    r$icer, if (r$nmb_b > r$nmb_a) "favouring B" else "favouring A")
    } else {
      "ICER undefined (QALYs essentially equal)"
    }
    sprintf(paste0("Regimen A: $%.0f, %.3f QALYs (NMB=$%.0f). Regimen B: $%.0f, %.3f QALYs ",
                   "(NMB=$%.0f). %s."),
            r$a$cost, r$a$qaly, r$nmb_a, r$b$cost, r$b$qaly, r$nmb_b, verdict)
  })
}

shinyApp(ui, server)
