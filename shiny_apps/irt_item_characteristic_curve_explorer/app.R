library(shiny)
library(ggplot2)

# IRT Item Characteristic Curve Explorer
# Companion to Chapter 33, SS33.1: sliders let the user vary an item's
# discrimination (a) and difficulty (b) parameters, with a live-updating
# item characteristic curve overlaid against a fixed reference item --
# makes directly visible the conceptual distinction between difficulty
# (shifts the curve left/right) and discrimination (changes the curve's
# steepness).

ui <- fluidPage(
  titlePanel("IRT Item Characteristic Curve Explorer"),
  p("Companion app for Chapter 33, \u00a733.1 (Patient-Reported Outcomes and ",
    "Preference Research). Under the 2-parameter logistic IRT model, each ",
    "PRO item has a discrimination (a) and difficulty (b) parameter. Drag ",
    "both for a 'your item' curve against a fixed reference item (a=1, ",
    "b=0) and see exactly how each parameter reshapes the item ",
    "characteristic curve differently."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("item_a", "Discrimination (a)", 0.2, 3, 1.5, step = 0.1),
      sliderInput("item_b", "Difficulty (b)", -3, 3, 0.5, step = 0.1),
      helpText("Reference item (grey, fixed): a=1.0, b=0.0 -- a ",
               "moderately discriminating item centred at the trait scale's midpoint.")
    ),
    mainPanel(
      plotOutput("icPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Difficulty and discrimination are easy to conflate but control genuinely different ",
        "things. Difficulty (b) shifts the curve LEFT/RIGHT along the trait scale -- where ",
        "the item is most informative -- without changing its steepness. Discrimination (a) ",
        "changes the curve's STEEPNESS at that midpoint without shifting its location. Set ",
        "b to match the reference item (b=0) and only vary a: the curves cross at the same ",
        "point but your item's curve is visibly steeper or flatter. Then reset a to 1.0 and ",
        "only vary b: the curve shape stays identical but slides sideways.")
    )
  )
)

server <- function(input, output, session) {

  icc_data <- reactive({
    theta <- seq(-4, 4, length.out = 300)
    p_ref <- 1 / (1 + exp(-1.0 * (theta - 0)))
    p_item <- 1 / (1 + exp(-input$item_a * (theta - input$item_b)))
    data.frame(theta = theta, p_ref = p_ref, p_item = p_item)
  })

  output$icPlot <- renderPlot({
    df <- icc_data()
    ggplot(df, aes(x = theta)) +
      geom_line(aes(y = p_ref, color = "Reference item (a=1, b=0)"), linewidth = 1, linetype = "dashed") +
      geom_line(aes(y = p_item, color = "Your item"), linewidth = 1.3) +
      geom_hline(yintercept = 0.5, linetype = "dotted", color = "grey60") +
      geom_vline(xintercept = input$item_b, linetype = "dotted", color = "#2166ac") +
      scale_color_manual(values = c("Reference item (a=1, b=0)" = "grey50", "Your item" = "#2166ac"), name = NULL) +
      labs(x = "Trait level (\u03b8)", y = "Probability of positive response",
           title = sprintf("Item characteristic curve: a = %.1f, b = %.1f", input$item_a, input$item_b)) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$interpretation <- renderText({
    # Slope at theta = b (the point of maximum discrimination) is a/4
    slope_at_b <- input$item_a / 4
    ref_slope <- 1.0 / 4
    discrim_desc <- if (input$item_a > 1.0) {
      sprintf("%.1f\u00d7 steeper than the reference item", input$item_a / 1.0)
    } else if (input$item_a < 1.0) {
      sprintf("%.1f\u00d7 flatter than the reference item", 1.0 / input$item_a)
    } else {
      "identical in steepness to the reference item"
    }
    sprintf(paste0("Your item is centred at \u03b8 = %.1f (difficulty b), meaning it is most ",
                   "informative for patients at that trait level -- shifted %s the reference ",
                   "item's centre (\u03b8=0). Its slope at that midpoint is %s (discrimination a=%.1f ",
                   "vs. the reference's a=1.0)."),
            input$item_b, if (input$item_b > 0) "right of" else if (input$item_b < 0) "left of" else "exactly at",
            discrim_desc, input$item_a)
  })
}

shinyApp(ui, server)
