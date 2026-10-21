library(shiny)
library(ggplot2)

# Transition Matrix Explorer
# Companion to Chapter 3, SS3.1: sliders set each cell of a 3-state
# (Healthy/Sick/Dead) transition matrix (constrained to row-sum-to-1); a
# live cohort-occupancy trace over N cycles previews the Markov machinery
# of Chapter 19, with a running rowSums() validity check.

state_names <- c("Healthy", "Sick", "Dead")

ui <- fluidPage(
  titlePanel("Transition Matrix Explorer"),
  p("Companion app for Chapter 3, \u00a73.1 (R Essentials for Health ",
    "Economists). A preview of the Markov machinery used throughout ",
    "Chapter 19: drag each outbound transition probability for a 3-state ",
    "model; the stay-in-state probability is auto-computed so every row ",
    "sums to exactly 1, with a live rowSums() validity check matching the ",
    "defensive-programming habit the chapter teaches."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n_cycles", "Number of cycles", 5, 40, 15, step = 1),
      hr(),
      h4("From Healthy"),
      sliderInput("p_h_s", "P(Healthy \u2192 Sick)", 0, 0.6, 0.15, step = 0.01),
      sliderInput("p_h_d", "P(Healthy \u2192 Dead)", 0, 0.2, 0.01, step = 0.005),
      hr(),
      h4("From Sick"),
      sliderInput("p_s_h", "P(Sick \u2192 Healthy)", 0, 0.6, 0.2, step = 0.01),
      sliderInput("p_s_d", "P(Sick \u2192 Dead)", 0, 0.6, 0.1, step = 0.01),
      verbatimTextOutput("validityOut")
    ),
    mainPanel(
      plotOutput("tracePlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Every row of a transition matrix MUST sum to exactly 1 -- each patient has to go ",
        "SOMEWHERE each cycle, including staying put. R will silently run a matrix ",
        "multiplication even if your rows don't sum to 1, quietly producing a cohort trace ",
        "that gains or loses patients out of nowhere with no error or warning. This is ",
        "exactly why Chapter 3 teaches defensive rowSums() checks as a standing habit, not ",
        "an occasional nicety \u2014 the rowSums() readout below always confirms validity live, ",
        "the way production model code should.")
    )
  )
)

server <- function(input, output, session) {

  trans_matrix <- reactive({
    p_h_h <- 1 - input$p_h_s - input$p_h_d
    p_s_s <- 1 - input$p_s_h - input$p_s_d
    m <- matrix(c(
      p_h_h, input$p_h_s, input$p_h_d,
      input$p_s_h, p_s_s, input$p_s_d,
      0, 0, 1
    ), nrow = 3, byrow = TRUE)
    rownames(m) <- state_names
    colnames(m) <- state_names
    m
  })

  cohort_trace <- reactive({
    m <- trans_matrix()
    n <- input$n_cycles
    trace <- matrix(0, nrow = n + 1, ncol = 3)
    trace[1, ] <- c(1, 0, 0)
    for (cyc in 2:(n + 1)) {
      trace[cyc, ] <- trace[cyc - 1, ] %*% m
    }
    df <- as.data.frame(trace)
    names(df) <- state_names
    df$cycle <- 0:n
    df
  })

  output$validityOut <- renderPrint({
    m <- trans_matrix()
    rs <- rowSums(m)
    cat("Transition matrix:\n")
    print(round(m, 3))
    cat("\nrowSums() check:\n")
    print(round(rs, 6))
    if (all(abs(rs - 1) < 1e-9)) {
      cat("\n[VALID] All rows sum to 1.\n")
    } else {
      cat("\n[INVALID] Rows do not sum to 1!\n")
    }
  })

  output$tracePlot <- renderPlot({
    df <- cohort_trace()
    df_long <- data.frame(
      cycle = rep(df$cycle, 3),
      proportion = c(df$Healthy, df$Sick, df$Dead),
      state = rep(state_names, each = nrow(df))
    )
    df_long$state <- factor(df_long$state, levels = state_names)

    ggplot(df_long, aes(x = cycle, y = proportion, fill = state)) +
      geom_area(alpha = 0.8) +
      scale_fill_manual(values = c("Healthy" = "#2ca25f", "Sick" = "#fdae61", "Dead" = "#555555")) +
      labs(x = "Cycle", y = "Proportion of cohort", fill = NULL,
           title = sprintf("Cohort-occupancy trace over %d cycles", input$n_cycles)) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$interpretation <- renderText({
    df <- cohort_trace()
    final <- df[nrow(df), ]
    m <- trans_matrix()
    rs <- rowSums(m)
    sprintf(paste0("All %d rows of the transition matrix sum to %s (valid). After %d cycles: ",
                   "%.1f%% Healthy, %.1f%% Sick, %.1f%% Dead. This is exactly the matrix-",
                   "multiplication machinery Chapter 19's full Markov cohort models build on ",
                   "-- the same mechanics, just with a simpler 3-state example here."),
            length(rs), paste(round(rs, 3), collapse = ", "), input$n_cycles,
            final$Healthy * 100, final$Sick * 100, final$Dead * 100)
  })
}

shinyApp(ui, server)
