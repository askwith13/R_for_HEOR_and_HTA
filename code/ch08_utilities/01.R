# Extracted from ch08_utilities.typ, lines 38-58
# Section: == 8.2 Value sets and scoring in R (eq5d)
# Chapter: 8

library(eq5d)

# Toy EQ-5D-5L health state profiles: one row per patient,
# one column per dimension (mobility, self-care, usual activities,
# pain/discomfort, anxiety/depression), each scored 1-5.
health_states <- data.frame(
  MO = c(1, 2, 3),
  SC = c(1, 1, 2),
  UA = c(2, 2, 3),
  PD = c(2, 3, 4),
  AD = c(1, 2, 3)
)

# Conceptual scoring step: apply a named country value set to convert
# each row's digit profile into a utility index anchored at 1 = full
# health, 0 = dead. Consult ?eq5d in your installed version for the
# exact argument names/spelling before running this on real data.
# utilities <- eq5d(scores = health_states, version = "5L", country = "UK")
# utilities
