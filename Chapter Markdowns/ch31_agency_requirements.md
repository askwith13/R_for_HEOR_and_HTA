# Chapter 31: Agency Requirements and Reference Cases

**Part VII: HTA in Practice** (FIRST chapter of this Part — a new real Part VII divider was inserted in `book.typ` immediately before this chapter's `#include`, following the Part I-VI precedent).

## Status
Drafted via interactive session (2026-10-20), delegating 31.1-31.3 and 31.4-31.6 to two parallel sub-agents, assembled into one Typst file. ONE revision pass was needed (code_validity scored 5.5 on first draft, 6.15 after fix) — all six Jev rubric dimensions now pass.

## Jev scores (raw, 1-10, after revision)
- Coverage: 8.25
- Technical correctness: 7.45
- Code validity: 6.15 (was 5.5 pre-revision)
- Agency grounding: 8.28
- Internal consistency: 8.58
- Readability (prose-only): 6.73

All six clear the 6/10 threshold.

## What the chapter covers

**31.1 NICE: reference case, DSU technical support documents, and submission templates.** NICE's reference case (NHS/PSS perspective, QALYs via EQ-5D, 3.5% discount rate, GBP20,000-30,000/QALY implicit threshold range); DSU TSD series described generically plus TSD 12 = PSA (consistent with Chapter 29's established citation, not newly invented); recap of the Technology Appraisal process (company submission → ERG critique → technical engagement → committee meeting); an agency-note on NICE's requirement for a fully executable model submitted alongside the written submission.

**31.2 CADTH, PBAC, ICER, G-BA/IQWiG and HAS.** A practical tour: CADTH's reanalysis culture, PBAC's Guidelines (Version 5.0, 2016 — consistent with Chapter 29's citation) and strong uncertainty tradition, IQWiG/G-BA's AMNOG early benefit assessment (patient-relevant outcomes, not a cost-per-QALY exercise), ICER's non-statutory US value framework, HAS's ASMR rating. A pitfall box on not assuming a single global reference case.

**31.3 HTA in India: HTAIn, the Indian reference case, and Ayushman Bharat PM-JAY.** HTAIn's Reference Case for Economic Evaluation (named consistently with Chapter 1), explicitly flagged as still maturing (matching Chapter 1's own characterization verbatim, not overstated). PM-JAY explained as the policy vehicle HTAIn assessments feed into. An honest, grounded discussion of India-specific data sparsity across public/private/PM-JAY tariffs, with a worked R code example parameterising unit cost by data-source scenario.

**31.4 HTA in LMICs: iDSI reference case, thresholds and capacity.** The iDSI reference case (a real initiative, York CHE/Imperial affiliation); an honest critique of the WHO's now-deprecated 1-3x GDP-per-capita WTP heuristic, contrasted with the more current opportunity-cost-based threshold direction (hedged appropriately); R's zero-licensing-cost advantage for LMIC capacity-building tied back to Chapter 30's open-source discussion. A pitfall box on not citing the deprecated GDP-multiple threshold as current practice.

**31.5 Comparing evidence requirements across agencies.** A 6-column `ref-table` comparing NICE/CADTH/PBAC/IQWiG-G-BA/HAS/ICER/HTAIn on perspective, discount rate, WTP threshold, comparator requirement, and uncertainty analysis — built from facts already established elsewhere in the book, with honest qualitative hedges ("not fixed," "varies by guidance") rather than invented precise numbers for agencies without confidently known figures. A heor-practice box on parameterising perspective/discount/comparator as function arguments rather than hardcoding.

**31.6 Responding to technical engagement and evidence review group critiques with R.** The ERG technical-engagement critique response workflow, illustrated with a worked R example re-running the TB Markov model at an alternative discount rate (6% vs. the original 3.5%) — explicitly NOT inventing new numeric results at the untested rate, reusing only the book's verified base-case numbers (-$844.14, 0.1440) for the original rate. A heor-practice box tying together Chapters 25-30's parameterisation/testing/reproducibility investment. Closes with a transition to Chapter 32 (Special Topics).

## Verification discipline
Independently confirmed two cross-chapter consistency claims before accepting the draft: (1) TSD 12 = PSA is cited consistently with Chapter 29's own citation (not a newly fabricated TSD-number-to-topic mapping); (2) PBAC Guidelines Version 5.0 (2016) matches the exact citation already used in Chapter 29. Caught and fixed ONE real rendering bug: the Section 31.5 comparison table was originally drafted with verbose cell text that made it too tall for one page, causing a genuine visual defect — the table overflowed and visually overlapped its own caption text on the compiled page. Fixed by compressing every cell to terse phrasing while preserving all factual content, re-verified clean on a single page post-fix. Also fixed the code_validity revision trigger: both of the chapter's two R code blocks were annotated to explicitly state they call already-established functions from Chapters 17-27/30 (`run_cea_model()`, `run_tb_model()`) rather than appearing to invent undefined functions with no context.

## Mandatory per-tick steps
- **Image tracker**: 1 new Track-1 entry logged and explicitly deferred as low priority (C27 — a NICE TA process flowchart was considered but the process has already been explained in prose across Chapters 27-30 multiple times; a diagram here would be a 4th/5th repetition, so deferred rather than built this tick).
- **Shiny candidates**: 1 new genuine candidate added (Cross-Agency Decision Explorer, §31.5 — letting a user vary an ICER and see live whether it clears each agency's stated/inferred WTP threshold, making the comparison table's practical consequence directly interactive). Total now 57 across 28 chapters.
- **Code extraction**: 2 R code blocks extracted to `code/ch31_agency_requirements/` (this is a policy-heavy chapter with intentionally less code than typical technical chapters).
- **renv.lock**: 1 package identified (`quarto`, genuinely NOT installed on this machine — confirmed via `requireNamespace()` — correctly flagged as an unverified marker, not fabricated).
- **Difficult terminology**: 4 boxes inserted (reference case [appears twice, once generally in §31.1 and once LMIC-specific in §31.4], Ayushman Bharat PM-JAY, Evidence Review Group (ERG)).

## Compile result
Compiled cleanly on the first pass (and again after both the table-overflow fix and the code_validity revision), zero warnings. `book.pdf` grew from 556 to **568 pages**. New Part VII divider inserted before this chapter's include.

## Continuity notes for Chapter 32
Chapter 32 (Special Topics) is the second chapter of Part VII: HTA in Practice — no new Part divider needed. It should pick up directly on §31.6's closing transition: having covered how agencies generally evaluate submissions, the book now turns to therapy-area-specific modelling considerations (oncology, rare diseases, vaccines, diagnostics, digital health, gene therapies, infectious disease/TB) — the TB case study used throughout Part IV-VI should connect naturally to §32.7's infectious disease/TB programmatic modelling content.
