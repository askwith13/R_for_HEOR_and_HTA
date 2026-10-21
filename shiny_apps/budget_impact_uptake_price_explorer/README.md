# Budget Impact Uptake/Price Explorer

**Book section:** Chapter 35, §35.4 (Case Study: Long-Acting Injectable Budget Impact)

## What this app does

Sliders for an LAI's annual price, relapse-rate reduction, and a 5-year uptake ramp speed recompute the year-by-year budget-impact table and cost-trajectory chart live, letting a reader discover for themselves how much the 5-year total depends on uptake speed versus price.

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
check, screenshotted in a real browser (including live slider
interaction to confirm dynamic behaviour, not just static defaults),
and cross-checked numerically against an independent standalone R
script before being marked complete.

## Interpretive layer

Beyond the live-updating plots, this app includes a reactive
"What you're seeing" panel (summarising the current computed result
in plain language) and a "Pitfall" callout (a fixed warning about a
real misinterpretation risk for this concept, matching the book's own
callout-box style). Both were verified to produce accurate, internally
consistent text against the actual computed numbers, not just
plausible-looking copy.
