# PSA Distribution & CEAC Explorer

**Book section:** Chapter 25. Handling Uncertainty, §25.4-25.5

Sliders for the willingness-to-pay threshold and the assumed evidence strength behind a Beta-distributed failure probability re-run an n=2000 PSA loop live, redrawing the CE plane, CEAC, and incremental-NMB histogram together.

## Running locally

```bash
cd shiny_apps/psa_distribution_ceac_explorer
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
