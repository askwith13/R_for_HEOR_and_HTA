library(shiny)
library(ggplot2)
library(forcats)

# Tornado Diagram Parameter-Range Explorer
# Companion to Chapter 25, SS25.2: sliders for each of 5 one-way
# sensitivity analysis parameters' low/high bounds re-run the chapter's
# incremental_nmb() function live, redrawing the tornado diagram and
# re-sorting bars by swing width in real time -- showing a tornado
# ranks parameters by influence on the decision, not by how uncertain
# they intuitively feel.

# Base-case values (reused 4-state TB Markov model framing from Ch.19/25)
base_params <- list(
  p_cure = 0.85,
  p_fail_death = 0.08,
  discount_rate = 0.035,
  drug_cost = 1200,
  util_ontx = 0.80
)

WTP <- 50000

incremental_nmb <- function(p_cure, p_fail_death, discount_rate, drug_cost, util_ontx) {
  # Simplified reduced-form NMB function, structurally consistent with the
  # chapter's TB Markov model: curing more patients and lower on-treatment
  # disutility raise NMB; higher drug cost and higher discount rate (which
  # shrinks future QALY gains relative to near-term cost) lower it.
  qaly_gain <- p_cure * 2.0 * util_ontx - p_fail_death * 0.5
  qaly_gain_disc <- qaly_gain / (1 + discount_rate)^2
  cost <- drug_cost * 6 # 6-month course
  nmb <- WTP * qaly_gain_disc - cost
  nmb
}

base_nmb <- do.call(incremental_nmb, base_params)

ui <- fluidPage(
  titlePanel("Tornado Diagram Parameter-Range Explorer"),
  p("Companion app for Chapter 25, \u00a725.2 (Handling Uncertainty). Five ",
    "one-way sensitivity analysis parameters from the chapter's TB Markov ",
    "model can each be dragged across a low/high range; the tornado diagram ",
    "re-sorts live by swing width (influence on NMB), not by how uncertain ",
    "a parameter intuitively feels."),
  sidebarLayout(
    sidebarPanel(
      h4("Parameter ranges (low, high)"),
      sliderInput("p_cure_range", "New-regimen cure probability",
                  0.5, 1.0, c(0.75, 0.95), step = 0.01),
      sliderInput("p_fail_death_range", "P(Fail\u2192Death), shared",
                  0.01, 0.3, c(0.04, 0.15), step = 0.01),
      sliderInput("discount_range", "Annual discount rate",
                  0, 0.08, c(0.015, 0.06), step = 0.005),
      sliderInput("drug_cost_range", "New-regimen drug cost (per month)",
                  200, 3000, c(800, 1800), step = 50),
      sliderInput("util_range", "On-treatment utility",
                  0.5, 1.0, c(0.70, 0.90), step = 0.01)
    ),
    mainPanel(
      plotOutput("tornadoPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A tornado diagram ranks parameters by how much they move the DECISION ",
        "(NMB here), not by how uncertain the parameter intuitively feels. A ",
        "parameter you're not very confident in can still rank low if plausible ",
        "variation in it barely moves NMB, while a parameter you're fairly ",
        "confident about can rank high if even a small range swings NMB a lot. ",
        "Try widening the discount-rate range \u2014 even though analysts are often ",
        "MORE confident about the discount rate than about cure probability, ",
        "watch whether it still outranks cure probability in influence.")
    )
  )
)

server <- function(input, output, session) {

  swings <- reactive({
    params <- list(
      p_cure = input$p_cure_range,
      p_fail_death = input$p_fail_death_range,
      discount_rate = input$discount_range,
      drug_cost = input$drug_cost_range,
      util_ontx = input$util_range
    )
    labels <- c(
      p_cure = "Cure probability",
      p_fail_death = "P(Fail\u2192Death)",
      discount_rate = "Discount rate",
      drug_cost = "Drug cost",
      util_ontx = "On-treatment utility"
    )

    rows <- lapply(names(params), function(pname) {
      lo_val <- params[[pname]][1]
      hi_val <- params[[pname]][2]

      args_lo <- base_params
      args_lo[[pname]] <- lo_val
      nmb_lo <- do.call(incremental_nmb, args_lo)

      args_hi <- base_params
      args_hi[[pname]] <- hi_val
      nmb_hi <- do.call(incremental_nmb, args_hi)

      data.frame(
        param = labels[[pname]],
        nmb_lo = min(nmb_lo, nmb_hi),
        nmb_hi = max(nmb_lo, nmb_hi),
        swing = abs(nmb_hi - nmb_lo)
      )
    })
    do.call(rbind, rows)
  })

  output$tornadoPlot <- renderPlot({
    df <- swings()
    df$param <- fct_reorder(df$param, df$swing)

    ggplot(df, aes(y = param)) +
      geom_vline(xintercept = base_nmb, linetype = "dashed", color = "black") +
      geom_segment(aes(x = nmb_lo, xend = nmb_hi, yend = param), linewidth = 8, color = "#2166ac") +
      labs(x = "Incremental NMB", y = NULL,
           title = "Tornado diagram: NMB range by parameter, sorted by swing width",
           subtitle = sprintf("Dashed line = base-case NMB ($%s)", format(round(base_nmb), big.mark = ","))) +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    df <- swings()
    df <- df[order(-df$swing), ]
    top <- df[1, ]
    bottom <- df[nrow(df), ]
    sprintf(paste0("Ranked by swing width: '%s' is the most influential parameter ",
                   "(NMB ranges $%s across its slider range), while '%s' is the least ",
                   "influential (range of only $%s). The most influential parameter is ",
                   "not always the one you'd intuitively guess is most uncertain."),
            top$param, format(round(top$swing), big.mark = ","),
            bottom$param, format(round(bottom$swing), big.mark = ","))
  })
}

shinyApp(ui, server)
