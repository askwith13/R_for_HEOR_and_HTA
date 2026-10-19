# Extracted from ch08_utilities.typ, lines 174-190
# Section: == 8.5 Utility decrements, age-adjusted utilities and background mortality
# Chapter: 8

# toy age-band utility multipliers (illustrative, not a real norm dataset)
age_norms <- data.frame(
  age_band = c("18-44", "45-54", "55-64", "65-74", "75+"),
  norm_utility = c(0.93, 0.88, 0.83, 0.78, 0.72)
)

baseline_disease_utility <- 0.80   # disease-specific utility at trial baseline age
baseline_norm <- age_norms$norm_utility[age_norms$age_band == "45-54"]

age_adjust <- function(age_band, disease_utility = baseline_disease_utility) {
  norm_now <- age_norms$norm_utility[age_norms$age_band == age_band]
  disease_utility * (norm_now / baseline_norm)
}

sapply(age_norms$age_band, age_adjust)
