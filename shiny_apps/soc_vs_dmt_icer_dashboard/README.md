# SoC vs. DMT Live ICER Dashboard

**Book section:** Chapter 19. Markov Cohort Models, §19.10

A 3-state (Well/Diseased/Dead) Markov cohort model comparing Standard of Care against a Disease-Modifying Therapy. Sliders for each arm's transition probabilities, state costs, state utilities, and the discount rate recompute the discounted 10-year cost/QALY totals and ICER live.

## Running locally

```bash
cd shiny_apps/soc_vs_dmt_icer_dashboard
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
