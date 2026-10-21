library(shiny)
library(ggplot2)

# Bucher ITC Calculator
# Companion to Chapter 12, SS12.2: four sliders (d_AC, SE_AC, d_BC, SE_BC)
# let the user vary each trial's log-effect estimate/precision and watch
# the indirect A-vs-B estimate and its (always wider) CI update live --
# the core "uncertainty never cancels in an indirect comparison" lesson.

ui <- fluidPage(
  titlePanel("Bucher ITC Calculator"),
  p("Companion app for Chapter 12, \u00a712.2 (Indirect Treatment Comparisons and ",
    "Network Meta-Analysis). Two trials share a common comparator C: Trial 1 ",
    "estimates A vs. C, Trial 2 estimates B vs. C. The Bucher method derives ",
    "A vs. B indirectly. All effects are on the log scale (log hazard ratio or ",
    "log odds ratio); drag any slider to see the indirect estimate and its ",
    "always-wider confidence interval update live."),
  sidebarLayout(
    sidebarPanel(
      h4("Trial 1: A vs. C"),
      sliderInput("d_AC", "log(HR or OR), A vs. C", -1.5, 1.5, -0.40, step = 0.01),
      sliderInput("se_AC", "Standard error", 0.05, 1, 0.20, step = 0.01),
      hr(),
      h4("Trial 2: B vs. C"),
      sliderInput("d_BC", "log(HR or OR), B vs. C", -1.5, 1.5, -0.10, step = 0.01),
      sliderInput("se_BC", "Standard error", 0.05, 1, 0.18, step = 0.01),
      hr(),
      checkboxInput("exp_scale", "Exponentiate to natural scale (HR/OR)", value = TRUE)
    ),
    mainPanel(
      h4("Indirect A vs. B estimate (Bucher method)"),
      verbatimTextOutput("bucherOut"),
      plotOutput("forestPlot", height = "350px"),
      helpText("d_AB = d_AC \u2212 d_BC;  Var(d_AB) = SE_AC\u00b2 + SE_BC\u00b2  ",
               "(variances always add; the indirect CI can never be narrower ",
               "than either direct trial's own CI.)"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "The Bucher method assumes the two trials are otherwise exchangeable \u2014 ",
        "similar enough populations, comparators, and designs that comparator C ",
        "would have performed the same way in both trials. Nothing in this ",
        "calculator checks that assumption; it only propagates the stated ",
        "uncertainty correctly. If the two trials' patient populations differ ",
        "meaningfully, see Chapter 13 (MAIC/STC) for population-adjustment methods ",
        "that attempt to correct for it before comparing.")
    )
  )
)

server <- function(input, output, session) {

  bucher <- reactive({
    d_AB <- input$d_AC - input$d_BC
    se_AB <- sqrt(input$se_AC^2 + input$se_BC^2)
    ci_lo <- d_AB - 1.96 * se_AB
    ci_hi <- d_AB + 1.96 * se_AB
    list(d_AB = d_AB, se_AB = se_AB, ci_lo = ci_lo, ci_hi = ci_hi)
  })

  output$bucherOut <- renderPrint({
    b <- bucher()
    if (input$exp_scale) {
      cat(sprintf("Indirect A vs. B (natural scale): %.3f  (95%% CI: %.3f to %.3f)\n",
                   exp(b$d_AB), exp(b$ci_lo), exp(b$ci_hi)))
    } else {
      cat(sprintf("Indirect A vs. B (log scale): %.3f  (95%% CI: %.3f to %.3f)\n",
                   b$d_AB, b$ci_lo, b$ci_hi))
    }
    cat(sprintf("SE(A vs. B) = %.3f  (vs. SE_AC = %.3f, SE_BC = %.3f)\n",
                b$se_AB, input$se_AC, input$se_BC))
  })

  output$forestPlot <- renderPlot({
    b <- bucher()
    df <- data.frame(
      comparison = factor(c("A vs. C (direct)", "B vs. C (direct)", "A vs. B (indirect)"),
                           levels = c("A vs. B (indirect)", "B vs. C (direct)", "A vs. C (direct)")),
      est = c(input$d_AC, input$d_BC, b$d_AB),
      lo = c(input$d_AC - 1.96 * input$se_AC, input$d_BC - 1.96 * input$se_BC, b$ci_lo),
      hi = c(input$d_AC + 1.96 * input$se_AC, input$d_BC + 1.96 * input$se_BC, b$ci_hi)
    )
    if (input$exp_scale) {
      df$est <- exp(df$est); df$lo <- exp(df$lo); df$hi <- exp(df$hi)
      xlab_txt <- "HR or OR"
      vline <- 1
    } else {
      xlab_txt <- "log(HR or OR)"
      vline <- 0
    }

    ggplot(df, aes(x = est, y = comparison)) +
      geom_vline(xintercept = vline, linetype = "dashed", color = "grey50") +
      geom_errorbarh(aes(xmin = lo, xmax = hi), height = 0.2, color = "#2166ac") +
      geom_point(size = 3, color = "#2166ac") +
      labs(x = xlab_txt, y = NULL,
           title = "Direct trial estimates vs. Bucher indirect estimate") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    b <- bucher()
    width_AB <- 2 * 1.96 * b$se_AB
    width_AC <- 2 * 1.96 * input$se_AC
    width_BC <- 2 * 1.96 * input$se_BC
    wider_than <- max(width_AC, width_BC)
    pct_wider <- (width_AB / wider_than - 1) * 100
    sig_txt <- if ((b$ci_lo > 0 && b$ci_hi > 0) || (b$ci_lo < 0 && b$ci_hi < 0)) {
      "statistically significant (CI excludes the null)"
    } else {
      "not statistically significant (CI crosses the null)"
    }
    sprintf(paste0("The indirect A-vs-B interval is %.0f%% wider than the widest of the two direct ",
                   "trial intervals it was built from, and %s. This widening is NOT a modelling ",
                   "choice \u2014 it's the mathematical consequence of SE_AB\u00b2 = SE_AC\u00b2 + SE_BC\u00b2, ",
                   "and happens every single time, regardless of which point estimates you pick."),
            pct_wider, sig_txt)
  })
}

shinyApp(ui, server)
