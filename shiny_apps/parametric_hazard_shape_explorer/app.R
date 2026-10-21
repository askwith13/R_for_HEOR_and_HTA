library(shiny)
library(ggplot2)
library(flexsurv)
library(survival)

# Parametric Hazard Shape Explorer
# Companion to Chapter 10, SS10.2: select a distribution family and drag
# shape/scale sliders; the survival/hazard curves overlay live against a
# synthetic Kaplan-Meier curve, extended to a user-set extrapolation
# horizon. Makes visible why "fits the trial period" and "extrapolates
# plausibly" are two different things.

set.seed(42)
# Synthetic trial data: Weibull(shape=1.3, scale=24) survival times,
# administrative censoring at 18 months.
n_patients <- 200
true_times <- rweibull(n_patients, shape = 1.3, scale = 24)
censor_time <- 18
obs_time <- pmin(true_times, censor_time)
obs_event <- as.numeric(true_times <= censor_time)
km_fit <- survfit(Surv(obs_time, obs_event) ~ 1)

ui <- fluidPage(
  titlePanel("Parametric Hazard Shape Explorer"),
  p("Companion app for Chapter 10, \u00a710.2 (Survival Analysis for Economic Evaluation). ",
    "A synthetic 200-patient trial (Weibull-generated, administratively censored ",
    "at 18 months) is shown as the solid Kaplan-Meier step curve. Choose a ",
    "parametric family and drag its shape/scale parameters; the fitted survival ",
    "and hazard curves redraw live, extrapolated to your chosen horizon."),
  sidebarLayout(
    sidebarPanel(
      selectInput("dist", "Distribution family",
                  choices = c("Exponential" = "exp", "Weibull" = "weibull",
                              "Gompertz" = "gompertz", "Log-logistic" = "llogis",
                              "Log-normal" = "lnorm"),
                  selected = "weibull"),
      conditionalPanel(
        condition = "input.dist == 'exp'",
        sliderInput("rate_exp", "Rate", 0.001, 0.2, 0.03, step = 0.001)
      ),
      conditionalPanel(
        condition = "input.dist == 'weibull'",
        sliderInput("shape_weibull", "Shape", 0.3, 3, 1.3, step = 0.05),
        sliderInput("scale_weibull", "Scale", 5, 60, 24, step = 1)
      ),
      conditionalPanel(
        condition = "input.dist == 'gompertz'",
        sliderInput("shape_gompertz", "Shape", -0.2, 0.2, 0.02, step = 0.005),
        sliderInput("rate_gompertz", "Rate", 0.001, 0.2, 0.03, step = 0.001)
      ),
      conditionalPanel(
        condition = "input.dist == 'llogis'",
        sliderInput("shape_llogis", "Shape", 0.5, 5, 1.8, step = 0.1),
        sliderInput("scale_llogis", "Scale", 5, 60, 20, step = 1)
      ),
      conditionalPanel(
        condition = "input.dist == 'lnorm'",
        sliderInput("meanlog_lnorm", "Meanlog", 1, 5, 3, step = 0.1),
        sliderInput("sdlog_lnorm", "SDlog", 0.1, 2, 0.8, step = 0.05)
      ),
      hr(),
      sliderInput("horizon", "Extrapolation horizon (months)", 18, 240, 120, step = 6),
      helpText("Trial follow-up ends at month 18 (dashed vertical line); ",
               "everything beyond that is extrapolation.")
    ),
    mainPanel(
      plotOutput("survPlot", height = "350px"),
      plotOutput("hazPlot", height = "300px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A curve can overlay the black KM line almost perfectly within the trial ",
        "period (up to month 18) while implying very different long-run survival ",
        "once extrapolated. Try the Exponential family (constant hazard) vs. Weibull ",
        "with shape > 1 (increasing hazard) \u2014 both can look reasonable up to month ",
        "18, but the Exponential curve keeps gliding downward far more slowly beyond ",
        "it. \"Fits the trial period\" and \"extrapolates plausibly\" are genuinely ",
        "different claims; NICE DSU TSD 14 requires both AIC/BIC AND visual/clinical ",
        "plausibility checks for exactly this reason.")
    )
  )
)

server <- function(input, output, session) {

  t_grid <- reactive(seq(0.1, input$horizon, length.out = 400))

  curves <- reactive({
    tg <- t_grid()
    switch(input$dist,
      exp = {
        list(surv = pexp(tg, rate = input$rate_exp, lower.tail = FALSE),
             haz = rep(input$rate_exp, length(tg)))
      },
      weibull = {
        sh <- input$shape_weibull; sc <- input$scale_weibull
        list(surv = pweibull(tg, shape = sh, scale = sc, lower.tail = FALSE),
             haz = hweibull(tg, shape = sh, scale = sc))
      },
      gompertz = {
        sh <- input$shape_gompertz; rt <- input$rate_gompertz
        list(surv = 1 - pgompertz(tg, shape = sh, rate = rt),
             haz = hgompertz(tg, shape = sh, rate = rt))
      },
      llogis = {
        sh <- input$shape_llogis; sc <- input$scale_llogis
        list(surv = pllogis(tg, shape = sh, scale = sc, lower.tail = FALSE),
             haz = hllogis(tg, shape = sh, scale = sc))
      },
      lnorm = {
        ml <- input$meanlog_lnorm; sl <- input$sdlog_lnorm
        list(surv = plnorm(tg, meanlog = ml, sdlog = sl, lower.tail = FALSE),
             haz = dlnorm(tg, meanlog = ml, sdlog = sl) /
                   plnorm(tg, meanlog = ml, sdlog = sl, lower.tail = FALSE))
      }
    )
  })

  output$survPlot <- renderPlot({
    tg <- t_grid()
    cv <- curves()
    km_df <- data.frame(time = km_fit$time, surv = km_fit$surv)

    ggplot() +
      geom_step(data = km_df, aes(x = time, y = surv), color = "black", linewidth = 0.8) +
      geom_line(data = data.frame(time = tg, surv = cv$surv),
                aes(x = time, y = surv), color = "#2166ac", linewidth = 1) +
      geom_vline(xintercept = 18, linetype = "dashed", color = "#d6604d") +
      coord_cartesian(ylim = c(0, 1)) +
      labs(x = "Time (months)", y = "Survival probability",
           title = "Observed KM (black) vs. fitted parametric curve (blue), extrapolated") +
      theme_minimal(base_size = 13)
  })

  output$hazPlot <- renderPlot({
    tg <- t_grid()
    cv <- curves()
    ggplot(data.frame(time = tg, hazard = cv$haz), aes(x = time, y = hazard)) +
      geom_line(color = "#2166ac", linewidth = 1) +
      geom_vline(xintercept = 18, linetype = "dashed", color = "#d6604d") +
      labs(x = "Time (months)", y = "Hazard", title = "Implied hazard function") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    tg <- t_grid()
    cv <- curves()
    # Survival at the end of trial follow-up (18mo) vs. at the extrapolation horizon
    idx_18 <- which.min(abs(tg - 18))
    surv_at_18 <- cv$surv[idx_18]
    surv_at_horizon <- cv$surv[length(cv$surv)]
    haz_start <- cv$haz[1]
    haz_end <- cv$haz[length(cv$haz)]
    shape_desc <- if (haz_end > haz_start * 1.05) {
      "rising (patients accumulate risk over time)"
    } else if (haz_end < haz_start * 0.95) {
      "falling (patients who survive longest face the lowest ongoing risk)"
    } else {
      "roughly flat (constant risk regardless of time already survived)"
    }
    sprintf(paste0("At month 18 (end of observed follow-up), fitted survival = %.1f%%. ",
                   "Extrapolated out to month %d, survival falls to %.1f%% \u2014 ",
                   "%.1f percentage points of that gap happens entirely in the ",
                   "extrapolated region, not the observed data. The hazard is %s."),
            surv_at_18 * 100, round(input$horizon), surv_at_horizon * 100,
            (surv_at_18 - surv_at_horizon) * 100, shape_desc)
  })
}

shinyApp(ui, server)
