# Extracted from ch14_bayesian_methods.typ, lines 80-97
# Section: == 14.2 Priors: informative, weakly informative and vague priors
# Chapter: 14

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
