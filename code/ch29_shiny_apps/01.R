# Extracted from ch29_shiny_apps.typ, lines 45-87
# Section: == 29.1 Shiny fundamentals for model front-ends
# Chapter: 29

library(shiny)

comparator_cost <- 2000  # fixed cost of standard of care

ui <- fluidPage(
  titlePanel("Toy ICER calculator"),
  sidebarLayout(
    sidebarPanel(
      numericInput("treatment_cost", "New treatment cost ($)",
                   value = 5000, min = 0, step = 100),
      numericInput("qaly_gain", "Incremental QALYs gained",
                   value = 0.15, min = 0, step = 0.01)
    ),
    mainPanel(
      h4("Incremental cost-effectiveness ratio"),
      textOutput("icer_text")
    )
  )
)

server <- function(input, output, session) {

  # Reactive expression: recomputes only when its inputs change
  incremental <- reactive({
    list(
      d_cost = input$treatment_cost - comparator_cost,
      d_qaly = input$qaly_gain
    )
  })

  icer <- reactive({
    inc <- incremental()
    inc$d_cost / inc$d_qaly
  })

  output$icer_text <- renderText({
    paste0("$", format(round(icer(), 0), big.mark = ","), " per QALY gained")
  })
}

shinyApp(ui, server)
