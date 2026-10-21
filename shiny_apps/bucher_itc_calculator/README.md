# Bucher ITC Calculator

**Book section:** Chapter 12. Indirect Treatment Comparisons and Network Meta-Analysis, §12.2

Four sliders (d_AC, SE_AC, d_BC, SE_BC) let the user vary each trial's log-effect estimate/precision and watch the indirect A-vs-B estimate and its always-wider confidence interval update live.

## Running locally

```bash
cd shiny_apps/bucher_itc_calculator
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
