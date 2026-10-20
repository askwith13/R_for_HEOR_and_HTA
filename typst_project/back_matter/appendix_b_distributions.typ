#import "../common.typ": *

= Appendix B. Statistical Distributions Commonly Used in HEOR

Two genuinely different families of distribution appear throughout this book, and it is worth separating them clearly before using this appendix as a lookup table: distributions used to characterise *parameter uncertainty* in a probabilistic sensitivity analysis (Chapter 25), and distributions used to describe the *shape of a survival/hazard curve* for extrapolation (Chapter 10). The same distribution name occasionally appears in both roles (lognormal, Gamma) but is doing a structurally different job each time.

== Distributions for probabilistic sensitivity analysis (PSA)

Chapter 25's central practical question for any model parameter is: given a point estimate and some measure of its precision (a standard error, a confidence interval, or raw success/failure counts), which distribution should be sampled from to propagate that parameter's uncertainty through the model?

#ref-table(
  [PSA distribution choice by HEOR parameter type (Chapter 19 §19.8, Chapter 25 §25.3-25.4)],
  academic-table(
    columns: (1.6fr, 1.2fr, 2.2fr),
    align: (left, left, left),
    header: ([Parameter type], [Distribution], [Why / how parameterised]),
    body: (
      [Single probability or proportion], [Beta$(a, b)$], [Bounded support $[0,1]$ by construction. $a$ and $b$ can be read directly as success/failure pseudo-counts when raw trial counts are available, or derived from a point estimate and standard error via the method of moments.],
      [Whole transition-matrix row], [Dirichlet$(alpha_1, ..., alpha_k)$], [The multivariate generalisation of Beta -- draws across the $k$ destination states sum to exactly 1 by construction, respecting the row-sums-to-1 constraint a set of independent per-cell Betas would silently break. Parameterised by a vector of pseudo-counts, one per destination state.],
      [Cost], [Gamma or lognormal], [Non-negative, right-skewed support matching empirical cost data. Gamma is more common in dedicated HEOR PSA tooling (`dampack`, `heemod` templates both default to it for cost parameters) and is fully specified by mean and standard error via $"shape" = (mu/sigma)^2$, $"rate" = mu/sigma^2$. Lognormal suits a cost-generating process that is itself understood to be multiplicative, or data already analysed on the log scale.],
      [Single utility value], [Beta (occasionally normal, if values above 1 are permitted by the elicitation method)], [Bounded support matching the typical $[0,1]$ utility range, for the same reason as a probability.],
      [Relative-effect estimate (log hazard ratio, log odds ratio)], [(Multivariate) normal, usually on the log scale], [A relative-effect estimate from a trial or meta-analysis (Chapter 11) typically reports a point estimate and standard error on the log scale, where the normal approximation is most defensible; exponentiating the normal draws back to the natural (HR/OR) scale preserves the correct right-skewed shape on that scale.],
      [Correlated parameter sets (e.g. joint cost-QALY draws)], [Multivariate normal via Cholesky decomposition], [A Cholesky factorisation of the target correlation/covariance matrix, applied to a vector of independent draws, produces a new vector with the desired correlation structure built in -- the standard route to correlated PSA draws from otherwise independent random inputs (Chapter 14).],
    ),
    footer: none,
  ),
)

#heor-practice[
  Hand-check a small number of draws (5, not 2,000) from each distribution before running the full PSA loop, confirming the mean of the draws matches the intended base-case value and that the shape looks right (Beta draws stay inside $(0,1)$; Gamma/lognormal draws stay positive with visible right skew). This costs almost nothing and catches a mis-specified `shape`/`rate` or `meanlog`/`sdlog` parameterisation before it silently corrupts thousands of PSA iterations.
]

== Distributions for parametric survival extrapolation

Chapter 10 covers a different question: given observed trial follow-up that ends before most patients have experienced the event, which distributional *shape* for the hazard function is most defensible when extrapolating beyond the data?

#ref-table(
  [Standard parametric survival distributions for extrapolation (Chapter 10 §10.2)],
  academic-table(
    columns: (1.4fr, 2.4fr, 1.2fr),
    align: (left, left, left),
    header: ([Distribution], [Hazard shape], [`flexsurv` dist code]),
    body: (
      [Exponential], [Constant hazard over time -- the simplest, most restrictive assumption.], [`"exp"`],
      [Weibull], [Monotonically increasing or decreasing hazard, shape fixed by one parameter. Common for mortality worsening steadily with age or disease progression.], [`"weibull"`],
      [Gompertz], [Hazard increasing (or decreasing) exponentially with time. A long-standing default for all-cause general-population mortality extrapolation.], [`"gompertz"`],
      [Log-logistic], [Hump-shaped hazard (rises then falls) -- can capture an initial period of elevated risk followed by a declining hazard.], [`"llogis"`],
      [Log-normal], [Similar hump-shaped hazard behaviour to log-logistic, fitted on the log-time scale.], [`"lnorm"`],
      [Generalised gamma], [A flexible three-parameter family nesting exponential, Weibull, and log-normal as special cases. Useful as an umbrella comparison model, at the cost of being harder to interpret and sometimes unstable to fit with sparse data.], [`"gengamma"`],
    ),
    footer: (table.cell(colspan: 3)[NICE DSU TSD 14 and most HTA bodies expect all six of these standard fits reported (AIC/BIC tabulated side by side) with visual and clinical-plausibility justification for whichever is chosen as the base case -- lowest AIC alone is necessary but not sufficient.],),
  ),
)

#pitfall[
  A cure-model structure (Chapter 10 §10.3, Chapter 32 §32.1) is a genuinely different modelling decision from choosing among the six distributions above, not a seventh item on the same list. Every distribution in the table assumes that, eventually, every patient experiences the event -- the survival curve always keeps falling toward zero, however slowly. If the clinical reality is that a genuine fraction of patients are effectively cured and never relapse, fitting an ordinary Weibull or Gompertz curve to that data is a category error: the fitted curve will keep sliding downward long after the real data has flattened out, systematically understating long-term survival. A mixture or non-mixture cure model is the correct fix, not a different choice among the six standard families.
]
