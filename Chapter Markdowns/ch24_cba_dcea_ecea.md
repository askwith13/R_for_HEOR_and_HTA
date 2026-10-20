# Chapter 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis

**Part:** IV. Decision-Analytic Modelling (final chapter of Part IV — Part V,
"Uncertainty, Value of Information and Model Validation," begins at Chapter 25).
**Status:** complete — ALL SIX Jev rubric dimensions passed on the FIRST draft,
no revision pass needed.

## Sections covered (map to TOC 1:1)
24.1 Monetary valuation of health
24.2 Distributional CEA and equity weighting
24.3 Extended CEA: financial risk protection
24.4 Multi-criteria decision analysis (MCDA) in R
24.5 Severity modifiers, value-based pricing and managed entry agreements

## Bridge from Chapter 23
Chapters 17-23 shared the convention that health is the only outcome dimension
and only cost is monetized; Chapter 24 steps outside that convention in five
different directions (monetizing health itself, making distribution explicit,
adding a non-health outcome, formalizing multi-axis decisions, adjusting the
price/threshold side directly) — explicitly framed as extensions/alternative
lenses on the existing CEA machinery, not replacements for it.

## Key claims and notation established (binding for later chapters)
- **§24.1**: CBA vs CEA framing — CBA monetizes BOTH cost and benefit (CEA only
  cost); VSL defined via a worked example (100,000 people x \$100 WTP x 1-in-
  100,000 risk reduction = \$10M implied VSL); real current agency figures
  cited: US DOT \$13.2M (2023\$), EPA \$7.4M (2006\$), HHS 2024 low/central/high
  \$6.1M/\$13.1M/\$19.9M; human-capital approach worked example (\$45,000/yr,
  10 years, 3% discount) → PV = \$395,375 (independently verified in Python:
  \$395,374.90, rounds to the stated figure); WTP approach contrasted. One
  `ref-table` comparing human-capital/WTP/VSL (reference content, correctly
  NOT `report-table` since it's a comparison, not a computed chapter result).
- **§24.2**: DCEA defined (disaggregates cost/health by equity-relevant
  subgroup, e.g. deprivation quintile); real citation **Asaria et al.**
  bowel-cancer-screening DCEA finding (targeted vs universal strategies);
  equity impact plane (**Cookson et al.**) with explicit 4-quadrant framing
  (win-win / lose-lose / efficient-unfair / fair-less-efficient); equity
  weighting defined as an explicit value judgement, not a technical
  correction. Toy 2-subgroup R worked example: Q1 (most deprived, 1000 pts,
  0.12 QALY gain, equity weight 1.5) vs Q5 (least deprived, 1000 pts, 0.08
  QALY gain, weight 1.0), both \$2,000/pt cost — **unweighted ICER
  \$20,000/QALY, equity-weighted ICER \$15,384.62/QALY**, independently
  re-verified exact in this session. `report-table` used correctly (chapter's
  own computed result). Agency-note: **NICE does NOT apply formal equity
  weighting in its reference case** — distinct from the severity modifier
  covered later in §24.5; this distinction is binding for later chapters.
- **§24.3**: ECEA defined, attributed to **Verguet/DCP3/Gates Foundation**
  work; real citation **Verguet et al. 2015** *Health Economics*, "Universal
  public finance of tuberculosis treatment in India" — directly reuses this
  book's own TB/India running thread (Ch.5, 9, 19, 21). CHE and
  poverty-cases-averted defined as complementary, non-interchangeable FRP
  metrics. Full parameterized `ecea_frp()` R function (5 quintiles x 20,000
  households, OOP \$150→\$20 status-quo-to-new-policy, 10% CHE threshold,
  \$400 poverty line) — independently re-verified in Python: **CHE cases
  averted = 53,333.33 total** (Q1 20,000 + Q2 20,000 + Q3 13,333.33, Q4/Q5
  zero), **poverty cases averted = 6,500** (entirely in Q1). `report-table`
  with full quintile breakdown. Pitfall: FRP outcomes are NOT denominated in
  the same units as a QALY/ICER and must be reported in parallel, never
  folded into a single combined metric.
- **§24.4**: MCDA general concept (weights + criteria + scores → combined
  ranking); weighted-sum vs weighted-product mathematically distinguished
  ($sum w_i s_i$ vs $product s_i^(w_i)$). Explicitly disclosed a
  tooling-honesty choice: `MCDA::weightedSum()` exists on CRAN but its live
  signature wasn't independently verifiable this session, so the worked
  example was built in base R/dplyr instead rather than guessing a call —
  consistent with the book's standing verification discipline. 3-drug/
  4-criteria worked example (efficacy 0.35, safety 0.25, severity 0.20,
  economic 0.20) — independently re-verified exact: weighted sum Drug
  A=67.5, Drug B=69.5 (winner), Drug C=68.0; weighted product Drug A=66.49,
  Drug B=68.48 (still winner), Drug C=64.53. `report-table` with all 3 drugs
  x 4 criteria x 2 scores. EVIDEM explained as the real, named health-sector
  MCDA framework (Goetghebeur et al. ~2008, MCDA Core Model ~14-15 criteria +
  Contextual Tool ~6 qualitative considerations).
- **§24.5**: NICE severity modifier explained (Jan 2022, replaced end-of-life
  modifier); absolute/proportional QALY shortfall defined with Table 6.1
  PMG36 weight bands (1/1.2/1.7, whichever measure implies the HIGHER
  weight). R worked example (qale_general=20.4, qale_condition=4.2) —
  independently re-verified exact: absolute shortfall=16.2, proportional
  shortfall≈0.794, severity weight=1.2, unweighted ICER \$30,000/QALY →
  severity-weighted ICER \$25,000/QALY. Value-based pricing explained via
  the inverted ICER-threshold relationship (price = threshold × incremental
  QALY + comparator cost); NICE's 2014 VBP consultation referenced
  accurately (did not replace standard appraisal). MEA section explicitly
  **cross-references Ch.23's `build_bia()` MEA scenario rather than
  re-deriving it** (per the skill's standing cross-reference-don't-rederive
  discipline). `ref-table` of 3 MEA types (financial-based, outcomes-based
  coverage-with-evidence-development, outcomes-based patient-level).

## Independent verification performed during assembly
All stated numeric claims across both sub-agent drafts were independently
re-checked in Python before finalizing (continuing the Ch.4/6/19/20/22/23
standing lesson):
- §24.1 human-capital PV: \$395,374.90 (matches stated \$395,375 rounded) —
  exact.
- §24.2 toy DCEA example: unweighted ICER \$20,000/QALY, equity-weighted
  ICER \$15,384.615.../QALY (matches stated \$15,384.62 rounded) — exact.
- §24.3 ECEA worked example: CHE cases averted 53,333.33 total, poverty cases
  averted 6,500 — both exact, including the Q3 fractional-band calculation.
- §24.4 MCDA worked example: all 3 drugs' weighted-sum and weighted-product
  scores — exact match to 2 decimal places.
- §24.5 severity modifier: absolute shortfall 16.2, proportional shortfall
  0.794, severity weight 1.2, unweighted ICER \$30,000/QALY, weighted ICER
  \$25,000/QALY — exact.
No arithmetic corrections were needed in either sub-agent's draft this
chapter — every stated number matched independent recomputation.

## Formatting fixes made during assembly (Typst-specific)
Two real Typst bugs caught and fixed before compiling:
1. **Double-star bold (`**text**`) is not valid Typst syntax** (Typst uses
   single `*text*` for bold) — both sub-agent drafts used `**...**` in three
   places (two in §24.3's worked-example prose, one in §24.5's severity-
   weight sentence), which compiled with a "no text within stars" warning
   and rendered literal stray asterisks. Fixed by converting all three to
   single-star emphasis.
2. **The book's known `{,}` thousands-separator-in-math-mode bug recurred**
   (already documented in the skill as a confirmed formatting pitfall) — one
   sub-agent wrote `$2{,}400$` and `$30{,}000$` inside math mode in §24.5.
   Fixed by removing the thousands separator inside math mode entirely
   (`$2400$`, `$30000$`) per the skill's existing guidance (plain prose text
   outside math mode can keep the comma; math mode cannot).

## Package/function-name verification
All R code uses only well-established functions: base R, `dplyr`
(`mutate()`, `select()`, `rowwise()`, `c_across()`, `arrange()`), `tibble`
(`tibble()`, `tribble()`). §24.4 explicitly avoided an unverified
`MCDA::weightedSum()` call signature in favor of a transparent base-R/dplyr
implementation — a disclosed, defensible tooling-honesty choice rather than
a guessed interface.

## Agency grounding (new references established this chapter)
- **Asaria et al.** (DCEA/York tradition) — bowel-cancer-screening targeted-
  vs-universal distributional finding, §24.2.
- **Cookson et al.** — the equity impact plane framework, §24.2.
- **Verguet, Laxminarayan & Jamison (2015)**; **Verguet, Kim & Jamison
  (2016)** — ECEA/DCP3 methodology origin, §24.3.
- **Verguet et al. (2015)**, *Health Economics* — "Universal public finance
  of tuberculosis treatment in India: an extended cost-effectiveness
  analysis" — the book's own TB/India thread's direct published ECEA
  instance, §24.3.
- **Goetghebeur et al. (~2008)** — EVIDEM framework origin, §24.4.
- NICE technology appraisal methods manual (PMG36), effective Jan 2022 —
  Table 6.1 severity modifier, §24.5.
- NICE's 2014 value-based-pricing consultation (referenced accurately as
  NOT having replaced the standard appraisal process), §24.5.

## Image tracking (per skill's mandatory step 11b)
- **Track 1**: C19 logged as Skipped — each subsection already made
  concrete by a worked numeric R example and table; no structural diagram
  judged necessary.
- **Track 2**: two new candidates logged — T27 (§24.2 equity impact plane
  2x2 quadrant chart) and T28 (§24.3 CHE/poverty cases averted by quintile,
  grouped bar chart). Both Pending, no `TODO-IMAGE` marker inserted since
  both concepts are already made concrete in prose + report-table.

## "How to report this" table check (per the mandatory step 11c)
Three `report-table` insertions (§24.2 toy DCEA ICER comparison, §24.3 ECEA
FRP-by-quintile, §24.4 MCDA scores) — all correctly used since each reports
a result the chapter's own code just produced. Two `ref-table` insertions
(§24.1 VSL/human-capital/WTP comparison, §24.5 MEA types) — correctly NOT
labelled "How to report this" since both are organizational/comparison
content, not computed chapter results.

## Shiny app candidate scan (per the mandatory step 11f)
Three genuine candidates logged in `progress/shiny_app_candidates.md`:
Equity-Weighted ICER Explorer (§24.2), ECEA Financial Risk Protection
Dashboard (§24.3), MCDA Weight Sensitivity Explorer (§24.4) — all strong,
non-forced candidates since each directly operationalizes a chapter-stated
point (the equity trade-off direction, the quintile-cutoff sensitivity, and
the pitfall box's own call for weight-sensitivity analysis respectively).
File's total count and coverage line updated (43→46 across 21→22 chapters).

## Jev rubric scores (raw, 1-10 scale)
**First and only pass — all six dimensions cleared the 6/10 threshold, no
revision needed**: coverage 8.52, technical_correctness 6.86, code_validity
6.93, agency_grounding 8.23, internal_consistency 8.43. **Readability
(prose-only method)**: 6.76/10 (PASSED on the first draft).

## Open items / things later chapters should not contradict
- Chapter 24 is the FINAL chapter of Part IV. Chapter 25 ("Handling
  Uncertainty: Deterministic and Probabilistic Sensitivity Analysis," per
  the TOC) is the FIRST chapter of Part V ("Uncertainty, Value of
  Information and Model Validation") and REQUIRES a new
  `#part-divider("V", "Uncertainty, Value of Information and Model
  Validation")` call inserted into `book.typ` before its `#include` — do
  not miss this per the skill's standing Part-boundary table.
- NICE's equity-handling landscape is now fully distinguished across three
  separate mechanisms, which later chapters should keep consistent: (1) the
  reference case uses an UNWEIGHTED QALY with no formal equity weight
  (§24.2), (2) the severity modifier (§24.5) is a SEPARATE, formulaic
  QALY-shortfall-based uplift mechanism, NOT the same thing as equity
  weighting from distributional CEA, (3) DCEA/formal equity weighting remain
  supplementary/academic tools, not mandatory reference-case steps.
- `build_bia()`'s MEA scenario (Ch.23, cumulative \$10,500,000 vs \$18,000,000
  base case) is the book's established cross-reference point for any later
  chapter discussing managed entry agreements — cross-reference, don't
  re-derive, per the pattern Ch.24 §24.5 itself followed.
- The Sullivan et al. (2014), Siebert et al. (2012), Karnon et al. (2012),
  Pitman et al. (2012), and Briggs et al. (2012) ISPOR/ISPOR-SMDM Task Force
  references (Ch.17/21/22/23) plus this chapter's new Verguet/Asaria/
  Cookson/Goetghebeur references together form the book's full
  decision-modelling citation base as Part IV closes.
- No new Part divider was needed for Chapter 24 itself (still Part IV,
  started at Chapter 17) — the Part V divider is needed starting Chapter 25,
  per the note above.
