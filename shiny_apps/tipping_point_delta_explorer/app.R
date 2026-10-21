library(shiny)
library(ggplot2)
library(dplyr)

# Tipping-Point Delta Explorer
# Companion to Chapter 7, SS7.5: a delta slider (applied to imputed
# intervention-arm values) live-recomputes and re-plots the risk
# difference/ICER vs. WTP, highlighting the tipping point -- lets a
# reviewer directly probe how implausible a departure from MAR would need
# to be to flip the conclusion.

ui <- fluidPage(
  titlePanel("Tipping-Point Delta Explorer"),
  p("Companion app for Chapter 7, \u00a77.5 (Missing Data). Missing utility ",
    "values in the intervention arm are imputed with the mean of OBSERVED ",
    "intervention-arm values (a simplified stand-in for a full MAR-based ",
    "multiple imputation via mice::mice()), then a DELTA is added to every ",
    "imputed (not observed) intervention-arm value to simulate a specific ",
    "departure from MAR -- representing the idea that missing patients may ",
    "have systematically worse (or better) outcomes than MAR assumes. Drag ",
    "delta and watch the estimated treatment effect move; the 'tipping ",
    "point' is where it crosses zero (or crosses cost-effectiveness)."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("delta", "Delta applied to imputed intervention-arm values",
                  -0.3, 0.3, 0, step = 0.01),
      sliderInput("missing_rate", "Intervention-arm missingness rate", 0.1, 0.5, 0.25, step = 0.05),
      helpText("Negative delta = imputed missing patients did WORSE than ",
               "MAR-based imputation assumes (a common sensitivity-analysis ",
               "direction, since dropout is often linked to worse outcomes).")
    ),
    mainPanel(
      plotOutput("tippingPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A single MAR-based imputed estimate reports ONE number, as if MAR were simply ",
        "true -- but MAR is an untestable assumption, since the data itself cannot tell you ",
        "whether missing values would look like similar observed values or not. A ",
        "tipping-point analysis instead asks the more honest question: 'how large would an ",
        "MAR violation need to be before the conclusion changes?' If a very small, clinically ",
        "implausible delta flips the result, the conclusion is fragile; if it takes an extreme, ",
        "clinically implausible delta, the conclusion is robust to realistic MAR departures.")
    )
  )
)

server <- function(input, output, session) {

  base_data <- reactive({
    set.seed(55)
    n_per_arm <- 150
    true_control <- rnorm(n_per_arm, 0.70, 0.12)
    true_intervention <- rnorm(n_per_arm, 0.74, 0.12) # true effect: +0.04 (modest, plausibly fragile)

    data.frame(
      arm = rep(c("control", "intervention"), each = n_per_arm),
      true_utility = c(true_control, true_intervention)
    )
  })

  tipping_result <- reactive({
    df <- base_data()
    set.seed(99)
    n_int <- sum(df$arm == "intervention")
    is_missing <- rep(0, nrow(df))
    int_idx <- which(df$arm == "intervention")
    n_missing <- round(input$missing_rate * n_int)
    missing_idx <- sample(int_idx, n_missing)
    is_missing[missing_idx] <- 1

    df$observed_utility <- df$true_utility
    df$observed_utility[is_missing == 1] <- NA

    # Simple MAR-consistent imputation: impute missing intervention values
    # using the mean of OBSERVED intervention values (simplified single
    # imputation, standing in for a full mice() MAR imputation), then add delta
    obs_int_mean <- mean(df$observed_utility[df$arm == "intervention"], na.rm = TRUE)
    df$imputed_utility <- df$observed_utility
    df$imputed_utility[is_missing == 1] <- obs_int_mean + input$delta

    risk_diff <- mean(df$imputed_utility[df$arm == "intervention"]) - mean(df$imputed_utility[df$arm == "control"])
    list(df = df, risk_diff = risk_diff, obs_int_mean = obs_int_mean, n_missing = n_missing)
  })

  delta_sweep <- reactive({
    delta_grid <- seq(-0.3, 0.3, length.out = 61)
    df <- base_data()
    set.seed(99)
    n_int <- sum(df$arm == "intervention")
    is_missing <- rep(0, nrow(df))
    int_idx <- which(df$arm == "intervention")
    n_missing <- round(input$missing_rate * n_int)
    missing_idx <- sample(int_idx, n_missing)
    is_missing[missing_idx] <- 1
    df$observed_utility <- df$true_utility
    df$observed_utility[is_missing == 1] <- NA
    obs_int_mean <- mean(df$observed_utility[df$arm == "intervention"], na.rm = TRUE)
    control_mean <- mean(df$observed_utility[df$arm == "control"], na.rm = TRUE)

    rd_grid <- sapply(delta_grid, function(d) {
      imputed_int_mean <- (sum(df$observed_utility[df$arm == "intervention"], na.rm = TRUE) +
                              sum(is_missing[df$arm == "intervention"]) * (obs_int_mean + d)) / n_int
      imputed_int_mean - control_mean
    })
    data.frame(delta = delta_grid, risk_diff = rd_grid)
  })

  output$tippingPlot <- renderPlot({
    sweep <- delta_sweep()
    r <- tipping_result()
    tipping_delta <- sweep$delta[which.min(abs(sweep$risk_diff))]

    ggplot(sweep, aes(x = delta, y = risk_diff)) +
      geom_line(color = "#2166ac", linewidth = 1.2) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
      geom_vline(xintercept = input$delta, linetype = "dashed", color = "#d6604d") +
      annotate("point", x = tipping_delta, y = 0, color = "#2ca25f", size = 5) +
      labs(x = "Delta applied to imputed intervention-arm values", y = "Estimated risk difference (intervention \u2212 control)",
           title = "Tipping-point curve: risk difference vs. delta",
           subtitle = sprintf("Green point: tipping point (delta \u2248 %.3f). Red dashed: current slider.", tipping_delta)) +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    r <- tipping_result()
    sweep <- delta_sweep()
    tipping_delta <- sweep$delta[which.min(abs(sweep$risk_diff))]
    verdict <- if (r$risk_diff > 0) "still favours the intervention" else "has flipped to favour control"
    sprintf(paste0("At delta = %.2f (missingness rate %.0f%%): estimated risk difference = %.4f, ",
                   "which %s. The tipping point -- where the estimate crosses zero -- is at ",
                   "delta \u2248 %.3f. A tipping point close to zero delta means the conclusion is ",
                   "fragile to even small, clinically plausible MAR departures; a tipping point ",
                   "far from zero means the conclusion is robust."),
            input$delta, input$missing_rate * 100, r$risk_diff, verdict, tipping_delta)
  })
}

shinyApp(ui, server)
