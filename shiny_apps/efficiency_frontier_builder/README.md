# Efficiency Frontier Builder

**Book section:** Chapter 4. Core Concepts in Health Economics, §4.7-4.8

Edit cost/QALYs for up to 5 treatments live; the app re-runs simple and extended dominance pruning and redraws the cost-effectiveness plane with dominated points greyed out and the efficient frontier connected.

## Running locally

```bash
cd shiny_apps/efficiency_frontier_builder
Rscript -e "shiny::runApp('.')"
```

Required packages: `shiny, ggplot2, dplyr`.

## Verification

This app's server logic has been independently verified: its computed
outputs were checked by hand (closed-form formulas, re-implemented in a
standalone script, or cross-checked against R's own base functions)
before being treated as correct, and the running app was visually
confirmed in a real browser session to render and update live as
described above.
