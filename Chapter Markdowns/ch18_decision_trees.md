# Chapter 18 — Decision Trees

**Part:** IV. Decision-Analytic Modelling (second chapter)
**Status:** complete — ONE revision pass needed, on code_validity only
(5.57/10 → 7.32/10 after revision). All six dimensions now pass.

## Sections covered (map to TOC 1:1)
18.1 Structure and expected-value calculations
18.2 Building decision trees from scratch in R
18.3 Using `rdecision`
18.4 Short-term models for screening, diagnostics and acute care
18.5 Combining a decision tree with a long-term Markov model

## Bridge from Chapter 17
Opens by framing the tree as the simplest engine for the §17.2
"one-off/short-horizon" model type, explicitly using a *different*
TB example than Chapter 17's regimen-choice question (which resolved
to a Markov cohort model) — this chapter's running example is a
short-term TB *diagnostic-strategy* decision, kept consistent across
all five subsections, with §18.5 explicitly handing off to Chapter 19's
Markov model for the regimen-choice question.

## Key claims and notation established (binding for later chapters)
- **§18.1**: Decision node/chance node/terminal node vocabulary,
  branch-probability-sum-to-1 rule, and the EV roll-back ("folding
  back") algorithm — explicitly the same `EV = sum(p_i * payoff_i)`
  logic from Ch.4 §4.4, applied to cost and QALYs separately. Worked
  TB diagnostic-strategy example: smear-only (sensitivity 0.60,
  specificity 0.98) vs Xpert MTB/RIF (sensitivity 0.90, specificity
  0.96) at prevalence 0.30. Hand-computed, independently re-verified
  during drafting: Smear EV cost $60.40, EV QALY 0.93302; Xpert EV
  cost $63.80, EV QALY 0.95454; ICER = $3.40/0.02152 ≈ $158/QALY
  gained. Pitfall callout on prevalence's effect on test value.
- **§18.2**: Same tree represented as a `tibble::tribble()` with one
  row per terminal path (`p_disease`, `p_test` columns kept
  *unmultiplied*), `path_prob = p_disease * p_test` computed
  explicitly as the branch-probability product, then
  `group_by(strategy) |> summarise(sum(path_prob * cost), sum(path_prob
  * qaly))` reproducing §18.1's hand-calculated EVs exactly (verified
  identical: $60.40/0.93302 and $63.80/0.95454). A `report-table`
  summarising expected cost/QALY/ICER per strategy inserted here using
  `academic-table`.
- **§18.3**: `rdecision` (real CRAN package, Sims/Keltie/Cognigni,
  follows Briggs 2006 terminology) introduced via its R6 classes:
  `DecisionNode`, `ChanceNode`, `LeafNode` (incremental `utility` +
  `interval`), `Action` (edges from decision nodes), `Reaction` (edges
  from chance nodes, carrying `p=`), `DecisionTree$new(V=, E=)`,
  `evaluate(setvars=, by=)`. **Revision history**: the first draft
  hedged these signatures as unverified; Jev's first pass flagged
  code_validity at 5.57/10 (the only failing dimension). Independently
  looked up the live CRAN reference manual and vignettes
  (cran.r-project.org/web/packages/rdecision) and replaced the hedge
  with a fully worked, argument-exact R example: confirmed
  `Action$new(source_node, target_node, label, cost = 0, benefit =
  0)`, `Reaction$new(source_node, target_node, p = 0, cost = 0, benefit
  = 0, label = "")`, and the package's own `p = NA_real_` idiom (one
  reaction per chance node left as `NA_real_`, auto-filled as
  one-minus-the-others at evaluation time) — all confirmed real via
  web search against cran.r-project.org, not asserted from memory.
  Re-scored code_validity to 7.32/10.
- **§18.4**: Reuses Ch.17 §17.2's "one-off/short-horizon" model-type
  criterion by name. Two brief (non-worked) examples generalising
  beyond TB: antenatal Down-syndrome screening algorithms, ED
  troponin-triage pathways. Agency-note names NICE's Diagnostics
  Assessment Programme methods guide (companion to the NICE Guide to
  the methods of technology appraisal).
- **§18.5**: Decision-tree-to-Markov-model handoff pattern — a tree's
  terminal-leaf path probabilities become the Markov model's `t=0`
  cohort-occupancy vector. Concretely maps the TB tree's TP/FN/FP/TN
  outcomes onto Markov starting states (On Treatment / Undiagnosed
  Active TB / Well-No TB), explicitly forward-pointing to Chapter 19's
  TB regimen Markov model (On Treatment/Cured/Treatment
  Failure/Death, diagrammed in Ch.17 §17.3's `DiagrammeR::grViz()`
  example) and reusing Ch.17 §17.6's inputs→engine→results→reporting
  architecture by name. No Markov mechanics (transition matrix, cycle
  length, half-cycle correction) introduced here — explicitly
  deferred to Chapter 19.

## Package/function-name verification (continuing Ch.6-17's lesson)
`rdecision`'s `DecisionNode`, `ChanceNode`, `LeafNode`, `Action`,
`Reaction`, `DecisionTree`, `evaluate()` all confirmed real via the
live CRAN reference manual and the package's own vignettes
(DT00-DecisionTreeTutorial, DT01-Sumatriptan, DT02-Tegaderm,
DT03-ShaleGas). Exact constructor argument names/order/defaults
verified rather than hedged, after the first Jev pass caught the
earlier hedged-sketch version as insufficiently code-valid — a new,
stronger standing lesson: a hedge ("I'm not confident of the exact
signature") does NOT satisfy the code_validity rubric dimension the
way an independently-verified signature does. Do the lookup, don't
just disclose the uncertainty.

## Agency grounding (proactive, per the Ch.4/16/17 lesson)
One specific named document: NICE's Diagnostics Assessment Programme
methods guide (§18.4), companion to the already-established NICE
*Guide to the methods of technology appraisal* / PMG36 reference case.

## Image tracking (per skill's mandatory step 11b)
- **Track 1 (conceptual diagrams)**: no new candidate logged this
  chapter — the TB diagnostic tree's structure is already fully
  captured by the §18.1 prose description and §18.2-18.3's code; a
  Mermaid/DiagrammeR diagram was considered but judged redundant with
  the worked numeric example immediately above it.
- **Track 2 (R-generated charts)**: no new candidate logged — all R
  code in this chapter produces console/data-frame output (EV
  tables), not a statistical plot.

## "How to report this" table check (per the mandatory step 11c)
One `report-table` inserted in §18.2, immediately after the `dplyr`
rollback code: expected cost, expected QALYs, incremental cost, and
ICER per strategy for the TB diagnostic-strategy example — a genuine
computed result from this chapter's own worked example, correctly
using `report-table` (not `ref-table`) per the skill's distinction.

## Jev rubric scores (raw, 1-10 scale)
**First pass**: coverage 8.24, technical_correctness 7.15,
**code_validity 5.57 (FAILED)**, agency_grounding 7.0,
internal_consistency 8.15, readability 7.25 (prose-only method,
passed on first draft, not re-scored after revision since the revision
only touched §18.3's code, not chapter prose).
**After one revision pass (code_validity only)**: coverage 8.41,
technical_correctness 7.53, **code_validity 7.32 (PASSED)**,
agency_grounding 7.01, internal_consistency 8.22. All six dimensions
now pass; no second revision needed.

## Open items / things later chapters should not contradict
- Chapter 19 (Markov Cohort Models) must pick up the TB regimen-choice
  running example from Chapter 17 (NOT the diagnostic-strategy example
  used in this chapter) and should explicitly show how a decision
  tree's terminal-leaf occupancy vector (the §18.5 handoff pattern)
  would seed a Markov model's time-0 cohort, even though Chapter 19's
  own worked example may start from a simpler initial distribution
  (e.g. 100% "On Treatment" at diagnosis) if a full tree-to-Markov
  integration is out of scope for that chapter's own worked example.
- `rdecision`'s real, verified constructor signatures (Action, Reaction,
  LeafNode, DecisionTree, evaluate) are now book-wide references —
  Chapter 19/20 should verify `heemod`/`hesim` signatures with the same
  live-lookup discipline before using them, rather than hedging.
- NICE's Diagnostics Assessment Programme methods guide is now a
  newly-named book-wide agency reference, alongside the established
  NICE PMG36/reference case, CHEERS 2022, and the TSD 1/2/3/14/16/18/
  21/33 family.
- **New standing lesson** (added to this chapter, worth propagating):
  when a sub-agent or draft hedges an R package's function signature
  instead of asserting it, that hedge is not itself sufficient to pass
  the code_validity rubric dimension — always do the live documentation
  lookup (CRAN reference manual, vignettes, `rdrr.io`) before finalizing,
  even when the drafted hedge language sounds appropriately cautious.
  Caution without verification still scores as unverified code.
