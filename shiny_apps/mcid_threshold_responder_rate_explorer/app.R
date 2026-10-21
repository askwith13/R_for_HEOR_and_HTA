library(shiny)
library(ggplot2)
library(dplyr)

# MCID Threshold / Responder-Rate Explorer
# Companion to Chapter 33, SS33.2: a slider for the distribution-based
# MCID fraction (x baseline SD) applied to simulated treatment-arm PRO
# data live-recomputes the responder-rate percentage and a histogram of
# patient-level changes with the MCID threshold marked -- demonstrates
# that the specific MCID threshold chosen is "doing a great deal of work"
# in determining how good a treatment looks.

set.seed(55)
n_patients <- 300
baseline_sd <- 15 # baseline PRO score SD
# Simulated patient-level change scores: genuine mean improvement with
# realistic individual variation
true_mean_change <- 8
change_scores <- rnorm(n_patients, mean = true_mean_change, sd = 12)

ui <- fluidPage(
  titlePanel("MCID Threshold / Responder-Rate Explorer"),
  p("Companion app for Chapter 33, \u00a733.2 (Patient-Reported Outcomes and ",
    "Preference Research). A simulated 300-patient treatment arm's ",
    "patient-reported-outcome CHANGE scores (mean improvement +8 points, ",
    "SD 12) are classified as 'responders' using a distribution-based ",
    "Minimal Clinically Important Difference (MCID) = a chosen fraction of ",
    "the baseline score's SD (15 points). Drag the fraction and watch the ",
    "responder rate swing."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("mcid_fraction", "MCID fraction (\u00d7 baseline SD)", 0.2, 0.8, 0.5, step = 0.05),
      helpText("Baseline PRO score SD = 15 points. MCID = fraction \u00d7 15.")
    ),
    mainPanel(
      plotOutput("responderPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "The underlying patient-level change data never changes as you drag this slider ",
        "-- only where the 'responder' line is drawn through the same fixed distribution ",
        "changes. A treatment can be made to look dramatically more or less effective ",
        "purely by choosing a smaller or larger MCID fraction, with zero change in the ",
        "actual clinical data. Any reported responder-rate figure should always be ",
        "accompanied by the specific MCID value and method used to derive it -- a 52% ",
        "responder rate and a 71% responder rate can describe literally the same trial ",
        "results, differing only in threshold choice.")
    )
  )
)

server <- function(input, output, session) {

  mcid_value <- reactive({
    input$mcid_fraction * baseline_sd
  })

  responder_data <- reactive({
    mcid <- mcid_value()
    responder <- change_scores >= mcid
    list(mcid = mcid, responder = responder,
         responder_rate = mean(responder) * 100,
         n_responders = sum(responder))
  })

  output$responderPlot <- renderPlot({
    r <- responder_data()
    df <- data.frame(change = change_scores, responder = r$responder)

    ggplot(df, aes(x = change, fill = responder)) +
      geom_histogram(bins = 30, color = "white") +
      geom_vline(xintercept = r$mcid, linetype = "dashed", color = "black", linewidth = 1) +
      scale_fill_manual(values = c("TRUE" = "#2166ac", "FALSE" = "#bbbbbb"),
                         labels = c("TRUE" = "Responder", "FALSE" = "Non-responder"), name = NULL) +
      labs(x = "Patient-level PRO change score", y = "Number of patients",
           title = sprintf("Responder classification at MCID = %.1f points (%.2f\u00d7 baseline SD)",
                            r$mcid, input$mcid_fraction),
           subtitle = "Dashed line: MCID threshold") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$interpretation <- renderText({
    r <- responder_data()
    sprintf(paste0("At MCID = %.1f points (%.2f\u00d7 baseline SD): %d of %d patients (%.1f%%) ",
                   "are classified as responders. The underlying mean improvement in this cohort ",
                   "is a fixed +8 points regardless of where this slider sits \u2014 only the responder ",
                   "RATE changes as the threshold moves across the same unchanged distribution."),
            r$mcid, input$mcid_fraction, r$n_responders, n_patients, r$responder_rate)
  })
}

shinyApp(ui, server)
