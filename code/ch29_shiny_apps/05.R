# Extracted from ch29_shiny_apps.typ, lines 176-194
# Section: == 29.3 Modular Shiny with `golem` and `rhino`
# Chapter: 29

# A module for a single cost-effectiveness summary box
ceSummaryUI <- function(id) {
  ns <- NS(id)
  tagList(
    h4("Incremental results"),
    textOutput(ns("icer_text"))
  )
}

ceSummaryServer <- function(id, incremental_results) {
  moduleServer(id, function(input, output, session) {
    output$icer_text <- renderText({
      res <- incremental_results()
      paste0("ICER: $", format(round(res$icer, 0), big.mark = ","))
    })
  })
}
