# Chapter 17 — Principles of Decision Modelling

**Part:** IV. Decision-Analytic Modelling (first chapter of this Part)
**Status:** complete — ALL SIX Jev rubric dimensions passed on the FIRST
draft, no revision pass needed. This is the second chapter since Chapter 9
to clear readability on the first draft (after Chapter 16), continuing the
density-first drafting pattern that broke the Chapter 10/13/14/15
readability-failure streak.

## Sections covered (map to TOC 1:1)
17.1 Model conceptualisation and problem scoping
17.2 Choosing a model type
17.3 Structural assumptions and model diagrams (`DiagrammeR`)
17.4 Parameter taxonomy and distributions
17.5 Model documentation and transparency
17.6 Modelling workflow in R: inputs → engine → outputs → reporting
17.7 Good practice guidelines (ISPOR-SMDM, NICE reference case)

## Bridge from Chapter 16 / Part III → Part IV transition
Opens by framing the shift explicitly: Part III's estimation toolkit
(effects, confounding adjustment, pooling, heterogeneity) is complete;
Part IV asks "given that evidence, what should a health system *do*?"
This chapter is a map, not a computation — it covers the decisions a
modeller makes BEFORE writing simulation code, deferring all actual
model-engine mechanics to Chapters 18-22.

## Key claims and notation established (binding for later chapters)
- **§17.1**: Reuses Chapter 4 §4.6's population/comparators/perspective/
  time-horizon vocabulary verbatim — explicitly not re-derived. Introduces
  PICOTS (Population, Intervention, Comparator, Outcomes, Timing, Setting)
  as a finer-grained checklist layered on top of those same four terms.
  Running example for the whole chapter established: a TB programme
  decision between a 4-month rifapentine-moxifloxacin regimen (per Study
  31/A5349) and the 6-month standard daily regimen (2HRZE/4HR). Introduces
  the "model concept document" as a pre-coding sign-off artifact.
- **§17.2**: Five-question decision framework for choosing a model type
  (one-off/short-horizon → decision tree ch.18; discrete recurring states
  → Markov cohort ch.19; survival-curve-driven without intermediate states
  → partitioned survival ch.20; patient-history-dependent → individual-level
  microsimulation ch.21; resource/queue-constrained → DES ch.22). Cites
  Siebert et al. (2012), ISPOR-SMDM Modeling Good Research Practices Task
  Force–3 ("State-Transition Modeling"), by name — real, verified citation.
  Applies the framework to the TB running example: Markov cohort model is
  selected, which Chapter 19 will build for this same example — a forward
  commitment Chapter 19 must honour.
- **§17.3**: Three structural-assumption questions established (backward
  movement between states, tunnel states, end-of-horizon handling) as a
  standing checklist any later state-transition chapter (18-22) can reuse
  by reference. **Real, executable R code** using `DiagrammeR::grViz()`
  with valid DOT/Graphviz syntax, drawing the TB Markov structure (On
  Treatment / Cured / Treatment Failure / Death, with a `Fail -> OnTx`
  back-edge and `Death` reachable from every state) — `DiagrammeR::grViz()`
  confirmed as the real exported function. Agency-note deliberately avoids
  naming an unverified specific NICE DSU TSD number for model-diagram
  requirements — cites "NICE's reference case... and NICE's Decision
  Support Unit technical support document series" generically instead,
  continuing the book's tooling/citation-honesty pattern but applied to
  citation precision rather than package-function identity this time.
- **§17.4**: Parameter taxonomy (transition probabilities, costs,
  utilities, relative treatment effects) with costs/utilities/effects
  explicitly cross-referenced to Chapters 8, 9, 11-12 rather than
  re-derived. Distribution conventions established for PSA (deferred to
  Ch.25): Beta/Dirichlet for probabilities, Gamma/lognormal for costs,
  Beta/Dirichlet for utilities, normal-on-log-scale for relative effects.
  **Worked method-of-moments Beta-fit arithmetic independently verified**:
  mean=0.85, 95% CI (0.80, 0.90) → SE=0.02551, variance=0.0006508 →
  alpha≈165.68, beta≈29.24; round-trip check confirms the fitted Beta
  reproduces mean=0.85 and SE=0.0255 exactly — computed via Python during
  drafting per the Ch.4 standing arithmetic-verification lesson, not just
  asserted as plausible.
- **§17.5**: Cites Eddy et al. (2012), ISPOR-SMDM Task Force paper on
  "Model Transparency and Validation" (part of the same 2012 seven-paper
  series as Siebert et al. in §17.2) — real, verified citation. Introduces
  the 5-part Technical Model Documentation (TMD) report structure (Inputs,
  Structure, Assumptions, Validation, Outputs) as a conventional HTA
  artifact distinct from the executable model itself. Cross-references
  Chapter 2's `renv` reproducibility machinery; forward-points to Chapter
  25 (PSA execution) and Chapter 28 (Reproducible Reporting) rather than
  duplicating either.
- **§17.6**: Establishes the book's inputs→engine→results→reporting
  architecture pattern for ALL decision models in Part IV — binding for
  Chapters 18-22. Real worked R skeleton: `run_model <- function(params)`
  returning a tibble of per-strategy `total_cost`/`total_qaly`, kept
  deliberately generic since real engine mechanics are Chapters 18-22's
  content. ICER/NMB computed in the results layer by explicit citation to
  Chapter 4 §4.4's formulas, not re-derived. Names `heemod` (Markov,
  Ch.19) and `hesim` (broader model types incl. partitioned survival,
  Ch.19-20) as real CRAN packages implementing this architecture — named
  without inventing their function signatures, since real usage is
  deferred to those chapters (continuing the Ch.13/15/16 tooling-honesty
  pattern of not fabricating usage ahead of verification).
- **§17.7**: Names the full ISPOR-SMDM Modeling Good Research Practices
  7-paper series (*Value in Health*, 2012) with Caro et al. (2012) as the
  umbrella/overview paper, explicitly tying together Siebert et al. (§17.2)
  and Eddy et al. (§17.5) as part of the same series rather than treating
  them as separate frameworks. States the NICE reference case's core
  requirements (NHS/PSS perspective, QALYs, discount rate, lifetime
  horizon) cross-referenced to Chapter 4. Closes with a direct transition
  to Chapter 18 (Decision Trees).

## Package/function-name verification (continuing Ch.6-16's lesson)
`DiagrammeR::grViz()` confirmed real, with syntactically valid DOT/
Graphviz used inside it (node/edge declarations, `rankdir = LR`,
`fillcolor`, edge `label` attributes — all real Graphviz DOT syntax).
`heemod` and `hesim` named as real, actively-used CRAN packages for
decision-analytic modelling in R, but no function from either is called
in this chapter — deliberately deferred to Chapters 19-20 where their
real signatures will be introduced and verified at that point, not here.

## Agency grounding (proactive, per the Ch.4/16 lesson)
Three specific named documents/series used: Siebert et al. (2012) ISPOR-
SMDM Task Force-3 (state-transition model selection, §17.2); Eddy et al.
(2012) ISPOR-SMDM Task Force paper on model transparency/validation
(§17.5); Caro et al. (2012) ISPOR-SMDM Task Force overview paper plus the
NICE reference case's specific methodological requirements (§17.7). The
§17.3 agency-note deliberately uses generic-but-accurate language ("NICE's
Decision Support Unit technical support document series") rather than
naming an unverified specific TSD number, since no single TSD in the book's
established TSD 1/2/3/14/16/18/21/33 family is specifically about model
diagrams — this is a precision choice, not a lapse into the earlier
generic-agency-claim pattern that failed Ch.2/3/9's first drafts (those
failures were about vague claims with NO document at all, not about
choosing accurate generality over an unverified specific number).

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: logged C14 — the §17.3 `DiagrammeR::
  grViz()` TB Markov structure diagram — as **Done**, since it is already
  live, executable R code embedded directly in the chapter (not a
  placeholder), and the whole point of §17.3 is teaching that exact
  function. No separate Mermaid diagram needed.
- **Track 2 (R-generated charts)**: no new candidate logged. This chapter
  is architecture/process-focused (scoping, model-type choice, structure,
  parameter taxonomy, documentation, workflow, guidelines) with no
  simulation output of its own yet — the engine mechanics that would
  produce a genuine statistical plot start in Chapter 18.

## "How to report this" table check (per the mandatory step 11c)
No `report-table`/`ref-table` inserted this chapter. The one real table
(§17.1's PICOTS table) is a plain `table()` — a simple 2-column
glossary-style organisational table, not a genuine academic reference/
comparison table substantial enough to warrant `ref-table`'s captioned
back-matter tracking, and certainly not a computed analytic result
(`report-table`'s exclusive remit). This chapter legitimately has zero
tables of either tracked kind, stated explicitly rather than as an
oversight.

## Jev rubric scores (raw, 1-10 scale)
First pass, ALL SIX dimensions passed — no revision needed: coverage
8.82, technical_correctness 7.97, code_validity 7.94, agency_grounding
8.01, internal_consistency 8.2, **readability 7.05** (prose-only method,
clears the 6/10 threshold comfortably — the second chapter since Chapter
9 to pass readability on the first draft, after Chapter 16, continuing
to support the density-not-sentence-length hypothesis recorded in
Chapters 10/13/14/15's markdowns).

## Open items / things later chapters should not contradict
- Chapter 18 (Decision Trees) should pick up directly from this chapter's
  closing transition: branches, probabilities, expected-value
  calculations, and the first fully-mechanical `run_model()` engine
  (filling in the generic skeleton established in §17.6).
- Chapter 19 (Markov Cohort Models) must honour the forward commitment
  made in §17.2: the TB regimen running example was explicitly resolved
  there to a Markov cohort model, and should use the same TB
  treatment-pathway structure (On Treatment / Cured / Treatment Failure /
  Death) diagrammed in §17.3's `grViz()` example, rather than introducing
  an unrelated example. Chapter 19 should also be where `heemod`'s real
  function signatures are introduced and verified.
- Chapters 19-20 should introduce `hesim`'s real function signatures when
  covering Markov and partitioned survival models respectively — named
  here in §17.6 but deliberately not used with any specific function call.
- The inputs→engine→results→reporting architecture from §17.6 is now the
  book's standing decision-model project structure for Chapters 18-22;
  later chapters should fill in the `run_model()` engine's internals
  rather than introducing a different project layout.
- Siebert et al. (2012), Eddy et al. (2012), and Caro et al. (2012) are
  now newly-named book-wide ISPOR-SMDM references, alongside the already-
  established NICE DSU TSD 1/2/3/14/16/18/21/33 family and CHEERS 2022.
