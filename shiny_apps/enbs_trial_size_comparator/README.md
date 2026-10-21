# ENBS Trial-Size Comparator

**Book section:** Chapter 26, §26.4 & 26.6 (Value of Information Analysis)

## What this app does

Sliders for sample size, per-patient trial cost, fixed setup cost, and population size recompute a moment-matching EVSI approximation and resulting ENBS live, letting a reader directly search for the ENBS-maximising sample size rather than assuming bigger is always better -- demonstrated with a clean interior maximum well below the largest feasible trial size.

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
