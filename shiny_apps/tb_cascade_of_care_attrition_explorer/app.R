library(shiny)
library(ggplot2)
library(dplyr)

# TB Cascade-of-Care Attrition Explorer
# Companion to Chapter 32, SS32.7: five sliders, one per cascade stage
# (diagnosis, treatment initiation, treatment completion, bacteriological
# cure), each 0-100%, with a live-updating waterfall chart showing the
# cohort shrinking stage by stage. Demonstrates that a fixed percentage-
# point improvement at one stage changes the final cured proportion by a
# different amount depending on which stage it's applied to.

ui <- fluidPage(
  titlePanel("TB Cascade-of-Care Attrition Explorer"),
  p("Companion app for Chapter 32, \u00a732.7 (Special Topics). A presumptive-TB ",
    "cohort moves through four successive cascade steps -- diagnosis, ",
    "treatment initiation, treatment completion, bacteriological cure -- ",
    "each with its own conditional probability. Attrition at any step ",
    "compounds with attrition at every prior step."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n_presumptive", "Presumptive TB cases (cohort size)",
                  1000, 50000, 10000, step = 500),
      sliderInput("p_diagnosed", "P(Diagnosed | Presumptive)", 0, 1, 0.70, step = 0.01),
      sliderInput("p_initiated", "P(Treatment initiated | Diagnosed)", 0, 1, 0.85, step = 0.01),
      sliderInput("p_completed", "P(Treatment completed | Initiated)", 0, 1, 0.80, step = 0.01),
      sliderInput("p_cured", "P(Bacteriologically cured | Completed)", 0, 1, 0.90, step = 0.01),
      helpText("Try raising each probability by the same +0.10 in turn and ",
               "compare the final cured count each time.")
    ),
    mainPanel(
      plotOutput("cascadePlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A 10-percentage-point improvement at an EARLY stage (diagnosis) ",
        "compounds through every subsequent stage and moves far more patients ",
        "to the final 'cured' count than the same 10-point improvement applied ",
        "to a LATE stage (cure). This is not about one stage being intrinsically ",
        "more important clinically \u2014 it's pure arithmetic: improving a step that ",
        "comes before more multiplication steps affects a larger base population. ",
        "Try moving only the diagnosis slider by +0.10 vs. only the cure slider by ",
        "+0.10, holding everything else fixed, and compare the change in final ",
        "cured count.")
    )
  )
)

server <- function(input, output, session) {

  cascade <- reactive({
    n0 <- input$n_presumptive
    n1 <- n0 * input$p_diagnosed
    n2 <- n1 * input$p_initiated
    n3 <- n2 * input$p_completed
    n4 <- n3 * input$p_cured

    data.frame(
      stage = factor(c("Presumptive", "Diagnosed", "Initiated", "Completed", "Cured"),
                      levels = c("Presumptive", "Diagnosed", "Initiated", "Completed", "Cured")),
      count = c(n0, n1, n2, n3, n4)
    )
  })

  output$cascadePlot <- renderPlot({
    df <- cascade()
    ggplot(df, aes(x = stage, y = count)) +
      geom_col(fill = "#2166ac", width = 0.6) +
      geom_text(aes(label = format(round(count), big.mark = ",")), vjust = -0.5, size = 4.2) +
      labs(x = NULL, y = "Patients",
           title = "TB cascade of care: cohort attrition by stage") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    df <- cascade()
    final_rate <- df$count[5] / df$count[1] * 100
    biggest_drop_idx <- which.max(-diff(df$count))
    stage_names <- as.character(df$stage)
    sprintf(paste0("Of %s presumptive cases, %s (%.1f%%) are ultimately cured \u2014 the overall ",
                   "cascade completion rate is the PRODUCT of all four conditional probabilities ",
                   "(%.0f%% \u00d7 %.0f%% \u00d7 %.0f%% \u00d7 %.0f%% = %.1f%%), not their average or sum. ",
                   "The single largest absolute drop in patient count happens at the '%s \u2192 %s' step."),
            format(round(df$count[1]), big.mark = ","), format(round(df$count[5]), big.mark = ","),
            final_rate,
            input$p_diagnosed * 100, input$p_initiated * 100, input$p_completed * 100, input$p_cured * 100,
            input$p_diagnosed * input$p_initiated * input$p_completed * input$p_cured * 100,
            stage_names[biggest_drop_idx], stage_names[biggest_drop_idx + 1])
  })
}

shinyApp(ui, server)
