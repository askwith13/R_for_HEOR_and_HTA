# PSM Oncology ICER Dashboard

**Book section:** Chapter 20, §20.6 (Advanced Topics in Survival Modelling)

## What this app does

Sliders for each arm's PFS/OS Weibull scale parameters and state costs/utilities feed a real partitioned-survival discounting loop, recomputing discounted cost, QALYs, and the ICER live for both arms, with a genuine curve-crossing check (not auto-corrected before being flagged) that fails loudly when PFS is pushed to exceed OS.

## Running locally

```r
# From this directory:
shiny::runApp(".")
```

The app will open in your default browser (or print a local URL to
the R console).

## Required packages

shiny, flexsurv, dplyr, ggplot2

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
