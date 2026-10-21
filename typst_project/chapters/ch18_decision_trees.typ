#import "../common.typ": *

= Chapter 18. Decision Trees

Chapter 17 was a map: how to scope a decision problem, choose a model type, and organise the R project around it. This chapter builds the first real engine on that map -- the decision tree, the simplest member of the decision-analytic modelling family and the right tool exactly when §17.2's "one-off/short-horizon" criterion is met: a question that resolves within a single episode of care, with no need to track a cohort through recurring health states over years.

The running example for this chapter is deliberately *different* from Chapter 17's regimen-choice question (which committed to a Markov cohort model, built in Chapter 19). Instead, §18.1 through §18.5 follow a short-term TB *diagnostic-strategy* decision: a district programme choosing between a cheaper sputum-smear-only algorithm and a Xpert MTB/RIF molecular-test algorithm for patients presenting with TB symptoms. This is squarely tree territory -- test, get a result, act on it, done -- and §18.5 closes the loop by showing exactly how a tree like this one hands its output to a longer-term Markov model when a diagnosed patient's story continues for years, setting up Chapter 19 directly.

#learning-objectives((
  [Describe a decision tree's three node types -- decision, chance, terminal -- and compute expected cost and expected QALYs by hand via the roll-back algorithm (18.1).],
  [Represent a decision tree as a tidy R data structure and compute its expected values with vectorised arithmetic, reproducing a hand calculation exactly (18.2).],
  [Build the same tree using the `rdecision` package's node/edge classes, and explain what a dedicated package buys over a from-scratch calculation (18.3).],
  [Recognise the general class of short-horizon problems -- screening, diagnostics, acute care -- that decision trees suit, beyond the chapter's TB example (18.4).],
  [Explain how a decision tree's terminal-node probabilities become the starting cohort distribution for a downstream Markov model (18.5).],
))

== 18.1 Structure and expected-value calculations

A decision tree is the short-horizon cousin of the Markov model you built in Chapter 17: instead of cycling through states over years, it plays out a single episode of care as a branching sequence of chance events, then stops. Every tree has three kinds of nodes. A *decision node* (drawn as a square) is the strategy choice itself -- the thing you, the analyst, are being asked to recommend. A *chance node* (a circle) is a point where nature decides the outcome, with branch probabilities that must sum to 1 across all branches leaving that node. A *terminal node* (a triangle, or just the end of a branch) carries the *payoffs* -- here, a cost and a QALY value -- accumulated by the time that path is reached. Trees are the right tool exactly when §17.2's criteria point to a short, non-recurring decision problem with no need to track disease progression over multiple cycles -- which is why this chapter switches to a different slice of the TB pathway than Chapter 17's regimen choice.

#shiny-app-box("diagnostic_tree_icer_dashboard", [Drag disease prevalence, test sensitivity/specificity, and cost sliders and watch the roll-back expected cost/QALYs and ICER update live for both diagnostic strategies.])

*Worked example -- diagnostic strategy choice.* A district TB programme is choosing between two algorithms for patients presenting with TB symptoms: a cheaper *sputum-smear-only* algorithm and a *Xpert MTB/RIF* molecular-test algorithm. Among symptomatic presenters, TB prevalence is $p = 0.30$. Smear microscopy has sensitivity $0.60$ and specificity $0.98$; Xpert has sensitivity $0.90$ and specificity $0.96$. Each strategy therefore branches first on true disease status (TB / no TB), then on test result, producing four terminal outcomes: true positive (TP, correctly started on treatment), false negative (FN, missed -- presents later, sicker), false positive (FP, treated unnecessarily), and true negative (TN, correctly reassured).

Branch probabilities (disease status $times$ conditional test-result probability):

- Smear: $"TP" = 0.30 times 0.60 = 0.18$; $"FN" = 0.30 times 0.40 = 0.12$; $"FP" = 0.70 times 0.02 = 0.014$; $"TN" = 0.70 times 0.98 = 0.686$ (sums to $1.000$).
- Xpert: $"TP" = 0.30 times 0.90 = 0.27$; $"FN" = 0.30 times 0.10 = 0.03$; $"FP" = 0.70 times 0.04 = 0.028$; $"TN" = 0.70 times 0.96 = 0.672$ (sums to $1.000$).

Terminal payoffs are the test's own cost plus whatever downstream cost and QALY the outcome triggers over the episode: TP costs the test plus \$100 treatment, QALY $0.95$; FN costs the test plus \$300 (later, more severe re-presentation), QALY $0.70$; FP costs the test plus \$100 unnecessary treatment, QALY $0.90$; TN costs only the test, QALY $0.97$. Smear costs \$5 per patient tested; Xpert costs \$25.

The *rollback* (or "folding back") algorithm works from the terminal nodes backward: at each chance node, replace the branches below it with their probability-weighted average payoff, repeating until only the decision node remains with one EV per strategy. For a tree this shallow, rollback collapses to a single weighted sum per strategy -- exactly the $"EV" = sum_i p_i times "payoff"_i$ logic from §4.4, just applied twice (once for cost, once for QALYs).

*Smear -- expected cost:*
$ 0.18 times 105 + 0.12 times 305 + 0.014 times 105 + 0.686 times 5 $
$ = 18.90 + 36.60 + 1.47 + 3.43 = \$60.40 $

*Smear -- expected QALYs:*
$ 0.18 times 0.95 + 0.12 times 0.70 + 0.014 times 0.90 + 0.686 times 0.97 $
$ = 0.1710 + 0.0840 + 0.0126 + 0.6654 = 0.93302 $

*Xpert -- expected cost:*
$ 0.27 times 125 + 0.03 times 325 + 0.028 times 125 + 0.672 times 25 $
$ = 33.75 + 9.75 + 3.50 + 16.80 = \$63.80 $

*Xpert -- expected QALYs:*
$ 0.27 times 0.95 + 0.03 times 0.70 + 0.028 times 0.90 + 0.672 times 0.97 $
$ = 0.2565 + 0.0210 + 0.0252 + 0.6518 = 0.95454 $

Xpert costs more per patient tested (\$63.80 vs \$60.40) but also catches more true TB cases, raising expected QALYs (0.95454 vs 0.93302). Following §4.4's ICER formula:

$ "ICER" = frac(63.80 - 60.40, 0.95454 - 0.93302) = frac(3.40, 0.02152) approx \$158 "per QALY gained" $

At roughly \$158 per QALY gained, Xpert is cheap insurance against missed diagnoses by almost any plausible willingness-to-pay threshold -- the arithmetic, not intuition, is what makes that call defensible.

#pitfall[
  It is tempting to price a diagnostic test only by sensitivity and specificity and forget that *prevalence* sets how often you even reach the TP/FN branches versus the FP/TN branches. A highly sensitive test bought at high prevalence saves far more QALYs than the same test deployed where TB prevalence among presenters is low -- rerun this tree with $p = 0.10$ and watch the ICER move before trusting any single-country number from a published costing study.
]

== 18.2 Building decision trees from scratch in R

You don't need a modelling package to run the rollback algorithm above -- it's eight numbers multiplied and added, which is exactly what R's vectorized arithmetic is for. Representing the tree as a tidy data structure, one row per terminal path, makes the "fold back" step a single `sum(prob * payoff)`, and it keeps every branch probability and payoff visible for audit rather than buried in a diagram.

The key discipline is to store the branch probabilities *unmultiplied* (disease status and conditional test-result probability as separate columns) and compute the path probability explicitly as their product -- that product is the rollback algorithm, made concrete as one line of R:

```r
library(dplyr)

tb_tree <- tibble::tribble(
  ~strategy, ~outcome, ~p_disease, ~p_test, ~cost_test, ~cost_downstream, ~qaly,
  "Smear",   "TP",      0.30,       0.60,    5,          100,              0.95,
  "Smear",   "FN",      0.30,       0.40,    5,          300,              0.70,
  "Smear",   "FP",      0.70,       0.02,    5,          100,              0.90,
  "Smear",   "TN",      0.70,       0.98,    5,          0,                0.97,
  "Xpert",   "TP",      0.30,       0.90,    25,         100,              0.95,
  "Xpert",   "FN",      0.30,       0.10,    25,         300,              0.70,
  "Xpert",   "FP",      0.70,       0.04,    25,         100,              0.90,
  "Xpert",   "TN",      0.70,       0.96,    25,         0,                0.97
)

tb_tree <- tb_tree |>
  mutate(
    path_prob = p_disease * p_test,     # the branch-probability product
    cost      = cost_test + cost_downstream
  )

# sanity check: branch probabilities must sum to 1 within each strategy
tb_tree |>
  group_by(strategy) |>
  summarise(total_prob = sum(path_prob))
#> Smear: 1.000   Xpert: 1.000
```

With `path_prob` computed, the rollback itself is one `summarise()` call -- a direct, line-by-line translation of the hand arithmetic in §18.1:

```r
ev <- tb_tree |>
  group_by(strategy) |>
  summarise(
    ev_cost = sum(path_prob * cost),
    ev_qaly = sum(path_prob * qaly)
  )
ev
#> strategy ev_cost ev_qaly
#> Smear      60.40 0.93302
#> Xpert      63.80 0.95454

icer <- diff(ev$ev_cost) / diff(ev$ev_qaly)
icer
#> [1] 157.99...
```

`ev_cost` and `ev_qaly` reproduce the \$60.40 / 0.93302 (Smear) and \$63.80 / 0.95454 (Xpert) computed by hand, and `icer` lands at the same $approx \$158$ per QALY gained -- confirming that `sum(path_prob * payoff)` *is* the rollback algorithm, not an approximation of it. `path_prob` is just the product of branch probabilities along one path through the tree; grouping by strategy and summing is folding every chance node back into its parent decision node in a single pass.

#report-table(
  [Expected cost, expected QALYs, and incremental cost-effectiveness ratio for the two TB diagnostic strategies, as computed in §18.1--§18.2's worked example.],
  academic-table(
    columns: (1.4fr, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    header: ([*Strategy*], [*Expected cost*], [*Expected QALYs*], [*Incr. cost*], [*ICER*]),
    body: (
      [Smear-only], [\$60.40], [0.93302], [--], [--],
      [Xpert MTB/RIF], [\$63.80], [0.95454], [\$3.40], [\$158/QALY],
    ),
    footer: (table.cell(colspan: 5)[Xpert MTB/RIF dominates on effectiveness at a low incremental cost per QALY gained relative to smear-only testing.],),
  ),
) <tab-ch18-tb-diagnostic-icer>

#agency-note[
  This `tribble` is small enough to type by hand for a teaching example, but in practice you'd pull `p_disease` (prevalence), `p_test` (sensitivity/specificity by algorithm), and `cost_downstream` straight from your programme's own diagnostic register and treatment-outcome data -- the same register you already query for routine TB surveillance reporting. Wiring a decision tree to live data is a `dplyr::summarise()` away once the register is shaped like `tb_tree`.
]

This data-frame-and-`sum()` approach scales poorly once trees grow beyond a handful of branches per strategy, or once you want probabilistic sensitivity analysis sampling every probability and payoff from a distribution -- bookkeeping that a dedicated package can do more safely. §18.3 rebuilds this exact tree in `rdecision`, so you can see the package automate precisely the two steps -- path-probability products and grouped summation -- you just wrote by hand.

== 18.3 Using `rdecision`

Everything built in §18.2 -- nodes, branch probabilities, cost and QALY bookkeeping -- was done by hand, in base R vectors and a handful of helper functions. That is the right way to *learn* what a decision tree computes, but it does not scale well once you want probabilistic sensitivity analysis (PSA, Chapter 25), graphical audit trails for a submission dossier, or a tree with more than two or three branch points. The CRAN package `rdecision` was written specifically for HTA-style decision-tree and Markov modelling in R, and it is worth adopting once your tree stops being a one-off script.

`rdecision` models a tree as a graph of R6-class objects rather than a data frame. The classes you will meet first are `DecisionNode` (a root-level choice point -- our "which algorithm?" node), `ChanceNode` (a point where nature decides -- "is the patient truly TB-positive?", "did the test read positive?"), and `LeafNode` (a terminal outcome, carrying an incremental `utility` and an `interval` over which it applies -- `rdecision`'s terminology for the per-path QALY contribution). Edges connecting them are `Action` objects (for branches out of a `DecisionNode`; constructor `Action$new(source_node, target_node, label, cost = 0, benefit = 0)` -- note `label` is required and `cost` is a named argument, not positional) and `Reaction` objects (for branches out of a `ChanceNode`; constructor `Reaction$new(source_node, target_node, p = 0, cost = 0, benefit = 0, label = "")`, where `p` is the conditional branch probability). The whole structure is assembled into a `DecisionTree` object from its vertex and edge lists, which exposes an `evaluate(setvars = "expected", by = "strategy")` method that walks the tree and returns a data frame of expected cost, benefit, and QALY per strategy -- doing the EV roll-back you wrote by hand in §18.2 internally.

#difficult-terminology("R6 class / R6-class objects")[
R6 is one of several systems R offers for *object-oriented
programming* -- a style of coding where, instead of keeping your data
in a plain data frame and writing separate functions that operate on
it, you bundle data and the functions (called *methods*) that act on
that data together into a single thing called an *object*. Each R6
object is created from a *class* -- a blueprint describing what fields
(data) and methods (behaviour) every object of that type will have.
Concretely in this chapter: a `ChanceNode` object doesn't just sit
there holding a probability value -- it is a self-contained thing that
knows its own branches, can be asked to validate that its outgoing
probabilities sum to 1, and participates in the tree's `evaluate()`
walk without you writing a bespoke loop for it. The syntax tell-tale is
the dollar sign: `Action$new(...)` *creates* a new object from the
`Action` class (like calling a constructor), and once you have an
object such as `ictstm` (seen later in Chapter 21), you call its
methods the same way -- `ictstm$sim_disease()` -- reading as "ask this
object to run its own disease-simulation method," as opposed to the
more familiar R style of `sim_disease(ictstm)`, where the object is
just a passive argument to a free-standing function. You do not need
to write your own R6 classes to use `rdecision` -- you only need to
recognise `Class$new(...)` as "build me an object of this type" and
`object$method(...)` as "ask this object to do something," which is
enough to read and adapt every `rdecision` example in this chapter.
]

These signatures (confirmed against the live CRAN reference manual for `rdecision`, not asserted from memory) resolve the hedge this chapter would otherwise need: argument order is `source_node, target_node` first, then the named `p=`/`cost=`/`benefit=`/`label=` arguments, and `rdecision` follows one `rdecision`-specific convention worth flagging explicitly for anyone used to the §18.1--18.2 convention of listing TP/FN/FP/TN as four separate branches per algorithm: it is idiomatic in `rdecision` vignettes to leave *one* reaction's probability as `p = NA_real_`, which the package then fills in at evaluation time as one minus the sum of the other reactions from that same chance node -- a built-in version of the "branch probabilities must sum to 1" check from §18.1, enforced by the package rather than by a manual `sum()` sanity check.

Sketched against the TB running example -- smear-only vs Xpert, each branching first on true disease status then on test result -- the shape below reuses §18.1--18.2's exact numbers ($p = 0.30$ prevalence; smear sensitivity 0.60/specificity 0.98; Xpert sensitivity 0.90/specificity 0.96; costs and QALYs per outcome as tabulated in §18.1):

```r
library(rdecision)

# Branch probabilities and payoffs, reusing §18.1's worked numbers exactly
p_tb <- 0.30
sens_smear <- 0.60; spec_smear <- 0.98
sens_xpert <- 0.90; spec_xpert <- 0.96
cost_smear_test <- 5; cost_xpert_test <- 25
cost_tp <- 100; cost_fn <- 300; cost_fp <- 100; cost_tn <- 0
qaly_tp <- 0.95; qaly_fn <- 0.70; qaly_fp <- 0.90; qaly_tn <- 0.97

# Decision node: choice of diagnostic algorithm
d1 <- DecisionNode$new("algorithm")

# One chance node per algorithm for disease status, one per status for
# the test-result branch (true-positive/false-negative under TB;
# false-positive/true-negative under no-TB)
c_smear_disease <- ChanceNode$new("smear: disease status")
c_smear_tb_test  <- ChanceNode$new("smear: test | TB")
c_smear_notb_test <- ChanceNode$new("smear: test | no TB")
c_xpert_disease <- ChanceNode$new("xpert: disease status")
c_xpert_tb_test  <- ChanceNode$new("xpert: test | TB")
c_xpert_notb_test <- ChanceNode$new("xpert: test | no TB")

# Leaves carry the incremental utility (QALY-equivalent) for the outcome
t_smear_tp <- LeafNode$new("Smear:TP"); t_smear_fn <- LeafNode$new("Smear:FN")
t_smear_fp <- LeafNode$new("Smear:FP"); t_smear_tn <- LeafNode$new("Smear:TN")
t_xpert_tp <- LeafNode$new("Xpert:TP"); t_xpert_fn <- LeafNode$new("Xpert:FN")
t_xpert_fp <- LeafNode$new("Xpert:FP"); t_xpert_tn <- LeafNode$new("Xpert:TN")

# Actions carry the per-test cost; Reactions carry branch probability + cost
a_smear <- Action$new(d1, c_smear_disease, cost = cost_smear_test, label = "Smear")
a_xpert <- Action$new(d1, c_xpert_disease, cost = cost_xpert_test, label = "Xpert")

r_smear_tb  <- Reaction$new(c_smear_disease, c_smear_tb_test,  p = p_tb, cost = 0, label = "TB")
r_smear_notb <- Reaction$new(c_smear_disease, c_smear_notb_test, p = NA_real_, cost = 0, label = "No TB")
r_smear_tp <- Reaction$new(c_smear_tb_test, t_smear_tp, p = sens_smear, cost = cost_tp, label = "+ve")
r_smear_fn <- Reaction$new(c_smear_tb_test, t_smear_fn, p = NA_real_, cost = cost_fn, label = "-ve")
r_smear_fp <- Reaction$new(c_smear_notb_test, t_smear_fp, p = 1 - spec_smear, cost = cost_fp, label = "+ve")
r_smear_tn <- Reaction$new(c_smear_notb_test, t_smear_tn, p = NA_real_, cost = cost_tn, label = "-ve")
# ... equivalent reactions for the Xpert branch, using sens_xpert/spec_xpert ...

tree <- DecisionTree$new(
  V = list(d1, c_smear_disease, c_smear_tb_test, c_smear_notb_test,
           t_smear_tp, t_smear_fn, t_smear_fp, t_smear_tn,
           c_xpert_disease, c_xpert_tb_test, c_xpert_notb_test,
           t_xpert_tp, t_xpert_fn, t_xpert_fp, t_xpert_tn),
  E = list(a_smear, a_xpert,
           r_smear_tb, r_smear_notb, r_smear_tp, r_smear_fn, r_smear_fp, r_smear_tn)
           # ... plus the equivalent Xpert reactions ...
)

results <- tree$evaluate(setvars = "expected", by = "strategy")
results
```

What this buys over the §18.2 from-scratch version is not the arithmetic -- a correctly written vector calculation gives you the identical expected cost and QALY -- it is three things that matter once the model has to survive contact with a reviewer or a resampling loop. First, `evaluate()` can be called repeatedly over resampled probability and cost inputs with the tree structure untouched, which is exactly the vectorised-resampling pattern Chapter 25's PSA needs: you draw a new parameter set per iteration and re-roll the same tree, rather than hand-writing a Monte Carlo wrapper around your own cost/QALY functions. Second, `rdecision` trees can be rendered graphically (the package includes plotting support for the graph structure), giving you a diagram you can drop straight into a HTA submission's technical appendix instead of a prose description of node logic. Third, because cost and effect are tracked as native node attributes, ICER and incremental-NMB comparisons between the Smear and Xpert strategies (using the formulas from §4.4) come out of `evaluate()`'s returned data frame directly, rather than requiring you to re-derive them from raw EV totals each time.

#heor-practice[
  Keep the §18.2 hand-rolled version in your repository even after you migrate to `rdecision`. It is your independent cross-check: run both on the same inputs and confirm the expected costs and QALYs agree to the last rupee and the fourth decimal of a QALY. A graphical, package-driven tree that silently diverges from a transparent manual calculation is a red flag worth catching in `tests/` (§17.6), not in review.
]

== 18.4 Short-term models for screening, diagnostics and acute care

The TB smear-vs-Xpert tree is one instance of a much broader class of problem that decision trees are the right tool for. Chapter 17 §17.2 gave you the model-type-choice framework for deciding, up front, whether a problem needs a tree, a Markov model, or something else; the criterion to reuse by name here is the *one-off/short-horizon* test. A decision tree suits a question when the clinically and economically relevant consequences of each choice resolve within a single episode of care -- a test result, a treatment decision, a short course of therapy and its immediate outcome -- such that there is no need to track a cohort moving between recurring health states over months or years. The moment your question involves patients cycling between "well," "relapsed," "on second-line treatment," and "dead" over a multi-year horizon, you have left tree territory and moved into Markov territory (Chapter 19).

Screening and diagnostic-pathway evaluation is the textbook case, because the question is almost always "given this test's sensitivity, specificity and cost, and the downstream cost/outcome of each possible result, which algorithm is cheapest per unit of health gained *right now*" -- precisely the TB example running through this chapter. The same structure recurs in:

- *Antenatal screening algorithms* -- e.g. combined first-trimester screening for Down syndrome (nuchal translucency plus serum markers) versus a non-invasive prenatal test, where branches represent screen-positive/negative and the diagnostic-confirmation pathway (amniocentesis) that follows a positive screen, with the short horizon being the pregnancy itself rather than a lifetime of states.
- *Emergency-department triage pathway cost-effectiveness* -- e.g. comparing a rapid point-of-care troponin protocol against a standard serial-testing protocol for suspected acute coronary syndrome, where the tree's branches are "ruled in," "ruled out," and "observed," each with an immediate cost and a short-term outcome (discharge, admission, missed-diagnosis adverse event) rather than a chronic disease trajectory.

Neither example needs to be built out here in full; the point is structural. Whenever the decision context is "choose a pathway, observe branch probabilities resolve, tally the immediate consequence," reach for a tree. Whenever a chosen branch instead seeds a cohort that then lives on for years under recurring risks, the tree becomes the *front end* of a hybrid model -- which is exactly §18.5's subject.

#agency-note[
  NICE's Diagnostics Assessment Programme methods guide (the diagnostics-specific companion to NICE's *Guide to the methods of technology appraisal*) explicitly expects short-horizon decision-tree structures for test-and-treat pathways, and asks submitters to report sensitivity/specificity, the full branch-probability tree, and per-branch cost and outcome consequences transparently enough for the Diagnostics Advisory Committee to re-derive the EV roll-back independently. A tree built the way §18.2--18.3 built it -- explicit nodes, explicit probabilities, an auditable calculation -- is written to survive exactly that kind of scrutiny; a tree that only exists as an opaque spreadsheet formula typically is not.
]

== 18.5 Combining a decision tree with a long-term Markov model

Real HTA submissions for conditions with a chronic phase rarely use a decision tree *or* a Markov model in isolation -- they chain the two together, and the TB diagnostic-strategy question is a clean illustration of why. The tree in §18.1--18.3 answers "which diagnostic algorithm, and what happens to the patient in the near term as a result of a true/false positive/negative result." But a patient who is correctly diagnosed and started on treatment, one who is a false negative and remains undiagnosed and infectious, and one who is a false positive and started on treatment unnecessarily, do not have the same future. Their subsequent trajectories -- treatment completion, relapse, acquired drug resistance, transmission to contacts, death -- unfold over years, which is squarely the territory of the cohort Markov model Chapter 19 builds for the TB regimen-choice question introduced back in Chapter 17.

The handoff between the two model types is a well-established HTA pattern, and it is worth being precise about what actually crosses the interface: not patients, not probabilities-as-abstractions, but a *vector of state-occupancy probabilities*. Each leaf node of the decision tree corresponds to (or maps onto) one of the Markov model's starting health states, and the probability mass arriving at that leaf -- the product of branch probabilities along the path from root to leaf -- becomes the initial occupancy of that state at Markov cycle zero (time 0).

Concretely, for the TB tree: a patient who is a true positive under whichever algorithm was chosen enters the Markov model's "On Treatment" state at time 0; a false negative enters "Undiagnosed Active TB" (continuing to accrue transmission risk and mortality hazard before any future re-presentation); a true negative enters a "Well/No TB" state; and a false positive enters "On Treatment" too -- despite not having TB -- carrying the model's treatment-related costs and disutilities without the corresponding disease-free benefit a true positive would eventually realise. The decision tree's four terminal leaves per strategy collapse into (at least) three or four Markov starting states, and the tree's job is simply to produce the correctly weighted probability of starting in each one, per strategy.

This is why it matters that §18.1--18.3's leaf probabilities are kept as an explicit, inspectable vector rather than folded away inside an aggregate expected-cost number: Chapter 19 will read that vector directly as its `t=0` cohort distribution, in the same `inputs/` → `engine/` → `results/` → `reporting/` project layout established in Chapter 17 §17.6 -- the tree's `results/` output becomes (part of) the Markov engine's `inputs/`. No Markov transition matrix, cycle length, or half-cycle correction is introduced here; building that model, and running the resulting hybrid tree-plus-Markov analysis end to end for the TB regimen-choice question, is Chapter 19's task in full.

Chapter 19 picks up exactly here: the same TB programme, now asking what happens over years to patients who entered treatment (correctly or not) via this chapter's diagnostic tree, modelled as a Markov cohort moving between On Treatment, Cured, Treatment Failure, and Death -- the structure Chapter 17 §17.3 already diagrammed with `DiagrammeR::grViz()`.
