# Chapter 23 — Budget Impact Analysis

**Part:** IV. Decision-Analytic Modelling (seventh and final chapter of
Part IV — Chapter 24 is the final chapter, but belongs to a different
methodological cluster: cost-benefit/distributional/extended CEA).
**Status:** complete — ALL SIX Jev rubric dimensions passed on the
FIRST draft, no revision pass needed (the fifth chapter in the book to
do so entirely cleanly, after Ch.4, Ch.5, Ch.12, Ch.19).

## Sections covered (map to TOC 1:1)
23.1 Purpose and ISPOR guidance
23.2 Population, uptake and market-share structure
23.3 Building a budget impact model in R
23.4 Scenario analyses
23.5 Presenting results to payers

## Bridge from Chapter 22
Opens on Chapter 22's explicit closing signpost: the book moves from the
clinical/epidemiological model-structure sequence (decision trees ->
Markov cohort -> partitioned survival -> microsimulation -> DES/dynamic
transmission, Ch.17-22) into budget-impact and distributional methods
(Ch.23-24). This chapter's core teaching point, stated immediately and
repeatedly: **BIA is NOT a shorter CEA** — it is a structurally
different payer-budget accounting exercise (short undiscounted horizon,
no health outcomes in the calculation, reference-vs-new scenario
comparison), not a truncated/undiscounted slice of the lifetime
cost/QALY models built in every prior Part IV chapter.

## Key claims and notation established (binding for later chapters)
- **§23.1**: BIA vs CEA distinction crystallized: CEA = lifetime,
  discounted, cost-per-QALY, societal/system perspective (Ch.17-22's
  entire territory); BIA = short horizon (1-5 years per ISPOR), payer's
  own budget perspective, undiscounted cash flow, reference-scenario
  ("world without") vs new-scenario ("world with") comparison, no health
  outcomes. **New named agency reference, the defining document for this
  entire chapter**: Sullivan SD, Mauskopf JA, Augustovski F, et al.
  (2014), "Budget Impact Analysis — Principles of Good Practice: Report
  of the ISPOR 2012 Budget Impact Analysis Good Practice II Task Force"
  (*Value in Health* 17(1):5-14) — 5 core structural requirements (short
  explicit horizon, payer-specific perspective, reference-vs-new
  scenario comparison, realistic population/uptake/market-share
  estimates, transparent reporting) used as the chapter's organizing
  skeleton across §23.2-23.5.
- **§23.2**: Three population-level ingredients built: (a) eligible
  population via a top-down epidemiological cascade (covered lives ->
  prevalence -> diagnosed -> meets label criteria -> eligible), R code
  using `dplyr::cumprod()`; (b) market share split TWICE (reference
  scenario vs new scenario) with an explicit worked netting-out example
  (1000 patients, reference $590,000 vs new-scenario $712,000, budget
  impact $122,000 — NOT the naive gross $240,000 figure); (c) uptake/
  diffusion curves, linear ramp vs logistic S-curve, R code with a
  `logistic_uptake()` function (peak_share=0.35 over 5 years).
- **§23.3**: Full worked, hand-verified BIA model via a parameterized
  `build_bia()` R function (base R/dplyr, `tibble`). 5-year horizon,
  flat eligible population 10,000/year, uptake 5/15/30/45/55%, SoC cost
  $500/patient-year, new drug $2,000/patient-year gross minus a $300/
  patient-year hospitalization offset = $1,700 net. Year-by-year budget
  impact: $600,000 / $1,800,000 / $3,600,000 / $5,400,000 / $6,600,000;
  cumulative $18,000,000 — independently verified by hand two ways
  (bottom-up sum of yearly impacts, and top-down subtraction of total
  new-mix cost $43,000,000 minus total current-mix cost $25,000,000),
  both agreeing exactly.
- **§23.4**: Two scenario analyses built as one-line parameter changes to
  the SAME `build_bia()` function (no copy-pasted model variants):
  faster-uptake (10/25/40/55/65%) and a managed-entry-agreement (MEA)
  price-reduction scenario ($1,500 list price vs $2,000 base case, net
  cost $1,200 after the same $300 offset). MEA scenario budget impact
  year-by-year: $350,000 / $1,050,000 / $2,100,000 / $3,150,000 /
  $3,850,000; cumulative $10,500,000 — $7,500,000 LOWER than the base
  case's $18,000,000, again verified both bottom-up and top-down.
- **§23.5**: Payer-facing presentation conventions: a `report-table`
  (`<tab-ch23-bia-result>`) reproducing the chapter's own §23.3 computed
  results exactly — correctly using `report-table` since it reports a
  result the chapter's own code just produced, not a reference/
  comparison table. Explicit instruction (anchored to an agency-note on
  NICE/CADTH-style submission templates) that acquisition cost and
  offset cost must be reported as SEPARATE lines, never pre-netted, even
  though netting is fine inside the R code itself. `ggplot2` combination
  bar+line chart code for annual vs cumulative budget impact, with a
  `TODO-IMAGE` marker (no fabricated figure) per the book's Track-2
  convention.

## Independent verification performed during assembly
All stated numeric claims across both sub-agent drafts were
independently re-checked by hand before finalizing (continuing the
Ch.4/6/19/20/22 standing lesson — verify, don't just read for
plausibility):
- §23.2's market-share netting example (1000 patients, 70/30 Drug A/B
  split, 20% new-drug uptake in year 2): reference $590,000, new
  scenario $712,000, budget impact $122,000 — hand-recomputed and
  matched the draft exactly.
- §23.3's base-case year-by-year and cumulative budget impact figures
  (summing to $18,000,000) — recomputed both bottom-up (sum of 5 yearly
  impacts) and top-down (total new-mix minus total current-mix), both
  routes agree and match the draft.
- §23.4's MEA scenario year-by-year and cumulative figures (summing to
  $10,500,000, a $7,500,000 reduction from base case) — recomputed the
  same two ways, both agree and match the draft. No arithmetic
  corrections were needed in either sub-agent's draft this chapter.

## Package/function-name verification
All R code uses only well-established, safe functions: base R, `dplyr`
(`mutate()`, `select()`, `bind_rows()`, `cumprod()`), `tidyr`
(`pivot_longer()`), `tibble::tibble()`, `ggplot2` (`geom_line()`,
`geom_col()`, `scale_y_continuous(labels = scales::dollar)`). No
invented packages or fabricated function signatures — this chapter's
code surface is deliberately simple (unlike the heavier
hesim/flexsurv/simmer/deSolve machinery of Ch.17-22) since BIA's
distinctive content is the accounting LOGIC, not a new specialized R
package.

## Agency grounding (one major new reference, continuing the proactive-citation discipline)
Sullivan et al. (2014) ISPOR BIA Good Practice II Task Force report is
THE defining citation for this chapter, introduced in §23.1 and used as
the organizing skeleton (5 requirements) referenced implicitly
throughout §23.2-23.5. A second agency-note in §23.5 references
NICE/CADTH-style submission-template conventions on separate
acquisition-vs-offset reporting lines (general agency practice, not a
single named document — consistent with how this book treats
well-established cross-agency submission conventions elsewhere).

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: no new candidate logged — the
  reference-vs-new-scenario structure and the eligible-population
  cascade are already made concrete by the chapter's own R code and
  worked arithmetic; no additional structural/process diagram judged
  necessary this chapter.
- **Track 2 (R-generated charts)**: two new candidates logged — (a)
  §23.2's two-line uptake-curve chart (linear vs logistic diffusion,
  terminal share 0.35, 5-year horizon) with a `TODO-IMAGE` marker
  inserted at the exact code location; (b) §23.5's combination bar+line
  chart (annual budget impact as bars, cumulative as an overlaid line)
  with a `TODO-IMAGE` marker inserted at the exact code location. Both
  Pending — Dr Aswath to supply after running the embedded `ggplot2`
  code.

## "How to report this" table check (per the mandatory step 11c)
One `report-table` insertion: §23.5's base-case year-by-year budget
impact table (`<tab-ch23-bia-result>`) — a genuine computed result from
the chapter's own `build_bia()` worked example in §23.3, correctly using
`report-table` (not `ref-table`, since this reports actual numbers the
chapter's own code just produced, not an organizational/comparison
table). No other code block in this chapter produces a distinct
reportable result warranting a second table — §23.4's scenario results
are reported in prose with hand-verifiable arithmetic rather than a
second table, keeping the chapter to one table as is typical for a
shorter, more narrowly-scoped chapter.

## Shiny app candidate scan (per the mandatory step 11f)
One genuine candidate logged in `progress/shiny_app_candidates.md`:
**Budget Impact Scenario Explorer** (§23.2-23.4) — sliders for terminal
uptake share, new-drug list price, and hospitalization offset, live
recomputing the year-by-year and cumulative budget-impact table and
chart via the same `build_bia()` logic already in the chapter. This is
a strong, non-forced candidate: the non-linear interaction between
uptake-curve shape and price materially changes WHEN the budget impact
becomes affordable in a way that is far more intuitive to explore live
than to read as three static scenario tables. Updated the file's total
count and coverage line (1-22 -> 1-23).

## Jev rubric scores (raw, 1-10 scale)
**First and only pass — all six dimensions cleared the 6/10 threshold,
no revision needed**: coverage 8.25, technical_correctness 7.82,
code_validity 7.25, agency_grounding 7.55, internal_consistency 8.32.
**Readability (prose-only method)**: 6.89/10 (PASSED on the first
draft).

## Open items / things later chapters should not contradict
- Chapter 24 (Cost-Benefit, Distributional and Extended Cost-Effectiveness
  Analysis) is the final chapter of Part IV and should NOT reintroduce
  BIA's reference-vs-new-scenario accounting pattern from scratch if it
  needs a similar structure for extended-CEA financial-risk-protection
  work — cross-reference this chapter's `build_bia()` pattern if the
  mechanics genuinely recur, rather than re-deriving.
- The Sullivan et al. (2014) ISPOR BIA Good Practice II Task Force
  report is now a book-wide reference specifically for budget-impact
  methodology — distinct from the Siebert et al. (2012) Task Force-3
  (model-structure choice), Karnon et al. (2012) Task Force-4 (DES),
  Pitman et al. (2012) Task Force-5 (dynamic transmission), and Briggs
  et al. (2012) Task Force-6 (parameter estimation) references already
  established in Ch.17/21/22 — five distinct ISPOR-SMDM/ISPOR Task Force
  reports are now named and citable across the book's decision-modelling
  Part.
- `build_bia()`'s worked numbers (base case cumulative $18,000,000;
  faster-uptake and MEA scenario variants; MEA cumulative $10,500,000)
  are now book-wide reference figures if any later chapter revisits this
  exact illustrative drug/offset structure — treat them as fixed,
  independently-verified inputs rather than re-deriving differently.
- No new Part divider needed for Chapter 23 (continues Part IV, which
  started at Chapter 17) — the next required divider is Part V
  ("Uncertainty, Value of Information and Model Validation") before
  Chapter 25, per the skill's standing Part-boundary table. Chapter 24
  still belongs to Part IV.
