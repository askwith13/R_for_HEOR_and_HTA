# Prior-Likelihood-Posterior Tug-of-War

**Book section:** Chapter 14. Bayesian Methods for HEOR, §14.2

Sliders for a Beta prior's alpha/beta and a new cohort's observed successes/total redraw the prior density, likelihood, and the exact conjugate posterior with its 95% credible interval live.

## Running locally

```bash
cd shiny_apps/prior_likelihood_posterior_tug_of_war
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

## Interpretive layer

Beyond the live-updating plots, this app includes a reactive
"What you're seeing" panel (summarising the current computed result
in plain language) and a "Pitfall" callout (a fixed warning about a
real misinterpretation risk for this concept, matching the book's own
callout-box style). Both were verified to produce accurate, internally
consistent text against the actual computed numbers, not just
plausible-looking copy.
