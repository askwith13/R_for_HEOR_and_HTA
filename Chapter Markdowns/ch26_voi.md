# Chapter 26: Value of Information Analysis

**Part V: Uncertainty, Value of Information and Model Validation** (second chapter of Part V — no new Part divider needed, Part V already opened by Chapter 25).

## Status
Drafted manually on 2026-10-20, continuing Dr Aswath's direct-request acceleration. Five of six Jev dimensions passed; readability failed twice (5.93 → 5.75, worse on revision) and is flagged as a genuinely open issue per the skill's two-consecutive-low-scores stop-rule, the same way Chapter 13's unresolved readability issue was handled.

## Jev scores (raw, 1–10)
- Coverage: 8.31 (later re-confirmed 8.30 after revision)
- Technical correctness: 7.49 (7.37 after revision)
- Code validity: 7.79 (7.81 after revision)
- Agency grounding: **1.41 on first pass (FAILED)** → fixed → **7.74** (passed)
- Internal consistency: 8.47 (8.46 after revision)
- Readability (prose-only): **5.93 → 5.75 (still fails, flagged open)**

## What the chapter covers

**26.1 Concepts: EVPI, EVPPI, EVSI, ENBS.** Grounds VOI in Claxton's 1999 "Irrelevance of Inference" (*Journal of Health Economics* 18(3):341-364) and Felli & Hazen's 1998 EVPI paper (*Medical Decision Making* 18(1):95-109) — both citations confirmed real via live web search (exact title/journal/volume/pages matched) before use. Formal EVPI definition and base-R code computing it directly from Chapter 25's existing PSA draws, no new simulation needed. A worked 6-draw illustrative example — **a real arithmetic error in the sub-agent's draft was caught and corrected here**: the stated EVPI was $617, but independently recomputing from the sub-agent's own table data gave the correct value of $858.33, which was corrected throughout the chapter including the dependent multi-threshold table in §26.2.

**26.2 Computing EVPI and EVPPI.** Turns the §26.1 logic into a reusable `calculate_evpi()` function run across a WTP grid, explaining why EVPI peaks near the CEAC's 50% crossing. Honestly states that neither `voi` nor `BCEA` is installed on this drafting machine (confirmed via `requireNamespace()`), describing their general interface pattern without fabricating exact function signatures.

**26.3 Efficient EVPPI via GAM regression.** Cites Strong, Oakley and Brennan (2014, *Medical Decision Making* 34(3):311-326) for the regression-based EVPPI shortcut — confirmed real via live web search. Working `mgcv::gam()` code (confirmed installed) fitting incremental NMB against a parameter of interest, with a difficult-terminology box on GAMs and a pitfall box on smoothness bias (`k=` too small underestimates EVPPI, too large overestimates it).

**26.4 EVSI approximation methods.** Cites Strong, Oakley, Brennan and Breeze (2015, *MDM* 35(5):570-583) and Jalal and Alarid-Escudero (2018, *MDM* 38(2):174-188), both confirmed real. Full worked Beta(8,92)→Beta(24,276) moment-matching example for a hypothetical n=200 trial — independently re-verified in Python (66.45% variance reduction, close to the 66.67% effective-sample-size heuristic).

**26.5 Value of implementation.** Distinguishes EVI (adoption/diffusion-focused) from information-focused VOI measures. Worked 5-year linear uptake-ramp example reusing Chapter 23's uptake-curve framing and Chapter 25's $8,044.05 incremental NMB — independently re-verified in Python: total value of implementation = $209,145,300 (exact match to the sub-agent's approximation).

**26.6 Using VOI to prioritise research.** Illustrative EVPPI-ranking table across 4 TB model parameters; ENBS comparison of small (n=200) vs large (n=2000) trials — independently re-verified: small trial ENBS = $29,950,000, large trial ENBS = -$2,150,000, a genuinely non-obvious finding that a larger, costlier trial can have lower (even negative) expected net benefit. Closes with a bridge to Chapter 27 (Model Calibration, Validation and Quality Assurance).

## A real agency_grounding failure and fix
First Jev pass scored agency_grounding at 1.41/10 — a hard fail. Root cause: two agency-notes were written with hedged, vague language ("verify the exact TSD number...", "exact document titles worth verifying...") that scored as unverified-sounding rather than as genuine named references. Fixed by replacing both with specific, web-search-confirmed real documents:
- NICE DSU's "A Pilot Study of Value of Information Analysis to Support Research Recommendations for NICE" (June 2005) — and explicitly confirmed, by checking the DSU's full numbered TSD 1-27 list, that VOI has no dedicated Technical Support Document, so this pilot report is correctly identified as the primary NICE-commissioned VOI reference rather than a guessed TSD number.
- The UK NIHR HTA Programme's own call documentation, which explicitly requires some commissioned studies to include "a health economic analysis including a value of information analysis to inform future primary research."

Re-score: agency_grounding jumped to 7.74.

## Readability: a genuinely open issue
Readability (prose-only) scored 5.93 on the first pass — below the 6/10 threshold. One revision pass broke up two dense, citation-stacked sentences into shorter ones. Re-score came back **worse** at 5.75. Per the skill's stop-rule (two consecutive low scores on the same dimension → stop and flag, don't loop indefinitely), no further revision was attempted. The likely driver is the chapter's genuinely dense subject matter (EVPI/EVPPI/EVSI formal definitions, moment-matching Beta-Binomial arithmetic, GAM regression mechanics) — the same pattern already seen and accepted as a real, unresolved issue in Chapter 13. **Flagged to Dr Aswath as open**, not silently passed.

## Verification discipline
Every numeric claim across all 6 subsections was independently re-computed in Python before being accepted, including one genuine arithmetic error caught and corrected (the EVPI worked example). All citations (5 total: Claxton 1999, Felli & Hazen 1998, Strong/Oakley/Brennan 2014, Strong/Oakley/Brennan/Breeze 2015, Jalal & Alarid-Escudero 2018, plus the two agency-note documents) were confirmed real via live web search with exact title/journal/volume/page matches before use.

## Compile result
Compiled cleanly on every pass, zero warnings. `book.pdf` grew from 446 to **467 pages**. Visually verified 3 pages (chapter opening, a mid-chapter code page, an agency-note page) via `pdftoppm` + `vision_analyze` — all clean.

## Continuity notes for Chapter 27
Chapter 27 (Model Calibration, Validation and Quality Assurance) is the final chapter of Part V — no new Part divider needed. It should pick up directly on §26.6's closing observation: VOI analysis presumes the underlying model is trustworthy; Chapter 27 covers how to verify that trust is actually warranted.
