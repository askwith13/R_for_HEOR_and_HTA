library(shiny)
library(ggplot2)
library(dplyr)

# Budget Impact Uptake/Price Explorer
# Companion to Chapter 35, SS35.4 (Case Study): sliders for a long-acting
# injectable's annual price, relapse-rate reduction, and a 5-year uptake
# trajectory recompute the year-by-year budget-impact table and
# cost-trajectory chart live, demonstrating that uptake speed -- not
# price -- is usually the dominant driver of 5-year net budget impact.

ui <- fluidPage(
  titlePanel("Budget Impact Uptake/Price Explorer"),
  p("Companion app for Chapter 35, \u00a735.4 (Case Study: Long-Acting ",
    "Injectable Budget Impact). A new long-acting injectable (LAI) ",
    "reduces relapse-related hospitalisation cost but has a higher ",
    "annual drug price than the standard of care (SoC). Drag the LAI's ",
    "annual price, its relapse-rate reduction, and a 5-year uptake ramp ",
    "speed, and watch the year-by-year budget impact recompute live --",
    "this app lets you discover for yourself whether price or uptake ",
    "speed dominates the net budget impact, rather than being told in ",
    "prose."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("lai_price", "LAI annual drug price ($)", 8000, 30000, 18000, step = 500),
      sliderInput("relapse_reduction", "LAI relapse-rate reduction (vs. SoC)", 0, 0.6, 0.35, step = 0.01),
      sliderInput("ramp_speed", "5-year uptake ramp speed (1 = slow linear, 5 = fast/front-loaded)", 1, 5, 2, step = 1),
      numericInput("eligible_population", "Eligible population size", value = 10000, min = 100),
      numericInput("soc_cost", "SoC annual total cost per patient ($, drug + relapse)", value = 9000, min = 0),
      numericInput("relapse_cost_per_event", "Cost per relapse hospitalisation event ($)", value = 15000, min = 0),
      numericInput("baseline_relapse_rate", "SoC baseline annual relapse rate", value = 0.3, min = 0, max = 1, step = 0.01)
    ),
    mainPanel(
      plotOutput("budgetPlot", height = "380px"),
      tableOutput("budgetTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A payer committee evaluating a new therapy often fixates on the PRICE per patient, since ",
        "that is the most visible, easily-compared number -- but the 5-year TOTAL budget impact is ",
        "also driven substantially by how fast the eligible population actually SWITCHES to the new ",
        "therapy (the uptake curve), not price alone. Try holding price fixed and dragging only the ",
        "ramp-speed slider, then holding ramp speed fixed and dragging only the price slider: in ",
        "this app's default parameterization the two levers can have COMPARABLE swings on the ",
        "5-year total, which is itself the point -- a committee that only sensitivity-tests price ",
        "and treats the uptake trajectory as a fixed assumption is leaving a comparably important ",
        "driver of budget risk unexamined.")
    )
  )
)

server <- function(input, output, session) {

  uptake_curve <- reactive({
    speed <- input$ramp_speed
    years <- 1:5
    # Front-loading increases with speed: speed=1 is linear, speed=5 is
    # steeply front-loaded (most uptake happens in years 1-2)
    raw <- years^(1 / speed)
    raw / max(raw)
  })

  budget_impact <- reactive({
    pop <- input$eligible_population
    uptake <- uptake_curve()
    lai_annual_cost <- input$lai_price +
      input$baseline_relapse_rate * (1 - input$relapse_reduction) * input$relapse_cost_per_event
    soc_annual_cost <- input$soc_cost

    n_on_lai <- pop * uptake
    n_on_soc <- pop - n_on_lai

    total_cost_with_lai <- n_on_lai * lai_annual_cost + n_on_soc * soc_annual_cost
    total_cost_soc_only <- pop * soc_annual_cost
    budget_impact <- total_cost_with_lai - total_cost_soc_only

    data.frame(year = 1:5, uptake_pct = uptake * 100, n_on_lai = round(n_on_lai),
               budget_impact = budget_impact)
  })

  output$budgetPlot <- renderPlot({
    df <- budget_impact()
    ggplot(df, aes(x = year, y = budget_impact)) +
      geom_col(fill = "#2166ac") +
      geom_text(aes(label = sprintf("$%s", format(round(budget_impact / 1e6, 1), nsmall = 1))), vjust = -0.5, size = 4) +
      labs(x = "Year", y = "Annual budget impact ($)",
           title = "Year-by-year budget impact (LAI vs. SoC-only baseline)") +
      theme_minimal(base_size = 13)
  })

  output$budgetTable <- renderTable({
    df <- budget_impact()
    df$budget_impact_millions <- round(df$budget_impact / 1e6, 2)
    df[, c("year", "uptake_pct", "n_on_lai", "budget_impact_millions")]
  }, digits = 1)

  output$interpretation <- renderText({
    df <- budget_impact()
    total_5yr <- sum(df$budget_impact)
    sprintf(paste0("At price=$%s, relapse reduction=%.0f%%, ramp speed=%d: 5-year cumulative ",
                   "budget impact = $%s million. The uptake curve reaches %.0f%% by year 5 ",
                   "(%.0f%% by year 2). Try changing ONLY the ramp-speed slider with price fixed, ",
                   "then changing ONLY the price slider with ramp speed fixed, and compare how much ",
                   "the 5-year total moves in each case."),
            format(input$lai_price, big.mark = ","), input$relapse_reduction * 100, input$ramp_speed,
            format(round(total_5yr / 1e6, 1), nsmall = 1), tail(df$uptake_pct, 1), df$uptake_pct[2])
  })
}

shinyApp(ui, server)
