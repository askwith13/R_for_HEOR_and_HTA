#import "../common.typ": *

= Chapter 25. Handling Uncertainty

#learning-objectives((
  [Distinguish parameter, structural and methodological uncertainty from heterogeneity, and explain why each calls for a genuinely different handling (Briggs, Weinstein et al.'s ISPOR-SMDM Task Force-6 taxonomy).],
  [Conduct one-way and two-way deterministic sensitivity analysis and construct a tornado diagram that ranks parameters by their influence on net monetary benefit (NMB).],
  [Write a reusable R scenario-analysis script that re-runs a model under named, deliberately chosen parameter bundles, and distinguish this from both deterministic sensitivity analysis and probabilistic sensitivity analysis.],
  [Choose an appropriate probabilistic sensitivity analysis (PSA) distribution per HEOR parameter type -- Beta, Gamma/lognormal, Dirichlet, (multivariate) normal -- and assess Monte Carlo error via a convergence check.],
  [Build and interpret the four standard PSA visualisations: the cost-effectiveness plane, the CEAC, the CEAF, and the NMB distribution.],
  [Conduct a threshold analysis to solve for the breakeven value of a single parameter at which a model's ICER crosses a stated willingness-to-pay threshold.],
  [Explore structural uncertainty by building a genuine alternative model structure, and combine multiple structures into a single result via model averaging, distinguishing it from plain scenario reporting.],
  [Analyse patient-level trial cost and QALY data directly via the non-parametric bootstrap, correctly preserving within-patient cost-QALY correlation, and build a bootstrap cost-effectiveness plane and CEAC from real trial data.],
))

Chapters 17 through 24 built and extended a series of decision-analytic
and value-assessment models, each reporting a single headline result --
an ICER, a budget impact, an equity-weighted ICER, a severity-adjusted
ICER. Every one of those headline numbers was computed at one fixed set
of input values: the base case. This chapter turns from building models
to interrogating them, asking the question a single base-case result
can never answer on its own: how much should a decision-maker actually
trust that number, given that every input feeding into it is itself
uncertain, contested, or only approximately known? Chapter 19's §19.8
explicitly deferred part of this question here -- "Chapter 25 covers
the general conventions for choosing PSA distributions for different
parameter types" -- and this chapter delivers on that promise in full,
building on (not repeating) the Dirichlet and Cholesky machinery §19.8
already introduced for transition-matrix rows and correlated
parameters.

== 25.1 Types of uncertainty: parameter, structural, methodological and heterogeneity

Chapter 19's §19.8 flagged that whole transition-matrix rows need a Dirichlet distribution rather than independent Betas per cell, and promised that "Chapter 25 covers the general conventions for choosing PSA distributions for different parameter types." Before getting there (§25.3-§25.4), this section draws the conceptual map those conventions sit inside. "Uncertainty" in a HEOR model is not one thing -- treating all of it the same way is a common and consequential error, because the four kinds below call for genuinely different handling, and conflating them produces either wasted analytical effort or, worse, a misleading answer presented with false confidence.

The standard reference for this taxonomy is Briggs, Weinstein, Fenwick, Karnon, Sculpher and Paltiel's "Model Parameter Estimation and Uncertainty Analysis: A Report of the ISPOR-SMDM Modeling Good Research Practices Task Force-6" (*Value in Health*, 2012, and *Medical Decision Making*, 2012) -- the sixth instalment of the same ISPOR-SMDM Task Force series already relied on in this book for state-transition modelling (Chapter 19) and model transparency (§19.9). Task Force-6's Table 1 distinguishes stochastic (first-order) uncertainty, parameter (second-order) uncertainty, heterogeneity, and structural uncertainty, and separately flags methodological uncertainty as "a specific type that can be as important as parameter uncertainty." This section works through parameter, structural and methodological uncertainty, then heterogeneity -- deliberately last, because it is the one that is *not* uncertainty at all, and the contrast lands better once the other three are fresh.

=== Parameter uncertainty

*Parameter uncertainty* is imprecision in the estimate of a single input value -- a transition probability, a unit cost, a utility weight, a hazard ratio -- arising because that estimate was derived from a finite, noisy sample rather than observed with certainty on the whole population of interest. Task Force-6's own illustration is almost comically simple and exactly transferable to our running example: if you estimate the probability of "heads" from 100 coin flips, your estimate carries a standard error, and a different 100 flips would have given a slightly different number. The transition probability $p("OnTx" -> "Fail") = 0.08$ used throughout Chapter 19 is exactly this kind of quantity -- estimated from some finite number of trial or cohort patients, carrying a standard error (or, in the Dirichlet framing of §19.8, a pseudo-count strength) that a properly conducted sensitivity analysis must propagate.

Parameter uncertainty is the uncertainty type PSA is built to address, and the one that occupies the bulk of this chapter: §25.3 covers choosing a distribution family per parameter type, and §25.5 onward runs full probabilistic analysis over all of them jointly. It is also, not coincidentally, the uncertainty type with the cleanest and most mechanical fix -- more data narrows a standard error, in a way that no amount of additional data can resolve a *structural* disagreement about what the model should even look like.

#difficult-terminology("stochastic (first-order) uncertainty")[
Task Force-6 is careful to separate parameter uncertainty from a related but distinct idea: *stochastic* or *first-order* uncertainty, which is the randomness in what happens to one simulated patient (or one simulated run) even when every input parameter is held at a single, perfectly known value. Flip a fair coin whose true probability of heads you know exactly to be 0.5 -- the *outcome* of any one flip is still random; that randomness is stochastic uncertainty, not parameter uncertainty (there is nothing uncertain about the 0.5). A cohort Markov model like Chapter 19's, which moves a whole proportion of the cohort deterministically each cycle, has essentially no first-order uncertainty to speak of -- it only ever has one "run" for a given set of parameters. The individual-level microsimulation model of Chapter 21, by contrast, simulates one patient's random path through the model at a time, so re-running it with *identical* parameters still gives a slightly different cost and QALY total purely from random patient-path noise -- first-order uncertainty baked into the simulation mechanics, on top of (and conceptually separate from) whatever parameter uncertainty is layered over it. The practical consequence: assessing parameter uncertainty cleanly in a microsimulation requires enough replications (or enough simulated patients per PSA draw) that stochastic noise is averaged out before parameter uncertainty is read off the results -- otherwise the two sources of spread get tangled together in the output.
]

=== Structural uncertainty

*Structural uncertainty* is uncertainty about the *model itself* -- its shape, not its inputs. Task Force-6's Table 1 defines it as "the assumptions inherent in the decision model," with the companion statistical-modelling analogy of *model uncertainty*: the choice of a linear versus a log-linear regression form. In HEOR modelling, structural choices recur throughout this book's Part IV: whether to build a Markov cohort model or a partitioned-survival model for the same decision problem (Chapter 17 §17.2, revisited at the close of Chapter 19); which parametric survival distribution -- Weibull, log-logistic, generalised gamma -- to extrapolate a Kaplan-Meier curve with beyond trial follow-up (Chapter 10); which comparator set to include (does a cost-effectiveness analysis of the new TB regimen include only the current standard of care, or also a plausible but not-yet-standard alternative regimen); how many health states to use (the 4-state TB model collapses several clinically distinct failure modes into one "Treatment Failure" state); and whether to model a tunnel-state time-dependency explicitly (§19.6) or accept the time-homogeneous simplification.

Structural uncertainty cannot, in general, be resolved by collecting more of the *same kind* of data that resolves parameter uncertainty -- a thousand more patients will narrow the standard error on $p("OnTx" -> "Fail")$, but will not by itself tell you whether a Markov model or a partitioned-survival model is the right *shape* for the decision problem. The standard way of exploring it is *structural sensitivity analysis*: building genuine alternative model structures (not just alternative parameter values inside one fixed structure) and comparing results across them -- for instance, re-running the TB cost-effectiveness analysis with Weibull versus log-logistic extrapolation of the failure-to-cure transition, or with a 3-state collapsed structure versus the full 4-state one, and reporting whether the conclusion (does the new regimen remain cost-effective) is robust to the choice.

#heor-practice[
Bilcke, Beutels, Brisson and Jit's "Accounting for Methodological, Structural, and Parameter Uncertainty in Decision-Analytic Models: A Practical Guide" (*Medical Decision Making*, 2011) is a widely cited companion to Task Force-6, specifically because it works through *how* to handle structural and methodological uncertainty in practice -- not just how to name them. Their core practical recommendation, echoed in most HTA submission guidance since, is to run the full analysis (including PSA over parameter uncertainty) separately under each plausible structural or methodological variant, and present results as a small set of scenario analyses rather than trying to force structural disagreement into a single probability-weighted PSA draw the way parameter uncertainty is handled. A reviewer who sees a single base case with no structural scenario analysis at all, for a decision with a genuinely contested modelling choice, will usually ask for one before the submission can proceed.
]

=== Methodological uncertainty

*Methodological uncertainty* is narrower than structural uncertainty and easy to conflate with it: it is disagreement not about the model's internal structure, but about which *analytic convention* should be applied in deriving an outcome -- a choice that is more a matter of HTA-body policy or disciplinary convention than of clinical or biological fact. Task Force-6 flags it explicitly as "a specific type that can be as important as parameter uncertainty," while also noting the standard practical resolution: adopting a *reference case* -- a single fixed set of methodological conventions that a given HTA body requires every submission to follow as the base case, with methodological sensitivity analysis permitted around it but not substituting for it.

Concrete examples already seen earlier in this book: the discount rate applied to future costs and QALYs (Chapter 4 §4.6, revisited in Chapter 19 §19.5 -- NICE's reference case fixes 3.5% annually for both costs and effects, while other jurisdictions fix different rates, or differential rates for costs versus health effects); the analytic *perspective* taken (health-system-only costs versus a broader societal perspective that includes productivity loss and informal caregiving, a genuinely contested convention across agencies); the choice of utility-elicitation instrument and value set feeding into the QALY calculation (EQ-5D-3L versus -5L, and which country's tariff to apply); and whether a half-cycle correction is applied at all, and by which method (§19.5's life-table/trapezoidal default versus the cruder beginning/end alternatives). None of these is a biological fact to be estimated from more patient data -- they are conventions, and the "uncertainty" is really disagreement among analysts, agencies or jurisdictions about which convention governs.

#agency-note[
NICE's reference case is the canonical example of resolving methodological uncertainty by *fiat* rather than by probabilistic weighting: NICE does not ask a submitting company to place a probability distribution over "which discount rate is correct" and propagate it through PSA. It fixes the rate (3.5% annually, as used throughout Chapter 19) as a reference-case requirement, and treats departures from it as a scenario analysis to be justified separately, not as an input to the main probabilistic result. Other HTA bodies make different reference-case choices (differential discounting of costs versus QALYs is permitted in some jurisdictions, for instance), which is precisely why a model built for one agency's submission often cannot simply be re-run unmodified for another -- the methodological conventions, not just the clinical parameters, need re-checking against the target agency's own reference case.
]

=== Heterogeneity -- not a form of uncertainty

The fourth item in Task Force-6's taxonomy is the one most often mishandled, precisely because it looks superficially like parameter uncertainty but is not: *heterogeneity*. Task Force-6's Table 1 defines it plainly as "the variability between patients that can be attributed to characteristics of those patients" -- real, *explainable* differences in outcomes or costs across identifiable patient subgroups, as opposed to the imprecision of an estimate.

Concretely: suppose the probability of cure on the new TB regimen is genuinely higher in HIV-negative patients than in HIV-co-infected patients -- not because either estimate is poorly measured, but because the biology really does differ by HIV status, and a large enough dataset could pin down *both* subgroup-specific cure probabilities with arbitrary precision. That is heterogeneity: variation *explained by* a patient characteristic (HIV status), with each stratum's own value potentially known very precisely. Contrast this with parameter uncertainty: the *imprecision* in the estimate of cure probability *within* one of those strata (say, HIV-negative patients), which narrows as more HIV-negative patients are observed but which exists even for a single, homogeneous group.

#pitfall[
The classic and consequential error is treating heterogeneity as if it were parameter uncertainty -- running a single pooled model with cure probability sampled from one PSA distribution that spans the HIV-negative-to-HIV-co-infected range, rather than running the model *separately* for each subgroup with its own point estimate and its own (much narrower) parameter uncertainty. The two give superficially similar-looking "spread" in the output, but they mean completely different things and demand completely different decisions downstream. Genuine parameter uncertainty is resolved, in principle, by collecting more data on the *same* population -- it narrows a standard error. Heterogeneity is not resolved by more data on the pooled population at all; it is resolved by *subgroup analysis*, i.e. running the model once per relevant subgroup and reporting a cost-effectiveness result (and, where policy allows it, a reimbursement recommendation) *per subgroup*, exactly as a stratified clinical-trial analysis would. Folding real subgroup variation into a single PSA distribution and reporting one pooled "uncertainty interval" obscures a decision-relevant signal -- that the new regimen might be clearly cost-effective in one subgroup and clearly not in another -- behind what looks like ordinary statistical noise. A reviewer who understands this distinction will ask, pointedly, whether a wide one-way or probabilistic sensitivity range reflects genuine imprecision or unaddressed heterogeneity, and "we pooled across known subgroups and called it PSA" is not a defensible answer.
]

Table @tab-ch25-uncertainty-taxonomy summarises the four-way (really three-plus-one) distinction this section has built, together with how each is standardly addressed -- the handling column is the thread §25.2 onward in this chapter, and Chapter 26, pick up and develop in depth.

#ref-table(
  [Task Force-6's uncertainty taxonomy and standard handling, applied to the TB regimen-choice model],
  academic-table(
    columns: (1.1fr, 2fr, 1.6fr),
    align: (left, left, left),
    header: ([*Type*], [*What varies, and why*], [*Standard handling*]),
    body: (
      [Parameter], [Imprecision in a single input estimate (e.g. $p("OnTx"->"Fail") = 0.08 plus.minus "SE"$) from finite-sample estimation], [One-way/two-way DSA (§25.2) and probabilistic sensitivity analysis with a distribution per parameter type (§25.3-§25.6)],
      [Structural], [Which model shape or assumption set is correct (Markov vs partitioned survival, which survival distribution, which comparator set, how many health states)], [Structural sensitivity analysis: build and compare genuine alternative model structures, report whether conclusions are robust across them],
      [Methodological], [Which analytic convention governs (discount rate, perspective, utility value set, half-cycle method)], [Adopt the target HTA agency's reference case as base case; present departures as separate scenario analyses],
      [Heterogeneity], [Real, explainable variation across patient subgroups (e.g. by HIV status, disease severity) -- not an estimation problem at all], [Stratified subgroup analysis: run and report the model separately per subgroup, never pool into a single PSA distribution],
    ),
    footer: (table.cell(colspan: 3)[Taxonomy per Briggs, Weinstein, Fenwick, Karnon, Sculpher and Paltiel, "Model Parameter Estimation and Uncertainty Analysis" (ISPOR-SMDM Task Force-6, *Value in Health* / *Medical Decision Making*, 2012), Table 1; methodological-uncertainty handling per the same source and Bilcke et al. (2011).],),
  )
) <tab-ch25-uncertainty-taxonomy>

With the taxonomy in place, the rest of this chapter works through how each uncertainty type that *is* genuinely addressable by sensitivity analysis gets analysed in practice -- starting, next, with the deterministic methods: one-way and two-way sensitivity analysis and the tornado diagram that summarises them.

== 25.2 Deterministic sensitivity analysis: one-way, two-way, tornado plots

*Deterministic sensitivity analysis* (DSA) is the simplest family of techniques for exploring parameter uncertainty (§25.1): vary one input at a time (or two, jointly) across a plausible range, re-run the model at each value, and see how much the output -- typically the ICER or the net monetary benefit (NMB) -- moves. "Deterministic" here means each run uses a single fixed value per varied parameter, in contrast to the *probabilistic* sensitivity analysis of §25.5 onward, which draws many parameter values at once from a full joint distribution. DSA is less statistically complete than PSA -- it cannot, by construction, explore combinations of extreme values across many parameters at once, nor attach a probability to any particular outcome -- but it remains the standard first step in almost every HEOR model build, precisely because it is cheap to run, easy to communicate to a non-technical audience, and directly answers the question "which inputs actually matter to this decision?" before committing to the heavier probabilistic machinery.

#difficult-terminology("net monetary benefit (NMB)")[
Net monetary benefit converts a cost-and-QALY pair into a single number by multiplying QALYs by a willingness-to-pay (WTP) threshold $lambda$ (e.g. \$50,000 per QALY) and subtracting cost: $"NMB" = lambda times "QALYs" - "Cost"$. For comparing two strategies, the *incremental* NMB is $Delta"NMB" = lambda times Delta"QALY" - Delta"Cost"$ -- a positive incremental NMB means the new strategy is worth adopting at that threshold, a negative one means it is not, and the two framings (ICER versus incremental NMB) are mathematically equivalent decision rules at a given $lambda$. NMB has one concrete practical advantage that matters directly for this section: an ICER is a *ratio*, and ratios misbehave arithmetically when the denominator (the incremental QALY gain) is small or changes sign across a sensitivity range -- a swing from a small positive incremental QALY to a small negative one makes the ICER jump from a very large positive number to a very large negative one with no smooth transition, even though the underlying change in value is smooth and continuous. NMB has no such discontinuity (it is a simple linear combination, not a ratio), which is why most modern tornado diagrams -- including the one built in this section -- plot incremental NMB on the horizontal axis rather than the ICER.
]

=== One-way sensitivity analysis

A *one-way sensitivity analysis* (sometimes OWSA) takes a single parameter, holds every other parameter at its base-case value, and re-computes the model output across a plausible low-to-high range for that one parameter -- typically bounded either by the 95% confidence interval around the point estimate (if the parameter was estimated from data with a reported standard error) or by expert-elicited plausible bounds (if no data-derived interval exists, as is common for cost or convention-driven parameters). Repeating this independently, one parameter at a time, produces a set of (low output, base-case output, high output) triples -- one per parameter -- that is the raw material both for the summary table below and for the tornado diagram that visualises it.

=== Two-way sensitivity analysis

A *two-way sensitivity analysis* varies two parameters *jointly*, across a grid of their plausible ranges, while again holding all other parameters fixed at base case. This matters when a decision is sensitive to the *combination* of two inputs in a way that two separate one-way analyses cannot reveal -- for instance, the new TB regimen might remain cost-effective if its cure probability is pessimistic *and* its drug cost is optimistic, or if both are pessimistic together, but a one-way analysis on cure probability alone (holding cost at base case) and a separate one-way analysis on cost alone (holding cure probability at base case) will each individually look reassuring while hiding a genuinely unfavourable *joint* corner of the parameter space. Two-way analysis is reported either as a small grid table (as below) or, more commonly in published HTA submissions, as a cost-effectiveness-plane contour or heatmap showing which combinations of the two parameters cross the willingness-to-pay threshold -- the two-dimensional generalisation of the one-way tornado bar.

=== Tornado diagrams

A *tornado diagram* is the standard way of visualising and ranking a full set of one-way sensitivity results at once: one horizontal bar per parameter, each bar spanning from the output value at that parameter's low bound to its value at the high bound, all bars centred on (or anchored against) the base-case output, and the bars sorted from widest (top) to narrowest (bottom) -- the sorted order gives the characteristic funnel/tornado silhouette the name describes, and lets a reader see at a glance which handful of parameters actually drive the result, out of what might be a model with dozens of inputs.

#heor-practice[
A tornado diagram ranks parameters by the *width* of the swing they cause in the chosen output, not by how uncertain the parameter "feels" intuitively or by how precisely it happens to have been measured. A parameter with a narrow plausible range but a very steep effect on NMB per unit change can out-rank a parameter with a wide plausible range but a shallow effect -- the diagram is answering "how much does this input matter to the decision," not "how uncertain is this input," and the two questions have different answers. This is also exactly why a tornado diagram is a *screening* tool for PSA, not a substitute for it: a parameter that ranks low in a one-way tornado can still contribute materially to the overall decision uncertainty quantified later by PSA (§25.5) and VOI (Chapter 26), if several merely-moderate parameters move unfavourably together -- a joint effect no one-at-a-time ranking can show.
]

=== Worked example: one-way sensitivity analysis on the TB regimen-choice model

This example reuses Chapter 19's 4-state TB model (On Treatment, Cured, Treatment Failure, Death), simplified to the two-strategy comparison Chapter 17 set up: the 4-month rifapentine-moxifloxacin regimen ("New") against the 6-month standard daily regimen 2HRZE/4HR ("SoC"). Base-case per-six-month-cycle parameters for each arm, consistent with Chapter 19's §19.1 structure (On Treatment -> Cured / Fail / Death / stay; Fail -> OnTx retreatment $p=0.60$ / Death $p=0.15$ / stay; Cured -> Death $p=0.01$ / stay):

- SoC: $p("OnTx"->"Cured")=0.75$, $p("OnTx"->"Fail")=0.08$, on-treatment cost \$2,500/cycle, on-treatment utility 0.65.
- New: $p("OnTx"->"Cured")=0.80$, $p("OnTx"->"Fail")=0.05$ (the shorter regimen is assumed, per Study 31/A5349's non-inferiority finding referenced in Chapter 17, to achieve at least as good a cure rate with a lower failure rate, reflecting better completion), on-treatment cost \$1,800/cycle (shorter course, net of any price difference per dose), on-treatment utility 0.65 (unchanged -- being on either regimen is assumed equally burdensome per cycle).

Shared across both arms (from Chapter 19 §19.1, §19.5): $p("Fail"->"OnTx")=0.60$, $p("Fail"->"Death")=0.15$, $p("Cured"->"Death")=0.01$, Cured-state cost \$50/cycle and utility 0.90, Fail-state cost \$4,000/cycle and utility 0.40, 20 six-month cycles (10-year horizon), discounted at NICE's 3.5% annual rate ($r approx 0.01735$ per cycle, per §19.5), half-cycle correction applied, willingness-to-pay threshold $lambda = \$50,000$/QALY.

```r
run_tb_model <- function(p_ontx_fail, p_ontx_cured,
                          cost_ontx, cost_cured = 50, cost_fail = 4000,
                          util_ontx, util_cured = 0.90, util_fail = 0.40,
                          p_fail_retx = 0.60, p_fail_die = 0.15, p_cured_die = 0.01,
                          r = 0.01735, cycles = 20) {
  p_ontx_die  <- 0.02
  p_ontx_stay <- 1 - p_ontx_cured - p_ontx_fail - p_ontx_die
  stopifnot(p_ontx_stay >= 0)

  P <- matrix(c(
    p_ontx_stay,   p_ontx_cured, p_ontx_fail,               p_ontx_die,
    0,             1 - p_cured_die, 0,                      p_cured_die,
    p_fail_retx,   0,            1 - p_fail_retx - p_fail_die, p_fail_die,
    0,             0,            0,                          1
  ), nrow = 4, byrow = TRUE)
  stopifnot(all(abs(rowSums(P) - 1) < 1e-9))

  trace <- matrix(0, nrow = cycles + 1, ncol = 4)
  trace[1, ] <- c(1, 0, 0, 0)
  for (t in seq_len(cycles)) trace[t + 1, ] <- trace[t, ] %*% P

  cost_vec <- c(cost_ontx, cost_cured, cost_fail, 0)
  util_vec <- c(util_ontx, util_cured, util_fail, 0)
  total_cost <- 0; total_qaly <- 0
  for (t in seq_len(cycles)) {
    avg_occ <- (trace[t, ] + trace[t + 1, ]) / 2       # half-cycle correction
    disc <- 1 / (1 + r)^t
    total_cost <- total_cost + sum(avg_occ * cost_vec) * disc
    total_qaly <- total_qaly + sum(avg_occ * util_vec) * disc
  }
  list(cost = total_cost, qaly = total_qaly)
}

soc_base <- list(p_ontx_fail = 0.08, p_ontx_cured = 0.75, cost_ontx = 2500, util_ontx = 0.65)
new_base <- list(p_ontx_fail = 0.05, p_ontx_cured = 0.80, cost_ontx = 1800, util_ontx = 0.65)

WTP <- 50000

incremental_nmb <- function(soc_args, new_args) {
  soc <- do.call(run_tb_model, soc_args)
  new <- do.call(run_tb_model, new_args)
  WTP * (new$qaly - soc$qaly) - (new$cost - soc$cost)
}

base_nmb <- incremental_nmb(soc_base, new_base)   # $8,044 (independently verified in Python)
```

Running this base case (independently re-verified in Python) gives incremental cost $\$2{,}259.79 - \$3{,}103.93 = -\$844.14$ (New is *cheaper*) and incremental QALYs $13.2491 - 13.1051 = 0.1440$ (New is also more effective), so incremental NMB at $lambda = \$50{,}000$/QALY is $50000 times 0.1440 - (-844.14) = \$8{,}044$ -- New dominates SoC in the base case (cheaper *and* more effective), a reassuring but not yet uncertainty-tested starting point.

One-way sensitivity analysis then re-runs this same calculation five times, each time moving a single parameter to its low and high bound while holding everything else (including the other arm's parameters, where the varied input is arm-specific) at base case:

```r
owsa_bounds <- list(
  cure_prob   = list(lo = 0.70, hi = 0.90),   # New-regimen cure probability p(OnTx->Cured)
  fail_die    = list(lo = 0.10, hi = 0.20),   # shared p(Fail->Death)
  disc_rate   = list(lo = 0.015, hi = 0.05),  # annual discount rate
  drug_cost   = list(lo = 1200, hi = 2400),   # New-regimen on-treatment cost per cycle
  ontx_util   = list(lo = 0.55, hi = 0.75)    # shared on-treatment utility (both arms)
)

ann_to_cycle <- function(r_annual) (1 + r_annual)^0.5 - 1

owsa_cure_prob <- sapply(owsa_bounds$cure_prob, function(v)
  incremental_nmb(soc_base, modifyList(new_base, list(p_ontx_cured = v, p_ontx_fail = 0.05))))

owsa_fail_die <- sapply(owsa_bounds$fail_die, function(v)
  incremental_nmb(modifyList(soc_base, list(p_fail_die = v)),
                   modifyList(new_base, list(p_fail_die = v))))

owsa_disc_rate <- sapply(owsa_bounds$disc_rate, function(v)
  incremental_nmb(modifyList(soc_base, list(r = ann_to_cycle(v))),
                   modifyList(new_base, list(r = ann_to_cycle(v)))))

owsa_drug_cost <- sapply(owsa_bounds$drug_cost, function(v)
  incremental_nmb(soc_base, modifyList(new_base, list(cost_ontx = v))))

owsa_ontx_util <- sapply(owsa_bounds$ontx_util, function(v)
  incremental_nmb(modifyList(soc_base, list(util_ontx = v)),
                   modifyList(new_base, list(util_ontx = v))))
```

#pitfall[
Notice that three of these five parameters -- $p("Fail"->"Death")$, the discount rate, and on-treatment utility -- are varied *in both arms simultaneously*, while cure probability and drug cost are varied *only in the New arm*. This is not an arbitrary coding shortcut: it reflects which parameters are genuinely shared biological/convention quantities (a patient's risk of dying once in treatment failure, or the discount rate, does not plausibly differ by which regimen they are on) versus which are specific to the regimen being evaluated (the New regimen's own cure rate and drug cost are properties of that regimen, not of SoC). Varying a shared parameter in only one arm during a one-way sensitivity analysis is a genuine and easy-to-miss bug -- it manufactures an artificial incremental difference between the arms that has nothing to do with the parameter actually being tested, and can make a structurally irrelevant parameter look far more influential (or far less) than it really is.
]

Running this (independently re-verified in Python, not just described) gives the swings in Table @tab-ch25-owsa below, each row showing the incremental NMB at the parameter's low bound, its high bound, and the resulting swing width -- the quantity the tornado diagram ranks on.

#report-table(
  [One-way sensitivity analysis: incremental net monetary benefit (New regimen vs SoC) at low and high bounds per parameter, $lambda = \$50,000$/QALY, base-case incremental NMB = \$8,044],
  academic-table(
    columns: (1.6fr, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    header: ([*Parameter*], [*Low bound*], [*NMB at low*], [*NMB at high*], [*Swing*]),
    body: (
      [New-regimen cure probability $p("OnTx"->"Cured")$ \[0.70, 0.90\]], [0.70], [3,615], [11,560], [7,945],
      [$p("Fail"->"Death")$, shared \[0.10, 0.20\]], [0.10], [6,780], [9,148], [2,368],
      [Annual discount rate \[1.5%, 5%\]], [1.5%], [8,690], [7,615], [1,076],
      [New-regimen cost per cycle \[\$1,200, \$2,400\]], [\$1,200], [8,458], [7,631], [827],
      [On-treatment utility, shared \[0.55, 0.75\]], [0.55], [8,365], [7,723], [642],
    ),
    footer: (table.cell(colspan: 5)[All figures in US dollars of incremental net monetary benefit; positive throughout this range, so the New regimen remains favoured across every one-way scenario tested. Swing = |NMB at high bound - NMB at low bound|.],),
  )
) <tab-ch25-owsa>

The cure-probability swing (\$7,945) dwarfs every other parameter's swing by a factor of three or more -- unsurprising given that cure probability drives both the Cured-state QALY accrual *and* how much Fail/Death-state cost and QALY loss is avoided, a double lever that a single cost or utility parameter does not have. The discount rate, drug cost and on-treatment utility all cluster in a much narrower \$600-\$1,100 band, confirming the base-case conclusion (New dominates SoC) is not knife-edge sensitive to any of those three individually. Reassuringly, incremental NMB stays positive at *every* bound tested here -- the decision to prefer the New regimen does not flip within any of these one-way ranges, though the two-way analysis below checks whether a *joint* pessimistic scenario can still flip it, and full PSA (§25.5) is needed to attach an actual probability to "New remains preferred" once every parameter moves at once.

=== Worked example: two-way sensitivity analysis

The two most influential parameters from Table @tab-ch25-owsa -- New-regimen cure probability and New-regimen drug cost -- are varied jointly across a $3 times 3$ grid of their low/base/high values, holding every other parameter at base case:

```r
cure_grid <- c(0.70, 0.80, 0.90)
cost_grid <- c(1200, 1800, 2400)

twsa_grid <- outer(cure_grid, cost_grid, function(cure, cost) {
  mapply(function(c, k)
    incremental_nmb(soc_base, modifyList(new_base, list(p_ontx_cured = c, p_ontx_fail = 0.05, cost_ontx = k))),
    cure, cost)
})
dimnames(twsa_grid) <- list(cure = cure_grid, cost = cost_grid)
```

#ref-table(
  [Two-way sensitivity analysis: incremental NMB (\$) across joint cure-probability / drug-cost combinations, New regimen vs SoC],
  academic-table(
    columns: (auto, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Cure probability*], [*Cost \$1,200/cycle*], [*Cost \$1,800/cycle (base)*], [*Cost \$2,400/cycle*]),
    body: (
      [0.70 (low)], [4,124], [3,615], [3,106],
      [0.80 (base)], [8,458], [8,044], [7,631],
      [0.90 (high)], [11,898], [11,560], [11,222],
    ),
    footer: (table.cell(colspan: 4)[Every combination tested keeps incremental NMB positive (New regimen preferred); independently re-verified in Python alongside the one-way results above.],),
  )
) <tab-ch25-twsa>

Even in the worst joint corner tested -- low cure probability *and* high cost -- incremental NMB stays at \$3,106, comfortably positive. This is the genuine value a two-way analysis adds over two separate one-way analyses: it confirms directly that the two most influential parameters do not interact to flip the decision even at their *combined* pessimistic extreme, something the one-way table alone (which never varies them together) cannot show.

=== Constructing the tornado diagram

The standard tornado diagram plots each parameter's low-to-high NMB range as a horizontal bar, anchored at the base case and sorted by swing width -- in `ggplot2`, this is most cleanly built from a long-format data frame with one row per parameter per bound:

```r
library(ggplot2)
library(dplyr)

owsa_results <- tibble::tribble(
  ~parameter,                              ~low,  ~high,
  "New-regimen cure probability",          3615,  11560,
  "p(Fail -> Death), shared",              6780,   9148,
  "Annual discount rate",                  8690,   7615,   # note: low bound gives HIGHER NMB here
  "New-regimen cost per cycle",            8458,   7631,
  "On-treatment utility, shared",          8365,   7723
) %>%
  mutate(
    swing = abs(high - low),
    parameter = forcats::fct_reorder(parameter, swing)   # sort by swing for the funnel shape
  )

base_nmb <- 8044

ggplot(owsa_results, aes(y = parameter)) +
  geom_segment(aes(x = pmin(low, high), xend = pmax(low, high), yend = parameter),
               linewidth = 8, colour = "#4477AA") +
  geom_vline(xintercept = base_nmb, linetype = "dashed", colour = "grey30") +
  labs(x = "Incremental net monetary benefit ($, λ = $50,000/QALY)",
       y = NULL,
       title = "Tornado diagram: one-way sensitivity analysis, New TB regimen vs SoC") +
  theme_minimal()
```

// TODO-IMAGE: tornado diagram (ggplot2 horizontal bar chart, one bar per
// parameter, sorted by swing width descending, base-case NMB = $8,044 shown
// as a dashed vertical reference line) built from the owsa_results table
// above -- see progress/image_tracker.md Track 2 entry for this chapter.

#pitfall[
Two bars in the code above are built from `low`/`high` columns that are *not* consistently ordered -- the discount rate's "low" bound (1.5% annually) gives the *higher* NMB (\$8,690), because a lower discount rate means future QALY gains (which accrue mostly in the Cured state, reached mainly in later cycles) are discounted less, boosting their value disproportionately relative to up-front costs. A tornado-plotting script that blindly assumes "low parameter value always gives the low bar end" will silently mis-draw this bar backwards. The `pmin()`/`pmax()` wrapping in the `geom_segment()` call above is the fix -- it draws the bar between whichever end is numerically smaller and whichever is larger, regardless of which one came from the parameter's *low* versus *high* bound, and is standard defensive practice for any tornado-plotting code, not just this example.
]

This chapter's deterministic sensitivity analysis -- one-way (§25.2's five-parameter sweep), two-way (the cure-probability/cost grid), and the tornado diagram that ranks and visualises the one-way results -- is the standard first pass at parameter uncertainty (§25.1) before committing to full probabilistic sensitivity analysis. The next sections take up exactly that upgrade: §25.4 covers the conventions for choosing a PSA distribution per parameter type -- Beta for probabilities, gamma or lognormal for costs, Beta for utilities, lognormal or normal-on-the-log-scale for relative-effect estimates -- extending, rather than re-deriving, the Dirichlet and Cholesky machinery Chapter 19 §19.8 already built for whole transition-matrix rows and correlated parameters.

== 25.3 Scenario analysis scripts

Before turning to probabilistic sensitivity analysis (PSA), it is worth being precise about a distinct and often-confused technique: *scenario analysis*. A scenario analysis re-runs the model a handful of times, each time with one *named, deliberately chosen* set of parameter overrides -- "optimistic", "base case", "pessimistic", or a specific structural alternative such as "no second-line retreatment available" -- and reports a results table with one row per scenario. Nothing is random: every scenario is a single deterministic re-run, chosen by the analyst for a reason (a published guideline range, a plausible best/worst case, a payer's specific what-if question), not sampled from a distribution. PSA, covered from §25.4 onward, instead draws *thousands* of parameter sets at random from specified distributions and summarises the resulting spread. The two techniques answer different questions -- "what happens under these specific, named alternative assumptions?" versus "how much does my overall conclusion wobble under my stated uncertainty?" -- and a common and avoidable confusion is presenting a handful of scenario re-runs as if they were a PSA, or vice versa.

#difficult-terminology("scenario analysis vs. one-way/multi-way sensitivity analysis")[
Scenario analysis is close kin to, but not identical to, the one-way and multi-way deterministic sensitivity analyses familiar from earlier in this chapter (varying a single parameter across a range, or two parameters jointly across a grid, and reporting a tornado diagram or grid of ICERs). The distinguishing feature of a *scenario* is that it is a coherent, *named* bundle of simultaneous changes motivated by a real-world narrative -- "optimistic" might lower the failure probability *and* the cost of managing a failure *and* raise the cure utility all at once, because those three changes plausibly travel together under one story about how the disease and health system actually behave. A one-way sensitivity analysis instead moves exactly one parameter at a time, holding everything else at its base-case value, specifically to isolate that parameter's individual influence on the result -- the tornado-diagram logic. Both are deterministic (no randomness), and both are frequently reported side by side in a submission, but they serve different purposes: tornado diagrams for influence-ranking single parameters, scenarios for stress-testing coherent alternative narratives.
]

A reusable scenario-analysis script needs exactly three pieces: (1) a model function that takes one named list of parameters and returns the results of interest, (2) a named list of override lists -- one entry per scenario, each only specifying the parameters that scenario changes, leaving everything else at the base case -- and (3) a thin wrapper that loops over the scenarios, merges each override onto the base-case parameter list, runs the model, and stacks the results into one table. The merge step is the one piece of machinery worth getting right: R's built-in `modifyList()` does exactly this, replacing only the named elements present in the override and leaving every other base-case value untouched, which is both the mechanism that makes "specify only what changed" ergonomic and the thing that prevents a scenario accidentally reverting an unrelated parameter to some stale default.

We reuse Chapter 19's four-state TB Markov model (On Treatment, Cured, Treatment Failure, Death) as the model function, wrapped so it accepts a single parameter list rather than hard-coded literals:

```r
state_names <- c("OnTx", "Cured", "Fail", "Death")

build_P <- function(p_ontx_cure, p_ontx_fail, p_ontx_death,
                     p_fail_retreat, p_fail_death, p_cured_death) {
  p_ontx_stay  <- 1 - p_ontx_cure - p_ontx_fail - p_ontx_death
  p_fail_stay  <- 1 - p_fail_retreat - p_fail_death
  p_cured_stay <- 1 - p_cured_death
  P <- matrix(
    c(p_ontx_stay,   p_ontx_cure, p_ontx_fail,    p_ontx_death,
      0,              p_cured_stay, 0,            p_cured_death,
      p_fail_retreat, 0,           p_fail_stay,    p_fail_death,
      0,              0,           0,              1),
    nrow = 4, byrow = TRUE, dimnames = list(state_names, state_names)
  )
  stopifnot(all(abs(rowSums(P) - 1) < 1e-9))  # same defensive check as §19.1/19.3
  P
}

# The model function: takes ONE named list of parameters, returns discounted
# total cost and QALYs -- exactly the signature a scenario-analysis wrapper needs.
run_tb_model <- function(params, n_cycles = 20, disc_rate = 0.01735) {
  P <- build_P(params$p_ontx_cure, params$p_ontx_fail, params$p_ontx_death,
               params$p_fail_retreat, params$p_fail_death, params$p_cured_death)
  costs <- c(params$cost_ontx, params$cost_cured, params$cost_fail, 0)
  utils <- c(params$u_ontx, params$u_cured, params$u_fail, 0)

  trace <- matrix(NA_real_, n_cycles + 1, 4)
  trace[1, ] <- c(1, 0, 0, 0)
  for (t in seq_len(n_cycles)) trace[t + 1, ] <- trace[t, ] %*% P

  disc <- (1 + disc_rate) ^ -(1:n_cycles)
  c(total_cost = sum((trace[-1, ] %*% costs) * disc),
    total_qaly = sum((trace[-1, ] %*% utils) * 0.5 * disc))  # 0.5 yr per 6-month cycle
}
```

With the model wrapped this way, the scenario-analysis engine itself is a short, fully generic function -- it has no TB-specific code in it at all, and would work unmodified against any model function with the same "named list in, named vector out" signature:

```r
# Generic scenario-analysis engine: works with ANY model_fun(params) -> named vector
run_scenarios <- function(base_params, scenario_overrides, model_fun) {
  out <- lapply(names(scenario_overrides), function(nm) {
    p   <- modifyList(base_params, scenario_overrides[[nm]])  # override only the named cells
    res <- model_fun(p)
    data.frame(scenario = nm, as.list(res))
  })
  do.call(rbind, out)
}

base_params <- list(
  p_ontx_cure = 0.75, p_ontx_fail = 0.08, p_ontx_death = 0.02,
  p_fail_retreat = 0.60, p_fail_death = 0.15, p_cured_death = 0.01,
  cost_ontx = 500, cost_cured = 50, cost_fail = 800,
  u_ontx = 0.65, u_cured = 0.90, u_fail = 0.50
)

scenarios <- list(
  "Optimistic"  = list(p_ontx_cure = 0.85, p_ontx_fail = 0.05,
                        p_ontx_death = 0.01, cost_fail = 600),
  "Base case"   = list(),                       # empty override = pure base case
  "Pessimistic" = list(p_ontx_cure = 0.65, p_ontx_fail = 0.15,
                        p_ontx_death = 0.03, cost_fail = 1200)
)

scenario_results <- run_scenarios(base_params, scenarios, run_tb_model)
print(scenario_results)
```

Running this (independently re-verified in both R and a parallel Python re-implementation of the same matrix arithmetic, both agreeing to four decimal places) gives:

#report-table(
  [Scenario analysis: discounted total cost and QALYs, four-state TB Markov model, optimistic/base/pessimistic parameter bundles],
  academic-table(
    columns: (auto, auto, auto),
    align: (left, right, right),
    header: ([*Scenario*], [*Total discounted cost*], [*Total discounted QALYs*]),
    body: (
      [Optimistic],  [\$859.36],  [6.7431],
      [Base case],   [\$955.34],  [6.5795],
      [Pessimistic], [\$1,202.83], [6.3087],
    ),
    footer: none,
  )
) <tab-ch25-scenarios>

The pattern is exactly what §19.1's intuition predicts: the optimistic bundle (higher cure probability, lower failure and death probabilities, cheaper failure management) produces both lower cost and higher QALYs than base case, while the pessimistic bundle moves both in the unfavourable direction -- cost up, QALYs down. Note the base-case row reproduces §19.3-19.5's own figures to within the rounding already used there, which is itself a useful sanity check that the wrapped, parameterised model function has not silently changed the underlying arithmetic.

#heor-practice[
Keep the override list for each scenario as small as possible -- specify *only* the parameters that scenario's narrative actually changes, and let `modifyList()` carry every other value forward from the base case untouched. A common and hard-to-spot error is copy-pasting an entire parameter list for each scenario and hand-editing a few values: it is easy to miss updating one shared value when the base case itself is later revised, silently leaving an old, stale parameter baked into a scenario that should have inherited the update. The override-list-plus-`modifyList()` pattern makes "what did this scenario actually change" visible at a glance in the code, and guarantees every scenario automatically tracks any later base-case revision for everything it did not explicitly override.
]

#pitfall[
Resist the temptation to call a handful of scenario re-runs "the sensitivity analysis" and stop there. Scenario analysis answers "what if these specific things were different" for whichever alternative narratives the analyst thought to name -- it says nothing about the *full* joint uncertainty in every parameter simultaneously, and a payer or HTA body will typically expect both: named scenarios *and* a full probabilistic sensitivity analysis (§25.4-25.5). The two are complementary, not substitutes for one another.
]

== 25.4 Probabilistic sensitivity analysis: choosing distributions

Where §25.3's scenarios were deterministic, one-off re-runs under named alternative assumptions, *probabilistic sensitivity analysis* (PSA) asks a different question: given everything we believe about the *uncertainty* in each parameter (not just its point estimate), how uncertain is our overall conclusion? The mechanics are simple to state -- assign each uncertain parameter a probability distribution reflecting its estimated uncertainty, draw one value for every parameter simultaneously from those distributions, run the model, record the result, and repeat this thousands of times -- but the choice of *which* distribution to assign each parameter type is not arbitrary. This section sets out the standard conventions, delivering on the promise Chapter 19 §19.8 made when it said this chapter would cover "the general conventions for choosing PSA distributions for different parameter types (probabilities, costs, utilities, relative-effect estimates)".

*Probabilities and proportions (bounded 0-1): Beta.* Any parameter that is itself a probability or a proportion -- a transition probability, a diagnostic test's sensitivity, a drug's response rate -- is bounded between 0 and 1, and the $"Beta"(a, b)$ distribution is the standard choice precisely because it shares that same bound by construction: a Beta-distributed random variable can never fall below 0 or above 1, however extreme the sampled draw. §19.8's difficult-terminology box on conjugate posteriors already explained the deeper reason Beta is the natural choice when the underlying evidence is itself a count of successes and failures (e.g. $s$ cured out of $n$ treated): the Beta parameters $a$ and $b$ can be read directly as "pseudo-counts" of success and failure, so a published point estimate $hat(p) = s\/n$ with a reported standard error can be converted to Beta parameters via the method of moments, or directly from the raw trial counts when they are available (the cleanest and most defensible route, since it needs no approximation at all).

*Costs (right-skewed, non-negative): Gamma or lognormal.* A cost can never be negative, and empirically, cost data is almost always right-skewed -- most patients cluster around a typical cost, with a long tail of a few high-cost patients (an extended hospital stay, a rare complication) pulling the mean well above the median. The Gamma and lognormal distributions both share this non-negative, right-skewed shape and are the two standard choices; Gamma is more common in dedicated HEOR cost-effectiveness tooling (it is the choice `dampack`'s and `heemod`'s own PSA templates typically use for cost parameters) and is fully specified by a mean and standard error via the method-of-moments relationships $"shape" = (mu\/sigma)^2$, $"rate" = mu\/sigma^2$. Lognormal is the more natural choice when the underlying cost-generating process is itself understood to be multiplicative (costs accumulating as a product of several positive factors) or when the original data were analysed on the log scale, as is common for skewed resource-use regressions (Chapter 9).

*Utilities and transition-matrix rows: Beta or Dirichlet.* A single health-state utility value, like a probability, is conventionally bounded (though strictly a utility can occasionally exceed 1 for health states valued as better than full health, which some elicitation methods permit) and is typically assigned a Beta distribution for the same bounded-support reason as probabilities. A whole *row* of a transition matrix, however, is not a single bounded scalar but a *vector* of probabilities constrained to sum to exactly 1 -- and that is precisely the structural wrinkle Chapter 19 §19.8 already worked through in full: the Dirichlet distribution as the multivariate generalisation of Beta, parameterised by a vector of pseudo-counts (one per destination state), with `dampack::rdirichlet()` as the ready-to-use implementation, and the worked On-Treatment-row example with `alpha_ontx <- c(Cured = 75, Fail = 8, Death = 2, OnTx = 15)`. That material is not repeated here; the reader who has not yet internalised why independent per-cell Beta draws break the row-sums-to-1 constraint should revisit §19.8 before continuing, since everything below assumes that logic as given.

*Relative-effect estimates (log hazard ratios, log odds ratios): (log-)normal, often multivariate.* A relative-effect estimate from a trial or meta-analysis (Chapter 11) is almost always reported, and almost always *estimated*, on the log scale -- a hazard ratio's sampling distribution is better approximated by a normal distribution on the log-HR scale than on the natural HR scale itself, because the log transformation symmetrises what would otherwise be a skewed ratio distribution. The standard PSA convention is therefore to sample the *log* relative effect from a normal distribution using the reported point estimate and standard error (both already on the log scale in most trial/meta-analysis outputs, or convertible from a reported 95% confidence interval via $"SE" = ("log"("upper")-"log"("lower"))\/(2 times 1.96)$), then exponentiate the draw back to the natural HR/OR scale for use inside the model. When a trial or meta-analysis reports relative effects on *more than one* outcome simultaneously -- as Chapter 19 §19.8 flagged for our TB model's Cure and Failure relative-effect estimates, which are clinically plausible correlated rather than independent, since both are downstream of the same underlying treatment-response process -- a single multivariate normal distribution on the vector of log relative effects, built from the reported covariance matrix, is the standard device for carrying that correlation into PSA rather than discarding it.

#difficult-terminology("multivariate normal distribution")[
A univariate normal distribution describes the spread of a single uncertain quantity around its mean, governed by one number: its standard deviation. A *multivariate* normal distribution is the natural extension to *several* uncertain quantities sampled *jointly*, governed by a full covariance matrix rather than a single standard deviation -- the diagonal of that matrix gives each quantity's own variance (how spread out it is on its own), and the off-diagonal entries give the *covariances* between pairs of quantities (whether they tend to move together, apart, or independently). Sampling from a multivariate normal therefore produces a vector of correlated draws in one step, rather than several separate univariate draws that would, by construction, ignore any relationship between the quantities. This is exactly the tool needed whenever a reported relative-effect estimate on several outcomes comes with a reported covariance matrix (common for a multi-outcome meta-analysis), or whenever two or more PSA parameters are known on clinical or statistical grounds to be correlated rather than independent.
]

*Correlated parameters: why independent sampling is not always safe, and the Cholesky fix.* Sampling every PSA parameter independently is the default and the right choice whenever there is no specific reason to believe two parameters move together. But independence is an *assumption*, not a safe default in every case -- and Chapter 19 §19.8 already named the standard fix for when it fails: factorising a correlation or covariance matrix $Sigma$ via Cholesky decomposition as $Sigma = L L^T$, then transforming a vector of independent standard normal draws $z$ into correlated draws via $x_"correlated" = mu + L z$. A single call to base R's `chol()` performs the decomposition; `heemod`'s own PSA machinery uses the `mvnfast` package internally for exactly this multivariate-normal sampling step, as already noted in §19.8. The question of *when* this machinery is needed rather than plain independent sampling comes down to one test: is there a specific, stated reason (a reported covariance matrix, a known shared data-generating process, or a structural constraint like a transition-matrix row) to expect two parameters to covary? If yes, independent sampling will misrepresent the joint uncertainty -- understating it if the true correlation is positive (independent sampling can produce combinations that are jointly implausible, like a very favourable Cure effect paired with a very unfavourable Failure effect, when in reality the two track together), or overstating it if negative. If no, independent sampling is the simpler, defensible default.

#pitfall[
Do not conflate the Dirichlet machinery (§19.8, for whole transition-matrix rows that must sum to 1) with the Cholesky machinery (for correlated continuous normal/lognormal parameters). They solve different structural problems and are not interchangeable: trying to "correlate" Dirichlet-sampled transition-matrix rows using a Cholesky step designed for normal draws, or trying to force independent relative-effect parameters to sum to 1 with a Dirichlet, produces draws with no coherent probabilistic interpretation. Match the tool to the actual constraint the parameter is subject to.
]

#ref-table(
  [Standard PSA distribution choices by HEOR parameter type.],
  academic-table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    header: ([*Parameter type*], [*Standard distribution*], [*Why*]),
    body: (
      [Single probability/proportion], [Beta$(a, b)$], [Bounded support $[0,1]$; $a,b$ read directly as success/failure pseudo-counts],
      [Whole transition-matrix row], [Dirichlet$(alpha_1,...,alpha_k)$ -- see §19.8], [Multivariate generalisation of Beta; draws sum to 1 by construction],
      [Cost], [Gamma or lognormal], [Non-negative, right-skewed support matching empirical cost data shape],
      [Single utility value], [Beta (occasionally normal if $>1$ permitted)], [Bounded support matching utility's typical $[0,1]$ range],
      [Relative-effect estimate (log HR/OR)], [Normal on the log scale, exponentiated back], [Sampling distribution is symmetric on the log scale, skewed on the natural scale],
      [Correlated relative-effect estimates], [Multivariate normal via Cholesky (§19.8)], [Preserves a reported/assumed covariance structure instead of discarding it],
    ),
  )
) <tab-ch25-psa-distributions>

#difficult-terminology("Monte Carlo error")[
Monte Carlo error is the uncertainty introduced by the simulation process itself, separate from and additional to the genuine clinical/economic uncertainty the PSA is trying to characterise. Every PSA iteration is a random draw, so the *sample* of, say, 1,000 simulated ICERs is itself only an estimate of the *true* underlying distribution of the ICER given the parameter uncertainty -- run the same PSA again with a different random seed and the mean ICER, the CEAC curve, and every other summary statistic will come out slightly different purely by chance, even though nothing about the model or the input distributions changed. This is directly analogous to the ordinary sampling error familiar from any statistical estimate: more draws (just like a larger sample size in a trial) shrink Monte Carlo error, in the same square-root-of-n way standard errors generally shrink with sample size, but it never reaches exactly zero at any finite number of iterations.
]

*How many PSA iterations are "enough"?* There is no single universal number -- 1,000 iterations is a common minimum convention in practice, with 5,000 or 10,000 used routinely where the model is cheap enough to run that many times quickly, but the right answer is empirical, not conventional: run a *convergence check*. Track a summary statistic of interest (the mean incremental cost, the mean incremental QALY, or a specific point on the CEAC) as a running quantity across increasing numbers of iterations, and look for the point at which adding more iterations stops changing that running estimate by a practically meaningful amount -- the diminishing-returns point where Monte Carlo error has shrunk below whatever precision the decision actually needs. A PSA with too few iterations is detectable exactly this way: the running mean still visibly wobbles as more iterations are added, meaning the reported point estimate has not yet converged and a different random seed could plausibly have produced a materially different headline number.

We verify this logic end to end: first sampling a handful of PSA draws by hand to confirm the distributional parameterisation is correct, then running the full loop, then checking convergence.

```r
set.seed(42)

# --- Step 1: verify the logic on 5 hand-checkable draws before trusting a big loop ---

# Beta for a transition probability: p_ontx_fail, base-case mean 0.08.
# Parameterise via an assumed effective evidence strength of 100 pseudo-patients:
# a = 8 (observed-equivalent failures), b = 92 (observed-equivalent non-failures)
a <- 8; b <- 92
cat("Beta(a,b) mean check:", a / (a + b), "\n")        # 0.08 -- matches base case
print(rbeta(5, a, b))
# [1] 0.0638 0.0922 0.1027 0.0938 0.0767  -- scattered plausibly around 0.08

# Gamma for a cost: cost_fail, base-case mean $800, assumed SE $200
mean_c <- 800; se_c <- 200
shape <- (mean_c / se_c)^2; rate <- mean_c / se_c^2       # method-of-moments
cat("Gamma shape/rate:", shape, rate,
    " implied mean/sd:", shape / rate, sqrt(shape) / rate, "\n")  # 800, 200 -- matches
print(rgamma(5, shape = shape, rate = rate))
# [1] 1101.10  756.48  558.84 1053.15 1290.49 -- right-skewed scatter around 800, as expected

# Lognormal for a relative-effect estimate: a hazard ratio HR = 0.6 (log HR = -0.511),
# assumed SE on the log scale = 0.15
hr_draws <- exp(rnorm(5, mean = log(0.6), sd = 0.15))
print(hr_draws)
# [1] 0.487 0.575 0.588 0.660 0.575 -- scattered around 0.6, always positive by construction
```

Each hand-checked draw behaves exactly as the distributional choice intends: the Beta draws stay inside $(0,1)$ and scatter around the base-case 0.08; the Gamma draws stay positive and scatter around \$800 with a visible right skew (note the 1,290 draw well above the mean, with no symmetric counterpart far below); the lognormal draws stay positive and scatter around the HR of 0.6. With the logic confirmed on 5 draws, the full PSA loop is the same code at $n=2000$ instead of $n=5$, applied inside the TB model from §25.3:

```r
n_psa <- 2000
set.seed(123)

psa_p_fail    <- rbeta(n_psa, shape1 = 8, shape2 = 92)
psa_cost_fail <- rgamma(n_psa, shape = shape, rate = rate)   # shape/rate from the hand-check above

psa_results <- matrix(NA_real_, n_psa, 2, dimnames = list(NULL, c("cost", "qaly")))
for (i in seq_len(n_psa)) {
  p <- base_params                          # from §25.3
  p$p_ontx_fail <- psa_p_fail[i]
  p$cost_fail   <- psa_cost_fail[i]
  psa_results[i, ] <- run_tb_model(p)
}

cat("Mean cost:", mean(psa_results[, "cost"]), " Mean QALY:", mean(psa_results[, "qaly"]), "\n")
# Mean cost: 956.17   Mean QALY: 6.5779 -- matches §25.3's base case (955.34 / 6.5795) to
# well within Monte Carlo noise, exactly as it should: PSA means should recover the base
# case when (as here) every sampled parameter's distribution is centred on its base-case value

# Convergence / Monte Carlo error check: running mean at increasing iteration counts
for (n in c(100, 500, 1000, 1500, 2000)) {
  cat("N=", n, " mean cost=", mean(psa_results[1:n, "cost"]),
      " mean qaly=", mean(psa_results[1:n, "qaly"]), "\n")
}
# N=  100  mean cost= 954.93  mean qaly= 6.5795
# N=  500  mean cost= 955.90  mean qaly= 6.5780
# N= 1000  mean cost= 956.22  mean qaly= 6.5783
# N= 1500  mean cost= 956.59  mean qaly= 6.5772
# N= 2000  mean cost= 956.17  mean qaly= 6.5779
```

The running mean has essentially stopped moving by $N=1000$-$1500$ (cost fluctuating by under \$1 and QALYs by under 0.002 per 500 additional iterations) -- a textbook example of the diminishing-returns convergence pattern: 2,000 iterations is comfortably past the point where more draws materially change this particular model's headline summary statistics, for this particular pair of sampled parameters.

#heor-practice[
Report the number of PSA iterations used and, ideally, a brief convergence check (a running-mean plot, or the simple "mean at N/2 versus mean at N" table style shown above) directly in a submission's methods section. A reviewer who cannot tell whether 1,000 iterations was a deliberate, checked choice or an untested default has grounds to ask the sponsor to re-run at a higher iteration count -- a delay easily avoided by showing the convergence check was already done.
]

#pitfall[
A PSA built by copy-pasting the deterministic base-case model code and replacing a handful of fixed numbers with random draws is only as good as *every* parameter being correctly matched to a distribution that respects its real support. A normal distribution naively applied to a probability parameter, for instance, will occasionally sample a negative "probability" or one exceeding 1 -- syntactically a valid number, but nonsensical once fed into a transition matrix, and the kind of bug that can go unnoticed for a long time if the sampled parameter's influence on the final ICER is modest enough not to produce an obviously absurd result. Match the distribution family to the parameter's actual bounded or unbounded support every time, not just for the headline parameters most likely to be scrutinised.
]

== 25.5 Visualising uncertainty: CE plane, CEAC, CEAF, NMB distributions

A PSA produces one row per iteration -- incremental cost and incremental QALY (or total cost/QALY per strategy) for every one of the (say) 2,000 draws -- and four standard plots are the conventional way to communicate what that spread means for the decision. `dampack` and BCEA are the two CRAN packages purpose-built for exactly this (BCEA's real, CRAN-verified functions include `bcea()` to build the core analysis object, `ceac.plot()`, and `multi.ce()`/`ceaf.plot()` for the acceptability-frontier case with more than two strategies), but since neither package is installed in this environment, the code below builds each plot directly in `ggplot2` from a plain PSA results data frame -- the same underlying logic either package's convenience functions would compute internally, made explicit here so every number plotted is traceable back to the data frame feeding it.

Assume a PSA data frame `psa_df` with one row per iteration and columns `delta_cost` (incremental cost of the new strategy versus the comparator) and `delta_qaly` (incremental QALYs), built by running both strategies through §25.4's PSA loop and differencing:

```r
library(ggplot2)

# psa_df: one row per PSA iteration, columns delta_cost and delta_qaly
# (incremental cost/QALY of the new regimen minus the standard-regimen comparator)
```

*The cost-effectiveness (CE) plane.* Each PSA draw's incremental cost and incremental QALY is one point on a scatter plot, cost on the vertical axis and QALY gain on the horizontal axis. A willingness-to-pay (WTP) line through the origin with slope equal to the threshold divides the plane into "cost-effective" (below the line) and "not cost-effective" (above it) regions for every draw simultaneously.

```r
wtp <- 50000  # illustrative cost-effectiveness threshold, $/QALY

ggplot(psa_df, aes(x = delta_qaly, y = delta_cost)) +
  geom_point(alpha = 0.3, colour = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_abline(intercept = 0, slope = wtp, linetype = "dotted", colour = "firebrick") +
  labs(x = "Incremental QALYs", y = "Incremental cost ($)",
       title = "Cost-effectiveness plane") +
  theme_minimal()
```

// TODO-IMAGE: CE-plane scatter plot of PSA draws (delta_qaly on x, delta_cost on
// y), origin cross-hairs, and a WTP threshold line through the origin at
// slope = $50,000/QALY -- see progress/image_tracker.md Track 2 for this
// chapter's entry.

#difficult-terminology("cost-effectiveness acceptability curve (CEAC)")[
A single CE-plane scatter shows every PSA draw at once but does not directly answer the most common practical question: "for a given willingness-to-pay threshold, what fraction of the time does this intervention come out cost-effective?" The CEAC answers exactly that, as a curve: for each candidate WTP value $k$ along the horizontal axis, it plots the *proportion* of PSA draws for which that draw's own incremental net monetary benefit is positive (equivalently, for which $k times "incremental QALY" - "incremental cost" > 0$) on the vertical axis. A CEAC near 1 at a given $k$ means the intervention is cost-effective in nearly every simulated parameter combination at that threshold; a CEAC near 0 means it almost never is. The curve typically rises from near 0 (at very low WTP, few draws favour spending more for a QALY gain) toward 1 (at very high WTP, almost any QALY gain looks worthwhile) as $k$ increases, though the exact shape depends entirely on the joint distribution of the PSA draws.
]

```r
wtp_grid <- seq(0, 100000, by = 1000)
ceac_df <- data.frame(
  wtp  = wtp_grid,
  prob_ce = sapply(wtp_grid, function(k) {
    mean(k * psa_df$delta_qaly - psa_df$delta_cost > 0)   # share of draws with positive NMB at k
  })
)

ggplot(ceac_df, aes(x = wtp, y = prob_ce)) +
  geom_line(colour = "darkgreen", linewidth = 1) +
  labs(x = "Willingness-to-pay threshold ($/QALY)",
       y = "Probability cost-effective",
       title = "Cost-effectiveness acceptability curve (CEAC)") +
  ylim(0, 1) +
  theme_minimal()
```

// TODO-IMAGE: CEAC line plot, WTP threshold ($0-$100,000/QALY) on x, proportion
// of PSA draws cost-effective (0-1) on y -- see progress/image_tracker.md
// Track 2 for this chapter's entry.

#difficult-terminology("cost-effectiveness acceptability frontier (CEAF)")[
A CEAC as defined above is built for a *single* pairwise comparison (new intervention versus one comparator). With three or more competing strategies, each pair has its own CEAC, and a decision-maker's actual question shifts from "is this specific intervention cost-effective against this specific comparator" to "which of *all* the available strategies is most likely to be cost-effective, at this WTP threshold" -- the answer can switch from one strategy to another as the threshold itself moves. The CEAF traces, for every WTP value along the horizontal axis, the acceptability-curve *value of whichever strategy currently has the highest probability of being optimal* at that threshold -- it is therefore not one continuous strategy's curve throughout, but a composite built by taking, at each threshold, the upper envelope across every strategy's own curve. BCEA's `multi.ce()` computes exactly this for a `bcea` object with more than two strategies, feeding `ceaf.plot()`.
]

```r
# Illustrative 3-strategy CEAF sketch: psa_wide has one row per PSA iteration and
# one delta_qaly_X/delta_cost_X pair of columns per strategy X (vs a common reference)
strategies <- c("StandardRegimen", "ShortRegimen", "NewRegimenB")

ceaf_long <- do.call(rbind, lapply(wtp_grid, function(k) {
  nmb <- sapply(strategies, function(s) {
    mean(k * psa_wide[[paste0("delta_qaly_", s)]] - psa_wide[[paste0("delta_cost_", s)]] > 0)
  })
  data.frame(wtp = k, strategy = strategies, prob_best = nmb,
             is_frontier = nmb == max(nmb))
}))

ggplot(ceaf_long, aes(x = wtp, y = prob_best, colour = strategy)) +
  geom_line(alpha = 0.3) +                                   # each strategy's own CEAC, faint
  geom_line(data = subset(ceaf_long, is_frontier),
            aes(group = 1), colour = "black", linewidth = 1.2) +  # the frontier itself, bold
  labs(x = "Willingness-to-pay threshold ($/QALY)", y = "Probability most cost-effective",
       title = "Cost-effectiveness acceptability frontier (CEAF)") +
  theme_minimal()
```

// TODO-IMAGE: CEAF plot -- three faint per-strategy CEAC lines plus one bold
// frontier line tracing the upper envelope across WTP thresholds -- see
// progress/image_tracker.md Track 2 for this chapter's entry.

*Net monetary benefit (NMB) distribution.* Net monetary benefit converts a strategy's cost and QALY outcome into a single monetary figure at a chosen WTP threshold, $"NMB" = k times "QALY" - "cost"$, so that two strategies can be ranked by a single number instead of a cost/QALY pair. Because each PSA draw yields its own NMB value, the *distribution* of incremental NMB across all draws -- not just its mean -- is itself informative: a histogram shows at a glance both the central tendency (does the new strategy look favourable on average at this threshold) and the spread (how much of the distribution sits on the unfavourable side of zero).

```r
k <- 50000  # same WTP threshold as the CE-plane example
psa_df$inmb <- k * psa_df$delta_qaly - psa_df$delta_cost  # incremental NMB per draw

ggplot(psa_df, aes(x = inmb)) +
  geom_histogram(bins = 40, fill = "slateblue", alpha = 0.7) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "firebrick") +
  labs(x = "Incremental net monetary benefit ($)", y = "Count of PSA draws",
       title = "Distribution of incremental NMB at WTP = $50,000/QALY") +
  theme_minimal()
```

// TODO-IMAGE: incremental-NMB histogram across PSA draws at a single WTP
// threshold, with a vertical dashed reference line at zero -- see
// progress/image_tracker.md Track 2 for this chapter's entry.

#heor-practice[
Present all four views together, not just the headline ICER point estimate: the CE plane for the raw joint spread, the CEAC (and CEAF, if more than two strategies are compared) for the threshold-dependent probability of cost-effectiveness, and the NMB histogram for a single-threshold distributional summary. A payer asking "how confident should I be in this ICER" is really asking a CEAC-shaped question, and a bare point-estimate ICER with no PSA visualisation at all does not answer it.
]

== 25.6 Threshold analysis

A *threshold analysis* asks a narrower, more targeted question than a full PSA or scenario set: holding every other parameter at its base-case value, what is the breakeven value of *one specific* parameter at which the ICER crosses a stated willingness-to-pay threshold? It is the direct computational counterpart of Chapter 24 §24.5's value-based-pricing relationship -- that section already derived the rearranged ICER formula, $"price" = "threshold" times "incremental QALY" + "cost of comparator"$, as the general way to solve for the maximum acceptable price given a target ICER. Threshold analysis is that same algebraic move applied to whichever single parameter the question is actually about -- price, as in Chapter 24's example, but equally uptake, a relative-effect size, a cost offset, or any other single lever a decision-maker wants an explicit breakeven value for.

#difficult-terminology("threshold analysis")[
Threshold analysis should not be confused with a one-way sensitivity analysis that happens to vary the same parameter: a one-way sensitivity analysis reports the *ICER at each of several chosen values* of a parameter across some range, whereas a threshold analysis solves algebraically (or numerically, by search, when no closed form exists) for the *exact value* at which the ICER equals a specific target -- typically the decision-maker's willingness-to-pay threshold, but it could equally be set to match a competitor's price or any other benchmark value. The output of a threshold analysis is a single number with a precise interpretation ("at any price below \$X, this drug is cost-effective at our threshold; above it, it is not"), not a table or curve of ICERs across a range.
]

Reusing the TB Markov model and Chapter 24 §24.5's rearranged relationship directly: suppose the standard 6-month regimen comparator's discounted total cost and QALYs are the base case already computed in §25.3 (\$955.34 and 6.5795 QALYs), and a candidate 4-month short-course regimen is expected to deliver an incremental QALY gain of 0.15 (a smaller, more realistic illustrative benefit than the full scenario-level swing in §25.3's table, since this example isolates one parameter -- the new regimen's total cost, standing in for its price -- rather than bundling several changes together). At a willingness-to-pay threshold of \$50,000/QALY, what is the maximum total cost the new regimen could have and still be judged cost-effective?

Starting from the standard ICER definition and rearranging exactly as Chapter 24 §24.5 did for price:

$ "ICER" = ("cost"_"new" - "cost"_"comp") / ("qaly"_"new" - "qaly"_"comp") = "WTP" $

$ "cost"_"new" = "cost"_"comp" + "WTP" times ("qaly"_"new" - "qaly"_"comp") $

```r
cost_comp  <- 955.3441    # discounted total cost, standard regimen (base case, §25.3)
qaly_comp  <- 6.579512    # discounted total QALYs, standard regimen (base case, §25.3)
qaly_gain  <- 0.15        # incremental QALYs of the 4-month regimen vs standard (illustrative)
wtp        <- 50000       # willingness-to-pay threshold, $/QALY

cost_threshold <- cost_comp + wtp * qaly_gain
cost_threshold
# [1] 8455.344

# Verification: plug the threshold cost back into the ICER formula and confirm
# it reproduces exactly the WTP threshold used to derive it
icer_check <- (cost_threshold - cost_comp) / qaly_gain
icer_check
# [1] 50000   -- confirms the algebra: at this cost, the ICER sits exactly on WTP
```

#report-table(
  [Threshold analysis: breakeven total discounted cost for a 4-month TB regimen delivering a 0.15-QALY gain over the standard regimen, at WTP = \$50,000/QALY],
  academic-table(
    columns: (auto, auto),
    align: (left, right),
    header: ([*Quantity*], [*Value*]),
    body: (
      [Comparator discounted cost (standard regimen)], [\$955.34],
      [Comparator discounted QALYs], [6.5795],
      [Incremental QALYs (new regimen)], [0.15],
      [Willingness-to-pay threshold], [\$50,000 / QALY],
      [*Breakeven total discounted cost (new regimen)*], [*\$8,455.34*],
      [Verification: ICER at breakeven cost], [\$50,000 / QALY exactly],
    ),
    footer: none,
  )
) <tab-ch25-threshold>

Read this result the way Chapter 24 §24.5 read its own price-threshold relationship: any total discounted cost for the new 4-month regimen *below* \$8,455.34 produces an ICER under \$50,000/QALY and clears the stated threshold; any cost above it does not. The new regimen's actual costs (on-treatment resource use, drug acquisition price, management of any failures) are all free to vary in reality -- this single number is the combined ceiling all of those costs, taken together, must stay under. Exactly as in Chapter 24's value-based-pricing framing, this is the mirror image of an ordinary ICER calculation: instead of taking a fixed price and computing the resulting ICER, threshold analysis takes a fixed target ICER and solves backward for the price (or whichever single parameter is in question) that produces it.

#agency-note[
A threshold analysis reported to a payer or HTA body is only as informative as the choice of *which* parameter is varied to find the breakeven. Price or uptake thresholds are the most common because they map directly onto a negotiable commercial lever (Chapter 24 §24.5's managed-entry-agreement discussion), but a threshold can in principle be computed for *any* single parameter -- the minimum clinical effect size needed to be cost-effective at a given price, for instance, is exactly as valid a threshold analysis and is often the more scientifically informative framing when price is fixed (e.g. already set by an external reference-pricing regime) and the open scientific question is instead "how much clinical benefit would this treatment need to demonstrate."
]

#pitfall[
A threshold analysis holds every parameter *except* the one being solved for fixed at its base-case value -- which means the resulting breakeven number inherits all the same base-case uncertainty flagged by the PSA in §25.4-25.5. A breakeven price of \$8,455 computed against a base-case comparator cost and QALY figure is not a single fixed truth; it will itself shift if the comparator's own cost or QALY estimate moves, which is exactly why a threshold analysis is typically reported *alongside* a PSA, not as a replacement for one -- the threshold answers "what is the breakeven value at my point-estimate base case," while the PSA (and, in particular, its CEAC) answers "how confident should I be that a given fixed price clears the threshold once every parameter's uncertainty is accounted for simultaneously."
]

== 25.7 Structural uncertainty and model averaging

Section 25.1 already introduced *structural uncertainty* conceptually -- the uncertainty that comes not from imprecise parameter values but from genuinely different choices about how to represent the disease and treatment pathways, citing the Briggs/Weinstein-led ISPOR-SMDM Task Force-6 recommendations and Bilcke et al.'s (2011) practical-guide advice to run each structural variant as a complete, separate analysis and present the set as scenario analyses. This section makes that advice computational: it builds a genuine structural alternative to the running TB model, works through the arithmetic, and then goes one step further than simple scenario reporting into formal *model averaging*. The foundational reference for both ideas in this section is Bojke, Claxton, Sculpher and Palmer's "Characterizing Structural Uncertainty in Decision Analytic Models: A Review and Application of Methods" (*Value in Health*, 2009), which identifies model averaging and model selection as the two explicit methods for handling structural uncertainty, alongside the more common (and, per their own review, more defensible) practice of simply reporting alternative structures as scenarios.

=== Two structures for the same decision problem

The running model (Chapters 19, 25.2-25.3) has four states: On Treatment, Cured, Fail, and Death, with a distinct retreatment pathway in which a patient who fails treatment moves back into On Treatment ($p("Fail"->"OnTx") = 0.60$) rather than being absorbed directly. A modeller with a different clinical view of the care pathway might reasonably argue that this retreatment detail is not worth modelling explicitly, and collapse Fail straight back into a single death-or-stay transition -- removing the intermediate Fail-state cost and utility entirely. This gives a simpler *3-state* structure: On Treatment, Cured, Death, with the failure probability folded directly into an increased risk of death from On Treatment rather than routed through its own state.

#difficult-terminology("structural uncertainty vs. parameter uncertainty")[
Parameter uncertainty asks "given this model's shape, how sure am I of the numbers that go into it?" -- that is what PSA (§25.2-25.5) quantifies. Structural uncertainty asks a prior, harder question: "is this even the right shape of model?" Two analysts with identical, perfectly precise parameter estimates can still disagree about whether failed treatment should route through a separate Fail state or be folded directly into an increased mortality risk -- that disagreement cannot be resolved by running more PSA draws; it requires building and comparing genuinely different model structures.
]

Both structures answer the same decision question (New regimen vs SoC, the same 20 six-month cycles, the same discount rate, the same WTP threshold) -- which is exactly what licenses comparing, and later averaging, their results.

```r
# ---- Structure A: the book's running 4-state model (recap, §25.2-25.3) ----
# States, in order: OnTx, Cured, Fail, Death
build_trans_4state <- function(cure, fail, cost_ontx) {
  p_fail_death  <- 0.15
  p_fail_ontx   <- 0.60
  p_cured_death <- 0.01
  matrix(c(
    1 - cure - fail - 0.02, cure,               fail,                          0.02,
    0,                       1 - p_cured_death,  0,                             p_cured_death,
    p_fail_ontx,             0,                  1 - p_fail_ontx - p_fail_death, p_fail_death,
    0,                       0,                  0,                             1
  ), nrow = 4, byrow = TRUE)
}

# ---- Structure B: collapsed 3-state model ----
# States, in order: OnTx, Cured, Death
# "Fail" is removed as a distinct state: a cycle's worth of failure risk
# routes straight into an increased chance of death from On Treatment,
# and the Fail-state cost ($4,000/cycle) and utility (0.40) are never
# accrued separately in this structure.
build_trans_3state <- function(cure, fail, cost_ontx) {
  p_fail_death <- 0.15     # death risk conditional on failing, applied directly
  p_cured_death <- 0.01
  death_from_fail <- fail * p_fail_death
  matrix(c(
    1 - cure - death_from_fail, cure,               death_from_fail,
    0,                           1 - p_cured_death,  p_cured_death,
    0,                           0,                  1
  ), nrow = 3, byrow = TRUE)
}
```

Working through the 3-state structure's discounted cohort trace by hand (20 cycles, cycle length 0.5 years, discount rate $approx 0.01735$/cycle, half-cycle correction, On-Treatment cost \$2,500/cycle for SoC and \$1,800/cycle for New, Cured-state cost \$50/cycle, utility 0.65 on treatment and 0.90 cured) and independently re-verifying it in Python gives:

#report-table(
  [Headline result under the 3-state collapsed structure vs. the book's 4-state base case, New regimen vs SoC],
  academic-table(
    columns: (1.6fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Structure*], [*Inc. cost*], [*Inc. QALY*], [*Inc. NMB @ \$50,000*]),
    body: (
      [4-state (base case, §25.2-25.3)], [-\$844.14], [0.1440], [\$8,044.05],
      [3-state collapsed (this section)], [-\$676.70], [0.0936], [\$5,357.89],
    ),
    footer: (table.cell(colspan: 4)[Figures for the 4-state structure are the book's established base case. Figures for the 3-state structure were independently computed for this section by discounted cohort trace arithmetic, applying the same discount rate, half-cycle correction and 20-cycle horizon.],),
  )
) <tab-ch25-structural>

The *direction* of the conclusion is robust: under both structures the New regimen is cheaper and more effective, and incremental NMB is positive at the \$50,000/QALY threshold -- the headline recommendation would not change if a reviewer insisted on the simpler structure. The *magnitude*, however, is clearly not robust -- the simpler structure understates New's advantage by roughly a third, because collapsing Fail into a direct mortality risk removes the costly, low-utility Fail state from the ledger for both arms, and New's lower failure probability (0.05 vs 0.08) is precisely the parameter that structure is most sensitive to. This is exactly the kind of finding Bilcke et al.'s guidance anticipates: report both, and let the reader see how much the answer depends on structural choices.

=== From scenario analysis to model averaging

#difficult-terminology("model averaging")[
Simple scenario analysis, which the comparison above already is, runs each structure and reports the results *side by side* -- the reader sees two rows in a table and forms their own judgement about which to trust. *Model averaging* goes one step further: it assigns each structure an explicit plausibility weight and *combines* the structures' results into a single number using those weights. The output is not "here are two answers, you choose" but "here is one answer that already reflects how much we trust each structure." That is a materially stronger -- and, per Bojke et al.'s own review, more assumption-laden and more contested -- claim than plain scenario reporting, which is why the two should never be conflated.
]

If structure $k$ produces result $r_k$ (typically an NMB) and is assigned weight $w_k$ with $sum_k w_k = 1$, the model-averaged result is simply

$ r_"avg" = sum_k w_k dot r_k $

Weights can come from several places: formal statistical fit when structures are nested and can be compared by information criteria such as AIC or BIC, structured expert elicitation about which clinical pathway is more realistic, or -- when there is genuinely no basis to prefer one structure -- equal weights, which at least makes the averaging transparent about its own ignorance. As §25.2 established, NMB (not the ICER) is the quantity that behaves additively under this kind of combination -- an ICER is a ratio of two uncertain quantities and ratios do not average sensibly, whereas NMB is a single linear combination of cost and effect, so a weighted sum of NMBs is itself a meaningful NMB. This is why the worked example below averages NMB, not ICER.

Suppose, following expert judgement that the 4-state structure is clinically more realistic (it reflects how retreatment is actually managed) but the 3-state structure is not implausible, weights of 0.6 and 0.4 are assigned respectively:

```r
w_4state <- 0.6
w_3state <- 0.4

nmb_4state <- 8044.05    # book's base case, §25.2-25.3
nmb_3state <- 5357.89    # worked in this section

nmb_averaged <- w_4state * nmb_4state + w_3state * nmb_3state
nmb_averaged
# 0.6 * 8044.05 + 0.4 * 5357.89 = 4826.43 + 2143.16 = 6969.59
```

#report-table(
  [Model-averaged incremental NMB at WTP = \$50,000/QALY, combining the 4-state and 3-state structures],
  academic-table(
    columns: (1.6fr, auto, auto),
    align: (left, right, right),
    header: ([*Structure*], [*Weight*], [*Contribution to averaged NMB*]),
    body: (
      [4-state (clinically detailed)], [0.6], [\$4,826.43],
      [3-state (collapsed)], [0.4], [\$2,143.16],
    ),
    footer: (table.cell(colspan: 3)[Model-averaged NMB = \$4,826.43 + \$2,143.16 = \$6,969.59. Weights are illustrative expert judgements for this worked example, not an empirically elicited set.],),
  )
) <tab-ch25-averaging>

The model-averaged NMB of \$6,969.59 sits, as it must, between the two structure-specific values -- it is a single number a decision-maker could act on, already discounted for the possibility that the simpler structure is the more correct one.

#pitfall[
Model averaging only makes sense when the structures being averaged are answering the *same* decision question with genuinely comparable outputs. If one structure uses a 10-year horizon and another uses a lifetime horizon, or one reports QALYs and another reports life-years, a weighted average of their results is not a defensible blended estimate -- it is an average of two different questions dressed up as an average of one. Always check that the candidate structures share the comparators, the time horizon, the outcome definition and the discount rate before combining their results; if they do not, scenario analysis (reporting them side by side) is the honest choice, not model averaging. Bojke et al. (2009) go further still, noting that model averaging and model selection are each, for different reasons, "neither appropriate nor desirable" as a universal default -- their own preferred alternative, for cases where it is feasible, is to parameterise the structural choice itself as an explicit uncertain input inside a single unified model, so that structural and parameter uncertainty are propagated together rather than handled as two separate exercises bolted together after the fact. That more advanced approach is beyond this chapter's scope, but the caution behind it is not: treat model averaging as one option among several, not as the automatically "more sophisticated, therefore better" choice.
]

#agency-note[
Several HTA bodies treat structural choices as something to interrogate explicitly rather than average away by default: reviewers routinely ask for the rationale behind a chosen model structure and may request alternative-structure sensitivity analyses as a condition of acceptance, even when the submitted base case itself does not use model averaging. Treat the 3-state exercise above as representative of the kind of structural challenge a technical reviewer may raise, and keep the comparison on hand as a template for answering it.
]

== 25.8 Analysing patient-level cost-effectiveness trial data and bootstrapping

Everything so far in this chapter has quantified uncertainty in a *decision-analytic model* -- a Markov cohort simulation with parameters drawn from PSA distributions. This section covers a genuinely different situation: a randomised trial that collected cost and effectiveness data on individual patients, with no Markov model involved at all. The question becomes: given these raw patient-level cost and QALY observations, how is incremental cost-effectiveness -- and, just as importantly, its uncertainty -- estimated directly from the data?

=== Why trial-based CEA is different

Trial-based cost-effectiveness analysis differs from model-based CEA in three ways that matter for the statistics. First, costs and QALYs are *observed*, not simulated -- there is no generating distribution chosen by the analyst; the data are whatever actually happened to the patients recruited. Second, both costs and QALYs from real patients are typically right-skewed rather than normally distributed: most patients incur modest costs and achieve reasonable QALYs, but a minority have very high resource use (a hospitalisation, a complication) or very poor outcomes, stretching the right tail -- the same empirical skewness Chapter 9 already established for cost data generally. Third, and the point most often missed, cost and QALY are usually *correlated within the same patient*: a patient who does badly clinically (low QALY) often also consumes more healthcare resources (high cost), because poor outcomes and intensive treatment tend to travel together. Any analysis that treats a patient's cost and their QALY as if they were drawn independently throws away real information about how the two move together, and -- as the pitfall below demonstrates directly -- gets the uncertainty wrong as a result.

=== The non-parametric bootstrap

#difficult-terminology("non-parametric bootstrap")[
A *parametric* method -- including the PSA machinery used earlier in this chapter -- assumes the uncertain quantity follows some distributional *form* (a Normal, a Gamma, a Beta) and estimates that distribution's parameters from the data. The *non-parametric bootstrap* makes no such assumption: it treats the actual observed sample as a stand-in for the population, and estimates a sampling distribution purely by resampling the observed data itself, with replacement, over and over. Because trial cost data is awkwardly skewed and rarely fits a textbook distribution cleanly, letting the data speak for itself -- rather than forcing a distributional shape onto it -- is exactly what makes the bootstrap the standard default here. This is the same style of resampling-based reasoning Chapter 25 §25.4 used to check PSA convergence by iteration count, applied here to real patients instead of simulated parameter draws.
]

The mechanics, adapted for paired cost-QALY data, are: for each trial arm, resample $n$ patients with replacement from that arm's patients -- crucially, resampling whole *rows* (a patient's cost and QALY together), never the cost column and the QALY column separately. Recompute the arm's mean cost and mean QALY from the resampled rows. Do this for both arms to get one bootstrap replicate's incremental cost and incremental QALY, then convert to an ICER or incremental NMB for that replicate. Repeating this thousands of times builds up a distribution of plausible incremental cost-effectiveness results, which can be plotted directly on the cost-effectiveness plane introduced in §25.5 -- the difference being that every point here comes from resampling real trial patients, not from a PSA draw through a model -- and the proportion of bootstrap replicates below the WTP threshold line gives a CEAC built the same way as in §25.5.

```r
set.seed(321)

# ---- Step 1: simulate an illustrative patient-level trial dataset ----
# n = 150 per arm. A latent patient-level "engagement" factor links cost
# and QALY WITHIN each patient -- the within-patient correlation a real
# trial dataset would also show (commonly in the opposite direction:
# sicker patients cost more and do worse), but the mechanics of
# preserving that correlation in the bootstrap are identical either way.
simulate_arm <- function(n, mean_qaly_base, cost_base, qaly_slope, cost_slope) {
  engagement <- rnorm(n, 0, 1)
  qaly <- mean_qaly_base + qaly_slope * engagement + rnorm(n, 0, 0.04)
  qaly <- pmin(pmax(qaly, 0.1), 1.0)
  cost_mean <- pmax(cost_base + cost_slope * engagement, 200)
  cost <- rgamma(n, shape = 6, scale = cost_mean / 6)   # right-skewed
  data.frame(qaly = qaly, cost = cost)
}

trial_new <- simulate_arm(150, mean_qaly_base = 0.72, cost_base = 3200,
                           qaly_slope = 0.10, cost_slope = 700)
trial_soc <- simulate_arm(150, mean_qaly_base = 0.68, cost_base = 3000,
                           qaly_slope = 0.10, cost_slope = 700)

cor(trial_new$cost, trial_new$qaly)   # within-patient correlation, New arm
cor(trial_soc$cost, trial_soc$qaly)   # within-patient correlation, SoC arm

inc_cost_obs <- mean(trial_new$cost) - mean(trial_soc$cost)
inc_qaly_obs <- mean(trial_new$qaly) - mean(trial_soc$qaly)
icer_obs <- inc_cost_obs / inc_qaly_obs
nmb_obs  <- inc_qaly_obs * 50000 - inc_cost_obs
```

Independently reproducing this generating process (same structure, same seeded randomness) gives within-patient correlations of 0.42 (New arm) and 0.53 (SoC arm) -- genuinely correlated, not independent -- observed mean cost/QALY of \$3,082.13/0.7138 for New and \$3,007.59/0.6727 for SoC, an observed incremental cost of \$74.53 and incremental QALY of 0.0411, giving a naive ICER of \$1,812.91/QALY and incremental NMB at WTP \$50,000 of \$1,981.11 -- New costs very slightly more on average in this particular simulated sample but buys enough extra QALYs to be comfortably cost-effective at the threshold.

```r
# ---- Step 2: non-parametric bootstrap, B = 2000 replicates ----
B <- 2000
n_new <- nrow(trial_new)
n_soc <- nrow(trial_soc)

boot_inc_cost <- numeric(B)
boot_inc_qaly <- numeric(B)
boot_nmb      <- numeric(B)
wtp <- 50000

for (b in seq_len(B)) {
  # resample WHOLE ROWS, with replacement, independently per arm --
  # this is what preserves each patient's own cost-QALY pairing
  idx_new <- sample(seq_len(n_new), n_new, replace = TRUE)
  idx_soc <- sample(seq_len(n_soc), n_soc, replace = TRUE)

  boot_new <- trial_new[idx_new, ]
  boot_soc <- trial_soc[idx_soc, ]

  d_cost <- mean(boot_new$cost) - mean(boot_soc$cost)
  d_qaly <- mean(boot_new$qaly) - mean(boot_soc$qaly)

  boot_inc_cost[b] <- d_cost
  boot_inc_qaly[b] <- d_qaly
  boot_nmb[b]      <- d_qaly * wtp - d_cost
}

mean(boot_nmb)
quantile(boot_nmb, c(0.025, 0.975))
mean(boot_nmb > 0)   # bootstrap estimate of P(New is cost-effective at this WTP)
```

// TODO-IMAGE: cost-effectiveness plane scatter of boot_inc_cost (y) against
// boot_inc_qaly (x) for all 2000 bootstrap replicates, with the
// WTP=$50,000 threshold line overlaid -- the trial-data analogue of the
// PSA cloud built in §25.5, but from resampled real patients rather than
// model PSA draws -- see progress/image_tracker.md Track 2 for this
// chapter's entry.

Independently re-running this exact bootstrap procedure gives:

#report-table(
  [Bootstrap summary of incremental cost-effectiveness from the simulated trial dataset, $B = 2000$ replicates],
  academic-table(
    columns: (1.8fr, auto, auto),
    align: (left, right, right),
    header: ([*Quantity*], [*Bootstrap mean*], [*95% percentile CI*]),
    body: (
      [Incremental cost], [\$69.90], [(-\$261.61, \$412.28)],
      [Incremental QALY], [0.0406], [(0.0179, 0.0639)],
      [Incremental NMB @ \$50,000/QALY], [\$1,961.22], [(\$945.52, \$3,042.30)],
    ),
    footer: (table.cell(colspan: 3)[Computed by simulating patient-level trial data and running a row-preserving non-parametric bootstrap, as described in the main text; 100% of bootstrap replicates had positive incremental NMB -- i.e. this simulated trial indicates New is cost-effective at this threshold with high bootstrap-estimated confidence, matching the observed-sample ICER of \$1,812.91/QALY comfortably below the \$50,000 threshold.],),
  )
) <tab-ch25-bootstrap>

#heor-practice[
Writing the bootstrap loop by hand is not strictly necessary every time -- established packages for trial-based CEA, and general-purpose bootstrap packages, can perform the resampling and percentile-interval calculation directly. But understanding the loop above matters, because it is exactly what those packages are doing under the hood, and it is the fastest way to be certain rows, not columns, are what is being resampled.
]

#pitfall[
It is tempting, and surprisingly easy to do by accident, to resample the cost column and the QALY column *independently* -- for instance, calling `sample()` twice with two different random index vectors instead of one shared index vector per arm. Doing this breaks the within-patient pairing: a bootstrap replicate can end up combining the cost of one patient with the QALY of an entirely different patient, destroying the real within-patient correlation the correct procedure preserves. Re-running the exact simulation above with cost and QALY columns resampled independently rather than row-wise inflated the standard deviation of the bootstrap NMB distribution by roughly *17%* (from \$530.72 to \$619.18) and widened the 95% percentile interval outward on both sides (to roughly (\$783.80, \$3,174.88)) -- an artificially wider, wrong sampling distribution that overstates genuine uncertainty. The fix is mechanical and easy to check: always resample row *indices*, and use that same index vector to pull both the cost and the QALY for a given patient in a given replicate.
]

=== A parametric alternative, briefly

The non-parametric bootstrap is not the only way to analyse trial-level cost-effectiveness data. A parametric alternative models cost and QALY jointly -- for example with a seemingly-unrelated-regression approach that explicitly estimates the correlation between the two outcomes -- or uses *net-benefit regression*, the approach introduced by Hoch, Briggs and Willan ("Something Old, Something New, Something Borrowed, Something Blue: A Framework for the Marriage of Health Econometrics and Cost-Effectiveness Analysis", *Health Economics*, 2002), which reframes the whole problem as a single linear regression of net monetary benefit (computed per patient at a chosen WTP threshold) on a treatment-arm indicator: the regression coefficient on treatment arm *is* the incremental NMB estimate, with the convenient side benefit that other covariates (baseline severity, site, age) can be added to the same regression to adjust for imbalances between arms. This chapter does not develop net-benefit regression further, but it is worth knowing it exists as the natural next step once resampling alone no longer feels like enough.

This chapter's PSA machinery (§25.2-25.6) and this section's bootstrap machinery solve the same underlying problem from two different data sources -- a simulated model and a real trial -- but produce the same kind of output: a distribution of plausible incremental results from which a CEAC can be built. Chapter 26 picks up exactly where that distribution leaves off: Value of Information analysis (EVPI, EVPPI) is built directly on top of the PSA or bootstrap draws already generated here, asking not just "how uncertain are we?" but "how much would it be worth to reduce that uncertainty with more research?"
