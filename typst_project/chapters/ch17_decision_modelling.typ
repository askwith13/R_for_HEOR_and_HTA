#import "../common.typ": *

= Chapter 17. Principles of Decision Modelling

Part III closed the estimation toolkit: effects, confounding adjustment, pooling, heterogeneity. Those chapters answered "what does the evidence say happened, or what would happen under a given treatment?" Chapter 17 asks a different question: given that evidence, what should a health system *do*? Decision-analytic modelling is the machinery for turning scattered estimates of effect, cost, and quality of life into a single comparative answer -- which TB treatment regimen should a programme adopt, and under what uncertainty?

This chapter is a map, not a computation. It walks through the decisions a modeller makes before writing a line of model code: what the decision problem actually is (17.1), which model type fits that problem (17.2), how to draw and defend the structure (17.3), what kinds of parameters feed it (17.4), how to document choices so others can audit them (17.5), how an R project should be organised to keep inputs, engine, and outputs cleanly separated (17.6), and which professional standards govern all of this (17.7). Chapters 18 through 22 then build the actual engines -- decision trees, Markov models, partitioned survival, and beyond.

#learning-objectives((
  [Scope a decision problem in HEOR terms: perspective, comparators, time horizon, and the question a model is meant to answer (17.1).],
  [Choose between decision trees, Markov models, partitioned survival, and other model types based on how a disease unfolds over time (17.2).],
  [Draw a model structure as a diagram in R using the DiagrammeR package, and justify structural assumptions explicitly (17.3).],
  [Classify model parameters by type -- probabilities, costs, utilities, relative effects -- and match each to an appropriate distribution for later uncertainty analysis (17.4).],
  [Write a model documentation record that makes every structural and parameter choice traceable and auditable (17.5).],
  [Organise an R decision-model project into separate inputs, engine, results, and reporting layers (17.6).],
  [Locate a decision model's obligations within the ISPOR-SMDM Modeling Good Research Practices series and the NICE reference case (17.7).],
))

== 17.1 Model conceptualisation and problem scoping

Before any R code is written, a decision model needs a clear statement of the question it is answering. This sounds obvious, but a surprising share of modelling projects go wrong here: the population drifts mid-project, the comparator list grows without anyone noticing, or the time horizon gets chosen by habit rather than by the disease biology. Chapter 4, section 4.6 already introduced the core framing vocabulary for an economic evaluation -- population, comparators, perspective, and time horizon. This chapter reuses those four terms exactly as defined there; we do not re-derive them.

#heor-practice[
Before opening RStudio, write down, in one sentence each: the population, the comparators, the perspective, and the time horizon for your model. If you cannot write all four sentences, you are not ready to model yet -- you are still scoping.
]

*The PICOTS framework.* HEOR borrows PICO from clinical epidemiology and extends it for economic evaluation: Population, Intervention, Comparator(s), Outcomes, Timing, Setting. PICOTS is simply a checklist that forces the same four ideas from 4.6 into a slightly finer grain -- splitting "comparators" into intervention vs. comparator, and adding outcomes, timing, and setting as explicit fields.

Take a TB programme decision as the running example for this chapter: should a national TB programme switch standard drug-susceptible TB patients from the 6-month daily regimen to a 4-month rifapentine-moxifloxacin regimen (as recommended following the Study 31/A5349 trial)? The table below sketches the PICOTS for this question.

#table(
  columns: (auto, auto),
  [*PICOTS element*], [*TB regimen example*],
  [Population], [Adults with newly diagnosed, drug-susceptible pulmonary TB],
  [Intervention], [4-month rifapentine-moxifloxacin regimen],
  [Comparator], [6-month standard daily regimen (2HRZE/4HR)],
  [Outcomes], [Treatment success, relapse, cost per patient treated, QALYs],
  [Timing], [Follow-up to 12 months post-treatment-completion, to capture relapse],
  [Setting], [Public TB programme clinics, national perspective],
)

Notice that "Timing" here is not the same as the model's time horizon. Timing in PICOTS describes the follow-up window of the *evidence* informing the model; the time horizon (4.6) is a separate modelling choice about how far forward the *model* itself projects, which may need to extend well beyond 12 months to capture downstream relapse and retreatment costs.

#pitfall[
A common scoping error is letting the comparator list expand once the project has started -- for example adding a shorter experimental regimen under trial, "just in case it's useful later." Every added comparator multiplies the data you need (efficacy, costs, utilities) and the validation burden. Lock the comparator list during scoping, and treat any addition as a formal scope change, not a quick extra column.
]

*The model concept document.* Once PICOTS is settled, write it up as a short model concept document -- typically one to two pages -- before touching R. This document states the decision problem, the PICOTS elements, the intended model type (chosen in 17.2), the main data sources you expect to use, and who the model is for (a funding ministry, a programme manager, a national guideline committee). Its purpose is to let clinical and economic stakeholders sign off on the *question* before anyone invests time building the *answer*. For our TB example, the concept document would note that the programme's budget cycle and WHO guideline review calendar may constrain the time horizon or the urgency of results -- decisions that are much cheaper to revisit on paper than inside a half-built R script.

== 17.2 Choosing a model type

Part IV covers five model types, one per chapter: decision trees (chapter 18), Markov cohort models (chapter 19), partitioned survival models (chapter 20), individual-level microsimulation (chapter 21), and discrete event simulation (chapter 22). This section does not explain how any of them work -- that is the job of chapters 18 through 22. Instead it gives you a framework for choosing *which* one fits a given decision problem, so that when you reach each later chapter you already know why it is the right tool for that chapter's example.

The ISPOR-SMDM Modeling Good Research Practices Task Force produced a series of papers exactly on this question. The task force report most relevant to choosing among state-transition approaches is Siebert et al. (2012), "State-Transition Modeling: A Report of the ISPOR-SMDM Modeling Good Research Practices Task Force--3." It is worth reading once you reach chapter 19, but its selection logic is useful right now.

*Five questions that narrow the choice.* Rather than memorising five model definitions, ask five questions about the disease and decision problem:

+ *Is this a single, one-off decision with a short time horizon and no need to track disease progression over time?* If yes, a decision tree (ch. 18) is usually sufficient -- and simpler is better when it is adequate.
+ *Does the disease move between a small number of discrete, recurring health states over time (e.g., "on treatment," "relapsed," "cured")?* This favours a Markov cohort model (ch. 19), the workhorse of chronic-disease HEOR.
+ *Is the treatment effect expressed mainly as survival curves or time-to-event outcomes, without well-defined intermediate health states to model explicitly?* This favours a partitioned survival model (ch. 20) -- common in oncology, where trial data arrive as progression-free and overall survival curves rather than discrete state transitions.
+ *Does a patient's future risk depend on their individual history -- how long they have already been in a state, prior treatment lines, accumulated events -- in a way a cohort-level model cannot capture?* This favours individual-level (microsimulation) modelling (ch. 21).
+ *Do shared, limited resources, queues, or interactions between patients matter to the outcome* -- for example, a diagnostic machine with finite daily capacity, or transmission between patients? This favours discrete event simulation (ch. 22), the only model type in Part IV that routinely models resource constraints explicitly.

These five questions are not mutually exclusive filters applied in strict order; they are prompts. Most real problems answer "yes" to more than one, and the final choice is a judgement about which structural feature matters *most* for the decision at hand, balanced against data availability and stakeholder familiarity with the method.

#heor-practice[
Apply the five questions to the TB regimen example from 17.1. TB treatment has discrete, clinically meaningful recurring states -- on treatment, cured, failed, relapsed, retreatment, death -- and patients can legitimately cycle between some of them (failure leads back to retreatment). There is no resource queue central to the question, and there is no strong need for patient-level memory beyond state occupancy. Question 2 dominates: a Markov cohort model (ch. 19) is the natural choice, and that is exactly the model type chapter 19 builds for this same example.
]

#pitfall[
Do not choose a model type because it is the one you already know how to code, or because a past project used it. The Siebert et al. task force report exists precisely because reviewers and HTA bodies expect the model type to follow from the disease's structural features -- not from analyst convenience. A mismatch (for example, forcing a partitioned survival model onto a disease with genuinely cyclical relapse-and-retreatment states) can bias results and will draw scrutiny in review.
]

== 17.3 Structural assumptions and model diagrams

Once a model type is chosen, the next step -- still before writing simulation code -- is to decide and document exactly how patients move through the model's health states. These choices are called structural assumptions, and three questions come up in almost every state-transition model:

- *Can patients move backward between states?* For example, can a "cured" TB patient return to "on treatment" (via relapse and retreatment), or is cure a one-way gate?
- *Is there a tunnel state* -- a state a patient can only occupy for a fixed number of cycles before being forced onward, used to represent things like a fixed treatment course length?
- *What happens at the end of the model's time horizon?* Do remaining patients in non-death states simply stop accruing costs and effects (a "closed cohort" assumption), or does the model apply some extrapolation beyond the explicit horizon?

Writing these answers down as explicit prose statements, before drawing anything, is what prevents disagreements from surfacing only after the R code is built and the numbers look odd.

*Drawing the structure.* A model diagram turns those prose statements into a picture that clinical collaborators can sanity-check at a glance, without reading any R code. The `DiagrammeR` package's `grViz()` function renders diagrams written in the DOT graph description language (the same language used by Graphviz), which makes it well suited to drawing health-state diagrams: states are nodes, transitions are directed edges.

The code below draws the structural diagram for our TB Markov model: patients on treatment can be cured or can fail treatment; failure leads back to re-registration for on-treatment care; and death is reachable as an absorbing state from every other state.

```r
library(DiagrammeR)

tb_model_diagram <- grViz("
digraph tb_markov_structure {

  graph [layout = dot, rankdir = LR]
  node [shape = box, style = filled, fontname = Helvetica]

  OnTx    [label = 'On Treatment',      fillcolor = lightblue]
  Cured   [label = 'Cured',             fillcolor = lightgreen]
  Fail    [label = 'Treatment Failure', fillcolor = lightsalmon]
  Death   [label = 'Death',             fillcolor = grey85]

  OnTx  -> Cured  [label = 'treatment success']
  OnTx  -> Fail   [label = 'treatment failure']
  Fail  -> OnTx   [label = 're-registration']

  OnTx  -> Death  [label = 'mortality']
  Cured -> Death  [label = 'mortality']
  Fail  -> Death  [label = 'mortality']
}
")

tb_model_diagram
```

Running this in RStudio (or a Quarto/R Markdown chunk) renders an interactive diagram directly in the viewer pane. The `rankdir = LR` argument lays the states left to right, which tends to read more naturally for treatment-pathway diagrams than the default top-to-bottom layout. Each `label` on an edge documents *why* the transition exists -- a habit worth keeping, because it turns the diagram itself into a piece of the structural-assumptions documentation rather than just decoration.

Note what the diagram already answers from our three questions above: backward movement exists (`Fail -> OnTx`), there is no tunnel state in this simplified version, and death is absorbing and reachable from everywhere -- all visible without reading a single line of transition-probability code.

#agency-note[
NICE's reference case for technology appraisals, together with NICE's Decision Support Unit technical support document series, expects submissions to include a clearly documented and justified model structure -- typically as a diagram of exactly this kind, accompanied by prose justifying each state and transition. Producing the diagram at the structural-assumptions stage, rather than retrofitting one after the model is built, makes this requirement far easier to satisfy.
]

#pitfall[
A model diagram is not optional polish added for a report's appendix. If you cannot draw your model's states and transitions in a few minutes using `grViz()`, you likely do not yet have a clear enough structural assumption set to start building the model in R -- go back to the three questions above before writing any transition-probability code.
]

== 17.4 Parameter taxonomy and distributions

Every decision-analytic model is built from four kinds of parameters, and getting the taxonomy straight matters because each kind draws its evidence from a different place in this book and takes a different distribution in probabilistic sensitivity analysis (PSA).

*Transition probabilities* move patients between health states each cycle: cured, on treatment, lost to follow-up, dead. *Costs* attach resource use in each state to a price. *Utilities* convert time in a state into quality-adjusted life years (QALYs). *Relative treatment effects* (hazard ratios, risk ratios, odds ratios) scale one arm's parameters relative to a comparator.

Costs and utilities are not estimated inside the decision model -- they are imported. Chapter 9 covered fitting GLMs to costing data and the gamma/lognormal distributions that describe the resulting uncertainty; Chapter 8 covered sourcing utility weights (EQ-5D mapping, vignette studies, literature tariffs) and their beta-like uncertainty. Chapter 17 does not re-derive any of that -- it just slots the fitted mean and standard error into the model's parameter table. Likewise, relative treatment effects come from the pooled estimates in Chapters 11 (pairwise meta-analysis) and 12 (network meta-analysis): the pooled log hazard ratio and its standard error from a random-effects model there become the treatment-effect parameter here.

What *is* new in a decision model is the transition probability itself, because trials rarely report it directly -- you typically reconstruct it from a reported proportion with a confidence interval, and that calls for a distribution that respects the 0-1 bound.

#heor-practice[
*Why bounded distributions, not normal.* A transition probability must stay between 0 and 1 in every PSA draw. A normal distribution can return a draw below 0 or above 1, which produces a model error or a silently nonsensical result. The beta distribution is defined on [0, 1] and is the standard choice for single probabilities; the Dirichlet distribution is its multivariate generalisation, used when several destination probabilities from one state (e.g. cured / still on treatment / dead) must each stay in [0, 1] *and* sum to exactly 1 every draw.
]

The conventional distributional choices, by parameter type, are:

- *Probabilities and proportions* -- Beta, because it is bounded on [0, 1] and matches the binomial likelihood that usually generated the estimate.
- *Multinomial transition probabilities* (more than two destinations from one state) -- Dirichlet, so the simulated probabilities always sum to 1.
- *Costs* -- Gamma or lognormal, because cost data are right-skewed and bounded at 0 (see Chapter 9 for the GLM machinery that produces the mean and variance going into these distributions).
- *Utilities* -- Beta when the utility itself is bounded in [0, 1] (most adult EQ-5D-3L tariffs), or Dirichlet when utility decrements are modelled as a set of mutually exclusive health-state weights that must sum to 1.
- *Relative treatment effects* -- usually normal on the log scale (log hazard ratio, log odds ratio), because that is the scale on which the meta-analytic standard error from Chapters 11-12 was estimated.

Fitting a beta distribution to a transition probability is pure algebra: the method-of-moments equations convert a mean and variance into the two beta shape parameters, alpha and beta.

$ alpha = mu dot (frac(mu(1-mu), sigma^2) - 1), quad beta = (1-mu) dot (frac(mu(1-mu), sigma^2) - 1) $

Suppose a trial reports a 12-month cure probability of 0.85 with a 95% CI of (0.80, 0.90). Treating the CI as approximately normal on the probability scale, the standard error is the half-width divided by 1.96, and the variance is its square.

```r
# Method-of-moments beta fit from a trial's reported mean and 95% CI
mean_p <- 0.85
ci_lower <- 0.80
ci_upper <- 0.90

se_p <- (ci_upper - ci_lower) / (2 * 1.96)
var_p <- se_p^2

common_term <- (mean_p * (1 - mean_p) / var_p) - 1
alpha_p <- mean_p * common_term
beta_p  <- (1 - mean_p) * common_term

alpha_p  # 165.68
beta_p   #  29.24

# Check: does Beta(alpha_p, beta_p) reproduce the mean and SE we started with?
fitted_mean <- alpha_p / (alpha_p + beta_p)
fitted_var  <- (alpha_p * beta_p) / ((alpha_p + beta_p)^2 * (alpha_p + beta_p + 1))
fitted_mean          # 0.85 -- matches
sqrt(fitted_var)     # 0.0255 -- matches se_p
```

The fitted shape parameters are alpha approx 165.68 and beta approx 29.24, and the check confirms the round trip: a `Beta(165.68, 29.24)` distribution has mean 0.85 and standard error 0.0255, exactly what the trial reported. In Chapter 25 this `Beta(alpha_p, beta_p)` object is what gets sampled thousands of times inside the PSA loop; this chapter's job stops at specifying the distribution correctly.

#pitfall[
Large alpha and beta values (as above) mean the beta distribution is tightly concentrated around the mean -- appropriate for a well-powered trial. A small trial arm (say n = 20) produces much smaller shape parameters and a visibly wider, sometimes skewed distribution. Always sanity-check the fitted alpha and beta against the sample size implied by the reported CI; a mismatch usually means the CI was log-scale or Wilson-interval, not the simple normal approximation used above.
]

#difficult-terminology("Wilson interval (Wilson score interval)")[
When you calculate a confidence interval around a proportion (like "85%
of patients responded"), the simplest textbook method — the one most
clinicians meet first — assumes the sampling distribution is roughly a
symmetric bell curve and builds the interval as "estimate plus or minus
some multiple of the standard error." That simple normal-approximation
method breaks down badly when the proportion is close to 0% or 100%,
or when the sample size is small: it can even produce a nonsensical
interval that dips below 0% or climbs above 100%. The Wilson interval
(also called the Wilson score interval) is an alternative formula that
handles exactly these edge cases properly — it is derived slightly
differently (by inverting a hypothesis-testing statistic rather than
assuming symmetry) and stays within the valid 0-100% range, and gives
more trustworthy coverage for small or extreme-proportion trial arms.
As a working rule: if a reported trial result's confidence interval
looks asymmetric around the point estimate, or the proportion is near
0 or 1, suspect it was built with a Wilson-type method rather than the
simple symmetric approximation, and account for that when back-fitting
a Beta distribution as in the worked example above.
]

== 17.5 Model documentation and transparency

A decision model that only its author can run is not fit for HTA submission, however correct its arithmetic. Two linked expectations govern this: external bodies expect the model's *logic* to be auditable, and they expect the model's *code* to actually execute on someone else's machine.

ISPOR-SMDM's Good Research Practices Task Force addressed the first expectation directly. Eddy et al. (2012), "Model Transparency and Validation" -- one paper in the seven-part task force series on good modelling practice -- sets out what a model needs to disclose so that a third party can understand what it does without re-running it: the health states and transitions, every parameter's source and value, every structural assumption, and the validation checks performed against external data. Transparency here does not mean publishing source code; it means a reviewer can reconstruct the model's logic from the written description alone.

NICE's methods guide goes further for UK submissions: it expects an *executable* R (or equivalent) model, fully commented, that NICE's own technical team can run and interrogate. Chapter 2 covered the `renv` project-level dependency locking that makes a submitted model reproducible on a reviewer's machine years later; Chapter 28 will cover the full reporting and submission-package treatment. The point to take from this section is narrower: documentation and code are not substitutes for each other. A commented script explains *how* the model computes; a technical model documentation (TMD) report explains *why* it is built the way it is, for a reader who may never open the script at all.

#agency-note[
NICE technical support documents and the associated reference case checklist specify that a submitted economic model must run without error in a clean environment, with all input parameters either hard-coded with cited sources or loaded from a clearly labelled data file -- no undocumented manual steps. This is precisely the reproducibility bar Chapter 2's `renv` workflow targets.
]

In practice, agencies expect a TMD report structured around five sections, matching the Eddy et al. transparency checklist:

+ *Inputs* -- every parameter, its point estimate, its source citation, and its distribution for PSA (the taxonomy from 17.4 feeds directly into this section).
+ *Structure* -- the states, cycle length, time horizon, and transitions, with a rationale for each structural choice (Section 17.1-17.3 territory).
+ *Assumptions* -- every simplification made and why it was judged acceptable (e.g. no second-line retreatment arm, constant background mortality).
+ *Validation* -- face validity checks, comparison against published cohort outcomes, and any cross-validation against an independent model.
+ *Outputs* -- the base-case results, and a signpost to where the uncertainty analysis (Chapter 25) and scenario analyses are reported.

#heor-practice[
Write the TMD's "Inputs" section as a literal table with four columns -- parameter, value, source, distribution -- rather than prose. Reviewers compare this table line-by-line against the R model's parameter list; prose descriptions slow that check down and invite transcription errors between report and code.
]

The TMD and the executable model are two views of the same object. Treat the TMD as the map and the R script as the territory: if they disagree, the model is wrong even when the code runs without error.

== 17.6 Modelling workflow in R: inputs -> engine -> outputs -> reporting

A decision model is a pipeline, not a script. Treating it as one script -- parameters hard-coded inline, calculations and formatting tangled together -- is the single most common cause of models that cannot be audited, extended, or debugged six months later. The fix is architectural, not statistical: separate the model into four layers that each do one job and talk to the next through a clean interface.

*The four layers.* An _inputs layer_ defines every parameter the model needs, as a named list or a tidy tibble, with nothing else happening in that file. An _engine layer_ is a function that takes the parameter object and returns raw model output -- total cost and total QALYs per strategy -- with no knowledge of how those numbers will later be displayed. A _results layer_ takes engine output and computes the comparative statistics analysts actually want: incremental cost-effectiveness ratios (ICERs) and net monetary benefit (NMB). Section 4.4 already derived both formulas in full; this layer simply applies them to whatever the engine produced, so nothing here is re-derived. A _reporting layer_ turns results into tables, plots, and narrative text. Chapter 28 (Reproducible Reporting) covers this layer properly; for now, treat it as "whatever renders the results object into something a decision-maker reads."

The payoff of this separation is that each layer can be tested, swapped, or re-run independently. Changing a discount rate means editing the inputs file. Changing from a decision tree to a Markov model means replacing the engine function -- the results and reporting layers do not change at all, because they only ever see cost and QALY totals per strategy, never the mechanics that produced them.

*A worked skeleton.* The engine function signature below is deliberately generic. It is a contract, not a working model: given a parameter list, return a tibble with one row per strategy. What happens *inside* the function -- branch probabilities for a decision tree, transition matrices for a Markov model, survival curves for partitioned survival -- is exactly the subject of Chapters 18 through 22. Nothing about that mechanics belongs in this chapter.

```r
# --- inputs layer ---------------------------------------------------
params <- list(
  strategies = c("Regimen_A", "Regimen_B"),
  cost_drug  = c(Regimen_A = 450, Regimen_B = 980),   # per course, local currency
  p_cure     = c(Regimen_A = 0.86, Regimen_B = 0.91),
  qaly_cured = 1.0,
  qaly_fail  = 0.6
)

# --- engine layer ----------------------------------------------------
# Generic signature only -- the real decision-tree / Markov mechanics
# live in Chapters 18-22. Here the engine is a stand-in.
run_model <- function(params) {
  tibble::tibble(
    strategy    = params$strategies,
    total_cost  = params$cost_drug[params$strategies],
    total_qaly  = params$p_cure[params$strategies] * params$qaly_cured +
                   (1 - params$p_cure[params$strategies]) * params$qaly_fail
  )
}

engine_out <- run_model(params)

# --- results layer -----------------------------------------------------
# ICER and NMB formulas: see Section 4.4. Not re-derived here.
results <- engine_out |>
  dplyr::arrange(total_cost) |>
  dplyr::mutate(
    inc_cost  = total_cost - dplyr::first(total_cost),
    inc_qaly  = total_qaly - dplyr::first(total_qaly),
    icer      = inc_cost / inc_qaly,
    nmb       = total_qaly * 20000 - total_cost   # threshold = 20,000/QALY
  )

# --- reporting layer -----------------------------------------------------
# Tables, plots, narrative -- see Chapter 28 (Reproducible Reporting).
```

#agency-note[
This skeleton is intentionally thin. `run_model()` here does almost nothing, because its real job -- simulating disease progression over time -- is Chapters 18 to 22's content. What matters in this chapter is the *shape* of the pipeline, not the arithmetic inside any one box.
]

*Two packages that already do this.* You do not have to build this architecture from scratch every time. _heemod_ is a mature CRAN package that implements exactly this inputs/engine/output separation for Markov cohort models, with its own functions for defining states, transitions, and strategies; Chapter 19 covers it properly. _hesim_ does something similar across a broader range of model types, including partitioned survival models; it appears again in Chapters 19 and 20. Neither package is used here beyond naming them -- inventing their function calls prematurely would teach the wrong syntax before the right chapter explains it.

#pitfall[
Mixing layers is the fastest way to make a model impossible to debug. If a cost figure looks wrong, you want to be able to check the inputs file in isolation, then the engine's arithmetic, then the results formulas -- not wade through three hundred lines where all of that is interleaved with `ggplot2` calls.
]

== 17.7 Good practice guidelines (ISPOR-SMDM, NICE reference case)

Everything in this chapter -- scoping, model choice, structure, parameters, documentation, workflow -- sits inside two governing frameworks that the rest of Part IV assumes without restating. Naming them once, here, is enough.

*ISPOR-SMDM Modeling Good Research Practices.* A joint ISPOR-SMDM task force, co-chaired by Eddy, Caro, Briggs, Pitman, Sculpher and others, published a seven-paper series in *Value in Health* in 2012 setting out good practice for health-economic modelling end to end. Caro et al. (2012), "Modeling Good Research Practices -- Overview," is the umbrella paper that frames the other six. Section 17.2 already cited Siebert et al. (2012) on state-transition (Markov) models specifically, and Section 17.5 already cited Eddy et al. (2012) on model transparency and validation; both are part of this same series, not separate frameworks. The series as a whole is the methodological backbone for Chapters 18 to 22: whichever model type you build, its task-force paper is the reference for what "good" looks like.

*The NICE reference case.* Where ISPOR-SMDM sets general modelling practice, the NICE reference case sets a specific national standard: a defined set of methodological choices that HTA submissions to England's National Institute for Health and Care Excellence must follow unless a deviation is explicitly justified. Its core requirements include an NHS and Personal Social Services (PSS) perspective, QALYs as the outcome measure, a specified discount rate for costs and health effects, and a lifetime (or sufficiently long) time horizon. Chapter 4 introduced the reference-case concept when it first discussed perspective and outcome choice; this is the same reference case, now tied to the specific body that issues it.

#heor-practice[
Think of ISPOR-SMDM as answering "is this model built well?" and the NICE reference case as answering "does this model meet *this* payer's specific rules?" A model can satisfy the first and still fail the second -- for example, by using a societal perspective where NICE requires an NHS/PSS perspective. Both checks matter, and they are not the same check.
]

Part IV does not re-litigate either framework chapter by chapter. Where a later chapter makes a choice -- a discount rate in Chapter 22, a validation step in a later audit chapter -- it will point back here rather than re-arguing the justification.

With the conceptual scaffolding in place, Chapter 18 starts building. Decision trees are the simplest model structure in the ISPOR-SMDM taxonomy from Section 17.2, and the next chapter constructs one from scratch in R: branches, probabilities, expected-value calculations, and the first full `run_model()` engine with real mechanics inside it.
