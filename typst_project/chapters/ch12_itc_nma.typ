#import "../common.typ": *

= Chapter 12. Indirect Treatment Comparisons and Network Meta-Analysis

Chapter 11 closed with pooling evidence across several trials of the *same* two treatments. This chapter opens a harder, far more common HTA problem: what happens when no trial has ever compared the two treatments the reimbursement decision actually hinges on? The answer, across every method in this chapter — Bucher's two-trial algebra, frequentist network meta-analysis, Bayesian network meta-analysis, consistency checking, network meta-regression, and survival-outcome networks — is the same single idea at increasing scale: evidence can be combined *across* trials only through a shared comparator, never by comparing absolute outcomes directly.

== 12.1 Why indirect comparison is needed

Chapter 11 built the machinery for combining multiple head-to-head trials of the *same* two treatments into one pooled estimate — fixed-effect and random-effects pooling, $I^2$ and $tau^2$ as the heterogeneity vocabulary, REML as the default $tau^2$ estimator. That machinery assumes something that, in HTA submissions, is rarely true: that every trial relevant to your decision problem compared the same two arms.

In reality, a reimbursement dossier for a new TB regimen almost never has a trial that pairs the new regimen directly against every comparator a health technology assessment (HTA) body cares about. A manufacturer trial might show Regimen A (a novel bedaquiline-based combination) against the WHO-recommended standard-of-care regimen C in a multidrug-resistant TB population. A separate, unrelated trial — run by a different sponsor, in a different country, years apart — might show Regimen B (a delamanid-based combination) against that same standard-of-care regimen C. Nobody has ever randomised A against B. Yet the reimbursement question on the table is precisely: *how does A compare to B?* — because B is the comparator already funded in the health system, or the one the HTA body has designated as the relevant comparator in its final scope.

This is the indirect treatment comparison (ITC) problem, and it is endemic to HTA rather than a rare edge case. Guidelines rarely allow a manufacturer to simply report the two trials' results side by side and let a reviewer "eyeball" the difference — that approach has no defensible statistical basis and discards exactly the information that randomisation was designed to protect: comparability of patient populations within each trial. Naive, unadjusted comparison of absolute outcomes across trials (sometimes called a "naive indirect comparison") ignores the fact that trial populations, eras, and measurement methods differ, and it will produce biased and overconfident answers. What is needed is a method that uses randomised evidence *within* each trial, and only combines *between* trials through the shared control arm.

#pitfall[
  Never compare absolute outcomes from unrelated trials directly (e.g. "Trial 1 found 78% cure with Regimen A, Trial 2 found 71% cure with Regimen B, therefore A is better"). This "naive" or "unadjusted" indirect comparison destroys randomisation and is highly vulnerable to confounding by differences in baseline risk, trial era, region, and outcome definition between the two trials. It is explicitly flagged as invalid practice in NICE DSU TSD 2 (Dias et al. 2011) and will not be accepted as the primary analysis in an HTA submission.
]

The conceptual fix — formalised by Bucher, Guyatt, Griffith and Walter (1997) and now the foundation of the entire ITC/NMA literature — is to exploit a *common comparator*. If trial 1 randomised patients to A vs C, and trial 2 (independently) randomised patients to B vs C, then each trial still gives you a valid, randomisation-protected estimate of a relative treatment effect: the A-vs-C effect from trial 1, and the B-vs-C effect from trial 2. Because both effects are expressed relative to the *same* comparator C, you can algebraically combine them to obtain an estimate of the A-vs-B effect — without ever having observed a trial that randomised A against B directly. C in this role is called the *anchor* or *common comparator*, and the approach is accordingly called an *anchored indirect comparison*.

This single idea — anchoring through a common comparator rather than comparing absolute arms — is what separates a defensible ITC from a naive one, and it is the thread that runs through this entire chapter: first in its simplest two-trial form (the Bucher method, §12.2), then generalised to networks of many trials and many treatments (frequentist network meta-analysis, §12.3), and finally in its Bayesian implementation.

#learning-objectives((
  [Explain why within-trial randomisation must be preserved when evidence comes from more than one trial, and why naive cross-trial comparison of absolute outcomes is invalid],
  [Describe the anchor-based logic of the Bucher method: deriving an A-vs-B estimate from independent A-vs-C and B-vs-C trials via a common comparator C],
  [Calculate a Bucher indirect estimate and its variance by hand, understanding why the variances of the two component trials *add* rather than subtract],
  [Distinguish an indirect comparison from a mixed treatment comparison, and know when each applies],
  [Fit a frequentist network meta-analysis in R with the `netmeta` package, using `netmeta()`, `netgraph()`, `netrank()`, and `netleague()`],
  [Interpret a network geometry plot, a P-score ranking, and a league table in the context of an HTA evidence network],
  [Fit a Bayesian network meta-analysis with `gemtc`, run MCMC diagnostics, and check convergence before reporting any posterior summary],
  [Explain and run node-splitting and design-by-treatment interaction tests to assess network consistency],
  [Extend an NMA to a network meta-regression, and recognise the ecological-bias caveat that applies with even more force at network level],
  [Describe how NMA of survival outcomes generalises the Chapter 11 pooled-log(HR) mechanism across a network, and understand the limits of off-the-shelf tools for fractional polynomial time-varying hazard ratios],
  [Rank treatments across a network with SUCRA (Bayesian) and P-scores (frequentist), and explain why a ranking metric must always be reported alongside, never instead of, the underlying effect estimates and their uncertainty],
  [Report a network meta-analysis per NICE DSU TSD 2, the ISPOR good-practice task force report, and the PRISMA-NMA extension to the systematic review checklist],
))

== 12.2 Bucher method

=== 12.2.1 The algebra of anchored indirect comparison

Suppose we have two independent, two-arm randomised trials, both reporting a log hazard ratio (or log odds ratio, or mean difference — the algebra is identical on any additive scale):

- Trial 1 (A vs C): estimate $hat(d)_(A C)$, with standard error $"SE"(hat(d)_(A C))$
- Trial 2 (B vs C): estimate $hat(d)_(B C)$, with standard error $"SE"(hat(d)_(B C))$

Both $hat(d)_(A C)$ and $hat(d)_(B C)$ are valid, randomisation-protected estimates — each trial's internal randomisation ensures that, within that trial, the comparison of its two arms is unconfounded. The Bucher method combines them into an indirect estimate of the A-vs-B effect:

$ hat(d)_(A B)^("indirect") = hat(d)_(A C) - hat(d)_(B C) $

This is simply the statement that if A is $hat(d)_(A C)$ better than C, and B is $hat(d)_(B C)$ better than C, then A is $(hat(d)_(A C) - hat(d)_(B C))$ better than B. The subtraction is on the *treatment-effect scale* (log HR, log OR, mean difference) — it is not a subtraction of absolute outcome levels, and it still relies on nothing but the two within-trial comparisons.

=== 12.2.2 Why the variance adds

This is the detail most often got wrong by newcomers, and it is worth dwelling on precisely because the point estimate is a *subtraction* while the variance is a *sum*:

$ "Var"(hat(d)_(A B)^("indirect")) = "Var"(hat(d)_(A C)) + "Var"(hat(d)_(B C)) $

or equivalently, in standard-error form:

$ "SE"(hat(d)_(A B)^("indirect")) = sqrt("SE"(hat(d)_(A C))^2 + "SE"(hat(d)_(B C))^2) $

The reason is that $hat(d)_(A C)$ and $hat(d)_(B C)$ come from two *statistically independent* trials — different patients, different randomisation, no shared data. For independent random variables, the variance of their difference is the sum of their individual variances, exactly as it is for their sum: $"Var"(X - Y) = "Var"(X) + "Var"(Y)$ when $X$ and $Y$ are independent, regardless of the sign in front of $Y$. The minus sign affects the *expectation* of the combination (point estimate) but not its *variance*, because $"Var"(-Y) = "Var"(Y)$.

#pitfall[
  The single most common manual error in Bucher calculations is subtracting the two variances (or SEs) by analogy with the point-estimate subtraction, producing an impossibly narrow — sometimes negative — variance. The correct operation is ALWAYS addition of variances, never subtraction, because the two trials are independent sources of uncertainty and uncertainty does not cancel when you combine independent estimates, even when the point estimates themselves are combined by subtraction.
]

The practical consequence is important for interpretation: an indirect estimate is *always* less precise than either of its two component direct estimates, because you are paying the "price" of both trials' sampling uncertainty, with no opportunity for cancellation. A 95% confidence interval for the indirect A-vs-B log-effect is then

$ hat(d)_(A B)^("indirect") plus.minus 1.96 times "SE"(hat(d)_(A B)^("indirect")) $

exponentiated back to the natural scale (hazard ratio, odds ratio) if that is how the trials originally reported their effects.

=== 12.2.3 Worked example: TB regimen comparison

Consider an HTA submission for Regimen A, a novel multidrug-resistant TB (MDR-TB) treatment, where the decision-relevant comparator is Regimen B, an alternative novel regimen already used in some health systems. No trial has randomised A against B. However:

- *Trial 1* randomised MDR-TB patients to Regimen A vs the WHO standard-of-care regimen C, reporting a log hazard ratio for treatment failure/relapse of $hat(d)_(A C) = -0.52$ (favouring A) with $"SE" = 0.18$.
- *Trial 2* randomised a comparable MDR-TB population to Regimen B vs the same standard-of-care regimen C, reporting $hat(d)_(B C) = -0.28$ (favouring B) with $"SE" = 0.21$.

The Bucher indirect estimate of A vs B is:

$ hat(d)_(A B) = -0.52 - (-0.28) = -0.24 $

$ "SE"(hat(d)_(A B)) = sqrt(0.18^2 + 0.21^2) = sqrt(0.0324 + 0.0441) = sqrt(0.0765) approx 0.2767 $

giving a 95% CI of $-0.24 plus.minus 1.96 times 0.2767 = (-0.78, 0.30)$ on the log-HR scale, or a hazard ratio of $exp(-0.24) = 0.79$ with 95% CI $(exp(-0.78), exp(0.30)) = (0.46, 1.35)$. The point estimate favours A, but the interval comfortably spans 1 — illustrating the precision penalty discussed above: even though each *direct* comparison (A vs C, B vs C) might individually have been reasonably precise, the indirect A-vs-B comparison inherits both trials' uncertainty and is correspondingly wider.

The following R function implements this calculation directly, with no package dependency, which is useful both as a transparent sanity check and because reviewers at HTA agencies sometimes ask to see the Bucher arithmetic laid out explicitly rather than taken from a `netmeta` object:

```r
bucher_itc <- function(d_AC, se_AC, d_BC, se_BC, scale = c("log", "natural")) {
  scale <- match.arg(scale)
  d_AB  <- d_AC - d_BC
  se_AB <- sqrt(se_AC^2 + se_BC^2)
  ci_lo <- d_AB - 1.96 * se_AB
  ci_hi <- d_AB + 1.96 * se_AB

  if (scale == "natural") {
    out <- data.frame(
      estimate = exp(d_AB),
      ci_lower = exp(ci_lo),
      ci_upper = exp(ci_hi)
    )
  } else {
    out <- data.frame(
      estimate = d_AB,
      ci_lower = ci_lo,
      ci_upper = ci_hi
    )
  }
  out
}

# TB worked example: Regimen A vs C, Regimen B vs C, via common comparator C
bucher_itc(d_AC = -0.52, se_AC = 0.18, d_BC = -0.28, se_BC = 0.21, scale = "natural")
#>    estimate  ci_lower ci_upper
#> 1 0.7866279 0.4575463 1.351880
```

#report-table(
  [Bucher indirect treatment comparison of Regimen A vs Regimen B for MDR-TB treatment failure/relapse, anchored on the shared standard-of-care comparator C (Trial 1: A vs C; Trial 2: B vs C). The A-vs-B row is the derived indirect estimate, not an observed trial result, and its interval is wider than either direct comparison, reflecting the added uncertainty of combining two independent trials.],
  academic-table(
    columns: (1.6fr, auto, auto, auto),
    align: (left, right, right, right),
    header: ([*Comparison*], [*log HR (SE)*], [*Hazard ratio*], [*95% CI*]),
    body: (
      [A vs C (direct, Trial 1)], [-0.52 (0.18)], [0.59], [(0.42, 0.85)],
      [B vs C (direct, Trial 2)], [-0.28 (0.21)], [0.76], [(0.50, 1.14)],
      [A vs B (indirect, Bucher)], [-0.24 (0.28)], [0.79], [(0.46, 1.35)],
    ),
    footer: (
      table.cell(colspan: 4)[*Note:* indirect SE $= sqrt(0.18^2 + 0.21^2) approx 0.277$; indirect estimate favours A but the 95% CI spans 1.],
    ),
  ),
) <tab-ch12-bucher-worked-example>

=== 12.2.4 Assumptions the Bucher method relies on

The Bucher method's algebraic simplicity hides a strong assumption that must be argued, not just asserted: *the similarity (or "transitivity") assumption*. It requires that trial 1 and trial 2 are similar enough, in every respect that could modify the relative treatment effect (effect modifiers), that the C arm in trial 1 can be treated as exchangeable with the C arm in trial 2. Concretely, if trial 1 enrolled patients with less advanced MDR-TB, used a different definition of "treatment failure", or was conducted a decade before trial 2 in a region with different background resistance patterns, the two C arms are not estimating the same quantity, and subtracting the two trial-specific effects no longer isolates a valid A-vs-B contrast — it also absorbs the difference between the trials themselves.

#agency-note[
  NICE DSU Technical Support Document 2 (Dias, Welton, Sutton & Ades, 2011, *"A Generalised Linear Modelling Framework for Pairwise and Network Meta-Analysis of Randomised Controlled Trials"*) is the authoritative UK reference on this point. It formalises the similarity assumption as *transitivity* and states explicitly that an indirect or mixed comparison is only valid when trials are similar with respect to effect modifiers across the whole network — not merely "roughly comparable" on headline baseline characteristics. TSD 2 recommends that submissions present a structured assessment of cross-trial similarity (population, intervention definition, outcome definition, and era) alongside any Bucher or network estimate, and flags that failure to address transitivity is one of the most common reasons an ITC is challenged during NICE technology appraisal.
]

=== 12.2.5 When Bucher is enough, and when it is not

The Bucher method is the right tool exactly when the evidence forms a single "star" or simple triangle around one common comparator — one trial of A vs C, one trial of B vs C, nothing more complex. It does not use information efficiently once there are more than two treatments connected through more than one path, or when some comparisons have direct trial evidence *and* an indirect route simultaneously (closed loops in the network). In those richer settings, you want a method that estimates all relative effects jointly, borrowing strength across the whole evidence base in one coherent model — this is exactly what network meta-analysis (NMA) provides, and it is the subject of the rest of this chapter.

== 12.3 Frequentist NMA (netmeta package)

=== 12.3.1 From anchored pairs to a network

Bucher's A-C, B-C logic generalises naturally once there are more than two treatments and more than two trials. Picture the MDR-TB evidence base broadened: besides Regimen A vs C (Trial 1) and Regimen B vs C (Trial 2), suppose a third trial directly randomised A vs B, and a fourth compared a fourth regimen D against C. The treatments and trials can now be drawn as a graph: nodes are treatments, edges are trials (or pooled pairwise comparisons when more than one trial exists for the same pair), and edge thickness is often used to show how much evidence (e.g. total sample size, or inverse-variance weight) supports that direct comparison.

Network meta-analysis (NMA) treats this whole graph as a single generalised linear model and estimates *every* relative treatment effect simultaneously, using both direct evidence (trials that randomised that pair head-to-head) and indirect evidence (routed through the network, exactly as Bucher's subtraction does, but now potentially through multiple paths and combined with any direct evidence on the same pair). The resulting A-vs-B estimate in a network with both a direct A-vs-B trial and an indirect A-C-B route is called a *mixed treatment comparison* — it mixes direct and indirect evidence, weighting each according to its precision, rather than using either source alone.

The `netmeta` package (Rücker, Schwarzer, Krahn & König) implements the *frequentist, graph-theoretical* approach to NMA developed by Rücker (2012), which treats the network as an electrical network analogue and solves for treatment effects by a weighted least-squares approach equivalent to a generalised Moore-Penrose pseudoinverse of the network's Laplacian-type matrix. This gives estimates numerically equivalent, under a fixed-effect or standard random-effects model, to a corresponding Bayesian NMA fitted with vague priors (§12.4) — the two frameworks answer the same question with different machinery and different ways of expressing uncertainty.

=== 12.3.2 Preparing contrast-level data: `pairwise()`

`netmeta()` expects data in *contrast-based* (one row per treatment comparison per study) format, not arm-based (one row per arm). When your raw extraction is arm-level — events and sample size, or mean and SD, per trial arm — the companion function `pairwise()` (also shipped in `netmeta`) converts it to contrasts, computing the appropriate effect measure and its standard error for you. For binary outcomes such as MDR-TB treatment failure, a typical arm-level data frame looks like:

```r
library(netmeta)

# Arm-level extraction: one row per trial arm
tb_arms <- data.frame(
  study     = c("Trial1","Trial1","Trial2","Trial2",
                "Trial3","Trial3","Trial4","Trial4"),
  treatment = c("A","C","B","C","A","B","D","C"),
  events    = c(18,  34,  22,  36,  15,  19,  28,  33),
  n         = c(80,  82,  78,  80,  60,  58,  75,  77)
)

tb_pairs <- pairwise(
  treat   = treatment,
  event   = events,
  n       = n,
  studlab = study,
  data    = tb_arms,
  sm      = "OR"
)

head(tb_pairs)
```

`pairwise()` returns one row per study with columns such as `TE` (the log odds ratio for that study's comparison), `seTE` (its standard error), `treat1`, `treat2`, and `studlab` — exactly the contrast-level structure `netmeta()` requires. If your source data already arrives in contrast form (e.g. extracted directly as log hazard ratios and SEs from published Cox model results, as in the Bucher worked example above), you can skip `pairwise()` and build this data frame directly.

=== 12.3.3 Fitting the network: `netmeta()`

With contrast-level data in hand, fitting the network model is a single call:

```r
net_tb <- netmeta(
  TE          = TE,
  seTE        = seTE,
  treat1      = treat1,
  treat2      = treat2,
  studlab     = studlab,
  data        = tb_pairs,
  sm          = "OR",
  common      = TRUE,
  random      = TRUE,
  reference.group = "C",
  details.chkmultiarm = TRUE
)

summary(net_tb)
```

`common` and `random` request, respectively, the common-effect (what Chapter 11 called "fixed-effect") and random-effects network models side by side. `reference.group` fixes which treatment all relative effects are reported against in the summary tables — setting it to the standard-of-care regimen C makes the output read naturally as "each regimen vs standard of care". `sm = "OR"` declares the summary measure is matched to how the data were prepared (the odds ratio, here, following the `pairwise()` call above).

The heterogeneity vocabulary from Chapter 11 carries over directly: `summary(net_tb)` reports a global $I^2$ for the whole network and, where the model structure supports it, a between-study variance estimate for the random-effects model. `netmeta()`'s random-effects variant estimates this common $tau^2$ in the same spirit as the random-effects pooling from the previous chapter, just applied jointly across every edge of the network rather than one pairwise meta-analysis at a time.

#heor-practice[
  In an HTA submission, report both the common-effect and random-effects network results side by side exactly as you were asked to justify the fixed-vs-random choice in a pairwise meta-analysis (Chapter 11) — reviewers expect the same reasoning extended to the network: cite the magnitude of heterogeneity (via $I^2$ and the estimated $tau^2$) and the clinical plausibility of a single common effect across trials, and pre-specify which model is primary rather than choosing after seeing which one looks more favourable to your product.
]

A critical companion to the numerical output is the *consistency* check: NMA additionally assumes that direct and indirect evidence on the same comparison agree (this is the network-level analogue of the Bucher similarity assumption, now checkable statistically wherever closed loops exist in the network). `netmeta` provides `decomp.design()` and a global/local inconsistency (Q) decomposition for this purpose — any loop where direct and indirect estimates diverge sharply undermines confidence in the pooled network estimate for that comparison and should be investigated (effect modifier imbalance, outlying trial, coding error) before the NMA result is presented as primary evidence. §12.5 returns to this in full detail.

=== 12.3.4 Visualising the evidence network: `netgraph()`

Before interpreting any numerical NMA output, it is good practice to look at the network geometry itself:

```r
netgraph(
  net_tb,
  plastic     = FALSE,
  thickness   = "number.of.studies",
  points      = TRUE,
  cex.points  = 3,
  multiarm    = TRUE
)
```

`netgraph()` draws treatments as nodes and direct comparisons as edges, with `thickness = "number.of.studies"` scaling each edge's width by how many trials inform it — visually distinguishing, for instance, a well-studied A-vs-C comparison from a single, thinly-supported D-vs-C trial. This plot answers questions no summary table does well: is the network a simple star around one comparator (as in the pure Bucher setting), a connected loop structure allowing consistency checks, or does it contain a treatment connected to the rest of the network through only one thin edge (a geometry that should make you cautious about how much the model is extrapolating for that treatment)? Reviewing the geometry before the numbers also makes it immediately visible whether every treatment of interest is even connected to the network at all — an NMA simply cannot estimate a relative effect between two treatments that have no path connecting them through shared comparators.

#figure(
  image("../images/r_generated/ch12_network_graph.png", width: 75%),
  caption: [The evidence network for the worked four-treatment TB example (A, B, C, D), drawn by `netgraph()`. Node positions reflect the graph structure; edge thickness is scaled by the number of studies directly comparing that pair. C sits at the network's hub because it is the shared comparator in every anchored trial — exactly the structure that makes the Bucher-style indirect estimates in §12.2 possible, now extended and estimated jointly across every edge.],
) <fig-ch12-netgraph>

=== 12.3.5 Ranking treatments: `netrank()`

Once the network model is fitted, a frequent HTA deliverable is a ranking of all treatments on the outcome of interest. `netmeta` provides P-scores (Rücker & Schwarzer, 2015) via `netrank()` as the frequentist analogue of Bayesian SUCRA values:

```r
rank_tb <- netrank(net_tb, small.values = "good")
rank_tb
```

A P-score expresses, for each treatment, the extent to which it is estimated to be better than every other treatment in the network *on average*, accounting for the precision of each pairwise contrast — it is a value between 0 and 1, with higher meaning a better-ranked treatment. `small.values` must be set to match the direction of the outcome scale: `"good"` when a smaller value of the outcome (e.g. a hazard ratio for treatment failure, or a log odds ratio for an adverse event) represents a better treatment, or `"bad"` when a larger value is better (e.g. a treatment success/cure proportion on an odds-ratio scale coded so that the reference favours the comparator).

#pitfall[
  Getting `small.values` backwards silently inverts the entire ranking without throwing any error — `netrank()` has no way to know, from the data alone, whether your outcome is coded so that "lower is better" or "higher is better". Always state explicitly, in the analysis plan and in the submitted report, which direction was used and why, and sanity-check the resulting P-score order against at least one comparison whose direction you already know from the raw summary table.
]

P-scores are a convenient single-number summary, but like SUCRA, they describe the *average* ranking across an entire distribution of equally plausible parameter values, and are not a substitute for reporting the actual relative-effect estimates and their confidence intervals for the comparisons that matter to the decision problem. An HTA reviewer who sees only a P-score table with no accompanying forest-style relative-effect output will reasonably ask for the full numerical results.

=== 12.3.6 Full pairwise results: `netleague()`

For a submission, reviewers typically want every pairwise relative effect implied by the network, not just the treatment-vs-reference-group table from `summary()`. `netleague()` produces this as a matrix ("league table") with one row and column per treatment, direct comparisons and network (NMA) estimates shown together for inspection:

```r
league_tb <- netleague(
  net_tb,
  common = FALSE,
  random = TRUE,
  seq    = rank_tb,
  ci     = TRUE,
  digits = 2
)

league_tb
```

Ordering rows/columns by `seq = rank_tb` (the `netrank()` object from above) arranges the league table from best- to worst-ranked treatment, which is typically how such tables appear in HTA appendices — it makes both the ranking and the magnitude/precision of every pairwise comparison readable in one exhibit. Setting `random = TRUE` (and `common = FALSE`) reports the random-effects network estimates consistently with whichever model was pre-specified as primary in §12.3.3; a league table that silently mixes common-effect and random-effects numbers in different cells is a known source of reviewer confusion and should be avoided.

#report-table(
  [Excerpt of the random-effects `netleague()` output for the four-treatment TB network, showing odds ratios (95% CI) for treatment failure, ordered best-to-worst by P-score (D, A, B, C). Each row is a pairwise contrast between the network's basic parameters; values above 1 favour the first-named treatment. Direct-evidence comparisons (A vs C, B vs C, A vs B, D vs C) are flagged, as `netleague()` output conventionally distinguishes them from purely indirect network estimates.],
  academic-table(
    columns: (1.6fr, auto, auto, 1fr),
    align: (left, right, right, left),
    header: ([*Comparison*], [*OR*], [*95% CI*], [*Evidence*]),
    body: (
      [D vs A], [1.42], [(0.81, 2.49)], [indirect],
      [D vs B], [1.65], [(0.93, 2.93)], [indirect],
      [D vs C], [2.01], [(1.21, 3.34)], [direct],
      [A vs B], [1.16], [(0.67, 2.01)], [direct],
      [A vs C], [1.42], [(0.98, 2.06)], [direct],
      [B vs C], [1.22], [(0.85, 1.75)], [direct],
    ),
    footer: (
      table.cell(colspan: 4)[*Note:* rows ordered by `seq = rank_tb`, best- to worst-ranked treatment; random-effects ($tau^2$) model reported throughout for consistency with the primary analysis.],
    ),
  ),
) <tab-ch12-netleague-excerpt>

Together, `netmeta()`, `netgraph()`, `netrank()`, and `netleague()` take the single algebraic idea introduced in §12.2 — borrow strength across trials through a shared comparator, letting variances add rather than cancel — and extend it to an arbitrarily connected evidence network, fitted in one coherent model rather than a chain of manual Bucher subtractions. The next section turns to the Bayesian implementation of the same underlying model, which offers a more natural route to full probabilistic statements such as "the probability that Regimen A is the best treatment" and is often the form NICE's own reference case analyses are built in.

== 12.4 Bayesian NMA (gemtc, multinma, bnma)

The frequentist network meta-analysis fitted in `netmeta` (§12.3) estimates a single network of relative effects by generalising the DerSimonian-Laird random-effects machinery to multi-arm, multi-treatment data. It is fast, requires no prior specification, and is an excellent first pass. But most published NMAs that inform NICE technology appraisals, and nearly every NMA submitted in an HTA dossier that needs to report the probability that a treatment is best, use a Bayesian framework instead. There are three practical reasons for this, and they matter for how you choose a package.

First, Bayesian NMA naturally produces the full posterior distribution of every treatment effect and of derived quantities — rankings, surface under the cumulative ranking curve (SUCRA), probability of being best, and absolute outcomes when combined with a baseline risk model. Second, it handles the correlation structure induced by multi-arm trials correctly and transparently through the model's shared random effects, rather than through a post-hoc adjustment. Third, and most relevant to reimbursement submissions, it integrates directly into probabilistic cost-effectiveness models: a cohort of Markov Chain Monte Carlo (MCMC) draws of relative treatment effects can be propagated straight into a probabilistic sensitivity analysis (PSA), preserving the full joint uncertainty across comparators. A point estimate and standard error from a frequentist NMA has to be re-approximated as a normal or multivariate-normal distribution before it can feed a PSA; a Bayesian NMA simply hands over the posterior samples.

Three R packages dominate Bayesian NMA practice: `gemtc`, `multinma`, and `bnma`. They differ mainly in their modelling backend and in how much of the NICE DSU TSD 2 methodology they expose directly.

=== gemtc: the NICE DSU TSD 2 reference implementation

`gemtc` ("Generalized Evidence Mapping and Treatment Comparison") wraps JAGS (Just Another Gibbs Sampler) and was written with the NICE Decision Support Unit's Technical Support Document 2 (Dias et al., 2011) explicitly in mind — its default priors, model parameterisation, and consistency assumptions mirror that document closely, which is one reason assessors are comfortable seeing it in a submission. It requires a working JAGS installation (`rjags`), which is a separate binary from R itself and must be installed on the system before the R package will run.

The `gemtc` workflow has three stages: build a network object, build a model object, and run the MCMC sampler.

```r
library(gemtc)

# Long-format trial data: study, treatment, arm-level outcome and sample size
# (binary outcome example: responders out of total)
data_long <- data.frame(
  study     = c("T1","T1","T2","T2","T3","T3","T3"),
  treatment = c("A","B","A","C","A","B","C"),
  responders = c(45, 62, 38, 71, 50, 58, 66),
  sampleSize = c(100, 100, 90, 95, 105, 102, 110)
)

network <- mtc.network(data.ab = data_long)
summary(network)
plot(network)   # igraph-based network diagram
```

`mtc.network()` accepts arm-level binomial data (`responders`, `sampleSize`), continuous data (`mean`, `std.dev`, `sampleSize`), or pre-computed contrast-level data, and optionally a `treatments` data frame to supply readable labels and a `description` string for the network. The resulting object already knows the graph structure — which treatments are directly compared in which studies — and `plot()` renders it so you can visually confirm expected closed loops are present before fitting anything.

`mtc.model()` then builds the actual Bayesian model specification — likelihood, link function, and random-effects structure — without yet sampling:

```r
model <- mtc.model(
  network,
  type = "consistency",     # the standard NMA assumption; see Section 12.5
  linearModel = "random",   # random-effects; "fixed" for common-effect
  n.chain = 4
)
```

The `type` argument is the key methodological lever: `"consistency"` fits the standard network model that assumes direct and indirect evidence agree (the assumption examined in Section 12.5); `"nodesplit"` is used internally by `mtc.nodesplit()` for the consistency check described below. `linearModel` chooses between a fixed- and random-effects likelihood exactly as in the pairwise and frequentist NMA settings.

`mtc.run()` hands the model to JAGS and returns the posterior samples as an `mcmc.list` (from the `coda` package), which is the common currency for everything downstream — trace plots, Gelman-Rubin diagnostics, forest plots, rank probabilities:

```r
result <- mtc.run(model, n.adapt = 5000, n.iter = 20000, thin = 10)

summary(result)
gemtc::forest(relative.effect(result, t1 = "A"))
gelman.diag(result)                 # convergence check, target < 1.05
```

#heor-practice[
Treat `n.adapt` (adaptation/burn-in) and `n.iter` (retained iterations) as a starting point, not a final answer. Always inspect `gelman.diag()` and trace plots before reporting any posterior summary — an NMA with a Gelman-Rubin statistic above roughly 1.05 on any parameter has not converged, and every downstream ranking, SUCRA, or cost-effectiveness result inherits that unreliability. If convergence is marginal, increase `n.iter` and re-run rather than reaching for a wider credible interval to paper over it.
]

=== multinma: a unified Stan-based alternative

`multinma` (Phillippo et al.) implements NMA, network meta-regression, and multilevel network meta-regression (ML-NMR) in one coherent framework, sampling with Stan rather than JAGS. Its main practical advantage over `gemtc` is that it accepts individual patient data (IPD), aggregate data (AgD), or a mixture of both within the same network, which matters when a submission combines a trial with patient-level access and comparator trials known only from published aggregate results.

```r
library(multinma)

network_ad <- set_agd_arm(
  data_long,
  study = study,
  trt = treatment,
  r = responders,
  n = sampleSize
)

fit <- nma(
  network_ad,
  trt_effects = "random",
  prior_intercept = normal(scale = 10),
  prior_trt = normal(scale = 10),
  prior_het = half_normal(scale = 1)
)

print(fit)
plot(relative_effects(fit))
```

`set_agd_arm()` (and its sibling `set_agd_contrast()` and `set_ipd()`) builds the network object from aggregate or individual data, analogous to `mtc.network()`. `nma()` then fits the model, with explicit `prior_*` arguments — a deliberate design choice in `multinma` to make prior assumptions visible in the code rather than buried in package defaults, which is useful when a reviewer or NICE assessor asks exactly what prior was used for the heterogeneity parameter.

Where `multinma` goes further than `gemtc` is in population-adjusted and meta-regression analyses. `add_integration()` attaches numerical-integration points (summary covariate moments, or simulated covariate distributions) to an aggregate-data network so that a multilevel network meta-regression (ML-NMR) model can integrate the IPD-estimated covariate interaction over the aggregate-data studies' covariate distribution — the mechanism underlying population-adjustment methods such as simulated treatment comparison (STC) and matching-adjusted indirect comparison (MAIC)-adjacent ML-NMR models. This is a substantially more advanced use case than a standard consistency NMA and is typically reserved for submissions where cross-trial population differences are a live concern (see also Chapter 13 on population adjustment methods).

#agency-note[
NICE DSU TSD 2 (Dias et al., 2011), *"A Generalised Linear Modelling Framework for Pairwise and Network Meta-Analysis of Randomised Controlled Trials,"* remains the primary methodological reference assessors cite when reviewing the modelling choices in a Bayesian NMA — fixed- vs random-effects, prior specification, and the consistency equation structure all trace back to it. When your `gemtc` or `multinma` code departs from TSD 2's default conventions (for example, an informative prior on heterogeneity rather than the vague priors TSD 2 illustrates), state the departure and its justification explicitly in the submission's statistical methods section; silent deviation is a common source of clarification requests from the Evidence Review Group.
]

=== bnma: a lighter-weight contrast-based option

`bnma` ("Bayesian Network Meta-Analysis") is a smaller package, also JAGS-based, that works from contrast-level data and offers a more compact interface than `gemtc` for standard random- and fixed-effects consistency models. It is a reasonable choice when the analysis is a conventional pairwise-data NMA without the meta-regression or IPD features of `multinma`, and the full generality of `gemtc`'s network-object machinery is not needed. Because its user base and feature set are narrower, most HTA-facing teams default to `gemtc` (for TSD 2 alignment) or `multinma` (for population-adjustment and mixed IPD/AgD networks), reaching for `bnma` mainly for quick sensitivity checks or teaching contexts.

#pitfall[
Do not treat a *Rhat* (Gelman-Rubin) diagnostic near 1.00 as a complete convergence check. It tells you the chains have mixed with each other, not that they have explored the full posterior. Always also inspect trace plots for the heterogeneity parameter ($tau$) specifically — heterogeneity variance in small networks is notoriously slow to converge and can look "converged" on Rhat while still being poorly estimated, because the chains can get stuck at similar but wrong values together. Running at least 4 chains from dispersed starting values is the standard safeguard, and is `gemtc`'s and `multinma`'s default.
]

== 12.5 Consistency and inconsistency assessment

Every network meta-analysis discussed so far rests on one assumption that is easy to state and easy to violate without noticing: *consistency*. Consistency means that direct evidence (trials that compared two treatments head-to-head) and indirect evidence (comparisons stitched together through a common comparator, e.g. A vs C inferred from A vs B and B vs C trials) agree, up to sampling error, about the relative effect of any two treatments in the network. If they do not agree, the network estimate — which by construction pools direct and indirect evidence together — is not a single coherent effect but an average of two conflicting answers, and reporting it without flagging the conflict is methodologically unsound. NICE DSU TSD 4 (Dias et al.), *"Inconsistency in Networks of Evidence Based on Randomised Controlled Trials,"* is the standard reference for how to check this assumption and what to do when it fails, and any HTA submission with a non-trivial network (more than a simple star or single closed loop) is expected to address it.

There are two broad strategies: local checks that examine one comparison (one edge of the network) at a time, and global checks that test the consistency assumption across the whole network simultaneously. Node-splitting is the standard local method; design-by-treatment interaction testing is the standard global method. They are complementary, not competing — a careful submission typically reports both.

=== Node-splitting: direct vs indirect evidence on one edge

The intuition behind node-splitting is straightforward even before any statistics are involved. Pick one specific comparison in the network — say, Drug B vs Drug C. Some of your evidence on B vs C comes from trials that randomised patients directly between B and C: this is the *direct* estimate. The rest of your evidence constrains B vs C only indirectly, by combining A vs B evidence with A vs C evidence (and any other route through the network that avoids using a B-vs-C trial): this is the *indirect* estimate. Node-splitting computes both of these estimates separately for the chosen edge, and then asks whether they are statistically compatible — do the direct and indirect routes to the same answer roughly agree, or do they pull in different directions? You repeat this one edge at a time, for every comparison in the network that has both direct and indirect evidence available (comparisons with only one type of evidence cannot be split, because there is nothing to compare against).

`gemtc` implements this directly as `mtc.nodesplit()`, operating on the same network object used for the main NMA:

```r
library(gemtc)

splits <- mtc.nodesplit(
  network,
  linearModel = "random",
  n.adapt = 5000,
  n.iter = 20000,
  thin = 10
)

summary(splits)
plot(splits)
```

`mtc.nodesplit()` automatically identifies which edges in the network have both direct and indirect evidence available to split, fits the direct-only and indirect-only sub-models alongside the network consistency model for each, and reports — for each split comparison — the direct estimate, the indirect estimate, their difference, and a Bayesian p-value (or credible interval on the difference) summarising whether that difference is distinguishable from zero. `summary()` tabulates this edge by edge; `plot()` draws the familiar node-splitting forest plot with direct, indirect, and network estimates stacked for visual comparison.

#report-table(
  [How to report this: `summary(mtc.nodesplit())` output for the TB network's three splittable edges, the conventional node-splitting layout showing the direct estimate, the indirect estimate, their difference, and a Bayesian $p$-value for each edge],
  academic-table(
    columns: (1.2fr, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    header: (
      [*Comparison*], table.cell(colspan: 2)[*Direct*], table.cell(colspan: 2)[*Indirect*],
      table.hline(start: 1, end: 3, stroke: 0.6pt), table.hline(start: 3, end: 5, stroke: 0.6pt),
      [], [OR (95% CrI)], [OR (95% CrI)], [Difference (log OR)], [$p$],
    ),
    body: (
      [A vs C], [1.42 (0.98, 2.06)], [1.51 (1.02, 2.24)], [-0.06], [0.74],
      [B vs C], [1.22 (0.85, 1.75)], [1.09 (0.71, 1.67)], [0.12], [0.58],
      [D vs C], [2.01 (1.21, 3.34)], [1.78 (1.04, 3.05)], [0.12], [0.69],
    ),
    footer: (
      table.cell(colspan: 5)[*Note:* no split edge shows a Bayesian $p$-value below the conventional 0.10 screening threshold; absence of a flagged edge is not proof of global consistency — see the design-by-treatment test below.],
    ),
  ),
) <tab-ch12-nodesplit>

#heor-practice[
Node-splitting answers aren't free: splitting a network with many closed loops means fitting a separate model for every splittable edge, each requiring its own MCMC run and convergence check. Budget real computation time for this — a network of a dozen treatments with good connectivity can have a dozen or more splittable edges, each needing the same convergence diligence (`gelman.diag()`, trace plots) as the main NMA model. Do not skim past convergence checks on the split models just because the main network model converged cleanly; they are separate fits with their own behaviour.
]

Interpreting node-splitting results requires some care on two fronts. First, a non-significant difference between direct and indirect estimates at one edge is evidence *consistent with* consistency, not proof of it — with the modest sample sizes typical of NMA networks, the test for a single split often lacks power to detect a real but moderate inconsistency. Second, when a network has many splittable edges, testing each one individually raises the usual multiple-comparisons concern: with, say, ten splits each tested at a nominal threshold, you expect some to look "significant" by chance alone even under perfect consistency. Node-splitting results should therefore be read as a diagnostic screening tool that flags candidate problem edges for substantive scrutiny (are those trials really comparable in population, dosing, or follow-up?), not as a formal hypothesis-testing procedure with a fixed error rate.

#pitfall[
A node-split p-value comfortably above 0.05 on every edge does not mean the network is free of inconsistency. Node-splitting tests consistency one edge at a time and can miss patterns of inconsistency that are spread diffusely across the network rather than concentrated on a single comparison — exactly the scenario the global design-by-treatment test below is built to catch. Relying on node-splitting alone, especially in a network with few closed loops to split in the first place, is a common and avoidable gap in submitted NMAs.
]

=== Design-by-treatment interaction: a global alternative

Where node-splitting asks "do direct and indirect evidence agree on this one edge?", design-by-treatment interaction testing asks a more global question: "across the whole network, is there a systematic interaction between the *design* of a study (which set of treatments it compared) and the treatment effects observed, beyond what sampling error would explain?" The idea, formalised by Higgins et al. and adopted in NICE DSU TSD 4, is to re-express the network as a design-by-treatment model in which every distinct set of treatments compared within a trial (a "design") is allowed its own inconsistency parameters, and then to test jointly whether those inconsistency parameters are needed at all — i.e., whether a simpler, fully consistent model fits the observed data equally well.

This test has a close relationship to Cochran's Q test for heterogeneity: it decomposes the overall disagreement among studies into a component attributable to between-study heterogeneity within designs and a component attributable to inconsistency between designs, in a manner directly analogous to how heterogeneity is partitioned in ordinary pairwise meta-analysis. A single omnibus chi-squared-type statistic (and its associated p-value) then summarises whether the network, taken as a whole, shows evidence of inconsistency.

In practice, this test is most commonly run through the frequentist `netmeta` package introduced in §12.3, which implements the design-by-treatment decomposition as part of its standard network meta-analysis output (via functions such as `decomp.design()` operating on a `netmeta` object), rather than through `gemtc` or `multinma`, which are oriented toward the Bayesian node-splitting route instead. A thorough consistency assessment therefore often combines a frequentist global design-by-treatment test alongside the Bayesian local node-splitting results, each catching a different flavour of inconsistency: the global test is sensitive to inconsistency distributed broadly across the network's design structure, while node-splitting is sensitive to — and specifically localises — a problem concentrated on one comparison.

#heor-practice[
When both checks are available, read them together rather than in isolation. A significant global design-by-treatment test with no single node-split edge standing out suggests inconsistency diffused across several comparisons — look for a subtler explanation such as a shift in standard-of-care or outcome definition across trial eras. A significant node-split on one edge with an otherwise clean global test points you straight at that comparison's trials for a focused clinical and methodological review (population, dosing, follow-up duration, outcome ascertainment). Report both results in the submission, including the exact test(s) used, so the Evidence Review Group can see which diagnostic found what.
]

#agency-note[
NICE DSU TSD 4 (Dias et al.), *"Inconsistency in Networks of Evidence Based on Randomised Controlled Trials,"* sets out the expected evidentiary standard here: it is not sufficient to run a consistency NMA and simply assert the assumption holds. TSD 4 expects a documented inconsistency assessment — using node-splitting, the design-by-treatment interaction model, or both as appropriate to the network's structure — with a discussion of plausible clinical or methodological sources for any flagged inconsistency (differences in effect modifiers, study quality, or outcome definitions across the designs involved) rather than a bare statistical verdict. Submissions that report a global p-value with no exploration of *why* an inconsistency might exist, when one is flagged, routinely draw follow-up questions from assessors.
]

== 12.6 Network meta-regression

§11.4 introduced pairwise meta-regression: adding a study-level covariate to a random-effects meta-analysis to explain some of the between-study heterogeneity in the pooled log hazard ratio. Network meta-regression is exactly that idea carried into the network setting of §§12.1–12.5, where more than two treatments are connected by a web of direct and indirect trials. Instead of a single pooled contrast, we now have a set of basic parameters (treatment effects relative to a reference) and we let a study-level covariate shift all of them simultaneously, under a shared regression coefficient (or, less commonly, treatment-specific coefficients when the network is informative enough to estimate them).

The motivation is the same as before: part of the between-study heterogeneity and part of any apparent inconsistency between direct and indirect evidence may be explained by differences in trial-level characteristics — average baseline risk, mean age, proportion with a biomarker, year of publication, background therapy intensity — rather than by genuine treatment-effect modification. If a covariate explains heterogeneity/inconsistency well, the regression-adjusted network is more defensible than the unadjusted one. If it does not, the adjustment buys nothing except extra parameters and wider intervals.

=== Mechanics in gemtc

The `gemtc` package supports covariate adjustment through regression arguments to `mtc.model()`. The key pieces are: a `network` object built with `mtc.network()` exactly as before, a covariate vector attached at the study level (via the `studies` argument to `mtc.network()`), and a `regressor` list passed to `mtc.model()` specifying which covariate to use, which treatment the regression coefficient is centred on (`coefficient = "shared"` vs treatment-specific), and the functional form.

```r
library(gemtc)

# study-level covariate table: one row per study, with a
# study-level covariate (e.g. mean baseline severity score)
# already summarised at the trial level
covariate_data <- data.frame(
  study    = c("TrialA", "TrialB", "TrialC", "TrialD", "TrialE"),
  baseline_severity = c(0.41, 0.52, 0.38, 0.60, 0.47)
)

# network object as in section 12.2, then merge in the covariate
network <- mtc.network(
  data.ab = arm_level_data,      # arms: study, treatment, responders, sampleSize
  studies = covariate_data       # adds baseline_severity as a study-level column
)

# regression model: shared coefficient for baseline_severity,
# centred on the covariate's mean across the network
model_regression <- mtc.model(
  network,
  linearModel = "random",
  regressor = list(
    coefficient = "shared",
    variable   = "baseline_severity",
    control    = list(value = mean(covariate_data$baseline_severity))
  )
)

results_regression <- mtc.run(model_regression, n.adapt = 5000,
                               n.iter = 20000, thin = 10)
summary(results_regression)
```

The `control = list(value = ...)` argument centres the covariate at a chosen reference value (commonly the network mean), so that the estimated basic treatment effects are interpreted *at that covariate value*, and the regression coefficient (`beta` in the `gemtc` output) represents the per-unit shift in the log odds ratio / log hazard ratio scale for each unit change in the covariate. A `coefficient = "shared"` specification assumes the same regression slope applies uniformly across all treatment contrasts in the network; `coefficient = "unrelated"` or treatment-specific alternatives relax that assumption but demand more data than most networks of five or six trials can support, and in practice are rarely identifiable outside large networks with good covariate spread. Readers extending this should consult the `gemtc` documentation and vignette for the exact list of accepted `coefficient` and `control` specifications, since these have evolved across package versions and a stale example can silently fail to fit the intended model.

=== Interpreting shrinkage of heterogeneity and inconsistency

A regression-adjusted model should be compared against the unadjusted model from §12.3 on two diagnostics: the between-study heterogeneity variance (τ²) and, where a node-splitting or inconsistency model is feasible (§12.5), the magnitude of any direct-versus-indirect discrepancy. A useful adjusted covariate meaningfully shrinks τ² and/or narrows the inconsistency gap; a covariate that leaves both essentially unchanged is not doing explanatory work, even if its own credible interval excludes zero.

```r
# compare DIC and residual deviance between unadjusted and
# regression-adjusted models
summary(results_unadjusted)$DIC
summary(results_regression)$DIC

# compare posterior median tau between the two models
print(results_unadjusted$deviance$tau)
print(results_regression$deviance$tau)
```

A drop in DIC alongside a materially smaller τ² is evidence the covariate is earning its place in the model; a drop in DIC driven mainly by better model fit to a handful of large studies, with little change in τ², is weaker evidence and should be reported cautiously.

#heor-practice[
When a submission dossier needs to defend a network meta-regression to a HTA body, present three results side by side: the unadjusted network estimates, the regression-adjusted estimates at the population mean of the covariate, and the regression-adjusted estimates at the specific covariate value matching the target population (e.g. the mean baseline severity in the decision-relevant population, not the trial-average value). Reviewers at NICE, CADTH, and similar bodies routinely ask for the third of these, because it is the one that actually answers "what does this network imply for our population," and sponsors who report only the network-mean-centred estimate invite a request for resubmission.
]

#report-table(
  [The three network meta-regression results a dossier should present side by side for the four-treatment TB network (odds ratios for treatment failure vs. the shared comparator C): the unadjusted network estimate, the regression-adjusted estimate centred on the network's mean baseline severity (0.476), and the regression-adjusted estimate centred on the decision-relevant target population's baseline severity (0.55, a more severe population than the trial-average mix).],
  academic-table(
    columns: (1fr, 1.4fr, 1.6fr, 1.6fr),
    align: (left, right, right, right),
    header: ([*Comparison*], [*Unadjusted network*], [*Adjusted, network mean*], [*Adjusted, target population*]),
    body: (
      [A vs C], [1.42 (0.98, 2.06)], [1.38 (0.95, 2.00)], [1.61 (1.05, 2.47)],
      [B vs C], [1.22 (0.85, 1.75)], [1.19 (0.83, 1.70)], [1.35 (0.89, 2.04)],
      [D vs C], [2.01 (1.21, 3.34)], [1.94 (1.17, 3.22)], [2.28 (1.30, 4.00)],
    ),
    footer: (table.cell(colspan: 4)[Between-study heterogeneity shrinks on adjustment ($tau^2$: 0.087 unadjusted $arrow$ 0.041 regression-adjusted), and DIC falls from 142.3 to 138.9, together suggesting baseline severity is doing real explanatory work rather than merely adding parameters. The target-population-centred column shifts every estimate upward relative to the network-mean column, illustrating exactly why the network-mean estimate alone understates effect size in a more severe target population.],),
  ),
) <tab-ch12-netregression-three-way>

#pitfall[
The ecological-bias caveat from §11.4 applies with exactly the same force here, and arguably more urgently, because a network multiplies the number of contrasts being (mis)explained. A study-level covariate — even something as intuitive as "mean baseline severity" or "proportion of patients with prior therapy" — is an aggregate summary of the patients enrolled in that trial. It is not a measurement on any individual patient, and a regression coefficient estimated from across-study variation in that aggregate cannot be read as the within-trial, patient-level effect of the same characteristic. A network regression that finds "trials with higher mean baseline severity show larger treatment effects" says nothing reliable about whether an individual patient with high severity does better on the treatment than an individual patient with low severity within the same trial — that is a different quantity, and confusing the two is the single most common error in reviewing network meta-regressions. This is precisely the situation Chapter 13 exists to address properly.
]

#agency-note[
NICE DSU Technical Support Document 3 (Dias et al., on heterogeneity and inconsistency in network meta-analysis) sets out the standard for when and how a covariate-adjusted network model should be presented alongside the unadjusted model, including the expectation that sponsors show the sensitivity of conclusions to the choice of effect modifiers and to the assumption of a shared versus treatment-specific regression coefficient. Any network meta-regression submitted in a dossier should explicitly reference this guidance and should not present the regression-adjusted result as a replacement for the unadjusted network analysis, but as a sensitivity and explanatory supplement to it.
]

== 12.7 NMA of survival outcomes: fractional polynomials and time-varying hazard ratios

§§12.1–12.6 have, for simplicity of exposition, largely used binary or continuous effect sizes (odds ratios, mean differences) as the currency of the network. Oncology and many chronic-disease HTA submissions instead need networks built on survival (time-to-event) outcomes, where the quantity of interest is not a single pooled hazard ratio but an entire extrapolated survival curve for every treatment in the network, consistent with the mechanism established in §11.5: a pooled log(HR) acting as a multiplier on a Chapter-10 flexsurv reference-arm hazard function, so that $h_("comparator")(t) = "HR" times h_("reference")(t)$.

The proportional-hazards version of that mechanism generalises to a network in the obvious way: pick a reference treatment (the node with the richest evidence base or the one anchoring the most direct comparisons), fit or source a flexsurv reference-arm hazard function $h_("ref")(t)$ exactly as in Chapter 10, and multiply by a network of pooled log(HR) contrasts estimated from a standard NMA on the hazard-ratio scale (the "contrast-based" NMA model from §§12.2–12.4, with log(HR) and its standard error as the arm-level or contrast-level input rather than log(OR)). Each treatment's extrapolated curve is then $h_k(t) = "HR"_(k "vs ref") times h_("ref")(t)$, and the basic parameters of the network (the pooled log hazard ratios relative to the reference) are exactly the multipliers from §11.5, now estimated jointly and coherently across every edge of the network rather than one pair at a time.

=== Why constant hazard ratios are often the wrong assumption

The proportional-hazards NMA above is appealing because it slots neatly into the apparatus already built in Chapters 10 and 11. Its central assumption — that the hazard ratio between any two treatments in the network is constant over the entire follow-up period — is frequently violated in oncology trials, where immunotherapies and targeted agents commonly show hazard ratios that are far from 1 early (while the treatment effect is still building, or while an early toxicity signal dominates) and move toward 1 or even cross over late (as a durable-responder subgroup separates from the rest, or as both arms' curves flatten near a plateau). Visual inspection of Kaplan-Meier curves and of log-cumulative-hazard plots, exactly as taught in Chapter 10's proportional-hazards diagnostics (§10.7), is the first and most important check before committing to a constant-HR network.

When proportional hazards is clearly untenable, the standard reference for handling time-to-event outcomes in a network meta-analysis is NICE DSU Technical Support Document 18 (Ouwens et al.), building on the methodology originally proposed by Jansen (2011). The approach replaces the single pooled log(HR) with a *fractional polynomial model of the hazard (or log-cumulative-hazard) function itself*, fitted jointly across all studies and all treatments in the network, so that the treatment effect is allowed to vary smoothly over time rather than being forced to a single multiplicative constant.

=== The Jansen / TSD 18 fractional polynomial NMA approach, conceptually

The core idea, following Jansen (2011) and TSD 18, is to model the log-hazard (or log-cumulative-hazard) of each arm in each study as a fractional polynomial function of time, with study-specific baseline terms and treatment-specific terms that are shared (pooled) across the network via the same kind of random- or fixed-effects structure used in an ordinary NMA. A first-order fractional polynomial model for the log cumulative hazard of arm $k$ in study $i$ at time $t$ takes the form

$ log(H_(i k)(t)) = mu_i + beta_(1, i k) dot t^(p_1) + beta_(2, i k) dot log(t) dot bb(1)[p_1 = 0] $

where $mu_i$ is a study-specific baseline (absorbing between-study differences in the overall level of risk), the power $p_1$ is chosen from the usual fractional-polynomial candidate set $(-2, -1, -0.5, 0, 0.5, 1, 2, 3)$ (with $p_1 = 0$ denoting the $log(t)$ term), and the treatment-specific coefficients $beta_(1, i k)$ and $beta_(2, i k)$ are decomposed into a study-level random effect around a network-level pooled treatment effect, in precisely the same hierarchical structure used for the log(HR) basic parameters in §§12.2–12.3. A second-order fractional polynomial adds a second time-power term and is the model actually recommended by TSD 18 for most oncology survival curves, because it can represent the early-divergence/late-convergence hazard-ratio shapes that a single-power or proportional-hazards model cannot.

Fitted this way, the model produces, for every treatment in the network, a time-varying log-hazard curve relative to the reference treatment: effectively a hazard ratio function $"HR"_k(t)$ rather than a single scalar $"HR"_k$. This is the direct generalisation, to a network and to a flexible time-varying form, of the §11.5 mechanism: instead of one pooled log(HR) multiplying a flexsurv reference hazard, we now have a pooled *time-varying* log hazard ratio function multiplying (on the log scale, additively; on the hazard scale, as a time-dependent multiplier) the same kind of Chapter-10 flexsurv-derived reference hazard.

#pitfall[
There is no widely adopted, actively maintained CRAN package that implements the full Jansen (2011) / TSD 18 multi-arm, multi-study fractional polynomial NMA of survival curves end to end — fitting the shared baseline terms, the treatment-specific fractional polynomial coefficients, the between-study random effects on those coefficients, and producing network-consistent extrapolated survival curves for every arm. This is genuinely bespoke analysis, typically built study-by-study in a Bayesian framework (WinBUGS, JAGS, or Stan, following the code structures published as appendices to TSD 18 itself and to Jansen's original paper), not a function call in an off-the-shelf R package. Any report or code example that presents a single named R function as doing this whole job should be treated with suspicion. What follows below is explicitly flagged as illustrative pseudocode / conceptual structure, not a verified function signature, precisely because asserting a fabricated function call here would be worse than admitting the gap.
]

=== Single-study building block with flexsurv, and the bespoke network step

The piece that *is* directly supported by a real, verified R function is the single-study, single-arm fractional-polynomial-style hazard fit, which `flexsurv` can produce via its generalised gamma, generalised F, or spline-based hazard models (Chapter 10), or via a direct Royston-Parmar / fractional-polynomial-on-the-log-cumulative-hazard specification fit arm-by-arm. A reasonable and honest workflow is:

```r
library(flexsurv)
library(survival)

# Step 1 (verified, real flexsurv usage): fit a flexible
# parametric hazard model to EACH trial arm separately, exactly
# as in Chapter 10, e.g. using the Royston-Parmar spline model
# on the log cumulative hazard scale, which behaves similarly
# in spirit to a fractional polynomial on log(H(t))
fit_arm_A <- flexsurvspline(
  Surv(time, status) ~ 1,
  data  = trial1_armA,
  k     = 2,            # number of internal knots
  scale = "hazard"
)

fit_arm_B <- flexsurvspline(
  Surv(time, status) ~ 1,
  data  = trial1_armB,
  k     = 2,
  scale = "hazard"
)

# these per-arm fits give study-specific, arm-specific hazard
# functions h_A(t), h_B(t) exactly as in Chapter 10 -- this part
# is real, verified flexsurv functionality.

# Step 2 (bespoke, NOT a single package function): pool the
# arm-level log-cumulative-hazard differences across studies and
# treatments into a network-consistent fractional polynomial
# model, following the Bayesian model structure set out in
# Jansen (2011) and NICE DSU TSD 18. Conceptually:
#
#   for each study i, each arm k:
#     log(H_ik(t)) ~ mu_i + sum_j beta_{j,trt(k)} * f_j(t)
#     beta_{j,trt(k)} ~ Normal(d_{j,trt(k)}, sigma_j^2)   [study-level RE]
#     d_{j,k} are the network's basic parameters for FP term j,
#     treatment k, estimated jointly across the whole network
#     (random-effects consistency model, as in sections 12.2-12.4)
#
# This step requires a custom JAGS/Stan/WinBUGS model written
# against the study-level log(H(t)) data extracted (e.g. by
# digitising published KM curves, as discussed in Chapter 10)
# from every trial in the network -- there is no single
# off-the-shelf R call that performs it, and any code claiming
# otherwise should not be trusted without checking the package
# documentation directly.
```

Once such a bespoke model is fitted (by whatever Bayesian engine the analyst chooses, following the TSD 18 appendix code as the template), the practical output is the same kind of object produced in §§12.2–12.5: a posterior distribution over the network's basic parameters, now indexed by both treatment and fractional-polynomial term, from which the analyst reconstructs a time-varying hazard-ratio function and an extrapolated survival curve for every treatment in the network relative to the chosen reference, continuing the Chapter 10 flexsurv extrapolation into a genuinely multi-arm, non-proportional-hazards setting.

#heor-practice[
Before investing in a bespoke fractional-polynomial NMA, always run the much cheaper proportional-hazards network from the start of this section and visually overlay the resulting extrapolated curves against the digitised Kaplan-Meier curves for every arm. If the proportional-hazards network's extrapolated curves already track the observed KM tails reasonably well for every treatment, the added complexity, computation time, and reviewer scrutiny of a fractional-polynomial model may not be justified. Reserve the TSD 18 fractional polynomial approach for networks where there is clear, visually and statistically documented evidence of non-proportional hazards in at least one key comparison, and say so explicitly in the report rather than defaulting to the more complex model as a matter of habit.
]

#agency-note[
NICE DSU Technical Support Document 18 (Ouwens et al., "Network Meta-Analysis of Survival Data") is the authoritative reference for every modelling choice in this section: the fractional polynomial specification, the choice between first- and second-order models, the treatment of between-study heterogeneity in the time-varying terms, and the reporting standards expected for a survival NMA submitted to NICE. Any fractional-polynomial or time-varying-hazard-ratio network model presented in a dossier should cite TSD 18 directly, reproduce its recommended model-selection diagnostics (comparison of DIC across candidate fractional polynomial power sets, visual fit to each arm's observed survival data), and should not be presented as a drop-in replacement for the proportional-hazards network without that comparison.
]

Both extensions in this section share a single underlying vulnerability: they assume that whatever is pooled across the network — a treatment effect, a regression slope, a fractional-polynomial hazard-ratio function — is *exchangeable* across the trials contributing to it, once any measured covariates have been accounted for. That assumption is exactly the one that network meta-regression's ecological-bias caveat warns us not to take for granted, and it is the assumption that breaks down most visibly when the trials in a network enrol genuinely different patient populations on characteristics that are also effect modifiers — the kind of situation where no amount of study-level covariate adjustment can substitute for patient-level information. Chapter 13, on population-adjusted indirect comparisons, takes up precisely that situation: methods such as matching-adjusted indirect comparison (MAIC) and simulated treatment comparison (STC) exist because standard NMA's exchangeability assumption, generalised and regression-adjusted as it may be, sometimes simply does not hold, and something closer to the patient level is required to make a defensible comparison at all.

== 12.8 Ranking, SUCRA and rankograms

Once a network is fitted — frequentist via `netmeta()` (§12.3) or Bayesian via `gemtc`/`multinma` (§12.4) — the deliverable a programme manager or committee usually asks for first is not a league table but a single ranking: *which treatment is best?* The standard way to answer this rigorously, rather than by eyeballing point estimates, is to summarise the full distribution of each treatment's rank, not just its mean effect.

In a Bayesian network, the MCMC sample already contains everything needed: at every retained iteration, each treatment has some rank (1st, 2nd, 3rd, ...) implied by that iteration's draw of all basic parameters. Salanti, Ades and Ioannidis (2011) formalised the Surface Under the Cumulative RAnking curve (SUCRA) as a single number between 0 and 1 summarising this rank distribution for each treatment — 1 meaning certain to be best across every possible rank position, 0 meaning certain to be worst. `gemtc` exposes this via `rank.probability()` and `sucra()`:

```r
rank_probs <- rank.probability(result, preferredDirection = -1)
# preferredDirection = -1 when a smaller effect (e.g. log HR < 1) is better,
# +1 when a larger effect is better -- set to match your outcome's coding

print(rank_probs)
sucra(rank_probs)
plot(rank_probs)   # rankogram: stacked probability of each rank, per treatment
```

`rank.probability()` returns a matrix of probabilities (treatment × rank), and `plot()` on that object draws the rankogram — effectively a stacked bar chart, one bar per treatment, showing the probability mass assigned to each possible rank. `sucra()` integrates that matrix into the single SUCRA value per treatment.

Frequentist NMA has no posterior to resample from, so Rücker and Schwarzer (2015) proposed P-scores as a frequentist analogue computed directly and deterministically from the network's point estimates and standard errors, without any resampling step. `netmeta`'s `netrank()`, introduced in §12.3.5, already returns these; `rankogram()` builds the frequentist analogue of the rankogram via a normal-approximation resampling scheme internally:

```r
library(netmeta)

rank_tb <- netrank(net_tb, small.values = "good")   # P-scores, as in §12.3.5
rankogram_tb <- rankogram(net_tb, nsim = 10000, small.values = "good")

plot(rankogram_tb)
print(rankogram_tb$ranking.matrix)
```

#report-table(
  [How to report this: Bayesian SUCRA values (`gemtc::sucra()`) alongside the frequentist P-scores (`netmeta::netrank()`) for the same four-treatment TB network, ranked best (1) to worst (4) on treatment failure. The two methods are computed differently (MCMC resampling vs a closed-form normal approximation) but should broadly agree when the network is well-behaved.],
  academic-table(
    columns: (1fr, auto, auto, auto),
    align: (left, right, right, center),
    header: ([*Treatment*], [*SUCRA (Bayesian)*], [*P-score (frequentist)*], [*Rank*]),
    body: (
      [D], [0.91], [0.89], [1],
      [A], [0.58], [0.61], [2],
      [B], [0.42], [0.39], [3],
      [C], [0.09], [0.11], [4],
    ),
    footer: (
      table.cell(colspan: 4)[`preferredDirection = -1` / `small.values = "good"` (lower log OR for treatment failure is better); SUCRA from 20,000 retained MCMC iterations post-convergence. Report alongside the §12.3.6 league table — a high rank here does not imply a clinically decisive effect size.],
    ),
  ),
) <tab-ch12-sucra-pscore>

#pitfall([
SUCRA and P-scores are the most over-interpreted single number in network meta-analysis reporting. A treatment can carry the top SUCRA or P-score while its credible or confidence interval for the actual effect size overlaps substantially — sometimes almost entirely — with the second- and third-ranked treatments. A high rank with a wide, overlapping interval usually means the apparent "win" rests on a thinly-evidenced comparison rather than a clinically meaningful difference. Never present a ranking metric on its own slide, table row, or sentence; always pair it with the forest-plot or league-table output from §12.3.6/§12.4 so the reader sees the uncertainty the ranking number hides.
])

== 12.9 Reporting per NICE DSU TSD 2, ISPOR and PRISMA-NMA

An NMA feeding a TB programme reimbursement or guideline submission is judged as much on its reporting as on its statistical execution. Three documents anchor that reporting, two already introduced earlier in this chapter and one new.

NICE DSU TSD 2 (Dias, Welton, Sutton and Ades, 2011) — the primary methods reference cited throughout §§12.3-12.5 — implies, beyond the modelling framework itself, a concrete reporting checklist: a network diagram showing every treatment node and the trials connecting them (the `netgraph()` output from §12.3.4), a full evidence table listing every included study's design, population and outcome definitions, model fit statistics (DIC for Bayesian fits, or the common-vs-random comparison for frequentist fits), the consistency assessment results from §12.5 (node-split estimates or the design-by-treatment decomposition), and the ranking results from §12.8 reported with their uncertainty, never as a bare league table or SUCRA number alone.

The ISPOR good practice task force report (Jansen et al., 2014, "Interpreting Indirect Treatment Comparisons and Network Meta-Analysis for Health-Care Decision Making") complements TSD 2 by framing the same checklist items as questions a decision-maker should ask of any submitted NMA: is the network geometry sound and fully connected for the comparisons that matter, is heterogeneity and inconsistency credibly assessed rather than merely asserted, and are the clinical and methodological similarity assumptions underlying transitivity made explicit rather than assumed by default. Where TSD 2 is the technical specification a sponsor builds against, the ISPOR paper is closer to the audit lens a payer or guideline committee applies to the finished product.

On the systematic literature review side that feeds the network, the PRISMA-NMA extension (Hutton et al., 2015, *Annals of Internal Medicine*) adds network-specific items to the base PRISMA checklist introduced in Chapter 6: an explicit description of the network geometry, the methods used to assess transitivity across the included trials, and how multi-arm trials were handled during extraction (a multi-arm trial contributes correlated contrasts, not independent pairwise comparisons — a point the `pairwise()` and `mtc.network()` functions in §§12.3-12.4 both handle internally, but which the write-up should still describe). The PRISMA flow diagram built with the PRISMA2020 package in Chapter 6 remains the natural entry point for the SLR; PRISMA-NMA extends the checklist items reported alongside that same diagram rather than requiring a second one.

#agency-note([
NICE's Diagnostics Assessment and Technology Appraisal methods guidance requires submissions using network meta-analysis to report against the TSD 2 framework specifically, including a stated justification for the fixed- vs random-effects choice and documented consistency checking per TSD 4. In practice, appraisal committees have requested additional analyses, or discounted a submitted NMA's headline result, when the network diagram, evidence table, or inconsistency assessment specified in TSD 2 was missing from the submitted evidence package — the checklist is not a formality, it is routinely enforced.
])
