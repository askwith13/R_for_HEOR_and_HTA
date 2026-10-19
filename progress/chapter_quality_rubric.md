# Chapter Quality Rubric — R for HEOR and HTA

Used at the end of every chapter draft, before marking it complete in
`progress/book_progress.json`. Claude self-critiques against this rubric
first; then the same six dimensions are sent to Jev (TypeSafe AI) as
`score` questions (0-10 scale), split across TWO different inputs
(changed Oct 18, 2026 — see "Jev question framing" below for why):
dimensions 1-5 use a text `state` summarizing the drafted chapter
content (section list + key claims + code presence); dimension 6
(readability) uses the chapter's ACTUAL PROSE TEXT extracted from the
`.typ` file, with code/figures/tables stripped out. Jev's raw scores
are logged untouched in `progress/jev_scores.csv`; Claude decides
whether to revise based on them.

## Revision threshold
Any dimension scoring below 6/10 (self or Jev) triggers one revision pass
on that dimension specifically before the chapter is marked "complete".
Two consecutive low scores on the same dimension across revisions means
stop and flag to Dr Aswath rather than looping indefinitely.

## The six dimensions

1. **Coverage of stated learning objectives (0-10)**
   Does the chapter actually address every subsection listed in the
   Table of Contents for this chapter, not a subset? Learning objectives
   stated at the chapter's start must map 1:1 to content actually present.

2. **Technical/statistical correctness (0-10)**
   Are the HEOR/biostatistics concepts (e.g. ICER formulas, discounting
   mechanics, survival model assumptions, Bayesian priors) stated
   correctly per standard references (ISPOR-SMDM guidance, NICE DSU TSDs,
   Briggs/Claxton/Sculpher "Decision Modelling for Health Economic
   Evaluation", Drummond et al. "Methods for the Economic Evaluation of
   Health Care Programmes")? Flag anything that looks fabricated or
   oversimplified to the point of being wrong.

3. **R code validity and relevance (0-10)**
   Is the R code syntactically plausible for the stated package
   (e.g. does it match `heemod`/`flexsurv`/`hesim`/`BCEA` real function
   signatures, not invented ones)? Does each code example directly
   illustrate the surrounding prose rather than being decorative filler?
   Code need not be executed/tested in early drafts, but must not
   reference non-existent functions or arguments from memory errors.

4. **HTA/agency-practice grounding (0-10)**
   Does the chapter correctly reference real agency practice where
   relevant (NICE reference case, CHEERS 2022, ISPOR-SMDM, HTAIn for
   India) rather than vague unsourced claims about "what agencies want"?

5. **Internal consistency with the rest of the book (0-10)**
   Does terminology match earlier chapters (e.g. consistent notation for
   discount rate, consistent NMB vs NHB usage)? Does it avoid
   contradicting content already written in earlier chapter markdown
   summaries? (Check against `Chapter Markdowns/` folder before drafting.)

6. **Readability and structure for the stated audience (0-10)**
   Dr Aswath is a working TB-programme data analyst with rusty-but-real
   SQL, strong R from applied public-health work, and basic HEOR
   exposure growing via this book itself and the companion R-HTA online
   text. Chapters should NOT assume postgraduate health-economics
   training already in place for concepts covered in Part I-II, but
   CAN build cumulative assumption of concepts from earlier chapters in
   this same book once introduced. Flag chapters that are either
   condescending (re-explaining already-covered basics) or that silently
   assume ungrounded prior knowledge.

## Jev question framing (two scripts, two inputs — changed Oct 18, 2026)
Dimensions 1-5 (coverage, technical_correctness, code_validity,
agency_grounding, internal_consistency) are scored by
`jev_score_chapter.py` as `score` questions (1-10 integer scale —
Jev's API rejects an 11-level 0-10 scale) against a structured `state`
JSON: chapter number/title, full subsection list from the TOC, a bullet
list of the key claims and code snippets actually drafted, and the
three or four prior chapters' one-paragraph summaries (for the
consistency dimension). Never pass full chapter prose for THESE five
dimensions — a structured summary is the right, intended input.

Dimension 6 (readability) is scored SEPARATELY by
`jev_score_readability_prose.py` against the chapter's actual prose
text, extracted straight from the `.typ` file with R code blocks,
`#figure()` image blocks, and `report-table()`/`ref-table()` table
blocks stripped out (Jev is text-only and code/tables aren't prose).
Confirmed by direct A/B test (Oct 18, 2026) that scoring readability
off the bundle `state` used for dimensions 1-5 systematically
underscores methodologically dense chapters, because a dense chapter
produces a denser bullet-point summary — which is itself harder to
read — regardless of whether the real sentences are fine: Chapter 10
scored 5.86 on the bundle vs 7.03 on real prose (passes); Chapter 15
scored 3.35 on the bundle vs 7.21 on real prose (passes). Chapter 13
barely moved (5.17 -> 5.32, still fails) — proof this is a genuine
scoring-methodology fix, not a blanket inflator; a chapter that is
truly hard to read still fails under the corrected method.

Both scripts log their raw scores to the same
`progress/jev_scores.csv`, each writing only the columns they're
responsible for (readability rows from the prose script leave the
other five columns blank, tagged `method=prose_only` in a `method`
column). Run both every chapter going forward; combine their results
when applying the >=6/10 revision-threshold rule.
