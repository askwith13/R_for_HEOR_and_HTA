#import "../common.typ": *

= Chapter 23. Budget Impact Analysis

#learning-objectives((
  [Distinguish budget impact analysis (BIA) from cost-effectiveness analysis (CEA) by perspective, time horizon, discounting convention, and the question each answers, and state the core requirements of ISPOR's Good Practice Task Force report for BIA.],
  [Build an eligible-population cascade and a current-versus-new market-share structure that captures how a new intervention displaces existing treatment, not just how many patients take it.],
  [Construct and interpret linear and logistic (S-shaped) uptake/diffusion curves over a short multi-year horizon.],
  [Assemble a complete, parameterized R budget impact model from a reference scenario and a new scenario, computing year-by-year and cumulative budget impact.],
  [Re-run the same model under structured scenario analyses (faster uptake, a managed-entry price agreement) to show payers a realistic range rather than a single point estimate.],
  [Present budget impact results the way payers actually expect to see them: separate acquisition-cost and offset lines, a year-by-year table, and an explicit statement of which assumption the result is most sensitive to.],
))

Chapters 17 through 22 built an increasingly rich family of models --
decision trees, Markov cohort models, partitioned survival models,
microsimulation, and discrete event simulation / dynamic transmission
models -- all answering some version of the same question: is a new
intervention good value for the health it produces, expressed as an
incremental cost-effectiveness ratio over a long, often lifetime,
horizon. This chapter and the next move to a different, shorter-horizon
question that sits alongside cost-effectiveness in every real HTA or
payer submission: not "is this worth it," but "what will this actually
cost our budget over the next few years, given how adoption really
unfolds." Budget impact analysis (BIA) is that question, and it uses a
genuinely different model structure -- not a cut-down version of the
CEA models already built in this book, but its own payer-facing
accounting exercise.

#pagebreak(weak: true)

== 23.1 Purpose and ISPOR guidance

Every model built so far in this book -- decision trees, Markov cohort
models, partitioned survival models, microsimulations, discrete event
simulations, dynamic transmission models -- has ultimately answered the
same question: is a new intervention *good value* for the health gained,
expressed as an incremental cost-effectiveness ratio (ICER) in cost per
quality-adjusted life year (QALY). That is the language of
cost-effectiveness analysis (CEA), and it is typically computed over a
*lifetime* horizon, from a *societal* or *healthcare-system* perspective,
because value-for-money has to be judged over the full span of health
gained and cost incurred.

Budget Impact Analysis (BIA) asks a completely different question, and
it is easy -- and common -- to conflate the two. A payer (a national
health service, an insurer, a hospital pharmacy and therapeutics
committee) does not primarily want to know whether a drug is good value
over a patient's lifetime. They want to know: *if we add this
intervention to our formulary next year, what will it do to our cash
budget over the next one to five years?* A drug can be highly
cost-effective (low cost per QALY, even cost-saving in the long run) and
still be *unaffordable* in the short term if a large eligible population
switches onto it quickly and the drug acquisition cost is high.
Conversely, a drug with a mediocre ICER might have almost no budget
impact if the eligible population is tiny. BIA and CEA are complementary,
not competing, questions, and ISPOR has always insisted they be reported
separately and not substituted for one another.

#difficult-terminology("Budget impact analysis (BIA)")[
Budget impact analysis is the financial modelling exercise that
estimates the *change in a specific payer's spending* that would result
from introducing, funding, or changing access to a health technology,
over a defined and short future period -- typically one to five years,
almost never a patient lifetime. Where CEA asks "is this worth it per
unit of health gained, over all time", BIA asks "what does this do to
this year's and next few years' cash outflow, for this specific budget
holder".

Think of it the way a hospital finance director thinks about a capital
purchase versus a clinician thinking about whether the purchase improves
patient outcomes. The clinician's question (does a new MRI scanner
improve diagnostic yield enough to justify its cost per QALY gained
across its operating lifetime) is the CEA question. The finance
director's question (can the hospital's budget absorb the purchase price
and running costs over the next three fiscal years, given how many
patients will actually be scanned on it) is the BIA question. Both are
legitimate, and a payer typically wants both answers before it funds
anything -- but they are not the same number, they are not computed the
same way, and conflating them in a report is a common and consequential
analytical error.
]

The defining methodological document for this chapter is a specific
ISPOR Good Practice Task Force report, and because BIA is so often done
badly (or done as a thin disguise for a CEA), it is worth being explicit
about what it actually requires.

#agency-note[
The operative ISPOR reference for everything in this chapter is:
Sullivan SD, Mauskopf JA, Augustovski F, Caro JJ, Lee KM, Minchin M,
Orlewska E, Penna P, Rodriguez Barrios JM, Shau W-Y. _Budget Impact
Analysis -- Principles of Good Practice: Report of the ISPOR 2012 Budget
Impact Analysis Good Practice II Task Force._ Value in Health.
2014;17(1):5-14.

This report lays out the core structural requirements that distinguish
a credible BIA from an ad-hoc spreadsheet: (1) a short, explicit time
horizon appropriate to payer budget cycles (commonly 1-5 years, stated
and justified, not defaulted to a lifetime horizon as in CEA); (2) the
payer's *actual* budget-holder perspective, including only costs that
fall on that specific budget (not broader societal costs unless the
payer's remit covers them); (3) an explicit comparison of a "world
without the new intervention" (reference scenario, usually the current
standard-of-care mix projected forward) against a "world with the new
intervention" (new scenario, reflecting a realistic adoption
trajectory), with the budget impact reported as the *difference* in
total cost between the two scenarios in each year; (4) realistic,
evidence-based estimates of the eligible population, uptake/diffusion
over time, and market share displacement of existing therapies, rather
than an assumption that the whole eligible population switches on day
one; and (5) transparent reporting of all assumptions and inputs so a
payer's own analysts can stress-test them. We return to each of these
five requirements directly as the model structure is built in the
remaining sections of this chapter.
]

#pitfall[
A frequent and serious mistake is to build a BIA by simply re-running
the CEA model's cohort over a shorter horizon and reporting undiscounted
cumulative cost. This is wrong for at least three reasons: the CEA
cohort typically represents *incident* patients entering a Markov or
survival process, not the *mixed prevalent-plus-incident* population
that will actually be on treatment in a given budget year; the CEA model
usually assumes 100% uptake among those eligible, whereas real-world
adoption is gradual; and CEA costs are discounted at a long-run societal
discount rate, whereas ISPOR guidance recommends BIA cash flows
typically be presented *undiscounted*, because a payer's budget is set
and spent in nominal terms year by year, not in present-value terms. If
your BIA numbers look exactly like a truncated slice of your CEA model,
something has gone structurally wrong.
]

#heor-practice[
When scoping a BIA, agree the time horizon and perspective with the
budget holder *before* building anything. Ask directly: "whose budget,
and over what fiscal years?" A national payer, a regional health
authority, and a single hospital pharmacy can have materially different
eligible populations, different existing market shares of comparator
treatments, and different budget cycles (some run 1-year rolling, some
run 3- or 5-year planning horizons). Building the population and uptake
structure (Section 23.2) around the wrong budget holder's perspective is
the single most common reason a BIA has to be rebuilt from scratch.
]

== 23.2 Population, uptake and market-share structure

Every budget impact model, however it is eventually coded, rests on the
same arithmetic skeleton repeated for each year of the horizon:

$ "Budget impact"_t = ("Eligible population"_t times "Uptake"_t times "Market share"_t times "Cost per patient") $

applied separately to the reference scenario (world without the new
intervention) and the new scenario (world with it), with the
year-by-year *difference* between the two totals being the budget impact
actually reported to the payer. Section 23.1 established *why* this
calculation is structured this way; this section builds the three
population-level ingredients -- eligible population size, market-share
mix, and the uptake/diffusion curve -- that feed it. The fourth
ingredient, cost per patient, is a straightforward unit-cost exercise
similar to costing work done in Chapter 9 and is assembled together with
these population terms into a working model in Section 23.3.

=== Eligible population

The eligible population is not simply "everyone with the diagnosis."
ISPOR good-practice guidance is explicit that the eligible population
should be derived top-down from an epidemiologically defensible base
(disease prevalence or incidence in the payer's covered population) and
then narrowed by every clinically and administratively relevant
restriction: diagnostic criteria, line-of-therapy eligibility,
reimbursement/label restrictions, and any contraindications. A common
structure is a simple cascade:

```r
library(dplyr)

# illustrative cascade - every number here is a placeholder to be
# replaced with payer-specific epidemiological and administrative data
population_cascade <- tibble::tibble(
  step = c("covered_lives", "disease_prevalence", "diagnosed",
           "meets_label_criteria", "eligible_for_new_intervention"),
  proportion_of_prior_step = c(1, 0.02, 0.80, 0.60, 0.90)
)

population_cascade <- population_cascade |>
  mutate(cumulative_proportion = cumprod(proportion_of_prior_step))

population_cascade
```

Each row narrows the denominator: of the payer's total covered lives,
some proportion has the disease, of those some proportion are actually
diagnosed, of those some proportion meet the specific label or guideline
criteria for the new intervention, and of those some proportion have no
contraindication. `cumprod()` gives the running cumulative proportion
applied to the covered-lives base, and multiplying that final cumulative
proportion by the covered-lives count gives the eligible population in
year 1. Because covered lives themselves can grow or shrink over the
horizon (population growth, membership churn in an insured population),
the eligible population is usually re-projected for each year of the
horizon rather than held constant, often with a simple annual
growth-rate multiplier applied to the covered-lives figure before the
cascade is reapplied.

#pitfall[
Do not reuse the CEA model's trial-based "intention-to-treat population"
as the BIA eligible population. Clinical trials recruit a selected
population under research conditions; real-world eligible populations
are almost always larger (broader label, less stringent exclusion) or,
just as often, smaller (diagnosis rates in routine practice are lower
than in a trial with active case-finding). The eligible-population
cascade should be built from real-world epidemiological and
claims/administrative sources specific to the payer's population, not
lifted from the trial's CONSORT diagram.
]

=== Market share: the reference versus new scenario

Once the eligible population for a given year is known, it must be split
across the available treatment options -- and it must be split *twice*:
once under the reference scenario (the world as it would continue
without the new intervention, i.e. existing therapies keep whatever
share trajectory they currently have), and once under the new scenario
(the world with the new intervention available, where it progressively
displaces some share from existing therapies). The payer-reported budget
impact in each year is the difference in total cost between these two
parallel market-share allocations, not the cost of the new intervention
alone.

#difficult-terminology("Market share (in a BIA context)")[
In everyday use "market share" means the proportion of a market a
product holds. In a BIA, market share specifically means the proportion
of the *eligible population currently receiving treatment in that year*
that is allocated to each named treatment option (existing drug A,
existing drug B, best supportive care, and the new intervention). It
matters because the new intervention's cost to the payer in any given
year is not simply "number of patients taking it times its price" -- it
is that, *minus* whatever cost the payer was already going to incur for
the patients who would otherwise have been on an existing (and possibly
cheaper, or possibly more expensive) therapy. A useful analogy: if a
hospital canteen introduces a new salad bar, the budget question is not
"what does the salad bar cost to run," it's "how does total catering
spend change," accounting for the fact that some diners who would have
bought a sandwich (a different cost) now buy a salad instead. The *net*
change, not the gross cost of the new option, is the budget impact.
]

A simple two-period illustration keeps the arithmetic checkable by hand.
Suppose a payer's eligible population for a condition is a constant 1000
patients per year (ignoring population growth for simplicity), and under
the *reference* scenario this population is split 70% onto existing Drug
A (cost \$500 per patient-year) and 30% onto existing Drug B (cost \$800
per patient-year):

$ "Reference scenario cost" = 1000 times (0.70 times 500 + 0.30 times 800) = 1000 times (350 + 240) = 590000 $

Now suppose that in the *new* scenario, by year 2 the new intervention
(cost \$1200 per patient-year) has captured 20% of the eligible
population, drawn proportionally from both existing drugs (so Drug A
falls to 56% and Drug B falls to 24%, preserving their 70:30 relative
split among the remaining 80%):

$ "New scenario cost" = 1000 times (0.56 times 500 + 0.24 times 800 + 0.20 times 1200) = 1000 times (280 + 192 + 240) = 712000 $

$ "Budget impact (year 2)" = 712000 - 590000 = 122000 $

The payer does not simply pay "20% of 1000 patients times \$1200" (which
would suggest a \$240,000 impact); because some of that \$1200 replaces
costs the payer was already paying for Drug A and Drug B, the true net
impact is smaller, at \$122,000. This netting-out is the entire reason a
BIA cannot be read off a drug's list price alone, and it is the single
most common source of inflated, indefensible budget-impact estimates
when analysts skip the reference-scenario comparison.

=== Uptake and diffusion over the time horizon

The 20% market share reached "by year 2" in the example above does not
appear instantly -- real-world adoption of a new intervention follows a
diffusion curve shaped by prescriber familiarity, guideline updates,
prior-authorization processes, and manufacturer launch sequencing. ISPOR
guidance calls for the uptake trajectory to be stated explicitly and
justified (analogous products' historical launch curves, expert
elicitation, or market-research forecasts are all acceptable evidence
sources), rather than assumed as an instant step-change or an arbitrary
straight line.

Two simple, defensible functional forms cover most practical cases: a
linear ramp-up to a terminal share, or an S-shaped logistic diffusion
curve that starts slowly, accelerates through early adoption, and then
levels off as the addressable market saturates -- the same qualitative
shape used to describe technology adoption in many fields.

```r
library(dplyr)
library(ggplot2)

years <- 1:5
peak_share <- 0.35   # terminal market share captured by the new intervention

# linear ramp-up: equal increments each year up to peak_share by year 5
linear_uptake <- seq(from = peak_share / 5, to = peak_share, length.out = 5)

# logistic (S-shaped) diffusion: slow start, faster middle, levelling off
# k controls steepness, t0 the inflection year
logistic_uptake <- function(t, peak, k = 1.2, t0 = 2.5) {
  peak / (1 + exp(-k * (t - t0)))
}

uptake_curves <- tibble::tibble(
  year = years,
  linear = linear_uptake,
  logistic = logistic_uptake(years, peak = peak_share)
)

uptake_curves |>
  tidyr::pivot_longer(cols = c(linear, logistic),
                       names_to = "curve", values_to = "market_share") |>
  ggplot(aes(x = year, y = market_share, colour = curve)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(x = "Year of horizon", y = "New intervention market share",
       title = "Illustrative uptake curves over a 5-year BIA horizon")
```

// TODO-IMAGE: Two-line chart (linear vs logistic uptake curves) over a
// 5-year horizon, terminal share 0.35, from the code block above --
// Dr Aswath to supply after running the ggplot2 code.

Multiplying each year's eligible population (from the cascade above) by
that year's uptake-adjusted market share, for both the reference and new
scenarios, and costing each resulting patient mix, generates exactly the
year-by-year budget impact table that payers expect to see -- the
mechanics of assembling that table, applying it within a full R model
structure, and extending it to scenario (sensitivity) analysis are taken
up next in Section 23.3.

#heor-practice[
Always sanity-check an uptake curve against real analogues before
presenting it to a payer: how quickly did the most comparable recent
therapy in this disease area actually get adopted, in this payer's own
historical claims or dispensing data, after launch? Modelled uptake
curves that assume faster diffusion than any historical comparator in
the same therapeutic class are a near-automatic credibility flag in
payer review, and are one of the first things a payer's technical
committee will ask you to defend.
]

== 23.3 Building a budget impact model in R

A budget impact analysis answers a narrower and more operational
question than the cost-effectiveness models of Chapters 17-22: not "is
this good value over a lifetime of discounted QALYs," but "what will the
payer actually have to find in the budget over the next one to five
years." There is no discounting of costs in the base case under ISPOR
good-practice guidance (the horizon is short enough that
time-value-of-money adjustments are usually judged immaterial), and
there are no health outcomes in the calculation at all -- only cash.

The model below is deliberately small enough to check by hand. It uses:

- a five-year horizon,
- a flat eligible population of 10,000 patients per year (no growth,
  stated explicitly -- the structural building blocks for sizing this
  population and its current/new treatment mix were covered in
  SS23.1-23.2),
- a "current mix" world in which 100% of eligible patients remain on
  standard of care (SoC) at \$500 per patient-year,
- a "new mix" world in which a new drug at \$2,000 per patient-year
  phases in via an uptake curve of 5%, 15%, 30%, 45%, 55% across years
  1-5, with every remaining patient still on SoC,
- one simple cost offset: patients on the new drug avoid \$300 per
  patient-year of downstream hospitalization cost, so the *net* new-drug
  cost is \$1,700 per patient-year.

```r
library(dplyr)

build_bia <- function(
    years          = 1:5,
    eligible_pop   = rep(10000, 5),
    uptake_share   = c(0.05, 0.15, 0.30, 0.45, 0.55),
    cost_soc       = 500,
    cost_new       = 2000,
    offset_new     = 300
) {
  tibble(
    year                = years,
    eligible_population = eligible_pop,
    uptake_share        = uptake_share
  ) %>%
    mutate(
      patients_on_new  = eligible_population * uptake_share,
      patients_on_soc  = eligible_population - patients_on_new,
      # net per-patient cost of the new drug after the hospitalization offset
      net_cost_new     = cost_new - offset_new,
      cost_new_mix     = patients_on_new * net_cost_new + patients_on_soc * cost_soc,
      cost_current_mix = eligible_population * cost_soc,
      budget_impact    = cost_new_mix - cost_current_mix
    ) %>%
    select(year, eligible_population, uptake_share, patients_on_new, patients_on_soc,
           cost_current_mix, cost_new_mix, budget_impact)
}

bia_base <- build_bia()
bia_base$cumulative_bi <- cumsum(bia_base$budget_impact)
bia_base
```

Working the arithmetic through by hand confirms the code's output. The
current-mix world costs the same every year because the population and
unit price never change: $10000 times 500 = 5000000$ per year, or
\$25,000,000 across the five years.

In the new-mix world, each year's cost is (patients on new drug times
\$1,700 net) + (patients on SoC times \$500):

- Year 1: $500 times 1700 = 850000$; $9500 times 500 = 4750000$; total \$5,600,000.
- Year 2: $1500 times 1700 = 2550000$; $8500 times 500 = 4250000$; total \$6,800,000.
- Year 3: $3000 times 1700 = 5100000$; $7000 times 500 = 3500000$; total \$8,600,000.
- Year 4: $4500 times 1700 = 7650000$; $5500 times 500 = 2750000$; total \$10,400,000.
- Year 5: $5500 times 1700 = 9350000$; $4500 times 500 = 2250000$; total \$11,600,000.

Subtracting the flat \$5,000,000 current-mix cost from each gives the
year-by-year budget impact: \$600,000, \$1,800,000, \$3,600,000,
\$5,400,000, and \$6,600,000. These five figures sum to \$18,000,000 --
the cumulative five-year budget impact, which can be cross-checked by
summing the new-mix total (\$43,000,000) and subtracting the
current-mix total (\$25,000,000): $43000000 - 25000000 = 18000000$. Both
routes agree, which is exactly the kind of independent cross-check a
model built in a spreadsheet rarely gets for free but a tidyverse
pipeline makes almost automatic.

#pitfall[
A recurring error in BIA submissions is quietly turning the model into a
cost-effectiveness analysis: discounting costs over a multi-year horizon
as if computing lifetime value, or reporting an incremental
cost-per-QALY alongside the budget table. BIA guidance (ISPOR, 2014)
deliberately omits discounting in the base case and omits outcomes
entirely -- the deliverable is *undiscounted net cash impact per year*,
not a value judgement. A second common mistake sits inside the uptake
curve itself: modelling diffusion as if every patient started and
stayed on the new drug, with no allowance for discontinuation or
non-adherence. If, in reality, 20% of patients who start the new drug
stop within the first year, the *effective* exposed population
generating cost (and offsetting hospitalization) is smaller than the raw
uptake share suggests, and a model that ignores this will overstate the
new-drug spend and understate any downstream offset actually realised.
]

== 23.4 Scenario analyses

A payer rarely accepts a single point estimate. The usual request is a
small set of structured alternatives built from the same model skeleton,
varying only the assumptions that are genuinely uncertain: the pace of
uptake, the unit price (often subject to a confidential managed-entry
agreement, MEA), or the size of the offset. Because `build_bia()`
already takes `uptake_share`, `cost_new`, and `offset_new` as arguments,
every scenario is a one-line call.

```r
# Scenario A: faster diffusion (e.g. a strong clinical-guideline endorsement)
bia_fast_uptake <- build_bia(
  uptake_share = c(0.10, 0.25, 0.40, 0.55, 0.65)
)

# Scenario B: managed-entry agreement - confidential 25% net price reduction
bia_mea <- build_bia(
  cost_new = 1500   # was 2000; offset_new stays at 300
)

scenarios <- bind_rows(
  bia_base        %>% mutate(scenario = "Base case"),
  bia_fast_uptake %>% mutate(scenario = "Faster uptake"),
  bia_mea         %>% mutate(scenario = "Managed-entry agreement")
)
```

The faster-uptake scenario is a pure "what-if" on the diffusion curve --
no new arithmetic principle, just larger `patients_on_new` values
feeding the same formula, and therefore a larger budget impact in every
year. The managed-entry-agreement scenario is worth checking by hand,
because it changes the net per-patient cost rather than the uptake
curve: with the new drug re-priced to \$1,500 and the same \$300
hospitalization offset, the net cost per patient on the new drug falls
from \$1,700 to \$1,200.

Re-running the same uptake shares (5%/15%/30%/45%/55%) against this
\$1,200 net cost gives, year by year: Year 1, $500 times 1200 = 600000$
plus $9500 times 500 = 4750000$, total \$5,350,000, budget impact
\$350,000. Year 2, $1500 times 1200 = 1800000$ plus $8500 times 500 =
4250000$, total \$6,050,000, budget impact \$1,050,000. Year 3, $3000
times 1200 = 3600000$ plus $7000 times 500 = 3500000$, total
\$7,100,000, budget impact \$2,100,000. Year 4, $4500 times 1200 =
5400000$ plus $5500 times 500 = 2750000$, total \$8,150,000, budget
impact \$3,150,000. Year 5, $5500 times 1200 = 6600000$ plus $4500 times
500 = 2250000$, total \$8,850,000, budget impact \$3,850,000.

Those five budget-impact figures sum to \$350,000 + \$1,050,000 +
\$2,100,000 + \$3,150,000 + \$3,850,000 = \$10,500,000 over five years.
That can again be cross-checked top-down: cumulative new-mix cost of
\$35,500,000 minus cumulative current-mix cost of \$25,000,000 is
\$10,500,000, matching the bottom-up sum. Against the base case's
\$18,000,000 cumulative impact, the MEA scenario reduces the five-year
budget impact by \$7,500,000 -- a figure the payer will care about far
more than the headline list-price discount.

#heor-practice[
Keep every scenario a parameter change to the *same* function rather
than a hand-edited copy of the spreadsheet. This is what lets a payer's
reviewer ask "what if uptake is 10 points lower in year 3" and get a
defensible, reproducible answer in one function call instead of a
re-built model that may silently diverge from the base case in some
other cell.
]

== 23.5 Presenting results to payers

A payer budget holder reading a BIA submission is not looking for a
single net number. They want, at minimum: a year-by-year table (not just
a five-year total, because budgets are set annually); drug-acquisition
cost and offset cost reported as *separate lines*, not pre-netted, so
the reviewer can independently judge whether the offset assumption is
credible; and some indication of how sensitive the result is to the
market-share/uptake assumption, since that is usually the single most
contestable input in the whole model.

The table below reports the base-case results computed in Section 23.3
exactly as calculated -- no rounding adjustments, no re-derivation.

#report-table(
  [Year-by-year budget impact of introducing the new drug, base-case uptake (current-mix cost held flat at \$5,000,000/year; all figures USD)],
  academic-table(
    columns: (1.6fr, auto, auto, auto, auto, auto),
    align: (left, right, right, right, right, right),
    header: ([*Year*], [*Eligible population*], [*Market share new (%)*], [*Cost, current mix*], [*Cost, new mix*], [*Budget impact*]),
    body: (
      [Year 1], [10,000], [5%],  [\$5,000,000], [\$5,600,000],  [\$600,000],
      [Year 2], [10,000], [15%], [\$5,000,000], [\$6,800,000],  [\$1,800,000],
      [Year 3], [10,000], [30%], [\$5,000,000], [\$8,600,000],  [\$3,600,000],
      [Year 4], [10,000], [45%], [\$5,000,000], [\$10,400,000], [\$5,400,000],
      [Year 5], [10,000], [55%], [\$5,000,000], [\$11,600,000], [\$6,600,000],
    ),
    footer: (table.cell(colspan: 6)[*Cumulative 5-year budget impact: \$18,000,000*],),
  ),
) <tab-ch23-bia-result>

A chart is the natural companion to this table -- payers typically
expect to see cumulative budget impact rising visually across the
horizon, alongside the annual (non-cumulative) figures so the "when does
spend accelerate" question is answered at a glance.

```r
library(ggplot2)
library(tidyr)

plot_data <- bia_base %>%
  mutate(cumulative_bi = cumsum(budget_impact)) %>%
  select(year, budget_impact, cumulative_bi) %>%
  pivot_longer(cols = c(budget_impact, cumulative_bi),
               names_to = "measure", values_to = "amount")

ggplot(plot_data, aes(x = year, y = amount, fill = measure)) +
  geom_col(data = . %>% filter(measure == "budget_impact"), position = "identity") +
  geom_line(data = . %>% filter(measure == "cumulative_bi"),
            aes(y = amount, group = 1), color = "black", linewidth = 1) +
  geom_point(data = . %>% filter(measure == "cumulative_bi"), size = 2) +
  scale_y_continuous(labels = scales::dollar) +
  labs(x = "Year", y = "Budget impact (USD)",
       title = "Annual vs. cumulative budget impact, base case") +
  theme_minimal()
```

// TODO-IMAGE: Combination bar-and-line chart showing annual budget
// impact (bars, $600K to $6.6M rising left to right) with cumulative
// budget impact overlaid as a line (climbing to $18M by year 5), x-axis
// years 1-5, y-axis USD, base-case uptake scenario from Table 23.1 --
// Dr Aswath to supply after running the ggplot2 code above.

#agency-note[
Most payer review templates (and many national BIA submission
guidelines, e.g. those referenced by NICE and CADTH) explicitly require
drug-acquisition cost and any claimed offset to be shown as separate
line items rather than netted together before submission. In the model
above this means reporting patients-on-new times \$2,000 as one line and
patients-on-new times \$300 (the hospitalization offset) as a second,
clearly-labelled reduction -- never collapsing straight to the \$1,700
net figure in the table a reviewer sees, even though netting is
perfectly fine inside the R code itself. Reviewers want to interrogate
the offset assumption on its own terms, and a pre-netted number removes
their ability to do that.
]

Finally, no payer-facing BIA is complete without an explicit statement of
which input the result is most sensitive to. In this example, that is
unambiguously the uptake curve: moving from the base case's 55% year-5
market share to the faster-uptake scenario's 65% increases the year-5
new-mix spend materially, while the managed-entry-agreement scenario
shows that a price concession on the same uptake path can claw back
\$7,500,000 of the cumulative impact. Presenting the base case, the
faster-uptake case, and the MEA case side by side -- rather than a
single number -- is what lets a budget holder see the realistic range
they are actually planning against.

Chapter 24 extends this payer-facing accounting into territory beyond a
single budget line: monetary valuation of health benefits, equity
weighting and distributional cost-effectiveness analysis, financial-risk
protection (extended CEA), and multi-criteria decision analysis -- all
building on the same habit this chapter established of making every
assumption (population, uptake, price, offset) explicit and separately
interrogable rather than collapsed into one opaque headline number.
