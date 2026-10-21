library(shiny)
library(ggplot2)

# Durability / Waning-of-Effect Explorer
# Companion to Chapter 32, SS32.6: switch between three structural
# scenarios (durable forever / constant-hazard waning / accelerating
# waning) for a one-time curative gene/cell therapy, with a live-updating
# relapse-free-proportion curve over a 20-year horizon -- makes directly
# visible that a single base case silently picks one of several plausible
# 20-year futures, and that the scenarios look identical early on before
# diverging sharply.

ui <- fluidPage(
  titlePanel("Durability / Waning-of-Effect Explorer"),
  p("Companion app for Chapter 32, \u00a732.6 (Special Topics). A one-time ",
    "curative gene/cell therapy's relapse-free proportion is modelled under ",
    "3 structural scenarios for how durable the cure is over 20 years. ",
    "Trial follow-up typically covers only the first few years -- watch the ",
    "scenarios look nearly identical there before diverging sharply beyond ",
    "the observed data."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("trial_followup", "Trial follow-up (years, observed data)", 1, 8, 3, step = 0.5),
      sliderInput("waning_start", "Constant/accelerating waning: onset (years)", 2, 15, 5, step = 0.5),
      sliderInput("relapse_hazard", "Per-year relapse hazard once waning begins", 0.01, 0.3, 0.08, step = 0.01),
      sliderInput("accel_factor", "Accelerating-waning: hazard growth factor per year", 1.0, 1.5, 1.15, step = 0.01)
    ),
    mainPanel(
      plotOutput("durabilityPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "All 3 structural scenarios can fit the observed trial data (within the dashed ",
        "follow-up line) almost identically, which is exactly why a single base case is ",
        "an understated representation of the real uncertainty here -- a reader looking ",
        "only at the fit-to-data region cannot distinguish which scenario is 'correct'. ",
        "The scenarios only diverge well beyond the trial's own follow-up period, in ",
        "territory the trial provides zero direct evidence about. Any one-time curative ",
        "therapy's cost-effectiveness case should report all 3 scenarios (or at minimum a ",
        "wide durability sensitivity range), not silently commit to the most favourable one.")
    )
  )
)

server <- function(input, output, session) {

  durability_data <- reactive({
    t <- seq(0, 20, length.out = 300)
    onset <- input$waning_start
    h <- input$relapse_hazard
    accel <- input$accel_factor

    # Scenario 1: durable forever (no relapse)
    s_durable <- rep(1, length(t))

    # Scenario 2: constant-hazard waning after onset
    s_constant <- ifelse(t <= onset, 1, exp(-h * (t - onset)))

    # Scenario 3: accelerating-hazard waning after onset
    s_accel <- numeric(length(t))
    for (i in seq_along(t)) {
      if (t[i] <= onset) {
        s_accel[i] <- 1
      } else {
        # integrate hazard(s) = h * accel^(s - onset) from onset to t[i]
        s_seq <- seq(onset, t[i], length.out = 50)
        hazard_seq <- h * accel^(s_seq - onset)
        ds <- diff(s_seq)
        if (length(ds) > 0) {
          cum_hazard <- sum((hazard_seq[-1] + hazard_seq[-length(hazard_seq)]) / 2 * ds)
        } else {
          cum_hazard <- 0
        }
        s_accel[i] <- exp(-cum_hazard)
      }
    }

    data.frame(t = t, durable = s_durable, constant_waning = s_constant, accelerating_waning = s_accel)
  })

  output$durabilityPlot <- renderPlot({
    df <- durability_data()
    df_long <- data.frame(
      t = rep(df$t, 3),
      relapse_free = c(df$durable, df$constant_waning, df$accelerating_waning),
      scenario = rep(c("Durable forever", "Constant-hazard waning", "Accelerating waning"), each = nrow(df))
    )
    df_long$scenario <- factor(df_long$scenario, levels = c("Durable forever", "Constant-hazard waning", "Accelerating waning"))

    ggplot(df_long, aes(x = t, y = relapse_free, color = scenario)) +
      geom_line(linewidth = 1.2) +
      geom_vline(xintercept = input$trial_followup, linetype = "dashed", color = "grey40") +
      scale_color_manual(values = c("Durable forever" = "#2ca25f", "Constant-hazard waning" = "#2166ac",
                                     "Accelerating waning" = "#d6604d"), name = NULL) +
      labs(x = "Years since one-time curative therapy", y = "Relapse-free proportion",
           title = "Durability scenarios over a 20-year horizon",
           subtitle = "Dashed line: end of actual trial follow-up (observed data ends here)") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$interpretation <- renderText({
    df <- durability_data()
    at_20 <- df[nrow(df), ]
    at_followup_idx <- which.min(abs(df$t - input$trial_followup))
    at_followup <- df[at_followup_idx, ]

    gap_at_followup <- max(at_followup$durable, at_followup$constant_waning, at_followup$accelerating_waning) -
                        min(at_followup$durable, at_followup$constant_waning, at_followup$accelerating_waning)
    gap_at_20 <- max(at_20$durable, at_20$constant_waning, at_20$accelerating_waning) -
                 min(at_20$durable, at_20$constant_waning, at_20$accelerating_waning)

    sprintf(paste0("At the end of trial follow-up (%.1f years): the 3 scenarios differ by only ",
                   "%.3f in relapse-free proportion (durable=%.3f, constant-waning=%.3f, ",
                   "accelerating=%.3f) \u2014 nearly indistinguishable from the trial data alone. At ",
                   "year 20: they differ by %.3f (durable=%.3f, constant-waning=%.3f, ",
                   "accelerating=%.3f) \u2014 a %.0fx larger gap, entirely outside the observed ",
                   "follow-up window."),
            input$trial_followup, gap_at_followup, at_followup$durable, at_followup$constant_waning,
            at_followup$accelerating_waning, gap_at_20, at_20$durable, at_20$constant_waning,
            at_20$accelerating_waning,
            if (gap_at_followup > 0.001) gap_at_20 / gap_at_followup else NA)
  })
}

shinyApp(ui, server)
