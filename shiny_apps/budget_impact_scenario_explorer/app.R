library(shiny)
library(ggplot2)
library(dplyr)

# Budget Impact Scenario Explorer
# Companion to Chapter 23, SS23.2-23.4: sliders for terminal uptake share,
# new-drug list price, and the per-patient hospitalization offset drive a
# live re-run of a build_bia()-style function, recomputing year-by-year and
# cumulative budget impact -- showing the non-linear interaction between
# uptake-curve shape and net price in determining WHEN cumulative spend
# crosses a given affordability threshold.

build_bia <- function(eligible_per_year, terminal_uptake, uptake_shape,
                       soc_cost, new_drug_price, hosp_offset, years = 5) {
  if (uptake_shape == "linear") {
    uptake <- seq(terminal_uptake / years, terminal_uptake, length.out = years)
  } else {
    # logistic ramp toward terminal_uptake
    x <- seq(-3, 3, length.out = years)
    logistic <- 1 / (1 + exp(-x))
    uptake <- logistic / max(logistic) * terminal_uptake
  }

  new_drug_net_cost <- new_drug_price - hosp_offset
  patients_on_new <- eligible_per_year * uptake
  patients_on_soc <- eligible_per_year * (1 - uptake)

  cost_new_scenario <- patients_on_new * new_drug_net_cost + patients_on_soc * soc_cost
  cost_reference <- eligible_per_year * soc_cost
  budget_impact <- cost_new_scenario - cost_reference

  data.frame(year = 1:years, uptake = uptake,
             budget_impact = budget_impact,
             cumulative = cumsum(budget_impact))
}

ui <- fluidPage(
  titlePanel("Budget Impact Scenario Explorer"),
  p("Companion app for Chapter 23, \u00a723.2\u201323.4 (Budget Impact Analysis). ",
    "A 5-year budget impact model recomputes live as you vary the terminal ",
    "uptake share, the new drug's list price, and the per-patient ",
    "hospitalization offset it displaces. Watch how uptake-curve SHAPE, not ",
    "just terminal uptake level, changes when cumulative spend crosses a ",
    "given affordability threshold."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("terminal_uptake", "Terminal uptake share (year 5)", 0.1, 1.0, 0.55, step = 0.05),
      radioButtons("uptake_shape", "Uptake curve shape",
                   choices = c("Linear" = "linear", "Logistic (slow start, fast middle)" = "logistic"),
                   selected = "linear"),
      sliderInput("new_drug_price", "New drug gross price (per patient-year)",
                  500, 10000, 2000, step = 100),
      sliderInput("hosp_offset", "Hospitalization cost offset (per patient-year)",
                  0, 2000, 300, step = 50),
      sliderInput("eligible", "Eligible population per year", 1000, 50000, 10000, step = 500),
      sliderInput("threshold", "Affordability threshold (cumulative $)",
                  1000000, 50000000, 10000000, step = 500000)
    ),
    mainPanel(
      plotOutput("bitPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Budget impact is NOT the gross spend on the new drug \u2014 it's the net ",
        "change versus what the payer would already have spent on displaced ",
        "existing therapy. A high new-drug price can still produce a modest ",
        "budget impact if the hospitalization offset is large; conversely a ",
        "cheap drug with no real offset can still blow the budget at high ",
        "uptake. Try pushing the hospitalization offset toward the new drug's ",
        "own price \u2014 watch the cumulative impact line flatten or even go ",
        "negative (net savings), even though gross new-drug spend keeps rising.")
    )
  )
)

server <- function(input, output, session) {

  bia_result <- reactive({
    build_bia(
      eligible_per_year = input$eligible,
      terminal_uptake = input$terminal_uptake,
      uptake_shape = input$uptake_shape,
      soc_cost = 500,
      new_drug_price = input$new_drug_price,
      hosp_offset = input$hosp_offset
    )
  })

  output$bitPlot <- renderPlot({
    df <- bia_result()
    df_long <- data.frame(
      year = rep(df$year, 2),
      value = c(df$budget_impact, df$cumulative),
      series = rep(c("Annual budget impact", "Cumulative budget impact"), each = nrow(df))
    )
    ggplot(df_long, aes(x = year, y = value, fill = series)) +
      geom_col(data = subset(df_long, series == "Annual budget impact"), width = 0.5) +
      geom_line(data = subset(df_long, series == "Cumulative budget impact"),
                aes(color = series), linewidth = 1.2, inherit.aes = TRUE) +
      geom_hline(yintercept = input$threshold, linetype = "dashed", color = "#d6604d") +
      scale_fill_manual(values = c("Annual budget impact" = "#9ecae1"), name = NULL) +
      scale_color_manual(values = c("Cumulative budget impact" = "#2166ac"), name = NULL) +
      labs(x = "Year", y = "Budget impact ($)",
           title = "Annual (bars) and cumulative (line) budget impact",
           subtitle = "Dashed line: affordability threshold") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$interpretation <- renderText({
    df <- bia_result()
    crossing_year <- which(df$cumulative > input$threshold)[1]
    crossing_txt <- if (is.na(crossing_year)) {
      sprintf("Cumulative budget impact never crosses the $%s threshold within 5 years.",
              format(input$threshold, big.mark = ","))
    } else {
      sprintf("Cumulative budget impact crosses the $%s threshold in year %d.",
              format(input$threshold, big.mark = ","), crossing_year)
    }
    sprintf(paste0("Year 1 budget impact: $%s. Year 5 budget impact: $%s. 5-year cumulative: $%s. %s"),
            format(round(df$budget_impact[1]), big.mark = ","),
            format(round(df$budget_impact[5]), big.mark = ","),
            format(round(df$cumulative[5]), big.mark = ","),
            crossing_txt)
  })
}

shinyApp(ui, server)
