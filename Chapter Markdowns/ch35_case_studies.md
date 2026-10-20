# Chapter 35: End-to-End Worked Case Studies

**Part VIII: Case Studies** (first and only chapter of this Part — new Part divider added, Part VIII opens here). This is the **final chapter of the entire 35-chapter book.**

## Status
Drafted via interactive session (2026-10-21), delegating 35.1-35.2, 35.3, and 35.4-35.6 to three parallel sub-agents, assembled into one Typst file. TWO revision passes needed (on two different dimensions, not a repeated failure on the same one — agency_grounding then code_validity) — all six Jev rubric dimensions now pass.

## Jev scores (raw, 1-10, after revisions)
- Coverage: 8.20
- Technical correctness: 7.51
- Code validity: 7.19 (was 5.88 after fixing agency_grounding, fixed in a second pass)
- Agency grounding: 7.97 (was 4.45 on first draft, fixed in the first revision pass)
- Internal consistency: 8.38
- Readability (prose-only): 6.31

## What the chapter covers

This is a synthesis chapter — no new statistical theory, six complete start-to-finish worked examples built around new simulated data and new numbers for each.

**35.1 Case study A: Markov model CEA (chronic kidney disease progression).** 5-state matrix-based base-R cohort Markov model (CKD3 → CKD4 → CKD5 pre-dialysis → dialysis → death), SGLT2i-class add-on vs. standard of care, 25-year horizon, 3% discounting. PSA (2000 draws) and cost-effectiveness acceptability curve. New agency-note names NICE's real £20,000-£30,000/QALY reference-case range (Chapter 31 §31.1) and real jurisdictional variation (PBAC, CADTH), correctly cross-referencing Chapter 25 §25.5's CEAC content.

**35.2 Case study B: oncology partitioned survival model with NMA inputs (metastatic urothelial carcinoma).** flexsurv Weibull fits on simulated 400-patient comparator IPD, NMA-derived hazard ratios (OS 0.68, PFS 0.74) correctly treated as already-validated inputs from Chapter 12's NMA machinery rather than re-derived. Two structural-uncertainty scenarios: log-logistic OS extrapolation, and treatment-effect waning. **A genuine bug was caught and fixed during independent verification**: the sub-agent's original Scenario 2 (waning) R code was a non-functional stub that defined two helper functions but never actually computed anything — replaced with a complete, independently-run numerical-integration implementation, and the stated numbers corrected from unreproducible placeholders (71,021 / 0.1821 / 389,943) to the real verified output (61,341 / 0.1798 / 341,219).

**35.3 Case study C: microsimulation of a screening programme (colorectal cancer).** 7-state, 200,000-patient individual-level microsimulation with a frailty-distribution heterogeneity structure (new difficult-terminology box), a screening test with realistic sensitivity/specificity, and a two-layer PSA explicitly separating first-order from second-order Monte Carlo uncertainty — the most comprehensive and elaborate case study, appropriately so as the book's capstone treatment of microsimulation. Result: screening dominates no screening (negative incremental cost, positive incremental QALYs). New agency-note names NICE's real DSU TSD 12 (probabilistic sensitivity analysis).

**35.4 Case study D: budget impact model and Shiny application (long-acting injectable antipsychotic).** Complete 5-year BIA with population growth and uptake ramp. Honest, scoped discussion (no fabricated Shiny code) of how the exact BIA calculation becomes an interactive payer tool, correctly cross-referencing Chapter 29 §29.2/§29.4/§29.8. New agency-note names the real ISPOR Budget Impact Analysis Task Force report (Sullivan et al., *Value in Health*, 2014), already cited in Chapter 23 §23.1.

**35.5 Case study E: RWE comparative effectiveness study with propensity scoring (SGLT2i add-on in type 2 diabetes).** Full MatchIt/WeightIt/cobalt workflow on a new simulated 2,400-patient confounded registry. Naive, matched, and weighted estimates all independently verified exact, including the full before/after SMD balance table.

**35.6 Case study F: TB programme cost-effectiveness analysis for an LMIC setting (active case-finding).** New cascade-of-care cohort model, correctly synthesizing (by conceptual reference only, no code reuse) Chapter 22's dynamic transmission content, Chapter 31 §31.3-31.4's LMIC threshold-setting content, and Chapter 32 §32.7's TB cascade framework. Honestly avoids inventing a specific country's official threshold figure. Closes with the chapter's and the whole book's modest, non-grandiose final paragraph.

## Verification discipline
Every single numeric claim across all 6 case studies was independently re-executed from scratch (not just read for plausibility) and compared against the chapter's stated numbers:
- **Case Study A**: exact match on every number (costs, QALYs, ICER 28,829, PSA mean).
- **Case Study B**: exact match on base case and Scenario 1; **Scenario 2 found to be a non-functional code stub** — rewritten as a complete, real implementation and the chapter's stated numbers corrected.
- **Case Study C**: exact match on every number (mean cost/QALY, dominant-strategy ICER -1,297.69).
- **Case Study D**: exact match on every year's budget impact and the cumulative 5-year figure.
- **Case Study E**: exact match on n treated, naive diff, matched/weighted estimates and CIs, and the full SMD balance table (unadjusted/matched/weighted).
- **Case Study F**: exact match on cascade completions, costs, DALYs, and ICER.

Also fixed two structural Typst issues inherited from sub-agent drafts before compiling: (1) one sub-agent used `report-table(caption, body)[...]` bracket-chaining and `caption:` named-argument syntax inconsistent with the book's established `report-table(caption, academic-table(...))` positional convention, and nested-paren table-body rows instead of flat cells — both fixed across all 6 report/ref-tables; (2) one sub-agent fabricated non-existent `@sec-XX` Typst label references (the same mistake caught in Chapter 34) — all 11 replaced with the book's established plain-text "Chapter N §N.N" convention, each cross-reference verified against the real source file.

## Mandatory per-tick steps
- **Image tracker**: 1 new explicit skip (C32 — all 6 case studies already render their own report/ref-tables; the chapter's purpose is synthesizing already-diagrammed concepts from earlier chapters, not introducing new visual content).
- **Shiny candidates**: 2 new genuine candidates added — Budget Impact Uptake/Price Explorer (§35.4, directly realizing the case study's own described Shiny integration) and CEAC/WTP Threshold Explorer (§35.1/§35.2 combined, contrasting the two case studies' very different threshold sensitivity). Total now 64 across 32 chapters.
- **Code extraction**: 30 R code blocks extracted to `code/ch35_case_studies/` (the largest single-chapter code extraction in the book, reflecting its capstone scope).
- **renv.lock**: 6 packages identified and verified installed (flexsurv, survival, ggplot2, MatchIt, WeightIt, cobalt).
- **Difficult terminology**: 1 new box (frailty distribution, §35.3) — appropriately minimal since this is a synthesis chapter of already-taught methods.

## Compile result
Compiled cleanly after both revision passes, zero warnings. `book.pdf` grew from 617 to **647 pages**. New Part VIII divider ("Case Studies") correctly inserted before this chapter's include in `book.typ`.

## This is the final chapter of the book
All 35 chapters are now drafted, scored, and compiled. `book_progress.json`'s `next_chapter_number` advances past 35 — there is no Chapter 36. Any future cron ticks should recognize the book as complete rather than attempting to draft a nonexistent next chapter; this needs an explicit check added to the cron job or the skill before its next scheduled fire.
