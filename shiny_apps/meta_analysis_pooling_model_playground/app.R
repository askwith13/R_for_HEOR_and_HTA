library(shiny)
library(meta)
library(ggplot2)

# Meta-Analysis Pooling Model Playground
# Companion to Chapter 11, SS11.1-11.2: switch between fixed-effect and
# random-effects pooling and between tau-squared estimators (DL/REML/PM)
# for a simulated set of trials with real between-study heterogeneity;
# forest plot, pooled estimate, CI width, and I^2/tau^2 all redraw live --
# lets a reader watch the interval breathe as estimator choice changes.

set.seed(321)
n_studies <- 8
true_effect_log_rr <- -0.3
tau_true <- 0.25 # genuine between-study heterogeneity
study_names <- paste("Trial", LETTERS[1:n_studies])
study_n <- sample(seq(80, 600, by = 40), n_studies)
true_study_effects <- rnorm(n_studies, mean = true_effect_log_rr, sd = tau_true)
se <- 1 / sqrt(study_n) * 1.5 # rough SE scaling with sample size
observed_log_rr <- rnorm(n_studies, mean = true_study_effects, sd = se)

ui <- fluidPage(
  titlePanel("Meta-Analysis Pooling Model Playground"),
  p("Companion app for Chapter 11, \u00a711.1\u201311.2 (Meta-Analysis). 8 simulated ",
    "trials (with genuine between-study heterogeneity, \u03c4 = 0.25 on the log-RR ",
    "scale) are pooled live. Switch between fixed-effect and random-effects ",
    "models, and between \u03c4\u00b2 estimators, and watch the pooled estimate and its ",
    "CI width change."),
  sidebarLayout(
    sidebarPanel(
      radioButtons("model_type", "Pooling model",
                   choices = c("Fixed-effect" = "fixed", "Random-effects" = "random"),
                   selected = "random"),
      conditionalPanel(
        condition = "input.model_type == 'random'",
        selectInput("tau_method", "\u03c4\u00b2 estimator",
                    choices = c("DerSimonian-Laird (DL)" = "DL",
                                "REML" = "REML",
                                "Paule-Mandel (PM)" = "PM"),
                    selected = "REML")
      ),
      helpText("8 simulated trials with genuine heterogeneity (true \u03c4 = 0.25 ",
               "on the log risk-ratio scale) underlie every choice here.")
    ),
    mainPanel(
      plotOutput("forestPlot", height = "450px"),
      tableOutput("summaryTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Switching between \u03c4\u00b2 estimators (DL/REML/PM) on the SAME data changes the ",
        "pooled CI width without changing a single data point \u2014 this is sometimes called ",
        "'estimator shopping' when done to produce a more favourable-looking result after ",
        "seeing the data. Fixed-effect pooling, by assuming zero between-study ",
        "heterogeneity, will always show an artificially narrow CI when real ",
        "heterogeneity (as simulated here) exists \u2014 compare the fixed-effect CI width ",
        "against any random-effects CI width to see how much narrower (and ",
        "overconfident) it looks.")
    )
  )
)

server <- function(input, output, session) {

  meta_fit <- reactive({
    if (input$model_type == "fixed") {
      metagen(TE = observed_log_rr, seTE = se, studlab = study_names,
              sm = "RR", common = TRUE, random = FALSE)
    } else {
      metagen(TE = observed_log_rr, seTE = se, studlab = study_names,
              sm = "RR", common = FALSE, random = TRUE, method.tau = input$tau_method)
    }
  })

  output$forestPlot <- renderPlot({
    m <- meta_fit()
    forest(m, comb.fixed = (input$model_type == "fixed"),
           comb.random = (input$model_type == "random"),
           leftlabs = c("Study", "log(RR)", "SE"))
  })

  output$summaryTable <- renderTable({
    m <- meta_fit()
    if (input$model_type == "fixed") {
      data.frame(
        Metric = c("Pooled log(RR)", "95% CI", "CI width", "I\u00b2", "\u03c4\u00b2"),
        Value = c(sprintf("%.3f", m$TE.common),
                  sprintf("%.3f to %.3f", m$lower.common, m$upper.common),
                  sprintf("%.3f", m$upper.common - m$lower.common),
                  sprintf("%.1f%%", m$I2 * 100),
                  "0 (assumed)")
      )
    } else {
      data.frame(
        Metric = c("Pooled log(RR)", "95% CI", "CI width", "I\u00b2", "\u03c4\u00b2"),
        Value = c(sprintf("%.3f", m$TE.random),
                  sprintf("%.3f to %.3f", m$lower.random, m$upper.random),
                  sprintf("%.3f", m$upper.random - m$lower.random),
                  sprintf("%.1f%%", m$I2 * 100),
                  sprintf("%.4f", m$tau2))
      )
    }
  })

  output$interpretation <- renderText({
    m <- meta_fit()
    if (input$model_type == "fixed") {
      ci_width <- m$upper.common - m$lower.common
      sprintf(paste0("Fixed-effect model: pooled log(RR) = %.3f, 95%% CI width = %.3f, I\u00b2 = %.1f%%. ",
                     "Fixed-effect pooling assumes \u03c4\u00b2 = 0 (no real between-study variation beyond ",
                     "sampling error) \u2014 but I\u00b2 = %.1f%% here suggests real heterogeneity exists, so this ",
                     "CI is likely too narrow."),
              m$TE.common, ci_width, m$I2 * 100, m$I2 * 100)
    } else {
      ci_width <- m$upper.random - m$lower.random
      sprintf(paste0("Random-effects model (%s estimator): pooled log(RR) = %.3f, \u03c4\u00b2 = %.4f, ",
                     "95%% CI width = %.3f, I\u00b2 = %.1f%%. The estimated \u03c4\u00b2 (true between-study ",
                     "heterogeneity) directly widens the CI relative to a fixed-effect model on the ",
                     "same data \u2014 this is a more honest reflection of the genuine simulated ",
                     "heterogeneity (true \u03c4 = 0.25) than the fixed-effect model's assumption of none."),
              input$tau_method, m$TE.random, m$tau2, ci_width, m$I2 * 100)
    }
  })
}

shinyApp(ui, server)
