# Spline Knot-Count Explorer

**Book section:** Chapter 10, §10.3 (Survival Analysis for Economic Evaluation)

## What this app does

A knot-count slider (k=0-3) for flexsurv::flexsurvspline() re-fits live against a simulated KM curve; shows log-likelihood always improving with more knots while AIC/BIC can go either way once the parameter-count penalty applies, with a live monotonicity check on the extrapolated tail.

## Running locally

```r
# From this directory:
shiny::runApp(".")
```

The app will open in your default browser (or print a local URL to
the R console).

## Required packages

shiny, flexsurv, survival, ggplot2

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
