# Parametric Hazard Shape Explorer

**Book section:** Chapter 10. Survival Analysis for Economic Evaluation, §10.2

Select a distribution family (exponential/Weibull/Gompertz/log-logistic/log-normal) and drag its shape/scale parameters; survival and hazard curves overlay live against a synthetic Kaplan-Meier curve, extrapolated to a user-set horizon.

## Running locally

```bash
cd shiny_apps/parametric_hazard_shape_explorer
Rscript -e "shiny::runApp('.')"
```

Required packages: `shiny, ggplot2, flexsurv, survival`.

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
