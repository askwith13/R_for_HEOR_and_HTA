library(shiny)
library(ggplot2)
library(gridExtra)

# Curve-Crossing Explorer
# Companion to Chapter 20, SS20.1 & 20.5: shape/scale sliders for
# independently-fit PFS and OS Weibull curves live-replot both survival
# curves plus the derived P(Progressed) = S_OS(t) - S_PFS(t) line across
# an extendable time horizon, shading in red where it goes negative --
# makes the partitioned-survival structural-flaw pitfall (curve crossing,
# often far out in the extrapolated tail) directly visible.

ui <- fluidPage(
  titlePanel("Curve-Crossing Explorer (Partitioned Survival Models)"),
  p("Companion app for Chapter 20, \u00a720.1 & 20.5 (Partitioned Survival ",
    "Models). PFS and OS are fit INDEPENDENTLY in a standard partitioned ",
    "survival model, with no structural guarantee that S_OS(t) \u2265 S_PFS(t) ",
    "at every time point. Drag the shape/scale parameters for each curve ",
    "and extend the horizon to find where (if anywhere) the curves cross."),
  sidebarLayout(
    sidebarPanel(
      h4("PFS curve (Weibull)"),
      sliderInput("pfs_shape", "PFS shape", 0.5, 3, 1.1, step = 0.05),
      sliderInput("pfs_scale", "PFS scale (months)", 3, 60, 10, step = 1),
      hr(),
      h4("OS curve (Weibull)"),
      sliderInput("os_shape", "OS shape", 0.5, 3, 0.9, step = 0.05),
      sliderInput("os_scale", "OS scale (months)", 5, 100, 24, step = 1),
      hr(),
      sliderInput("horizon", "Extrapolation horizon (months)", 24, 240, 60, step = 6)
    ),
    mainPanel(
      plotOutput("curvePlot", height = "450px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Curve crossing often happens far out in the extrapolated tail, well beyond where a ",
        "quick glance at the trial-period plot would ever catch it. Set PFS shape BELOW 1 ",
        "(a long flat tail of slow progression) with a short-to-moderate scale, and OS shape ",
        "ABOVE 2 (an accelerating hazard, as a long-controlled disease eventually catches up) ",
        "with a longer scale, then push the horizon out to 150+ months \u2014 watch the red-shaded ",
        "'impossible' region (P(Progressed) < 0, meaning more patients are alive-and-",
        "progression-free than alive overall) appear only well after the trial's own ",
        "follow-up period has ended. Always check the FULL extrapolated horizon, not just the ",
        "observed data range, before trusting a partitioned survival model's structure.")
    )
  )
)

server <- function(input, output, session) {

  curves <- reactive({
    t <- seq(0, input$horizon, length.out = 300)
    s_pfs <- exp(-(t / input$pfs_scale)^input$pfs_shape)
    s_os <- exp(-(t / input$os_scale)^input$os_shape)
    p_progressed <- s_os - s_pfs

    first_cross <- NA
    neg_idx <- which(p_progressed < 0)
    if (length(neg_idx) > 0) first_cross <- t[neg_idx[1]]

    data.frame(t = t, s_pfs = s_pfs, s_os = s_os, p_progressed = p_progressed,
               first_cross = first_cross)
  })

  output$curvePlot <- renderPlot({
    df <- curves()
    crossing_exists <- !is.na(df$first_cross[1])

    p1 <- ggplot(df, aes(x = t)) +
      geom_line(aes(y = s_os, color = "OS"), linewidth = 1.1) +
      geom_line(aes(y = s_pfs, color = "PFS"), linewidth = 1.1) +
      scale_color_manual(values = c("OS" = "#2166ac", "PFS" = "#2ca25f"), name = NULL) +
      labs(x = NULL, y = "Survival probability", title = "PFS and OS survival curves") +
      theme_minimal(base_size = 13) + theme(legend.position = "top")

    p2 <- ggplot(df, aes(x = t, y = p_progressed)) +
      geom_ribbon(data = subset(df, p_progressed < 0), aes(ymin = p_progressed, ymax = 0),
                  fill = "#d6604d", alpha = 0.4) +
      geom_line(color = "#555555", linewidth = 1) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
      labs(x = "Time (months)", y = "P(Progressed) = S_OS \u2212 S_PFS",
           title = if (crossing_exists) {
             sprintf("Curve crossing detected at t = %.1f months (shaded red = impossible region)", df$first_cross[1])
           } else {
             "No curve crossing within this horizon"
           }) +
      theme_minimal(base_size = 13)

    gridExtra::grid.arrange(p1, p2, ncol = 1, heights = c(1, 1.2))
  })

  output$interpretation <- renderText({
    df <- curves()
    crossing_exists <- !is.na(df$first_cross[1])
    if (crossing_exists) {
      sprintf(paste0("With these parameters, the PFS and OS curves cross at t = %.1f months ",
                     "(out of a %.0f-month horizon) \u2014 past this point, the model implies MORE ",
                     "patients are alive-and-progression-free than alive overall, which is ",
                     "structurally impossible. This indicates the independently-fit PFS and OS ",
                     "extrapolations are not jointly plausible beyond this point."),
              df$first_cross[1], input$horizon)
    } else {
      sprintf(paste0("With these parameters, no curve crossing occurs within the %.0f-month ",
                     "horizon \u2014 S_OS(t) stays above S_PFS(t) throughout, which is the required ",
                     "structural relationship. Try extending the horizon or making the OS curve's ",
                     "tail heavier (lower shape) relative to PFS to find where this can break down."),
              input$horizon)
    }
  })
}

shinyApp(ui, server)
