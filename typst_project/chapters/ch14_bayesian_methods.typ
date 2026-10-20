#import "../common.typ": *

= Chapter 14. Bayesian Methods for HEOR

Chapter 12 used Bayesian network meta-analysis (`gemtc`, `multinma`, `bnma`) and flagged a `gelman.diag()` convergence check as mandatory. It did not explain *why* that check matters, or what to do when it fails. That explanation was deliberately saved for here.

This chapter has two jobs. First, it builds the Bayesian framework from first principles — what a prior, a likelihood and a posterior actually are, and how to compute one. Second, it fulfils Chapter 12's promise: full MCMC diagnostics, done properly. Along the way it reaches the chapter's single most useful idea for everyday modelling work: a Bayesian posterior sample can be used *directly* as a PSA sample, with no extra distribution-fitting step in between.

The chapter follows a simple arc, section by section:

- §14.1-14.2 build the concepts: what Bayesian updating is, and how to choose a prior.
- §14.3 introduces the three tools that turn those concepts into actual posterior draws: Stan, JAGS, and `brms`.
- §14.4 is the diagnostics discipline — the part Chapter 12 deferred.
- §14.5-14.6 connect evidence synthesis to decision-making: turning posterior draws into PSA input.
- §14.7 covers expert elicitation (SHELF), for when there is no data at all.
- §14.8 closes with a roadmap tying every piece together, and pointing forward to Part IV.

#learning-objectives((
  [Explain the prior/likelihood/posterior relationship and contrast a Bayesian credible interval's interpretation with a frequentist confidence interval's interpretation],
  [Choose between informative, weakly informative and vague priors for a given parameter, and justify the choice with a documented rationale and a prior sensitivity check],
  [Fit a simple Bayesian model using `rstan`, `rjags`, and `brms`, and explain when each tool is the natural choice],
  [Explain Metropolis-Hastings, Hamiltonian Monte Carlo and the No-U-Turn Sampler at a conceptual level sufficient to interpret why some models converge faster than others],
  [Check MCMC convergence using the Gelman-Rubin statistic (R-hat), assess effective sample size, and run a posterior predictive check before trusting any posterior summary],
  [Describe Bayesian evidence synthesis as a pipeline that produces a joint posterior sample, building on Chapter 12's Bayesian NMA machinery without re-deriving it],
  [Use posterior draws directly as a PSA sample for a cost-effectiveness decision model, preserving parameter correlation structure without fitting an intermediate distribution],
  [Describe the Sheffield Elicitation Framework (SHELF) process for eliciting a parameter's distribution from expert judgement when no usable data exist, and use the `SHELF` R package to fit and inspect the resulting distribution],
  [Trace the end-to-end Bayesian HEOR workflow from prior specification through evidence synthesis, MCMC fitting, diagnostics and PSA to reporting, and locate where it hands off to Part IV's uncertainty (Ch.25) and value-of-information (Ch.26) chapters],
))

== 14.1 Bayesian thinking for decision makers

Every health economic model you have built so far in this book has used probability in a particular way. A transition probability, a hazard ratio, a utility weight — each has been treated as a fixed, if uncertain, number, and you have expressed that uncertainty by attaching a distribution to it and running probabilistic sensitivity analysis. That workflow already contains a Bayesian idea, even if nobody called it that: a distribution over a parameter represents what you believe about a quantity you cannot observe directly. This section makes that idea explicit and gives it a name, because from here through the rest of the book — cost-effectiveness model parameterisation, value of information, adaptive trial designs — Bayesian reasoning is the natural language for decisions made under uncertainty.

Start with three ingredients.

A _prior_, $pi(theta)$, is what you believe about a parameter $theta$ before looking at today's data. It might come from an earlier trial, an expert elicitation exercise, or simply a wide, non-committal range.

A _likelihood_, $L(theta | y)$, is how probable the data $y$ you actually observed would be, for each possible value of $theta$. This is the same likelihood function behind your maximum-likelihood fits from earlier chapters.

Combine the two with Bayes' theorem and you get the _posterior_, $p(theta | y)$ — your updated belief about $theta$, after seeing the data:

$ p(theta | y) = frac(L(y | theta) pi(theta), integral L(y | theta) pi(theta) dif theta) $

The denominator just rescales things so the posterior integrates to one. The relationship you actually use day to day is much simpler:

$ "posterior" prop "likelihood" times "prior" $

Everything in this chapter is an exercise in computing or approximating that product. Picture a tug-of-war: the likelihood pulls toward what the current data say; the prior pulls toward what was already believed; and the strength of each pull depends on how much information each one carries. A small pilot study of 20 patients has a weak, spread-out likelihood — a well-chosen prior can meaningfully sharpen the estimate. A large national surveillance dataset has a sharp likelihood that will dominate almost any reasonable prior.

Contrast this with the frequentist framing you have used for most of this book. A frequentist 95% confidence interval is a statement about the long-run behaviour of an estimation _procedure_: if you repeated the same sampling process many times, 95% of the intervals you construct would contain the true parameter. It is not a statement of 95% probability about the parameter itself, no matter how often it is informally described that way. A Bayesian 95% credible interval, by contrast, _is_ a direct probability statement: given this data and this prior, there is a 95% probability that $theta$ lies in this interval. This is not a technicality — it is exactly the kind of statement a reimbursement committee, a Ministry of Health budget holder, or a WHO technical working group actually wants to hear, and it is why Bayesian output translates so cleanly into decision language without the usual hedging.

This also explains why Bayesian methods sit so naturally inside decision modelling. A cost-effectiveness analysis is ultimately a decision problem: given everything currently known, should we recommend this intervention? The expected net monetary benefit, the probability that an intervention is cost-effective at a given threshold, the expected value of perfect information — all of these are posterior quantities, computed by integrating a decision function over a distribution of parameter uncertainty. When you ran probabilistic sensitivity analysis in earlier chapters by sampling parameters from distributions and tabulating the proportion of simulations below a willingness-to-pay threshold, you were already doing applied Bayesian decision analysis, just without a likelihood update step. The step this chapter adds is the machinery for formally updating those parameter distributions with real trial or surveillance data, rather than specifying them by assumption or extraction from a single published estimate.

There is also a scientific-honesty argument for working this way in TB and other high-burden, data-scarce programmes. Frequentist methods implicitly treat each study in isolation, re-estimating uncertainty from scratch each time. Bayesian updating lets you formally carry forward what a previous regional drug-resistance survey or an earlier cohort's treatment-success rate told you, combine it transparently with new programme data, and report exactly how much the new evidence moved your estimate. That transparency — prior stated, likelihood stated, posterior shown — is precisely the kind of audit trail that evidence reviewers increasingly expect, and it is the foundation the rest of this chapter builds on.

#heor-practice[
  When presenting Bayesian results to a non-technical decision committee, lead with the posterior probability statement ("there is an 87% probability that the intervention is cost-effective at this threshold") rather than the mechanics of the prior-likelihood combination. Reserve the prior/likelihood/posterior language for technical appendices or methods sections aimed at reviewers, where it needs to be fully transparent and reproducible.
]

#agency-note[
  NICE DSU Technical Support Document 18 (*Methods for Population-Adjusted Indirect Comparisons*), which you met in Chapter 13, explicitly recommends Bayesian estimation for several population-adjustment methods because it propagates parameter uncertainty coherently into the final decision metric without relying on asymptotic normality assumptions that can break down in small populated subgroups — exactly the situation common in TB sub-population analyses.
]

== 14.2 Priors: informative, weakly informative and vague priors

Choosing a prior is the step in Bayesian analysis that makes newcomers most nervous, usually because it feels like injecting a subjective opinion into what should be an objective calculation. The more useful framing is that every statistical model already makes assumptions — a frequentist generalised linear model assumes a link function, an error distribution, and an absence of unmeasured confounding, none of which are "objective" in any strong sense. A prior simply makes one particular assumption explicit, documented, and open to sensitivity testing, which is in many ways more honest than burying equivalent assumptions in model structure.

*Informative priors* encode substantial prior knowledge about a parameter, usually from a previous study, a meta-analysis, or formal expert elicitation. If a prior national TB survey found treatment success in 78% of patients with a standard error corresponding to a $"Beta"(150, 42)$ distribution, and you are now analysing a new but related cohort, using that as your prior is not cheating — it is using the discipline's accumulated evidence rather than discarding it. The key discipline is documenting _where the prior came from_ and _why it is relevant to the new analysis_, exactly as you would document an extrapolation assumption in a Markov model.

*Weakly informative priors* rule out implausible values without expressing a strong opinion among the plausible ones. For a log hazard ratio, a $"Normal"(0, 2.5)$ prior on the log scale is weakly informative: it says hazard ratios somewhere between roughly 0.007 and 150 are conceivable, but a hazard ratio of a trillion is not, which keeps the sampler well-behaved and rules out numerically absurd solutions without pulling the estimate toward any particular value. These are the default workhorse priors in most modern Bayesian regression work, including the `brms` defaults you will use in §14.3.

*Vague (or "flat") priors* attempt to express complete prior ignorance, for example a $"Uniform"(-infinity, infinity)$ prior on a regression coefficient, or a $"Beta"(1,1)$ — equivalent to $"Uniform"(0,1)$ — on a probability. In simple, well-identified models these behave reasonably and the posterior is driven almost entirely by the likelihood. But truly flat priors on an unbounded scale are improper (they do not integrate to one) and can cause real problems in more complex hierarchical models, where they place surprising amounts of prior mass on extreme values once transformed through a nonlinear link function. In practice, a weakly informative prior usually does the job a vague prior was trying to do, with fewer pathologies.

A practical distinction worth internalising is *conjugate versus non-conjugate priors*. A prior is conjugate to a likelihood when the resulting posterior belongs to the same distributional family as the prior, which makes the update available in closed form. The classic HEOR example is the Beta-Binomial pair: if $theta$ is a probability (say, treatment success) with prior $theta tilde "Beta"(alpha, beta)$, and you observe $y$ successes out of $n$ trials, the posterior is simply

$ theta | y tilde "Beta"(alpha + y, beta + n - y) $

no simulation required. You can compute and plot this directly in R:

```r
# Beta-Binomial conjugate update: TB treatment success rate
alpha_prior <- 150   # prior "successes"
beta_prior  <- 42    # prior "failures"

y <- 34   # observed successes in new cohort
n <- 40   # total patients in new cohort

alpha_post <- alpha_prior + y          # 184
beta_post  <- beta_prior + (n - y)     # 48

post_mean   <- alpha_post / (alpha_post + beta_post)   # 0.793
post_median <- qbeta(0.5, alpha_post, beta_post)
cri_95      <- qbeta(c(0.025, 0.975), alpha_post, beta_post)

cat(sprintf("Posterior mean: %.3f\n", post_mean))
cat(sprintf("95%% credible interval: [%.3f, %.3f]\n", cri_95[1], cri_95[2]))
```

With $alpha_"prior" = 150$, $beta_"prior" = 42$, $y = 34$ and $n = 40$, the update gives $alpha_"post" = 150 + 34 = 184$ and $beta_"post" = 42 + (40-34) = 48$, so the posterior mean is $184 \/ (184+48) = 0.793$ — barely moved from the prior mean of $150\/192 = 0.781$, because the new cohort of 40 patients carries far less information than the 192 "pseudo-observations" already encoded in the prior. This is exactly the tug-of-war intuition from §14.1 made concrete.

#report-table(
  [Posterior summary for TB treatment success probability, Beta-Binomial conjugate update ($n=40$ new cohort patients, $y=34$ successes, informative prior $"Beta"(150,42)$)],
  academic-table(
    columns: (1.6fr, auto, auto),
    align: (left, right, right),
    header: ([*Quantity*], [*Prior*], [*Posterior*]),
    body: (
      [Distribution], [Beta(150, 48)], [Beta(184, 48)],
      [Mean], [0.781], [0.793],
      [95% interval], [(0.714, 0.841)], [(0.738, 0.843)],
    ),
    footer: none,
  ),
) <tab-ch14-betabinom>

Other conjugate pairs worth knowing are Normal-Normal (for a mean with known variance) and Gamma-Poisson (for a rate). Conjugacy is a mathematical convenience, not a requirement — most realistic HEOR models (hierarchical survival models, mixed-effects utility regressions, network meta-analyses with covariate adjustment) have no conjugate solution, which is exactly why §14.3 introduces MCMC: it lets you approximate the posterior numerically when no closed form exists.

Whatever prior family you choose, *always run a prior sensitivity analysis*. Refit the model under at least two or three materially different, individually defensible priors (for example, your informative prior, a weakly informative alternative, and a vague one) and report whether the posterior conclusions change. If the data are informative relative to the prior, the posteriors will look similar regardless of which prior you used, and you can say so with confidence. If they diverge noticeably, that divergence is itself an important finding — it tells the decision maker that current evidence is not yet strong enough to overrule prior belief, which is a very different message than reporting a single, confidently-stated number.

#pitfall[
  Do not reach for a "flat" or improper prior reflexively just to seem neutral. On transformed scales (odds ratios, hazard ratios, variance components) a flat prior on one scale can be very informative — and in a distorting way — on another. A Uniform prior on an odds ratio from 0 to 1000, for instance, puts almost all of its prior mass above an odds ratio of 10, which is rarely a neutral starting point for a clinical effect.
]

#heor-practice[
  Report your prior choices in a dedicated subsection of the methods, including the exact distributional form and parameters, the source or rationale, and the results of at least one prior sensitivity check. This is now standard expectation in Bayesian HTA submissions and mirrors the transparency already required for deterministic and probabilistic sensitivity analysis assumptions elsewhere in your model.
]

== 14.3 MCMC with Stan, JAGS and brms

Conjugate models give you an exact posterior in closed form, but almost no model you will actually need for TB programme evaluation or cost-effectiveness analysis is that convenient. Hierarchical structures, correlated random effects, non-standard likelihoods, and covariate-adjusted network meta-analyses (as in Chapter 12) all produce posteriors with no analytic solution. Markov Chain Monte Carlo (MCMC) is the computational workaround: instead of solving for the posterior algebraically, you draw a long sequence of correlated samples whose distribution converges to the posterior you want, and then you summarise those samples the same way you would summarise any other distribution of draws — means, quantiles, credible intervals.

The core idea behind every MCMC algorithm is the same: build a Markov chain — a sequence of parameter values where the next value depends only on the current one — whose long-run behaviour matches the posterior you want. Then just run it for a long time and summarise the values it visits.

The oldest practical version, *Metropolis-Hastings*, proposes a candidate next value by perturbing the current one, then accepts or rejects it with a carefully chosen probability. Over many iterations, the chain visits each region of parameter space in proportion to its posterior density. It is simple and general, but can be slow: small random proposals take a long time to cross large, high-dimensional spaces.

*Hamiltonian Monte Carlo (HMC)* speeds this up with an idea borrowed from physics. It treats the negative log-posterior as a hilly energy surface and simulates a particle rolling across it with momentum, using the surface's *gradient* to steer proposals toward high-density regions instead of wandering randomly. Big, informed steps even in high dimensions — that is why HMC scales so much better to the complex hierarchical models common in HEOR.

*NUTS, the No-U-Turn Sampler*, is the practical refinement of HMC that Stan actually runs. It automatically decides how far the simulated particle should travel before it starts turning back on itself, so you never have to hand-tune a step count. You do not need to implement any of this maths yourself — Stan's compiler and sampler handle it — but the intuition explains why Stan models typically reach the same effective sample size in fewer iterations than JAGS models. §14.4 picks that thread back up.

JAGS (Just Another Gibbs Sampler) — the engine behind `gemtc` in Chapter 12 — instead typically uses *Gibbs sampling*: a special case of Metropolis-Hastings that updates one parameter at a time, drawing each directly from its full conditional distribution given every other parameter's current value. This fits naturally with conjugate or near-conjugate hierarchical structures, which is part of why JAGS remains common in network meta-analysis work. It can converge more slowly than HMC/NUTS, though, when parameters are highly correlated.

It helps to see all three engines fit the same simple model: a Beta-Binomial treatment-success analysis, extended slightly to a logistic-regression-style setting so the code generalises to more realistic use. Start with raw Stan via `rstan`, which requires writing the model explicitly in Stan's own modelling language and compiling it:

```r
library(rstan)

stan_code <- "
data {
  int<lower=0> n;      // number of patients
  int<lower=0> y;      // number of successes
}
parameters {
  real<lower=0, upper=1> theta;   // treatment success probability
}
model {
  theta ~ beta(2, 2);    // weakly informative prior
  y ~ binomial(n, theta);
}
"

stan_data <- list(n = 40, y = 34)

fit_stan <- stan(
  model_code = stan_code,
  data       = stan_data,
  chains     = 4,
  iter       = 2000,
  warmup     = 1000,
  seed       = 123
)

print(fit_stan, probs = c(0.025, 0.5, 0.975))
```

The same model in JAGS, using `rjags`, requires its own BUGS-style model syntax and a slightly more manual sampling loop built from `jags.model()` followed by `coda.samples()`:

```r
library(rjags)
library(coda)

jags_code <- "
model {
  theta ~ dbeta(2, 2)
  y ~ dbin(theta, n)
}
"
writeLines(jags_code, con = "beta_binom.jags")

jags_data <- list(n = 40, y = 34)

jags_mod <- jags.model(
  file     = "beta_binom.jags",
  data     = jags_data,
  n.chains = 4,
  n.adapt  = 1000
)

update(jags_mod, n.iter = 1000)   # burn-in

fit_jags <- coda.samples(
  jags_mod,
  variable.names = "theta",
  n.iter         = 2000
)

summary(fit_jags)
```

Finally, `brms` sits on top of Stan and lets you specify most standard regression-style models using familiar R formula syntax, generating and compiling the underlying Stan code automatically:

```r
library(brms)

tb_df <- data.frame(
  success = 34,
  total   = 40
)

fit_brms <- brm(
  success | trials(total) ~ 1,
  data   = tb_df,
  family = binomial(),
  prior  = set_prior("normal(0, 2.5)", class = "Intercept"),
  chains = 4,
  iter   = 2000,
  warmup = 1000,
  cores  = 4,
  seed   = 123
)

summary(fit_brms)
plot(fit_brms)
```

Note the prior is set on the intercept on the logit scale here rather than directly on $theta$, since `brms` builds a generalised linear model internally — this is a common source of confusion for analysts moving from hand-coded Beta-Binomial models to formula-based Bayesian regression, and worth testing on a known conjugate example (as above) before trusting it on a model with no closed-form answer.

Each tool has a natural niche. `rstan` gives you full control and is the natural choice when you need a custom likelihood that neither JAGS's BUGS dialect nor `brms`'s formula interface can express. `rjags` remains valuable for Gibbs-friendly hierarchical structures and for continuity with network meta-analysis workflows already built on JAGS, as in Chapter 12's `gemtc` models. `brms` is usually the fastest path for standard regression-style problems — mixed-effects survival models, multilevel utility regressions, dose-response curves — because it handles the Stan code generation, prior specification helpers, and post-processing for you, while still letting you drop down to the underlying `stanfit` object (via `fit_brms$fit`) when you need finer control. For most day-to-day HEOR regression work, start with `brms`; reach for raw `rstan` or `rjags` when the model structure genuinely demands it.

#pitfall[
  Running an MCMC model and immediately trusting `summary()` output without checking convergence is the single most common Bayesian analysis error. The `print()` and `summary()` calls above already return `Rhat` and effective sample size alongside the posterior estimates — do not report a posterior mean or credible interval until those diagnostics have been checked, which §14.4 covers in full, building on the $hat(R) < 1.05$ convergence rule you already applied to `gemtc` and `multinma` network meta-analysis models in Chapter 12.
]

== 14.4 Diagnostics: convergence, effective sample size, and posterior predictive checks

Running an MCMC sampler and getting numbers back is the easy part. Trusting those numbers is the job. In Chapter 12 you fit Bayesian network meta-analyses with `gemtc`, `multinma`, and `bnma`, and each time we flagged a `coda::gelman.diag()` check and moved on, promising we'd come back to what it actually means. This is that promise kept. Diagnostics are not a bureaucratic box to tick before an HTA submission reviewer asks for them — they are the difference between a posterior distribution that describes your evidence and one that describes an algorithm that got stuck.

=== Why convergence is not optional

An MCMC chain is only a valid sample from the posterior once it has "forgotten" its starting value and is exploring the full shape of the distribution the way it would if you had started it somewhere else entirely. Before that point, the chain is still wandering through unrepresentative territory — the burn-in or warm-up period. The trouble is that a chain can _look_ perfectly healthy on a trace plot in the short run while still being far from target, especially in high-dimensional models like network meta-analyses with many treatment contrasts and heterogeneity parameters.

The standard first line of defence is to run several chains (`coda`, `rstan`, and `rjags`/`gemtc` all default to this) from dispersed starting values and ask whether they have converged to the _same_ distribution. If chain 1 is sampling a different region of parameter space than chain 2, you don't have one posterior, you have evidence that your sampler hasn't settled.

```r
library(coda)

# mcmc.list object from gemtc, rjags, or similar
gelman.diag(mcmc_samples, multivariate = FALSE)
```

This returns the potential scale reduction factor (PSRF), commonly called the R-hat or Gelman-Rubin statistic, for every monitored parameter. Conceptually, R-hat compares the variance _between_ chains to the variance _within_ chains. If the chains have converged, these two variances should agree and R-hat should sit at 1. In practice:

- R-hat $< 1.05$ is the traditional "acceptable" threshold used in most applied Bayesian HTA work, including the `gemtc`/NICE DSU NMA tradition you used in Chapter 12.
- R-hat $< 1.01$ is the more conservative threshold recommended by newer Stan-ecosystem guidance and increasingly expected by methodologically careful reviewers, particularly for models going into a regulatory or reimbursement submission.

#pitfall[
  A single R-hat below threshold tells you nothing if you only checked one parameter. Always check _all_ monitored parameters, not just the headline treatment effect — heterogeneity variance terms and random-effects parameters in NMA models are notoriously the last to converge, and they drive the width of your decision uncertainty downstream.
]

Trace plots remain the most intuitive diagnostic precisely because R-hat is a _summary_ and summaries hide failure modes. A chain can have an acceptable R-hat and still show a slow drift, a sticky patch, or a second chain exploring a completely different mode of a multimodal posterior — all of which are visually obvious on a trace plot and easy to miss in a single number.

```r
library(bayesplot)
library(rstan)

fit <- stan(file = "nma_model.stan", data = stan_data,
            chains = 4, iter = 4000, warmup = 2000)

posterior_array <- as.array(fit)
mcmc_trace(posterior_array, pars = c("d[1]", "d[2]", "tau"))
```

A healthy trace plot looks like a "fat hairy caterpillar" — four overlapping bands with no trend, no chain visibly separated from the others, and no long flat stretches where the sampler got stuck.

#figure(
  image("../images/r_generated/ch14_mcmc_trace.png", width: 90%),
  caption: [
    Illustrative `bayesplot::mcmc_trace()` diagnostic on *simulated* MCMC
    draws (4 chains x 2,000 post-warmup iterations, hand-constructed with
    mild autocorrelation around the chapter's own Beta-Binomial posterior
    mean of 0.793), shown on both the natural ($theta$) and logit scales.
    This is *not* output from an actually-fitted Stan/brms model — the
    book's environment does not have rstan/brms installed/fittable — it is
    provided purely to demonstrate what a healthy, well-mixed "fat hairy
    caterpillar" trace plot looks like in practice.
  ],
) <fig-ch14-mcmc-trace>

=== Effective sample size: why 20,000 draws can be worth 200

Here is the point that trips up most analysts moving from frequentist bootstrapping to MCMC: _the number of post-warm-up iterations you ran is not the number of independent pieces of information you have._ MCMC draws are autocorrelated — each draw depends on the one before it — so a chain of 10,000 iterations might carry the statistical information of only a few hundred truly independent draws if the sampler mixes slowly.

The effective sample size (ESS) corrects for this autocorrelation and tells you, in effect, "how many independent draws would give you the same precision as the correlated chain you actually have."

```r
effectiveSize(mcmc_samples)
```

Inside the Stan ecosystem, `rstan::monitor()` reports `n_eff` alongside R-hat for exactly this reason — the two diagnostics are reported together because they answer different questions. R-hat asks "have my chains converged to the same place?" ESS asks "once converged, how much _information_ do I actually have about this parameter?" You can have excellent R-hat with dismal ESS if chains converge quickly to the right region but then mix very slowly within it — a common pattern for variance components in hierarchical NMA models.

As a rule of thumb, treat ESS below roughly 400 (across all chains combined) for any parameter you plan to report as a trigger to run the model longer or reparameterise it, regardless of how good your R-hat looks. For Stan models specifically, also check sampler-level diagnostics beyond R-hat and ESS — divergent transitions, which indicate the sampler is struggling with the geometry of the posterior (common with funnel-shaped hierarchical priors):

#difficult-terminology("funnel-shaped hierarchical priors (Neal's funnel)")[
In a hierarchical model, individual-level effects (e.g. each study's own effect) are usually written as "the overall average, plus a study-specific deviation whose size is controlled by one variance parameter." The trouble is that this variance parameter and the individual deviations are mathematically tangled together: when the variance parameter is estimated to be small, the deviations are forced to be tiny too, and when it's large, the deviations can range widely. Plotted together, the geometry of that joint space looks like a funnel — wide and open at one end (large variance, loosely-constrained deviations), narrowing to a tight neck at the other (small variance, tightly-constrained deviations). Samplers like Stan's HMC/NUTS struggle badly inside that narrow neck, because the step size that works well in the wide part of the funnel is too large to navigate the narrow part without "divergent transitions" (the sampler effectively crashing into the funnel's walls). It's a well-known pathology named after statistician Radford Neal, and the standard fix is a *non-centered parameterisation* — reformulating the model so the individual deviations are expressed as independent, unit-scaled quantities multiplied by the variance parameter afterwards, rather than directly tangled with it, which straightens the funnel out into geometry the sampler can explore efficiently.
]

```r
check_hmc_diagnostics(fit)
```

A model with zero divergent transitions, R-hat below 1.01, and adequate ESS on every parameter you intend to use downstream is one you can defend to a reviewer. A model with any one of those failing is not ready for a decision analysis, no matter how plausible the point estimates look.

=== Posterior predictive checks

Convergence diagnostics tell you whether your _sampler_ worked. They say nothing about whether your _model_ is any good. For that you need posterior predictive checks (PPCs): simulate new data from the fitted model's posterior and ask whether that simulated data looks like the data you actually observed. If your model is a reasonable description of the data-generating process, replicated datasets drawn from the posterior predictive distribution should be hard to distinguish from the real thing.

```r
library(bayesplot)

y_rep <- posterior_predict(fit)  # or extract manually from Stan output

ppc_dens_overlay(y = observed_outcomes, yrep = y_rep[1:50, ])
```

This overlays the density of your observed outcome on top of 50 densities simulated from posterior draws. A model that fits well produces a tight bundle of replicated curves hugging the observed curve. A model that systematically misses — too much dispersion, wrong skew, a mode in the wrong place — shows up as replicated curves that visibly diverge from the observed data, which is a much more concrete signal than a residual plot for an analyst still building intuition for what "model misfit" looks like in a Bayesian setting.

#figure(
  image("../images/r_generated/ch14_ppc_dens_overlay.png", width: 90%),
  caption: [
    Illustrative `bayesplot::ppc_dens_overlay()` diagnostic comparing a
    *simulated* observed-outcome density to 20 *simulated* posterior-predictive
    replicate densities, both drawn from Beta distributions perturbed around
    the chapter's Beta-Binomial posterior parameters ($alpha_"post"=184$,
    $beta_"post"=48$). This is *not* output from an actually-fitted
    Stan/brms model — the book's environment does not have rstan/brms
    installed/fittable — it is provided purely to demonstrate what a tight,
    well-fitting bundle of replicated curves looks like against the observed
    data.
  ],
) <fig-ch14-ppc-dens-overlay>

#heor-practice[
  For a Bayesian NMA feeding a cost-effectiveness model, run PPCs on each trial's observed event counts against the model's posterior predictive event counts before trusting the pooled treatment effects. A network that fits the overall deviance well can still badly misfit one influential trial — exactly the trial that might be driving your incremental cost-effectiveness ratio.
]

#agency-note[
  NICE DSU Technical Support Document 2 (Dias et al., *Evidence Synthesis for Decision Making 2: A Generalised Linear Modelling Framework for Pairwise and Network Meta-Analysis of Randomised Controlled Trials*), already named in Chapter 12's reporting section, explicitly recommends reporting the deviance information criterion alongside convergence diagnostics for network meta-analysis models submitted to NICE, and treats inadequate convergence checking as a methodological limitation reviewers are instructed to flag.
]

== 14.5 Bayesian evidence synthesis as a pipeline

Chapter 12 walked through fitting Bayesian network meta-analyses in practice — `gemtc` wrapping JAGS, `multinma` wrapping Stan, and `bnma` as a lighter-weight alternative — and showed you how to extract pooled treatment effects and relative rankings. This section does not repeat that. Instead, it steps back to the principle that makes Bayesian evidence synthesis worth the extra modelling effort in the first place, and sets up why §14.6 can treat the output of Chapter 12's models as directly usable decision-analytic input.

=== The general principle: synthesis produces a distribution, not a number

Classical (frequentist) meta-analysis gives you a pooled effect estimate and a confidence interval. That interval describes sampling variability under repeated hypothetical experiments — a long-run frequency statement, not a probability statement about the parameter itself. A Bayesian meta-analysis or NMA, by contrast, gives you a full posterior distribution over every pooled effect, every between-study heterogeneity parameter, and every treatment ranking probability. That distribution _is_ a direct probability statement: "given this evidence and this model, here is how plausible each value of the treatment effect is."

This distinction sounds academic until you reach the point where you need to propagate evidence uncertainty into a decision model. A confidence interval does not tell you how to sample from it in a way that respects the correlation structure between parameters — you have to impose an additional distributional assumption (normal, usually, on the log-hazard-ratio scale) and often ignore correlations between related parameters altogether. A Bayesian posterior needs none of that. It already _is_ a joint sample over every parameter, correlations included, ready to be drawn from directly.

=== Why this matters more as networks get more complex

The benefit of full posterior propagation scales with the complexity of the evidence base. A two-arm pairwise meta-analysis has one pooled effect and its uncertainty is easy to approximate reasonably well with a normal distribution. A network with several treatments, as in Chapter 12's worked example, has many pairwise contrasts, each correlated with the others through the network structure and the consistency assumptions baked into the model. There is no sensible way to hand-construct a joint distributional assumption that preserves those correlations for a downstream Monte Carlo simulation. The posterior sample from `gemtc`, `multinma`, or `bnma`, however, already carries those correlations intact, because every MCMC draw is a complete, internally consistent set of all the contrasts simultaneously.

This is the real argument for Bayesian evidence synthesis in an HEOR context. It isn't that Bayesian point estimates differ meaningfully from frequentist ones under vague priors (often they barely do). It's that the _output object_ — the posterior sample — is already in the exact shape a decision model needs, with no further approximation step required.

```r
# Recall from Chapter 12: a gemtc NMA fit
library(gemtc)

# mcmc.list of relative-effect draws, one column per contrast
relative_effects <- relative.effect(nma_fit, t1 = "placebo")
re_samples <- as.matrix(relative_effects$samples)

# Each row is one joint posterior draw across every contrast --
# correlations between contrasts are preserved automatically
head(re_samples)
```

This `re_samples` matrix is the hinge on which the rest of this chapter turns: it is simultaneously the end product of Chapter 12's evidence synthesis and the raw material for the decision analysis in §14.6.

=== Where this fits in the overall workflow

Think of Bayesian evidence synthesis as the first stage of a two-stage pipeline, not a standalone analysis:

1. _Synthesis stage_ (Chapter 12's territory): combine all available trials — pairwise or networked — into posterior distributions for relative treatment effects, using `gemtc`, `multinma`, or `bnma` as appropriate to the network structure and priors required.
2. _Decision stage_ (this chapter's territory, §14.6): feed those posterior draws, unmodified, into a cost-effectiveness model as the probabilistic sensitivity analysis sample for treatment effect.

#heor-practice[
  When writing up methods for a submission, be explicit that the PSA distribution for relative treatment effect _is_ the NMA posterior sample, not a distribution fitted _to_ the posterior sample's mean and standard deviation. Re-fitting a normal distribution to posterior summary statistics throws away exactly the correlation structure that made the Bayesian synthesis worth doing, and reviewers familiar with the NICE DSU documents will ask why you did it.
]

#pitfall[
  Thinning or subsampling the posterior sample before passing it to the decision model (e.g. taking every 10th draw to get a "round" PSA sample size) is usually unnecessary and can quietly reduce the effective precision of your PSA results. Unless autocorrelation diagnostics (§14.4) indicate the chain needs thinning for storage reasons, pass the full post-warm-up sample through.
]

The next section makes this pipeline concrete: taking posterior draws — whether from an NMA, a simpler pairwise meta-analysis, or any other Bayesian evidence model — and using them as the engine of a full probabilistic cost-effectiveness analysis.

== 14.6 Bayesian decision analysis: from posterior to PSA

Everything in this chapter has been building toward one practical payoff, and it is worth stating plainly: _a Bayesian model's posterior draws are a probabilistic sensitivity analysis sample._ There is no separate step where you fit a distribution to a parameter and then sample from it for PSA — the posterior draws produced by your MCMC sampler in §14.1-14.3, or by the NMA models of Chapter 12, already are that sample. This section shows how to use them that way.

=== Expected value under a posterior

A health economic decision model computes, for each strategy $s$, some net benefit function — most commonly net monetary benefit at a willingness-to-pay threshold $lambda$:

$ "NMB"_s = lambda times "QALY"_s - "Cost"_s $

In a deterministic model you plug in point estimates for every input parameter and get one number per strategy. In a Bayesian decision-analytic framing, every input parameter — the treatment effect, the utility decrement, the cost, the transition probability — has a posterior distribution, and so does $"NMB"_s$. The _expected_ net monetary benefit is the posterior mean of that distribution:

$ "E"["NMB"_s] = integral "NMB"_s (theta) p(theta | D) dif theta $

where $theta$ is the full vector of model parameters and $p(theta | D)$ is their joint posterior given data $D$. You never evaluate this integral analytically. You approximate it by Monte Carlo: run the cost-effectiveness model once per posterior draw, and average the resulting net benefits across draws. This is exactly standard PSA mechanics — the only thing that has changed is _where the samples came from_.

=== Posterior draws as PSA input: the direct pipeline

In a conventional (non-Bayesian) PSA workflow, you fit each input parameter a distribution — a beta for a probability, a gamma for a cost, a normal for a log-hazard-ratio — usually justified by matching a point estimate and standard error from a single study or a frequentist meta-analysis, then draw independently from each one and hope the implied joint distribution across parameters is reasonable. Correlations between parameters, when they exist, have to be imposed by hand (e.g. via a multivariate normal on the log scale, or a Cholesky decomposition), which is awkward and frequently skipped.

#difficult-terminology("Cholesky decomposition")[
Suppose you want to simulate several correlated quantities at once (e.g. cost and utility that tend to move together) by starting from easy-to-generate independent random numbers. A Cholesky decomposition breaks a correlation (or covariance) matrix down into a single "square root" matrix that, when multiplied by a vector of independent random draws, produces a new vector with exactly the desired correlation structure baked in. It's the standard recipe for "injecting" a specified correlation pattern into otherwise-independent simulated numbers. A kitchen analogy: if independent random numbers are plain flour, water, and eggs, the Cholesky matrix is the recipe/ratios that combine them into a batter with the specific consistency (correlation) you wanted, rather than three separate unrelated ingredients. The point raised here is that doing this by hand, for every PSA parameter set, is exactly the fiddly step a genuine Bayesian joint posterior sample (the rest of this section) sidesteps entirely, because the posterior draws already come out correlated correctly without needing any decomposition trick.
]

A Bayesian evidence base sidesteps all of this. If your relative treatment effect comes from the NMA posterior sample built in §14.5, each row of that sample already is one coherent PSA iteration for the treatment-effect parameters, correlations and all. You use the rows directly as your PSA loop, rather than drawing from a distribution that was fitted _to_ that sample.

```r
library(dplyr)

# re_samples: posterior draws of relative treatment effect from gemtc/NMA (14.5)
# n_psa draws, one row per PSA iteration, columns are contrasts

n_psa <- nrow(re_samples)

# Other model inputs can also come from posteriors -- e.g. a Bayesian
# survival model's posterior draws of a hazard ratio, or simple
# independent draws if those parameters weren't modelled jointly
cost_psa    <- rgamma(n_psa, shape = 20, rate = 20 / 3500)
utility_psa <- rbeta(n_psa, shape1 = 40, shape2 = 10)

psa_results <- vector("list", n_psa)

for (i in seq_len(n_psa)) {
  log_hr <- re_samples[i, "d.placebo.treatment"]

  qalys_treatment <- simulate_qalys(hr = exp(log_hr), utility = utility_psa[i])
  cost_treatment  <- simulate_costs(hr = exp(log_hr), unit_cost = cost_psa[i])

  psa_results[[i]] <- data.frame(
    iteration = i,
    nmb_treatment = 30000 * qalys_treatment - cost_treatment,
    nmb_control   = 30000 * simulate_qalys(hr = 1, utility = utility_psa[i]) -
                     simulate_costs(hr = 1, unit_cost = cost_psa[i])
  )
}

psa_df <- bind_rows(psa_results)

# Expected net monetary benefit per strategy, and probability treatment
# is cost-effective at this threshold
psa_df |>
  summarise(
    E_nmb_treatment = mean(nmb_treatment),
    E_nmb_control   = mean(nmb_control),
    prob_ce         = mean(nmb_treatment > nmb_control)
  )
```

Notice what did _not_ happen here: there was no step that said "fit a normal distribution to the log hazard ratio's posterior mean and SD, then draw from that." The posterior draws went straight into the simulation loop. Every correlation between contrasts that existed in the original NMA posterior — for instance, if two active treatments were both compared against the same reference and so their relative effects are not independent — survives into the PSA, because row $i$ of `re_samples` is used as a complete, internally consistent unit.

#heor-practice[
  When your evidence base mixes Bayesian and non-Bayesian sources — a Bayesian NMA posterior for relative effect alongside a classically-fitted parametric survival curve for baseline risk — align the number of PSA iterations to the smaller or more constrained posterior sample, or resample consistently, and document which inputs came from genuine joint posteriors versus independently assumed distributions. A reviewer should be able to tell at a glance which parts of your PSA have real correlation structure behind them.
]

=== Decision uncertainty is now a direct statement about the evidence

Reporting a cost-effectiveness acceptability curve (CEAC) built from this PSA has a cleaner Bayesian interpretation than its frequentist counterpart. The proportion of PSA iterations where treatment has higher net benefit than control, at a given $lambda$, is a direct posterior probability that treatment is cost-effective at that threshold, given the data and the model — not an approximation justified by asymptotic sampling theory. This is a more honest match between the question decision-makers actually ask ("how likely is it that this treatment is worth it?") and the quantity the analysis reports.

#pitfall[
  If you draw $theta$ from a posterior but then still report the deterministic ("base case") analysis using the posterior _mean_ of $theta$ plugged into the model once, you have built a Bayesian evidence base but reverted to a non-probabilistic decision analysis. The expected value of a nonlinear function of $theta$ is not generally equal to the function evaluated at $"E"[theta]$ — run the full posterior sample through the model, not just its central tendency.
]

#agency-note[
  The ISPOR-SMDM Modeling Good Research Practices Task Force report on model transparency and validation (Eddy et al. 2012, *Value in Health*, "Model Transparency and Validation") recommends that probabilistic sensitivity analysis fully propagate parameter uncertainty including correlation structure where it exists — a requirement that a direct Bayesian-posterior-as-PSA-sample pipeline satisfies by construction, where an independently-sampled, distribution-fitted PSA typically does not.
]

== 14.7 Expert elicitation methods (SHELF)

Most of this chapter has assumed you have _data_ — trial arms, observational cohorts, registry follow-up — from which a likelihood can be built and combined with a prior. But a large share of real HEOR work, especially around rare diseases, orphan drugs, and early-stage HTA submissions for genuinely novel technologies, runs into parameters for which no usable data exist at all. What is the five-year mortality benefit of a gene therapy with eighteen months of trial follow-up? What proportion of patients will adhere to a new delivery device nobody has used outside a lab? Committees still need a number — or, in the Bayesian framing of this chapter, a _distribution_ — for these parameters, and when data cannot supply it, the next-best evidence is structured expert judgement.

The word "structured" matters enormously here. Unstructured expert judgement — asking a clinician "what do you think the rate is?" over the phone — is exactly the kind of informal, poorly-calibrated input that got Bayesian methods a bad reputation for being "subjective" in a pejorative sense. The response from the methodology community, and specifically from the University of Sheffield group, was to formalise the process into a reproducible protocol: the *Sheffield Elicitation Framework*, universally known by its acronym, *SHELF*. SHELF is not a piece of software first and foremost — it is a facilitation method, a set of templates, and a philosophy for turning "what an expert believes" into a probability distribution that can be defended, audited, and fed into a model. The R package of the same name (note the package name is capitalised, `SHELF`) is the computational companion that fits distributions to the quantities the facilitation process produces.

#heor-practice[
  Elicitation is appropriate for parameters where data genuinely do not exist or are too immature to trust — not as a shortcut past the inconvenience of designing a study. A NICE committee or a payer reviewer confronted with an elicited prior will scrutinise _how_ it was elicited at least as closely as the number itself. Treat the process documentation (who, how many experts, what questions, what reconciliation) as a deliverable in its own right, not an afterthought.
]

*Roles in the process.* A SHELF exercise has two distinct kinds of participant, and conflating them is a common and damaging mistake.

- _The facilitator_ is a trained elicitation specialist (ideally with statistical literacy but, crucially, with no personal stake in the parameter's value) who runs the session, asks questions in a format designed to counteract known cognitive biases (overconfidence, anchoring, availability), and never offers their own opinion of the "right" answer.
- _The experts_ are the substantive content specialists — clinicians, epidemiologists, sometimes patients or carers for quantities like health state preferences — who hold the relevant domain knowledge but typically have no particular training in thinking probabilistically. Part of the facilitator's job is translating a clinical intuition ("most patients do reasonably well, a few have terrible outcomes") into quantiles a distribution can be fitted to.

*The general process.* A typical SHELF exercise, whether for a single parameter or a small set, follows roughly this arc:

1. _Preparation._ The facilitator defines the quantity of interest precisely (a frequent failure mode is experts answering slightly different questions from each other because the parameter was never pinned down — "response rate" at what time point, in what population, by what definition of response).
2. _Individual elicitation._ Each expert, independently and without discussion with the others, is asked a sequence of questions designed to pin down their personal distribution for the parameter — typically a median, then a lower and upper quartile or tertile, sometimes plausible extreme bounds. Individual elicitation first is deliberate: it prevents the loudest or most senior voice in the room from anchoring everyone else before independent judgements are recorded.
3. _Group discussion._ The individual judgements are shared, discussed, and the _reasons_ behind disagreement are explored — not to force consensus, but so that each expert can rationally update their own view in light of arguments they hadn't considered.
4. _Reconciliation._ The group works toward a single "rational impartial observer" distribution representing the pooled judgement — SHELF provides specific templates for this step, rather than leaving it to an unstructured vote.
5. _Distribution fitting._ The elicited quantiles (individual or reconciled) are fitted to a parametric distribution — commonly a beta for a probability, a gamma or log-normal for a rate or cost, a normal for a roughly symmetric continuous quantity.

*R tooling.* The `SHELF` package on CRAN implements the fitting and feedback steps computationally. Given elicited judgements (for example, a median and two quartiles from one expert), the typical workflow is to fit a family of candidate distributions and visually check which gives a good fit to the elicited quantiles:

```r
library(SHELF)

# Example: an expert has given judgements for a response-rate
# parameter as quantiles: 25th percentile = 0.30, median = 0.45,
# 75th percentile = 0.60
my_probs <- c(0.25, 0.5, 0.75)
my_vals  <- c(0.30, 0.45, 0.60)

fit <- SHELF::fitdist(vals = my_vals, probs = my_probs,
                       lower = 0, upper = 1)

# Inspect which parametric family fits best
fit$ssq

# Visualise the fitted distribution(s) against the elicited points
SHELF::plotfit(fit, lp = TRUE)
```

The package also provides feedback-style diagnostics — comparing implied probabilities from the fitted distribution back against further quantiles the expert supplies, as a sanity check that the fit captures their actual judgement — via a function along the lines of `SHELF::feedback()`. Not every argument name and default in the current `feedback()` signature has been independently re-checked against the live CRAN documentation here, so treat the call above as illustrative of the _idea_ rather than a copy-paste guarantee; always run `?SHELF::fitdist` and `?SHELF::feedback` in your own R session before relying on the precise arguments, since package APIs do shift across versions. The package also ships a Shiny app for live group elicitation sessions — genuinely useful if you expect to run this more than once.

#figure(
  image("../images/r_generated/ch14_shelf_plotfit.png", width: 85%),
  caption: [`SHELF::plotfit()` overlay of fitted candidate distributions against the elicited response-rate quantiles (25th/50th/75th percentiles = 0.30/0.45/0.60). By `fit$ssq` least-squares scoring, SHELF's default ranking places the unbounded skew-normal and normal families as the closest numerical fit to these three points (ssq on the order of $10^(-32)$ -- essentially exact, because a symmetric three-point quantile set is fit almost perfectly by a two/three-parameter symmetric family). The beta fit scores a higher but still small ssq ($1.99 times 10^(-5)$), with gamma and log-normal trailing further behind. For a HEOR prior on a probability, this is the practical lesson: the *lowest-ssq* family is not automatically the *right* one to carry into the model -- a response rate is bounded on $[0,1]$, and the normal/skew-normal fits can assign positive density outside that range, which is nonsensical for a probability parameter. The beta fit, despite its slightly larger ssq, is the one that should feed the prior, precisely because it respects the support of the parameter being elicited.]
) <fig-ch14-shelf>

#pitfall[
  A beta or gamma fit to elicited quantiles is a _summary_ of judgement, not a measurement. Resist the temptation to report the fitted distribution's standard error with the same confident precision you would give a trial estimate's standard error — it reflects how confident the expert group felt, filtered through a parametric approximation, not a sampling distribution of anything. Always report, alongside the fitted parameters, who was elicited, how many experts, and whether reconciliation changed the picture materially.
]

#agency-note[
  NICE's Decision Support Unit Technical Support Document 33, "Expert Elicitation: Issues and Challenges," is the standard methodological reference UK HTA submissions point to when using elicited priors, and SHELF is the protocol it most closely aligns with in practice; if an elicitation exercise will inform a submission, read that document (or the equivalent guidance your jurisdiction's HTA body references) before designing the session, not after.
]

== 14.8 Bayesian health economic modelling workflows

This closing section is deliberately a roadmap rather than a new technique. Up to this point the chapter has built the pieces in isolation — Bayes' theorem and conjugate updating, MCMC sampling with Stan or JAGS, convergence diagnostics, and posterior-to-PSA translation — and §14.7 just added expert elicitation as a way to construct priors when data run out. None of these pieces does anything useful for a decision-maker on its own. The payoff is in chaining them into a single, reproducible, end-to-end workflow that starts with "what do we believe before seeing data" and ends with "here is the probability this technology is cost-effective, and here is how much it would be worth resolving our remaining uncertainty." Walking through that chain end to end is the point of this section.

*Step 1 — Prior elicitation and specification.* Every Bayesian model starts with a prior, whether it is a deliberately vague, weakly informative default or a carefully elicited distribution from §14.7. The discipline worth adopting here is documentation: record not just the prior's parametric form but _why_ that form and those parameter values were chosen — vague because nothing better was available, informative because a SHELF exercise was run, or weakly informative as a regularising choice to stabilise an otherwise unidentified model. A reviewer (or your future self) will ask.

*Step 2 — Bayesian evidence synthesis.* Where there are multiple studies bearing on a parameter — several trials estimating a treatment effect, several registries estimating a transition probability — Chapter 12's Bayesian network meta-analysis, or a simpler Bayesian meta-analysis of the kind introduced earlier in this chapter, combines them into a single posterior while properly propagating between-study heterogeneity. This step is where most of the genuine _evidence_ enters the model; the prior from Step 1 and the likelihood from the synthesised data combine here, typically specified as a hierarchical model in Stan or JAGS.

*Step 3 — MCMC fitting.* The joint posterior over every parameter in the synthesis model — treatment effects, baseline event rates, heterogeneity variances, and anything else in the model's parameter vector — is sampled numerically, since it almost never has a closed form once you move past the simplest conjugate cases covered early in the chapter. This is mechanically the same `stan()` or `jags.model()` call pattern used throughout the chapter; what differs model to model is the structure wired into the Stan/JAGS code, not the fitting mechanics.

*Step 4 — Diagnostics.* Before a single posterior draw is trusted for anything downstream, run the checks from §14.4: $hat(R)$ close to 1 for every parameter, adequate effective sample size, trace plots that look like noise rather than trends, and divergent-transition counts near zero if you are using Stan's Hamiltonian Monte Carlo sampler. This is not an optional formality — a decision model fed non-converged MCMC output will produce PSA results that look precise and are simply wrong, and nothing downstream will flag that for you.

```r
# Illustrative: checking convergence before using draws downstream
library(rstan)
print(fit_synthesis, pars = c("mu", "tau"))   # check Rhat, n_eff
rstan::traceplot(fit_synthesis, pars = c("mu", "tau"))
```

*Step 5 — Posterior draws as the PSA sample.* This is the step that makes the whole chapter's effort worthwhile, and it is where §14.6's logic lands. In a conventional frequentist PSA, you fit point estimates and standard errors to each model parameter, then _separately_ specify a distribution (beta, gamma, log-normal) for each one to sample from — an extra modelling step that can lose the correlation structure between parameters estimated jointly from the same data. In a Bayesian workflow, there is no separate step: each row of the MCMC output _already is_ one coherent draw of the full parameter vector from the joint posterior, correlations intact. You simply take those draws — thousands of them, one per retained MCMC iteration — and pass them straight into the decision-analytic model (a Markov model, a partitioned survival model, whatever structure Part IV's chapters build) to compute costs and QALYs under each draw. No distributional assumptions are layered on top of the evidence synthesis; the posterior _is_ the PSA input.

```r
# Illustrative: extracting posterior draws as PSA inputs
library(rstan)
draws <- rstan::extract(fit_synthesis)
# draws$mu, draws$tau (etc.) are now vectors of length n_draws,
# ready to be looped through a cost-effectiveness model row by row
```

*Step 6 — Reporting.* Transparency matters at every step above, but especially here: a results table or report should make clear which parameters came from elicitation, which from synthesis, what the convergence diagnostics showed, and how many posterior draws fed the PSA. This is the kind of audit trail HTA bodies and peer reviewers increasingly expect, and the ISPOR-SMDM Modeling Good Research Practices task force reports are a useful reference point for what that reporting should cover structurally, alongside CHEERS 2022 for the economic evaluation reporting itself.

#heor-practice[
  Treat this six-step chain as a checklist you re-run for every Bayesian submission, not a one-off design exercise. The most common real-world failure is not a statistical error in any single step — it is a broken link between steps: synthesis draws that get summarised down to a mean and SD before being handed to the decision model, discarding exactly the joint uncertainty structure that made the Bayesian approach worth doing in the first place. Keep the full draws array moving through every step; only summarise at the very end, for reporting.
]

Looking forward, this workflow is the hinge between this chapter and Part IV. Chapter 25, on handling uncertainty and probabilistic sensitivity analysis, picks up exactly at Step 5 above and develops the decision-model side — cost-effectiveness acceptability curves, cost-effectiveness planes, and the full machinery for summarising PSA output once you have it. Chapter 26, on value of information analysis, is where a fully Bayesian model pays an extra dividend that a frequentist PSA cannot offer as naturally: because the PSA sample already _is_ a set of draws from a genuine joint posterior over every parameter, quantities like the Expected Value of Perfect Information (EVPI) and Expected Value of Partial Perfect Information (EVPPI) can be computed directly from those draws, without the additional approximating machinery sometimes needed to retrofit VOI onto a non-Bayesian PSA. If you take one thing from this chapter into the rest of the book, it should be this: a Bayesian evidence base is not just a different way of getting a p-value-free answer — it is the natural, low-friction substrate for everything Part IV does with uncertainty afterward.

#pitfall[
  Running MCMC for the evidence synthesis and then discretising the posterior down to a handful of scenarios ("low, medium, high") for the decision model defeats the purpose of this entire workflow and will understate decision uncertainty. If you have thousands of posterior draws, use thousands of draws in the PSA loop — modern decision models in R run this comfortably; the computational cost of looping over draws is rarely the real constraint.
]
