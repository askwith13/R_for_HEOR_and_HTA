# Extracted from ch25_handling_uncertainty.typ, lines 470-496
# Section: == 25.4 Probabilistic sensitivity analysis: choosing distributions
# Chapter: 25

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
