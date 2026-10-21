library(shiny)
library(deSolve)
library(ggplot2)

# SEIR Epidemic Curve and Herd-Effect Explorer
# Companion to Chapter 22, SS22.4/22.6: sliders for R0, the latent-period
# rate sigma, and intervention effectiveness ve re-run a deSolve::ode()
# SEIR model live, plotting infectious-compartment curves for baseline and
# intervention arms and recalculating cumulative infections averted --
# showing small changes in ve produce disproportionately large changes in
# final epidemic size once R0 is close to 1 (a non-linear relationship).

seir_model <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    N <- S + E + I + R
    dS <- -beta * S * I / N
    dE <- beta * S * I / N - sigma * E
    dI <- sigma * E - gamma * I
    dR <- gamma * I
    list(c(dS, dE, dI, dR))
  })
}

run_seir <- function(R0, sigma, gamma, ve, N = 100000, days = 365) {
  beta <- R0 * gamma
  beta_intervention <- beta * (1 - ve)

  init <- c(S = N - 10, E = 0, I = 10, R = 0)
  times <- seq(0, days, by = 1)

  out_base <- ode(y = init, times = times, func = seir_model,
                   parms = c(beta = beta, sigma = sigma, gamma = gamma))
  out_int <- ode(y = init, times = times, func = seir_model,
                  parms = c(beta = beta_intervention, sigma = sigma, gamma = gamma))

  df_base <- as.data.frame(out_base); df_base$arm <- "Baseline (no intervention)"
  df_int <- as.data.frame(out_int); df_int$arm <- "Intervention"
  df <- rbind(df_base, df_int)

  cum_inf_base <- N - tail(df_base$S, 1)
  cum_inf_int <- N - tail(df_int$S, 1)

  list(df = df, cum_inf_base = cum_inf_base, cum_inf_int = cum_inf_int,
       averted = cum_inf_base - cum_inf_int, N = N)
}

ui <- fluidPage(
  titlePanel("SEIR Epidemic Curve and Herd-Effect Explorer"),
  p("Companion app for Chapter 22, \u00a722.4/22.6 (Discrete Event Simulation and ",
    "Dynamic Models). A compartmental SEIR model (deSolve::ode()) compares a ",
    "baseline epidemic against one with an intervention reducing transmission ",
    "by a chosen effectiveness (ve). Watch how a fixed change in ve produces ",
    "very different reductions in final epidemic size depending on how close ",
    "R0 is to 1."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("R0", "R0 (basic reproduction number)", 1.0, 5, 2.5, step = 0.1),
      sliderInput("sigma", "Latent-period rate, \u03c3 (1/incubation days)",
                  0.1, 1, 0.2, step = 0.05),
      sliderInput("gamma", "Recovery rate, \u03b3 (1/infectious days)",
                  0.1, 1, 0.14, step = 0.02),
      sliderInput("ve", "Intervention effectiveness (ve), reduction in transmission",
                  0, 0.9, 0.4, step = 0.05),
      helpText("N = 100,000, 10 initial infections, 365-day horizon.")
    ),
    mainPanel(
      plotOutput("seirPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "The relationship between intervention effectiveness and infections ",
        "averted is highly non-linear near R0 = 1. Set R0 to 1.2 and compare ve ",
        "= 0.1 against ve = 0.2 \u2014 doubling ve can eliminate the epidemic almost ",
        "entirely once R_effective = R0\u00d7(1\u2212ve) drops below 1, a threshold effect ",
        "a linear cost-effectiveness model would miss entirely. This is the core ",
        "reason dynamic transmission models exist: a cohort/Markov model cannot ",
        "represent this herd-protection threshold at all.")
    )
  )
)

server <- function(input, output, session) {

  sim <- reactive({
    run_seir(input$R0, input$sigma, input$gamma, input$ve)
  })

  output$seirPlot <- renderPlot({
    s <- sim()
    ggplot(s$df, aes(x = time, y = I, color = arm)) +
      geom_line(linewidth = 1.1) +
      scale_color_manual(values = c("Baseline (no intervention)" = "#d6604d",
                                     "Intervention" = "#2166ac")) +
      labs(x = "Day", y = "Infectious (I)", color = NULL,
           title = "SEIR infectious-compartment curves") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$interpretation <- renderText({
    s <- sim()
    r_eff <- input$R0 * (1 - input$ve)
    pct_averted <- s$averted / s$cum_inf_base * 100
    threshold_note <- if (r_eff < 1) {
      sprintf("R_effective = %.2f is below 1, so the intervention alone is enough to prevent sustained spread (herd protection achieved).", r_eff)
    } else {
      sprintf("R_effective = %.2f is still above 1, so the epidemic still spreads even with the intervention, just more slowly.", r_eff)
    }
    sprintf(paste0("Baseline: %s cumulative infections (%.1f%% of the population). ",
                   "With the intervention: %s cumulative infections \u2014 %s averted ",
                   "(%.1f%% reduction). %s"),
            format(round(s$cum_inf_base), big.mark = ","), s$cum_inf_base / s$N * 100,
            format(round(s$cum_inf_int), big.mark = ","),
            format(round(s$averted), big.mark = ","), pct_averted, threshold_note)
  })
}

shinyApp(ui, server)
