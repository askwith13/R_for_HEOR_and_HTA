# Extracted from ch29_shiny_apps.typ, lines 105-129
# Section: == 29.2 Designing a user interface for non-programmers
# Chapter: 29

library(shiny)
library(bslib)

ui <- page_navbar(
  title = "TB treatment cost-effectiveness explorer",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  nav_panel("Inputs & summary", icon = icon("sliders"),
    sidebarLayout(
      sidebarPanel(
        sliderInput("tx_cost", "Annual treatment cost ($)",
                    min = 500, max = 3000, value = 1200, step = 50),
        selectInput("regimen", "Treatment regimen",
                    choices = c("Standard 6-month" = "std",
                                "Shortened 4-month" = "short"))
      ),
      mainPanel(textOutput("icer_summary"))
    )
  ),
  nav_panel("Cost-effectiveness plane", icon = icon("chart-scatter"),
            plotOutput("ce_plane")),
  nav_panel("CEAC", icon = icon("chart-line"),
            plotOutput("ceac_plot"))
)
