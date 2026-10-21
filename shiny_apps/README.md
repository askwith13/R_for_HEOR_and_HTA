# Shiny Apps — R for HEOR and HTA

Companion interactive Shiny apps for this book, one subfolder per
app, each illustrating a single book concept with live parameter
sliders rather than a static plot.

## Status: 44 apps built, verified, and explanatory-layer complete

`progress/shiny_app_candidates.md` holds the full planning inventory
-- 64 candidate apps identified by reading every chapter's actual
content and applying a selectivity filter (only concepts where a
parameter's live-varying effect on a result is genuinely non-trivial
or non-monotonic qualify). 44 candidates -- 11/16 of the inventory --
(spanning Parts I-VII of the book) have now been built, run, and
visually verified in a real browser session:

| App | Book section |
|---|---|
| `transition_matrix_explorer/` | Chapter 3, §3.1 |
| `icer_quadrant_net_benefit_explorer/` | Chapter 4, §4.4 |
| `wtp_threshold_sensitivity_dashboard/` | Chapter 4, §4.5 |
| `discount_rate_time_horizon_explorer/` | Chapter 4, §4.6 |
| `efficiency_frontier_builder/` | Chapter 4, §4.7-4.8 |
| `missingness_mechanism_simulator/` | Chapter 7, §7.1 |
| `tipping_point_delta_explorer/` | Chapter 7, §7.5 |
| `eq5d_tariff_comparator/` | Chapter 8, §8.2 |
| `age_adjusted_utility_decrement_explorer/` | Chapter 8, §8.5 |
| `cost_distribution_model_fit_explorer/` | Chapter 9, §9.3-9.4 |
| `censored_cost_estimator_comparator/` | Chapter 9, §9.6 |
| `meta_analysis_pooling_model_playground/` | Chapter 11, §11.1-11.2 |
| `bucher_itc_calculator/` | Chapter 12, §12.2 |
| `maic_weight_ess_explorer/` | Chapter 13, §13.2 |
| `prior_likelihood_posterior_tug_of_war/` | Chapter 14, §14.2 |
| `e_value_sensitivity_dashboard/` | Chapter 15, §15.9 |
| `logistic_link_function_explorer/` | Chapter 16, §16.1 |
| `overdispersion_zero_inflation_visualizer/` | Chapter 16, §16.3 |
| `quantile_regression_tau_slider/` | Chapter 16, §16.4 |
| `beta_distribution_fitter/` | Chapter 17, §17.4 |
| `toy_regimen_icer_explorer/` | Chapter 17, §17.6 |
| `diagnostic_tree_icer_dashboard/` | Chapter 18, §18.1-18.2 |
| `markov_cohort_trace_builder/` | Chapter 19, §19.1 & 19.3 |
| `discounting_half_cycle_correction_comparator/` | Chapter 19, §19.5 |
| `tunnel_state_risk_shape_explorer/` | Chapter 19, §19.6 |
| `soc_vs_dmt_icer_dashboard/` | Chapter 19, §19.10 |
| `curve_crossing_explorer/` | Chapter 20, §20.1 & 20.5 |
| `treatment_waning_assumption_visualizer/` | Chapter 20, §20.3 |
| `parametric_hazard_shape_explorer/` | Chapter 10, §10.2 |
| `spline_knot_count_explorer/` | Chapter 10, §10.3 |
| `first_order_noise_convergence_explorer/` | Chapter 21, §21.4 |
| `mm1_queue_utilisation_explorer/` | Chapter 22, §22.2 |
| `seir_epidemic_herd_effect_explorer/` | Chapter 22, §22.4/22.6 |
| `budget_impact_scenario_explorer/` | Chapter 23, §23.2-23.4 |
| `equity_weighted_icer_explorer/` | Chapter 24, §24.2 |
| `psa_distribution_ceac_explorer/` | Chapter 25, §25.4-25.5 |
| `tornado_diagram_parameter_range_explorer/` | Chapter 25, §25.2 |
| `evpi_vs_wtp_curve_explorer/` | Chapter 26, §26.1-26.2 |
| `cross_agency_decision_explorer/` | Chapter 31, §31.5 |
| `durability_waning_of_effect_explorer/` | Chapter 32, §32.6 |
| `tb_cascade_of_care_attrition_explorer/` | Chapter 32, §32.7 |
| `irt_item_characteristic_curve_explorer/` | Chapter 33, §33.1 |
| `mcid_threshold_responder_rate_explorer/` | Chapter 33, §33.2 |
| `random_forest_risk_threshold_explorer/` | Chapter 34, §34.1 |

The remaining 20 candidates in `progress/shiny_app_candidates.md` are
not yet built.

## What each app folder contains

- `app.R` -- the runnable Shiny app (single-file `shinyApp(ui, server)`
  convention, matching Chapter 29's pattern).
- `README.md` -- a short description, the exact book chapter and
  section the app illustrates, how to run it locally, and a note on
  how its logic was verified.
- `renv.lock` -- an honest package manifest (same policy as `code/`'s
  per-chapter lockfiles, see Chapter 2 §2.3) generated via
  `python3 ~/.hermes/scripts/generate_shiny_app_renvlock.py`. All 44
  built apps currently show 100% verified-installed packages (no
  `NOT_VERIFIED_IN_THIS_ENVIRONMENT` markers).

## Verification discipline for every app built so far

Each app's computational core was checked two ways before being
treated as correct: (1) independently re-implemented in a standalone
R or Python script and compared against known closed-form results
where one exists (e.g. the M/M/1 queueing formulas, the Bucher
method's variance-addition rule, conjugate Beta-Binomial posterior
algebra, the SEIR model's threshold behaviour as R_effective crosses
1, the MAIC effective-sample-size formula, quantile regression slope
divergence under heteroscedasticity, E-values via the `EValue`
package, fixed- vs. random-effects CI widths via `meta`, Markov
transition-matrix compounding, Poisson-GLM residual-deviance ratios
under NB/ZIP data, method-of-moments Beta fitting, restricted-mean
survival gains under alternative waning assumptions, real country
tariffs via the `eq5d` package, Lin's-partitioned-style censored-cost
bias reduction via `survival::survfit()`, flexsurvspline AIC/log-
likelihood tradeoffs, first-order sampling-noise convergence,
MCAR/MAR/MNAR complete-case bias, tipping-point delta sensitivity
analysis, and beginning/end/half-cycle discounted-total differences),
and (2) the running app itself was loaded in a real browser session
and its live output -- including, where relevant, after live slider
interaction -- visually confirmed to match, not just assumed to work
because the code looked plausible.

## Interpretive layer

Every app includes a reactive "What you're seeing" panel, computed
live from the current slider state, and a fixed "Pitfall" callout
warning about a real, specific misinterpretation risk for that app's
concept -- matching the book's own callout-box density. These panels
were independently re-verified against each app's own displayed
numbers before being accepted, not just read for plausibility. A few
pitfall-text claims across the full build were caught overstating
what the app's own simulation actually demonstrates (the cost-
distribution app's OLS/gamma-GLM divergence, the spline app's "AIC
always falls" claim, and the tipping-point app's original true-effect
size placing the tipping point outside the visible slider range) and
corrected to match the real, verified behaviour rather than left as
plausible-sounding but inaccurate copy.

## Building more apps

Folder names should be short, lowercase, underscore-separated slugs
describing the app's subject (e.g. `maic_weight_ess_explorer`), not
the chapter number alone, since several chapters contribute more than
one candidate. `progress/shiny_app_candidates.md`'s selection criteria
section notes which remaining candidates are the strongest teaching
aids; start there for the next batch rather than working strictly
chapter-by-chapter.
