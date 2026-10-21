# Extreme-Value Test Sandbox

**Book section:** Chapter 27, §27.3 (Model Calibration, Validation and Quality Assurance)

## What this app does

A transition-probability slider spanning the full 0-1 range (not just the chapter's own 0/1 extremes) live-recomputes a cohort survival trace and runs an explicit extreme-value check at the boundaries, showing the trace degrade continuously and confirming the model matches the closed-form geometric decay at every intermediate value too.

## Running locally

```r
# From this directory:
shiny::runApp(".")
```

The app will open in your default browser (or print a local URL to
the R console).

## Required packages

shiny, ggplot2

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
