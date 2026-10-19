# Difficult Terminology Audit — R for HEOR and HTA (Ch. 1–21)

Compiled Oct 19, 2026, per Dr Aswath's request after Chapter 21's delivery. Four parallel reviews
(Ch.1-5, 6-10, 11-15, 16-21) read every chapter in full and cross-checked against
`front_matter/abbreviations.typ` (acronyms only — excluded here; this list is spelled-out
statistical/mathematical/methodological CONCEPTS used as if already known, with no inline gloss or
earlier in-book definition). Suggested definitions are pitched at the book's stated reader profile:
SQL basic/rusty, medical doctor/public health background, not deeply technical in stats.

**Total: 70 unexplained terms** across 21 chapters (20 in Ch.1-5, 13 in Ch.6-10, 28 in Ch.11-15,
9 in Ch.16-21). Density roughly tracks chapter difficulty — Ch.11-15 (meta-analysis, NMA,
population-adjusted ITCs, Bayesian methods, causal inference) is by far the densest cluster;
Ch.16-21 (regression, decision modelling) was comparatively disciplined, since those chapters
already define most of their own core mechanics (tunnel states, Dirichlet/Cholesky, clock-forward
vs. clock-reset, etc. were checked and found properly explained, so excluded).

---

## Chapter 1 — Introduction to HEOR and HTA

1. **Welfare economics / demand theory / public finance** — §"What HEOR is and what it is not". Named in one breath as background disciplines, never individually described.
   > Welfare economics studies how to judge whether a policy change makes society better or worse off overall; demand theory models how much of something people buy at different prices; public finance studies how governments raise and spend money. HEOR borrows ideas from all three but focuses narrowly on "is this one health technology worth paying for."

2. **Parametric survival curve (extrapolation)** — same section, pitfall box. Used as if "parametric" and "extrapolated" are already understood.
   > A mathematical curve (e.g., Weibull, log-normal) fitted to the survival pattern seen in trial data, then used to project survival probabilities forward past the period patients were actually followed.

3. **Microsimulation** — §Typical deliverables / §Where R fits. Listed with no description of what makes it distinct.
   > A model that simulates many individual (not just average) patients moving through health states over time, each with their own random draw of risks, so results can vary person-to-person rather than only by group averages.

4. **Discrete event simulation** — §Where R fits. Named once in a list of model types.
   > A simulation approach that advances time event-by-event (e.g., relapse, hospital admission) rather than in fixed cycles, useful when timing is irregular or resources (beds, staff) are limited.

5. **Distributional / extended cost-effectiveness analysis** — §Where R fits. Mentioned once, no definition anywhere.
   > A cost-effectiveness analysis that goes beyond one population-average result to show how costs and health gains are distributed across subgroups (e.g., income level or region), so equity impacts can be checked, not just the average value-for-money.

## Chapter 2 — Setting Up an R Environment for HEOR

6. **Hamiltonian Monte Carlo / No-U-Turn Sampler (NUTS)** — §2.5. Named as "an efficient external sampler" with zero description.
   > An algorithm for drawing samples from a complex Bayesian model's probability distribution; the No-U-Turn Sampler automatically decides how far to step each time so it explores efficiently without manual tuning.

7. **Gibbs sampling** — §2.5, contrasted with Stan's method. No description.
   > An older Markov Chain Monte Carlo technique that samples from a joint probability distribution by updating one variable at a time, each conditional on the current values of all the others.

8. **Posterior distribution** — §2.5, opening paragraph on Bayesian methods. Used as a given.
   > In Bayesian statistics, the updated probability distribution of a parameter once observed data has been combined with prior belief; Stan/JAGS exist specifically to approximate this when it can't be solved with a formula.

9. **Hierarchical structure ("borrowing strength")** — §2.5, same paragraph. Dropped in without explanation.
   > A model structure where related groups of data (e.g., several trials) share statistical information with each other, so a group with little data gets more precise estimates by partially "borrowing" information from the others.

10. **Multi-state model** — §2.7, orientation notes. Named once as a `hesim` capability.
    > A model that tracks a patient moving between more than two defined health states over time (not just alive/dead), estimating the chance and timing of each transition — a generalisation of a simple survival or Markov model.

## Chapter 3 — R Essentials for Health Economists

11. **S3 / S4 objects** — §3.4, on bundling model parameters. Mentioned as an alternative to a named list.
    > Two of R's systems for object-oriented programming — ways of packaging data together with the functions that act on it into a formally defined "object" type, more structured than a plain list.

12. **Flame graph** — §3.5, `profvis::profvis()`. No description of how to read one.
    > A visual summary of code profiling where horizontal bars show how much time each function used, stacked to show which function called which — making the slowest part of the code visually obvious.

13. **Radix sort / hash-based grouping** — §3.2, `data.table` performance discussion. No description of either technique.
    > A radix sort orders data by processing digits/characters rather than comparing whole values pairwise, making it unusually fast on large tables; hash-based grouping uses a similar lookup-table trick to group rows quickly without comparing every pair of rows.

## Chapter 4 — Core Concepts in Health Economics

14. **Non-inferiority trial** — §4.2, cost-minimization analysis bullet. No description of the trial design.
    > A clinical trial designed specifically to show a new treatment is not meaningfully worse than an existing one (within a pre-agreed margin), rather than trying to prove it's better.

15. **Value-of-a-statistical-life estimate** — §4.2, cost-benefit analysis bullet. No description of what it measures.
    > A monetary figure — derived from studies of wage premiums for risky jobs or willingness-to-pay surveys — representing what a population is, in aggregate, willing to pay to reduce the risk of one statistical death; used to put a cash value on health in cost-benefit analysis.

16. **Simpson's rule (half-cycle correction variant)** — §4.6. No description of the numerical method.
    > A numerical technique for estimating the area under a curve more accurately than a plain average, by fitting short parabolic segments between data points — used here as a refinement of the simple half-cycle midpoint approximation.

17. **Revealed preference** — §4.5, willingness-to-pay thresholds. Named alongside "stated preference" (which IS described), but itself never described.
    > A method of inferring how much people value something by observing their actual choices and trade-offs in the real world (e.g., wage premiums for riskier jobs), rather than asking them directly in a survey as stated-preference methods do.

18. **Time trade-off / standard gamble** — §4.3, QALY utility-weight elicitation. Named as "techniques" with no description of either method.
    > Time trade-off asks a respondent how many years of full health they'd give up to avoid a longer life in an impaired health state; standard gamble asks them to choose between that impaired state for certain or a gamble with some chance of immediate death versus full health. Both are standard ways of measuring how "bad" a health state is on the 0–1 utility scale.

## Chapter 5 — Data Sources and Data Management

19. **Funnel plot / Egger's test** — §5.3, publication-bias discussion. Named as "the standard tools" with no description of what either does.
    > A funnel plot graphs each study's effect size against its precision (e.g., sample size); missing small, imprecise studies on one side suggests publication bias. Egger's test is the corresponding formal statistical test for that visual asymmetry.

20. **SQL injection** — §5.4, parameterised database queries. No description of the attack itself.
    > A security flaw where untrusted text is pasted directly into a SQL query, letting someone alter what the query actually does; parameterised queries avoid this by sending user-supplied values separately from the query's structure.

---

## Chapter 6 — SLR Support in R

21. **Cohen's kappa** — §6.2. Computed and reported (0.71) with a rule-of-thumb threshold, but never explains what it measures.
    > Cohen's kappa measures how much two reviewers agree beyond what you'd expect from chance alone — unlike simple "% agreement," it corrects for the fact that two people guessing randomly will still agree sometimes.

22. **Forest plot** — §6.4/6.5, referenced as a figure type used elsewhere, never shown/described in Ch.6-10.
    > A forest plot shows each study's effect estimate (e.g. a risk ratio) as a point, with a horizontal line for its confidence interval, stacked one study per row — commonly used to compare results across studies in a meta-analysis.

## Chapter 7 — Missing Data

23. **ICH E9(R1) intercurrent-event strategies** (treatment-policy, hypothetical, composite, while-on-treatment, principal-stratum) — §7.7. Five named strategies in one sentence, zero elaboration.
    > These are five different ways to define what a clinical trial's result question actually means when something goes wrong mid-trial (dropout, rescue medication, death). For example, "treatment-policy" counts whatever happens to a patient regardless of whether they stay on the drug, while "hypothetical" asks what would have happened if the intercurrent event hadn't occurred.

24. **Degrees of freedom (pooled multiple-imputation estimates)** — §7.4. Listed as an output with no explanation of what it is or why it's non-integer here.
    > Degrees of freedom is a number used to decide how wide a confidence interval or how strict a p-value threshold should be, roughly reflecting how much independent information went into an estimate. After pooling several imputed datasets, this number is adjusted downward to reflect the extra uncertainty from not knowing the true missing values.

## Chapter 8 — Utilities

25. **Homoscedasticity** — §8.3, mapping algorithms/OLS critique. Used as a technical objection with no definition.
    > Homoscedasticity means a model assumes the scatter (variance) of errors is the same size everywhere along the range of predictions. Utility data violates this because the "noise" behaves differently near the 1.0 ceiling than lower down.

26. **Logit link (in beta regression)** — §8.4. Link functions never explained.
    > A link function is a mathematical transformation that lets a regression model predict a bounded or non-normal outcome using ordinary straight-line machinery. The logit link transforms a 0–1 value onto an unbounded scale, fits the line there, then converts predictions back — guaranteeing results stay between 0 and 1.

27. **Random utility theory (McFadden)** — §8.6, DCE elicitation table. Named as theoretical basis with no further explanation.
    > Random utility theory assumes that when people choose between options, each option has some "true" attractiveness to them plus a random, unpredictable wobble — from the pattern of many such choices, statisticians can back out how much each attribute matters on average.

## Chapter 9 — Costs and Resource Use

28. **Leverage points** — §9.3, cost data pitfalls. Used as settled statistical vocabulary.
    > A leverage point is an extreme or unusual data value (here, an extremely costly patient) that has an outsized effect on a summary statistic like the mean, simply because of how far it sits from the rest of the data.

29. **Step-down allocation** — §9.5, hybrid micro-costing. No explanation of what "step-down" means mechanically.
    > Step-down allocation is a method for spreading shared overhead costs across different services/departments in sequence, each step passing a share of cost down to the next — a standard hospital/programme cost-accounting technique.

30. **Bootstrapped estimate** — §9.3, pitfall box. "Bootstrapped" used as if self-evident.
    > Bootstrapping estimates how uncertain a statistic (like a mean) is by repeatedly resampling your own dataset (with replacement) thousands of times and recalculating the statistic each time.

## Chapter 10 — Survival Analysis

31. **Hazard function / hazard rate** — used continuously from §10.2 onward, never formally defined despite the chapter building its whole extrapolation framework around it.
    > The hazard at a given moment is the instantaneous risk of the event (e.g. death or relapse) happening right now, given that the patient has survived up to that moment — a constantly updating "risk speedometer," distinct from the overall probability of ever having the event.

32. **Schoenfeld residuals** — §10.7, `cox.zph()`. Behaviour described, mechanism never explained.
    > A Schoenfeld residual is the gap at each event time between a patient's actual covariate value and what the model's assumption predicts it should average out to — if a treatment's effect is truly constant over time, these gaps should bounce around zero.

33. **Log-likelihood** — §10.6, model selection. Starting point for AIC/BIC, never itself explained.
    > The log-likelihood is a single number summarizing how probable the observed data would be if the fitted model were true — higher (less negative) means the model describes the data better.

---

## Chapter 11 — Meta-Analysis

34. **Mantel-Haenszel (MH) method** — §11.1. Named as the fixed-effect pooling method with no description.
    > A way of combining risk ratios or odds ratios across several studies by weighting each study's result by the number of events it contributes — a classic fixed-effect pooling method, especially useful when event counts are small.

35. **Chi-squared distribution** — §11.2, justifies the Q-statistic. Shape/meaning never explained.
    > A standard statistical distribution used to test whether an observed spread of values is larger than chance alone would produce — here, whether studies disagree more than sampling error explains.

36. **Prediction interval** (vs. confidence interval) — §11.2. Never conceptually distinguished from a CI.
    > A range that tries to capture where the true effect of a brand-new, not-yet-conducted study would likely fall — wider than a confidence interval, because it accounts for between-study variation too.

37. **Generalised linear mixed model** — §11.6. Named as what `reitsma()` fits under the hood, no "mixed model" primer anywhere.
    > A regression model that combines fixed, shared effects (e.g. an overall sensitivity/specificity) with random, study-specific effects, allowing each study to deviate from the average while still being pooled together.

38. **Positive/negative likelihood ratio** — §11.6 report table. Listed as results, no clinical/statistical meaning given.
    > The positive likelihood ratio tells you how many times more likely a positive test result is in a diseased versus non-diseased patient; the negative likelihood ratio does the same for a negative result.

39. **Diagnostic odds ratio** — §11.6 report table. Value given (82.5), no explanation.
    > The odds of a positive test in diseased patients divided by the odds of a positive test in non-diseased patients — a single summary number for how well a test discriminates.

40. **"ML" and "PM" as τ² estimators** — §11.1, `rma()` options. Zero explanation, and "ML" confusingly collides with the book's own Machine-Learning abbreviation.
    > In this specific context, "ML" means maximum-likelihood estimation of the between-study variance (not machine learning), and "PM" is the Paule-Mandel estimator — another method for estimating how much studies genuinely disagree.

## Chapter 12 — Indirect Treatment Comparisons and Network Meta-Analysis

41. **Moore-Penrose pseudoinverse / Laplacian-type matrix** — §12.3.1. Pure unexplained linear-algebra jargon.
    > A matrix-algebra trick used to solve the network equations even when there isn't a single unique algebraic solution — distributing each trial's evidence consistently across every treatment comparison, analogous to solving for current flow in an electrical circuit.

42. **Basic parameters** (of a network) — used repeatedly from §12.3 onward, never defined.
    > The minimal set of treatment-effect estimates (each relative to one reference treatment) from which every other pairwise comparison in the network can be derived algebraically.

43. **Deviance / residual deviance** — §12.6. DIC is in the abbreviations file, but "deviance" itself is not.
    > A measure of how poorly a statistical model fits the observed data — lower deviance means a better fit; it's the quantity DIC and AIC are built from.

44. **Exchangeability** — §12.7. Central NMA assumption, never defined.
    > The assumption that, once known differences are accounted for, any of the included studies could have produced any of the observed results — nothing systematically different makes a particular study's "true" effect fundamentally incomparable to the others.

45. **Royston-Parmar spline model** — §12.7. Named twice, never explained.
    > A flexible survival model that fits the log cumulative hazard using smooth curve segments (splines) rather than a single fixed mathematical shape.

46. **Generalized gamma / generalized F distributions** — §12.7. Deferred to Ch.10, but Ch.10 doesn't actually cover them — remains unexplained within the book as audited.
    > Two flexible families of mathematical curves for modelling survival time that can take on a wide range of shapes, more adaptable than simpler shapes like the exponential or Weibull.

## Chapter 13 — Population-Adjusted Indirect Comparisons

47. **Sobol' sequences / Quasi-Monte Carlo integration points** — §13.4. Dense statistical-computing jargon with no gloss.
    > A structured (non-random) way of generating sample points that cover a range of possible covariate values efficiently and evenly, used to numerically average a model's predictions over a trial's reported covariate distribution.

48. **Gaussian copula** — same sentence as above, §13.4.
    > A mathematical device for generating correlated random values for several covariates at once (e.g. age and disease severity moving together realistically), built from each covariate's own distribution plus their reported correlations.

49. **Robust (sandwich-type) standard errors** — §13.2. Named but mechanism/reason not explained.
    > A way of calculating a parameter's uncertainty that doesn't assume the model's variance structure is exactly correct — useful here because MAIC weights are themselves estimated with their own uncertainty.

## Chapter 14 — Bayesian Methods for HEOR

50. **Funnel-shaped hierarchical priors** (Neal's funnel) — §14.4. A well-known pathology referenced only by a cryptic adjective.
    > A shape that can occur in hierarchical models where a variance parameter and the individual effects it governs become tightly, awkwardly linked — notoriously hard for samplers to explore properly and a common cause of poor convergence.

51. **Cholesky decomposition** — §14.6. Named with no explanation of purpose.
    > A matrix-algebra technique for generating correlated random draws from independent random numbers — a recipe for "injecting" a specified correlation structure into simulated data.

## Chapter 15 — Real-World Evidence and Causal Inference

52. **Endogeneity / endogenous variable** — §15.6 report table. Central to the IV rationale, never defined in plain language.
    > A variable is "endogenous" when it's influenced by the same unmeasured factors that influence the outcome — ordinary regression will give a biased estimate of its effect, which instrumental variables are designed to fix.

53. **Wu-Hausman test** — §15.6 table. Named with only a one-line result, mechanism unexplained.
    > A statistical test comparing the regular regression estimate to the instrumental-variables estimate; a significant result suggests unmeasured confounding (endogeneity) is a real concern.

54. **Sargan (over-identification) test** — §15.6 table. Minimally glossed, mechanism unexplained.
    > A check, only possible when you have more instruments than strictly needed, for whether all the instruments appear to be estimating the same effect.

55. **Marginal structural models** — §15.5. Named as one of three g-methods, no description of what distinguishes it.
    > A model for estimating what would happen if everyone received a particular treatment strategy over time, built by reweighting patients (via time-varying IPTW) rather than including time-varying confounders directly as covariates.

56. **G-estimation of structural nested models** — §15.5, same sentence as above, zero further explanation.
    > A g-method that estimates treatment effects by directly modelling how much a patient's observed outcome would have differed had their treatment history been different, solved through an iterative search.

57. **Two-way fixed effects (TWFE)** — §15.7. Mechanism never explained as a concept, even while its failure mode (staggered-adoption bias) is discussed in detail.
    > A regression that includes a separate adjustment term for every unit and every time period, so each comparison is effectively made relative to that unit's own average and that period's own average — the traditional way of running difference-in-differences with more than two groups/periods.

58. **ICH E9(R1) estimand strategies + intercurrent events** — §15.5 agency-note. Listed by name only, parenthetically.
    > Intercurrent events are things that happen after treatment starts that complicate measuring the "treatment effect" (e.g. switching treatment, dropping out). The ICH E9(R1) framework offers several official strategies for handling them when defining exactly what question a trial is answering.

---

## Chapter 16 — Regression Models for HEOR Data

59. **Exponential family** — §16.1. Named as the organizing concept behind GLMs, examples listed, never explained.
    > A family of probability distributions (including the normal, binomial, Poisson and gamma) that share a common mathematical form, which is what allows them all to be fitted using the same GLM machinery in R.

60. **Residual deviance / degrees of freedom** — §16.3, pitfall box. Used as a ready-made diagnostic rule.
    > Residual deviance is a measure of how poorly the model's predictions fit the observed data (lower is better); degrees of freedom is roughly the number of observations minus the number of parameters estimated. Dividing one by the other gives a rough overdispersion check.

61. **Type I error** — §16.3, pitfall box. Used as shorthand.
    > A "false positive" — concluding there is a real treatment effect (or difference) when in fact there isn't one.

62. **DAG (directed acyclic graph)** — §16.6. Referenced as a tool from Ch.15, never described within Ch.16-21.
    > A diagram with arrows showing assumed cause-and-effect relationships between variables, used to reason about confounding and which variables need adjusting for.

63. **Brant-type test** — §16.4, pitfall box. Named as the standard formal check, no description of mechanism.
    > A statistical test that checks whether the proportional-odds assumption holds — whether a predictor's effect is really the same across every cut-point of an ordinal outcome.

## Chapter 17 — Principles of Decision Modelling

64. **Wilson interval (Wilson score interval)** — §17.4, pitfall box. No description of what distinguishes it from the normal approximation used in the worked example.
    > A method for calculating a confidence interval around a proportion that behaves better than the simple normal approximation when the proportion is close to 0 or 1, or the sample size is small.

## Chapter 18 — Decision Trees

65. **R6 class / R6-class objects** — §18.3, recurs in Ch.21 §21.6. Used as if the reader already knows R's R6 object system.
    > R6 is an R package/system for object-oriented programming, where "objects" bundle together data and the functions (methods) that act on it — e.g. a tree's nodes know their own properties and can be asked to evaluate themselves, rather than everything living in a plain data frame.

## Chapter 19 — Markov Cohort Models

66. **Conjugate posterior** — §19.8. Used twice to justify why Beta/Dirichlet are natural choices, concept itself never explained.
    > In Bayesian statistics, a "conjugate" distribution is one where combining a starting assumption (prior) with observed data gives back an updated distribution (posterior) of the same mathematical family — why Beta and Dirichlet pair neatly with binomial/multinomial data.

## Chapter 21 — Individual-Level State-Transition Models (Microsimulation)

67. **Law of large numbers** — §21.4. Invoked to justify why more simulated patients reduces noise, principle itself not described.
    > A basic statistical principle stating that as you average over more random trials, the average result gets closer to the "true" expected value — why simulating more patients per PSA draw shrinks random noise but doesn't change genuine parameter uncertainty.

*(Chapter 20 — Partitioned Survival Models — had zero genuine gaps found.)*

---

## Observations

- **Densest cluster by far**: Chapters 11-15 (meta-analysis, NMA, population-adjusted ITCs,
  Bayesian methods, causal inference) — 28 of the 70 terms. Within that, Ch.15's g-methods/IV/
  estimands section and Ch.11's diagnostic-accuracy section are the two worst offenders.
- **Best-disciplined chapters**: Ch.13 (MAIC) and Ch.14 (Bayesian methods) were comparatively
  well self-explained despite being dense subjects, likely because both lean heavily on worked
  numeric examples that ground the jargon. Ch.16-21 (regression, decision modelling) were the
  most disciplined block overall — those chapters already define their own core mechanics well
  (tunnel states, Dirichlet/Cholesky, clock-forward/reset, half-cycle correction, common random
  numbers, zero-inflation vs. hurdle all checked and found properly explained).
- **A naming collision worth fixing regardless of the glossary decision**: in Ch.11, "ML" is used
  to mean maximum-likelihood τ² estimation, while the book's own abbreviations list defines ML as
  Machine Learning — worth a disambiguating footnote wherever it recurs.
- **Two terms recur across chapters** and would only need defining once if added to a running
  glossary: R6 classes (Ch.18 and Ch.21), and ICH E9(R1) intercurrent-event strategies (Ch.7 and
  Ch.15, described with slightly different framing each time — a shared definition would also
  remove that duplication).

## Options going forward (not yet actioned — awaiting your call)

1. **Do nothing / leave as-is** — the book already explains its load-bearing concepts; these are
   secondary/supporting terms a motivated reader can look up.
2. **Add a running Glossary** (new front-matter section, like `abbreviations.typ` but for
   concepts) — lowest-effort, keeps chapter prose untouched, reader flips to the back when stuck.
3. **Inline footnote/gloss at first use** — higher effort (touches 21 chapter files), but keeps
   definitions where the reader actually needs them.
4. Some combination: glossary for the ~15-20 terms that recur or are foundational (hazard
   function, posterior distribution, conjugate posterior, DAG, exchangeability, etc.), leave the
   rest as one-off citations/footnotes only where they appear.
