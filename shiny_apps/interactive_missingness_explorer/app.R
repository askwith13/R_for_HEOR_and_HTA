library(shiny)
library(naniar)
library(visdat)
library(ggplot2)
library(dplyr)

# Interactive Missingness Explorer
# Companion to Chapter 7, SS7.2: filter a simulated multi-site trial
# extract by site/arm/variable via dropdowns; naniar::vis_miss() and
# gg_miss_var() plots regenerate live rather than being pre-generated
# as static figures.

ui <- fluidPage(
  titlePanel("Interactive Missingness Explorer"),
  p("Companion app for Chapter 7, \u00a77.2 (Missing Data). A simulated ",
    "multi-site trial extract (3 sites, 2 arms, 400 patients, 6 ",
    "variables) has deliberately uneven missingness -- one site has ",
    "worse data completeness than the others, and one variable has more ",
    "missingness in the intervention arm. Filter by site and arm and ",
    "watch the real `naniar::vis_miss()` and `naniar::gg_miss_var()` ",
    "plots regenerate live, rather than being static figures computed ",
    "once on the full dataset."),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("sites", "Sites to include",
                         choices = c("Site A", "Site B", "Site C"),
                         selected = c("Site A", "Site B", "Site C")),
      checkboxGroupInput("arms", "Arms to include",
                         choices = c("Control", "Intervention"),
                         selected = c("Control", "Intervention")),
      helpText("Try isolating just Site C to see its worse completeness, ",
               "or isolating just the Intervention arm to see the ",
               "variable-specific missingness pattern.")
    ),
    mainPanel(
      plotOutput("visMissPlot", height = "350px"),
      plotOutput("ggMissVarPlot", height = "300px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A single missingness summary computed on the FULL pooled dataset can completely hide a ",
        "site- or arm-specific missingness problem -- if one site's missingness is much worse than ",
        "the others, it gets averaged away in a pooled number, understating the severity where it ",
        "actually matters. Filtering interactively by site/arm (rather than only ever looking at ",
        "one static, pre-generated plot of the whole dataset) is often how a real missingness ",
        "problem concentrated in one subgroup gets discovered in the first place.")
    )
  )
)

server <- function(input, output, session) {

  full_data <- reactive({
    set.seed(321)
    n <- 400
    site <- sample(c("Site A", "Site B", "Site C"), n, replace = TRUE, prob = c(0.4, 0.35, 0.25))
    arm <- sample(c("Control", "Intervention"), n, replace = TRUE)

    age <- rnorm(n, 55, 12)
    baseline_severity <- rnorm(n, 5, 2)
    utility_baseline <- rbeta(n, 5, 3)
    utility_followup <- rbeta(n, 5, 3)
    cost <- rlnorm(n, log(5000), 0.5)
    adverse_event <- rbinom(n, 1, 0.2)

    df <- data.frame(id = seq_len(n), site = site, arm = arm, age = age,
                      baseline_severity = baseline_severity,
                      utility_baseline = utility_baseline,
                      utility_followup = utility_followup,
                      cost = cost, adverse_event = adverse_event)

    # Deliberately uneven missingness: Site C has worse data completeness
    # overall, and utility_followup has more missingness in the
    # Intervention arm (patients who respond poorly drop out more)
    site_c_idx <- which(df$site == "Site C")
    df$utility_followup[sample(site_c_idx, round(length(site_c_idx) * 0.45))] <- NA
    df$cost[sample(site_c_idx, round(length(site_c_idx) * 0.3))] <- NA

    intervention_idx <- which(df$arm == "Intervention")
    df$utility_followup[sample(intervention_idx, round(length(intervention_idx) * 0.25))] <- NA

    # Small amount of baseline missingness everywhere for realism
    df$baseline_severity[sample(n, round(n * 0.03))] <- NA
    df$adverse_event[sample(n, round(n * 0.02))] <- NA

    df
  })

  filtered_data <- reactive({
    df <- full_data()
    df <- df[df$site %in% input$sites & df$arm %in% input$arms, ]
    df[, c("age", "baseline_severity", "utility_baseline", "utility_followup", "cost", "adverse_event")]
  })

  output$visMissPlot <- renderPlot({
    df <- filtered_data()
    validate(need(nrow(df) > 0, "No records match the current site/arm filter."))
    vis_miss(df) + labs(title = sprintf("Missingness pattern (n = %d records)", nrow(df)))
  })

  output$ggMissVarPlot <- renderPlot({
    df <- filtered_data()
    validate(need(nrow(df) > 0, "No records match the current site/arm filter."))
    gg_miss_var(df, show_pct = TRUE) + labs(title = "Missingness by variable")
  })

  output$interpretation <- renderText({
    df <- filtered_data()
    if (nrow(df) == 0) return("No records match the current filter.")
    pct_missing_overall <- round(mean(is.na(df)) * 100, 1)
    pct_missing_followup <- round(mean(is.na(df$utility_followup)) * 100, 1)
    sprintf(paste0("With sites = {%s} and arms = {%s}: %d records, %.1f%% of all cells missing ",
                   "overall, %.1f%% of utility_followup specifically missing. Compare this to the ",
                   "full-dataset summary (all sites, all arms) to see whether your current filter ",
                   "reveals a worse (or better) missingness picture than the pooled average."),
            paste(input$sites, collapse = ", "), paste(input$arms, collapse = ", "),
            nrow(df), pct_missing_overall, pct_missing_followup)
  })
}

shinyApp(ui, server)
