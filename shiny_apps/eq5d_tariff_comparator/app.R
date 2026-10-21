library(shiny)
library(eq5d)
library(ggplot2)

# EQ-5D Tariff Comparator
# Companion to Chapter 8, SS8.2: set a 5-dimension EQ-5D-3L health-state
# profile via sliders and select up to 3 country value sets; the utility
# index recomputes live across countries side by side via the real
# eq5d::eq5d() package function, showing the SAME health state scoring
# differently under different tariffs.

dimensions <- c("Mobility", "Self-Care", "Usual Activities", "Pain/Discomfort", "Anxiety/Depression")

ui <- fluidPage(
  titlePanel("EQ-5D Tariff Comparator"),
  p("Companion app for Chapter 8, \u00a78.2 (Health-Related Quality of Life ",
    "and Utilities). Set a 5-dimension EQ-5D-3L health-state profile (each ",
    "1=no problems, 2=some problems, 3=extreme problems) and compare the ",
    "resulting utility INDEX across country value sets via the real ",
    "`eq5d::eq5d()` TTO tariffs -- the identical health state is scored ",
    "differently in each country."),
  sidebarLayout(
    sidebarPanel(
      lapply(seq_along(dimensions), function(i) {
        sliderInput(paste0("dim_", i), dimensions[i], min = 1, max = 3, value = 2, step = 1)
      }),
      hr(),
      selectInput("countries", "Compare countries", multiple = TRUE,
                  choices = c("UK", "USA", "Germany", "Japan", "China", "Spain", "Netherlands_2006"),
                  selected = c("UK", "USA", "Japan"))
    ),
    mainPanel(
      verbatimTextOutput("healthStateOut"),
      plotOutput("tariffPlot", height = "350px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "An EQ-5D utility index is NOT a universal, country-independent number -- it is the ",
        "product of (a) a fixed patient-reported health state and (b) a country-specific ",
        "value set derived from that country's own general population's preferences (often ",
        "via time-trade-off elicitation). The exact same self-reported health state (e.g. ",
        "'some problems walking, no other problems') can score noticeably differently in ",
        "the UK vs. Japan vs. the USA tariff. Always report WHICH country's value set a ",
        "QALY calculation used -- borrowing a foreign tariff for a local HTA submission is ",
        "a real and common methodological red flag.")
    )
  )
)

server <- function(input, output, session) {

  health_state <- reactive({
    paste0(input$dim_1, input$dim_2, input$dim_3, input$dim_4, input$dim_5)
  })

  tariff_results <- reactive({
    hs <- health_state()
    req(length(input$countries) > 0)
    results <- sapply(input$countries, function(ctry) {
      tryCatch({
        eq5d(scores = hs, country = ctry, version = "3L", type = "TTO")
      }, error = function(e) NA)
    })
    data.frame(country = input$countries, utility = results)
  })

  output$healthStateOut <- renderPrint({
    hs <- health_state()
    cat("Health state code:", hs, "\n")
    for (i in seq_along(dimensions)) {
      level_desc <- c("1 = no problems", "2 = some problems", "3 = extreme problems")[as.integer(substr(hs, i, i))]
      cat(sprintf("  %s: %s\n", dimensions[i], level_desc))
    }
  })

  output$tariffPlot <- renderPlot({
    df <- tariff_results()
    req(nrow(df) > 0)
    ggplot(df, aes(x = reorder(country, utility), y = utility, fill = country)) +
      geom_col() +
      geom_hline(yintercept = c(0, 1), linetype = "dotted", color = "grey50") +
      geom_text(aes(label = sprintf("%.3f", utility)), vjust = -0.3, size = 4.5) +
      labs(x = NULL, y = "EQ-5D utility index",
           title = sprintf("Utility index for health state %s across countries", health_state())) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "none")
  })

  output$interpretation <- renderText({
    df <- tariff_results()
    req(nrow(df) > 0)
    range_val <- max(df$utility, na.rm = TRUE) - min(df$utility, na.rm = TRUE)
    best <- df$country[which.max(df$utility)]
    worst <- df$country[which.min(df$utility)]
    sprintf(paste0("For health state %s, utility ranges from %.3f (%s) to %.3f (%s) across ",
                   "the %d selected countries \u2014 a spread of %.3f utility points on IDENTICAL ",
                   "self-reported health, purely from different population value sets."),
            health_state(), min(df$utility, na.rm = TRUE), worst,
            max(df$utility, na.rm = TRUE), best, nrow(df), range_val)
  })
}

shinyApp(ui, server)
