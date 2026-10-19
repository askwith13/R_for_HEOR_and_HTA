# Chapter 20 — Partitioned Survival Models

**Part:** IV. Decision-Analytic Modelling (fourth chapter)
**Status:** complete — dimensions 1-5 (coverage, technical_correctness,
code_validity, agency_grounding, internal_consistency) all passed on
the FIRST pass. Readability FAILED the revision threshold on first
pass (5.73/10) and FAILED AGAIN after one targeted revision (5.69/10,
essentially flat) — per the skill's stop-after-two-consecutive-low-
scores rule, no further revision attempted. Flagged to Dr Aswath.

## Sections covered (map to TOC 1:1)
20.1 Structure and when it is appropriate
20.2 Building PSMs from survival extrapolations
20.3 Treatment waning and relative-effect assumptions
20.4 Modelling with `hesim`, `flexsurv` and custom code
20.5 Limitations compared with state-transition models
20.6 Worked example: an oncology CEA

## Bridge from Chapter 19
Opens by explicitly contrasting the Chapter 19 Markov cohort model
(transition matrix, cohort trace) against the Partitioned Survival
Model's (PSM) structurally different approach: state occupancy read
directly off two independently-fitted survival curves. Reuses Chapter
17 §17.2's model-type-choice framework (Siebert et al. 2012
ISPOR-SMDM Task Force-3) to justify when a PSM is the right choice —
exactly the forward-pointer Chapter 19's own closing transition
flagged as binding for this chapter. Deliberately uses a NEW synthetic
oncology (new drug vs standard of care) worked example rather than the
TB regimen running example, per Chapter 19's markdown instruction that
a genuinely survival-curve-driven oncology-style example fits this
chapter's TOC framing better than reusing the 4-state TB Markov
structure.

## Key claims and notation established (binding for later chapters)
- **§20.1**: PSM = 3-state structure (PFS, Progressed, Death) driven
  directly by two independently-fitted survival curves (PFS and OS),
  not a transition matrix. State occupancy formulas:
  P(PFS)=S_PFS(t), P(Dead)=1-S_OS(t), P(Progressed)=S_OS(t)-S_PFS(t).
  Pitfall callout: P(Progressed) can go negative if the OS and PFS
  curves cross during extrapolation — a structural flaw unique to
  PSMs that a Markov model cannot produce by construction. Cross-
  references Chapter 17 §17.2's framework for when a PSM is the right
  model-type choice (data are two KM curves, not a transition matrix).
- **§20.2**: Reuses Chapter 10's `flexsurvreg()` (real CRAN flexsurv
  function, `formula = Surv(time, event) ~ 1, data=, dist=`) fitted
  independently to PFS and OS across the same six standard parametric
  families. Extrapolation via `summary(fit, type = "survival", t =
  times)` (real flexsurv method, confirmed from Ch.10's own usage).
  Worked synthetic micro-example on PFS median ~8mo / OS median ~20mo
  Weibull fits, extrapolated to 60 months with no crossing in the base
  case, confirmed by `min(occupancy$p_progressed) >= 0`.
- **§20.3**: Treatment waning vs indefinite relative-effect
  extrapolation established as an explicit structural assumption
  requiring justification, not a software default. Agency-note
  reuses NICE DSU TSD 14 (Latimer, 2013) — already established in
  Chapter 10 — specifically on the requirement to justify waning
  assumptions, continuing the Ch.4/16/17/18/19 proactive-citation
  lesson rather than inventing a new document.
- **§20.4**: `hesim`'s PSM-specific module described at a conceptual/
  hedged level only — exact class/constructor names explicitly NOT
  asserted, since they were not independently verified via a live
  CRAN lookup during this tick. This is a DELIBERATE and CORRECT
  application of the Chapter 18 standing lesson ("a hedge is not
  itself sufficient to pass code_validity — do the lookup"): rather
  than hedge-and-hope, the chapter instead avoids asserting any new
  `hesim` PSM signature at all and relies ONLY on already-verified
  functions from Ch.10/19 (`flexsurvreg()`, `summary()`) plus a
  pointer to the live vignette. Custom from-scratch alternative given
  in full: a `psm_occupancy()` function using `summary(fit, t=,
  type="survival")` with an explicit `pmax(0, ...)` floor as the
  first line of defence against the §20.1 curve-crossing pitfall.
- **§20.5**: Four PSM limitations vs Chapter 19's Markov model: (a)
  curve crossing (pitfall callout, same mechanism as §20.1), (b) fixed
  3-state structure with no tunnel-state equivalent (cross-refs Ch.19
  §19.6 `heemod::define_state()`), (c) each arm needs its own
  independently-fitted curve pair, weaker cross-arm mechanistic link
  than a shared transition matrix, (d) two independent extrapolations
  compound rather than cancel uncertainty. Cross-references Chapter 19
  §19.9's calibration-vs-validation distinction and the Chapter 27
  forward-pointer, extending it to PSM-specific external validation.
- **§20.6**: Fully worked, self-contained synthetic oncology CEA — new
  drug vs standard of care (SOC), each arm with independently-fit
  Weibull PFS/OS curves, 20 six-month cycles (10-year horizon), NICE
  3.5% annual discounting at cycle midpoints (cross-refs Ch.4 §4.6's
  discounting formula, reused verbatim from Ch.19's own treatment).
  **CAUGHT AND FIXED a real arithmetic error during assembly**: the
  sub-agent's first draft stated an ICER of £25,603/QALY that did not
  match its own stated inputs (incremental cost £7,936.57, incremental
  QALY 0.3128 actually compute to £25,371/QALY, confirmed by an
  independent Python re-run of the full cycle-by-cycle R logic — SOC
  discounted cost £10,077.03/QALYs 1.1875, new drug discounted cost
  £18,013.61/QALYs 1.5003, incremental cost £7,936.57, incremental
  QALY 0.3128, ICER = 7936.57/0.3128 = 25,371.29). This is the SAME
  class of error flagged as a standing lesson since Chapter 4 — always
  independently verify a sub-agent's stated numeric result by doing
  the arithmetic, not just checking the code would plausibly run — and
  it recurred here despite the lesson being well-established, worth
  re-emphasizing: EVERY worked-example final number needs independent
  re-computation before the chapter is finalized, every single
  chapter, not just the first few where the lesson was learned.
  `report-table` inserted with the corrected final cost/QALY/ICER
  result. Closes with a transition to Chapter 21 (Individual-Level
  State-Transition Models / Microsimulation), noting both PSM and
  cohort Markov models track mean cohort proportions, which breaks
  down once individual patient history matters.

## Package/function-name verification (continuing Ch.6-19's lesson)
`flexsurv::flexsurvreg()` and `summary.flexsurvreg(type = "survival")`
reused from Chapter 10's already-verified usage — not re-verified from
scratch this chapter since they are now a book-wide established
reference. `hesim`'s PSM-specific module (class/constructor names)
deliberately NOT asserted in this chapter, since no live CRAN lookup
of that specific module was performed during this tick — the chapter
hedges explicitly rather than inventing a plausible-sounding signature,
consistent with (not contradicting) the Chapter 18 lesson that a hedge
alone doesn't satisfy code_validity: the Jev score (7.3/10 on
code_validity) confirms this approach — avoid-and-point-to-source
beats hedge-and-assert for a signature not actually looked up.

## Agency grounding (proactive, per the Ch.4/16/17/18/19 lesson)
Reuses NICE DSU TSD 14 (Latimer, 2013) — already established in
Chapter 10 — on justifying extrapolation and waning assumptions
(§20.3), rather than inventing a new citation, since this chapter's
content is a direct continuation of Ch.10's extrapolation methodology
applied to a PSM context rather than a genuinely new methodological
area needing its own document.

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: logged new candidate C16 (§20.1
  three-state PSM structure) as Skipped — the structure and its
  occupancy formulas are already fully captured by prose + formula
  block + the §20.2 worked numeric check; a PSM's "states" are
  entirely curve-derived rather than linked by estimated transitions
  worth diagramming the way a Markov model's states are.
- **Track 2 (R-generated charts)**: logged new candidate T23 (§20.6
  stacked-area PFS/Progressed/Dead occupancy trace, one panel per arm)
  as Pending, no `// TODO-IMAGE` marker inserted since the worked
  arithmetic stands alone without it (same convention as T12/T16/T17
  for optional supply-later candidates).

## "How to report this" table check (per the mandatory step 11c)
One `report-table` insertion: §20.6's final oncology CEA result
(cost/QALYs/incremental/ICER per arm) — a genuine computed result from
this chapter's own worked example, correctly using `report-table` (not
`ref-table`) per the skill's distinction. No other code block in this
chapter produces a result with a genuine conventional reporting format
distinct from this one (§20.2's occupancy trace and §20.4's custom
function are illustrative of method, not a final reportable result).

## Jev rubric scores (raw, 1-10 scale)
**First pass (dimensions 1-5)**: coverage 8.34, technical_correctness
7.22, code_validity 7.3, agency_grounding 7.8, internal_consistency
8.16 — all five pass, no revision needed on these dimensions.
**Readability (prose-only method)**: FIRST PASS 5.73/10 (FAILED).
Did one revision pass targeting dense sentences in the opening bridge,
§20.1, §20.4, and §20.5 (splitting long compound sentences into
shorter ones, replacing semicolon-chained clauses with separate
sentences). RE-SCORE: 5.69/10 — essentially flat, still FAILS. Per
the skill's stop-after-two-consecutive-low-scores rule, did NOT attempt
a third revision. Flagged to Dr Aswath in the cron report.

## Open items / things later chapters should not contradict
- **Readability flag remains open for Chapter 20** (5.69/10, prose-only
  method), the fifth chapter in the book with this issue after Chapters
  10, 13, 14, and 15 — joining Chapter 13's still-genuinely-open case
  rather than the resolved Ch.10/15 cases. Possible contributing factor
  worth testing later: this chapter has unusually many short, dense
  technical asides (hedged package-API caveats, pmax() floor
  explanations, curve-crossing mechanics restated three times across
  §20.1/20.4/20.5) that may read as repetitive/dense even at the
  sentence-length level the revision targeted — a structural edit
  (consolidating the curve-crossing explanation to ONE place with
  cross-references elsewhere, rather than three near-identical
  restatements) might be a different, more effective fix than further
  sentence-splitting, worth trying if Dr Aswath asks for a deeper pass.
- Chapter 21 (Individual-Level State-Transition Models /
  Microsimulation) should pick up this chapter's closing transition:
  both the PSM and the Chapter 19 Markov model track mean cohort
  proportions, which breaks down once individual patient history
  (cumulative treatment exposure, time already progression-free,
  prior-line-dependent costs) matters — that's the microsimulation
  chapter's reason to exist.
- `flexsurv::flexsurvreg()`/`summary(type="survival")` remain the
  book's verified survival-fitting references; Chapter 21 should
  verify any NEW `hesim`/microsimulation-specific signatures with the
  same live-lookup discipline before using them, rather than hedging.
- The oncology-CEA numbers established in §20.6 (SOC discounted cost
  £10,077.03/QALYs 1.1875; new drug discounted cost £18,013.61/QALYs
  1.5003; ICER £25,371/QALY) are now book-wide reference numbers if any
  later chapter revisits this exact PSM worked example.
- **Standing lesson reinforced (not new, but worth restating since it
  recurred)**: independently re-verify EVERY stated final numeric
  result in a sub-agent's worked example, every chapter, even this far
  into the book — the Chapter 4 arithmetic-verification lesson is not
  a one-time fix, it needs active application on every single
  worked-example number, every tick.
