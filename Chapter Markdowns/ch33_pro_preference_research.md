# Chapter 33: Patient-Reported Outcomes and Preference Research

**Part VII: HTA in Practice** (third and final chapter of this Part — no new Part divider needed, Part VII was opened by Chapter 31).

## Status
Drafted via interactive session (2026-10-21), delegating 33.1-33.2 and 33.3-33.4 to two parallel sub-agents, assembled into one Typst file. ONE revision pass was needed (agency_grounding scored 5.88 on first draft, below threshold) — all six Jev rubric dimensions now pass.

## Jev scores (raw, 1-10, after revision)
- Coverage: 8.41
- Technical correctness: 7.75
- Code validity: 7.92
- Agency grounding: 8.07 (was 5.88, pre-revision)
- Internal consistency: 8.19
- Readability (prose-only): 6.10

All six clear the 6/10 threshold after one revision pass.

## What the chapter covers

**33.1 PRO analysis and psychometrics in R (lavaan, mirt).** Patient-reported outcome (PRO) measures tied directly back to Chapter 8's utility-value content (QALYs ultimately trace to a patient filling in a questionnaire). Classical test theory (CTT) and Cronbach's alpha explained, with their structural limitations (instrument-level not item-level, assumes everyone took an identical test). Confirmatory factor analysis (CFA) via `lavaan::cfa()` explained with the real `=~` formula syntax; a worked 2-factor, 6-item simulated example — independently executed, produces standardized loadings (0.67–0.83) all comfortably above the stated threshold and clean fit indices (RMSEA 0.000, SRMR 0.030). Item response theory (IRT) via `mirt::mirt()` explained with the real `itemtype = "2PL"` argument; a worked 5-item binary IRT example — independently executed, produces valid discrimination/difficulty coefficients. A pitfall box on ad hoc instruments not substituting for genuine multi-study validation; a heor-practice box on CTT/CFA/IRT being complementary, not competing. New agency-note citing the real, specific FDA 2009 PRO Guidance (Docket FDA-2006-D-0362).

**33.2 Minimal clinically important differences.** MCID/MID distinguished from statistical significance with a bathroom-scale analogy (a precise scale can "significantly" detect a 50g change nobody would notice). Anchor-based methods (patient global rating of change) and distribution-based methods (0.5× baseline SD, correctly attributed to Norman/Sloan/Wyrwich) explained honestly — anchor-based preferred, distribution-based a weaker statistical proxy. MCID's role in translating PRO change to utility change and in defining "responder" model structures explained. Agency-note on methods guidance expecting justified thresholds. R example computes a distribution-based MCID and runs a responder analysis — independently executed and the `report-table`'s values corrected to match the real computed output exactly (baseline SD 11.32, MCID 5.66, mean change 6.42, responder rate 52.0%; the sub-agent's original draft had used approximate placeholder numbers, replaced after independent verification).

**33.3 Discrete choice experiments (mlogit, apollo, logitr).** DCEs explained as a stated-preference method grounded in random utility theory — correctly cross-referenced to Chapter 8 §8.6 (which already introduced random utility theory/McFadden in the context of DCE-based utility elicitation) rather than re-explained from scratch, fixing a genuine duplicate-terminology-box issue caught during the per-tick terminology check. Conditional/multinomial logit as the workhorse model; mixed logit explained as relaxing the identical-preferences assumption. Three real R packages (mlogit, apollo, logitr) described with honest, non-fabricated relative positioning. A long-format DCE dataset structure illustrated, explicitly flagged as not a fitted-model example since real coefficients require real survey data.

**33.4 Best-worst scaling and conjoint analysis.** BWS explained via a concrete rating-vs-BWS contrast; the three real BWS cases (object scaling, profile case, multi-profile case) described accurately per genuine BWS methodology literature structure. Conjoint analysis explained as the umbrella term, with DCE-as-choice-based-conjoint vs. older ratings-based-conjoint honestly distinguished. Patient preference evidence's real, active role in HTA/regulatory decision-making strengthened during revision with two specific named documents: the FDA's "Incorporating Voluntary Patient Preference Information over the Total Product Life Cycle" guidance (2026 update, under FDASIA Section 1137) and ISPOR's Good Research Practices for Conjoint Analysis Task Force 10-item checklist (Bridges et al., Value in Health 2011;14(4):403-413) — both independently confirmed via web search, replacing the original hedged, unnamed "both FDA and NICE have shown interest" sentence. A pitfall box on stated vs. revealed preferences. Closes with a transition to Chapter 34 (Emerging Methods and the Future of HEOR in R).

## Verification discipline
Independently installed `lavaan` and `mirt` (not previously installed on this machine) and executed both CFA and IRT code examples before finalizing, rather than only checking plausibility — both produced sensible, real output matching the surrounding prose's claims exactly. Independently executed the MCID R example and discovered the sub-agent's draft `report-table` used approximate placeholder values (12.1, 6.0, 6.2, 52%) rather than the actual computed output (11.32, 5.66, 6.42, 52.0%) — corrected to the real numbers before finalizing. Independently cross-checked for duplicate difficult-terminology boxes against all prior chapters and found one genuine duplicate: "random utility theory" already had a full box in Chapter 8 §8.6 — fixed by replacing Chapter 33's duplicate box with a short cross-reference sentence per the skill's recurring-terms guidance, rather than leaving two competing full explanations of the same term in the book. Independently web-searched and confirmed three real, specific, currently-citable regulatory/methods documents (FDA 2009 PRO Guidance, FDA 2026 PPI guidance, ISPOR 2011 conjoint-analysis task force report) to replace vaguer hedged claims, fixing the agency_grounding score from 5.88 to 8.07.

## Mandatory per-tick steps
- **Image tracker**: 1 new explicit skip (C30 — 33.1-33.4 content is statistical/methodological rather than structural/process/relational, already made concrete via 4 worked R code examples and one report-table; a BWS "three cases" diagram was considered but the existing bulleted comparison already communicates it clearly at this scale).
- **Shiny candidates**: 2 new genuine candidates added — IRT Item Characteristic Curve Explorer (§33.1, sliders for discrimination/difficulty with a live curve) and MCID Threshold / Responder-Rate Explorer (§33.2, slider for the MCID fraction with a live responder-rate histogram). Total now 61 across 30 chapters.
- **Code extraction**: 4 R code blocks extracted to `code/ch33_pro_preference_research/`.
- **renv.lock**: 2 packages identified (lavaan, mirt — both newly installed and verified this session, zero unverified markers, fully honest manifest).
- **Difficult terminology**: 9 boxes inserted (Cronbach's alpha, confirmatory factor analysis (CFA), Item Response Theory (IRT), Minimal Clinically Important Difference (MCID), anchor-based method, distribution-based method, mixed logit model, best-worst scaling) — one originally-drafted 10th box ("random utility theory") was found to duplicate an existing Chapter 8 box and was replaced with a cross-reference sentence instead.

## Compile result
Compiled cleanly on the first pass (and again after both the agency-grounding revision and the duplicate-terminology fix), zero warnings. `book.pdf` grew from 590 to **603 pages**. No new Part divider needed (third and final chapter of Part VII, opened by Chapter 31).

## Continuity notes for Chapter 34
Chapter 34 (Emerging Methods and the Future of HEOR in R) is the next chapter, continuing Part VII: HTA in Practice (confirmed against the TOC — Part VIII: Case Studies does not start until Chapter 35, so no new Part divider needed for Chapter 34 either). It should pick up directly on §33.4's closing transition: machine learning, large language models, digital twins, and the future of HEOR in R. No outstanding open items carried forward from Chapter 33.
