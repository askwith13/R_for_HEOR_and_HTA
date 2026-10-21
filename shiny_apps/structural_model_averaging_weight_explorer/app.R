library(shiny)
library(ggplot2)

# Structural Model Averaging Weight Explorer
# Companion to Chapter 25, SS25.7: a single slider for the weight
# assigned to the 4-state structure (with the 3-state structure's weight
# auto-set to 1 minus that value) re-computes the model-averaged NMB live
# from the chapter's own two fixed structure-specific NMB values.

ui <- fluidPage(
  titlePanel("Structural Model Averaging Weight Explorer"),
  p("Companion app for Chapter 25, \u00a725.7 (Handling Uncertainty). Two ",
    "competing model STRUCTURES (a simpler 3-state Markov model and a ",
    "more detailed 4-state model) give different NMB estimates for the ",
    "same treatment comparison: $8,044.05 (4-state) and $5,357.89 ",
    "(3-state). Drag a single weight for how much you trust the 4-state ",
    "structure (the 3-state weight auto-completes to 1 minus that value) ",
    "and watch the model-averaged NMB move between the two endpoints."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("weight_4state", "Weight on 4-state structure", 0, 1, 0.5, step = 0.01),
      helpText("0 = trust the 3-state structure completely. ",
               "1 = trust the 4-state structure completely.")
    ),
    mainPanel(
      plotOutput("averagingPlot", height = "350px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Structural model-averaging weights are usually expert judgement, not a hard ",
        "empirical fact derived from the data -- there is rarely a statistically rigorous way ",
        "to say '4-state deserves exactly 65% trust.' The model-averaged NMB moves smoothly ",
        "and substantially between the two structure-specific values as this largely ",
        "subjective weight changes, which means the FINAL reported number can be quietly ",
        "shaped by whoever chooses the weighting, even though both input NMB values ($8,044 ",
        "and $5,358) were computed with equal rigor. Any model-averaged result should report ",
        "both structure-specific values alongside the weighting rationale, not just the ",
        "single blended number.")
    )
  )
)

server <- function(input, output, session) {

  nmb_4state <- 8044.05
  nmb_3state <- 5357.89

  averaged_nmb <- reactive({
    w4 <- input$weight_4state
    w3 <- 1 - w4
    w4 * nmb_4state + w3 * nmb_3state
  })

  output$averagingPlot <- renderPlot({
    w4 <- input$weight_4state
    w_grid <- seq(0, 1, length.out = 100)
    nmb_grid <- w_grid * nmb_4state + (1 - w_grid) * nmb_3state
    df <- data.frame(w4 = w_grid, nmb = nmb_grid)

    ggplot(df, aes(x = w4, y = nmb)) +
      geom_line(color = "#2166ac", linewidth = 1.2) +
      geom_point(aes(x = w4, y = averaged_nmb()), data.frame(w4 = input$weight_4state),
                 color = "#d6604d", size = 6) +
      geom_hline(yintercept = c(nmb_3state, nmb_4state), linetype = "dotted", color = "grey50") +
      annotate("text", x = 0.02, y = nmb_3state, label = "3-state: $5,357.89", hjust = 0, vjust = -0.5, size = 3.5) +
      annotate("text", x = 0.02, y = nmb_4state, label = "4-state: $8,044.05", hjust = 0, vjust = -0.5, size = 3.5) +
      labs(x = "Weight on 4-state structure", y = "Model-averaged NMB ($)",
           title = "Model-averaged NMB as the structural weight moves") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    nmb_avg <- averaged_nmb()
    w4 <- input$weight_4state
    sprintf(paste0("At weight = %.2f on the 4-state structure (%.2f on 3-state): model-averaged ",
                   "NMB = $%.2f. This sits %.1f%% of the way from the 3-state value ($5,357.89) ",
                   "to the 4-state value ($8,044.05) -- purely a linear interpolation driven by ",
                   "the weight you chose, with neither input NMB value itself changing."),
            w4, 1 - w4, nmb_avg, w4 * 100)
  })
}

shinyApp(ui, server)
