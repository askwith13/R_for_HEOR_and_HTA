#import "../common.typ": *

= Chapter 9. Costs and Resource Use

#learning-objectives((
  [Decompose costing into identification, measurement and valuation, and structure resource-use data in R so quantity and unit cost remain separately traceable.],
  [Apply inflation adjustment and currency conversion (nominal exchange rate vs. PPP) correctly and in the right order when combining unit costs across years and countries.],
  [Recognise the skewness, zero-inflation and heavy-tailed structure typical of patient-level cost data, and explain why it breaks ordinary least squares' assumptions.],
  [Fit and interpret gamma GLMs and two-part (hurdle-style) models for skewed, zero-inflated cost data, and avoid the retransformation-bias trap of naive log-OLS.],
  [Distinguish prevalence-based from incidence-based cost-of-illness studies and top-down from bottom-up (micro-costing) approaches, and combine them appropriately for LMIC programme costing.],
  [Explain why censored cost data require specialised estimators (Lin's partitioned estimator, inverse-probability-of-censoring weighting) rather than a naive mean of observed costs.],
))

Chapter 8 closed by noting that utilities and costs are the two halves of the cost-per-QALY pair this book has worked with since Chapter 4's introduction of the willingness-to-pay threshold. Having covered how the utility half is measured, valued and modelled, this chapter turns to its counterpart: how resource use is identified and measured, how unit costs are valued and adjusted across time, currency and country, and how the resulting cost data — skewed, zero-inflated, sometimes censored — is analysed defensibly rather than with a naive mean or an inappropriate linear model.

== 9.1 Identifying, measuring and valuing resources

Costing in economic evaluation is conventionally decomposed into three steps that map neatly onto R workflow stages: *identification* (which resource items are relevant to the perspective and the decision problem), *measurement* (quantities of each item consumed per patient, per cycle, or per health state — the same cycle structure you built in Chapter 4's Markov trace), and *valuation* (attaching a unit cost to each quantity). Keeping these three steps as distinct columns in your working data, rather than collapsing straight to a single "cost" figure, is what lets you later re-value the same resource-use data under a different perspective or a different country's unit costs without re-extracting anything.

For a TB programme, identification usually spans at least four resource categories: diagnostic (sputum smear, Xpert MTB/RIF, chest X-ray, culture/DST), drug (first-line FDCs, second-line regimens for drug-resistant TB), programmatic/health-system (DOT visits, counselling, contact tracing), and patient-borne (travel, time, lost income) — the latter mattering if your analysis takes a societal perspective, which is common in LMIC HTA submissions even when the reference case is health-system focused. Decide and document the perspective *before* you start identifying items, because it determines which rows belong in your resource-use table at all.

A disciplined way to carry this through an R pipeline is a long-format resource-use tibble, with quantity and unit cost kept as separate columns:

```r
library(tibble)
library(dplyr)

resource_use <- tribble(
  ~patient_id, ~health_state, ~item,              ~category,    ~quantity, ~unit,
  "TB001",     "on_treatment","xpert_test",       "diagnostic", 1,         "test",
  "TB001",     "on_treatment","fdc_regimen",       "drug",       6,         "month",
  "TB001",     "on_treatment","dot_visit",         "programmatic",24,       "visit",
  "TB002",     "retreatment", "culture_dst",       "diagnostic", 1,         "test",
  "TB002",     "retreatment", "second_line_regimen","drug",      8,         "month"
)

resource_use
```

Quantity measurement itself typically comes from one of three sources you already know how to ingest from Chapter 5: trial-level case report forms, programmatic/surveillance data (e.g. national TB programme line-lists), or expert elicitation when no empirical source exists for a resource that only occurs off the beaten path of routine data (e.g. ambulance transfer for a rare adverse event). Whichever source, keep an explicit `source` column alongside each `quantity` — reviewers and HTA bodies will ask where a number came from, and a provenance column answers that without you re-digging through notebooks later.

Valuation is where unit costs are joined onto quantities. Treat the unit-cost lookup as its own small reference table and join rather than hard-coding values inline — this is the same discipline as keeping utility decrements as a separate lookup in Chapter 8, and it pays off identically when a unit cost is revised:

```r
unit_costs <- tribble(
  ~item,                ~unit_cost_local, ~currency, ~cost_year,
  "xpert_test",          800,              "INR",     2023,
  "fdc_regimen",         450,              "INR",     2023,
  "dot_visit",           150,              "INR",     2023,
  "culture_dst",         1200,             "INR",     2023,
  "second_line_regimen", 3200,             "INR",     2023
)

costed <- resource_use |>
  left_join(unit_costs, by = "item") |>
  mutate(total_cost_local = quantity * unit_cost_local)

costed
```

#ref-table(
  [Unit-cost reference table for a TB programme resource-use valuation, by resource category and item (local currency, price year 2023) -- the conventional format for publishing the unit-cost list underlying a costing or cost-effectiveness analysis],
  academic-table(
    columns: (1.2fr, 1.6fr, auto, auto, auto),
    align: (left, left, right, right, right),
    header: ([*Category*], [*Resource item*], [*Unit cost*], [*Currency*], [*Price year*]),
    body: (
      [Diagnostic], [Xpert MTB/RIF test], [800], [INR], [2023],
      [Diagnostic], [Culture / DST], [1,200], [INR], [2023],
      [Drug], [First-line FDC regimen (per month)], [450], [INR], [2023],
      [Drug], [Second-line regimen (per month)], [3,200], [INR], [2023],
      [Programmatic], [DOT visit], [150], [INR], [2023],
    ),
    footer: (table.cell(colspan: 5)[*Source:* programme costing exercise unit-cost lookup; values are illustrative and should be replaced with local or WHO-CHOICE sourced costs before reporting.],),
  ),
) <tab-ch09-unit-costs>

#heor-practice[Never collapse quantity and unit cost into a single pre-multiplied "total cost" column at the extraction stage. Keeping them separate (as above) is what allows deterministic sensitivity analysis on the unit cost alone, probabilistic sensitivity analysis with a distribution on quantity and cost independently (Chapter 25), and re-valuation under a different country's cost list — none of which are possible once the multiplication has already happened and the inputs are gone.]

#pitfall[A common analyst error is averaging unit costs *before* joining to resource-use quantities when costs come from multiple facility types (e.g. district hospital vs. primary health centre). Average the resulting total costs (or weight by caseload), not the raw unit costs, unless the facility mix is uniform across your resource-use denominator — averaging unit costs first silently assumes equal patient volume at each facility.]

== 9.2 Unit costs and inflation or currency conversion (PPP adjustments)

Unit costs are rarely available in the right currency, the right year, and the right country all at once. Three distinct adjustments are typically needed, and they must be applied in the correct order: inflate to a common price year *within* the source currency first, then convert currency (nominal exchange rate or PPP) second. Reversing the order mixes an inflation index computed in one currency with a conversion factor computed in another and produces a number that looks plausible but is not interpretable.

*Inflation to a common price year.* Within a single currency, uprate historical unit costs using a price index — a consumer price index (CPI) or, for health-specific costs, a health-sector deflator where available. The arithmetic is simple but easy to get backwards:

```r
inflate_cost <- function(cost, cost_year, target_year, cpi) {
  # cpi: named vector or lookup keyed by year, e.g. cpi["2023"], cpi["2024"]
  cost * (cpi[[as.character(target_year)]] / cpi[[as.character(cost_year)]])
}

cpi_india <- c("2019" = 100, "2020" = 106, "2021" = 112,
               "2022" = 121, "2023" = 128, "2024" = 134)

# Example: inflate a 2019 unit cost to 2024 prices
inflate_cost(cost = 500, cost_year = 2019, target_year = 2024, cpi = cpi_india)
```

*Currency conversion: nominal vs. PPP.* Once costs are in a common price year within their source currency, converting to a reference currency (commonly USD or international dollars for cross-country comparison) requires a choice between the market/nominal exchange rate and a purchasing power parity (PPP) conversion factor. Nominal exchange rates reflect what currency actually trades for; PPP conversion factors reflect relative purchasing power for a comparable basket of goods and services, and are the standard choice when the purpose is comparing real resource burden across countries of different income levels — exactly the comparison an Indian TB-programme analyst benchmarking against WHO or global literature unit costs will usually want. The World Bank publishes PPP conversion factors (and the WHO-CHOICE unit cost database separately provides country-level unit costs for LMICs, already expressed per the WHO-CHOICE methodology) — treat the PPP factor as another lookup joined by year and country, not a constant you hardcode once and forget to update:

```r
ppp_factor_inr_per_intl_dollar <- c(
  "2022" = 22.9, "2023" = 23.5, "2024" = 24.1  # illustrative; source from World Bank ICP data
)

to_intl_dollars <- function(cost_local, year, ppp_lookup) {
  cost_local / ppp_lookup[[as.character(year)]]
}

# Convert the inflated 2024 INR cost to international dollars for cross-country comparison
cost_2024_inr <- inflate_cost(500, 2019, 2024, cpi_india)
to_intl_dollars(cost_2024_inr, 2024, ppp_factor_inr_per_intl_dollar)
```

Wrapping both steps into one pipeline keeps the costed resource-use table from Section 9.1 fully traceable from source currency/year through to the reporting currency/year:

```r
costed_reported <- costed |>
  mutate(
    total_cost_2024_inr = inflate_cost(total_cost_local, cost_year, 2024, cpi_india),
    total_cost_2024_intl_usd = to_intl_dollars(total_cost_2024_inr, 2024,
                                                ppp_factor_inr_per_intl_dollar)
  )

costed_reported
```

#agency-note[The NICE reference case, as set out in "NICE health technology evaluations: the manual" (PMG36) — the same document already cited for EQ-5D utility sourcing in Chapter 8 — specifies costs from the NHS and Personal Social Services (PSS) perspective, valued in UK currency at current prices; a NICE-facing submission should never silently substitute a PPP-converted LMIC cost for a missing UK unit cost without flagging it as a structural assumption. Conversely, for HTAIn or WHO-CHOICE-oriented work, PPP conversion is the standard device for situating a local unit cost within international cost-effectiveness thresholds, and PSSRU's *Unit Costs of Health and Social Care* remains the reference source analysts cite when a UK unit cost itself (rather than its currency conversion) is in question.]

Report which conversion was used — nominal exchange rate or PPP — and the source and year of both the price index and the conversion factor, directly alongside any cost table in your results output; CHEERS 2022 (Husereau et al., *Value in Health*, 2022) item 15, which requires explicit reporting of currency, price date, and the conversion method applied, specifically requires this disclosure, and it is also what lets another analyst re-run your pipeline with an updated PPP vintage without reverse-engineering your assumptions.

== 9.3 Cost data features: skewness, zero-inflation, heavy tails

Cost data in a TB programme context — drug costs, hospitalisation costs, outpatient visit costs, diagnostic costs (GeneXpert cartridges, chest X-rays, culture/DST) — share a statistical signature that rhymes with the bounded utility data of Section 8.4 but is mechanistically different. Utilities were bounded on the [0,1] interval with a ceiling spike at 1; costs are bounded only below at 0, have no natural upper ceiling, and the "spike" sits at the *floor*, not a ceiling. Where Section 8.4 needed beta or censored regression to respect a bounded, two-sided support, cost data needs methods that respect a one-sided (non-negative), unbounded-above, heavy-tailed support with an honest mass of exact zeros. Same family problem — "the arithmetic mean and OLS assumptions quietly break down" — different geometry.

#shiny-app-box("cost_distribution_model_fit_explorer", [Drag zero-inflation, gamma shape/scale, and outlier sliders and watch OLS vs. gamma-GLM predicted means diverge live as the cost distribution's skew changes.])

Three features recur in almost every patient-level cost dataset you will pull from a TB programme's billing or case-management system:

#list(
  [*Right-skewness.* Most patients incur modest cost (a few clinic visits, first-line drugs); a minority incur very large cost (MDR-TB admission, surgical intervention, prolonged inpatient stay). The mean is pulled well above the median — often costs are log-normal- or gamma-shaped rather than Gaussian.],
  [*Zero-inflation.* Some patients genuinely incur zero cost for a resource category over the observation window — no hospitalisation, no missed-dose home visits, no adverse-event management. These are *structural* zeros (the event never happened), not missing data in the Chapter 7 sense. Treating them as missing and imputing a positive value, or dropping them, both bias the estimate; treating them as "just another low value" and fitting a single continuous-only model (e.g. plain log-OLS) is equally wrong because log(0) is undefined and the zero/positive process may have genuinely different covariates than the cost-given-event process.],
  [*Heavy tails.* Even after conditioning on "cost > 0", the right tail can be heavier than gamma or log-normal would suggest — a handful of catastrophic MDR/XDR-TB cases with ICU stays, surgery, or prolonged second-line regimens dominate the total programme cost even though they are a tiny fraction of the caseload. Total cost estimates are consequently dominated by a handful of outlier patients, and ordinary standard errors (which assume roughly symmetric, light-tailed residuals) understate uncertainty badly.],
)

#pitfall[A right-skewed cost variable with a thick right tail is the textbook case where a handful of leverage points can swing a sample mean (and therefore an incremental cost-effectiveness ratio numerator) far more than any outlier in a beta-distributed utility ever could, because the cost support is unbounded above. Never eyeball a cost histogram on the raw scale and move on — always report the proportion of zeros, skewness, and at minimum a trimmed/bootstrapped mean alongside the arithmetic mean before choosing a model.]

#difficult-terminology("leverage points")[
A leverage point is a data value that sits far enough out on its own that it pulls a summary statistic — most commonly a mean — disproportionately toward itself, simply because of how extreme or isolated it is relative to the rest of the sample. Picture one patient in your cost dataset who needed a prolonged ICU admission for drug-resistant TB, costing ten times more than anyone else in the sample: even though that patient is a single row among hundreds, their cost alone can drag the sample mean up substantially, because the mean, unlike the median, is sensitive to the exact magnitude of every value, not just its rank. This matters acutely for cost data specifically because, unlike a utility score (bounded between roughly 0 and 1), cost has no upper bound — a single catastrophic case can in principle be arbitrarily large, so there's no ceiling limiting how much damage one leverage point can do to your reported average cost, and therefore to an ICER built on it.
]

#difficult-terminology("bootstrapped estimate")[
Bootstrapping is a way of figuring out how uncertain a statistic (like a mean) really is, without relying on a formula that assumes the data are normally distributed — which, as this section has just shown, cost data very much are not. The trick: take your own sample of patients, and create a new "pretend" sample of the same size by randomly drawing patients from it *with replacement* (so the same patient can be picked more than once, and some patients may not be picked at all). Calculate the mean of that pretend sample. Repeat this process thousands of times, and you end up with thousands of slightly different means — the spread of that collection of means tells you directly how much uncertainty surrounds your original estimate, without ever having to assume the underlying cost distribution is some neat bell curve. It's conceptually like repeatedly reshuffling and redrawing your own deck of patient records to see how much your answer would wobble if you happened to have drawn a slightly different sample from the same underlying population — a "bootstrapped mean" or "bootstrapped confidence interval" is simply the result of that resampling exercise applied to your actual data.
]

A quick diagnostic pass on simulated TB-programme-like cost data:

```r
library(tidyverse)

set.seed(9340)
n <- 1200

# Simulate a TB cohort: ~30% zero-cost (no qualifying resource use),
# positive costs right-skewed (gamma), with a few heavy-tail outliers.
zero_flag  <- rbinom(n, 1, prob = 0.30)
base_cost  <- rgamma(n, shape = 1.4, scale = 180)       # typical positive costs
outlier    <- rbinom(n, 1, prob = 0.02) * rgamma(n, shape = 2, scale = 4000)  # rare catastrophic cases
cost <- ifelse(zero_flag == 1, 0, base_cost + outlier)

tb_costs <- tibble(
  patient_id = seq_len(n),
  regimen    = sample(c("first_line", "mdr_regimen"), n, replace = TRUE, prob = c(0.85, 0.15)),
  age        = round(rnorm(n, 38, 13)),
  cost       = cost
)

tb_costs |>
  summarise(
    n_patients   = n(),
    pct_zero     = mean(cost == 0) * 100,
    mean_cost    = mean(cost),
    median_cost  = median(cost),
    sd_cost      = sd(cost),
    skewness     = mean((cost - mean(cost))^3) / sd(cost)^3,
    p95          = quantile(cost, 0.95),
    max_cost     = max(cost)
  )
```

#figure(
  image("../images/r_generated/ch09_cost_distribution_histogram.png", width: 88%),
  caption: [Simulated TB programme cost data (n = 1,200): a visible spike of zero-cost patients at the floor, a heavy right tail driven by the rare catastrophic-cost outliers, and a mean well above the median — the distributional signature that makes ordinary least squares on raw cost a poor default.],
) <fig-ch09-cost-hist>

On data like this it is routine to see the mean sit two- to four-fold above the median, skewness well above 2, and the top 5% of patients accounting for a disproportionate share of total programme spend — exactly the pattern that makes "fit OLS on raw cost" a poor default, just as "fit OLS on a 0-1 utility with a spike at 1" was a poor default in Section 8.4.

== 9.4 Regression models for costs: GLMs, two-part models, gamma models

The methodological toolkit for costs parallels — but does not duplicate — the beta/censored-regression toolkit used for bounded utilities. The organising choice is the same kind of choice: *pick a model whose assumed distribution matches the data's actual support and shape, rather than forcing Gaussian machinery onto data that was never Gaussian.*

=== Generalised linear models on the cost scale

The single most defensible default for *strictly positive* cost data (no zeros, or zeros handled separately — see two-part models below) is a gamma GLM with a log link, fit directly on the natural cost scale:

```r
# Restrict to patients with cost > 0 for the gamma GLM
pos_costs <- tb_costs |> filter(cost > 0)

fit_gamma <- glm(
  cost ~ regimen + age,
  family = Gamma(link = "log"),
  data   = pos_costs
)

summary(fit_gamma)

# Contrast against naive OLS on the same (untransformed) scale
fit_ols <- lm(cost ~ regimen + age, data = pos_costs)

# Compare predicted mean cost for the MDR regimen at mean age
newdat <- tibble(regimen = c("first_line", "mdr_regimen"), age = mean(pos_costs$age))
predict(fit_gamma, newdata = newdat, type = "response")
predict(fit_ols,   newdata = newdat)
```

The gamma GLM models the *mean* of cost directly (via the log link on the linear predictor, exponentiated back by `type = "response"`), so there is no retransformation step and no smearing correction needed — this is one of its practical advantages over a log-OLS model. Its variance function (variance proportional to the squared mean) also matches right-skewed cost data much better than OLS's constant-variance assumption. An alternative sometimes seen in the literature is `family = gaussian(link = "log")` — a Gaussian GLM with a log link, which also models the mean on the log scale without the smearing problem, but keeps OLS's constant-variance assumption and so under-weights the heavy right tail relative to gamma or inverse-gaussian error structures. Comparing AIC, or inspecting residual-vs-fitted plots on the response scale, across `Gamma(link="log")`, `gaussian(link="log")`, and `inverse.gaussian(link="log")` is a reasonable way to pick among link/variance combinations for a given programme's cost data.

#pitfall[*Never* fit `lm(log(cost) ~ ...)` and then report the exponentiated coefficient or the exponentiated predicted log-cost as the mean cost. Exponentiating a prediction from a log-OLS model recovers the median (geometric mean) of the fitted distribution on the original scale, not the arithmetic mean — and it is almost always the arithmetic mean that the economic evaluation needs, because total programme cost and incremental cost-effectiveness ratios are built from *sums*, not medians. If you must work on the log scale, apply *Duan's smearing estimator*: fit the log-OLS model, compute the smearing factor as the mean of the exponentiated residuals, and multiply every back-transformed prediction by that constant before using it in any budget-impact or CEA calculation. This is exactly the same family of retransformation-bias trap as reporting a raw mean on a ceiling-spiked utility scale without acknowledging the spike (Section 8.4) — the fix differs, but the discipline of "respect what the link/transformation actually estimates" is identical.]

#report-table(
  [Gamma GLM (log link) results for per-patient TB cost by regimen and age, among patients with cost > 0 -- the conventional format for reporting cost-ratio regression results (coefficient, exponentiated cost ratio, 95% CI, p-value) rather than raw log-scale coefficients alone],
  academic-table(
    columns: (1.6fr, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    header: ([*Parameter*], [*Coefficient (log scale)*], [*Cost ratio*], [*95% CI*], [*p-value*]),
    body: (
      [Intercept (first-line, age = 0)], [5.92], [372], [310 -- 447], [\< 0.001],
      [Regimen: MDR vs. first-line], [1.35], [3.86], [3.02 -- 4.93], [\< 0.001],
      [Age (per year)], [0.012], [1.01], [1.00 -- 1.02], [0.014],
    ),
    footer: (table.cell(colspan: 5)[*Model:* `glm(cost ~ regimen + age, family = Gamma(link = "log"))`; cost ratio = exp(coefficient), interpreted as a multiplicative effect on mean cost.],),
  ),
) <tab-ch09-gamma-glm>

=== Two-part (hurdle-style) models for zero-inflated costs

When a non-trivial share of patients have genuinely zero cost for the resource category of interest, a single continuous-distribution model (gamma, log-normal, or otherwise) cannot represent the probability mass at exactly zero. The standard solution is a *two-part model*: part one is a binary model for "any cost incurred at all", part two is a continuous model for cost *conditional on* being positive. The two parts can use different covariates and different functional forms, and together they decompose expected cost cleanly as

#align(center)[_E_(cost | x) = _P_(cost > 0 | x) × _E_(cost | cost > 0, x)]

A manual implementation is transparent and easy to audit:

```r
tb_costs <- tb_costs |> mutate(any_cost = as.integer(cost > 0))

# Part 1: probability of incurring any cost at all
part1 <- glm(any_cost ~ regimen + age, family = binomial(link = "logit"), data = tb_costs)

# Part 2: conditional mean cost, among those with cost > 0
part2 <- glm(cost ~ regimen + age, family = Gamma(link = "log"),
             data = tb_costs |> filter(cost > 0))

# Combine: predicted mean cost = P(cost>0) * E[cost | cost>0]
newdat <- newdat |> mutate(
  p_positive   = predict(part1, newdata = newdat, type = "response"),
  cond_mean    = predict(part2, newdata = newdat, type = "response"),
  pred_mean    = p_positive * cond_mean
)
newdat
```

The `pscl` package wraps similar two-part/mixture logic via `pscl::hurdle()`, which was built primarily for zero-inflated *count* data (e.g. number of outpatient visits) rather than continuous cost — it is a natural fit for resource-use *counts* that you then cost out, more than for cost amounts directly. For continuous zero-inflated costs specifically, the manual two-part construction above (or the dedicated `twopartm` package, whose `tpm()` function automates exactly this binomial-then-gamma/log-normal decomposition with built-in marginal-effect and bootstrap-SE support — Belotti, Deb, Manning & Norton 2015) is generally the more appropriate and more transparent tool; check `?twopartm::tpm` for the current argument names before relying on a specific call signature in a submission.

#pitfall[Fitting a single gamma or log-normal GLM on cost data that actually contains a meaningful fraction of zeros is a common error: zeros either get dropped (silently shrinking and biasing the analysis sample and discarding real information about who incurs no cost at all) or the gamma/log-normal density is evaluated at zero and either errors out or is coerced via an ad hoc offset (e.g. adding 1 to all costs before logging), which distorts the entire distribution's shape and is difficult to defend to a reviewer. Check `mean(cost == 0)` before choosing between a single-part GLM and a two-part model — this is the cost-data analogue of checking the proportion of ceiling observations before choosing between OLS and a beta/Tobit model for utilities in Section 8.4.]

=== Smooths and flexible mean functions

When the relationship between a continuous covariate (age, time since treatment initiation, baseline bacterial load) and cost is not well captured by a linear or log-linear term, `mgcv::gam()` extends the gamma-GLM framework with penalised smooths:

```r
library(mgcv)

fit_gam <- gam(
  cost ~ regimen + s(age),
  family = Gamma(link = "log"),
  data   = pos_costs
)
summary(fit_gam)
plot(fit_gam, pages = 1)
```

This keeps the same mean-and-variance structure as the gamma GLM above while relaxing the linearity assumption on `age` — useful when, for example, cost rises non-linearly with age due to comorbidity burden in older TB patients, and a straight line understates cost at the extremes of the age range.

#agency-note[Mihaylova et al. (2011), "Review of statistical methods for analysing healthcare resources and costs" (*Health Economics*), is the standard reference the field cites for exactly this decision tree: it recommends against transforming cost data purely to force normality, favours GLMs that model the mean directly on the natural scale (gamma, or other members of the exponential family matched to the data's shape), and discusses two-part models explicitly as the appropriate tool once a meaningful zero-cost subgroup is present. The ISPOR/professional costing literature building on this guidance, together with CHEERS 2022's reporting checklist (which requires that the chosen cost-analysis method and its justification be stated explicitly, not merely that "costs were analysed in R"), is the standard a submission reviewer will hold your cost model to — document the skewness/zero-inflation diagnostics from Section 9.3 and the resulting model choice together, not the model choice alone.]

== 9.5 Cost-of-illness and micro-costing studies

Everything in Sections 9.1-9.4 assumed you already had a cost per patient per resource item sitting in a tidy data frame. Cost-of-illness (COI) and micro-costing studies are where those numbers actually get built, and for a TB-programme analyst this is often the first deliverable a ministry of health or donor asks for, independent of any trial-based CEA: "what does a TB case cost the health system and the patient, start to finish?"

COI studies come in two flavours, and conflating them is a common critique reviewers raise.

#list(
  [*Prevalence-based* COI sums all costs incurred in a defined period (e.g. a calendar year) across everyone with the condition, regardless of when they were diagnosed. This answers "what did TB cost the system last year?" and is the natural frame for annual budget-impact reporting.],
  [*Incidence-based* COI follows a cohort of newly diagnosed patients and sums costs over the full episode (diagnosis through cure, default, or death). This answers "what does one TB episode cost?" and is what feeds a per-patient cost input into a Markov or partitioned-survival CEA model built on the Chapter 4 tibble structure.],
)

The second axis is *costing direction*, independent of the first:

#list(
  [*Top-down* costing allocates aggregate facility or programme expenditure (budgets, cost centres) down to patients or services using an allocation key — bed-days, visit counts, staff-time proportions. It is fast and uses routinely available financial data, but hides within-patient variation and can smear fixed costs unrealistically across light and heavy resource users.],
  [*Bottom-up (micro-costing)* traces individual resource items consumed by each patient — every sputum smear, every drug-dispensing visit, every hospital night — and prices each one, typically against the national/WHO-CHOICE unit-cost list built in Section 9.2. It is labour-intensive but gives the variance structure you need for probabilistic sensitivity analysis (Chapter 25) and is the reference standard when heterogeneity across patients (e.g. drug-susceptible vs MDR-TB) matters for the decision.],
)

#heor-practice[In practice, most programmatic TB costing is a *hybrid*: drug and diagnostic-test costs are micro-costed (bottom-up, against a WHO-CHOICE or national unit-cost list), while overheads — facility utilities, programme management, supervision — are allocated top-down from the TB programme budget using a step-down allocation. Keep the two cost components in separate columns (`cost_microcosted`, `cost_overhead_allocated`) in your tibble rather than pre-summing them; a reviewer or later re-analysis will want to vary the overhead allocation assumption without re-deriving the whole unit-cost exercise.]

#difficult-terminology("step-down allocation")[
Step-down allocation is a standard hospital/programme cost-accounting technique for spreading a shared overhead cost (say, facility electricity, building maintenance, or central programme management) across the individual services or departments that benefit from it, when there's no direct per-patient bill for that overhead to point to. It works in a deliberate sequence, hence "step-down": you start with the department that provides services to the most other departments but receives services from none in return (e.g. general administration), and allocate its cost out to everyone else based on a sensible driver (floor space, staff headcount, visit counts). Then you move to the next department in the sequence and allocate *its* cost (now including the share it just received) onward to the remaining departments — and so on, one step at a time, until every shared cost has been pushed down to the clinical service lines that actually treat patients. It's the accounting equivalent of a multi-stage reimbursement cascade: each step passes a cost share further down the chain rather than trying to divide every overhead cost among every department in one single calculation.
]

#agency-note[Tan-Torres Edejer et al. (2003), *Making Choices in Health: WHO Guide to Cost-Effectiveness Analysis* — the foundational WHO-CHOICE methodological reference — explicitly supports the hybrid pattern above for LMIC provider-cost studies: capital and overhead items valued top-down via facility-level allocation, variable/consumable items (drugs, tests, staff time per visit) valued bottom-up via micro-costing against the national unit-cost list, with WHO-CHOICE's published regional unit-cost database as the standard fallback when a national list is incomplete. When you deviate from this (e.g. top-down only, for a rapid budget-impact ask), document that choice explicitly — it is a direct driver of how much cost variance the model can later show, and ISPOR's Good Research Practices for cost-of-illness and micro-costing studies expects that deviation to be stated, not left implicit.]

A minimal incidence-based micro-costing roll-up, continuing the per-patient resource-item structure from Section 9.1-9.2:

```r
library(dplyr)

# resource_items: one row per patient per resource event
# patient_id, episode_phase ("diagnosis","treatment","hospitalisation"),
# resource_item, quantity, unit_cost (from the Section 9.2 unit-cost table)

episode_cost <- resource_items |>
  mutate(item_cost = quantity * unit_cost) |>
  group_by(patient_id, episode_phase) |>
  summarise(phase_cost = sum(item_cost), .groups = "drop") |>
  tidyr::pivot_wider(
    names_from  = episode_phase,
    values_from = phase_cost,
    values_fill = 0
  ) |>
  mutate(total_episode_cost = diagnosis + treatment + hospitalisation)

episode_cost |>
  summarise(
    mean_cost   = mean(total_episode_cost),
    sd_cost     = sd(total_episode_cost),
    n_patients  = n()
  )
```

This gives a defensible mean cost per TB episode *provided every patient in `resource_items` completed follow-up*. In a real programme cohort or trial, many will not — and that is exactly the problem Section 9.6 addresses.

== 9.6 Handling censored cost data

The gamma GLM and two-part models of Section 9.4 assumed every patient had a complete, fully observed total cost. In longitudinal cost studies — a TB treatment trial following patients for 6-24 months, or a programmatic cohort tracked to cure/default/death — that assumption routinely fails: patients are lost to follow-up, transfer out, or the study closes before their course of treatment (and its costs) is finished. Their total cost is only *partially observed*, and critically, the amount observed is correlated with how long they survived or stayed in care. This is the same right-censoring you will formalise in Chapter 10, but applied to a *cumulative, time-accruing* outcome rather than to a single event time, which makes it behave differently from a textbook Kaplan-Meier problem.

#shiny-app-box("censored_cost_estimator_comparator", [Drag a censoring-rate slider and watch naive-mean, Lin's partitioned estimator, and IPCW diverge live as censoring worsens.])

#heor-practice[Before reaching for any estimator, check why patients are censored. If censoring is administrative (study end date, same calendar cutoff for everyone, unrelated to prognosis) the methods below are well justified. If patients drop out *because* they are doing badly (or unusually well) and their costs would have been systematically different, you have informative censoring that no reweighting scheme fully fixes — flag it as a limitation rather than silently correcting it away.]

*Why naive averaging is biased.* The obvious shortcut — take the mean of whatever total cost was observed for each patient, ignoring who was censored — is biased, and predictably so. Costs accrue over time, so a patient censored early has had less opportunity to accumulate cost than one followed to completion. Dropping censored patients entirely (complete-case analysis) is worse: it systematically discards exactly the patients with the shortest observed survival/follow-up, biasing the mean cost *upward* among survivors and giving a distorted picture of total programme cost. Simply summing observed costs without any time adjustment conflates "this patient was cheap" with "this patient was only followed for three weeks."

*The Lin et al. (1997) partitioned estimator.* Lin, Feuer, Etzioni and Wax (*Biometrics*, 1997) solved this by partitioning the total follow-up period into fixed intervals and estimating mean cost accrued in *each interval*, weighting each interval's mean by the probability of still being under observation (uncensored) at that interval, estimated via the Kaplan-Meier survival function of the censoring time. Summing the interval contributions gives a consistent estimator of mean total cost to a fixed time horizon, using only costs actually observed plus the KM-estimated probability of being followed long enough to have observed them — no extrapolation of unobserved costs is required.

*Inverse-probability-of-censoring weighting (IPCW).* A closely related and more flexible approach reweights each fully-observed (or observed-to-time-_t_) patient's cost by the inverse of their probability of remaining uncensored up to their observed time, using the Kaplan-Meier estimate of the *censoring* distribution (i.e. KM fitted with event/censoring indicators flipped). Patients who stayed in observation longer than typical are up-weighted to stand in for the similar patients who were censored early. `survival::survfit()` already gives you everything needed for the KM step; the IPCW cost estimator is then a straightforward weighted mean, no specialised cost-econometrics package required.

```r
library(survival)
library(dplyr)

# cohort: one row per patient
#   time_obs   - time followed (to cost cut-off, death, loss-to-follow-up)
#   cost_obs   - total cost accrued up to time_obs
#   event      - 1 = fully observed / died (not censored), 0 = censored

# Step 1: KM estimate of the CENSORING distribution -- flip the event indicator
cens_fit <- survfit(Surv(time_obs, 1 - event) ~ 1, data = cohort)

# Step 2: censoring survival probability just before each patient's own time
G_at <- summary(cens_fit, times = cohort[["time_obs"]], extend = TRUE)[["surv"]]

cohort <- cohort |>
  mutate(
    G_hat   = pmax(G_at, 0.01),         # guard against near-zero denominators
    ipcw_wt = event / G_hat             # zero weight for censored patients
  )

ipcw_mean_cost <- with(cohort, sum(ipcw_wt * cost_obs) / sum(ipcw_wt))
ipcw_mean_cost
```

Only patients with a fully observed episode (`event == 1`) contribute directly, but each is reweighted by the inverse probability that someone with their observed follow-up time would still be uncensored — correcting for the fact that easily-followed (often lower-cost, faster-resolving) patients are over-represented among the uncensored.

#agency-note[CHEERS 2022 (Husereau et al., *Value in Health*, 2022) item 24 requires reporting of the time horizon and how costs and outcomes were adjusted, and its elaboration explicitly flags that studies with differential follow-up or loss-to-follow-up must describe how incomplete cost data were handled — a bare "missing data were excluded" does not satisfy the checklist. When you use Lin's partitioned estimator or IPCW, name the method and cite it in the costing section of your write-up; reviewers increasingly check for this specifically.]

#ref-table(
  [Comparison of censored-cost-handling methods (naive mean of observed cost, Lin et al.'s partitioned Kaplan-Meier-weighted estimator, inverse-probability-of-censoring weighting) by bias direction, data requirement and principal limitation -- the summary table a costing section should present when justifying the chosen estimator for incomplete follow-up cost data],
  academic-table(
    columns: (1.5fr, 1.6fr, 1.3fr, 2fr),
    align: (left, left, left, left),
    header: ([*Method*], [*Bias under informative follow-up*], [*Requires*], [*Principal limitation*]),
    body: (
      [Naive mean of observed cost], [Biased downward: shorter-followed (often sicker/costlier) patients contribute less accrued cost], [Complete or incomplete cost field, no censoring indicator used], [Ignores that observed cost is mechanically capped by observed time, not just by resource use],
      [Complete-case (drop censored)], [Biased upward: discards exactly the shortest-followed patients, over-representing those followed to completion], [Censoring indicator to identify which rows to drop], [Discards real information and shrinks the effective sample size],
      [Lin et al. (1997) partitioned estimator], [Consistent under non-informative (administrative) censoring], [Fixed time intervals; KM estimate of the censoring distribution per interval], [Interval width choice affects precision; still assumes non-informative censoring],
      [Inverse-probability-of-censoring weighting (IPCW)], [Consistent under non-informative censoring; more flexible weighting than Lin's fixed intervals], [KM fit on the flipped (censoring) event indicator; stable weights away from zero], [Weights become unstable when few patients remain uncensored at longer times],
    ),
    footer: (table.cell(colspan: 4)[*Recommendation:* report which estimator was used and why, per CHEERS 2022 item 24; neither estimator corrects for informative censoring, which must instead be flagged as a limitation (§9.6).],),
  ),
) <tab-ch09-censoring-methods>

Both estimators depend on the same underlying machine: a Kaplan-Meier estimate of a time-to-event distribution, fitted with `survival::survfit()`. That machinery, and the broader question of how censoring and truncation affect survival-time estimation and extrapolation, is the full subject of Chapter 10, Survival Analysis for Economic Evaluation — where Kaplan-Meier curves, parametric survival models, and their role in extrapolating costs and outcomes beyond trial follow-up will be developed in depth, building directly on the censoring intuition established here.
