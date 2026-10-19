# Chapter 1 — Introduction to HEOR and HTA

**Part:** I. Foundations
**Status:** complete (first chapter of the book)

## Sections covered (map to TOC 1:1)
1.1 What HEOR is and what it is not
1.2 The HTA ecosystem (NICE, CADTH, PBAC, IQWiG/G-BA, HAS, ICER, HTAIn, EU Joint Clinical Assessments)
1.3 Evidence needs across the product lifecycle
1.4 Typical deliverables
1.5 Why R: the case for open-source and reproducible HEOR
1.6 Where R fits in the HEOR workflow

## Key claims / definitions established
- HEOR defined operationally as producing the evidence base that answers:
  "is this intervention worth it, for whom, compared to what, and under
  what degree of uncertainty?" — distinguished from health economics
  proper, biostatistics/epidemiology, health services research, and
  market access (a close collaborator, not the same function).
- Agency roster with role descriptions: NICE (England/Wales, DSU TSDs),
  CADTH (Canada), PBAC (Australia), IQWiG/G-BA (Germany, AMNOG), HAS
  (France), ICER (US, non-government), HTAIn (India — Dept of Health
  Research, MoHFW; Indian reference case; feeds Ayushman Bharat PM-JAY
  decisions).
- EU Joint Clinical Assessment (EU HTA Regulation, in force Jan 2025 for
  oncology/ATMPs) noted as decoupling joint clinical assessment from
  still-national economic/pricing assessment.
- Five-stage product lifecycle for evidence needs: early pipeline →
  Phase III/pre-launch → launch/HTA submission → post-launch RWE →
  re-assessment/loss of exclusivity.
- Deliverables list: global value dossiers, economic models, budget
  impact models, SLRs/NMAs, RWE studies, payer submissions/technical
  engagement responses.
- Why-R argument built on five pillars: reproducibility (renv + Git),
  statistical depth (flexsurv, meta/metafor/netmeta, brms/Stan,
  MatchIt/WeightIt), cost (free vs TreeAge/SAS licensing), reviewer
  transparency, and Quarto/R Markdown reporting interoperability —
  balanced with an explicit acknowledgment that TreeAge, SAS and Python
  retain real advantages in specific contexts (not a one-sided pitch).
- Book structure walkthrough: the 8 parts mapped onto a generic HEOR
  workflow (Foundations → Data → Statistical methods → Decision-analytic
  modelling → Uncertainty/VOI/validation → Reporting/deployment → HTA in
  practice → Case studies), stated explicitly as cumulative (later parts
  assume earlier ones).

## Notation / terminology introduced (binding for later chapters)
- ICER = ΔC / ΔE (consistent with the front-matter Conventions chapter's
  notation: discount rate *r*, time horizon *T*, ΔC, ΔE).
- Three recurring callout types used exactly as defined in `common.typ`
  and the Conventions front-matter section: "HEOR in practice", "Common
  pitfall", "Agency perspective", plus a "Learning objectives" block at
  chapter open.
- HTAIn referred to by its full form once, then as "HTAIn" throughout —
  later India-specific chapters (31.3) should follow this short form.

## Code
None — intentionally narrative-only, as this is the introductory chapter
with no R illustrations expected per the TOC. Jev's code_validity question
scores 10 by default for code-free chapters; confirmed in this run (8.9/10,
near-ceiling given the explicit no-code framing in the state passed).

## Open items / things later chapters should not contradict
- Chapter 2 should NOT re-introduce ICER notation differently — follow
  ΔC/ΔE as set here and in the front matter.
- Dr Aswath's TB/Expand ELEVATE applied context was flagged against
  Chapters 22-23 (DES/dynamic models, budget impact) and 32.7 (TB
  programmatic models) — those chapters should actually deliver a
  TB-relevant worked angle given this chapter promised it.
- HTAIn's methodology was described as "still maturing relative to NICE
  or CADTH" — Chapter 31.3 (HTA in India) should expand this claim with
  specifics rather than just repeating the same vague characterization.
