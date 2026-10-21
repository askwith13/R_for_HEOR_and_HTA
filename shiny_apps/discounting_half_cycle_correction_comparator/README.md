# Discounting & Half-Cycle Correction Comparator

**Book section:** Chapter 19, §19.5 (Markov Cohort Models)

## What this app does

Compares beginning-of-cycle, end-of-cycle, and half-cycle-corrected (trapezoidal) discounted totals from a fixed cycle stream, showing the half-cycle correction sits exactly between the other two and the gap widens with a faster-declining cohort.

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
