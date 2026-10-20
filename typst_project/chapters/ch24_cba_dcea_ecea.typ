#import "../common.typ": *

= Chapter 24. Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis

#learning-objectives((
  [Explain how cost-benefit analysis (CBA) differs from cost-effectiveness analysis (CEA) by monetizing both sides of the value equation, and describe the value of a statistical life (VSL), human-capital, and willingness-to-pay approaches used to do so.],
  [Explain why a population-average ICER can mask unequal distribution of costs and benefits, and apply distributional cost-effectiveness analysis (DCEA) and equity weighting to make that distribution explicit.],
  [Compute an extended cost-effectiveness analysis (ECEA) financial-risk-protection outcome -- catastrophic health expenditure cases averted and poverty cases averted -- alongside a conventional health outcome.],
  [Build a simple multi-criteria decision analysis (MCDA) scoring pipeline in R, distinguishing weighted-sum from weighted-product combination, and relate it to the EVIDEM health-sector MCDA framework.],
  [Apply NICE's severity modifier to an ICER using the absolute and proportional QALY shortfall, and distinguish value-based pricing and the two broad types of managed entry agreement (MEA).],
))

Chapters 17 through 23 shared one quiet convention: health is measured
in health units (QALYs, life-years, cases averted) and only cost is
measured in money, with the two combined into a cost-per-QALY ratio
compared against a threshold, or — in Chapter 23's budget impact
analysis — reduced to an undiscounted payer cash-flow question with no
health outcome in the calculation at all. This closing chapter of Part
IV steps outside that convention in five different directions: methods
that monetize health itself (cost-benefit analysis), methods that make
visible who actually receives an intervention's costs and benefits
(distributional CEA), methods that add a second, non-health outcome
dimension entirely (extended CEA's financial risk protection), methods
that formalize decision criteria beyond cost and a single health
outcome (multi-criteria decision analysis), and mechanisms that adjust
the price or threshold side of the value equation directly (severity
modifiers, value-based pricing, managed entry agreements). None of
these replace the cost-effectiveness machinery built across Chapters
17-23 — each is a genuine extension or alternative lens applied to it.

== 24.1 Monetary valuation of health

Every model built in Chapters 17 through 23 has shared one convention
without ever stating it as a choice: health is measured in *health
units* -- quality-adjusted life years (QALYs), life years, or cases
averted -- and only cost is measured in money. The result, an
incremental cost-effectiveness ratio (ICER) in cost per QALY, lets an
analyst compare interventions to each other and to a decision-maker's
willingness-to-pay threshold, but it never actually monetizes the
health benefit itself. Cost-benefit analysis (CBA) makes the different,
more demanding choice of converting *both* sides of the ledger -- costs
and health benefits -- into the same monetary unit, so that a single
net monetary figure (benefits minus costs, in dollars or pounds) can be
compared against zero, or against the net benefit of competing uses of
the same money entirely outside healthcare. This section covers how
that monetization of health is actually done, and why the choice of
method has mattered, for decades, well beyond health economics.

=== Why monetize health at all

CEA answers "which of these health interventions gives the most health
per dollar spent," holding the healthcare budget's boundary fixed and
implicit. It cannot, by construction, answer "is this health programme
worth it compared with building a bridge, funding a school, or leaving
the money with taxpayers" -- because health is in one unit (QALYs) and
the alternative use of the money is in another (dollars). Government-wide
regulatory analysis -- transport safety rules, environmental
regulations, workplace safety standards -- routinely has to make exactly
that comparison, and it is CBA's capacity to put a dollar value on a
human life or a QALY that allows it. This is also the reason CBA
appears far more often in environmental and transport-safety economics
than in national HTA decision-making for medicines: most national HTA
bodies (NICE, Australia's PBAC, Canada's CADTH) formally compare within
the health budget using CEA, not CBA, precisely so they are not forced
to state an explicit dollar value of a human life as part of a medicines
appraisal. CBA's natural territory in health is broader public-health
and regulatory decisions where money, not just the health budget, is
genuinely the alternative use of the resource.

#difficult-terminology("Cost-benefit analysis (CBA) vs. cost-effectiveness analysis (CEA)")[
Both methods compare an intervention's incremental cost against its
incremental benefit, but they differ in what unit the *benefit* side is
measured in. CEA (and its close relative, cost-utility analysis, used
throughout this book) measures benefit in natural health units -- QALYs,
life-years gained, cases prevented -- and reports a ratio, cost per unit
of health, which is only interpretable relative to a threshold or to
another intervention's ratio. CBA measures *both* cost and benefit in
money, so it can report a single net figure (total monetized benefit
minus total cost) that is directly interpretable on its own: a positive
net benefit means the intervention is worth doing in resource terms,
full stop, without reference to any other intervention. The price of
that convenience is that CBA requires converting health into money
somewhere in the calculation -- via a value of a statistical life, a
human-capital earnings calculation, or a willingness-to-pay survey --
and that conversion is itself a value judgement, not a neutral
measurement, which is why CEA remains the dominant method inside
formal drug/device HTA while CBA remains dominant in transport,
environmental, and occupational safety regulation.
]

=== Value of a statistical life (VSL)

The value of a statistical life (VSL) is the dominant monetization
method in regulatory CBA, and it is routinely misunderstood even by
people who use the number professionally, so it is worth stating
precisely what it is *not* before stating what it is.

#difficult-terminology("Value of a statistical life (VSL)")[
VSL is not an attempt to price any individual, identified person's
life -- regulators and economists are emphatic about this, because the
phrase invites exactly that misreading. VSL instead aggregates small,
individual willingness-to-pay amounts for *small reductions in mortality
risk* into an implied value for "one statistical death avoided" across a
large group. The canonical illustration: suppose each of 100,000 people
would pay \$100 for a programme that reduces each person's own annual
risk of death by 1 in 100,000. That risk reduction, summed across the
group, means the group expects one fewer death per year on average.
Total willingness to pay is 100,000 times \$100 = \$10,000,000, and
because that total buys exactly one statistical death avoided, the VSL
implied by this group's preferences is \$10 million. No single person in
the group paid \$10 million, and no one's actual death was priced --
what was priced is the *risk reduction*, at the rate people actually
revealed they would pay for it. VSL estimates are built empirically from
either stated-preference surveys (asking people directly what they would
pay for risk reductions) or revealed-preference studies (inferring the
implicit value of safety from real choices, most famously wage
differentials that workers demand to accept riskier jobs -- the
"hedonic wage" method).
]

VSL estimates vary substantially by agency, country, and year, because
each reflects a different underlying survey/wage-differential evidence
base and a different real-income base year. The US Department of
Transportation's guidance recommended \$13.2 million (2023 dollars) for
regulatory analysis, an upward revision from \$12.5 million (2022
dollars) to account for both general inflation and real income growth;
the US EPA's standing default, built on a different literature base, is
\$7.4 million in 2006 dollars (updated for inflation when applied); HHS's
2024 standard values set a central estimate of \$13.1 million with a low
of \$6.1 million and a high of \$19.9 million, explicitly carried through
regulatory sensitivity analysis rather than collapsed to one number.
These are not competing "right answers" to the same question -- they are
different agencies' considered choices from a literature that itself
spans a wide range, and the spread is wide enough (roughly \$6 million to
\$20 million, a more than threefold range) that the choice of VSL is
frequently the single most consequential, and most contested, input in
any regulatory CBA.

#pitfall[
Do not treat a VSL figure from one jurisdiction, sector, or year as a
portable universal constant. A VSL estimated from US wage-risk data in
transport safety regulation reflects the income level, labour market,
and risk perceptions of that specific population and context; applying
it unadjusted to, say, a vaccination programme's mortality benefit in a
different country with a different income level systematically
mis-states willingness to pay. Where cross-country or cross-sector VSL
transfer is unavoidable, published guidance (OECD, WHO) recommends
income-elasticity adjustment, not a flat transfer of the headline number.
]

=== Human capital vs. willingness-to-pay approaches

Once the decision is made to monetize health, there are two
historically distinct, philosophically different ways to do it.

The *human capital approach* values a health improvement (or the cost of
a health loss) as the *production* it enables or prevents losing --
typically approximated by discounted future earnings. A death or
disabling illness in a working-age adult is valued, under this
approach, as the present value of the earnings that person would have
produced had they remained healthy and working. As a worked
illustration: a person earning \$45,000 a year who would otherwise have
worked 10 more years, discounted at 3% per year, represents a human
capital value of

$ "PV" = sum_(t=0)^(9) 45000 / 1.03^t = 395375 $

(computed directly by summing the ten discounted annual terms; the
closed-form annuity formula gives the identical figure).

#difficult-terminology("Human capital approach")[
This is the older of the two monetization approaches, borrowed directly
from labour economics: a person's economic worth is approximated by
their expected lifetime earnings, so health is valued by how much
earning capacity it protects or restores. It is straightforward to
compute from wage and life-table data, which is why it was the default
approach for decades, but it has a well-known, severe equity problem: it
systematically values the health of children, retirees, unpaid
caregivers, and anyone outside paid employment at zero or near-zero,
and values the health of a high earner more than the identical health
gain in a low earner, purely because of their market wage. A retired
80-year-old grandparent's quality of life gain from a hip replacement
has genuine value to them and their family, but the human capital
approach records essentially none of it, because they produce no
market earnings. This flaw is the single biggest reason the willingness-
to-pay approach displaced human capital as the preferred method in
modern welfare-economic practice.
]

The *willingness-to-pay (WTP) approach* instead asks what people
themselves would pay for a health improvement, independent of their
earning capacity -- the same conceptual move underlying VSL above,
generalized to morbidity as well as mortality. WTP can be elicited
directly (contingent valuation surveys asking "how much would you pay
for X% reduction in your risk of Y") or indirectly (revealed preference
from real spending and risk-taking behaviour, including the hedonic wage
method). WTP is grounded in welfare economics' standard definition of
value -- what an individual would sacrifice to obtain something, which
by construction captures the value of health to retirees, children, and
unpaid carers as fully as to high-earning professionals, since it
depends on each person's own preferences and budget constraint rather
than their market wage.

#difficult-terminology("Willingness-to-pay (WTP) approach")[
WTP asks, directly or indirectly, how much money a person would be
willing to give up to obtain a health benefit (or avoid a health harm),
and uses that amount as the monetary value of the benefit. The appeal is
philosophical consistency with how economists value everything else --
goods, services, environmental amenities -- by the preferences of the
people who hold them, not by any external judgement of worth. The
practical difficulty is that stated-preference surveys are vulnerable to
hypothetical bias (people answering a survey question differently than
they would act with real money on the line) and to the fact that WTP for
health is mechanically constrained by ability to pay -- a poor person's
WTP for an identical health gain is, by definition, capped by a smaller
budget than a rich person's, which reintroduces an income-related
distortion from a different direction than human capital's wage
distortion. Neither approach is therefore equity-neutral; they are
differently non-neutral, and that difference is a live methodological
debate, not a solved problem.
]

#ref-table(
  [Comparing the two main approaches to monetizing health, and VSL as a specific instance of the WTP approach],
  academic-table(
    columns: (1.1fr, 1.6fr, 1.6fr),
    align: (left, left, left),
    header: ([*Approach*], [*How health is valued*], [*Main limitation*]),
    body: (
      [Human capital], [Discounted future earnings the person would otherwise have produced], [Values non-earners (children, retirees, carers) near zero; values identical health gains differently by wage],
      [Willingness-to-pay (general)], [What the person themselves would pay for the health improvement, by survey or revealed behaviour], [Vulnerable to hypothetical bias in stated-preference surveys; WTP mechanically limited by ability to pay],
      [Value of a statistical life (VSL)], [Aggregated WTP for small mortality-risk reductions, scaled up to an implied value per statistical death avoided], [Wide variation across agencies/years (roughly \$6M to \$20M in current US federal guidance); not transferable across country/sector without income-elasticity adjustment],
    ),
  ),
) <tab-ch24-vsl-comparison>

#heor-practice[
If you are asked to build a CBA rather than a CEA -- most often for a
public-health, environmental, or occupational-safety programme rather
than a medicines HTA submission -- the single most important design
decision is which VSL or WTP-per-QALY source to use, and that choice
should be stated and justified as explicitly as a discount rate choice,
with the resulting net benefit re-run across the published low/central/
high range (as HHS and DOT both now do natively) rather than reported as
a single deterministic figure. A CBA that reports only the central VSL
estimate, with no sensitivity range, understates how much the
bottom-line conclusion depends on a contested input.
]

== 24.2 Distributional CEA and equity weighting

Every ICER computed in Chapters 17 through 23 was a *population-average*
figure: total incremental cost divided by total incremental QALYs,
across the whole modelled cohort. An intervention with an attractively
low average ICER can still deliver its costs and its health gains very
unevenly across subgroups -- by income, by disease severity, by
ethnicity, by geography -- and a decision based on the average alone is
blind to that distribution. Distributional cost-effectiveness analysis
(DCEA) is the methodology, developed principally at the University of
York's Centre for Health Economics and used in UK policy analysis
feeding into NICE's thinking on equity, that makes this distribution
visible and lets a decision-maker weigh it explicitly against the
average result.

=== Why the average can mask unequal distribution

Consider a screening programme that, on average across the eligible
population, is highly cost-effective. If uptake, benefit, and cost are
not spread evenly -- say the programme is taken up disproportionately by
the least deprived quintile (who are more likely to attend screening
appointments, more health-literate, and more likely to act on a positive
result), while the opportunity cost of funding it (displaced spending
elsewhere in a fixed healthcare budget) falls more heavily, in relative
terms, on more deprived groups who rely more on the services being
displaced -- the same average ICER could correspond to a programme that
*widens* health inequality even as it looks efficient on paper. This is
not a hypothetical concern: it is the precise finding of the DCEA
literature's most-cited applied example, Asaria and colleagues' analysis
of targeted versus universal reminder strategies to increase uptake of
bowel cancer screening in England, which found that a targeted strategy
produced a *smaller* total health gain than a universal strategy but a
*larger* reduction in health inequality across deprivation groups --
precisely the kind of efficiency-equity divergence that a single
population-average ICER cannot show.

#difficult-terminology("Distributional cost-effectiveness analysis (DCEA)")[
DCEA extends ordinary CEA by disaggregating costs and health effects
across equity-relevant subgroups -- most commonly socioeconomic
deprivation quintiles, but also severity of illness, ethnicity, age, or
geography -- rather than collapsing everything into one population-wide
average. It explicitly accounts for *opportunity costs*: health gained
by the new intervention has to be weighed against the health that would
have been produced by whatever existing care gets displaced to fund it,
and that displaced care's benefit is itself unevenly distributed (the
population groups who rely most on the services being cut back are not
necessarily the same groups who benefit most from the new intervention).
The output is not a single number but a *distribution* -- how much
health gain, and how much health opportunity cost, each subgroup
experiences -- which can then be summarized with an inequality metric
and, if the decision-maker wants, combined with the overall
cost-effectiveness result into a single equity-weighted social welfare
index. Crucially, DCEA was built specifically to answer questions that
an average ICER structurally cannot: not just "is this good value on
average" but "who gains, who loses, and does this intervention narrow or
widen existing health inequality."
]

=== Equity weighting and the equity-efficiency impact plane

Once subgroup-level health effects are visible, a decision-maker who
cares about both total health and its distribution needs some way to
combine the two into a judgement. Cookson and colleagues' widely-cited
framework for this -- developed with, and published through, the
DCEA/York tradition -- is the *equity impact plane*: a two-dimensional
chart with the ordinary cost-effectiveness/net-health-benefit result on
one axis and a summary measure of the intervention's net equity impact
(for example, its effect on the gap in health between the most and least
deprived groups) on the other. A programme that improves *both* total
health and equity sits in the unambiguous "win-win" quadrant; one that
harms both sits in "lose-lose" -- in neither case is there a genuine
trade-off to make. The interesting, and most common, real-world cases
are the other two quadrants: a programme that improves total health but
*worsens* equity (efficient but unfair), or one that *narrows* health
inequality at the cost of some total health forgone (fair but less
efficient). Only in these two quadrants does equity weighting -- putting
an explicit numeric weight on health gains or losses according to which
group receives them, typically weighting gains to more deprived groups
more heavily than identical gains to less deprived groups -- do
real analytical work, because only there does giving more weight to
equity actually change which option looks best.

#difficult-terminology("Equity weighting")[
An equity weight is a multiplier, greater than 1 for a disadvantaged
group and often fixed at 1 for the reference (typically least deprived
or least severely ill) group, applied to the health gain or loss that
group experiences before it is summed into a decision metric. A weight
of 1.5 for the most deprived quintile means the analysis is deliberately
treating one QALY gained by that group as "worth" 1.5 ordinary QALYs for
decision-making purposes -- not because it is a biologically different
QALY, but as an explicit value judgement that reducing health inequality
has worth beyond the raw health gained. The weight itself is not an
empirical fact to be estimated from data; it is a social-value judgement
that has to come from somewhere -- published equity weights have been
derived from general-population surveys asking people directly how they
would trade off total health against equity, from elicited parameters in
formal social welfare functions, or simply specified as a range for
sensitivity analysis so a decision-maker can see how much the ranking of
options changes as the weight increases from 1 (pure efficiency) upward.
Equity weighting is a tool for making a value judgement *transparent and
quantified*, not a tool for removing the value judgement altogether.
]

#pitfall[
Do not present an equity-weighted ICER as though it were a more
"accurate" or "corrected" version of the unweighted ICER. The two numbers
answer different questions under different ethical premises: the
unweighted ICER answers "what is the cost per QALY if every QALY counts
equally regardless of who receives it," and the equity-weighted ICER
answers "what is the cost per QALY if we have decided, as a value
judgement, that QALYs gained by a specified disadvantaged group count
for more." Reporting only the equity-weighted figure smuggles in a
contestable ethical position as if it were a technical correction;
reporting only the unweighted figure silently assumes that distribution
never matters. Good practice, consistent with the equity impact plane's
purpose, is to report both, plus the specific equity weight used and a
plausible range around it, so the decision-maker sees exactly how much
of the conclusion depends on the equity judgement rather than the
efficiency evidence.
]

=== A toy two-subgroup worked example

The arithmetic of equity weighting is simple enough to verify by hand,
which is the point of walking through a toy example before trusting any
larger model's output. Suppose a screening intervention is rolled out to
two equal-sized subgroups of 1,000 patients each -- an income-quintile-5
(least deprived) group and an income-quintile-1 (most deprived) group --
at an identical cost of \$2,000 per patient in both groups, but with a
*larger* QALY gain in the most deprived group (0.12 QALYs per patient)
than in the least deprived group (0.08 QALYs per patient), reflecting
that the most deprived group has more untreated disease burden to begin
with and so more capacity to benefit.

```r
library(dplyr)

subgroups <- tibble::tibble(
  group           = c("Q1_most_deprived", "Q5_least_deprived"),
  n_patients      = c(1000, 1000),
  cost_per_pt     = c(2000, 2000),
  qaly_gain_pt    = c(0.12, 0.08),
  equity_weight   = c(1.5, 1.0)   # Q1 QALYs up-weighted 1.5x; Q5 left at 1.0
)

subgroups <- subgroups |>
  mutate(
    total_cost        = n_patients * cost_per_pt,
    total_qaly        = n_patients * qaly_gain_pt,
    weighted_qaly      = total_qaly * equity_weight
  )

total_cost          <- sum(subgroups$total_cost)
total_qaly          <- sum(subgroups$total_qaly)
total_weighted_qaly <- sum(subgroups$weighted_qaly)

icer_unweighted <- total_cost / total_qaly
icer_weighted   <- total_cost / total_weighted_qaly

subgroups
icer_unweighted   # cost per unweighted QALY
icer_weighted     # cost per equity-weighted QALY
```

Working the arithmetic through by hand, exactly as `R` would: total
cost is \$2,000 times 2,000 patients = \$4,000,000. Total unweighted
QALYs are (1,000 times 0.12) + (1,000 times 0.08) = 120 + 80 = 200, so
the unweighted ICER is \$4,000,000 / 200 = *\$20,000 per QALY*. Applying
the 1.5x equity weight to the most-deprived group's QALYs only, total
equity-weighted QALYs become (120 times 1.5) + (80 times 1.0) = 180 + 80
= 260, so the equity-weighted ICER is \$4,000,000 / 260 = *\$15,384.62
per QALY* (both figures independently verified by direct calculation,
not just the R output).

#report-table(
  [Unweighted vs. equity-weighted ICER for a toy two-subgroup screening example (equity weight of 1.5 applied to the most-deprived quintile's QALYs)],
  academic-table(
    columns: (1.6fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Metric*], [*Q1 (most deprived)*], [*Q5 (least deprived)*], [*Total / combined*]),
    body: (
      [Patients], [1,000], [1,000], [2,000],
      [Cost per patient], [\$2,000], [\$2,000], [--],
      [Total cost], [\$2,000,000], [\$2,000,000], [\$4,000,000],
      [QALY gain per patient], [0.12], [0.08], [--],
      [Total unweighted QALYs], [120], [80], [200],
      [Equity weight applied], [1.5], [1.0], [--],
      [Total equity-weighted QALYs], [180], [80], [260],
    ),
    footer: (
      table.cell(colspan: 4)[*Unweighted ICER: \$20,000/QALY -- Equity-weighted ICER: \$15,384.62/QALY*],
    ),
  ),
) <tab-ch24-dcea-toy>

The direction of the effect is the point of the illustration, not the
specific weight chosen: because the equity weight was applied to the
subgroup that was *already* receiving the larger QALY gain, up-weighting
that subgroup's QALYs makes the intervention look *more* cost-effective
once equity is taken into account (\$15,384.62/QALY under equity
weighting versus \$20,000/QALY unweighted) -- the two objectives happen
to point the same way here, a "win-win" case on the equity impact plane.
Had the most-deprived group instead received the *smaller* QALY gain (an
intervention that, for example, is more efficiently delivered to the
already-healthier, less deprived group), the same equity weighting
exercise would move the two ICERs in *opposite* directions, producing
the genuine trade-off the equity impact plane exists to visualize: a
result that is efficient on average but regressive in its distribution,
with the equity-weighted ICER numerically worse than the unweighted one.

#agency-note[
NICE does not currently apply a formal numeric equity weight inside its
standard reference-case cost-utility analysis for technology appraisals
-- the reference case remains an unweighted QALY, consistent with the
"a QALY is a QALY" principle also used throughout Chapters 17-23 of this
book. Equity considerations instead enter NICE decision-making through
separate mechanisms: a modifier for end-of-life treatments, severity
modifiers introduced in 2022 that increase the acceptable cost-per-QALY
threshold for diseases causing a larger absolute QALY loss, and
qualitative equity considerations raised by committees outside the
numeric ICER itself. DCEA and formal equity weighting, by contrast, are
used as *supplementary* analytical tools -- commissioned research,
academic analyses feeding into broader policy debate, and in some
non-UK jurisdictions' extended CEA work (Section 24.3) -- rather than as
a mandatory step inside every submitted reference-case model. Knowing
which regime you are modelling for determines whether an equity-weighted
ICER is an expected deliverable or a supplementary exhibit.
]

== 24.3 Extended cost-effectiveness analysis: financial risk protection

Every method in this book so far shares one structural assumption: health gain -- a QALY, a DALY averted, a life-year -- is the only outcome dimension that matters once costs are on the table. That assumption is reasonable in a high-income system with near-universal insurance, where a diagnosis rarely bankrupts a household. It is far less reasonable in a low- or middle-income country (LMIC) context with large out-of-pocket (OOP) health spending, where the *same* clinical event -- a TB diagnosis, a complicated delivery, a cancer admission -- can simultaneously improve health and push a family into poverty. Extended cost-effectiveness analysis (ECEA, also written eCEA or EEA) is the method built specifically to put that second consequence on the same footing as the first.

ECEA originates from the Disease Control Priorities Network's third edition (DCP3) and the associated Gates Foundation-funded programme of work, most closely associated with Stéphane Verguet and colleagues (Verguet, Laxminarayan & Jamison 2015; Verguet, Kim & Jamison 2016). Its central move is to compute, alongside the conventional health and cost outcomes, an explicit *financial risk protection* (FRP) outcome: how many households are protected from catastrophic health expenditure, or from falling into poverty, by a policy -- a public health programme, a subsidy, an insurance expansion -- that reduces out-of-pocket spending. A policy can therefore be judged cost-effective on health grounds *and* valuable on financial-protection grounds, and the two numbers are reported side by side rather than collapsed into one.

#difficult-terminology("Catastrophic health expenditure (CHE)")[
A household's health spending is classified as *catastrophic* when it exceeds some fixed fraction of the household's income or total consumption in a given period -- a common convention, and the one used in this section's worked example, is 10% of income, though national studies sometimes use 25% or 40% depending on the policy question. The threshold is arbitrary in the same way a p-value threshold of 0.05 is arbitrary: it is a convention chosen to be policy-relevant, not a biologically or economically derived cut point. The intuition is simple even though the word sounds technical -- a household earning \$1,000 a year that pays \$150 out of pocket for a hospitalization (15% of income) has crossed a 10% catastrophic-expenditure threshold, whereas a household earning \$10,000 paying the same \$150 (1.5% of income) has not, even though both households spent an identical dollar amount. This is precisely why ECEA tracks financial risk protection *by income quintile* rather than as a single population-wide number: the same absolute OOP cost has a completely different welfare consequence depending on where a household sits in the income distribution, which a conventional CEA computed only in aggregate cost and aggregate QALYs would never reveal.
]

#difficult-terminology("Poverty cases averted")[
This is ECEA's second, related financial-risk-protection metric, counting a different event: not whether spending crossed a fixed percentage-of-income threshold, but whether spending pushed a household's *remaining* income below an absolute poverty line (e.g. a national or international \$-per-day poverty line) that it would otherwise have stayed above. A household can face catastrophic expenditure without being pushed into poverty (a wealthy household spending 15% of a large income), and a household can be pushed into poverty by health spending that is not catastrophic by the 10% convention (a household just above the poverty line paying a moderate OOP amount that is nonetheless enough to tip it under the line). Verguet, Olson and colleagues' original formulation (DCP3, 2015-2017) treats poverty-cases-averted and CHE-cases-averted as complementary, not interchangeable, FRP metrics -- a full ECEA reports both where data allow, and this section's worked example computes both for exactly that reason.
]

The conceptual shift ECEA makes relative to the cost-effectiveness analyses built in Chapters 17-22 is best stated plainly: a standard CEA asks "how much health does this buy, and at what cost to the payer or health system." ECEA asks that question *and* a second one: "how much financial protection does this buy for the households who would otherwise have paid out of pocket, and how is that protection distributed across the income spectrum." Both outcomes come from the same underlying intervention and the same underlying cost data -- ECEA does not require a separate clinical trial or a separate cost study, only that OOP cost and household income data be available (or credibly imputed) alongside the clinical and system-cost data a conventional CEA already needs.

#agency-note[
ECEA was built for, and is used almost exclusively in, LMIC and universal-health-coverage (UHC) policy contexts -- WHO's UHC agenda, World Bank health-financing work, and country-level priority-setting exercises in settings such as India, Ethiopia, and Nigeria are the method's natural home. It is not a NICE or CADTH reference-case requirement, and it would be unusual to see a full ECEA in a UK or Canadian single-technology appraisal, where near-universal coverage makes catastrophic OOP spending largely a non-issue for the technologies under appraisal. Where this book's TB/India thread (Chapters 5, 9, 19, 21) is concerned, ECEA is exactly the kind of analysis that would accompany a universal-public-finance-for-TB-treatment policy question -- indeed, Verguet and colleagues' 2015 *Health Economics* paper, "Universal public finance of tuberculosis treatment in India: an extended cost-effectiveness analysis," is a direct, published instance of this method applied to this book's own running disease area and country setting.
]

*Worked example.* Consider a stylized version of exactly that India-TB policy question: a government is deciding whether to move from the status quo, in which TB patients pay a meaningful share of diagnosis and treatment costs out of pocket, to a universal-public-finance policy in which the government covers nearly all of those costs. We work this through for five income quintiles of 20,000 households each (100,000 households total), using simple uniform income distributions within each quintile band -- a simplification for illustration; a real ECEA would use an empirical household expenditure survey, not an assumed uniform distribution.

```r
library(dplyr)

ecea_frp <- function(
    quintile_income_bands = list(
      Q1 = c(300, 700),    Q2 = c(700, 1100),  Q3 = c(1100, 1700),
      Q4 = c(1700, 2700),  Q5 = c(2700, 5300)
    ),
    pop_per_quintile = 20000,
    oop_status_quo   = 150,   # $ per TB episode, status quo
    oop_new_policy    = 20,   # $ per TB episode, after universal public finance
    che_threshold     = 0.10, # 10% of income convention
    poverty_line      = 400   # $ per year
) {
  che_income_cutoff <- function(oop) oop / che_threshold

  frac_below <- function(cutoff, lo, hi) {
    pmax(0, pmin(1, (cutoff - lo) / (hi - lo)))
  }
  frac_in_interval <- function(lo, hi, a, b) {
    left  <- max(lo, a); right <- max(min(hi, b), left)
    (right - left) / (hi - lo)
  }

  bands <- tibble(
    quintile = names(quintile_income_bands),
    income_lo = sapply(quintile_income_bands, `[`, 1),
    income_hi = sapply(quintile_income_bands, `[`, 2)
  )

  thresh_sq  <- che_income_cutoff(oop_status_quo)
  thresh_new <- che_income_cutoff(oop_new_policy)

  bands %>%
    mutate(
      che_cases_sq    = frac_below(thresh_sq,  income_lo, income_hi) * pop_per_quintile,
      che_cases_new   = frac_below(thresh_new, income_lo, income_hi) * pop_per_quintile,
      che_averted     = che_cases_sq - che_cases_new,
      pov_cases_sq    = frac_in_interval(income_lo, income_hi,
                                          poverty_line, poverty_line + oop_status_quo) * pop_per_quintile,
      pov_cases_new   = frac_in_interval(income_lo, income_hi,
                                          poverty_line, poverty_line + oop_new_policy) * pop_per_quintile,
      pov_averted     = pov_cases_sq - pov_cases_new
    ) %>%
    select(quintile, che_cases_sq, che_cases_new, che_averted,
           pov_cases_sq, pov_cases_new, pov_averted)
}

frp_result <- ecea_frp()
frp_result
```

Working the arithmetic through by hand confirms the function's output. A household crosses the catastrophic-expenditure threshold when its income falls below $"OOP cost" / 0.10$: at the status-quo OOP cost of \$150 that cutoff is \$1,500, and at the new-policy OOP cost of \$20 it is \$200. Comparing those cutoffs against each quintile's income band: Q1 (\$300-\$700) is entirely below \$1,500, so all 20,000 households there are classified catastrophic under the status quo; the same is true of Q2 (\$700-\$1,100); Q3 (\$1,100-\$1,700) straddles \$1,500, so only the $(1500-1100)/(1700-1100) = 2/3$ of that band below the cutoff -- $13,333.3$ households -- are catastrophic; Q4 and Q5 sit entirely above \$1,500 and contribute zero. Summing gives $20,000 + 20,000 + 13,333.3 + 0 + 0 = 53,333.3$ catastrophic cases under the status quo. Under the new policy the \$200 cutoff falls below every quintile's income floor except Q1's, where only the share of the band below \$200 (an empty interval here, since Q1 starts at \$300) counts -- zero. So the new policy reduces catastrophic cases from 53,333.3 to 0, for *53,333.3 catastrophic health expenditure cases averted*, concentrated entirely in the poorest three quintiles.

The poverty calculation works differently: a household falls into poverty when its income sits just above the \$400 poverty line by no more than the OOP amount it pays, i.e. in the interval (\$400, \$400 + OOP). Under the status quo (OOP = \$150) that interval is (\$400, \$550), which overlaps only Q1's band (\$300-\$700): the overlap is (\$400, \$550), a width of \$150 out of Q1's \$400-wide band, giving $150/400 = 0.375$ of Q1's households, or $0.375 times 20,000 = 7,500$ poverty cases. Under the new policy (OOP = \$20) the interval shrinks to (\$400, \$420), a width of \$20 out of the same \$400 band, giving $20/400 = 0.05$, or $1,000$ poverty cases. The policy therefore averts $7,500 - 1,000 = 6,500$ poverty cases, again concentrated in Q1 -- exactly the pro-poor distributional pattern the DCP3 case studies (South Africa salt policy, Niger/China tobacco tax, India TB financing) consistently report.

#report-table(
  [Extended cost-effectiveness analysis: financial risk protection by income quintile, universal public finance of TB treatment versus status quo (illustrative).],
  academic-table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    header: (
      [*Quintile*], [*CHE cases, status quo*], [*CHE cases, new policy*],
      [*CHE cases averted*], [*Poverty cases averted*],
    ),
    body: (
      [Q1 (poorest)], [20,000], [0], [20,000], [6,500],
      [Q2], [20,000], [0], [20,000], [0],
      [Q3], [13,333], [0], [13,333], [0],
      [Q4], [0], [0], [0], [0],
      [Q5 (richest)], [0], [0], [0], [0],
      table.cell(colspan: 1)[*Total*], table.cell(colspan: 1)[53,333], table.cell(colspan: 1)[0],
      table.cell(colspan: 1)[*53,333*], table.cell(colspan: 1)[*6,500*],
    ),
    footer: (
      table.cell(colspan: 5)[Illustrative uniform-within-band income distribution, 20,000 households per quintile. CHE: catastrophic health expenditure, threshold 10% of income. Poverty line \$400/year.],
    ),
  ),
) <tab-ch24-ecea-frp>

#heor-practice[
Report financial risk protection results *by quintile*, never only as a single pooled figure. The pooled total of 53,333 CHE cases averted is true but hides the policy-relevant finding: essentially all of the financial protection accrues to the three poorest quintiles, with zero effect on Q4 and Q5. A payer or ministry deciding between a universal subsidy and a means-tested subsidy targeted at the bottom three quintiles needs exactly this quintile breakdown to see that the latter could capture almost the same financial-protection benefit at a fraction of the fiscal cost -- a comparison the aggregate number alone cannot support.
]

#pitfall[
ECEA's financial risk protection outcome is not a substitute for a conventional cost-effectiveness analysis, and it is not denominated in the same units as a QALY or an ICER -- there is no accepted exchange rate for converting "catastrophic health expenditure cases averted" into dollars or QALYs, and attempting to force one onto a single combined metric defeats the method's purpose. The two outcomes (health gain and financial risk protection) are reported *in parallel*, as DCP3's own case studies consistently do, precisely because they answer different policy questions: is this intervention good value for health, and does it also protect households from a specific and separate harm. A submission that quietly adds a monetized FRP benefit into the numerator of an ICER has silently changed what the ICER means and should be flagged as such.
]

== 24.4 Multi-criteria decision analysis (MCDA) in R

Every method covered in this book so far -- cost-effectiveness analysis, budget impact analysis, extended CEA -- ultimately reduces a decision to one or two explicit numeric axes: cost and a single health outcome (or cost and a financial-protection outcome, in §24.3's case). Many real coverage decisions are not actually made on one or two axes. A reimbursement committee weighing a new orphan drug is also, explicitly or not, weighing disease severity, unmet need, quality of the clinical evidence, budget affordability, and sometimes equity or innovation considerations that have no natural place inside an ICER. Multi-criteria decision analysis (MCDA) is the family of methods built to make that multi-axis weighing *explicit and reproducible* rather than leaving it as an unstated, inconsistent judgement call made differently in every committee meeting.

The general MCDA idea is simple to state even though implementations vary: define a set of criteria relevant to the decision (efficacy, safety, disease severity, budget impact, quality of evidence, equity, and so on); assign each criterion a *weight* reflecting how much the decision-maker cares about it relative to the others (weights conventionally sum to 1); score each alternative (each drug, each programme) on each criterion, usually on a common 0-100 or 0-1 scale after normalizing the criterion's raw units away; and combine weights and scores into a single overall score per alternative, most commonly by a *weighted sum* (additive combination) or occasionally a *weighted product* (multiplicative combination). The alternative with the highest combined score is, by the model's own logic, the most preferred -- though MCDA's real value is usually less about producing a single ranking and more about forcing the weighting judgement into the open where it can be debated, revisited, and sensitivity-tested, exactly as a one-way or probabilistic sensitivity analysis does for an ICER.

#difficult-terminology("Weighted sum versus weighted product")[
A *weighted sum* combines criterion scores by multiplying each score by its weight and adding the results: $"score" = sum_i w_i dot s_i$. It assumes criteria are, in effect, *compensatory* -- a low score on one criterion can always be offset by a high enough score on another, in direct proportion to their weights. A *weighted product* instead multiplies each score raised to the power of its weight: $"score" = product_i s_i^(w_i)$. Because any score of zero on any criterion drives the whole product to zero regardless of how well the alternative scores elsewhere, the weighted product is much less forgiving of a catastrophic failure on a single criterion -- useful when a decision-maker genuinely wants "unacceptable on safety" to disqualify an alternative outright rather than be averaged away by strong efficacy, but inappropriate if criteria are meant to trade off freely against each other. Most published health-sector MCDA applications, including EVIDEM (below), use a weighted-sum-style additive combination as the default.
]

Several dedicated MCDA R packages exist on CRAN -- the long-standing `MCDA` package provides a `weightedSum()` function for exactly the additive combination described above, and newer packages such as `mcdabench` implement a much larger family of methods (TOPSIS, PROMETHEE, ELECTRE, VIKOR, and more) with built-in normalization and weight-sensitivity analysis. Because this book's standing discipline is to show only function signatures independently verified against current documentation rather than a remembered or guessed interface, and because the weighted-sum logic itself is genuinely simple, the worked example below builds the scoring pipeline directly in base R and `dplyr` -- the identical arithmetic a dedicated package's `weightedSum()`-style function would perform, just written out so every step is visible and auditable, which is itself a defensible choice for a committee-facing analysis that needs to be checked by non-R-programmer reviewers.

*Worked example.* Three hypothetical drugs for the same indication are scored by a committee on four criteria -- efficacy, safety, disease severity addressed, and economic value -- each on a 0-100 scale, with committee-agreed weights of 35% efficacy, 25% safety, 20% severity, 20% economic value (summing to 1).

```r
library(dplyr)

mcda_weighted_score <- function(scores, weights) {
  # scores:  a named list/data frame of criterion scores per alternative
  # weights: a named numeric vector of criterion weights, must sum to 1
  stopifnot(abs(sum(weights) - 1) < 1e-8)

  scores %>%
    rowwise() %>%
    mutate(
      weighted_sum = sum(c_across(names(weights)) * weights[names(weights)]),
      weighted_product = prod(c_across(names(weights))^weights[names(weights)])
    ) %>%
    ungroup()
}

weights <- c(efficacy = 0.35, safety = 0.25, severity = 0.20, economic = 0.20)

drug_scores <- tibble::tribble(
  ~drug,     ~efficacy, ~safety, ~severity, ~economic,
  "Drug A",  80,        70,      60,        50,
  "Drug B",  60,        90,      60,        70,
  "Drug C",  90,        50,      80,        40
)

mcda_result <- mcda_weighted_score(drug_scores, weights)
mcda_result %>% arrange(desc(weighted_sum))
```

Working the weighted sum through by hand for Drug A: $80 times 0.35 + 70 times 0.25 + 60 times 0.20 + 50 times 0.20 = 28 + 17.5 + 12 + 10 = 67.5$. For Drug B: $60 times 0.35 + 90 times 0.25 + 60 times 0.20 + 70 times 0.20 = 21 + 22.5 + 12 + 14 = 69.5$. For Drug C: $90 times 0.35 + 50 times 0.25 + 80 times 0.20 + 40 times 0.20 = 31.5 + 12.5 + 16 + 8 = 68$. The weighted-sum ranking is therefore Drug B (69.5) > Drug C (68.0) > Drug A (67.5) -- Drug B's combination of strong safety and reasonable scores elsewhere edges out Drug C's higher efficacy and severity scores, because safety carries a larger weight (25%) than either of the criteria on which Drug C leads. The weighted-product scores (Drug A: 66.49, Drug B: 68.48, Drug C: 64.53, each computed as $product s_i^(w_i)$) preserve the same ranking here because no criterion score is close to zero for any drug, but the gap between Drug B and Drug C widens slightly under the product rule, illustrating the point made above: the multiplicative combination punishes Drug C's relatively weaker safety score (50) more heavily than the additive rule does.

#report-table(
  [MCDA weighted-sum and weighted-product scores for three illustrative drugs, equal-criteria committee weighting.],
  academic-table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: (left, right, right, right, right, right, right),
    header: (
      [*Drug*], [*Efficacy*], [*Safety*], [*Severity*], [*Economic*],
      [*Weighted sum*], [*Weighted product*],
    ),
    body: (
      [Drug A], [80], [70], [60], [50], [67.50], [66.49],
      [Drug B], [60], [90], [60], [70], [69.50], [68.48],
      [Drug C], [90], [50], [80], [40], [68.00], [64.53],
    ),
    footer: (
      table.cell(colspan: 7)[Weights: efficacy 0.35, safety 0.25, severity 0.20, economic 0.20 (sum = 1.00). All scores on a committee-assigned 0-100 scale.],
    ),
  ),
) <tab-ch24-mcda-scores>

#pitfall[
The ranking above is entirely a function of the committee's chosen weights, not an objective fact about the three drugs -- halve the safety weight and double the economic weight and Drug B's lead can disappear. Every MCDA result reported to a decision body should be accompanied by a weight-sensitivity analysis (re-running the same `mcda_weighted_score()` call across a plausible range of alternative weight sets, exactly as a one-way sensitivity analysis re-runs an ICER across a plausible range of input values) rather than presented as a single fixed ranking. Without this, MCDA can create a false appearance of objectivity around what is, by construction, an aggregation of subjective value judgements.
]

#difficult-terminology("EVIDEM")[
EVIDEM (Evidence and Value: Impact on DEcisionMaking) is the most widely cited health-sector-specific MCDA framework, developed and field-tested from around 2008 onward (Goetghebeur et al.) and piloted or used operationally by several HTA bodies, including a pan-Canadian appraisal pilot and a Canadian public-payer field test for a specific drug coverage decision. EVIDEM structures the generic weighted-sum logic above into two components: a *MCDA Core Model* of roughly 14-15 quantifiable criteria (grouped into quality-of-evidence, disease, intervention, and economic domains -- disease severity, size of population affected, unmet need, comparative efficacy/safety/patient-reported outcomes, and cost-effectiveness among them) that are weighted and scored exactly as this section's worked example does; and a separate *Contextual Tool* covering roughly six qualitative, non-quantifiable considerations (ethical principles such as fairness and the goal of healthcare, and system-level considerations such as political priorities or organizational capacity) that are deliberated rather than scored numerically, because EVIDEM's developers judged that forcing a number onto "is it ethically acceptable to prioritize this population" would misrepresent the nature of that judgement. The two-part structure is EVIDEM's central methodological claim: that a defensible health-sector MCDA needs both an explicit, numeric, auditable core (what this section's R code produces) and an explicit space for the value judgements that genuinely cannot be reduced to a weight and a score.
]

== 24.5 Severity modifiers, value-based pricing, and managed entry agreements

The three methods in this chapter so far -- societal-perspective cost-benefit analysis, distributional/equity-weighted CEA, and ECEA's financial-risk-protection outcome -- all share one feature: they modify or supplement the *outcome* side of the value equation. This closing section covers three mechanisms that act on the *decision threshold and price* side instead: how a health system can explicitly weight QALYs by disease severity before applying its usual cost-effectiveness threshold, how value-based pricing sets a price directly from estimated value rather than from a cost-plus or reference-pricing convention, and how managed entry agreements (MEAs) let a payer and manufacturer agree a price conditional on real-world performance or simply a confidential discount -- closing the loop back to Chapter 23's budget-impact worked example, where an MEA scenario already appeared as a straightforward parameter change.

*NICE's severity modifier.* From January 2022, NICE's technology appraisal methods manual replaced its older "end of life" modifier with a broader *severity modifier*, applying a greater weight to QALYs gained for conditions judged sufficiently severe. The mechanism is deliberately formulaic: NICE computes the *absolute QALY shortfall* (the difference between the QALYs a general population of the same age and sex would expect over their remaining lifetime, and the QALYs people with the condition under current standard care are expected to have) and the *proportional QALY shortfall* (that same shortfall expressed as a fraction of the general population's expected QALYs). Table 6.1 of NICE's manual then assigns a QALY weight of 1 (no uplift), 1.2, or 1.7 depending on where those two shortfall measures fall, using whichever of the two implies the *higher* severity category.

#difficult-terminology("QALY shortfall (absolute and proportional)")[
Both shortfall measures answer the same underlying question -- how much worse off, in QALY terms, is someone with this condition compared to someone of the same age and sex without it -- but express it differently. *Absolute* shortfall is a QALY count: if the general population would expect 20.4 remaining QALYs and people with the condition under current NHS care would expect only 4.2, the absolute shortfall is $20.4 - 4.2 = 16.2$ QALYs. *Proportional* shortfall expresses the same gap as a fraction of what the general population would have had: $16.2 \/ 20.4 approx 0.79$, meaning this condition costs its patients roughly 79% of the healthy-population QALY expectation. The two measures can disagree about which severity band a condition falls into -- a condition affecting mostly elderly patients, who have less remaining QALY expectation even in good health, might show a modest absolute shortfall but a large proportional one, while a condition striking young patients early could show the reverse -- which is exactly why NICE's rule takes whichever of the two implies the higher weight, rather than picking one measure and discarding the other.
]

```r
# Illustrative NICE-style severity-modifier calculation and its effect
# on a submitted ICER -- not a real appraisal, parameters chosen for
# the worked example only.

qale_general_population <- 20.4    # expected remaining QALYs, matched age/sex
qale_with_condition     <- 4.2     # expected remaining QALYs under current NHS care

absolute_shortfall     <- qale_general_population - qale_with_condition
proportional_shortfall <- absolute_shortfall / qale_general_population

severity_weight <- function(abs_shortfall, prop_shortfall) {
  # Table 6.1, NICE health technology evaluations manual (PMG36), 2022
  if (prop_shortfall >= 0.95 || abs_shortfall >= 18) {
    1.7
  } else if (prop_shortfall >= 0.85 || abs_shortfall >= 12) {
    1.2
  } else {
    1
  }
}

w <- severity_weight(absolute_shortfall, proportional_shortfall)

incremental_cost <- 2400   # $ per patient
incremental_qaly <- 0.08   # unweighted QALY gain per patient

icer_unweighted <- incremental_cost / incremental_qaly
icer_weighted   <- incremental_cost / (incremental_qaly * w)

list(
  absolute_shortfall = absolute_shortfall,
  proportional_shortfall = round(proportional_shortfall, 3),
  severity_weight = w,
  icer_unweighted = icer_unweighted,
  icer_weighted = icer_weighted
)
```

Working this through by hand: the absolute shortfall is $20.4 - 4.2 = 16.2$ QALYs, and the proportional shortfall is $16.2 / 20.4 approx 0.794$. Against Table 6.1's bands, 16.2 falls in the "12 to 18" absolute-shortfall band (weight 1.2), and 0.794 falls below the "0.85 to 0.95" proportional-shortfall band (weight 1, since it is under 0.85) -- taking whichever measure implies the *higher* weight gives an overall severity weight of *1.2*. Applying that weight to the unweighted ICER of $2400 / 0.08 = \$30,000$ per QALY gives a severity-adjusted ICER of $2400 / (0.08 times 1.2) = 2400 / 0.096 = \$25,000$ per QALY -- the same drug, same trial data, same cost, now appears more cost-effective purely because its QALY gain is uplifted for treating a condition with a substantial health shortfall under current care.

#heor-practice[
A severity-weighted ICER is not a trick for making an unaffordable drug look affordable -- it is NICE's explicit, published, formulaic way of saying that a QALY gained for someone with very little remaining healthy life expectancy is judged more valuable than a QALY gained for someone closer to general-population health, a position grounded in the same equity reasoning Chapter 24's earlier sections built up through distributional CEA and equity weights. The modifier only applies in technology appraisals (not routinely in diagnostics or highly specialised technology evaluations, where severity is judged to already be captured elsewhere in the process), and the shortfall calculation itself needs the same rigour as any other model input: a recent, robust source for general-population EQ-5D and survival data, and discounting at the reference-case rate, exactly as the standard cost-effectiveness calculations in Chapters 17-20 require.
]

*Value-based pricing.* Where a severity modifier adjusts the *QALY side* of the cost-effectiveness equation, value-based pricing (VBP) works on the *price side* directly: rather than setting a drug's price from manufacturing cost plus margin, or by referencing prices in comparator countries, VBP sets the price at (or just below) the level implied by the health system's own cost-effectiveness threshold, given the drug's estimated incremental benefit. In principle this is the mirror image of the standard ICER calculation already used throughout this book: instead of computing $"ICER" = "incremental cost" / "incremental QALY"$ and comparing it to a threshold, VBP rearranges the same relationship to solve for the maximum acceptable price -- $"price" = "threshold" times "incremental QALY" + "cost of comparator"$ -- so that the resulting ICER lands exactly at the threshold. NICE's 2014 VBP consultation ultimately did not replace the standard appraisal process with formal value-based pricing, but the underlying arithmetic -- "what is the highest price at which this ICER still clears our threshold" -- is exactly the threshold-price calculation every HTA submission in this book implicitly performs when testing a drug's current or hypothetical price against a cost-effectiveness threshold (Chapters 17, 19, 20).

*Managed entry agreements.* Chapter 23's §23.4 already built a worked managed-entry-agreement (MEA) scenario directly into `build_bia()`, showing that a confidential price concession on the same uptake path reduced the five-year cumulative budget impact by \$7,500,000 relative to the list-price base case. That example is worth re-reading here rather than re-deriving, because it illustrates the most common MEA type in practice -- a *financial-based* agreement, where the manufacturer simply agrees a confidential discount, rebate, price-volume agreement, or cap on total spend, with no requirement to track real-world clinical performance at all.

#ref-table(
  [Managed entry agreement types.],
  academic-table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    header: ([*Type*], [*Mechanism*], [*What is tracked*]),
    body: (
      [Financial-based], [Confidential discount, rebate, price-volume agreement, or budget cap negotiated at launch], [Nothing beyond utilization/volume -- no clinical outcome data collection required],
      [Outcomes-based (coverage with evidence development)], [Price or reimbursement conditional on evidence generated after launch, often via a registry or real-world data collection], [Population-level outcomes (e.g. survival, response rate) measured in a defined post-launch cohort],
      [Outcomes-based (patient-level / pay-for-performance)], [Payer pays, or is refunded, conditional on an individual patient's own response to treatment], [Individual patient outcome against a pre-agreed clinical response criterion],
    ),
  ),
) <tab-ch24-mea-types>

#difficult-terminology("Outcomes-based managed entry agreement")[
An outcomes-based MEA ties the price actually paid -- or a refund -- to evidence of how well the treatment performs after launch, rather than fixing a discount at launch regardless of subsequent performance. The two broad sub-types differ in what is measured: a *coverage-with-evidence-development* agreement, as the name suggests, is really a conditional reimbursement decision -- the payer covers the drug now in exchange for a commitment to collect further population-level evidence (commonly through a mandatory registry) that will inform a formal re-appraisal once that evidence matures. A *patient-level* outcomes-based agreement is narrower and more operationally demanding: an individual patient's own clinical response (e.g. tumour response at a defined scan, a biomarker threshold, time to progression) determines whether the manufacturer is paid in full, paid partially, or refunds the payer for that specific patient's treatment course. Patient-level agreements require clinical infrastructure most health systems do not have at scale -- defining, capturing, and auditing a response criterion for every treated patient -- which is exactly why financial-based agreements, needing none of that infrastructure, remain far more common internationally despite outcomes-based agreements being the more frequently *discussed* type in the HTA literature.
]

#pitfall[
An outcomes-based MEA shifts financial risk from the payer to the manufacturer only to the extent the outcome-measurement infrastructure is genuinely reliable -- a registry with poor case ascertainment, inconsistent outcome definitions across sites, or incomplete follow-up can let a manufacturer appear to meet performance criteria that would not hold up under a cleaner data collection design, which is precisely why coverage-with-evidence-development schemes are typically paired with an explicit re-appraisal date and a pre-specified evidence standard, not left open-ended. Conversely, treat Chapter 23's §23.4 point as the general rule for *financial*-based MEAs specifically: because they require no new outcome data at all, they are far simpler to model (a straight price-parameter change to the same budget-impact or cost-effectiveness function, exactly as `build_bia()` demonstrated) and far simpler to audit, which is the main reason payers reach for them first even where an outcomes-based structure might in principle be more clinically appropriate.
]

#agency-note[
Confidentiality is the norm, not the exception, for MEA pricing in nearly every jurisdiction that uses them -- published list prices and HTA submissions routinely show the pre-discount price, with the true net price known only to the payer and manufacturer, which is exactly why Chapter 23's worked example described its MEA scenario's discounted net cost as "confidential" rather than reporting an observed real-world figure. This has a direct modelling consequence worth restating from this chapter's and Chapter 23's running theme: every MEA scenario belongs in the model as a *parameter*, callable on demand once a negotiation concludes, rather than hard-coded into a single committed model version -- the same discipline Chapter 23 established for budget-impact scenarios applies without modification to a cost-effectiveness or ECEA model incorporating a confidential net price.
]
