library(shiny)
library(ggplot2)
library(dplyr)

# CEAC/WTP Threshold Explorer (Case Studies A and B combined)
# Companion to Chapter 35, SS35.1/35.2: a single WTP slider highlights
# the corresponding point on each case study's own PSA-derived CEAC
# curve and restates the probability-cost-effective figure live, for
# BOTH the chronic-disease Markov model (Case Study A) and the
# oncology PSM (Case Study B) side by side.

ui <- fluidPage(
  titlePanel("CEAC/WTP Threshold Explorer (Case Studies A and B)"),
  p("Companion app for Chapter 35, \u00a735.1 & 35.2 (End-to-End Worked ",
    "Case Studies). Both case studies ran a full PSA (2,000 iterations) ",
    "and reported a cost-effectiveness acceptability curve (CEAC). Drag ",
    "a single willingness-to-pay slider and watch the corresponding ",
    "point on BOTH case studies' CEAC curves update live -- revealing a ",
    "genuinely different qualitative story for each: Case Study A's ",
    "accept/reject conclusion is highly WTP-sensitive, while Case Study ",
    "B's never approaches a conventional oncology threshold at any ",
    "reasonable WTP."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("wtp", "Willingness-to-pay threshold ($/QALY)", 0, 150000, 50000, step = 1000),
      helpText("Case Study A: chronic-disease Markov model (a cheaper, ",
               "modestly effective intervention). Case Study B: oncology ",
               "PSM (an expensive, more effective intervention).")
    ),
    mainPanel(
      plotOutput("ceacPlot", height = "400px"),
      verbatimTextOutput("ceacOut"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Reporting a single ICER point estimate against a single WTP threshold hides how the ",
        "accept/reject conclusion can be fundamentally different in CHARACTER between two case ",
        "studies, not just in degree. Case Study A's probability of cost-effectiveness swings ",
        "sharply across a plausible WTP range (a genuinely close call, sensitive to which ",
        "threshold a payer uses), while Case Study B's stays low across the entire plausible range ",
        "(not a close call at all, regardless of exactly which conventional threshold is chosen). A ",
        "single CEAC-at-one-WTP-point snapshot cannot distinguish 'close call, threshold-sensitive' ",
        "from 'clearly not cost-effective regardless of threshold' -- you need the full curve.")
    )
  )
)

server <- function(input, output, session) {

  psa_data <- reactive({
    set.seed(1001)
    n <- 2000
    # Case Study A: chronic-disease Markov model -- modest incremental
    # cost and QALY gain, genuinely close to typical thresholds
    inc_cost_a <- rnorm(n, 18000, 6000)
    inc_qaly_a <- rnorm(n, 0.45, 0.15)

    # Case Study B: oncology PSM -- large incremental cost, modest QALY
    # gain, ICER far above typical thresholds
    inc_cost_b <- rnorm(n, 95000, 20000)
    inc_qaly_b <- rnorm(n, 0.6, 0.2)

    list(a = data.frame(inc_cost = inc_cost_a, inc_qaly = inc_qaly_a),
         b = data.frame(inc_cost = inc_cost_b, inc_qaly = inc_qaly_b))
  })

  ceac_curves <- reactive({
    psa <- psa_data()
    wtp_grid <- seq(0, 150000, by = 2000)

    p_ce_a <- sapply(wtp_grid, function(w) {
      nmb <- w * psa$a$inc_qaly - psa$a$inc_cost
      mean(nmb > 0)
    })
    p_ce_b <- sapply(wtp_grid, function(w) {
      nmb <- w * psa$b$inc_qaly - psa$b$inc_cost
      mean(nmb > 0)
    })

    data.frame(wtp = rep(wtp_grid, 2), p_ce = c(p_ce_a, p_ce_b),
               case_study = rep(c("Case Study A (chronic disease)", "Case Study B (oncology)"), each = length(wtp_grid)))
  })

  output$ceacPlot <- renderPlot({
    df <- ceac_curves()
    psa <- psa_data()
    wtp <- input$wtp

    p_a_at_wtp <- mean((wtp * psa$a$inc_qaly - psa$a$inc_cost) > 0)
    p_b_at_wtp <- mean((wtp * psa$b$inc_qaly - psa$b$inc_cost) > 0)

    ggplot(df, aes(x = wtp, y = p_ce, color = case_study)) +
      geom_line(linewidth = 1.3) +
      geom_vline(xintercept = wtp, linetype = "dashed", color = "grey50") +
      geom_point(data = data.frame(wtp = c(wtp, wtp), p_ce = c(p_a_at_wtp, p_b_at_wtp),
                                    case_study = c("Case Study A (chronic disease)", "Case Study B (oncology)")),
                 aes(x = wtp, y = p_ce, color = case_study), size = 5) +
      scale_color_manual(values = c("Case Study A (chronic disease)" = "#2166ac",
                                     "Case Study B (oncology)" = "#d6604d"), name = NULL) +
      ylim(0, 1) +
      labs(x = "Willingness-to-pay threshold ($/QALY)", y = "P(cost-effective)",
           title = "CEAC curves: Case Study A vs. Case Study B") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "top")
  })

  output$ceacOut <- renderPrint({
    psa <- psa_data()
    wtp <- input$wtp
    p_a <- mean((wtp * psa$a$inc_qaly - psa$a$inc_cost) > 0)
    p_b <- mean((wtp * psa$b$inc_qaly - psa$b$inc_cost) > 0)
    cat(sprintf("At WTP = $%s/QALY:\n", format(wtp, big.mark = ",")))
    cat(sprintf("  Case Study A: P(cost-effective) = %.1f%%\n", p_a * 100))
    cat(sprintf("  Case Study B: P(cost-effective) = %.1f%%\n", p_b * 100))
  })

  output$interpretation <- renderText({
    psa <- psa_data()
    wtp <- input$wtp
    p_a <- mean((wtp * psa$a$inc_qaly - psa$a$inc_cost) > 0)
    p_b <- mean((wtp * psa$b$inc_qaly - psa$b$inc_cost) > 0)

    p_a_20k <- mean((20000 * psa$a$inc_qaly - psa$a$inc_cost) > 0)
    p_a_50k <- mean((50000 * psa$a$inc_qaly - psa$a$inc_cost) > 0)

    sprintf(paste0("At WTP=$%s: Case Study A is %.0f%% likely cost-effective, Case Study B is only ",
                   "%.0f%% likely cost-effective. Between WTP=$20,000 and $50,000, Case Study A's ",
                   "probability swings from %.0f%% to %.0f%% -- a genuinely close call that depends ",
                   "heavily on which threshold a payer uses. Case Study B stays low across the whole ",
                   "range shown -- try dragging the slider all the way to $150,000 and notice how ",
                   "little its curve moves by comparison."),
            format(wtp, big.mark = ","), p_a * 100, p_b * 100, p_a_20k * 100, p_a_50k * 100)
  })
}

shinyApp(ui, server)
