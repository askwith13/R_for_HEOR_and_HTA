# Shiny Apps — R for HEOR and HTA

Companion interactive Shiny apps for this book, one subfolder per
app, each illustrating a single book concept with live parameter
sliders rather than a static plot.

## Status: planning inventory complete, apps not yet built

`progress/shiny_app_candidates.md` holds the full planning inventory
-- 64 candidate apps identified by reading every chapter's actual
content and applying a selectivity filter (only concepts where a
parameter's live-varying effect on a result is genuinely non-trivial
or non-monotonic qualify; most chapters contribute 1-3 candidates,
a few contribute none). No app has been built yet; this folder exists
so the companion repository's structure is correct from the start,
matching `front_matter/companion_website.typ`.

## What belongs here once an app is built

One subfolder per app (e.g. `shiny_apps/icer_ce_plane_explorer/`),
each containing:

- `app.R` -- the runnable Shiny app (or `ui.R` + `server.R` for
  larger apps, matching the convention introduced in Chapter 29).
- `README.md` -- a short description plus the exact book chapter and
  section the app illustrates, linking back the same way
  `code/chNN_slug/block_index.md` links code blocks to source lines.
- `renv.lock` -- pinned package versions, same policy as `code/`'s
  per-chapter lockfiles (see Chapter 2 §2.3).

Folder names should be short, lowercase, hyphen-or-underscore
slugs describing the app's subject (e.g. `markov_trace_explorer`,
`maic_weight_ess_explorer`), not the chapter number alone, since a
handful of chapters contribute more than one app.

## Building the highest-value apps first

`progress/shiny_app_candidates.md`'s selection criteria section notes
which candidates are the strongest teaching aids (parameter changes
with a visibly non-monotonic or surprising effect on the result,
rather than a simple linear scaling); start there when building the
first batch rather than working strictly chapter-by-chapter.
