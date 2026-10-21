# ICER Quadrant & Net Benefit Explorer

**Book section:** Chapter 4, §4.4 (Core Concepts in Health Economics)

## What this app does

Drag incremental cost, incremental QALYs, and a WTP threshold anywhere on the cost-effectiveness plane; ICER, NMB, and NHB recompute live, with the quadrant explicitly flagged to resolve the ambiguity of a negative ICER.

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
