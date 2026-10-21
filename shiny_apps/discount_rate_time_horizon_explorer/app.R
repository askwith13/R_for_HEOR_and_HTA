library(shiny)
library(ggplot2)

# Discount Rate & Time Horizon Explorer
# Companion to Chapter 4, SS4.6: sliders for discount rate and time
# horizon show the present-value decay curve update live, with
# NICE/CADTH/HTAIn-style preset convention buttons, making the equal- vs
# differential-discounting debate concrete.

ui <- fluidPage(
  titlePanel("Discount Rate & Time Horizon Explorer"),
  p("Companion app for Chapter 4, \u00a74.6 (Core Concepts in Health ",
    "Economics). A fixed annual benefit stream is discounted back to ",
    "present value over a chosen horizon and rate; drag the rate or ",
    "horizon, or click a jurisdictional preset, and watch total present ",
    "value change live."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("rate", "Annual discount rate", 0, 0.1, 0.035, step = 0.005),
      sliderInput("horizon", "Time horizon (years)", 5, 50, 20, step = 1),
      hr(),
      h4("Jurisdictional presets"),
      actionButton("preset_nice", "NICE (England): 3.5%"),
      actionButton("preset_cadth", "CADTH (Canada): 1.5%"),
      actionButton("preset_htain", "HTAIn (India): 3%"),
      helpText("Clicking a preset sets the discount rate to that ",
               "jurisdiction's conventional value, leaving the horizon ",
               "unchanged.")
    ),
    mainPanel(
      plotOutput("discountPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Discounting matters most for benefits far in the future \u2014 a long-horizon, ",
        "upfront-cost intervention (e.g. a one-time curative therapy with lifetime ",
        "benefit) is penalised more heavily by a HIGHER discount rate than a short-horizon ",
        "intervention. Compare the CADTH preset (1.5%) against the NICE preset (3.5%) at a ",
        "50-year horizon \u2014 the total present-value gap between them is far larger than at ",
        "a 5-year horizon, which is exactly why the choice of discount rate is itself a ",
        "contested policy decision for long-horizon curative/preventive interventions, not ",
        "a neutral technical parameter.")
    )
  )
)

server <- function(input, output, session) {

  rv <- reactiveValues(rate = 0.035)

  observeEvent(input$preset_nice, { updateSliderInput(session, "rate", value = 0.035) })
  observeEvent(input$preset_cadth, { updateSliderInput(session, "rate", value = 0.015) })
  observeEvent(input$preset_htain, { updateSliderInput(session, "rate", value = 0.03) })

  pv_data <- reactive({
    years <- 1:input$horizon
    annual_benefit <- 1000 # fixed annual benefit, arbitrary units
    discount_factor <- 1 / (1 + input$rate)^years
    pv <- annual_benefit * discount_factor
    data.frame(year = years, annual_benefit = annual_benefit,
               discount_factor = discount_factor, pv = pv)
  })

  output$discountPlot <- renderPlot({
    df <- pv_data()
    ggplot(df, aes(x = year, y = pv)) +
      geom_col(fill = "#2166ac") +
      geom_hline(yintercept = 1000, linetype = "dashed", color = "grey50") +
      labs(x = "Year", y = "Present value of that year's $1,000 benefit",
           title = sprintf("Discounted value of a constant $1,000/year benefit at %.1f%% over %d years",
                            input$rate * 100, input$horizon),
           subtitle = "Dashed line: undiscounted $1,000 for reference") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    df <- pv_data()
    total_pv <- sum(df$pv)
    total_undiscounted <- 1000 * input$horizon
    pct_lost <- (total_undiscounted - total_pv) / total_undiscounted * 100
    last_year_pv <- tail(df$pv, 1)
    sprintf(paste0("At %.1f%% discount rate over %d years: total present value = $%s, vs. ",
                   "$%s undiscounted \u2014 discounting has eroded %.1f%% of the nominal total. ",
                   "The final year's $1,000 benefit is worth only $%.0f in present-value terms, ",
                   "showing how much more heavily discounting penalises far-future benefit ",
                   "compared to near-term benefit."),
            input$rate * 100, input$horizon, format(round(total_pv), big.mark = ","),
            format(total_undiscounted, big.mark = ","), pct_lost, last_year_pv)
  })
}

shinyApp(ui, server)
