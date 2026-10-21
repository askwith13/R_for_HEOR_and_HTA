library(shiny)
library(ggplot2)

# SoC vs. DMT Live ICER Dashboard
# Companion to Chapter 19, SS19.10: a 3-state (Well/Diseased/Dead) Markov
# cohort model comparing Standard of Care against a Disease-Modifying
# Therapy. Sliders for each arm's transition probabilities, state costs,
# state utilities, and the discount rate recompute the full discounted
# 10-year cost/QALY totals and ICER live.

N_CYCLES <- 10 # years
STATES <- c("Well", "Diseased", "Dead")

run_markov <- function(p_well_diseased, p_diseased_dead, p_well_dead,
                        cost_well, cost_diseased, util_well, util_diseased,
                        discount_rate) {
  P <- matrix(0, nrow = 3, ncol = 3, dimnames = list(STATES, STATES))
  P["Well", "Diseased"] <- p_well_diseased
  P["Well", "Dead"] <- p_well_dead
  P["Well", "Well"] <- 1 - p_well_diseased - p_well_dead
  P["Diseased", "Dead"] <- p_diseased_dead
  P["Diseased", "Diseased"] <- 1 - p_diseased_dead
  P["Dead", "Dead"] <- 1

  trace <- matrix(0, nrow = N_CYCLES + 1, ncol = 3, dimnames = list(NULL, STATES))
  trace[1, ] <- c(1, 0, 0)
  for (t in 2:(N_CYCLES + 1)) {
    trace[t, ] <- trace[t - 1, ] %*% P
  }

  costs_per_cycle <- trace[, "Well"] * cost_well + trace[, "Diseased"] * cost_diseased
  qalys_per_cycle <- trace[, "Well"] * util_well + trace[, "Diseased"] * util_diseased

  disc_factors <- 1 / (1 + discount_rate) ^ (0:N_CYCLES)
  disc_cost <- sum(costs_per_cycle * disc_factors)
  disc_qaly <- sum(qalys_per_cycle * disc_factors)

  list(trace = trace, disc_cost = disc_cost, disc_qaly = disc_qaly)
}

ui <- fluidPage(
  titlePanel("SoC vs. DMT Live ICER Dashboard"),
  p("Companion app for Chapter 19, \u00a719.10 (Markov Cohort Models). ",
    "A 3-state Well/Diseased/Dead cohort model compares Standard of Care ",
    "(SoC) against a Disease-Modifying Therapy (DMT) over a 10-year horizon. ",
    "Every slider recomputes the discounted cost/QALY totals and ICER live."),
  sidebarLayout(
    sidebarPanel(
      h4("Standard of Care (SoC)"),
      sliderInput("soc_p_wd", "P(Well\u2192Diseased)", 0, 0.5, 0.15, step = 0.01),
      sliderInput("soc_p_dd", "P(Diseased\u2192Dead)", 0, 0.5, 0.10, step = 0.01),
      sliderInput("soc_cost_w", "Cost per cycle, Well", 0, 5000, 500, step = 50),
      sliderInput("soc_cost_d", "Cost per cycle, Diseased", 0, 20000, 4000, step = 100),
      sliderInput("soc_util_w", "Utility, Well", 0, 1, 0.90, step = 0.01),
      sliderInput("soc_util_d", "Utility, Diseased", 0, 1, 0.60, step = 0.01),
      hr(),
      h4("Disease-Modifying Therapy (DMT)"),
      sliderInput("dmt_p_wd", "P(Well\u2192Diseased)", 0, 0.5, 0.08, step = 0.01),
      sliderInput("dmt_p_dd", "P(Diseased\u2192Dead)", 0, 0.5, 0.10, step = 0.01),
      sliderInput("dmt_cost_w", "Cost per cycle, Well", 0, 20000, 8000, step = 100),
      sliderInput("dmt_cost_d", "Cost per cycle, Diseased", 0, 20000, 4000, step = 100),
      sliderInput("dmt_util_w", "Utility, Well", 0, 1, 0.90, step = 0.01),
      sliderInput("dmt_util_d", "Utility, Diseased", 0, 1, 0.60, step = 0.01),
      hr(),
      sliderInput("p_wd_shared", "P(Well\u2192Dead), both arms", 0, 0.05, 0.01, step = 0.001),
      sliderInput("discount_rate", "Annual discount rate", 0, 0.08, 0.035, step = 0.005)
    ),
    mainPanel(
      fluidRow(
        column(6, h4("Results"), tableOutput("resultsTable")),
        column(6, h4("ICER"), verbatimTextOutput("icerOut"))
      ),
      plotOutput("cePlanePlot", height = "400px")
    )
  )
)

server <- function(input, output, session) {

  soc <- reactive({
    run_markov(input$soc_p_wd, input$soc_p_dd, input$p_wd_shared,
               input$soc_cost_w, input$soc_cost_d,
               input$soc_util_w, input$soc_util_d, input$discount_rate)
  })
  dmt <- reactive({
    run_markov(input$dmt_p_wd, input$dmt_p_dd, input$p_wd_shared,
               input$dmt_cost_w, input$dmt_cost_d,
               input$dmt_util_w, input$dmt_util_d, input$discount_rate)
  })

  output$resultsTable <- renderTable({
    data.frame(
      Arm = c("SoC", "DMT"),
      `Discounted cost` = c(soc()$disc_cost, dmt()$disc_cost),
      `Discounted QALYs` = c(soc()$disc_qaly, dmt()$disc_qaly),
      check.names = FALSE
    )
  }, digits = 2)

  output$icerOut <- renderPrint({
    dc <- dmt()$disc_cost - soc()$disc_cost
    dq <- dmt()$disc_qaly - soc()$disc_qaly
    if (abs(dq) < 1e-9) {
      cat("Incremental QALYs ~ 0: ICER undefined\n")
    } else {
      icer <- dc / dq
      cat(sprintf("Incremental cost:  %.2f\n", dc))
      cat(sprintf("Incremental QALYs: %.4f\n", dq))
      cat(sprintf("ICER:              %.2f per QALY\n", icer))
      if (dc < 0 && dq > 0) cat("DMT dominates SoC (cheaper and more effective)\n")
      if (dc > 0 && dq < 0) cat("DMT is dominated by SoC (costlier and less effective)\n")
    }
  })

  output$cePlanePlot <- renderPlot({
    dc <- dmt()$disc_cost - soc()$disc_cost
    dq <- dmt()$disc_qaly - soc()$disc_qaly
    df <- data.frame(x = dq, y = dc)
    ggplot(df, aes(x = x, y = y)) +
      geom_point(size = 5, color = "#2166ac") +
      geom_hline(yintercept = 0, linetype = "dashed") +
      geom_vline(xintercept = 0, linetype = "dashed") +
      labs(x = "Incremental QALYs (DMT \u2212 SoC)", y = "Incremental cost (DMT \u2212 SoC)",
           title = "Cost-effectiveness plane") +
      theme_minimal(base_size = 13)
  })
}

shinyApp(ui, server)
