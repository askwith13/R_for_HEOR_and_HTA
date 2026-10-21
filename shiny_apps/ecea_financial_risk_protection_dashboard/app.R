library(shiny)
library(ggplot2)
library(dplyr)

# ECEA Financial Risk Protection Dashboard
# Companion to Chapter 24, SS24.3: sliders for the status-quo and new-
# policy out-of-pocket cost, the catastrophic-expenditure threshold (%),
# and the poverty line re-run an Extended Cost-Effectiveness Analysis
# financial-risk-protection function live across all five income
# quintiles, redrawing the CHE-cases-averted and poverty-cases-averted
# bar chart.

ui <- fluidPage(
  titlePanel("ECEA Financial Risk Protection Dashboard"),
  p("Companion app for Chapter 24, \u00a724.3 (Cost-Benefit, Distributional ",
    "and Extended Cost-Effectiveness Analysis). A new health policy ",
    "reduces out-of-pocket (OOP) cost relative to the status quo, for a ",
    "simulated population split into 5 income quintiles. Drag the OOP ",
    "costs, the catastrophic-health-expenditure (CHE) threshold (as a % ",
    "of income), and the poverty line, and watch cases of catastrophic ",
    "expenditure and impoverishment averted recompute live by quintile."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("oop_status_quo", "Status-quo out-of-pocket cost ($)", 50, 1000, 400, step = 25),
      sliderInput("oop_new_policy", "New-policy out-of-pocket cost ($)", 0, 1000, 100, step = 25),
      sliderInput("che_threshold", "Catastrophic expenditure threshold (% of income)", 5, 40, 10, step = 1),
      sliderInput("poverty_line", "Poverty line (annual income, $)", 500, 3000, 1200, step = 100)
    ),
    mainPanel(
      plotOutput("riskProtectionPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Financial risk protection benefits are NOT evenly distributed across income ",
        "quintiles for an identical dollar reduction in out-of-pocket cost -- the same $300 ",
        "OOP reduction can push many poorest-quintile households below the catastrophic-",
        "expenditure threshold while barely registering for the richest quintile, whose ",
        "spending was never close to that threshold either way. Push the poverty line and CHE ",
        "threshold to different levels and watch which quintiles see the largest 'cases ",
        "averted' bars shift -- a standard cost-effectiveness analysis that reports only a ",
        "population-average ICER misses this distributional story entirely.")
    )
  )
)

server <- function(input, output, session) {

  quintile_incomes <- c(800, 1500, 2500, 4000, 7000) # illustrative annual income by quintile

  ecea_frp <- reactive({
    oop_sq <- input$oop_status_quo
    oop_new <- input$oop_new_policy
    che_thresh <- input$che_threshold / 100
    poverty <- input$poverty_line
    n_per_quintile <- 1000 # illustrative population size per quintile

    results <- lapply(seq_along(quintile_incomes), function(q) {
      income <- quintile_incomes[q]
      che_sq <- oop_sq / income > che_thresh
      che_new <- oop_new / income > che_thresh
      che_averted <- as.integer(che_sq & !che_new) * n_per_quintile

      impov_sq <- (income - oop_sq) < poverty
      impov_new <- (income - oop_new) < poverty
      poverty_averted <- as.integer(impov_sq & !impov_new) * n_per_quintile

      data.frame(quintile = q, income = income, che_averted = che_averted, poverty_averted = poverty_averted)
    })
    do.call(rbind, results)
  })

  output$riskProtectionPlot <- renderPlot({
    df <- ecea_frp()
    df_long <- data.frame(
      quintile = rep(df$quintile, 2),
      cases_averted = c(df$che_averted, df$poverty_averted),
      type = rep(c("Catastrophic expenditure averted", "Impoverishment averted"), each = nrow(df))
    )
    df_long$quintile <- factor(df_long$quintile, labels = paste("Q", 1:5, "(poorest to richest)"))

    ggplot(df_long, aes(x = quintile, y = cases_averted, fill = type)) +
      geom_col(position = "dodge") +
      scale_fill_manual(values = c("Catastrophic expenditure averted" = "#2166ac",
                                    "Impoverishment averted" = "#d6604d"), name = NULL) +
      labs(x = "Income quintile", y = "Cases averted per 1,000 households",
           title = "Financial risk protection: cases averted by income quintile") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top", axis.text.x = element_text(angle = 15, hjust = 1))
  })

  output$interpretation <- renderText({
    df <- ecea_frp()
    total_che <- sum(df$che_averted)
    total_poverty <- sum(df$poverty_averted)
    best_che_q <- df$quintile[which.max(df$che_averted)]
    best_pov_q <- df$quintile[which.max(df$poverty_averted)]

    sprintf(paste0("At OOP cost $%d \u2192 $%d (threshold %d%% of income, poverty line $%d): %d total ",
                   "catastrophic-expenditure cases averted per 1,000 households per quintile, ",
                   "%d impoverishment cases averted. The largest catastrophic-expenditure effect ",
                   "is in quintile %d; the largest impoverishment effect is in quintile %d -- ",
                   "these benefits are concentrated in specific income bands, not spread evenly ",
                   "across the population."),
            input$oop_status_quo, input$oop_new_policy, input$che_threshold, input$poverty_line,
            total_che, total_poverty, best_che_q, best_pov_q)
  })
}

shinyApp(ui, server)
