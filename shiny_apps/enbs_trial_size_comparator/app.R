library(shiny)
library(ggplot2)

# ENBS Trial-Size Comparator
# Companion to Chapter 26, SS26.4/26.6: sliders for sample size and
# trial cost re-compute a moment-matching EVSI approximation and the
# resulting ENBS live, so a reader can search for the sample size that
# maximises ENBS rather than assuming bigger is always better.

ui <- fluidPage(
  titlePanel("ENBS Trial-Size Comparator"),
  p("Companion app for Chapter 26, \u00a726.4 & 26.6 (Value of Information ",
    "Analysis). A proposed study would reduce uncertainty in one PSA ",
    "parameter (`p_ontx_fail`). EVSI (Expected Value of Sample ",
    "Information) grows with sample size but with diminishing returns, ",
    "while trial COST typically grows roughly linearly. ENBS = EVSI ",
    "minus trial cost. Drag the sample-size and per-patient-cost sliders ",
    "and search for the trial size that MAXIMISES ENBS -- it is rarely ",
    "the largest feasible trial."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("sample_size", "Proposed trial sample size (per arm)", 20, 2000, 300, step = 20),
      sliderInput("cost_per_patient", "Trial cost per patient ($)", 500, 10000, 3000, step = 250),
      sliderInput("fixed_trial_cost", "Fixed trial setup cost ($)", 0, 500000, 100000, step = 10000),
      sliderInput("population_size", "Decision-relevant population size", 1000, 500000, 50000, step = 1000)
    ),
    mainPanel(
      plotOutput("enbsPlot", height = "400px"),
      verbatimTextOutput("enbsOut"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "EVSI grows with sample size but with strongly DIMINISHING returns (doubling the sample ",
        "size does NOT double the information gained, because precision scales roughly with the ",
        "square root of sample size), while trial cost grows roughly LINEARLY with sample size. ",
        "This means ENBS is typically maximised at some INTERMEDIATE sample size, not the largest ",
        "feasible one -- a larger, costlier trial can genuinely have LOWER (even negative) ENBS ",
        "than a well-chosen smaller trial, which runs directly counter to the common intuition ",
        "that 'more data is always better.'")
    )
  )
)

server <- function(input, output, session) {

  # A simplified moment-matching EVSI proxy: prior parameter variance
  # shrinks as ~ n/(n + n0), scaled by total EVPPI (fixed) and population
  evppi_per_patient <- 50 # fixed illustrative per-decision EVPPI base rate ($/decision)
  n0 <- 150 # "prior effective sample size" governing diminishing returns

  evsi_result <- reactive({
    n <- input$sample_size
    pop <- input$population_size
    # EVSI fraction of EVPPI captured, saturating as n grows (moment-matching approximation)
    info_fraction <- n / (n + n0)
    evsi_per_decision <- evppi_per_patient * info_fraction
    evsi_total <- evsi_per_decision * pop

    trial_cost <- input$fixed_trial_cost + input$cost_per_patient * n * 2 # 2 arms
    enbs <- evsi_total - trial_cost

    list(evsi_total = evsi_total, trial_cost = trial_cost, enbs = enbs)
  })

  enbs_curve <- reactive({
    pop <- input$population_size
    n_grid <- seq(20, 2000, by = 20)
    info_fraction <- n_grid / (n_grid + n0)
    evsi_total <- evppi_per_patient * info_fraction * pop
    trial_cost <- input$fixed_trial_cost + input$cost_per_patient * n_grid * 2
    enbs <- evsi_total - trial_cost
    data.frame(n = n_grid, evsi = evsi_total, cost = trial_cost, enbs = enbs)
  })

  output$enbsPlot <- renderPlot({
    df <- enbs_curve()
    r <- evsi_result()
    optimal_n <- df$n[which.max(df$enbs)]

    ggplot(df, aes(x = n)) +
      geom_line(aes(y = evsi, color = "EVSI (total)"), linewidth = 1) +
      geom_line(aes(y = cost, color = "Trial cost"), linewidth = 1) +
      geom_line(aes(y = enbs, color = "ENBS (= EVSI \u2212 cost)"), linewidth = 1.3) +
      geom_vline(xintercept = optimal_n, linetype = "dashed", color = "grey50") +
      geom_point(aes(x = input$sample_size, y = r$enbs), color = "black", size = 5) +
      scale_color_manual(values = c("EVSI (total)" = "#2166ac", "Trial cost" = "#d6604d",
                                     "ENBS (= EVSI \u2212 cost)" = "#1a9850"), name = NULL) +
      annotate("text", x = optimal_n + 20, y = max(df$enbs), label = sprintf("ENBS-maximising n = %d", optimal_n), hjust = 0, size = 3.5) +
      labs(x = "Trial sample size (per arm)", y = "$",
           title = "EVSI, trial cost, and ENBS vs. proposed trial size") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$enbsOut <- renderPrint({
    r <- evsi_result()
    cat(sprintf("Sample size: %d per arm\n", input$sample_size))
    cat(sprintf("EVSI (total): $%s\n", format(round(r$evsi_total), big.mark = ",")))
    cat(sprintf("Trial cost: $%s\n", format(round(r$trial_cost), big.mark = ",")))
    cat(sprintf("ENBS: $%s\n", format(round(r$enbs), big.mark = ",")))
  })

  output$interpretation <- renderText({
    r <- evsi_result()
    df <- enbs_curve()
    optimal_n <- df$n[which.max(df$enbs)]
    optimal_enbs <- max(df$enbs)
    sprintf(paste0("At n=%d: ENBS = $%s. The ENBS-maximising sample size on this curve is n=%d ",
                   "(ENBS = $%s). %s"),
            input$sample_size, format(round(r$enbs), big.mark = ","), optimal_n,
            format(round(optimal_enbs), big.mark = ","),
            if (input$sample_size > optimal_n * 1.5) {
              "Your current sample size is well ABOVE the ENBS-maximising point -- a smaller, cheaper trial would likely deliver more net value."
            } else if (input$sample_size < optimal_n * 0.5) {
              "Your current sample size is well BELOW the ENBS-maximising point -- a larger trial would likely deliver more net value, up to a point."
            } else {
              "Your current sample size is reasonably close to the ENBS-maximising point."
            })
  })
}

shinyApp(ui, server)
