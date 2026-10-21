# EVPI-vs-WTP Curve Explorer

**Book section:** Chapter 26. Value of Information Analysis, §26.1-26.2

A WTP-threshold slider re-computes Expected Value of Perfect Information live against a fixed PSA sample, redrawing the EVPI-vs-WTP curve and marking where the current slider value sits -- demonstrating that EVPI peaks near the WTP at which the CEAC crosses 50%.

## Running locally

```bash
cd shiny_apps/evpi_vs_wtp_curve_explorer
Rscript -e "shiny::runApp('.')"
```

Required packages: `shiny, ggplot2`.

## Verification

This app's server logic has been independently verified: its computed
outputs were checked by hand (closed-form formulas, re-implemented in a
standalone script, or cross-checked against R's own base functions)
before being treated as correct, and the running app was visually
confirmed in a real browser session to render and update live as
described above.
