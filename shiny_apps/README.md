# Shiny Apps — R for HEOR and HTA

Companion interactive Shiny apps for this book, one subfolder per
app, each illustrating a single book concept with live parameter
sliders rather than a static plot.

## Status: first batch of 8 apps built and verified

`progress/shiny_app_candidates.md` holds the full planning inventory
-- 64 candidate apps identified by reading every chapter's actual
content and applying a selectivity filter (only concepts where a
parameter's live-varying effect on a result is genuinely non-trivial
or non-monotonic qualify). The 8 highest-value candidates (spanning
Parts I-V of the book, chosen for being either strong single teaching
aids or genuinely non-monotonic/surprising relationships) have now
been built, run, and visually verified in a real browser session:

| App | Book section |
|---|---|
| `efficiency_frontier_builder/` | Chapter 4, §4.7-4.8 |
| `bucher_itc_calculator/` | Chapter 12, §12.2 |
| `prior_likelihood_posterior_tug_of_war/` | Chapter 14, §14.2 |
| `parametric_hazard_shape_explorer/` | Chapter 10, §10.2 |
| `soc_vs_dmt_icer_dashboard/` | Chapter 19, §19.10 |
| `mm1_queue_utilisation_explorer/` | Chapter 22, §22.2 |
| `psa_distribution_ceac_explorer/` | Chapter 25, §25.4-25.5 |
| `evpi_vs_wtp_curve_explorer/` | Chapter 26, §26.1-26.2 |

The remaining 56 candidates in `progress/shiny_app_candidates.md` are
not yet built.

## What each app folder contains

- `app.R` -- the runnable Shiny app (single-file `shinyApp(ui, server)`
  convention, matching Chapter 29's pattern).
- `README.md` -- a short description, the exact book chapter and
  section the app illustrates, how to run it locally, and a note on
  how its logic was verified.
- `renv.lock` -- an honest package manifest (same policy as `code/`'s
  per-chapter lockfiles, see Chapter 2 §2.3) generated via
  `python3 ~/.hermes/scripts/generate_shiny_app_renvlock.py`. All 8
  built apps currently show 100% verified-installed packages (no
  `NOT_VERIFIED_IN_THIS_ENVIRONMENT` markers).

## Verification discipline for every app built so far

Each app's computational core was checked two ways before being
treated as correct: (1) independently re-implemented in a standalone
R script and compared against known closed-form results where one
exists (e.g. the M/M/1 queueing formulas, the Bucher method's
variance-addition rule, conjugate Beta-Binomial posterior algebra),
and (2) the running app itself was loaded in a real browser session
and its live output visually confirmed to match, not just assumed to
work because the code looked plausible.

## Building more apps

Folder names should be short, lowercase, underscore-separated slugs
describing the app's subject (e.g. `maic_weight_ess_explorer`), not
the chapter number alone, since several chapters contribute more than
one candidate. `progress/shiny_app_candidates.md`'s selection criteria
section notes which remaining candidates are the strongest teaching
aids; start there for the next batch rather than working strictly
chapter-by-chapter.
