# Chapter 7 — Missing Data

**Part:** II. Data for HEOR
**Status:** complete (passed all six Jev dimensions on the FIRST draft, no revision pass needed)

## Sections covered (map to TOC 1:1)
7.1 Mechanisms: MCAR, MAR, MNAR
7.2 Exploring missingness (`naniar`, `visdat`, Shiny-based explorers)
7.3 Complete-case versus imputation
7.4 Multiple imputation (`mice`, `Amelia`, `missForest`)
7.5 Sensitivity analysis, including tipping-point and pattern-mixture approaches
7.6 Missing data in cost and QALY data
7.7 Reporting missing data handling for HTA

## Bridge from Chapter 6
Opens by linking Ch.6's reproducible-evidence-pool theme to this chapter's
subject: not every cell in the primary trial/registry/claims dataset
itself is filled in, and mishandling the gaps can change a
cost-effectiveness conclusion as much as any later modelling choice.

## Key claims and notation established (binding for later chapters)
- **§7.1 mechanisms**: Rubin's 1976 MCAR/MAR/MNAR framework, explicitly
  flagged as UNVERIFIABLE from observed data alone — the same missing
  pattern is consistent with all three mechanisms. One EQ-5D
  non-response example carried through all three. Complete-case
  unbiased only under MCAR; MI (mice/missForest) justified under MAR;
  MNAR needs selection models, pattern-mixture models, or sensitivity
  analysis.
- **§7.2 exploring missingness**: real `naniar` functions `vis_miss()`
  (clustered heatmap), `gg_miss_var()` (ranked bar, with `facet =`
  argument for by-arm splits), `gg_miss_upset()` (co-missingness
  combinations), `mcar_test()` (Little's MCAR test — rules OUT MCAR on
  a significant result, does NOT confirm MCAR on a non-significant
  one, and is structurally blind to MNAR). `visdat::vis_dat()` /
  `vis_miss()` for whole-frame type+missingness overview. Shiny framed
  as a thin interactive wrapper over the same functions, not a new
  method.
- **§7.3 complete-case vs. imputation**: listwise deletion defensible
  only under true MCAR with small proportion missing; mean/median
  imputation and LOCF both understate uncertainty because standard
  errors are computed as if fabricated values were observed. Worked R
  comparison: naive mean-imputation SE vs. `mice`-pooled SE on
  identical simulated MAR-ish data, pooled SE visibly larger.
- **§7.4 multiple imputation**: `mice()` with `m`, `method` (`"pmm"`,
  `"logreg"`, `"polyreg"`), `complete()`, and `with()`+`pool()` per
  Rubin's rules (within + between-imputation variance). `Amelia`
  (EMB algorithm, longitudinal/time-series strength) and `missForest`
  (random-forest, nonparametric, handles mixed types well, but
  produces a SINGLE completed dataset — not naturally combinable via
  Rubin's rules the way `mice::pool()` is — flagged as a real,
  standing limitation) as alternatives.
- **§7.5 sensitivity analysis**: tipping-point analysis (vary a delta
  applied only to imputed values, find the delta at which a
  conclusion flips, judge that delta's clinical plausibility) worked
  with an R loop; ties to Ch.4's WTP threshold lambda for the
  cost-effectiveness variant. Pattern-mixture models explained
  conceptually (stratify by missingness pattern, differing
  assumptions per pattern, "jump to reference"). `rbmi` (real
  Roche-developed CRAN package for reference-based MI in clinical
  trials) named at the conceptual/purpose level without inventing
  specific function calls, per the task's explicit caution.
- **§7.6 missing cost/QALY data**: cost data right-skewed/zero-inflated
  (naive mean imputation especially dangerous); utilities bounded
  (~[-0.59, 1]); informative dropout as a form of MNAR (deteriorating
  patients disproportionately missing late-stage data). `mice`
  post-processing to clamp imputed values to valid ranges, worked R
  example. Explicitly ties back to Chapter 4's `treatment`/`cost`/
  `qaly` dominance-pruning tibble as the downstream consumer most at
  risk from undetected upstream imputation error.
- **§7.7 reporting for HTA**: CHEERS 2022's missing-data checklist item
  (amount/pattern by arm, assumed mechanism+justification, primary
  method stated with reproducible specificity, sensitivity analyses +
  robustness conclusion) as the anchor. ICH E9(R1) estimand framework
  (intercurrent events, treatment-policy/hypothetical/composite/
  while-on-treatment/principal-stratum strategies) tied to how the
  "right" missing-data assumption gets chosen. Closing transition to
  Chapter 8 (HRQoL and Utilities) — missing utility values as a
  symptom of instrument/elicitation/timing choices covered there.

## Agency grounding — proactive, all real named documents
Continuing the proactive discipline from Ch.4-6: Faria, Gomes, Epstein
& White (2014, *PharmacoEconomics*) "A Guide to Handling Missing Data
in Cost-Effectiveness Analysis Conducted Within Randomised Controlled
Trials" (§7.2); CHEERS 2022's missing-data reporting item, already
established as a real citable document since Ch.3 (§7.7); ICH E9(R1)
addendum on estimands and sensitivity analysis (§7.7). No fabricated
document names, numbers, or TSD references — where `rbmi`'s exact
function signatures weren't confidently known, the chapter deliberately
described its purpose/approach only, per the task's own instruction,
rather than inventing specific calls.

## Package/function-name verification (continuing Ch.6's lesson)
All package functions cross-checked as real during assembly before
being accepted: `naniar::vis_miss()`, `gg_miss_var()`, `gg_miss_upset()`,
`mcar_test()`; `visdat::vis_dat()`, `vis_miss()`; `mice::mice()`,
`complete()`, `with()`, `pool()` with real method names `"pmm"`,
`"logreg"`, `"polyreg"`; `Amelia::amelia()`; `missForest::missForest()`;
`rbmi` as a real CRAN package name (used only at conceptual level, no
invented function calls). No invented functions found this chapter —
zero code_validity issues on the first Jev pass (7.35/10, clear above
threshold).

## Image tracking (per skill's mandatory step 11b)
- **Track 1:** none identified this chapter — the MCAR/MAR/MNAR
  decision logic (§7.1) is conceptual but adequately served by the
  worked prose example; no genuinely diagram-shaped structural content
  found.
- **Track 2:** none identified this chapter — all R code in this
  chapter produces console/summary output (SE comparisons, pooled
  regression summaries, tipping-point tibbles) rather than a
  statistical plot; the naniar/visdat visualisations in §7.2 are
  themselves the content being taught, not a supplementary figure for
  Dr Aswath to render and supply separately.

## Jev rubric scores (raw, 1-10 scale) — first pass, no revision needed
coverage 8.44, technical_correctness 7.58, code_validity 7.35,
agency_grounding 6.56, internal_consistency 8.34, readability 6.89.
All six dimensions clear the 6/10 threshold on the first draft.

## Open items / things later chapters should not contradict
- Chapter 8 (HRQoL and Utilities) should pick up directly where §7.7's
  closing transition leaves off: missing utility values as a function
  of instrument choice, elicitation method, and measurement timing,
  not re-derive missing-data mechanics from scratch.
- Any later chapter handling missing cost or utility data in a worked
  example should respect the bounded-imputation discipline established
  in §7.6 (clamp utilities to their valid range, costs to non-negative)
  rather than silently reverting to unconstrained mean imputation.
- `rbmi` is now an established real-package reference for
  reference-based/pattern-mixture MI; if a later chapter (e.g. Ch.10
  survival analysis, Ch.25 uncertainty) needs to go deeper into its
  actual function signatures, verify them against real package
  documentation before using them, per the standing Ch.6 lesson.
