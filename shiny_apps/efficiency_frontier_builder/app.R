library(shiny)
library(ggplot2)
library(dplyr)

# Efficiency Frontier Builder
# Illustrates Chapter 4 SS4.7-4.8: simple and extended dominance pruning,
# and the cost-effectiveness efficiency frontier.
# Reader edits cost/QALY for up to 5 treatments; the app re-runs dominance
# pruning live and redraws the CE-plane with dominated points greyed out
# and the frontier connected.

n_treatments <- 5
default_names <- c("A", "B", "C", "D", "E")
default_costs <- c(1000, 3000, 5000, 9000, 15000)
default_qalys <- c(0.50, 0.70, 0.75, 0.95, 1.00)

ui <- fluidPage(
  titlePanel("Efficiency Frontier Builder"),
  p("Companion app for Chapter 4, \u00a74.7\u20134.8 (Core Concepts in Health Economics). ",
    "Edit each treatment's cost and QALYs below; simple and extended dominance ",
    "pruning re-runs live, and the cost-effectiveness plane redraws with ",
    "dominated points greyed out and the efficient frontier connected."),
  sidebarLayout(
    sidebarPanel(
      h4("Treatment inputs"),
      lapply(seq_len(n_treatments), function(i) {
        fluidRow(
          column(4, textInput(paste0("name", i), paste("Name", i), value = default_names[i])),
          column(4, numericInput(paste0("cost", i), "Cost", value = default_costs[i], min = 0, step = 100)),
          column(4, numericInput(paste0("qaly", i), "QALYs", value = default_qalys[i], min = 0, step = 0.01))
        )
      }),
      hr(),
      helpText("Dominated points (simple or extended) are flagged automatically ",
               "and excluded from the connected frontier line.")
    ),
    mainPanel(
      plotOutput("cePlane", height = "450px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      h4("Dominance classification"),
      tableOutput("dominanceTable"),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "An extended-dominated treatment is NOT beaten outright by any single other ",
        "treatment on both cost and QALYs \u2014 that's simple dominance. It is beaten ",
        "by a hypothetical mix of its two frontier neighbours that would deliver the ",
        "same QALYs for less cost (or more QALYs for the same cost), which is why it ",
        "still gets pruned even though it looks \"undominated\" at first glance. Try ",
        "moving treatment C's cost toward 4000 \u2014 watch its status flip from Extended ",
        "dominance back to Efficient once its own ICER vs. B stops exceeding D's ICER vs. B.")
    )
  )
)

server <- function(input, output, session) {

  treatments <- reactive({
    df <- data.frame(
      name = sapply(seq_len(n_treatments), function(i) input[[paste0("name", i)]]),
      cost = sapply(seq_len(n_treatments), function(i) input[[paste0("cost", i)]]),
      qaly = sapply(seq_len(n_treatments), function(i) input[[paste0("qaly", i)]]),
      stringsAsFactors = FALSE
    )
    df <- df[!is.na(df$cost) & !is.na(df$qaly), ]
    df
  })

  # Simple + extended dominance pruning, matching Chapter 4's worked logic:
  # 1. Simple dominance: a treatment is dominated if another treatment has
  #    both lower (or equal) cost AND higher (or equal) QALYs, with at least
  #    one strict inequality.
  # 2. Extended (weak/economic) dominance: among the simple-dominance survivors
  #    sorted by QALY, a treatment is dominated if its ICER vs. the next-lower
  #    QALY survivor exceeds the ICER of a higher-QALY survivor vs that same
  #    lower point (i.e. it lies above the frontier connecting its neighbours).
  frontier_result <- reactive({
    df <- treatments()
    if (nrow(df) < 2) {
      df$status <- "Insufficient data"
      return(df)
    }

    df$status <- "Efficient"

    # Simple dominance check
    for (i in seq_len(nrow(df))) {
      for (j in seq_len(nrow(df))) {
        if (i == j) next
        cost_le <- df$cost[j] <= df$cost[i]
        qaly_ge <- df$qaly[j] >= df$qaly[i]
        strict <- (df$cost[j] < df$cost[i]) || (df$qaly[j] > df$qaly[i])
        if (cost_le && qaly_ge && strict) {
          df$status[i] <- "Simple dominance"
        }
      }
    }

    # Extended dominance among simple-dominance survivors
    survivors <- df[df$status == "Efficient", ]
    survivors <- survivors[order(survivors$qaly), ]
    if (nrow(survivors) >= 3) {
      repeat {
        changed <- FALSE
        if (nrow(survivors) < 3) break
        for (k in 2:(nrow(survivors) - 1)) {
          icer_lo <- (survivors$cost[k] - survivors$cost[k - 1]) /
            (survivors$qaly[k] - survivors$qaly[k - 1])
          icer_hi <- (survivors$cost[k + 1] - survivors$cost[k]) /
            (survivors$qaly[k + 1] - survivors$qaly[k])
          if (is.finite(icer_lo) && is.finite(icer_hi) && icer_lo > icer_hi) {
            df$status[df$name == survivors$name[k]] <- "Extended dominance"
            survivors <- survivors[survivors$name != survivors$name[k], ]
            changed <- TRUE
            break
          }
        }
        if (!changed) break
      }
    }
    df
  })

  output$cePlane <- renderPlot({
    df <- frontier_result()
    req(nrow(df) >= 1)

    frontier_pts <- df[df$status == "Efficient", ]
    frontier_pts <- frontier_pts[order(frontier_pts$qaly), ]

    p <- ggplot(df, aes(x = qaly, y = cost, label = name)) +
      geom_point(aes(color = status), size = 4) +
      geom_text(vjust = -1, size = 4) +
      labs(x = "QALYs", y = "Cost", color = "Dominance status",
           title = "Cost-effectiveness plane: efficiency frontier") +
      theme_minimal(base_size = 13) +
      scale_color_manual(values = c(
        "Efficient" = "#2166ac",
        "Simple dominance" = "#999999",
        "Extended dominance" = "#d6604d",
        "Insufficient data" = "#999999"
      ))

    if (nrow(frontier_pts) >= 2) {
      p <- p + geom_line(data = frontier_pts, aes(x = qaly, y = cost),
                          color = "#2166ac", linewidth = 1, inherit.aes = FALSE)
    }
    p
  })

  output$dominanceTable <- renderTable({
    df <- frontier_result()
    df$cost <- round(df$cost, 2)
    df$qaly <- round(df$qaly, 3)
    df[, c("name", "cost", "qaly", "status")]
  })

  output$interpretation <- renderText({
    df <- frontier_result()
    n_eff <- sum(df$status == "Efficient")
    n_simple <- sum(df$status == "Simple dominance")
    n_ext <- sum(df$status == "Extended dominance")
    parts <- c(sprintf("%d treatment(s) on the efficient frontier (blue line)", n_eff))
    if (n_simple > 0) parts <- c(parts, sprintf("%d simply dominated (grey, strictly beaten by one other treatment)", n_simple))
    if (n_ext > 0) parts <- c(parts, sprintf("%d extended-dominated (red, beaten by a mix of two frontier treatments)", n_ext))
    paste0(paste(parts, collapse = "; "), ".")
  })
}

shinyApp(ui, server)
