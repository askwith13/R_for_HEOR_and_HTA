# Extracted from ch29_shiny_apps.typ, lines 518-543
# Section: == 29.8 Case study: a transparent, reviewable submission-ready model app
# Chapter: 29

ui <- fluidPage(
  titlePanel("TB Markov Model -- Interactive PSA Explorer (ERG Review Build)"),
  sidebarLayout(
    sidebarPanel(
      numericInput("tx_success_prob", "Treatment success probability",
                   value = 0.85, min = 0, max = 1, step = 0.01),
      numericInput("relapse_rate", "Annual relapse rate",
                   value = 0.05, min = 0, max = 0.5, step = 0.01),
      numericInput("discount_rate", "Discount rate (%)",
                   value = 3.5, min = 0, max = 10, step = 0.5),
      numericInput("wtp", "Willingness-to-pay threshold (£/QALY)",
                   value = 20000, min = 1000, max = 100000, step = 1000),
      numericInput("n_psa", "Number of PSA iterations",
                   value = 1000, min = 100, max = 10000, step = 100),
      actionButton("run_psa", "Run PSA", class = "btn-primary"),
      downloadButton("download_report", "Download full audited report")
    ),
    mainPanel(
      plotOutput("ce_plane"),
      plotOutput("ceac"),
      verbatimTextOutput("icer_summary")
    )
  )
)
