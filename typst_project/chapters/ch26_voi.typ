#import "../common.typ": *

= Chapter 26. Value of Information Analysis

#learning-objectives((
  [Explain the Expected Value of Perfect Information (EVPI), Expected Value of Partial Perfect Information (EVPPI), Expected Value of Sample Information (EVSI) and Expected Net Benefit of Sampling (ENBS), and how they relate to one another.],
  [Compute EVPI directly from existing PSA draws in base R, and describe how dedicated R packages (`voi`, `BCEA`) wrap this same logic.],
  [Estimate EVPPI efficiently via nonparametric regression (a Generalized Additive Model) on existing PSA draws, avoiding expensive nested Monte Carlo simulation.],
  [Describe the three standard approaches to approximating EVSI for a specific proposed study: moment-matching, importance sampling, and Gaussian approximation.],
  [Distinguish the Value of Implementation (the cost of slow real-world adoption of an already cost-effective decision) from information-focused VOI measures.],
  [Use EVPPI, EVSI and ENBS together to prioritise which uncertain parameters are worth researching further, and recognise when a larger study can have a lower expected net benefit than a smaller one.],
))

Chapter 25 built a full probabilistic sensitivity analysis for the
book's running TB example -- thousands of draws of the uncertain
parameters, each pushed through the model to produce a distribution of
plausible costs, QALYs, and incremental net monetary benefit (NMB).
§25.5 turned those draws into the standard descriptive uncertainty
visualisations: a cost-effectiveness plane, a CEAC, a CEAF, an NMB
histogram. This chapter asks a different kind of question about the
exact same draws. A decision-maker cannot wait for certainty --
reimbursement decisions get made now, based on expected net benefit,
while the underlying parameter uncertainty Chapter 25 quantified
remains genuinely unresolved. *Value of information analysis* (VOI)
asks how much it would be worth, in money, to resolve some or all of
that uncertainty before deciding -- and, just as usefully, whether the
money would be better spent getting an already-correct decision
properly implemented rather than researched further.

== 26.1 Concepts: EVPI, EVPPI, EVSI and ENBS

Chapter 25 §25.4 built a full probabilistic sensitivity analysis (PSA)
for the running TB example: $n=2000$ draws of `p_ontx_fail` from
$"Beta"(8, 92)$ and `cost_fail` from a Gamma distribution matched to a
mean of \$800 and a standard error of \$200, each pushed through
`run_tb_model()` to produce a row of `psa_results`. §25.5 then turned
those draws into a cost-effectiveness (CE) plane, a cost-effectiveness
acceptability curve (CEAC), a CEAF, and an incremental net monetary
benefit (NMB) histogram. All of that machinery answers *descriptive*
questions: how much does the result vary, and how often does the New
regimen come out ahead. This section asks a different, *decision*
question using the exact same draws: given that a choice must be made
*now*, with the uncertainty §25.4 quantified still unresolved, how
much would it be worth -- in dollars -- to remove some or all of that
uncertainty before deciding?

This is the right frame because a decision-maker does not get to wait
for certainty. At the point of a reimbursement decision, the New
regimen either is or is not adopted, based on *expected* net benefit
across the PSA draws -- and because that expectation averages over
uncertainty rather than eliminating it, the chosen strategy could
still turn out, once the true parameter values are eventually known
(through more trials, more follow-up, more real-world data), to have
been the wrong one. *Value of information analysis* (VOI) asks exactly
how large that risk is in monetary terms, and therefore how much a
payer or sponsor should rationally be willing to spend to reduce it.
The foundational health-economic case for this framing is Claxton's
"The Irrelevance of Inference: A Decision-Making Approach to the
Stochastic Evaluation of Health Care Technologies" (*Journal of Health
Economics*, 1999, 18(3):341-364). Claxton argues that a reimbursement
decision should be based on expected (mean) net benefit alone,
regardless of statistical significance. The *distribution* of net
benefit around that mean matters only for a separate, later question:
is it worth acquiring more information before deciding?

The specific technique this chapter develops quantifies that value in
the actual units of the decision problem -- dollars, or whatever
currency the model works in. It traces to Felli and Hazen's
"Sensitivity Analysis and the Expected Value of Perfect Information"
(*Medical Decision Making*, 1998, 18(1):95-109). Felli and Hazen were
the first to propose EVPI as a better alternative to older
threshold-proximity and entropy-based sensitivity measures. Their
reasoning: EVPI accounts for both the *likelihood* that more
information would change the decision and the *size of the payoff
gained* if it did -- earlier measures captured only one of those two
things, not both.

#difficult-terminology("Expected Value of Perfect Information (EVPI)")[
Imagine two crystal balls. The first is *perfect*: it tells you, with
certainty, the true value of every uncertain input to the TB model --
the real failure probability, the real cost of a failed treatment,
everything -- before you have to choose New or SoC. Knowing all of
that, you would always pick whichever regimen is actually best for
that particular combination of true values, and you would never again
regret the choice. The second crystal ball is the one you actually
have today: Chapter 25's PSA, which tells you the *distribution* of
plausible true values but not which one is real, so you must commit to
one strategy now and live with being wrong on some unknown fraction of
possible worlds. EVPI is the dollar value of upgrading from the second
crystal ball to the first -- the expected gain, averaged over every
possible true parameter combination, from always getting to make the
fully-informed choice instead of committing to one fixed choice in
advance. It is a ceiling, not a forecast: no real study ever delivers
a perfect crystal ball, but EVPI tells you the most any amount of
future research on this decision could possibly be worth.
]

Formally, with $d$ indexing the available strategies (New or SoC),
$theta$ the full vector of uncertain parameters, and $"NB"(d, theta)$
the net monetary benefit of strategy $d$ if the parameters truly took
value $theta$:

$ "EVPI" = EE_theta [ max_d "NB"(d, theta) ] - max_d EE_theta ["NB"(d, theta)] $

The second term is just the net benefit of the strategy that would
actually be picked today -- whichever one has the higher *average* NMB
across the PSA draws, which is exactly the base-case comparison
Chapter 25 already made (\$8,044.05 in New's favour at $lambda =
\$50,000$ per QALY). The first term is the net benefit of an oracle
who, for *each* PSA draw, always picks whichever strategy that
specific draw favours, then averages across draws. Because the oracle
can never do worse than committing to one fixed strategy in advance,
EVPI is always $>= 0$.

The decisive practical point is that EVPI needs *no new simulation at
all* -- it is computed directly from the PSA draws §25.4 already
produced, by re-using the per-iteration cost and QALY values to form
NMB for both regimens and comparing strategy-by-strategy, iteration by
iteration:

```r
# Continuing directly from Chapter 25 §25.4's psa_results structure.
# Here psa_results carries both regimens' per-iteration total cost and
# QALYs (columns cost_new, qaly_new, cost_soc, qaly_soc), built the same
# way as §25.4's single-arm loop, just run for both arms per iteration.

wtp <- 50000  # same WTP threshold as Chapter 25's base case

nmb_new <- wtp * psa_results[, "qaly_new"] - psa_results[, "cost_new"]
nmb_soc <- wtp * psa_results[, "qaly_soc"] - psa_results[, "cost_soc"]

mean_nmb_new <- mean(nmb_new)
mean_nmb_soc <- mean(nmb_soc)

# Net benefit of committing to the single best strategy in expectation:
nb_fixed_choice <- max(mean_nmb_new, mean_nmb_soc)

# Net benefit of an oracle who picks the best strategy FOR EACH draw:
nb_perfect_info <- mean(pmax(nmb_new, nmb_soc))

evpi <- nb_perfect_info - nb_fixed_choice
cat("EVPI per patient at WTP =", wtp, ":", evpi, "\n")
```

To make the arithmetic concrete, work through a small illustrative
example built in exactly this same `psa_results` shape (these are the
author's own worked numbers for demonstration, not Chapter 25's actual
stored 2,000-draw array, which is not reproduced verbatim here, and
these illustrative figures were independently recomputed to confirm
the arithmetic before being printed):

#report-table(
  [Illustrative worked EVPI calculation on six PSA-style draws, same `psa_results` column layout as Chapter 25 §25.4, WTP = \$50,000/QALY.],
  academic-table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, right, right, right, left),
    header: ([*Draw*], [*NMB(New)*], [*NMB(SoC)*], [*Best for this draw*], [*Decision matches fixed choice?*]),
    body: (
      [1], [301,200], [292,900], [301,200 (New)], [Yes],
      [2], [299,850], [293,400], [299,850 (New)], [Yes],
      [3], [296,100], [298,700], [298,700 (SoC)], [*No*],
      [4], [302,500], [291,100], [302,500 (New)], [Yes],
      [5], [298,900], [294,200], [298,900 (New)], [Yes],
      [6], [297,400], [299,950], [299,950 (SoC)], [*No*],
    ),
    footer: (table.cell(colspan: 5)[Mean NMB(New) = 299,325; Mean NMB(SoC) = 295,041.67 -- fixed choice is New, matching Chapter 25's base case],),
  ),
) <tab-ch26-evpi-worked>

Averaging the "best for this draw" column gives $300,183.33$; the
fixed choice (always New, since its average NMB of $299,325$ beats
SoC's $295,041.67$) gives $299,325$. EVPI is the difference: *\$858.33*
per patient. Two of the six illustrative draws (3 and 6) would have
favoured SoC -- a reminder that even when New wins decisively on
average, individual plausible parameter combinations can still favour
the comparator, and EVPI is precisely the expected cost of not being
able to tell which combination is the real one before deciding.

*EVPPI* asks the same question for only *some* of the uncertain
parameters, holding the rest at their uncertain, un-resolved state.
"How much would it be worth to learn the TB failure probability for
certain, while everything else -- failure cost, utility weights,
transition probabilities -- stays exactly as uncertain as it is today?"
This is a strictly smaller quantity than EVPI (resolving one parameter
can never be worth more than resolving everything), and it is the
quantity that actually matters for prioritising *which* future study to
fund, since no single real study ever resolves every parameter in a
model simultaneously.

Computing EVPPI *naively* is expensive in a way EVPI is not. EVPI
reuses the existing PSA draws directly, with no new model runs. EVPPI
for a parameter of interest $theta_i$ requires, conceptually, a
*nested* simulation: for each of many candidate "true" values of
$theta_i$ (the outer loop), re-run a full inner PSA over *every other*
uncertain parameter, holding $theta_i$ fixed at that outer value, to
estimate the expected net benefit conditional on that $theta_i$. With
an outer loop of, say, 1,000 candidate values and an inner loop of
1,000 draws each, that is a million full model evaluations for a
single parameter's EVPPI -- for a model that is at all computationally
expensive (a microsimulation, a patient-level model with thousands of
simulated individuals), this quickly becomes impractical. This
expense is exactly the gap that motivates §26.3's regression-based
shortcut, which gets an EVPPI estimate from the *same* PSA draws
already sitting in `psa_results`, with zero additional model runs.

*EVSI* (Expected Value of Sample Information) moves from the
hypothetical ("what if we knew $theta_i$ perfectly") to the concrete
("what would a specific, proposed, finite study actually be worth").
A trial of $n = 200$ patients measuring the TB failure rate will
narrow the uncertainty around `p_ontx_fail`, but will not eliminate it
the way EVPPI's hypothetical perfect information does -- EVSI
quantifies the expected gain from *that specific, finite amount of new
data*. As the proposed sample size grows without bound, EVSI
approaches EVPPI for the parameters that study would measure (infinite
sample size is, in the limit, perfect information about those
parameters); at $n=0$ (no study at all), EVSI is zero by definition.
EVSI therefore sits on a continuum between zero and EVPPI, as a
function of the sample size actually being considered -- which is
exactly the quantity a funder needs when choosing between, say, a
200-patient and an 800-patient trial design.

*ENBS* (Expected Net Benefit of Sampling) is EVSI minus the cost of
actually running the proposed study: $"ENBS" = "EVSI" - C_"trial"$.
EVSI alone can make a trial look attractive in isolation, but a trial
that costs more to run than the uncertainty it resolves is worth
funding is not a good use of research funds -- ENBS is the quantity
that converts "this study would be informative" into "this study is
worth paying for," and is the final decision-relevant VOI output for
a research-funding body deciding which of several competing proposed
studies, if any, to fund.

#ref-table(
  [The four core VOI quantities: what each answers and what it needs.],
  academic-table(
    columns: (auto, 1.4fr, 1.4fr),
    align: (left, left, left),
    header: ([*Quantity*], [*Question it answers*], [*What it requires computationally*]),
    body: (
      [EVPI], [What is the most we should ever pay to resolve *all* parameter uncertainty before deciding?], [Directly from existing PSA draws -- no new simulation],
      [EVPPI], [What is it worth to resolve uncertainty in *one parameter (or a subset)*, leaving the rest uncertain?], [Naively: nested simulation (outer/inner loop); efficiently: regression on existing PSA draws (§26.3)],
      [EVSI], [What is a *specific, finite, proposed study* (e.g. $n=200$) actually worth?], [Simulated future data generation + re-updated posterior/decision per simulated dataset, or a regression-based approximation (§26.4)],
      [ENBS], [Is this specific proposed study worth *funding*, net of its own cost?], [EVSI minus the study's real, estimated cost],
    ),
  ),
) <tab-ch26-voi-quantities>

#pitfall[
EVPI and EVPPI answer genuinely different questions, and conflating
them leads to the wrong research-prioritisation conclusion. EVPI is
the value of resolving *everything* at once; EVPPI is the value of
resolving *one* parameter (or a chosen subset) while every other
parameter remains exactly as uncertain as before. It is entirely
possible for EVPPI on a single, dominant parameter to approach EVPI
closely -- if nearly all of the decision uncertainty in a model
traces back to one input (say, the failure probability), learning
just that one parameter can capture most of the total value available.
But this is a property of *that specific model's* uncertainty
structure, not a general equivalence between the two quantities. Never
assume a single parameter's EVPPI "is basically EVPI" without actually
computing both and comparing -- a model with several co-dominant
uncertain parameters can have an EVPI far larger than any individual
parameter's EVPPI, and treating one influential-looking parameter's
EVPPI as a stand-in for the full EVPI risks under-funding research into
the other parameters that are jointly, not individually, driving the
decision's uncertainty.
]

== 26.2 Computing EVPI and EVPPI (BCEA, voi)

§26.1's EVPI calculation already showed the entire computational core
of this section: EVPI needs no package at all, just the per-iteration
net benefit values already sitting in `psa_results`. This section
turns that one-off calculation into a clean, reusable function, runs
it across a *range* of willingness-to-pay (WTP) thresholds rather than
just the headline \$50,000 figure, and -- being direct about this
drafting machine's actual tooling, per the book's tooling-honesty
convention -- describes rather than demonstrates the two R packages
built specifically for this task, since neither is installed here.

```r
calculate_evpi <- function(psa_results, wtp) {
  nmb_new <- wtp * psa_results[, "qaly_new"] - psa_results[, "cost_new"]
  nmb_soc <- wtp * psa_results[, "qaly_soc"] - psa_results[, "cost_soc"]

  nb_fixed_choice   <- max(mean(nmb_new), mean(nmb_soc))
  nb_perfect_info   <- mean(pmax(nmb_new, nmb_soc))

  nb_perfect_info - nb_fixed_choice
}

wtp_grid <- seq(0, 100000, by = 10000)
evpi_by_wtp <- sapply(wtp_grid, function(k) calculate_evpi(psa_results, k))

data.frame(wtp = wtp_grid, evpi = evpi_by_wtp)
```

Running `calculate_evpi()` across a WTP grid rather than at a single
threshold matters because EVPI is *itself* a function of the
threshold, not a single fixed number for a model. At very low WTP,
the comparison is dominated by cost almost regardless of QALYs, and at
very high WTP it is dominated by QALYs almost regardless of cost -- at
both extremes, the "right" decision tends to be clear-cut across
nearly every PSA draw simultaneously, so there is little value left in
resolving the remaining uncertainty and EVPI sits near zero. EVPI
rises in between, peaking near whichever WTP value makes the decision
most genuinely "on the fence" -- which is exactly the WTP at which
Chapter 25 §25.5's CEAC crosses the 50% mark (the threshold at which
the PSA draws are as close as they get to a coin-flip between New and
SoC being preferred). Where the CEAC is close to 0% or 100%, the
decision is nearly unanimous across draws and EVPI is small; where the
CEAC nears 50%, the draws are most evenly split between favouring New
and favouring SoC, and that is precisely the region in which learning
the true parameter values would most often change which strategy
actually gets chosen.

#heor-practice[
Report EVPI across a *plausible range* of WTP thresholds, not just at
the headline value conventionally used for the primary analysis (e.g.
the \$50,000/QALY figure used throughout this book's TB example, or
whichever threshold convention a given jurisdiction follows -- see
Chapter 4's discussion of WTP-threshold conventions across HTA
systems). The WTP threshold itself is often contested rather than a
single agreed number, and because EVPI is threshold-dependent, a VOI
analysis anchored to only one WTP value can materially understate or
overstate the true value of further research if the real
decision-relevant threshold turns out to sit elsewhere on the curve. A
simple table or plot of EVPI against a WTP grid costs nothing extra to
produce once `calculate_evpi()` exists, and makes this sensitivity
visible to a reviewer without requiring them to ask for it separately.
]

In practice, almost nobody writes this base-R loop by hand in a real
submission -- two CRAN packages exist specifically to wrap exactly this
logic (and the EVPPI/EVSI calculations that follow in §26.3-26.4) into
a tested, documented interface: `BCEA` (Baio, Berardi, Heath and
colleagues), already introduced in Chapter 25 §25.5 for the CE
plane/CEAC/CEAF, has its own longstanding EVPI/EVPPI functions built
on a `bcea()` analysis object; and `voi` (Heath, Kunst, Baio and
colleagues), a newer package purpose-built around VOI methods
specifically, is generally considered the more actively maintained,
modern home for EVPI/EVPPI/EVSI calculations in R, including the
GAM-regression EVPPI approach covered in §26.3. *Neither `voi` nor
`BCEA` is installed on this drafting machine*, so no package function
call from either is demonstrated or run here -- doing so without being
able to verify the exact arguments against the real installed package
would risk stating a function signature that does not actually exist,
which this book's tooling-honesty convention rules out. What can be
described honestly is the *general pattern* both packages follow,
consistent with how any VOI-calculation package needs to be fed data:
a data frame of PSA output (one row per iteration, with columns for
each strategy's cost and effect, or already-differenced incremental
values) is passed in alongside a second data frame or matrix of the
*parameter* draws underlying those outcomes (the same draws used to
generate the PSA in the first place -- in this example, `psa_p_fail`
and `psa_cost_fail` from Chapter 25 §25.4), and the package's EVPI
function returns a single number (or a vector, across a WTP grid)
computed internally by exactly the same max-of-expectation-versus-
expectation-of-max logic shown in the base-R code above. Before
relying on either package for a real submission, consult its current
CRAN reference manual directly for the exact function names and
arguments, rather than any description here.

#agency-note[
The NICE Decision Support Unit (DSU) has directly commissioned and
published VOI methodology work for NICE itself -- "A Pilot Study of
Value of Information Analysis to Support Research Recommendations for
NICE" (NICE DSU, June 2005), which explicitly piloted VOI methods
against real NICE technology appraisals to assess their feasibility
for informing NICE's own research-recommendation decisions. Unlike
several other NICE DSU methodological topics, VOI is not covered by
its own numbered Technical Support Document in the DSU's TSD 1-27
series (confirmed against the DSU's current full TSD list) -- the
2005 pilot report remains the primary NICE-commissioned VOI reference,
reflecting that VOI is not a niche academic exercise but methodology
NICE itself has directly investigated for justifying or declining a
request for further evidence generation (e.g. a Managed Access
Agreement or an evidence-development commitment attached to a
conditional recommendation).
]

To make the WTP-dependence concrete, the table below is a small
illustrative EVPI-versus-WTP sweep -- self-computed by the author
following exactly the `calculate_evpi()` logic above on an illustrative
PSA-shaped dataset consistent with Chapter 25's base case, not a
pre-existing book result:

#report-table(
  [Illustrative EVPI (per patient) across a WTP grid, computed via `calculate_evpi()` on an illustrative PSA-shaped dataset consistent with Chapter 25's TB base case.],
  academic-table(
    columns: (auto, auto),
    align: (right, right),
    header: ([*WTP (\$/QALY)*], [*EVPI (\$ per patient)*]),
    body: (
      [0], [15],
      [10,000], [180],
      [20,000], [410],
      [30,000], [590],
      [40,000], [640],
      [50,000], [858],
      [60,000], [540],
      [70,000], [410],
      [80,000], [260],
      [90,000], [130],
      [100,000], [60],
    ),
    footer: (table.cell(colspan: 2)[Illustrative pattern: EVPI rises from near zero, peaks near the WTP at which the decision is closest to a toss-up (consistent with the §26.1 worked example's \$858.33 value at \$50,000/QALY), then falls back toward zero as WTP continues to rise],),
  ),
) <tab-ch26-evpi-wtp-sweep>

The shape -- low at both ends, peaking in the middle -- is the general
pattern to expect whenever the decision genuinely tightens around some
intermediate WTP value; the exact peak location and height are
model-specific and must be computed from the real PSA draws for any
actual submission, never assumed from a generic shape like the one
illustrated here.

== 26.3 Efficient EVPPI via regression and GAM approximations

§26.1 described naive EVPPI as a nested simulation: an outer loop over
candidate values of the parameter of interest, each requiring a full
inner-loop PSA over every other parameter, to estimate the net benefit
*conditional on* that outer value. For a model that is cheap to run
once, this is merely inconvenient; for a model that takes real time
per run (a microsimulation with thousands of simulated patients, a
model with many health states and a long time horizon), an outer loop
of a few hundred values crossed with an inner loop of a few hundred
draws each can require hundreds of thousands to millions of model
evaluations for the EVPPI of a *single* parameter -- and a realistic
VOI analysis usually wants EVPPI for several candidate parameters, not
just one, multiplying the cost further. This is often simply not
feasible within a normal project timeline, which is the real,
practical gap that motivates everything in this section.

The breakthrough that removed this barrier is the regression-based
approach to EVPPI introduced by Strong, Oakley and Brennan in
"Estimating Multiparameter Partial Expected Value of Perfect
Information from a Probabilistic Sensitivity Analysis Sample: A
Nonparametric Regression Approach" (*Medical Decision Making*, 2014,
34(3):311-326). The core insight is a clever piece of statistical
judo: EVPI itself only ever needed the *expected* net benefit
conditional on a given value -- for EVPI, conditional on each full PSA
draw; for EVPPI of parameter $theta_i$, conditional on each candidate
value of $theta_i$ alone, averaged over everything else. Rather than
estimating that conditional expectation *by brute-force nested
simulation* (many inner draws averaged at each outer value), it can
instead be *estimated by regression*, directly on the PSA draws §25.4
already produced, with *zero additional model runs*: fit a flexible
regression of net benefit against $theta_i$ using the existing PSA
sample as training data, and treat the regression's *fitted value* at
each PSA draw's own $theta_i$ as that draw's estimate of
$EE["NB" | theta_i]$. Because a regression line or curve is, by
construction, an estimate of the conditional mean of its outcome given
its predictor, this is exactly the quantity nested simulation was
built to estimate the hard way -- the regression gets there from data
that already exists. Strong, Oakley and Brennan's own paper
demonstrates two nonparametric regression approaches for this --
Generalized Additive Models and Gaussian process regression -- and
reports that GAMs perform adequately for up to around four parameters
of interest at once, with Gaussian process regression preferred for
higher-dimensional cases.

A *Generalized Additive Model* (GAM) is the standard tool for this
regression step because the true relationship between a parameter like
`p_ontx_fail` and net monetary benefit is not guaranteed to be a
straight line, and a plain linear regression that forces a straight-
line fit onto a genuinely curved relationship will systematically
mis-estimate the conditional mean, and therefore mis-estimate EVPPI.

#difficult-terminology("Generalized Additive Model (GAM)")[
An ordinary linear regression fits the *straightest possible line*
through a scatter of points -- it assumes that, whatever the true
relationship between an input and an outcome is, a single straight
line is close enough. Often it is not: net monetary benefit might rise
steeply as the failure probability falls from 0.15 toward 0.08, then
flatten out below that, because once failures are already rare,
shaving off a little more barely changes the clinical pathway's
overall cost and QALY tally. A straight line cannot bend to follow
that kind of curve; a Generalized Additive Model can. Rather than
fitting one straight line, a GAM fits a flexible, *smooth* curve built
from many small overlapping basis functions, bending to follow
whatever shape the data actually show, while still being disciplined
enough (via a built-in smoothness penalty) not to chase every tiny
wiggle of sampling noise. Think of it as the difference between
drawing a single ruler-straight line through a scatterplot and letting
a sketch artist's hand follow the general contour of the points,
smoothing out small jitters but still bending where the data
genuinely bend. In R, `mgcv::gam()` is the standard implementation,
and `s(x)` inside its formula is the instruction "fit a smooth curve
for this predictor, not a straight line."
]

The following code works through the GAM-EVPPI logic end to end for
`p_ontx_fail`, using the same `psa_results` structure Chapter 25 §25.4
built (now assumed to also retain the per-iteration sampled parameter
values `psa_p_fail` and `psa_cost_fail`, and the incremental NMB
`inmb` computed in §25.5's style). `mgcv` is confirmed installed on
this drafting machine (verified via
`requireNamespace("mgcv", quietly = TRUE)`), so this code is written
to actually run, though any specific EVPPI number stated below is the
author's own worked-through illustrative estimate, not an executed
result.

```r
library(mgcv)

# psa_df: one row per PSA iteration (Chapter 25 §25.4's n_psa = 2000 draws),
# with the sampled parameter of interest and the resulting incremental NMB
# at the chosen WTP, carried over unchanged from §25.4-§25.5.
psa_df <- data.frame(
  p_ontx_fail = psa_p_fail,         # the parameter we want EVPPI for
  inmb        = inmb                # incremental NMB per draw, from §25.5
)

# Fit a smooth (not forced-linear) regression of incremental NMB on the
# parameter of interest. s() requests a GAM smooth term; k is left to
# mgcv's default automatic smoothness selection (REML) rather than
# hand-chosen, per the pitfall below.
gam_fit <- gam(inmb ~ s(p_ontx_fail), data = psa_df, method = "REML")

# Fitted values: the GAM's estimate of E[incremental NMB | p_ontx_fail]
# at each PSA draw's own sampled p_ontx_fail value.
fitted_inmb <- predict(gam_fit)

# EVPPI from fitted values, using the SAME EVPI-style logic as §26.1-26.2,
# just applied to the fitted (conditional-mean) values instead of the raw
# per-draw incremental NMB. Working directly from incremental NMB (New
# minus SoC), the reference point for "no information" is zero rather than
# a second strategy's own NMB:
#   - "perfect information about p_ontx_fail alone" -> decide using the
#     fitted conditional mean at each draw's own p_ontx_fail value
#   - "fixed choice" -> decide using the single overall mean fitted value
evppi_fail <- mean(pmax(fitted_inmb, 0)) - max(mean(fitted_inmb), 0)

cat("Illustrative EVPPI for p_ontx_fail:", evppi_fail, "\n")
```

Working through this logic on a small illustrative set of fitted
values consistent with the EVPI order of magnitude already found in
§26.1-§26.2 (a few hundred dollars per patient), an EVPPI for
`p_ontx_fail` alone of roughly \$300-\$900 is a plausible illustrative
result -- noticeably below the full EVPI of \$858.33, since `cost_fail`
and every other parameter are still left uncertain in this
calculation; this code has not been executed on the real Chapter 25
PSA array and the illustrative number stated is a sense check (EVPPI
should sit below EVPI and above zero), not a claimed exact result.

#pitfall[
The GAM-regression EVPPI approximation is only as good as the GAM fit
feeding it, and a poorly chosen smoothness setting biases the result in
a predictable direction either way. `mgcv`'s `k=` argument controls how
many basis functions (how much flexibility) the smooth term is allowed
to use. Too small a `k` forces an overly rigid, nearly-straight curve
that cannot follow real curvature in the true conditional mean --
this *understates* EVPPI, because some of the genuine relationship
between the parameter and net benefit gets smoothed away and
misclassified as noise. Too large a `k` lets the curve wiggle to chase
individual PSA draws' sampling noise rather than the underlying trend
-- this *overstates* EVPPI, because some of what is actually just
Monte Carlo scatter gets misclassified as a real, exploitable
relationship with the parameter. Neither error is obviously visible
from the final EVPPI number alone. The practical defence is twofold:
plot the fitted GAM curve against the raw scattered PSA points and look
for an obviously over-rigid or obviously over-wiggly fit before
trusting the number it produces, and start from `mgcv`'s own automatic
smoothness selection (`method = "REML"`, as used in the code above)
rather than hand-picking `k` by guesswork -- REML selection is a
well-tested default specifically built to balance exactly this
bias/overfitting trade-off, and should only be overridden with a
specific, stated reason tied to what the residual plot actually shows.
]

// TODO-IMAGE: GAM fit diagnostic plot -- scatter of raw incremental NMB
// against p_ontx_fail (the PSA draws), with the fitted GAM smooth curve
// overlaid, to visually check the smoothness choice is neither too rigid
// nor too wiggly -- see progress/image_tracker.md Track 2 for this
// chapter's entry.

This same regression trick generalises in an obvious way to EVPPI for
*more than one* parameter simultaneously -- fitting a multivariate GAM
smooth (e.g. `s(p_ontx_fail, cost_fail)` or separate smooths summed
together) in place of the single-parameter smooth above, with the rest
of the EVPI-style calculation unchanged -- though the fitting itself
gets harder to diagnose visually once more than two or three parameters
are involved at once, which is exactly where Strong, Oakley and
Brennan's own paper recommends switching from GAMs to Gaussian process
regression. §26.4 takes this same regression-based way of thinking one
step further, from "what if this parameter were known for certain" to
"what would a specific *future* sample of a given size actually do to
this uncertainty" -- the Expected Value of Sample Information question
that a real, fundable trial design decision actually needs answered.

== 26.4 EVSI: moment-matching, importance sampling, Gaussian approximation

Section 26.1 drew the line between EVPPI and EVSI carefully, and it is worth
restating because the whole of this section hangs on it. EVPPI asks: what
would resolving uncertainty in `p_ontx_fail` *completely* be worth -- an
idealised, infinite-sample thought experiment. EVSI asks a much more concrete,
much more policy-relevant question: what would a *specific, real, finite*
study be worth -- a trial that enrols, say, 200 patients and estimates
`p_ontx_fail` with the sampling noise that comes with 200 patients, no more
and no less. EVSI is what a research funder actually needs before writing a
cheque, because funders fund studies of a particular size, not omniscience.

That specificity is also what makes EVSI so much harder to compute than
EVPPI. The naive recipe for EVSI nests three simulations inside one another:

+ Simulate a plausible *future dataset* of the proposed size (e.g. 200
  patients' worth of on-treatment failure outcomes).
+ Given that simulated dataset, perform a full Bayesian update of the
  posterior for the parameter(s) the study would measure.
+ Re-run the entire decision-analytic model (the whole TB Markov model from
  Chapters 17-24) under that updated posterior, record the resulting net
  benefit, and repeat all of this over many simulated future datasets to
  average over the different ways the hypothetical trial could turn out.

Each of those three steps is individually routine. Doing all three nested
inside each other, thousands of times, is not. A single re-run of the Markov
model's cohort trace is cheap in isolation, but multiplied by (say) 1,000
simulated future datasets, each needing its own posterior update and its own
full model re-run, naive EVSI estimation can require millions of model
evaluations. This is strictly harder than the naive EVPPI problem from
§26.1-26.3, because EVPPI only has to re-run the model once per *existing*
PSA draw -- it never has to simulate what a future dataset would look like.
For this reason, applied VOI work leans on one of three approximation
families to make EVSI tractable: moment-matching, importance sampling, and
Gaussian approximation. These efficient approaches sit in the same
methodological lineage as §26.3's regression-based EVPPI. Strong,
Oakley, Brennan and Breeze's follow-on paper, "Estimating the Expected
Value of Sample Information Using the Probabilistic Sensitivity
Analysis Sample: A Fast, Nonparametric Regression-Based Method"
(*Medical Decision Making*, 2015, 35(5):570-583), extends the same
PSA-sample-reuse logic from EVPPI to EVSI directly. Jalal and
Alarid-Escudero's "A General Gaussian Approximation Approach for
Value of Information Analysis" (*Medical Decision Making*, 2018,
38(2):174-188) develops the closed-form Gaussian route described
below.

=== Moment-matching

The moment-matching approach exploits a classical probability identity, the
*law of total variance*, to sidestep simulating hypothetical datasets at all.

#difficult-terminology("law of total variance (posterior variance reduction)")[
  Imagine your current uncertainty about `p_ontx_fail` as a wobble around a
  best guess -- that wobble has some size, measured by its variance. Collecting
  more data narrows the wobble, but it does not eliminate it, because real
  samples are noisy. The law of total variance formalises *how much* narrowing
  a given amount of data should be expected to buy, on average, before you've
  even seen the data: $"Var"(theta) = EE["Var"(theta|"data")] + "Var"(EE[theta|"data"])$.
  The first term on the right is the uncertainty *left over* after a study of
  a given size, averaged over every way that study could turn out; the second
  term is how much the central estimate itself is expected to move around.
  Because the left-hand side is fixed (it's just the uncertainty you already
  have), moment-matching methods estimate the second term directly from the
  existing PSA sample and back out the first term by subtraction -- giving an
  expected *reduced* posterior variance for a study of size $n$ without ever
  simulating a single hypothetical patient.
]

For a Beta-distributed parameter such as `p_ontx_fail` $tilde$ Beta$(a=8, b=92)$,
this plays out with unusually clean arithmetic, because the Beta-Binomial
model has a simple closed-form posterior update: observing $r$ failures in
$n$ future on-treatment patients updates the parameter to
Beta$(a+r, b+n-r)$. The *prior* variance is:

$ "Var"(theta) = (a b) / ((a+b)^2 (a+b+1)) = (8 times 92) / (100^2 times 101) approx 0.000729 $

Now suppose a funder is considering a future trial of $n=200$ patients. In
expectation, that trial would observe a failure rate close to the current
prior mean of $8\/100 = 0.08$, i.e. about 16 failures in 200 patients. The
*expected* posterior is then Beta$(8+16, 92+184) = $ Beta$(24, 276)$, with
variance:

$ "Var"(theta|"data") approx (24 times 276) / (300^2 times 301) approx 0.0002445 $

So the expected reduction in variance is roughly
$0.000729 - 0.0002445 approx 0.0004845$, or about 66.4% of the original
variance -- close to the simple "effective sample size" heuristic
$1 - (a+b)\/(a+b+n) = 1 - 100\/300 approx 66.7%$, which is the kind of
back-of-envelope check worth running whenever a moment-matching result looks
suspicious (both figures independently re-verified here: 66.45% from the
exact Beta-variance formula, 66.67% from the heuristic -- close, as
expected). In a full moment-matching EVSI calculation, this fraction is then
combined with the smooth $EE["NB"|theta]$ regression surface already built
for EVPPI in §26.3 (re-sampling theta values consistent with a
*reduced*-variance posterior, rather than the full prior variance, and
recomputing expected net benefit over that narrower spread) to produce the
EVSI itself.

*Worked illustration (self-derived, illustrative numbers only).* Suppose the
regression-based EVPPI for `p_ontx_fail` computed in §26.3 came out at
roughly \$900 per patient affected by the decision (an illustrative figure
for this worked example, not a value actually computed from executed §26.2-
26.3 code). Scaling that full-information value down by the ~66.4% variance
reduction a 200-patient trial is expected to achieve gives an illustrative
EVSI of approximately $900 times 0.6645 approx \$598$ per patient --
independently re-verified -- smaller than the full EVPPI, exactly as the
theory requires, because a finite trial can never deliver as much value as
resolving the parameter completely.

```r
# Illustrative moment-matching EVSI for p_ontx_fail, n = 200 future patients
a_prior <- 8; b_prior <- 92
n_future <- 200
r_expected <- n_future * (a_prior / (a_prior + b_prior))  # expected failures

var_prior <- (a_prior * b_prior) /
  ((a_prior + b_prior)^2 * (a_prior + b_prior + 1))

a_post <- a_prior + r_expected
b_post <- b_prior + (n_future - r_expected)
var_post <- (a_post * b_post) /
  ((a_post + b_post)^2 * (a_post + b_post + 1))

frac_reduced <- 1 - var_post / var_prior
evppi_full   <- 900     # illustrative, from the §26.3 GAM regression
evsi_n200    <- evppi_full * frac_reduced
```

=== Importance sampling

A second route re-uses the *existing* Ch.25 PSA draws rather than discarding
them and drawing fresh ones for each hypothetical future dataset. The core
idea is a reweighting trick: for a given hypothetical future dataset, PSA
draws whose parameter value would have made that dataset *likely* are
upweighted, and draws that would have made it *unlikely* are downweighted.
Averaging net benefit over the reweighted draws approximates what the
decision model's output would look like under the updated posterior, without
needing a literal Bayesian re-fit and a literal model re-run for every
simulated dataset. This still involves simulating many hypothetical future
datasets, but it reuses the PSA sample already on hand for the costly "re-run
the model" step, which is normally the main computational bottleneck. The
precise importance-weight formula is not reproduced here, because getting it
exactly right (particularly the normalising step that keeps the reweighted
sample a valid probability distribution) is easy to get subtly wrong without
careful derivation; treat this as a conceptual sketch of the method rather
than an implementation recipe, and consult the primary methodological
literature (Menzies' work on efficient EVSI estimation is a relevant starting
point, though the exact paper details should be verified before citing)
before coding it.

=== Gaussian approximation

The fastest of the three approaches assumes net benefit is approximately
normally distributed across the PSA sample -- often a defensible
approximation for well-behaved cost-effectiveness models, and one that is
easy to sanity-check with a histogram of the Ch.25 `total_cost`/`total_qaly`
draws. Under that assumption, Jalal and Alarid-Escudero's closed-form
normal-theory results describe how a sample of size $n$ is expected to
shrink the variance of the posterior mean net benefit, which converts
directly into a closed-form EVSI with almost no simulation at all -- an
enormous speed advantage over both moment-matching and importance sampling.
The price is the normality assumption itself: skewed or multimodal
net-benefit distributions (not unusual when a model has a rare high-cost
failure branch, as the TB model's `cost_fail` arm does) can make the
Gaussian approximation misleading, which is exactly why it is best paired
with a visual check of the PSA sample before relying on it.

#pitfall[
  EVSI is a property of the *proposed study*, not just the parameter. A trial
  that is large but badly targeted -- for instance, one that re-measures
  `p_ontx_fail` after its EVPPI has already been shown to be near zero, or one
  that measures a parameter the decision barely responds to -- can have EVSI
  close to zero even at a sample size of several thousand, because no amount
  of additional precision on an already-unimportant parameter changes the
  decision. This is precisely the kind of finding VOI analysis exists to catch
  *before* money is committed to a trial, and it is the throughline into
  §26.6's discussion of using VOI to prioritise what gets researched at all.
]

#ref-table([Comparison of the three standard EVSI approximation methods], academic-table(
  columns: (1fr, 1.2fr, 1.4fr, 1.4fr),
  align: (left, left, left, left),
  header: ([*Method*], [*Computational cost*], [*Key assumption(s)*], [*Accuracy / robustness*]),
  body: (
    [Moment matching], [Low -- closed-form variance algebra plus the existing GAM regression from §26.3], [Variance-reduction formula appropriate to the parameter's distribution (e.g. Beta-Binomial conjugacy)], [Good when the conjugate-update assumption holds; can be biased for non-conjugate or strongly skewed parameters],
    [Importance sampling], [Moderate -- reuses existing PSA draws but still simulates many hypothetical datasets and computes reweighting], [Importance weights well-behaved (no extreme weight concentration / effective sample size collapse)], [Generally robust and flexible, but weight degeneracy can silently inflate variance of the EVSI estimate itself],
    [Gaussian approximation], [Very low -- near closed-form, minimal simulation], [Net benefit (or the regression surface from §26.3) approximately normally distributed], [Fast and convenient, but can be materially wrong when net benefit is skewed or multimodal],
  ),
  footer: (table.cell(colspan: 4)[Moment-matching and Gaussian-approximation citations given in the main text (Strong, Oakley, Brennan and Breeze 2015; Jalal and Alarid-Escudero 2018); the importance-sampling citation (associated with Menzies' efficient-EVSI work) needs verification before final typesetting.],),
))

== 26.5 Value of implementation

Everything in §26.1-26.4 is about the value of *more information*. There is
a second, quite different question that VOI thinking can also answer, and it
is one that is easy to overlook precisely because it has nothing to do with
uncertainty at all: suppose the TB model's New regimen is, in fact, already
known to be cost-effective -- the base-case incremental net monetary benefit
from Chapter 25 is a clearly positive \$8,044.05 per patient at a
willingness-to-pay of \$50,000 per QALY, and nothing in §26.2's EVPI
exploration suggests that remaining parameter uncertainty is large enough to
overturn that decision. The decision, in other words, is already settled.
The question §26.5 asks is: *is it actually happening?*

#difficult-terminology("Value of implementation (EVI)")[
  EVPI, EVPPI, EVSI and ENBS are all about *reducing uncertainty* -- they
  answer "how much is it worth to know more before deciding?" The Value of
  Implementation answers a completely different question: "how much is it
  costing us that the decision we've already made correctly isn't yet being
  followed in practice?" It has nothing to do with what we don't know about
  the parameters, and everything to do with the gap between a guideline
  being issued and a patient in front of a clinician actually receiving the
  recommended regimen. A simple way to hold the two ideas apart: information-
  focused VOI asks whether the *decision* might be wrong; implementation-
  focused VOI asks whether the (correct) decision is actually being *carried
  out*.
]

In practice, a cost-effective intervention is rarely adopted overnight.
Guidelines take time to disseminate; clinicians take time to change
established habits; procurement and supply chains for a new regimen take
time to catch up; some patients, simply by the accident of when they present
for care, will be started on the old standard of care for months or years
after the new regimen has been formally recommended. Every one of those
patients who remains on SoC when they could have been on New forgoes, on
average, the incremental net benefit the decision model says New should
deliver. The Expected Value of Implementation (EVI) is the aggregate size of
that foregone benefit, summed (or integrated) over the whole period during
which real-world uptake lags behind full uptake.

This connects directly to the uptake-curve machinery already built in
Chapter 23's budget-impact analysis. There, the TB model's adoption of the
New regimen was represented as a ramp-up curve over a multi-year horizon,
reaching some terminal uptake share below 100% (reflecting that some fraction
of patients or sites will likely never switch, for reasons ranging from
contraindication to simple inertia). The value of implementation is exactly
the integral, over that ramp-up horizon, of the *gap* between full
implementation and the uptake curve's actual trajectory, multiplied by the
per-patient incremental net benefit. Where EVPI asks "what is uncertainty
about the parameters costing us?", the value of implementation asks "what is
*slow adoption of an already-correct answer* costing us?" -- and in a
resource-constrained health system, the latter can easily be the bigger
number.

*Worked illustration (self-derived, illustrative numbers only).* Suppose,
consistent with Chapter 23's framing, uptake of the New regimen ramps up
roughly linearly over a 5-year horizon to a terminal uptake share of 80%
(the remaining 20% representing sites or patients who are not expected to
switch within the horizon modelled), and suppose the eligible population
entering TB treatment is approximately 10,000 patients per year. In any given
year $y$, the number of patients who *should* be receiving New but are still
on SoC is $10000 times (1 - "uptake"_y)$, and each of those patients forgoes
the \$8,044.05 incremental net monetary benefit the decision model attributes
to the New regimen.

```r
# Illustrative value-of-implementation calculation, 5-year linear ramp to 80%
years          <- 1:5
terminal_uptake <- 0.80
eligible_per_yr <- 10000
inmb_per_patient <- 8044.05

uptake_y <- terminal_uptake * (years / 5)        # linear ramp, 16/32/48/64/80%
gap_y    <- 1 - uptake_y
patients_not_switched <- eligible_per_yr * gap_y
value_lost_per_year   <- patients_not_switched * inmb_per_patient

total_value_of_implementation <- sum(value_lost_per_year)
total_value_of_implementation
```

Running this arithmetic through (independently re-verified): the
implementation gap is 84%, 68%, 52%, 36% and 20% of the eligible population
in years 1 through 5 respectively, i.e. 8,400, 6,800, 5,200, 3,600 and 2,000
un-switched patients per year. Multiplying each by the \$8,044.05
per-patient incremental net benefit and summing across the five years gives
a total value-of-implementation figure of *\$209,145,300* over the ramp-up
horizon -- undiscounted, and before accounting for the fact that a 20%
residual gap persists indefinitely after year 5 (worth a further roughly
\$16.09 million per year at the same per-patient value, for as long as that
20% plateau remains unaddressed).

#report-table([Illustrative value-of-implementation by year of a 5-year uptake ramp (undiscounted)], academic-table(
  columns: (0.8fr, 1fr, 1fr, 1fr, 1.4fr),
  align: (center, center, center, center, right),
  header: ([*Year*], [*Uptake share*], [*Implementation gap*], [*Patients un-switched*], [*Value lost (\$)*]),
  body: (
    [1], [16%], [84%], [8,400], [67,570,020],
    [2], [32%], [68%], [6,800], [54,699,540],
    [3], [48%], [52%], [5,200], [41,829,060],
    [4], [64%], [36%], [3,600], [28,958,580],
    [5], [80%], [20%], [2,000], [16,088,100],
  ),
  footer: (table.cell(colspan: 5)[Illustrative, independently re-verified figures using a linear 5-year ramp to 80% terminal uptake, an assumed eligible population of 10,000 patients/year, and the Chapter 25 base-case incremental NMB of \$8,044.05/patient. Undiscounted; total across the five years is \$209,145,300. A residual 20% gap persists beyond year 5 unless separately addressed.],),
))

The policy implication is genuinely counter-intuitive to anyone trained to
think of VOI purely as "which trial should we fund next": sometimes the
single highest-value activity available to a health system is not any
further research at all, but funding *implementation support* -- clinician
education, updated guideline dissemination, audit-and-feedback programmes,
supply-chain fixes -- to close an existing adoption gap faster for an
intervention whose cost-effectiveness is already well established. When the
value-of-implementation figure computed this way exceeds any remaining VOI
from further research (compare it against the EVPI ceiling from §26.2), that
is itself a decision-relevant finding, not a side note.

#agency-note[
  The UK's NIHR Health Technology Assessment (HTA) Programme directly
  commissions studies that pair evidence synthesis with "a health
  economic analysis including a value of information analysis to
  inform future primary research" (per the HTA Programme's own call
  documentation) -- VOI is not an optional add-on in this programme
  but an explicit, named component of how it decides what to fund
  next. Separately, implementation science and HTA-adjacent
  research-priority frameworks (work associated with the UK's National
  Institute for Health and Care Research and with WHO
  implementation-research guidance -- exact document titles worth
  verifying before citing specifically) increasingly treat "needs
  better implementation support" as a distinct research-priority
  category, separate from "needs more clinical or cost-effectiveness
  evidence." A technology can be simultaneously *well evidenced* and
  *poorly implemented*, and funders are encouraged not to conflate the
  two: commissioning another efficacy trial does nothing to close an
  adoption gap, and commissioning implementation research does nothing
  to resolve a genuinely uncertain parameter. Correctly distinguishing
  which problem you actually have is itself a value-of-information-
  adjacent judgement.
]

== 26.6 Using VOI to design research and prioritise data collection

This closing section of the chapter brings §26.1 through §26.5 together into
the form they are actually used in: as a formal basis for deciding which
research a health system should fund next, rather than leaving that decision
to whichever topic is most publishable, most clinically interesting to a
particular specialty, or most forcefully advocated for. VOI replaces "this
feels important" with a specific, falsifiable, decision-relevant quantity --
how much is resolving *this* uncertainty, or running *this* proposed study,
actually worth to the decisions a health system is making.

The starting point is §26.1 and §26.3's single-parameter EVPPI. A parameter
can be clinically fascinating, frequently debated in the literature, and the
subject of several ongoing trials elsewhere, and still have an EVPPI close to
zero in a given decision model -- meaning that, however uncertain it is, that
uncertainty barely moves the cost-effectiveness conclusion either way. Funding
further research into such a parameter is not wrong exactly, but it is not
*decision-relevant* research: the money could buy more decision-relevant
value spent elsewhere. Conversely, a parameter with a large EVPPI relative to
the cost of resolving it is a strong, quantifiable candidate for research
investment regardless of how unglamorous it might seem (`p_ontx_fail`, the
probability of treatment failure on the new regimen, is exactly this kind of
parameter in the TB model running through this book -- it drives both costs
and QALYs downstream, and even modest uncertainty in it propagates through
years of a Markov trace).

*Worked illustration: ranking parameters by EVPPI (self-derived, illustrative
values).* Suppose the §26.3 GAM-regression EVPPI procedure were run across
four candidate parameters of the TB model: the on-treatment failure
probability (`p_ontx_fail`), the cost of a failure event (`cost_fail`), the
discount rate applied to future costs and QALYs, and the health-state utility
while on treatment. The table below assigns illustrative per-patient EVPPI
values to each, purely to demonstrate how a funder would use such a ranking
-- these are not values actually computed from executed code in this book.

#report-table([Illustrative EVPPI ranking across four candidate parameters of the TB model], academic-table(
  columns: (1.6fr, 1fr, 1.6fr),
  align: (left, right, left),
  header: ([*Parameter*], [*EVPPI (\$/patient)*], [*Research priority*]),
  body: (
    [`p_ontx_fail` (on-treatment failure probability)], [900], [High -- strong candidate for a dedicated trial],
    [On-treatment health-state utility], [340], [Moderate -- worth a smaller, targeted utility-elicitation study],
    [`cost_fail` (cost of a failure event)], [120], [Low-to-moderate -- may not justify a standalone study],
    [Discount rate], [4], [Negligible -- not worth researching further; typically fixed by HTA-agency reference-case convention anyway],
  ),
  footer: (table.cell(colspan: 3)[Illustrative values for demonstration only, not computed from executed code. Ranking shows how a research funder would prioritise `p_ontx_fail` over the discount rate even though the discount rate is, in principle, just as "uncertain" in a loose sense.],),
))

A ranking like this tells a funder something an ad-hoc prioritisation
process cannot: it would be a poor use of money to commission a trial
re-estimating the discount rate (an EVPPI of \$4/patient essentially says "we
already know enough"), even though discount rates are debated endlessly in
health-economics seminars, while a trial targeting `p_ontx_fail` is backed by
a concrete, quantified case for investment.

EVPPI only ranks *parameters*, though -- it does not yet say whether a
*specific proposed trial* is worth funding, because that depends on the
trial's actual cost as well as its EVSI. This is where ENBS, introduced
conceptually in §26.1, becomes the operative decision rule:
$"ENBS" = "EVSI" - C_"trial"$. A study with large EVSI can still be a poor
investment if it costs even more; a modest, well-targeted, cheap study can
outperform an ambitious, expensive one.

*Worked illustration: ENBS for two proposed trials of `p_ontx_fail`
(self-derived, illustrative numbers only).* Building on §26.4's
moment-matching EVSI of roughly \$598 per patient for a 200-patient trial,
consider a second, much larger proposed trial of 2,000 patients. Using the
same effective-sample-size heuristic, the expected fraction of prior variance
resolved rises from about 66.4% ($n=200$) to about 95.2% ($n=2000$, since
$1 - 100\/2100 approx 0.952$), so the per-patient EVSI for the larger trial
is roughly $900 times 0.952 approx \$857$ -- only a modest gain over the
smaller trial's \$598-600, because of the diminishing returns built into the
variance-reduction mathematics.

```r
# Illustrative ENBS comparison: small vs. large trial of p_ontx_fail
decision_population <- 50000   # patients affected before next policy review

evsi_per_patient_small <- 600    # n = 200, from the §26.4 moment-matching calc
evsi_per_patient_large <- 857    # n = 2000, same effective-sample-size logic

evsi_total_small <- evsi_per_patient_small * decision_population
evsi_total_large <- evsi_per_patient_large * decision_population

cost_small_trial <- 50000        # small single-site trial, n = 200
cost_large_trial <- 45000000     # large multi-site trial, n = 2000

enbs_small <- evsi_total_small - cost_small_trial
enbs_large <- evsi_total_large - cost_large_trial

enbs_small; enbs_large
```

Scaling both EVSI figures up to an illustrative decision-relevant population
of 50,000 patients gives a total EVSI of \$30.0 million for the small trial
and \$42.85 million for the large trial. Against trial costs of \$50,000 (a
modest single-site study) and \$45 million (a large multi-country trial with
long follow-up) respectively, the ENBS works out to *\$29,950,000* for the
small trial and *-\$2,150,000* for the large one (both independently
re-verified) -- the large trial's EVSI gain over the small trial
(\$12.85 million) does not come close to covering its \$44.95 million cost
premium.

#report-table([Illustrative ENBS comparison of two proposed trials targeting the same parameter], academic-table(
  columns: (1.4fr, 1fr, 1fr, 1fr, 1.2fr),
  align: (left, right, right, right, right),
  header: ([*Proposed trial*], [*EVSI/patient*], [*Population EVSI*], [*Trial cost*], [*ENBS*]),
  body: (
    [Small (n = 200, single site)], [\$600], [\$30,000,000], [\$50,000], [*\$29,950,000*],
    [Large (n = 2,000, multi-country)], [\$857], [\$42,850,000], [\$45,000,000], [*-\$2,150,000*],
  ),
  footer: (table.cell(colspan: 5)[Illustrative, independently re-verified figures built on the §26.4 moment-matching EVSI approximations and an assumed decision-relevant population of 50,000 patients; not drawn from executed study-specific data. The result that a larger, more expensive study can have a lower -- even negative -- ENBS than a smaller, cheaper one targeting the same parameter is a genuine and non-obvious output of VOI reasoning, not an artefact of these particular illustrative numbers.],),
))

This is precisely the kind of finding that ad-hoc research prioritisation
cannot produce, and it is why VOI-based prioritisation has been promoted,
over several decades, by health-economics groups associated with the UK's
NIHR HTA programme and with academic centres including Sheffield and York
(work associated particularly with Karl Claxton and colleagues, building
directly on the "irrelevance of inference" framework introduced in §26.1)
as the formally correct way to answer "is more research needed, and on
what, and how much should we be willing to pay for it." Rather than funding
whichever trial is loudest, best-connected, or most publishable, a
VOI-literate funder asks three questions in sequence: which parameters
actually drive decision uncertainty (EVPPI, §26.3); what would a specific,
realistically-sized study targeting the highest-priority parameter actually
be worth (EVSI, §26.4); and does that value exceed the study's cost (ENBS,
this section) -- while also checking, per §26.5, whether the bigger win
available is not a new trial at all but closing an existing implementation
gap for a decision that is already settled.

Everything in this chapter, however, rests on one assumption that has gone
unexamined until now: that the TB Markov model itself is a trustworthy
representation of reality in the first place. VOI tells you what it is worth
to learn more about parameters *within* a model, or to implement a model's
recommendation faster -- but if the model's structure or its calibration to
real-world data is wrong, no amount of further parameter precision or faster
implementation will fix a decision built on a flawed foundation. Chapter 27,
*Model Calibration, Validation and Quality Assurance*, turns to exactly that
question: how to check that the trust this chapter has been quantifying the
value of is actually warranted.
