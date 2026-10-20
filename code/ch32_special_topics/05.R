# Extracted from ch32_special_topics.typ, lines 324-347
# Section: == 32.7 Infectious diseases and TB: programmatic and cascade-of-care models
# Chapter: 32

# Illustrative TB cascade-of-care attrition, feeding a Markov cohort's
# starting distribution. Stage probabilities are hypothetical/illustrative,
# not real country-level TB programme data.
library(dplyr)

cascade <- tibble::tibble(
  stage = c("symptomatic_presumptive_tb",
            "diagnosed",
            "initiated_treatment",
            "completed_treatment",
            "bacteriologically_cured"),
  # Probability of REACHING this stage, CONDITIONAL on having reached
  # the previous stage -- not an absolute population-level probability.
  conditional_prob = c(1.00,   # everyone starts as presumptive (by definition)
                        0.70,  # 70% of presumptive TB cases get correctly diagnosed
                        0.85,  # 85% of those diagnosed actually start treatment
                        0.80,  # 80% of those who start complete the full course
                        0.90)  # 90% of completers are confirmed bacteriologically cured
) %>%
  mutate(cumulative_prob = cumprod(conditional_prob))

cascade
