library(shiny)
library(meta)
library(ggplot2)

# Funnel Asymmetry Lab
# Companion to Chapter 11, SS11.3: a slider controls how many small
# "missing" studies are synthetically suppressed; funnel plot, Egger's
# test, and trim-and-fill re-run live, showing the pooled estimate chase a
# moving target as suppression changes -- makes concrete that trim-and-
# fill is a sensitivity check, not a correction.

set.seed(88)
n_studies_full <- 20
true_effect <- -0.3 # true log(RR), e.g. a genuinely beneficial treatment
study_n <- round(exp(rnorm(n_studies_full, log(150), 0.9)))
se <- 1 / sqrt(study_n) * 1.2
# Simulate publication bias: smaller (less precise) studies with "unfavourable"
# (toward-null or harmful) results are more likely to go unpublished
true_te <- rnorm(n_studies_full, true_effect, 0.1)
observed_te <- rnorm(n_studies_full, true_te, se)

ui <- fluidPage(
  titlePanel("Funnel Asymmetry Lab"),
  p("Companion app for Chapter 11, \u00a711.3 (Meta-Analysis). 20 simulated ",
    "studies include a mix of large precise trials and small imprecise ",
    "ones. Drag a slider to synthetically suppress ('un-publish') an ",
    "increasing number of the smallest studies with less favourable ",
    "(closer-to-null) results, simulating publication bias, and watch the ",
    "funnel plot, Egger's test, and trim-and-fill respond live."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n_suppressed", "Number of small 'unfavourable' studies suppressed", 0, 8, 0, step = 1),
      helpText("Suppression targets the smallest studies with the LEAST ",
               "favourable (closest-to-null or harmful) observed effect -- ",
               "the classic publication-bias pattern.")
    ),
    mainPanel(
      plotOutput("funnelPlot", height = "400px"),
      tableOutput("biasTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Trim-and-fill is a SENSITIVITY CHECK, not a correction that recovers the true ",
        "effect -- it imputes hypothetical 'missing' studies to restore funnel-plot symmetry, ",
        "which is a statistical heuristic, not a guarantee of removing publication bias. Push ",
        "suppression up and watch the trim-and-fill-adjusted estimate chase the shifting ",
        "pooled estimate, but never perfectly recover the ORIGINAL unsuppressed pooled ",
        "estimate -- a published report showing a trim-and-fill-adjusted result should never ",
        "be read as 'the bias has been corrected,' only as 'here is one plausible adjustment ",
        "under one specific symmetry assumption.'")
    )
  )
)

server <- function(input, output, session) {

  suppressed_data <- reactive({
    n_supp <- input$n_suppressed
    df <- data.frame(te = observed_te, se = se, study_n = study_n)
    df <- df[order(df$study_n), ] # smallest first

    if (n_supp > 0) {
      # Among the smallest studies, suppress those with least favourable (highest, i.e.
      # closest to or above zero) observed effect -- classic publication bias simulation
      small_studies <- df[1:min(n_supp * 2, nrow(df)), ]
      worst_idx <- order(-small_studies$te)[1:min(n_supp, nrow(small_studies))]
      suppress_rows <- rownames(small_studies)[worst_idx]
      df <- df[!(rownames(df) %in% suppress_rows), ]
    }
    df
  })

  meta_results <- reactive({
    df <- suppressed_data()
    req(nrow(df) >= 3)
    m <- metagen(TE = df$te, seTE = df$se, sm = "RR", common = FALSE, random = TRUE, method.tau = "REML")
    egger <- tryCatch(metabias(m, method.bias = "Egger")$pval, error = function(e) NA)
    tf <- tryCatch(trimfill(m), error = function(e) NULL)
    list(m = m, egger = egger, tf = tf, df = df)
  })

  output$funnelPlot <- renderPlot({
    r <- meta_results()
    if (!is.null(r$tf)) {
      funnel(r$tf, comb.random = TRUE, studlab = FALSE,
             main = sprintf("Funnel plot (%d studies suppressed, %d remain + trim-and-fill)",
                             input$n_suppressed, nrow(r$df)))
    } else {
      funnel(r$m, comb.random = TRUE, studlab = FALSE)
    }
  })

  output$biasTable <- renderTable({
    r <- meta_results()
    tf_est <- if (!is.null(r$tf)) r$tf$TE.random else NA
    data.frame(
      Metric = c("Studies remaining", "Pooled estimate (log RR)", "Egger's test p-value",
                 "Trim-and-fill adjusted estimate", "True simulated effect (oracle)"),
      Value = c(nrow(r$df), sprintf("%.3f", r$m$TE.random),
                if (is.na(r$egger)) "n/a" else sprintf("%.3f", r$egger),
                if (is.na(tf_est)) "n/a" else sprintf("%.3f", tf_est),
                sprintf("%.3f", true_effect))
    )
  })

  output$interpretation <- renderText({
    r <- meta_results()
    tf_est <- if (!is.null(r$tf)) r$tf$TE.random else NA
    egger_txt <- if (is.na(r$egger)) {
      "undefined (too few studies)"
    } else if (r$egger < 0.1) {
      sprintf("p=%.3f (suggestive of funnel asymmetry)", r$egger)
    } else {
      sprintf("p=%.3f (no strong evidence of asymmetry)", r$egger)
    }
    sprintf(paste0("With %d of 20 studies suppressed: pooled estimate = %.3f (true simulated ",
                   "effect = %.3f). Egger's test: %s. Trim-and-fill adjusted estimate = %s -- ",
                   "note this is a statistical adjustment toward symmetry, not a guaranteed ",
                   "recovery of the true effect."),
            input$n_suppressed, r$m$TE.random, true_effect, egger_txt,
            if (is.na(tf_est)) "n/a" else sprintf("%.3f", tf_est))
  })
}

shinyApp(ui, server)
