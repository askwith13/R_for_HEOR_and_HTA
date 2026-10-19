#import "../common.typ": *

= Chapter 4. Core Concepts in Health Economics (with R Illustrations)

#learning-objectives((
  [Explain the opportunity-cost foundation of health economics and distinguish the types of costs and effects an economic evaluation must capture.],
  [Distinguish cost-minimization, cost-effectiveness, cost-utility, cost-benefit, and cost-consequence analysis, and explain why cost-utility analysis with QALYs is the HTA-agency default.],
  [Construct a QALY from health-state duration and utility weight, and distinguish QALYs from DALYs and plain life-years, including their opposite sign conventions.],
  [Compute an ICER, and convert it to net monetary benefit (NMB) or net health benefit (NHB) to avoid the ratio's sign-ambiguity problems.],
  [Describe what a willingness-to-pay threshold represents, and the major methodological traditions (opportunity cost vs stated preference) used to set one, including India's HTAIn approach.],
  [Apply perspective, time horizon, discounting and half-cycle correction as explicit, justified modelling choices.],
  [Identify simple and extended dominance and construct an efficiency frontier from a set of competing treatments.],
  [Write a complete R pipeline that takes cost/QALY data for multiple treatments and produces a dominance-pruned, incrementally-costed frontier table — the book's first executed health-economic calculation.],
))

== 4.1 Costs, effects and the opportunity cost of health care

Every health system, however wealthy, faces the same brute fact: the budget for health care is finite, but the number of things worth paying for is not. A national payer, an insurance fund, or a hospital formulary committee has a fixed pot of money in any given year. Every pound, dollar, or rupee spent funding one technology is a pound, dollar, or rupee that cannot be spent funding another. This is the economic idea of *scarcity*, and its direct consequence is *opportunity cost*: the value of the best alternative forgone when a choice is made.

This single idea is the foundation of everything in health economic evaluation. If a health system adopts a new oncology drug at a given price, the money for that drug is drawn, directly or indirectly, from the same budget that could have funded extra dialysis capacity, additional health visitor time, or a different medicine entirely. The health gained by patients on the new drug must be weighed against the health that could have been produced by whatever was displaced. A technology is not "cost-effective" in some free-standing, absolute sense — it is cost-effective *relative to* the alternative use of the same resources. This is why every serious economic evaluation is fundamentally comparative: it never asks "is this good?" in isolation, but "is this better use of this money than the next-best thing we could do with it?"

This comparative framing is what separates health economic evaluation from simple clinical evaluation. A clinical trial can show a drug extends survival or shrinks tumours; it says nothing about whether funding that drug is a *good use* of a constrained budget relative to displaced alternatives. Economic evaluation exists precisely to answer that second, harder question.

To do so formally, every analysis needs two ingredients: *costs* and *effects*.

Costs are usually split into three categories:

#list(
  [*Direct medical costs* — costs borne by the health system in delivering care: drug acquisition, staff time, hospital bed-days, diagnostic tests, outpatient visits, adverse-event management.],
  [*Direct non-medical costs* — costs borne by the patient or their household in accessing care but not for clinical care itself: travel to appointments, informal carer time, home modifications, over-the-counter aids.],
  [*Indirect costs* — productivity losses from illness or treatment: time off paid work, reduced workplace output ("presenteeism"), premature mortality's effect on lifetime earnings. Whether indirect costs belong in the analysis at all is a long-standing methodological fault line — most European HTA reference cases (and NICE in particular) exclude productivity costs from the base case on distributional-fairness grounds, while some willingness-to-pay/societal-perspective frameworks (and some CBA applications) include them.],
)

Effects are more subtle, because "effect" in clinical research and "effect" in HEOR are not the same thing. A clinical trial reports *clinical outcomes*: tumour response rate, HbA1c reduction, relapse rate, blood pressure change. These are precise, measurable, and essential — but they are not, on their own, comparable across disease areas, and they carry no information about how much patients *value* the change. A one-point drop in HbA1c and a 10% reduction in stroke risk cannot be traded off against each other using clinical endpoints alone. HEOR needs *value-laden* outcome measures that convert clinical effect into a common currency of health gain, so that a diabetes drug, a cancer drug, and a hip replacement can, in principle, be compared on the same scale. That conversion — from clinical endpoint to a generic, preference-weighted outcome — is the subject of the next two sections.

```r
# Illustrating opportunity cost with a fixed budget
budget <- 10e6               # fixed annual budget, GBP 10m
cost_per_qaly_drugA <- 20000  # technology A
cost_per_qaly_drugB <- 12000  # displaced alternative use of the same money

qalys_A <- budget / cost_per_qaly_drugA
qalys_B <- budget / cost_per_qaly_drugB

qalys_A; qalys_B
qalys_B - qalys_A   # health forgone by funding A instead of B
```

Spending the whole £10m budget on technology A buys 500 QALYs; spending it on the displaced alternative B buys 833 QALYs. The 333 QALY difference is not an abstraction — it is real health that could have existed but did not, because the money went elsewhere. This is the opportunity cost of the funding decision, and it is the quantity that cost-effectiveness analysis exists to make visible.

#heor-practice[
  When you build cost inputs in R, keep direct medical, direct non-medical, and indirect cost components as *separate columns* in your cost data frame (not a single pre-summed "total cost") for as long as possible in the pipeline. Reviewers and HTA submission templates routinely ask for a disaggregated cost breakdown, and recomputing it after the fact from a single summed column is error-prone and often impossible if the component data was discarded.
]

== 4.2 Types of economic evaluation

Not all economic evaluations measure "effect" the same way, and the choice of effect measure defines the *type* of analysis. Drummond et al.'s taxonomy, now standard across the field, distinguishes five main forms. Understanding the differences is essential, because HTA agencies do not accept any of them interchangeably — most require one specific type as their reference-case default.

#list(
  [*Cost-minimization analysis (CMA)* — used only when there is good evidence that two or more interventions produce *equivalent* effects (established, for example, by a non-inferiority trial). If effects are genuinely equal, the decision collapses to picking the cheapest option. CMA is fragile: it is valid only as long as the equal-effectiveness assumption holds, and it is frequently misused when effects are merely *untested* for difference rather than *proven* equivalent.],
  [*Cost-effectiveness analysis (CEA)* — effects are measured in natural clinical units specific to the disease area: life-years gained, cases of disease averted, mmHg reduction, strokes prevented. Results are reported as a cost per unit of natural effect (e.g., cost per life-year gained, cost per case averted). CEA in this narrow sense is useful within a single disease area but cannot compare across different natural units — cost per stroke averted cannot be ranked against cost per cataract corrected.],
  [*Cost-utility analysis (CUA)* — a specific, standardized form of cost-effectiveness analysis in which effects are expressed in quality-adjusted life years (QALYs), a generic preference-weighted outcome that combines length of life and health-related quality of life into a single number (constructed explicitly in §4.3). Because QALYs are intended to mean the same thing regardless of disease area, CUA is the only one of these methods that supports cross-programme comparison — a cost per QALY for a cancer drug and a cost per QALY for a diabetes drug are, in principle, directly comparable, which is exactly what a national payer deciding across its whole portfolio needs.],
  [*Cost-benefit analysis (CBA)* — the most ambitious and least commonly used in HTA practice: all effects, including health itself, are monetized (via willingness-to-pay studies, value-of-a-statistical-life estimates, or similar), so that a single net monetary benefit figure summarizes the decision. CBA permits comparison not just across health interventions but across sectors entirely (health spending versus transport safety spending, for instance) but the monetization of health and life is methodologically and ethically contentious, and most health-specific HTA bodies avoid it as a primary reference-case method.],
  [*Cost-consequence analysis (CCA)* — deliberately avoids collapsing effects into a single ratio. Costs and multiple disaggregated effects (QALYs, specific clinical events, resource-use impacts) are presented side by side in a balance-sheet format, leaving the decision-maker to weigh trade-offs themselves. CCA is often used as a *supplementary* presentation alongside a CUA base case, especially where some important consequences resist being folded sensibly into a single utility number.],
)

#difficult-terminology("non-inferiority trial")[
Most clinical trials are designed as *superiority* trials: they try to
show a new treatment works better than an existing one (or than
placebo). A non-inferiority trial sets out to answer a deliberately
different question — not "is the new treatment better," but "is the
new treatment not meaningfully worse," within a pre-agreed margin that
both the trial's designers and the relevant regulator accept in
advance as clinically unimportant. This design is typically chosen
when the new treatment offers some other advantage — cheaper, more
convenient to take, fewer side effects, easier to manufacture at scale
— so that proving "just as good, clinically" is enough to justify
switching, without needing to prove outright superiority on the
primary clinical outcome. Because a non-inferiority trial cannot prove
two treatments are *exactly* equal (no finite trial can rule out every
conceivable tiny difference), its result is always "not worse by more
than margin X," not "identical" — a distinction HEOR analysts must
keep in mind before treating a non-inferiority result as licence for
unqualified cost-minimisation.
]

#difficult-terminology("value-of-a-statistical-life estimate")[
This sounds like it is pricing one specific, identified person's life,
but it is not — it is a population-level monetary figure representing
how much a group of people are collectively willing to pay to reduce
everyone's risk of death by a small amount. It is typically derived
either by observing how much extra pay workers demand to take
measurably riskier jobs (a *revealed preference* method, explained
further in §4.5 below), or by asking people directly in surveys how
much they would pay for a small reduction in their own risk of dying
(a *stated preference* method). The number is then extrapolated:
if 100,000 people are each willing to pay \$50 for a reduction in risk
that is expected to prevent one death across that group, the
value-of-a-statistical-life estimate for that context is \$5 million —
not the value of any one real, identified person's life, but the
aggregate amount a population puts toward preventing one anonymous,
statistical death among them. It is the standard tool cost-benefit
analysis (CBA, described just above) uses to convert mortality risk
reduction into a monetary figure that can be added alongside other
costs and benefits.
]

In practice, CUA with QALYs has become the de facto default that HTA agencies worldwide demand for formal technology appraisal, and it is worth being explicit about *why*: a finite health budget has to allocate across wildly different disease areas — oncology, rare disease, cardiovascular prevention, mental health — and only a generic outcome measure makes those allocation decisions comparable on a common scale. A natural-units CEA cost per "case averted" cannot inform whether money is better spent on cancer or on diabetes; a QALY-denominated CUA, at least nominally, can.

#agency-note[
  NICE's reference case for technology appraisals specifies the QALY, estimated using the EQ-5D (or an NICE-endorsed alternative under its 2022 health technology evaluation methods manual), as the required outcome measure; submissions that present only natural-unit CEA or CCA results without an accompanying QALY-based CUA are routinely asked to supply one. HTAIn's (Health Technology Assessment in India) reference case similarly mandates a QALY-based cost-utility analysis as the base-case outcome measure for the cost-effectiveness threshold it applies, placing India alongside NICE in the CUA-as-default camp despite very different thresholds and population contexts.
]

#pitfall[
  Do not treat "cost-effectiveness analysis" as a synonym for the whole field. In the strict Drummond taxonomy, CEA specifically denotes natural-units analysis, and CUA (QALY-based) is a distinct, narrower category. Many papers and even some agency documents use "cost-effectiveness" loosely to mean "any formal economic evaluation" — when reading or writing a submission, check the actual outcome measure used before assuming which type is meant.
]

== 4.3 QALYs, DALYs and life-years

Three outcome metrics recur throughout HEOR, and each solves the "how do we weigh life" problem differently. Historically, the simplest and oldest is the *life-year*: a count of time lived, with no adjustment at all for the quality of that time. A treatment that extends survival by one year scores exactly the same whether that year is spent in full health or bedridden in severe pain. Life-years remain useful for mortality-dominated contexts (vaccination programmes, acute life-saving interventions) and for sensitivity analysis, but their indifference to quality of life is precisely the gap the QALY was built to close.

The *quality-adjusted life year (QALY)* combines duration of time in a health state with a *utility weight* reflecting how good or bad that state is. Formally:

$ "QALY" = sum_i t_i times u_i $

where $t_i$ is the time (in years) spent in health state $i$, and $u_i$ is the utility weight for that state on a scale anchored at $u=1$ for full health and $u=0$ for dead. Crucially, the scale is not bounded below at zero: health states judged worse than death (severe, unremitting pain with no prospect of recovery, for example) can carry negative utility weights, reflecting that a respondent would trade some of their remaining life expectancy to avoid that state entirely, or would prefer death to it. Utility weights are typically elicited using standardized preference-based instruments (EQ-5D, SF-6D, HUI) administered to patients or to general-population samples, then converted to utilities via a country-specific value set derived from techniques such as time trade-off or standard gamble.

#difficult-terminology("time trade-off / standard gamble")[
Both are standard techniques for turning "how bad is this health
state" into a number between 0 (dead) and 1 (full health) that a QALY
calculation can use — they ask a respondent (patient or member of the
public) to express that judgement through a concrete choice, rather
than simply rating the state on an abstract scale. *Time trade-off*
asks: given a fixed number of years to live in the impaired health
state being valued, how many of those years would you be willing to
give up in exchange for the remaining years being in full health
instead? Someone willing to trade 2 years out of 10 to be fully
healthy for the remaining 8 implies a utility of 0.8 for that state —
the less of their remaining life they'd sacrifice, the closer to 1.0
(full health) the implied utility. *Standard gamble* instead offers a
choice between the impaired state for certain, versus a gamble: a
probability $p$ of full, instant recovery to perfect health, and a
probability $(1-p)$ of immediate death. The respondent's indifference
point — the probability $p$ at which they can no longer decide whether
they prefer the certain impaired state or the gamble — is taken as the
utility value of that impaired state. A concrete worked example: if a
respondent says they would accept a 25% chance of death in exchange
for a 75% chance of being cured, rather than continuing to live with
their current health problem for certain, their utility for that
health state is read off as 0.75. Both methods are more cognitively
demanding than simply asking someone to rate a state "out of 10," but
are grounded in a formal economic theory of choice under uncertainty
(standard gamble) or time preference (time trade-off), which is why
country-specific EQ-5D value sets are built from large population
samples answering one or the other.
]

```r
# Simple QALY calculation across two health states
time_in_full_health   <- 2.0   # years
utility_full_health   <- 1.0

time_in_impaired_state <- 3.0  # years
utility_impaired_state  <- 0.6

qalys <- time_in_full_health * utility_full_health +
         time_in_impaired_state * utility_impaired_state
qalys
```

Two years at full health (utility 1.0) contribute 2.0 QALYs; three further years at a utility of 0.6 (reflecting, say, moderate chronic pain and reduced mobility) contribute 1.8 QALYs; the patient's total is 3.8 QALYs over five calendar years of survival — a single number that simultaneously encodes both how long and how well the patient lived. An incremental analysis compares the QALYs accumulated under a new technology against the QALYs accumulated under the comparator, and that QALY difference becomes the denominator of the ICER introduced in Chapter 1. The QALY is explicitly a *good*: more QALYs is always better, and interventions are evaluated by how many QALYs they gain.

The *disability-adjusted life year (DALY)*, by contrast, comes from a different tradition entirely — the WHO/World Bank Global Burden of Disease programme, designed to quantify population-level disease burden rather than to evaluate individual health technologies. A DALY is constructed as:

$ "DALY" = "YLL" + "YLD" $

where YLL (years of life lost) captures premature mortality relative to a reference life expectancy, and YLD (years lived with disability) captures time lived in a less-than-full-health state, weighted by a disability weight (conceptually similar to, but methodologically distinct from, a QALY utility weight, and typically derived from large multi-country disability-weight surveys rather than patient-elicited utilities). The DALY is explicitly a *bad*: it measures burden, and the policy goal is to minimize DALYs, not maximize them. An intervention's benefit in DALY terms is expressed as "DALYs averted" — the reduction in burden the intervention achieves relative to no intervention — which is a positive good, even though the underlying DALY count itself represents harm.

#agency-note[
  WHO's Global Burden of Disease framework uses the DALY as its standard metric for quantifying population-level disease burden and informing global health priority-setting; this is a distinct convention from, and should not be conflated with, the QALY-based cost-utility reference cases used by technology-appraisal HTA bodies such as NICE and HTAIn. Some national HTA systems (several Asian and a number of low- and middle-income country adaptations) do permit DALY-averted as an acceptable alternative effect measure to the QALY in cost-effectiveness submissions, so the choice between QALY and DALY conventions is itself a jurisdiction-specific methodological decision to check in any agency's reference case before modelling.
]

#pitfall[
  QALYs and DALYs run in *opposite* directions, and mixing up the sign convention is a common and consequential modelling error. A QALY is a good: a successful treatment should *increase* total QALYs relative to the comparator, and the ICER is cost divided by QALYs *gained*. A raw DALY is a burden: a successful treatment should *decrease* total DALYs, and the relevant effectiveness quantity for a cost-effectiveness ratio is DALYs *averted* (comparator DALYs minus intervention DALYs), not the raw DALY count itself. Coding a model that subtracts intervention QALYs from comparator QALYs (the DALY-style direction) — or divides cost by raw DALYs accrued rather than DALYs averted — will silently produce an ICER with the wrong sign or the wrong magnitude. When porting a published DALY-based burden estimate into an R cost-effectiveness model, explicitly convert it to "DALYs averted" and sanity-check the sign before it ever reaches your ICER formula.
]

== 4.4 ICERs, net monetary benefit (NMB) and net health benefit (NHB)

Chapter 1 introduced the incremental cost-effectiveness ratio in its canonical form, $"ICER" = (Delta C) / (Delta E)$, where $Delta C = C_2 - C_1$ is the incremental cost of a new treatment (treatment 2) relative to a comparator (treatment 1), and $Delta E$ is the incremental effect, almost always measured in quality-adjusted life years (QALYs) in HTA work. The ICER answers a narrow but useful question: how much extra does it cost, per unit of extra health gained, to adopt the new treatment instead of the old one?

Consider a worked example. A new oral anticoagulant costs £1,800 per patient per year versus £400 for standard warfarin monitoring, and modelling over a patient's lifetime projects 0.28 additional QALYs for the new drug due to fewer strokes and bleeds.

```r
cost_new <- 1800 * 12   # simplified lifetime cost proxy, GBP
cost_comp <- 400 * 12
qaly_new <- 8.42
qaly_comp <- 8.14

delta_C <- cost_new - cost_comp
delta_E <- qaly_new - qaly_comp
icer <- delta_C / delta_E
icer
```

This returns an ICER of £60,000 per QALY gained (ΔC = £16,800, ΔE = 0.28) — a figure a reimbursement committee can compare directly against a threshold (§4.5). At a £20,000/QALY threshold, this drug would not be considered cost-effective on this evidence.

The ratio format, however, conceals as much as it reveals. Two well-known problems arise:

#list(
  [*Sign ambiguity.* A negative ICER is uninformative on its own: it can arise from a treatment that is more effective and cheaper (dominant — unambiguously good), or from one that is less effective and more expensive (dominated — unambiguously bad). Both quadrants of the cost-effectiveness plane produce the same algebraic sign, so the ICER alone cannot distinguish "obviously adopt" from "obviously reject."],
  [*Non-monotonicity near zero.* As $Delta E$ approaches zero from either side, the ICER magnitude explodes toward infinity even for small, economically unimportant differences in cost, making ratios unstable for ranking or for probabilistic sensitivity analysis summaries.],
)

#pitfall[
  A reviewer reports: "Drug X is dominated by Drug Y because the ICER is negative (-£2,500/QALY)." This is only sometimes true. Plot the four quadrants: in the *north-west* quadrant (more effective, less costly — Drug X dominant), $Delta C < 0$ and $Delta E > 0$, giving a negative ratio that means "adopt." In the *south-east* quadrant (less effective, more costly — Drug X dominated), $Delta C > 0$ and $Delta E < 0$, also giving a negative ratio, but meaning "reject." Never report a negative ICER without stating which quadrant it comes from; always accompany it with the disaggregated $Delta C$ and $Delta E$ signs, or better, switch to net benefit.
]

#figure(
  image("../images/r_generated/ch04_icer_quadrants.png", width: 85%),
  caption: [The cost-effectiveness plane's four quadrants. The two orange points share the identical ICER (-£2,500/QALY) but sit in opposite quadrants with opposite real-world meanings — dominant (adopt) versus dominated (reject) — exactly the ambiguity the pitfall above warns against. The blue point plots this section's own anticoagulant worked example (ΔE = 0.28, ΔC = £16,800), which falls in the north-east trade-off quadrant where neither sign alone resolves the decision and the ICER (or NMB) must actually be compared against a threshold.],
) <fig-ch04-icer-quadrants>

The standard remedy is to convert the ratio into a linear measure by fixing a willingness-to-pay (WTP) threshold, $lambda$, for one additional QALY. Two equivalent formulations exist:

$ "NMB" = (Delta E times lambda) - Delta C $
$ "NHB" = Delta E - (Delta C) / lambda $

NMB expresses net benefit in monetary units; NHB expresses it in health units (QALYs). Because both are linear in $Delta C$ and $Delta E$, they are well-behaved however small the denominator would have been, they aggregate cleanly across subgroups or probabilistic simulation draws, and — critically — the decision rule becomes unambiguous: *a positive NMB (or NHB) at threshold $lambda$ means the intervention is cost-effective at that threshold; negative means it is not.* No quadrant-reading is required.

```r
lambda <- 20000   # GBP per QALY, illustrative threshold
nmb <- delta_E * lambda - delta_C
nhb <- delta_E - delta_C / lambda
nmb; nhb
```

With ΔE = 0.28 and ΔC = £16,800: NMB = 0.28 × £20,000 − £16,800 = £5,600 − £16,800 = −£11,200. NMB is negative, so at a £20,000/QALY threshold this drug is *not* cost-effective — exactly the same conclusion the £60,000/QALY ICER already pointed to (£60,000 exceeds the £20,000 threshold). NMB and the ICER decision rule are always mathematically consistent for a single comparator when $Delta E > 0$ and $lambda$ is fixed; NMB's real advantage is not a different conclusion but a *linear*, sign-unambiguous one that remains well-defined even when $Delta E$ is close to zero, which is precisely why it is the quantity averaged across probabilistic sensitivity analysis draws rather than the ICER itself.

#report-table(
  [A CHEERS 2022-style cost-effectiveness results table for the anticoagulant worked example — the standard way an ICER/NMB result is reported in a paper or HTA submission, rather than left as bare console output.],
  academic-table(
    columns: (1.6fr, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    header: ([*Treatment*], [*Cost (GBP)*], [*QALYs*], [*Incremental cost*], [*Incremental QALYs*]),
    body: (
      [Standard warfarin monitoring], [4,800], [8.14], [--], [--],
      [New oral anticoagulant], [21,600], [8.42], [16,800], [0.28],
    ),
    footer: (table.cell(colspan: 5)[*ICER* = £60,000 per QALY gained #h(1em) *NMB* at λ = £20,000/QALY = –£11,200 (not cost-effective at this threshold)],),
  ),
) <tab-ch04-icer-nmb>

#heor-practice[
  In practice, NMB is the default output of a Bayesian or bootstrap probabilistic sensitivity analysis: for each of, say, 10,000 simulated parameter draws, compute NMB at the threshold of interest, then summarise the proportion of draws with positive NMB as the "probability cost-effective." This is the basis of cost-effectiveness acceptability curves (CEACs), covered in Chapter 25. Reporting an ICER confidence interval from simulated draws is often nonsensical (ratios of near-zero denominators), whereas an NMB distribution is always well-defined.
]

== 4.5 Willingness-to-pay thresholds, including country-specific and LMIC thresholds

A willingness-to-pay (WTP) or cost-effectiveness threshold, denoted $lambda$ in §4.4, represents the maximum amount a payer is prepared to pay for one additional unit of health gained — conventionally one QALY. It is the single parameter that converts an ICER (or NMB/NHB) from a descriptive statistic into an actionable reimbursement decision: if $"ICER" < lambda$, the intervention is judged cost-effective at that threshold; if $"ICER" > lambda$, it is not (subject to the quadrant caveats of §4.4).

The most widely cited threshold range in the HTA literature is NICE's (England and Wales) historical £20,000–£30,000 per QALY range, used since the early 2000s as an informal reference point in appraisals, with values above £30,000 requiring increasingly strong justification (e.g., end-of-life criteria, severity modifiers) and values below £20,000 treated as straightforwardly acceptable. It is worth being explicit that this range was never a hard legislative threshold, was not derived from a formal empirical exercise at the time of adoption, and has been persistently criticised — including by health economists associated with NICE's own methods reviews — as arbitrary and not clearly linked to the opportunity cost of displaced NHS spending. Claxton and colleagues' empirical work estimating the NHS's own marginal productivity (health forgone per pound spent elsewhere in the system) suggested a supply-side threshold closer to £12,000–£15,000 per QALY, considerably below the £20,000–£30,000 range, triggering substantial debate about whether NICE's reference range was too generous.

#agency-note[
  NICE's current reference case for threshold use and modifiers is set out in *NICE Health Technology Evaluations: The Manual* (PMG36, 2022), which retains the £20,000–£30,000/QALY range for standard appraisals, allows an additional severity weighting (replacing the older "end-of-life" criteria) for conditions with greater absolute or proportional QALY shortfall, and directs analysts to NICE DSU technical support documents for the quantitative severity-modifier calculations. Students producing a submission for NICE should cite the Manual directly, not a secondary paraphrase of the threshold range.
]

For low- and middle-income countries (LMICs), the historically dominant heuristic came from the WHO's Choosing Interventions that are Cost-Effective (WHO-CHOICE) programme, which proposed classifying interventions as "very cost-effective" below one times GDP per capita per QALY/DALY averted, and "cost-effective" between one and three times GDP per capita, with anything above three times GDP per capita judged not cost-effective. This 1–3x GDP-per-capita rule was administratively convenient and widely adopted in early LMIC HTA guidance, but it has been substantially abandoned by the WHO itself: a widely cited 2016 WHO Bulletin piece (Bertram et al., "Cost-effectiveness thresholds: pros and cons") explicitly recommended retiring the GDP-multiple heuristic, arguing it has no sound empirical basis, is unrelated to a country's actual health budget or opportunity cost, and tends to label far too many interventions as "cost-effective" relative to what health systems can actually afford.

#agency-note[
  WHO's updated position, reflected in WHO-CHOICE guidance and the 2016 Bulletin of the World Health Organization commentary by Bertram, Lauer, Joncheere, Edejer, Baltussen and colleagues, favours deriving thresholds from the *opportunity cost of displaced health spending within the country's own budget* — analogous to Claxton's NHS-marginal-productivity approach — rather than an arbitrary GDP multiple or a stated willingness-to-pay survey figure.
]

This opportunity-cost framing sits opposite a second methodological tradition: stated- or revealed-preference willingness-to-pay surveys, which ask members of the public how much they would personally pay (or how much compensation they would require) for a given health gain, typically yielding higher thresholds than supply-side opportunity-cost estimates because they reflect individual valuation of health rather than a health system's binding budget constraint. The debate between these two schools — opportunity cost (what health is displaced if we fund this) versus willingness-to-pay (what society says health is worth) — remains unresolved and is one of the most active areas in health economics methods research; neither is "correct" in an absolute sense, and the choice has first-order consequences for which technologies get funded.

#difficult-terminology("revealed preference")[
"Stated preference" (used just above, and already described elsewhere
in this section) means directly asking people what they would pay or
accept — a survey. *Revealed preference* takes the opposite approach:
instead of asking, it infers how much people value something by
observing the actual trade-offs they make in real decisions. The
classic example underlying value-of-a-statistical-life estimates
(§4.2) is the "wage premium" study: researchers compare otherwise
similar jobs that differ mainly in their on-the-job fatality risk
(construction versus office work, for instance) and observe how much
extra pay workers demand, on average, to accept the riskier job. That
observed wage gap, scaled by the size of the risk difference, reveals
an implicit price workers are putting on their own safety through
real choices they actually made — not through a hypothetical
questionnaire answer. The general principle extends beyond wages:
any real-world choice where people visibly trade one thing for
another (buying a safer but more expensive car, choosing a shorter but
costlier commute) can, in principle, reveal an implicit valuation,
provided the choice is genuinely free and the trade-off can be
isolated from other confounding factors.
]

India's HTA body, HTAIn (Health Technology Assessment in India), operationalised a country-specific threshold rather than adopting the WHO GDP-multiple rule.

#agency-note[
  HTAIn's *Methods and Processes Manual* (operationalised through the Department of Health Research) and subsequent HTAIn-commissioned work (notably India-specific cost-effectiveness threshold studies led by health economics teams around 2018–2021) estimated a supply-side, opportunity-cost-based threshold substantially below one times India's per-capita GDP, reflecting the real resource constraints of India's public health budget rather than a generic multiple. Analysts preparing a submission for HTAIn should reference the current HTAIn threshold value published in its manual, not the superseded WHO 1–3x GDP heuristic.
]

#heor-practice[
  When a jurisdiction's own threshold is unclear or evolving, report results across a *range* of thresholds in a cost-effectiveness acceptability curve (Chapter 25) rather than committing to a single $lambda$. This is standard practice precisely because threshold-setting is contested, and it lets decision-makers apply their own judgement.
]

#ref-table(
  [Willingness-to-pay / cost-effectiveness threshold conventions across selected HTA jurisdictions — the kind of comparison table a methods section uses to justify which threshold a submission is benchmarked against.],
  academic-table(
    columns: (1.4fr, 1.8fr, 1.6fr, 1.8fr),
    align: (left, left, left, left),
    header: ([*Jurisdiction / body*], [*Threshold convention*], [*Approximate value*], [*Methodological basis*]),
    body: (
      [NICE (England \& Wales)], [Fixed reference range, severity-modified], [£20,000--£30,000 per QALY], [Historical reference range; no formal empirical derivation; Claxton et al. supply-side estimate suggests £12,000--£15,000],
      [CADTH (Canada)], [No single published hard threshold], [Often benchmarked informally around CAD 50,000 per QALY in practice], [Deliberative committee judgement rather than a codified rule; threshold not fixed in CADTH's own methods guidance],
      [HTAIn (India)], [Country-specific supply-side threshold], [Below 1 times India's per-capita GDP], [Opportunity-cost-based estimate from India-specific threshold studies (\~2018--2021), not the WHO GDP-multiple rule],
      [WHO-CHOICE (historical)], [GDP-per-capita multiple], [1x GDP/capita = \"very cost-effective\"; 1--3x = \"cost-effective\"], [Administrative heuristic; formally recommended for retirement by Bertram et al. 2016 (WHO Bulletin)],
    ),
    footer: (table.cell(colspan: 4)[*Note:* The GDP-multiple rule is retained here only as a historical reference point; current WHO guidance favours country-specific opportunity-cost thresholds, consistent with the HTAIn and Claxton/NICE supply-side approaches above.],),
  ),
) <tab-ch04-wtp-thresholds>

== 4.6 Perspective, time horizon, discounting and half-cycle correction

Four further modelling choices — perspective, time horizon, discounting, and (in Markov models) half-cycle correction — jointly determine what counts as a cost or effect, over what period, and how future values are weighted. Each is a source of real controversy and, unlike the ICER/NMB arithmetic above, each requires an explicit judgement call that should be justified and reported transparently.

*Perspective* defines whose costs and whose effects enter the analysis. The two most common are:

#list(
  [*Healthcare payer (or healthcare system) perspective*: includes only costs borne by the payer — drug acquisition, administration, monitoring, hospitalisation, adverse event management — and excludes costs falling on patients, families, or other sectors.],
  [*Societal perspective*: additionally includes productivity losses (time off work, informal caregiver time), patient out-of-pocket costs, transport to appointments, and sometimes costs in other sectors (e.g., social care, criminal justice for some public health interventions).],
)

The choice matters substantially for conditions with large informal-care or productivity burdens (e.g., dementia, severe mental illness): a healthcare-payer analysis can understate the true value of an intervention that reduces caregiver burden even if it does little to reduce direct medical costs. NICE's reference case specifies an NHS-and-Personal-Social-Services perspective for costs (narrower than full societal) paired with QALYs measured across all effects on the patient, while PBAC and others have historically leaned payer-perspective with societal perspective as a supplementary sensitivity analysis.

*Time horizon* is the period over which costs and effects are modelled. The general principle, stated in essentially all major HTA methods guides, is that the horizon should be long enough to capture *all* costs and effects relevant to the decision — for a one-off curative intervention this might be a few years, but for a chronic, progressive disease (diabetes, chronic kidney disease, most oncology indications) a *lifetime horizon* is typically required, because truncating too early can systematically understate long-run benefits (e.g., avoided complications decades later) or long-run costs (ongoing drug costs, disease progression costs).

#pitfall[
  A common and costly modelling error is choosing a short time horizon (e.g., a trial's own follow-up period, often 1–3 years) simply because that is what outcome data are directly observed for, rather than because it genuinely captures the decision-relevant period. For a chronic disease, this almost always biases the ICER against interventions whose main benefit accrues late (e.g., prevention of long-term complications), because the model stops before those benefits are realised while some of the upfront costs are already fully counted. Extrapolation beyond trial follow-up (Chapter 10 and Chapter 19) is then unavoidable and must be justified, not treated as an afterthought.
]

*Discounting* addresses the fact that costs and health effects occurring in the future are valued less than those occurring today, reflecting positive time preference (both for money, due to its opportunity cost, and arguably for health itself). A future cost or QALY is converted to its present value by dividing by $(1+r)^t$, where $r$ is the discount rate and $t$ is the number of years in the future the cost or effect occurs.

```r
discount_pv <- function(value, rate, year) {
  value / (1 + rate)^year
}

# A QALY gained in year 10, discounted at NICE's 3.5% rate
discount_pv(value = 1, rate = 0.035, year = 10)
```

#agency-note[
  NICE's *Health Technology Evaluations: The Manual* (PMG36, 2022) specifies a discount rate of 3.5% per annum for both costs and health effects as the reference-case base case, consistent with UK Treasury Green Book conventions for public-sector appraisal, with sensitivity analysis at 1.5% for health effects permitted only in narrowly defined circumstances (very long-term, substantial health gains). This "equal discounting" of costs and QALYs at the same rate is itself a resolved policy choice following an extended methodological debate.
]

That debate concerns *differential discounting*: some health economists (echoing earlier work by Claxton and colleagues, and reflected in US Panel on Cost-Effectiveness in Health and Medicine recommendations at various points) have argued health effects should be discounted at a *lower* rate than costs, because health does not have the same investment/opportunity-cost properties as money and because discounting health heavily can appear to penalise prevention relative to treatment. Most national HTA bodies, however, have settled on equal discounting of costs and effects at a single rate (3.5% at NICE; comparable single-rate conventions are used by CADTH and others) for consistency and to avoid distortions where differential rates can make almost any sufficiently long-term prevention programme appear cost-saving regardless of its actual value.

#ref-table(
  [Perspective, time horizon and discount rate reference-case conventions across selected HTA bodies — the modelling-choices summary a methods section typically tabulates before presenting results.],
  academic-table(
    columns: (1.3fr, 1.7fr, 1.5fr, 1.7fr),
    align: (left, left, left, left),
    header: ([*HTA body*], [*Reference-case perspective*], [*Time horizon*], [*Discount rate (costs / effects)*]),
    body: (
      [NICE (England \& Wales)], [NHS and Personal Social Services], [Long enough to capture all relevant costs/effects; typically lifetime for chronic disease], [3.5% / 3.5% (equal); 1.5% on effects only in narrow long-term, large-benefit cases],
      [CADTH (Canada)], [Publicly funded health care payer (base case); societal as sensitivity analysis], [Lifetime horizon for chronic/progressive conditions], [1.5% / 1.5% (equal, per current CADTH guidance)],
      [HTAIn (India)], [Health system / payer perspective], [Lifetime horizon recommended for chronic conditions], [3% / 3% (equal), per HTAIn Methods and Processes Manual],
    ),
    footer: (table.cell(colspan: 4)[*Note:* Values shown are reference-case defaults; most agencies also require sensitivity analyses varying perspective, horizon, and discount rate from these defaults. Consult each agency's current methods manual before a live submission -- rates and conventions are periodically revised.],),
  ),
) <tab-ch04-perspective-discounting>

*Half-cycle correction* is a technical adjustment specific to Markov cohort models (introduced formally in Chapter 19), noted briefly here because it interacts directly with discounting and time horizon. A Markov model tracks a hypothetical cohort moving between health states in discrete cycles (e.g., annual cycles), and by convention accumulates costs and QALYs as if the entire cohort occupies its cycle-start health state for the whole cycle. In reality, transitions between states (e.g., disease progression, death) occur continuously throughout the cycle, so a naive cycle-start (or cycle-end) accounting overstates (or understates) time spent in each state by roughly half a cycle's worth. Half-cycle correction adjusts for this by assuming, on average, that transitions occur at the cycle midpoint — commonly implemented as a simple average of the cycle-start and cycle-end state occupancy, or via Simpson's-rule-weighted approaches for greater accuracy with longer cycle lengths. The correction typically has a modest but non-trivial effect on both costs and QALYs, and omitting it is a recognised, checkable error in submitted economic models. Full mechanics, including worked trace calculations and the Simpson's-rule variant, are deferred to Chapter 19's dedicated treatment of cohort Markov models in R.

#difficult-terminology("Simpson's rule (half-cycle correction variant)")[
Simpson's rule is a general numerical technique, unrelated to health
economics specifically, for estimating the area under a curve more
accurately than a plain average would. The simplest "half-cycle"
correction described just above averages only two points per cycle —
the state occupancy at the cycle's start and at its end — effectively
approximating the true, continuously-curving occupancy over that
cycle with a straight line between those two points. Simpson's rule
improves on this by also using the occupancy at the cycle's *midpoint*
and fitting a short parabolic (curved) segment through all three
points rather than a straight line, which tracks a genuinely curving
trend much more closely, particularly when cycles are long or the
underlying transition probabilities change quickly. A practical
analogy: estimating the distance a car travelled using only its speed
at the start and end of an hour (the simple average) assumes it
accelerated in a straight line; checking its speed at the halfway mark
too, and fitting a smooth curve through all three readings (Simpson's
rule), gives a noticeably better estimate if the car sped up and
slowed down unevenly during that hour rather than changing speed at a
constant rate. In R-based Markov models, this usually means sampling
state-occupancy at an extra set of mid-cycle time points and combining
them with a specific weighted-average formula, rather than performing
any genuinely novel calculus.
]

#heor-practice[
  When reviewing someone else's Markov model, check three things together, since they interact: the time horizon is long enough (ideally lifetime for chronic disease), the discount rate matches the target jurisdiction's reference case (e.g., 3.5% equal discounting for a NICE submission), and half-cycle correction (or an equivalent continuous-time correction) has been applied. Getting the first two right while omitting the third still produces a systematically biased ICER.
]

== 4.7 Dominance, extended dominance and the efficiency frontier

Section 4.4 gave you the ICER as a ratio, $Delta C \/ Delta E$, and left a loose thread: an ICER only tells you something useful once you know *which two options* belong on either side of the slash. Compare the wrong pair — a brand-new drug against some arbitrary older comparator that was never really in contention — and the number you compute is technically arithmetic but economically meaningless. This section ties that thread off by introducing the idea of *dominance* and the *efficiency frontier*, the two concepts that tell you which comparisons are legitimate in the first place.

Start with the simplest case. Suppose Treatment A costs more than Treatment B *and* delivers fewer QALYs than Treatment B. A is strictly worse on both axes: no rational decision-maker would ever choose it, regardless of budget or willingness to pay. We say A is *dominated* (specifically, *simply* or *strictly* dominated) by B, and the correct analytical move is to delete A from the comparison set entirely. You do not compute an ICER for a dominated option — dividing a positive cost difference by a negative effect difference produces a number that looks like a ratio but describes a trade nobody would make. Simple dominance is easy to spot on a cost-effectiveness plane (cost on the vertical axis, effect on the horizontal axis): A sits up and to the left of B, in the "worse in every way" quadrant relative to B.

Extended dominance is subtler and is the piece most newcomers miss. A treatment can fail to be dominated by *any single alternative* and still be inefficient, because it is dominated by a *mix* of two other treatments. Picture three non-dominated options B, C, and D, ordered by increasing cost and increasing effect, plotted on the cost-effectiveness plane. Draw a straight line connecting B and D. If C's point lies *above* that line — more costly, for its effect, than some hypothetical blend of B and D obtained by giving a fraction of patients B and the rest D — then C is extendedly dominated. A decision-maker could, in principle, achieve C's average effectiveness at lower average cost by mixing B and D (or, more realistically, by simply recognising that C offers a worse incremental trade than the B-to-D step does directly). C is therefore excluded from the efficient set, even though neither B nor D alone beats it on both cost and effect.

This geometric test — lying above the line connecting the two neighbouring non-dominated points — is exactly equivalent to a numerical test you will use constantly from here on: C is extendedly dominated whenever its ICER against the next-cheaper non-dominated option exceeds its ICER against the next-more-expensive one. When ICERs stop increasing monotonically as you move up the cost ranking, you have found an extended-dominance violation, and the offending option drops out.

Once all simply and extendedly dominated options are removed, what remains is the *efficiency frontier*: the set of treatments for which every additional unit of cost buys you additional effect at a non-decreasing rate, when you walk the ranking from cheapest to most expensive. Plotted on the cost-effectiveness plane, the frontier is a piecewise-linear curve connecting these surviving points, convex from below, with ICERs between adjacent segments that rise (or stay flat) as you move rightward. Any point below this curve is infeasible given the available technologies; any point above it (whether literally dominated or extendedly dominated) is inefficient and has already been pruned.

This is why the rule — compare adjacent alternatives, not an arbitrary comparator — is not a stylistic preference but a structural necessity. An ICER is only interpretable as "the price of the next increment of health" when the two options being compared are *adjacent on the frontier*: nothing cheaper-and-nearly-as-effective, and nothing dearer-and-better, sits between them. Comparing a frontier option against a non-adjacent one, or against something that should already have been eliminated, manufactures a ratio with no decision-relevant meaning, however clean the arithmetic looks.

#pitfall[
  A persistent error in student work and, occasionally, in submitted dossiers: computing the ICER of a new treatment against "standard of care" without first checking whether standard of care, or the new treatment, has been dominated or extendedly dominated by something else in the comparator set. Always sort by cost, strip out simply dominated options, check for and strip out extendedly dominated options, *then* compute ICERs only between what remains, moving strictly from one adjacent frontier point to the next. An ICER against a non-adjacent or dominated comparator is not merely imprecise — it is answering a question nobody asked.
]

#agency-note[
  NICE's health technology evaluation manual (PMG36, 2022) is explicit that analyses submitted for appraisal should present a *fully incremental analysis*: all relevant, non-dominated comparators ranked by cost, with ICERs reported between adjacent options on the efficiency frontier, rather than a series of pairwise comparisons against a single fixed comparator chosen by the manufacturer. The ISPOR-SMDM Modeling Good Research Practices Task Force reports (Caro et al., 2012, published in *Value in Health* and *Medical Decision Making*) reinforce the same expectation for decision-analytic models generally: dominated and extendedly dominated strategies must be identified and excluded before any ICER is presented as evidence for reimbursement decision-making.
]

== 4.8 Coding a first simple CEA in R

Three chapters of scaffolding — ICER notation, the HTA agency landscape, the four callout conventions you've been reading throughout this book, and a tour of `dplyr`, `purrr`, and function-writing in R — have all been building toward this moment. This is the first section in the entire book where R code actually *performs a health-economic calculation* rather than illustrating a general-purpose programming idiom. Everything from here on builds on the pattern you are about to write: a tidyverse pipeline that takes raw cost and effect data, prunes it down to an efficiency frontier, and reports incremental results. Treat this as a milestone worth lingering on — type it in, run it, and watch the frontier logic from §4.7 fall out of five `dplyr` verbs.

The toy scenario: a hypothetical chronic condition with four candidate treatments — a generic standard of care and three newer options — each characterised, for this illustration, by a single deterministic cost and a single deterministic QALY estimate (we are deliberately ignoring uncertainty for now; Chapter 25 will put proper probabilistic distributions around every one of these point estimates and propagate them through exactly this kind of frontier logic via probabilistic sensitivity analysis).

```r
library(dplyr)
library(tibble)

# Step 1: define the toy treatment data -------------------------------
treatments <- tibble(
  treatment = c("Standard Care", "Drug A", "Drug B", "Drug C"),
  cost      = c(1200,            4800,     5100,     9000),
  qaly      = c(0.62,            0.81,     0.74,     0.95)
)

treatments
```

The data frame has one row per treatment and exactly the two columns a cost-effectiveness analysis needs at minimum: `cost` and `qaly`. Note that Drug B costs more than Drug A but delivers *fewer* QALYs — a hint of trouble we'll let the pipeline catch rather than spotting it by eye.

```r
# Step 2: rank treatments from cheapest to most expensive --------------
ranked <- treatments |>
  arrange(cost)

ranked
```

```r
# Step 3: remove simply dominated treatments ----------------------------
# A treatment is simply dominated if some cheaper treatment already
# delivers equal or greater QALYs. We flag and drop these before doing
# any incremental arithmetic at all.
remove_simple_dominance <- function(df) {
  df <- df |> arrange(cost)
  keep <- logical(nrow(df))
  best_qaly_so_far <- -Inf
  for (i in seq_len(nrow(df))) {
    if (df$qaly[i] > best_qaly_so_far) {
      keep[i] <- TRUE
      best_qaly_so_far <- df$qaly[i]
    } else {
      keep[i] <- FALSE   # cheaper option already matches/beats this QALY
    }
  }
  df |> filter(keep)
}

non_dominated <- remove_simple_dominance(ranked)
non_dominated
```

Running this on our four rows drops Drug B: it costs more than Drug A (£5,100 vs £4,800) while delivering fewer QALYs (0.74 vs 0.81) — textbook simple dominance from §4.7. Standard Care, Drug A, and Drug C survive, each cheaper-but-worse or dearer-but-better than its neighbour.

```r
# Step 4: check for extended dominance -----------------------------------
# A survivor of simple dominance can still be extendedly dominated if its
# ICER against the next-cheaper option exceeds its ICER against the
# next-more-expensive option (i.e. ICERs are not rising as cost rises).
check_extended_dominance <- function(df) {
  df <- df |>
    arrange(cost) |>
    mutate(
      icer_vs_prev = (cost - lag(cost)) / (qaly - lag(qaly))
    )

  repeat {
    icers <- df$icer_vs_prev
    violation <- which(icers < lag(icers))[1]  # ICER drops vs previous step
    if (is.na(violation) || length(violation) == 0) break
    df <- df |>
      filter(treatment != df$treatment[violation]) |>
      mutate(icer_vs_prev = (cost - lag(cost)) / (qaly - lag(qaly)))
  }
  df
}

frontier <- check_extended_dominance(non_dominated)
```

With only three survivors in this toy example, ICERs happen to rise monotonically already (Standard Care → Drug A → Drug C), so no further rows are removed — but the function is written generally, re-checking after every removal, exactly as it would need to for a larger comparator set where extended dominance bites.

```r
# Step 5: build the final frontier table of incremental results ---------
results <- frontier |>
  arrange(cost) |>
  mutate(
    incr_cost = cost - lag(cost),
    incr_qaly = qaly - lag(qaly),
    icer      = incr_cost / incr_qaly
  ) |>
  select(treatment, cost, qaly, incr_cost, incr_qaly, icer)

print(results, digits = 2)
```

```
# A tibble: 3 x 6
  treatment      cost  qaly incr_cost incr_qaly   icer
  <chr>         <dbl> <dbl>     <dbl>     <dbl>  <dbl>
1 Standard Care  1200  0.62        NA        NA     NA
2 Drug A         4800  0.81      3600      0.19  18947
3 Drug C         9000  0.95      4200      0.14  30000
```

Read this table exactly as §4.7 told you to: Standard Care is the frontier's starting point (no comparator cheaper than it exists in this set, so its incremental row is `NA`). Moving to Drug A costs an incremental £18,947 per additional QALY. Moving on from Drug A to Drug C — *not* from Standard Care to Drug C — costs an incremental £30,000 per QALY. Drug B never appears because it was eliminated at Step 3, and no row anywhere compares a treatment to a non-adjacent option. That rising sequence of ICERs, £18,947 then £30,000, is the numerical signature of a valid, extended-dominance-checked efficiency frontier.

#figure(
  image("../images/r_generated/ch04_ce_plane_frontier.png", width: 85%),
  caption: [The cost-effectiveness plane for the four-treatment toy example. Drug B (orange) sits above and to the left of Drug A — more expensive, fewer QALYs — and is excluded from the frontier at Step 3. The blue line connects the three surviving, non-dominated treatments in the order the efficiency frontier is built: Standard Care, then Drug A, then Drug C.],
) <fig-ch04-ce-plane>

#report-table(
  [How the four-treatment frontier analysis would be reported: dominance status, survival of pruning, and the ICER against the next-cheaper non-dominated option.],
  academic-table(
    columns: (1.3fr, auto, auto, 1.5fr, auto),
    align: (left, right, right, left, right),
    header: ([*Treatment*], [*Cost (GBP)*], [*QALYs*], [*Dominance status*], [*ICER vs next-cheaper (GBP/QALY)*]),
    body: (
      [Standard Care], [1,200], [0.62], [On frontier (reference)], [--],
      [Drug A], [4,800], [0.81], [On frontier], [18,947],
      [Drug B], [5,100], [0.74], [Simply dominated by Drug A (higher cost, fewer QALYs)], [Excluded],
      [Drug C], [9,000], [0.95], [On frontier], [30,000],
    ),
    footer: (table.cell(colspan: 5)[*Note:* ICERs are reported only between adjacent frontier survivors (Standard Care → Drug A → Drug C). Drug B is excluded by simple dominance at Step 3 and never receives an ICER. No extended-dominance violation occurs in this toy data set, since ICERs rise monotonically (£18,947 then £30,000) along the surviving sequence.],),
  ),
) <tab-ch04-frontier-reporting>

#heor-practice[
  Wrap Steps 3–5 into a single reusable function, say `build_frontier(df)`, that takes any `treatment`/`cost`/`qaly` tibble and returns the pruned, incrementally-costed frontier table. You will reuse this exact pattern — rank by cost, strip simple dominance, strip extended dominance, compute adjacent increments — every time a new decision problem in this book has more than two comparators, including the Markov and partitioned-survival models from Part IV.
]

#pitfall[
  It is tempting to skip straight to `mutate(icer = (cost - cost[1]) / (qaly - qaly[1]))` — comparing everything back to the first row. This silently computes ICERs against a *fixed* baseline rather than the *adjacent* frontier comparator, and it will happily produce a number even for a dominated treatment that should have been deleted at Step 3. Always run the dominance-removal steps first, and always difference against `lag()` on a cost-sorted, already-pruned tibble — never against row 1 by position.
]

The point estimates in `results` — one cost, one QALY, one ICER per frontier step — are exactly what Chapter 25 will revisit and turn probabilistic: instead of a single `cost = 4800` for Drug A, you will eventually draw thousands of plausible costs and QALYs from distributions, run this same dominance-and-increment logic on each draw, and summarise the resulting cloud of ICERs with a cost-effectiveness acceptability curve. For now, savor the deterministic version — this five-step `dplyr` pipeline, however small the toy data set, is a complete, decision-grade cost-effectiveness analysis, correctly respecting every rule about dominance and frontiers that §4.7 just laid out.
