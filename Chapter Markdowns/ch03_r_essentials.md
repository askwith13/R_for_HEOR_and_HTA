# Chapter 3 — R Essentials for Health Economists

**Part:** I. Foundations
**Status:** complete (one revision pass on agency_grounding dimension)

## Sections covered (map to TOC 1:1)
3.1 Data structures: vectors, lists, data frames and tibbles, arrays and matrices
3.2 Data wrangling with `tidyverse` and `data.table`
3.3 Functional programming with `purrr` and vectorization
3.4 Writing functions, parameter lists and defensive programming
3.5 Performance: profiling, `Rcpp`, parallelisation (`future`, `furrr`)
3.6 Dates, durations and time-to-event data (`lubridate`)
3.7 Debugging and error handling

## Key claims / infrastructure established
- Data structures: vectorized arithmetic, type coercion hierarchy,
  `tibble` vs base `data.frame` (no partial matching, no silent
  dimension drop), `matrix`/`array` with a worked 3-state (Healthy/
  Sick/Dead) transition-matrix example using `dimnames` + `rowSums()`
  check — **directly foreshadows Chapter 19 (Markov models)**.
- `dplyr` (`filter/select/mutate/group_by/summarise` + `|>`/`%>%`) vs
  `data.table` (`DT[i,j,by]`, `.N`, `.()`, `:=`, reference semantics
  requiring explicit `copy()`) — guidance on when to prefer each
  (readability/small data vs claims-registry scale/millions of rows).
- `purrr::map()`/`map_dbl()`/`map2_dbl()`/`pmap_dbl()` — explicitly
  framed as the literal skeleton of a PSA loop; **directly
  foreshadows Chapter 25** (a `pmap_dbl(scenarios, calc_total_cost)`
  pattern becomes `pmap(psa_params, run_model)` at scale).
- Named parameter-list function design (vs long positional args),
  `stopifnot()`/`stop()`/`warning()` defensive programming — framed
  explicitly as HEOR submission-risk mitigation, not just style.
- Performance: `profvis`/`Rprof` for evidence-based profiling before
  optimizing, `Rcpp::cppFunction()` as a last-resort for a confirmed
  hot loop (not a default), `future::plan(multisession)` +
  `furrr::future_map()` as the drop-in parallel PSA pattern.
- `lubridate` (`ymd/dmy/mdy`, `difftime`, `interval()`/`time_length()`)
  with an explicit DD/MM vs MM/DD international-trial-data pitfall,
  and the censored-vs-missing event-date distinction — **directly
  foreshadows Chapter 10** (survival analysis).
- Debugging (`traceback`, `debug`, `browser`) vs error-handling
  (`tryCatch`) — explicit per-iteration (not whole-loop) `tryCatch`
  pattern for PSA loops, with a worked example and an agency-note on
  the danger of over-permissive error handling (substituting 0 for a
  failed draw silently biasing a CEAC).

## Agency grounding — revision pass fix pattern (now established twice)
This chapter's first Jev pass failed agency_grounding at 2.47/10 —
expected, since this is a pure R-skills chapter with inherently few
natural HEOR-agency touchpoints (no health-econ methods yet, that's
Ch.4). The fix: rather than inventing new agency claims to force-fit,
tied each agency-note back to references **already established in
Chapter 2's own revision pass**:
- CHEERS 2022 item 29 (reproducibility reporting) — tied to the
  within-script code-style-consistency point in §3.2.
- NICE technology appraisal process + ERG re-run reliance (the exact
  Ch.2 precedent) — tied to defensive-programming-as-QA in §3.4.
- ISPOR-SMDM good-practice guidance on PSA transparency/iteration-count
  reporting (→ Chapter 27) — tied to the error-handling-permissiveness
  point in §3.7.

**Generalizable lesson for future chapters:** when a chapter's
substance is genuinely methods-agnostic (infrastructure, R skills,
general programming practice) rather than HEOR-methodological, do not
invent chapter-specific agency claims to force an agency_grounding
score — instead anchor back to the SAME already-established, verified
agency references (NICE process, CHEERS 2022, ISPOR-SMDM, named DSU
TSDs) applied to this chapter's specific practice. This keeps every
agency claim traceable to a real document while still clearing the
rubric threshold.

## Code
All code real and technically accurate — no invented functions.
Confirmed genuine: `str()/class()/typeof()`, `dplyr` verbs + pipe,
`data.table` `DT[i,j,by]`/`:=`/`copy()`, `purrr::map_dbl/map2_dbl/
pmap_dbl()`, `stopifnot()/stop()/warning()`, `profvis::profvis()`,
`Rprof()/summaryRprof()`, `Rcpp::cppFunction()`, `future::plan()`,
`furrr::future_map()`, `lubridate::ymd/dmy/mdy/difftime/interval/
time_length()`, `traceback()/debug()/browser()/tryCatch()`.

## Notation / terminology — no changes from Ch.1/Ch.2
ICER = ΔC/ΔE not restated (correctly out of scope — no health-econ
content in this chapter). Callout conventions used identically to
Ch.1/Ch.2's established pattern — confirmed by internal_consistency
8.48/10.

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams):** considered a data-structure
  hierarchy diagram for §3.1 (vector→list→data.frame/tibble→matrix/
  array) but logged as **Skipped** in `progress/image_tracker.md`
  (C6) — prose + code examples cover it adequately without a diagram.
- **Track 2 (R-generated images):** logged one entry (T1) — a real
  `profvis::profvis()` flame-graph screenshot from actually running
  §3.5's profiling example, for Dr Aswath to supply later. Inserted a
  `// TODO-IMAGE:` comment at the exact point in the `.typ` file
  (immediately after the `profvis()` code block), with the exact
  `#figure()` call to drop in once the real image exists. Book
  compiles cleanly with the marker present (confirmed, zero errors).

## Jev rubric scores (raw, 1-10 scale)
**First pass:** coverage 8.49, technical_correctness 8.19, code_validity
8.14, agency_grounding **2.47 (FAILED, revision triggered)**,
internal_consistency 8.56, readability 6.80.

**After revision** (strengthened 3 agency-note callouts, same fix
pattern as Chapter 2): coverage 8.35, technical_correctness 8.36,
code_validity 7.81, **agency_grounding 7.34 (PASSED)**,
internal_consistency 8.48, readability 6.82. All six dimensions clear
the 6/10 threshold.

## Open items / things later chapters should not contradict
- Chapter 19 (Markov models) should actually build on the §3.1
  transition-matrix convention (named `dimnames`, `rowSums()` check)
  established here as a "building this habit early" promise.
- Chapter 25 (PSA / uncertainty) should actually deliver the
  `pmap(psa_params, run_model)` pattern explicitly promised in §3.3's
  heor-practice callout, and the per-iteration `tryCatch` pattern from
  §3.7.
- Chapter 10 (survival analysis) should honor the censored-vs-missing
  event-date distinction raised in §3.6.
- Chapter 27 (model validation/QA) now has a forward commitment from
  this chapter's agency-note to cover ISPOR-SMDM transparency guidance
  on PSA iteration-count reporting specifically.
- Confirmed generalizable pattern: the agency-grounding revision fix
  from Ch.2 (name specific documents, don't gesture vaguely) works
  even on methods-agnostic chapters by anchoring to previously
  established references rather than inventing new ones — worth
  applying proactively in Ch.4 onward's agency-note callouts from the
  first draft, rather than needing a revision pass each time.
