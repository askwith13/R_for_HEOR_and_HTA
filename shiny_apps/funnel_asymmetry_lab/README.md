# Funnel Asymmetry Lab

**Book section:** Chapter 11, §11.3 (Meta-Analysis)

## What this app does

A slider suppresses an increasing number of small 'unfavourable' simulated studies; the real funnel plot, Egger's test, and trim-and-fill (via the meta package) re-run live, showing the pooled estimate chase a moving target and that trim-and-fill is a sensitivity check, not a guaranteed correction.

## Running locally

```r
# From this directory:
shiny::runApp(".")
```

The app will open in your default browser (or print a local URL to
the R console).

## Required packages

shiny, meta, ggplot2

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
