# GAM EVPPI Smoothness Explorer

**Book section:** Chapter 26, §26.3 (Value of Information Analysis)

## What this app does

A basis-dimension (k) slider re-fits a real mgcv::gam() regression of incremental NMB on a PSA parameter with a genuinely non-linear (quadratic + fine-wiggle) relationship, redrawing the fitted smooth against the raw scatter and the resulting EVPPI proxy, showing under-fit at low k and over-fit noise-chasing at high k.

## Running locally

```r
# From this directory:
shiny::runApp(".")
```

The app will open in your default browser (or print a local URL to
the R console).

## Required packages

shiny, mgcv, ggplot2

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
