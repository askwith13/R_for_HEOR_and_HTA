# ECEA Financial Risk Protection Dashboard

**Book section:** Chapter 24, §24.3 (Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis)

## What this app does

Sliders for out-of-pocket costs, the catastrophic-expenditure threshold, and the poverty line re-run a financial-risk-protection calculation live across 5 income quintiles, showing the benefit of an identical OOP reduction is concentrated in specific income bands, not spread evenly.

## Running locally

```r
# From this directory:
shiny::runApp(".")
```

The app will open in your default browser (or print a local URL to
the R console).

## Required packages

shiny, ggplot2, dplyr

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
