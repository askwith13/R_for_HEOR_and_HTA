# Missingness Mechanism Simulator

**Book section:** Chapter 7, §7.1 (Missing Data)

## What this app does

A simulated utility dataset has values deleted under a chosen missingness mechanism (MCAR, MAR, or MNAR); shows the complete-case mean diverging substantially from the true mean only under MNAR, while MCAR/MAR stay approximately unbiased.

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
