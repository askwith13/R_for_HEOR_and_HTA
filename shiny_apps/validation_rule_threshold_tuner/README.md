# Validation Rule Threshold Tuner

**Book section:** Chapter 5, §5.6 (Data Import, Cleaning and Validation)

## What this app does

Sliders set bounds for 3 validation rules (plausible cost range, plausible QALY range, maximum baseline-to-follow-up utility change) on a simulated 500-record cost_qaly_tbl extract with 15 deliberately injected genuine errors; pass/fail counts and a flagged-record table update live, demonstrating the unavoidable trade-off between catching more genuine errors and flagging more false positives.

## Running locally

```r
# From this directory:
shiny::runApp(".")
```

The app will open in your default browser (or print a local URL to
the R console).

## Required packages

shiny, ggplot2, dplyr

## Verification

This app was independently parsed for syntax errors, launched as a
real background Shiny server, confirmed live via an HTTP 200 health
check, screenshotted in a real browser (including live slider/filter
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

## Note on data

This app uses a fully self-contained simulated dataset generated
in-app (with `set.seed()` for reproducibility), rather than loading an
external reference extract -- the original candidate description in
`progress/shiny_app_candidates.md` suggested a "loaded extract," but a
self-contained simulation keeps the app runnable standalone with no
external data dependency, consistent with every other app in this
collection.
