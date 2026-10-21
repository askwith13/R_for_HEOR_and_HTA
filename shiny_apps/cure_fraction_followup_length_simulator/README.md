# Cure-Fraction vs. Follow-up-Length Simulator

**Book section:** Chapter 10, §10.4 (Survival Analysis for Economic Evaluation)

## What this app does

A simulated cohort's true cure fraction and trial follow-up duration regenerate a censored cohort and refit a real flexsurvcure::flexsurvcure() mixture cure model live, showing how short administrative censoring manufactures a spuriously large cure estimate.

## Running locally

```r
# From this directory:
shiny::runApp(".")
```

The app will open in your default browser (or print a local URL to
the R console).

## Required packages

shiny, flexsurvcure, flexsurv, survival, ggplot2

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
