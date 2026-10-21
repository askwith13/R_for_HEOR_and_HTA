library(shiny)
library(ggplot2)

# Waning Assumption Visualizer
# Companion to Chapter 20, SS20.3: a toggle (no waning / linear waning)
# plus waning-onset and waning-duration sliders reshape the intervention
# arm's OS extrapolation live against a fixed "no waning" reference curve,
# showing how much of the lifetime QALY gain depends on an untested
# post-trial assumption about whether treatment benefit persists.

ui <- fluidPage(
  titlePanel("Treatment-Waning Assumption Visualizer"),
  p("Companion app for Chapter 20, \u00a720.3 (Partitioned Survival Models). ",
    "An intervention arm's survival advantage over control is extrapolated ",
    "beyond the trial follow-up period. Toggle between assuming the ",
    "benefit persists indefinitely ('no waning') and assuming it fades ",
    "linearly over a chosen window ('linear waning'), and watch the ",
    "lifetime QALY gain estimate change."),
  sidebarLayout(
    sidebarPanel(
      radioButtons("waning_type", "Post-trial benefit assumption",
                   choices = c("No waning (benefit persists forever)" = "none",
                               "Linear waning" = "linear"),
                   selected = "none"),
      conditionalPanel(
        condition = "input.waning_type == 'linear'",
        sliderInput("waning_onset", "Waning onset (months after trial follow-up ends)", 0, 36, 12, step = 3),
        sliderInput("waning_duration", "Waning duration (months to reach control-level risk)", 6, 60, 24, step = 3)
      ),
      sliderInput("trial_followup", "Trial follow-up duration (months)", 12, 48, 24, step = 3),
      sliderInput("horizon", "Lifetime horizon (months)", 60, 300, 180, step = 12)
    ),
    mainPanel(
      plotOutput("waningPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Whether treatment benefit persists indefinitely after the trial ends is almost ",
        "always an UNTESTED assumption -- the trial simply didn't follow patients that ",
        "long. Compare the lifetime QALY gain under 'no waning' against 'linear waning' ",
        "with the same waning window \u2014 a large gap between the two numbers means a large ",
        "fraction of the reported lifetime benefit rests on an assumption the trial data ",
        "cannot actually verify, which should prompt reporting BOTH scenarios rather than ",
        "picking one as 'the' base case without scrutiny.")
    )
  )
)

server <- function(input, output, session) {

  hazard_rates <- reactive({
    # Illustrative fixed hazard rates (per month) during the trial period
    list(control = 0.025, intervention = 0.015) # intervention has lower hazard
  })

  survival_data <- reactive({
    h <- hazard_rates()
    t <- seq(0, input$horizon, length.out = 300)
    s_control <- exp(-h$control * t)

    if (input$waning_type == "none") {
      s_intervention <- exp(-h$intervention * t)
    } else {
      onset <- input$trial_followup + input$waning_onset
      full_wane <- onset + input$waning_duration
      hazard_t <- numeric(length(t))
      for (i in seq_along(t)) {
        if (t[i] <= onset) {
          hazard_t[i] <- h$intervention
        } else if (t[i] <= full_wane) {
          frac <- (t[i] - onset) / (full_wane - onset)
          hazard_t[i] <- h$intervention + frac * (h$control - h$intervention)
        } else {
          hazard_t[i] <- h$control
        }
      }
      # cumulative hazard via trapezoidal integration
      dt <- diff(t)
      cum_hazard <- c(0, cumsum((hazard_t[-1] + hazard_t[-length(hazard_t)]) / 2 * dt))
      s_intervention <- exp(-cum_hazard)
    }

    data.frame(t = t, s_control = s_control, s_intervention = s_intervention)
  })

  output$waningPlot <- renderPlot({
    df <- survival_data()
    trial_end <- input$trial_followup

    ggplot(df, aes(x = t)) +
      geom_line(aes(y = s_control, color = "Control"), linewidth = 1.1) +
      geom_line(aes(y = s_intervention, color = "Intervention"), linewidth = 1.1) +
      geom_vline(xintercept = trial_end, linetype = "dashed", color = "grey40") +
      scale_color_manual(values = c("Control" = "#d6604d", "Intervention" = "#2166ac"), name = NULL) +
      labs(x = "Months", y = "Survival probability",
           title = sprintf("Survival extrapolation: %s", if (input$waning_type == "none") "no waning" else "linear waning"),
           subtitle = "Dashed line: end of trial follow-up (observed data ends here)") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$interpretation <- renderText({
    df <- survival_data()
    t <- df$t
    dt <- diff(t)
    area_control <- sum((df$s_control[-1] + df$s_control[-length(df$s_control)]) / 2 * dt) / 12
    area_intervention <- sum((df$s_intervention[-1] + df$s_intervention[-length(df$s_intervention)]) / 2 * dt) / 12
    gain_years <- area_intervention - area_control

    sprintf(paste0("Lifetime survival-years gained (intervention vs. control), restricted mean up to ",
                   "the %d-month horizon: %.2f years under '%s'. Of the %d-month horizon, only the first ",
                   "%d months are backed by actual trial observation \u2014 everything beyond the dashed ",
                   "line is extrapolated."),
            input$horizon, gain_years, if (input$waning_type == "none") "no waning" else "linear waning",
            input$horizon, input$trial_followup)
  })
}

shinyApp(ui, server)
