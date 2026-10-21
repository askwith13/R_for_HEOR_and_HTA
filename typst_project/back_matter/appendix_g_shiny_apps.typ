#import "../common.typ": *

= Appendix G. List of Interactive Shiny Apps

The companion GitHub repository (see front matter, "Companion GitHub
Repository, Code, Shiny App, Quiz and Data Sets") includes a
`shiny_apps/` folder with all 64 interactive Shiny apps referenced
throughout this book, each illustrating one specific book concept
with live parameter sliders rather than a static plot. Every app was
independently verified -- parsed for syntax errors, launched as a
real Shiny server, confirmed live via an HTTP health check,
screenshotted in a real browser session (including, where relevant,
after live slider interaction), and cross-checked numerically against
an independent standalone R script -- before being accepted as
complete. See `shiny_apps/README.md` in the repository for the full
verification discipline, including the handful of real logic bugs
caught and fixed during that process.

#agency-note[
  Repository: #link("https://github.com/askwith13/R_for_HEOR_and_HTA")[github.com/askwith13/R\_for\_HEOR\_and\_HTA]. Each app lives in its own subfolder under `shiny_apps/`, runnable standalone via `shiny::runApp(".")` with its own `renv.lock` package manifest -- no external data dependency, since every app's dataset is generated in-app with a fixed `set.seed()` for reproducibility.
]

// NOTE: a plain breakable table() is used here instead of the usual
// ref-table()/academic-table() combo -- that combo wraps the table in
// a non-breakable figure(), which is fine for every other table in
// this book (all under ~15 rows) but forces this 64-row table onto a
// single page, causing row/footer overlap. A manual caption-style line
// substitutes for the figure's caption since this table deliberately
// opts out of the "List of Tables" index (it is a reference listing,
// not the reported output of an analysis).
#text(style: "italic", size: 10pt)[Table: All 64 companion Shiny apps, by book chapter and section]
#v(0.3em)

#table(
    columns: (2.4fr, 1fr),
    align: (left, left),
    stroke: none,
    inset: 6pt,
    table.hline(stroke: 1pt),
    table.header([*App folder*], [*Book section*]),
    table.hline(stroke: 0.6pt),
      [`transition_matrix_explorer/`], [Ch. 3, §3.1],
      [`icer_quadrant_net_benefit_explorer/`], [Ch. 4, §4.4],
      [`wtp_threshold_sensitivity_dashboard/`], [Ch. 4, §4.5],
      [`discount_rate_time_horizon_explorer/`], [Ch. 4, §4.6],
      [`efficiency_frontier_builder/`], [Ch. 4, §4.7-4.8],
      [`validation_rule_threshold_tuner/`], [Ch. 5, §5.6],
      [`dedup_threshold_explorer/`], [Ch. 6, §6.2],
      [`missingness_mechanism_simulator/`], [Ch. 7, §7.1],
      [`interactive_missingness_explorer/`], [Ch. 7, §7.2],
      [`tipping_point_delta_explorer/`], [Ch. 7, §7.5],
      [`eq5d_tariff_comparator/`], [Ch. 8, §8.2],
      [`age_adjusted_utility_decrement_explorer/`], [Ch. 8, §8.5],
      [`cost_distribution_model_fit_explorer/`], [Ch. 9, §9.3-9.4],
      [`censored_cost_estimator_comparator/`], [Ch. 9, §9.6],
      [`parametric_hazard_shape_explorer/`], [Ch. 10, §10.2],
      [`spline_knot_count_explorer/`], [Ch. 10, §10.3],
      [`cure_fraction_followup_length_simulator/`], [Ch. 10, §10.4],
      [`meta_analysis_pooling_model_playground/`], [Ch. 11, §11.1-11.2],
      [`funnel_asymmetry_lab/`], [Ch. 11, §11.3],
      [`bucher_itc_calculator/`], [Ch. 12, §12.2],
      [`covariate_recentering_explorer/`], [Ch. 12, §12.6],
      [`maic_weight_ess_explorer/`], [Ch. 13, §13.2],
      [`prior_likelihood_posterior_tug_of_war/`], [Ch. 14, §14.2],
      [`extreme_weights_trimming_simulator/`], [Ch. 15, §15.4],
      [`e_value_sensitivity_dashboard/`], [Ch. 15, §15.9],
      [`logistic_link_function_explorer/`], [Ch. 16, §16.1],
      [`overdispersion_zero_inflation_visualizer/`], [Ch. 16, §16.3],
      [`quantile_regression_tau_slider/`], [Ch. 16, §16.4],
      [`beta_distribution_fitter/`], [Ch. 17, §17.4],
      [`toy_regimen_icer_explorer/`], [Ch. 17, §17.6],
      [`diagnostic_tree_icer_dashboard/`], [Ch. 18, §18.1-18.2],
      [`markov_cohort_trace_builder/`], [Ch. 19, §19.1 & 19.3],
      [`discounting_half_cycle_correction_comparator/`], [Ch. 19, §19.5],
      [`tunnel_state_risk_shape_explorer/`], [Ch. 19, §19.6],
      [`soc_vs_dmt_icer_dashboard/`], [Ch. 19, §19.10],
      [`curve_crossing_explorer/`], [Ch. 20, §20.1 & 20.5],
      [`treatment_waning_assumption_visualizer/`], [Ch. 20, §20.3],
      [`psm_oncology_icer_dashboard/`], [Ch. 20, §20.6],
      [`first_order_noise_convergence_explorer/`], [Ch. 21, §21.4],
      [`common_random_numbers_variance_reduction_demo/`], [Ch. 21, §21.5],
      [`mm1_queue_utilisation_explorer/`], [Ch. 22, §22.2],
      [`seir_epidemic_herd_effect_explorer/`], [Ch. 22, §22.4/22.6],
      [`budget_impact_scenario_explorer/`], [Ch. 23, §23.2-23.4],
      [`equity_weighted_icer_explorer/`], [Ch. 24, §24.2],
      [`ecea_financial_risk_protection_dashboard/`], [Ch. 24, §24.3],
      [`mcda_weight_sensitivity_explorer/`], [Ch. 24, §24.4],
      [`tornado_diagram_parameter_range_explorer/`], [Ch. 25, §25.2],
      [`psa_distribution_ceac_explorer/`], [Ch. 25, §25.4-25.5],
      [`threshold_analysis_breakeven_calculator/`], [Ch. 25, §25.6],
      [`structural_model_averaging_weight_explorer/`], [Ch. 25, §25.7],
      [`bootstrap_resampling_method_comparator/`], [Ch. 25, §25.8],
      [`evpi_vs_wtp_curve_explorer/`], [Ch. 26, §26.1-26.2],
      [`gam_evppi_smoothness_explorer/`], [Ch. 26, §26.3],
      [`enbs_trial_size_comparator/`], [Ch. 26, §26.4 & 26.6],
      [`calibration_target_search_explorer/`], [Ch. 27, §27.1],
      [`extreme_value_test_sandbox/`], [Ch. 27, §27.3],
      [`cross_agency_decision_explorer/`], [Ch. 31, §31.5],
      [`durability_waning_of_effect_explorer/`], [Ch. 32, §32.6],
      [`tb_cascade_of_care_attrition_explorer/`], [Ch. 32, §32.7],
      [`irt_item_characteristic_curve_explorer/`], [Ch. 33, §33.1],
      [`mcid_threshold_responder_rate_explorer/`], [Ch. 33, §33.2],
      [`random_forest_risk_threshold_explorer/`], [Ch. 34, §34.1],
      [`budget_impact_uptake_price_explorer/`], [Ch. 35, §35.4],
      [`ceac_wtp_threshold_explorer/`], [Ch. 35, §35.1 & 35.2],
    table.hline(stroke: 0.6pt),
    table.cell(colspan: 2)[64 apps, one per subfolder under `shiny_apps/` in the companion repository, each with its own `README.md`, `app.R`, and `renv.lock`.],
    table.hline(stroke: 1pt),
)

== Running an app locally

Every app follows the same pattern -- clone the repository, enter the
app's folder, and launch it with Shiny's own `runApp()`:

```r
# From a local clone of the companion repository:
setwd("shiny_apps/icer_quadrant_net_benefit_explorer")
shiny::runApp(".")
```

This opens the app in a browser (or prints a local URL to the R
console), with no external data dependency -- every app's dataset is
generated in-app, not loaded from an external file.

#pitfall[
  Each app's `renv.lock` is the same kind of honest, per-folder package
  manifest described in Chapter 2 §2.3 for the main `code/` repository
  -- a real version number for every package verified installed on the
  machine that built the app, not a guaranteed-reproducible frozen
  snapshot. Run `renv::restore()` inside an app's folder, or simply
  `install.packages()` any missing dependency it reports, before
  relying on an app's output for anything beyond illustration.
]
