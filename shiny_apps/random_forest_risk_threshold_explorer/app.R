library(shiny)
library(ggplot2)
library(randomForest)

# Random Forest Risk-Threshold / Confusion-Matrix Explorer
# Companion to Chapter 34, SS34.1: a slider for the predicted-probability
# cutoff used to classify a patient as "high-cost" recomputes a confusion
# matrix and accuracy/sensitivity/specificity live from a fitted random
# forest's predicted probabilities -- demonstrating that a single accuracy
# figure hides a sensitivity/specificity trade-off that shifts with the
# decision threshold.

set.seed(99)
n <- 1000
age <- rnorm(n, 55, 15)
n_comorbidities <- rpois(n, 1.5)
prior_admissions <- rpois(n, 0.8)
# True (latent) high-cost probability, genuinely driven by the covariates
logit_p <- -3 + 0.03 * age + 0.6 * n_comorbidities + 0.9 * prior_admissions
true_p <- 1 / (1 + exp(-logit_p))
high_cost <- rbinom(n, 1, true_p)

df <- data.frame(age = age, n_comorbidities = n_comorbidities,
                  prior_admissions = prior_admissions,
                  high_cost = factor(high_cost, levels = c(0, 1), labels = c("No", "Yes")))

train_idx <- sample(seq_len(n), size = 0.7 * n)
train_df <- df[train_idx, ]
test_df <- df[-train_idx, ]

rf_fit <- randomForest(high_cost ~ age + n_comorbidities + prior_admissions,
                        data = train_df, ntree = 300)
test_probs <- predict(rf_fit, test_df, type = "prob")[, "Yes"]

ui <- fluidPage(
  titlePanel("Random Forest Risk-Threshold / Confusion-Matrix Explorer"),
  p("Companion app for Chapter 34, \u00a734.1 (Emerging Methods and the Future of ",
    "HEOR in R). A random forest (trained on a 700-patient synthetic cohort, ",
    "evaluated on a held-out 300-patient test set) predicts each patient's ",
    "probability of being 'high-cost' next year. Drag the classification ",
    "threshold and watch the confusion matrix and accuracy/sensitivity/",
    "specificity shift live."),
  sidebarLayout(
    sidebarPanel(
      sliderInput("threshold", "Classification threshold", 0.05, 0.95, 0.5, step = 0.01),
      helpText("A patient is classified 'predicted high-cost' if the forest's ",
               "predicted probability exceeds this threshold."),
      verbatimTextOutput("confusionOut")
    ),
    mainPanel(
      plotOutput("rocPlot", height = "400px"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "A single 'X% accuracy' headline figure hides which kind of error the ",
        "model is making. Lowering the threshold toward 0.1 catches almost ",
        "every true high-cost patient (high sensitivity) but also flags many ",
        "low-risk patients unnecessarily (low specificity) \u2014 the right trade-off ",
        "depends on what a flagged patient actually triggers downstream (an extra ",
        "phone call is cheap to over-trigger; a costly case-management ",
        "intervention is not). There is no single 'correct' threshold in the ",
        "abstract \u2014 it should be chosen based on the real cost of a false ",
        "positive versus a false negative for the specific programme.")
    )
  )
)

server <- function(input, output, session) {

  confusion <- reactive({
    pred_class <- ifelse(test_probs > input$threshold, "Yes", "No")
    actual <- as.character(test_df$high_cost)

    tp <- sum(pred_class == "Yes" & actual == "Yes")
    fp <- sum(pred_class == "Yes" & actual == "No")
    fn <- sum(pred_class == "No" & actual == "Yes")
    tn <- sum(pred_class == "No" & actual == "No")

    accuracy <- (tp + tn) / length(actual)
    sensitivity <- if ((tp + fn) > 0) tp / (tp + fn) else NA
    specificity <- if ((tn + fp) > 0) tn / (tn + fp) else NA

    list(tp = tp, fp = fp, fn = fn, tn = tn,
         accuracy = accuracy, sensitivity = sensitivity, specificity = specificity)
  })

  output$confusionOut <- renderPrint({
    c <- confusion()
    cat("              Actual: No  Actual: Yes\n")
    cat(sprintf("Predicted No:  %4d        %4d\n", c$tn, c$fn))
    cat(sprintf("Predicted Yes: %4d        %4d\n", c$fp, c$tp))
    cat(sprintf("\nAccuracy:    %.1f%%\n", c$accuracy * 100))
    cat(sprintf("Sensitivity: %.1f%%\n", c$sensitivity * 100))
    cat(sprintf("Specificity: %.1f%%\n", c$specificity * 100))
  })

  output$rocPlot <- renderPlot({
    thresholds <- seq(0.02, 0.98, by = 0.02)
    actual <- as.character(test_df$high_cost)
    roc_df <- do.call(rbind, lapply(thresholds, function(th) {
      pred <- ifelse(test_probs > th, "Yes", "No")
      tp <- sum(pred == "Yes" & actual == "Yes")
      fp <- sum(pred == "Yes" & actual == "No")
      fn <- sum(pred == "No" & actual == "Yes")
      tn <- sum(pred == "No" & actual == "No")
      data.frame(threshold = th,
                 sensitivity = if ((tp+fn)>0) tp/(tp+fn) else NA,
                 specificity = if ((tn+fp)>0) tn/(tn+fp) else NA)
    }))

    c <- confusion()
    ggplot(roc_df, aes(x = 1 - specificity, y = sensitivity)) +
      geom_line(color = "#2166ac", linewidth = 1) +
      geom_abline(slope = 1, intercept = 0, linetype = "dotted", color = "grey50") +
      geom_point(data = data.frame(x = 1 - c$specificity, y = c$sensitivity),
                 aes(x = x, y = y), color = "#d6604d", size = 4) +
      coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) +
      labs(x = "1 \u2212 Specificity (false positive rate)", y = "Sensitivity (true positive rate)",
           title = "ROC-style curve across all thresholds",
           subtitle = "Red point: current threshold setting") +
      theme_minimal(base_size = 13)
  })

  output$interpretation <- renderText({
    c <- confusion()
    n_flagged <- c$tp + c$fp
    sprintf(paste0("At threshold = %.2f: %d of %d test patients are flagged as predicted ",
                   "high-cost (%d true positives + %d false positives). Accuracy = %.1f%%, ",
                   "but sensitivity (%.1f%%) and specificity (%.1f%%) tell a more complete ",
                   "story \u2014 %d true high-cost patients are being MISSED at this threshold."),
            input$threshold, n_flagged, nrow(test_df), c$tp, c$fp,
            c$accuracy * 100, c$sensitivity * 100, c$specificity * 100, c$fn)
  })
}

shinyApp(ui, server)
