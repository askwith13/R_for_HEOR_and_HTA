library(shiny)
library(ggplot2)

# MAIC Weight & ESS Explorer
# Companion to Chapter 13, SS13.2: sliders adjust how far the IPD trial's
# covariate distribution sits from the AgD trial's target means; method-
# of-moments weights, Effective Sample Size (ESS), and the weighted
# treatment effect recompute live -- showing a large ESS loss is a
# credibility red flag that should be watched happening, not just read
# about.

set.seed(2024)
n_ipd <- 300
# Simulated IPD trial covariate: age (baseline distribution)
age_ipd <- rnorm(n_ipd, mean = 55, sd = 10)
# Simulated true treatment effect (log HR), with a genuine age-effect-modifier
true_log_hr_base <- -0.4
age_interaction <- 0.01 # each year of age above 55 shifts the effect slightly

ui <- fluidPage(
  titlePanel("MAIC Weight & ESS Explorer"),
  p("Companion app for Chapter 13, \u00a713.2 (Population-Adjusted Indirect ",
    "Comparisons). A simulated 300-patient IPD trial (mean age 55) is ",
    "re-weighted via Matching-Adjusted Indirect Comparison (MAIC) to match a ",
    "target age mean from an aggregate-data (AgD) trial. As the target mean ",
    "moves further from the IPD trial's own mean, watch effective sample ",
    "size (ESS) shrink and the weighted effect estimate shift."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("target_age_mean", "AgD trial's target population mean age",
                  40, 75, 55, step = 1),
      helpText("IPD trial's own (unweighted) mean age is 55. As the target ",
               "moves away from 55, weights become more extreme and ESS falls.")
    ),
    mainPanel(
      plotOutput("weightPlot", height = "350px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A large drop in ESS (well below the original IPD sample size) is a ",
        "credibility red flag, not just a technical footnote \u2014 it means the ",
        "re-weighted analysis is effectively behaving as if it had far fewer ",
        "patients than the trial actually enrolled, because a small number of ",
        "unusual patients are carrying disproportionate weight. Push the target ",
        "age mean toward the extremes (40 or 75) and watch ESS collapse; a ",
        "published MAIC with an ESS that has shrunk by 70%\u201390% should prompt ",
        "real scepticism about how far the matched population has drifted from ",
        "what the trial actually observed.")
    )
  )
)

server <- function(input, output, session) {

  maic_result <- reactive({
    target_mean <- input$target_age_mean

    # Method-of-moments MAIC weighting on a single covariate (age):
    # find alpha such that weighted mean of (age - target_mean) = 0
    centered <- age_ipd - target_mean
    obj <- function(a) (sum(centered * exp(a * centered)) )^2
    fit <- optim(0, obj, method = "Brent", lower = -1, upper = 1)
    alpha <- fit$par
    w <- exp(alpha * centered)
    w <- w / sum(w) * n_ipd # normalise to sum to n (conventional display scale)

    ess <- (sum(w))^2 / sum(w^2)

    # True individual log-HR with age effect modification, weighted mean
    true_effect_i <- true_log_hr_base + age_interaction * (age_ipd - 55)
    weighted_effect <- sum(w * true_effect_i) / sum(w)
    unweighted_effect <- mean(true_effect_i)

    list(w = w, ess = ess, weighted_effect = weighted_effect,
         unweighted_effect = unweighted_effect, target_mean = target_mean)
  })

  output$weightPlot <- renderPlot({
    r <- maic_result()
    df <- data.frame(age = age_ipd, weight = r$w)
    ggplot(df, aes(x = age, y = weight)) +
      geom_point(alpha = 0.5, color = "#2166ac") +
      geom_vline(xintercept = r$target_mean, linetype = "dashed", color = "#d6604d") +
      geom_vline(xintercept = 55, linetype = "dotted", color = "grey40") +
      labs(x = "Patient age (IPD trial)", y = "MAIC weight",
           title = "Patient-level MAIC weights",
           subtitle = "Red dashed = target mean age; grey dotted = IPD trial's own mean age") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    r <- maic_result()
    ess_loss_pct <- (1 - r$ess / n_ipd) * 100
    sprintf(paste0("Target age mean: %d (IPD trial's own mean: 55). Effective sample size (ESS) ",
                   "has dropped from %d to %.0f \u2014 a %.1f%% loss. Weighted treatment effect: ",
                   "%.3f (log HR) vs. the trial's own unweighted effect of %.3f. The further ",
                   "the target mean sits from the trial's own population, the more the weights ",
                   "concentrate on a shrinking subset of unusual patients."),
            r$target_mean, n_ipd, r$ess, ess_loss_pct, r$weighted_effect, r$unweighted_effect)
  })
}

shinyApp(ui, server)
