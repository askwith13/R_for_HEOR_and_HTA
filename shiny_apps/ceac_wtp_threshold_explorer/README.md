# CEAC/WTP Threshold Explorer (Case Studies A and B combined)

**Book section:** Chapter 35, §35.1 & 35.2 (End-to-End Worked Case Studies)

## What this app does

A single WTP slider highlights the corresponding point on two independently-simulated PSA-derived CEAC curves side by side -- a chronic-disease Markov model (Case Study A) and an oncology PSM (Case Study B) -- revealing a genuinely different qualitative story: A's accept/reject conclusion is highly WTP-sensitive, while B's stays low across the whole plausible range.

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
