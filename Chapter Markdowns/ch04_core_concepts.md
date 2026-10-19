# Chapter 4 — Core Concepts in Health Economics (with R Illustrations)

**Part:** I. Foundations
**Status:** complete (NO revision pass needed — all six dimensions passed on first draft)

## Sections covered (map to TOC 1:1)
4.1 Costs, effects and the opportunity cost of health care
4.2 Types of economic evaluation
4.3 QALYs, DALYs and life-years
4.4 ICERs, net monetary benefit (NMB) and net health benefit (NHB)
4.5 Willingness-to-pay thresholds, including country-specific and LMIC thresholds
4.6 Perspective, time horizon, discounting and half-cycle correction
4.7 Dominance, extended dominance and the efficiency frontier
4.8 Coding a first simple CEA in R

## Milestone chapter
This is the first chapter with actual health-economics content (Ch.1-3
were scope/infrastructure/R-skills only) and §4.8 is **the book's first
executed health-economic R calculation** — explicitly framed that way
in the prose as a payoff after three chapters of foundation-building.

## Key concepts and notation established (binding for all later chapters)
- **Opportunity cost / scarcity framing** — cost-effectiveness is
  comparative, never absolute. Cost taxonomy: direct medical / direct
  non-medical / indirect (productivity).
- **Drummond 5-type taxonomy**: CMA, CEA (natural units), CUA (QALYs —
  the HTA default), CBA (monetizes health), CCA (disaggregated
  balance-sheet). CUA's dominance explained via cross-disease-area
  comparability.
- **QALY** = Σ(tᵢ × uᵢ), utility anchored 1=full health/0=dead, **can go
  negative** for worse-than-death states. **DALY** = YLL + YLD, WHO/GBD
  convention, **opposite sign** to QALY (burden to minimize, not a good
  to maximize) — DALYs *averted* is the benefit quantity, not raw DALYs.
- **ICER = ΔC/ΔE** (consistent with Ch.1). **NMB = (ΔE×λ) − ΔC**, **NHB
  = ΔE − (ΔC/λ)** — linear alternatives avoiding the ICER's
  sign-ambiguity/quadrant-confusion problem.
- **WTP thresholds**: NICE's £20–30k/QALY (historical, contested, not
  empirically derived — Claxton's NHS-marginal-productivity work
  suggested £12–15k). WHO-CHOICE's 1–3× GDP-per-capita heuristic —
  **explicitly abandoned by WHO itself** (real citation: Bertram et al.
  2016, Bulletin of the WHO). HTAIn's own below-1×-GDP opportunity-cost
  threshold, distinct from the superseded WHO rule.
- **Perspective** (payer vs societal), **time horizon** (lifetime for
  chronic disease), **discounting** (value/(1+r)^t, NICE 3.5% equal
  rate for costs+effects, differential-discounting debate noted),
  **half-cycle correction** (conceptual only, full mechanics deferred to
  Ch.19 as promised).
- **Simple dominance** (worse on both axes → delete) and **extended
  dominance** (dominated by a mix of two frontier points; geometric
  "above the line" test ≡ numerical "ICER not rising monotonically"
  test). **Efficiency frontier** = non-dominated, cost-ranked set with
  non-decreasing ICERs. ICERs are only valid between *adjacent* frontier
  points.
- **§4.8 R pipeline** (binding pattern for later chapters, especially
  Part IV): `arrange(cost)` → remove simple dominance (custom function
  tracking best-QALY-so-far) → remove extended dominance (repeat loop
  checking ICER monotonicity via `lag()`) → compute incremental
  cost/QALY/ICER with `mutate()` + `lag()`. Toy 4-treatment example
  (Standard Care/Drug A/Drug B/Drug C) — Drug B correctly eliminated by
  simple dominance; final frontier ICERs £18,947 then £30,000 (correctly
  rising).

## Correction made during assembly (worth flagging)
The sub-agent draft for §4.4 contained a **real arithmetic error**: it
stated the worked-example ICER as "£7,467/QALY" but the actual inputs
(ΔC=£16,800, ΔE=0.28) compute to **£60,000/QALY**. Caught this during
assembly by actually doing the division rather than trusting the
sub-agent's stated figure. Fixed throughout — including the downstream
NMB consistency-check paragraph, which originally tried to reconcile a
negative NMB against a "favourable-looking" £7,467 ICER (a contradiction
that would never actually arise) and had to be rewritten to correctly
show NMB and the corrected £60,000 ICER agreeing (both say "not
cost-effective at £20k threshold"). **Lesson for the pipeline**:
always independently verify any stated numeric result in sub-agent R
output by doing the arithmetic yourself before assembling — don't trust
a worked example's stated number just because the code shown would, if
run, produce *some* number.

## Agency grounding — proactive application of the Ch.2/Ch.3 lesson
This chapter's agency-notes were grounded in specific named documents
**from the first draft**, per the lesson explicitly flagged in Ch.3's
markdown summary. Result: agency_grounding scored **8.85/10 on the
first pass — no revision needed**, confirming that proactive citation
discipline from the start avoids the revision cycle entirely. Specific
citations used: NICE's *Health Technology Evaluations: The Manual*
(PMG36, 2022) — cited 3 times across §4.2/4.5/4.6/4.7 for QALY
requirement, threshold range, discount rate, and fully-incremental-
analysis expectation; HTAIn reference case (§4.2, §4.5); WHO-CHOICE +
the real Bertram et al. 2016 Bulletin of the WHO citation (§4.5); WHO
Global Burden of Disease DALY framework (§4.3); ISPOR-SMDM Modeling
Good Research Practices Task Force, Caro et al. 2012, *Value in
Health*/*Medical Decision Making* (§4.7).

## Code
All R code real, syntactically correct, and verified by independent
arithmetic check (see correction above). Uses `tibble`, `dplyr`
(`arrange`, `filter`, `mutate`, `lag`, `select`) correctly throughout.

## Image tracking (per skill's mandatory step 11b)
- **Track 1:** none identified for this chapter — no genuinely
  non-data-driven structural/process concept needing a Claude-made
  diagram.
- **Track 2:** logged T2 — a ggplot2 cost-effectiveness-plane plot of
  the chapter's own §4.8 toy data (4 treatments, QALY x-axis/cost
  y-axis, Drug B visibly dominated, frontier line connecting the 3
  surviving treatments). This is squarely Track 2 (not Track 1) because
  it plots the EXACT data already in the chapter's R example — Dr
  Aswath should extend the §4.8 script with one `ggplot()` call.
  `TODO-IMAGE` marker inserted immediately after the results table in
  §4.8; book compiles cleanly with the marker present.

## Jev rubric scores (raw, 1-10 scale) — single pass, no revision
coverage 8.33, technical_correctness 8.33, code_validity 7.69,
agency_grounding **8.85**, internal_consistency 8.75, readability 6.97.
All six dimensions clear the 6/10 threshold on the first draft.

## Open items / things later chapters should not contradict
- Chapter 19 (Markov models) owes the full half-cycle-correction
  mechanics promised here in §4.6.
- Chapter 25 (PSA/uncertainty) owes: (a) the NMB-as-PSA-default pattern
  promised in §4.4's heor-practice callout, (b) the CEAC construction
  promised in §4.5's heor-practice callout, (c) turning this chapter's
  exact 4-treatment point estimates probabilistic, as explicitly
  promised in §4.8's closing paragraph.
- Chapter 10 (survival analysis) and Chapter 19 (Markov models) should
  reuse the §4.8 `build_frontier()`-style dominance/extended-dominance
  pipeline pattern — flagged in §4.8's heor-practice callout as a
  reusable function worth generalizing.
- Confirmed generalizable lesson: proactively grounding agency-notes in
  named documents from the first draft (rather than fixing it in a
  revision pass) is both achievable and avoids an entire review cycle —
  continue this discipline into Ch.5 onward.
- New lesson from this chapter: independently verify any stated numeric
  result in a sub-agent's worked R example by doing the arithmetic
  yourself during assembly, not just checking that the code would run.
