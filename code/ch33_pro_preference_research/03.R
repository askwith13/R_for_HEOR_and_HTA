# Extracted from ch33_pro_preference_research.typ, lines 169-191
# Section: === A simple distribution-based MCID and responder analysis in R
# Chapter: 33

set.seed(123)
n <- 200

# Simulated baseline and follow-up PRO scores (e.g. a 0-100 symptom scale,
# higher is better) for a treatment arm
baseline  <- rnorm(n, mean = 55, sd = 12)
treatment_effect <- rnorm(n, mean = 6, sd = 10)  # patient-level change
follow_up <- baseline + treatment_effect

pro_df <- data.frame(baseline = baseline, follow_up = follow_up)
pro_df$change <- pro_df$follow_up - pro_df$baseline

# Distribution-based MCID: 0.5 x baseline SD
baseline_sd <- sd(pro_df$baseline)
mcid_distribution <- 0.5 * baseline_sd
cat(sprintf("Distribution-based MCID estimate: %.2f points\n", mcid_distribution))

# Responder analysis: proportion of patients exceeding the MCID threshold
pro_df$responder <- pro_df$change >= mcid_distribution
responder_rate <- mean(pro_df$responder)
cat(sprintf("Responder rate (change >= MCID): %.1f%%\n", responder_rate * 100))
