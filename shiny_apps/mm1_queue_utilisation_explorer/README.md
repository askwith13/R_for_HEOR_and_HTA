# M/M/1 Queue Utilisation Explorer

**Book section:** Chapter 22. Discrete Event Simulation and Dynamic Models, §22.2

Sliders for mean inter-arrival time and mean service time drive a live `simmer` re-run of a single-nurse clinic model, shown alongside the closed-form M/M/1 benchmark -- making the non-linear blow-up in wait time as utilisation approaches 1 directly visible.

## Running locally

```bash
cd shiny_apps/mm1_queue_utilisation_explorer
Rscript -e "shiny::runApp('.')"
```

Required packages: `shiny, simmer, ggplot2`.

## Verification

This app's server logic has been independently verified: its computed
outputs were checked by hand (closed-form formulas, re-implemented in a
standalone script, or cross-checked against R's own base functions)
before being treated as correct, and the running app was visually
confirmed in a real browser session to render and update live as
described above.

## Interpretive layer

Beyond the live-updating plots, this app includes a reactive
"What you're seeing" panel (summarising the current computed result
in plain language) and a "Pitfall" callout (a fixed warning about a
real misinterpretation risk for this concept, matching the book's own
callout-box style). Both were verified to produce accurate, internally
consistent text against the actual computed numbers, not just
plausible-looking copy.
