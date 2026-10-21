# Curve-Crossing Explorer (Partitioned Survival Models)

**Book section:** Chapter 20, §20.1 & 20.5 (Partitioned Survival Models)

## What this app does

Independently-fit PFS and OS Weibull curves (shape/scale sliders) live-replot survival curves plus the derived P(Progressed) = S_OS − S_PFS line, shading in red where it goes negative (a structurally impossible crossing) -- usually far out in the extrapolated tail.

## Running locally

```r
# From this directory:
shiny::runApp(".")
```

The app will open in your default browser (or print a local URL to
the R console).

## Required packages

shiny, ggplot2, gridExtra

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
