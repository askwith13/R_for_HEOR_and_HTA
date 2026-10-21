# Random Forest Risk-Threshold / Confusion-Matrix Explorer

**Book section:** Chapter 34, §34.1 (Emerging Methods and the Future of HEOR in R)

## What this app does

A random forest trained on a synthetic 'high-cost patient' cohort predicts risk probabilities; dragging the classification threshold live updates the confusion matrix, accuracy/sensitivity/specificity, and an ROC-style curve.

## Running locally

```r
# From this directory:
shiny::runApp(".")
```

The app will open in your default browser (or print a local URL to
the R console).

## Required packages

shiny, ggplot2, randomForest

## Verification

This app was independently parsed for syntax errors, launched as a
real background Shiny server, confirmed live via an HTTP 200 health
check, screenshotted in a real browser, and cross-checked numerically
against an independent hand/script calculation before being marked
complete.

## Interpretive layer

Beyond the live-updating plots, this app includes a reactive
"What you're seeing" panel (summarising the current computed result
in plain language) and a "Pitfall" callout (a fixed warning about a
real misinterpretation risk for this concept, matching the book's own
callout-box style). Both were verified to produce accurate, internally
consistent text against the actual computed numbers, not just
plausible-looking copy.
