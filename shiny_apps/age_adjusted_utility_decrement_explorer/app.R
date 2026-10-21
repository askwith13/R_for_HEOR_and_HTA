library(shiny)
library(ggplot2)
library(dplyr)

# Age-Adjusted Utility & Decrement Explorer
# Companion to Chapter 8, SS8.5: sliders for baseline utility, decrement
# size, and an additive-vs-multiplicative toggle, plus a horizon selector,
# replot the utility trajectory live -- showing additive adjustment
# drifting toward implausible/negative values over a long horizon while
# multiplicative compresses toward (not past) zero.

ui <- fluidPage(
  titlePanel("Age-Adjusted Utility & Decrement Explorer"),
  p("Companion app for Chapter 8, \u00a78.5 (Health-Related Quality of Life ",
    "and Utilities). A chronic condition applies a fixed per-year ",
    "disutility decrement on top of general-population age-related ",
    "utility decline. Toggle between ADDITIVE (subtract a fixed amount) ",
    "and MULTIPLICATIVE (multiply by a fixed proportion) adjustment and ",
    "watch what happens over a long time horizon."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("baseline_utility", "Baseline utility at model start", 0.5, 1.0, 0.85, step = 0.01),
      sliderInput("decrement", "Condition-specific decrement per year", 0.01, 0.15, 0.06, step = 0.005),
      radioButtons("adjustment_type", "Adjustment method",
                   choices = c("Additive (subtract)" = "additive", "Multiplicative (scale)" = "multiplicative"),
                   selected = "additive"),
      sliderInput("horizon", "Time horizon (years)", 10, 60, 40, step = 5),
      helpText("General-population utility also declines with age in this ",
               "model, at a fixed background rate of 0.004/year, applied the ",
               "same way regardless of the toggle.")
    ),
    mainPanel(
      plotOutput("utilityPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Additive disutility adjustment has no floor \u2014 applied every year for long enough, ",
        "it can drive projected utility below 0 (implying a health state 'worse than death', ",
        "which may or may not be clinically intended) or even keep subtracting past that ",
        "point into nonsensical negative territory. Multiplicative adjustment, by contrast, ",
        "compresses utility toward (but mathematically never past) zero, since it is always ",
        "scaling a positive number by a fraction. Push the horizon to 60 years and compare ",
        "the two methods' year-60 utility \u2014 additive adjustment with a large decrement can ",
        "go negative while multiplicative stays bounded, a structural difference that can ",
        "matter a great deal for a long-horizon chronic-disease model.")
    )
  )
)

server <- function(input, output, session) {

  utility_trajectory <- reactive({
    years <- 0:input$horizon
    bg_decline_rate <- 0.004
    bg_utility <- input$baseline_utility - bg_decline_rate * years

    if (input$adjustment_type == "additive") {
      adjusted_utility <- bg_utility - input$decrement * years
    } else {
      adjusted_utility <- bg_utility * (1 - input$decrement)^years
    }

    data.frame(year = years, bg_utility = bg_utility, adjusted_utility = adjusted_utility)
  })

  output$utilityPlot <- renderPlot({
    df <- utility_trajectory()
    ggplot(df, aes(x = year)) +
      geom_line(aes(y = bg_utility, color = "General population (background decline only)"),
                linetype = "dashed", linewidth = 1) +
      geom_line(aes(y = adjusted_utility, color = "With condition-specific decrement"),
                linewidth = 1.3) +
      geom_hline(yintercept = 0, linetype = "dotted", color = "black") +
      scale_color_manual(values = c("General population (background decline only)" = "grey50",
                                     "With condition-specific decrement" = "#2166ac"), name = NULL) +
      labs(x = "Years since model start", y = "Utility",
           title = sprintf("Utility trajectory: %s adjustment",
                            if (input$adjustment_type == "additive") "additive" else "multiplicative")) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$interpretation <- renderText({
    df <- utility_trajectory()
    final <- tail(df, 1)
    went_negative <- any(df$adjusted_utility < 0)
    neg_year <- if (went_negative) df$year[which(df$adjusted_utility < 0)[1]] else NA

    sprintf(paste0("At year %d (%s adjustment): utility = %.3f. %s"),
            input$horizon, input$adjustment_type, final$adjusted_utility,
            if (went_negative) {
              sprintf("This method crosses below 0 at year %d \u2014 implying a state judged worse than death from this year onward, which may not be clinically intended.", neg_year)
            } else {
              "This method stays non-negative across the full horizon."
            })
  })
}

shinyApp(ui, server)
