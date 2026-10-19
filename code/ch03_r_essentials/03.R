# Extracted from ch03_r_essentials.typ, lines 53-63
# Section: == 3.1 Data structures: vectors, lists, data frames and tibbles, arrays and matrices
# Chapter: 3

  states <- c("Healthy", "Sick", "Dead")
  tm <- matrix(
    c(0.80, 0.15, 0.05,
      0.00, 0.70, 0.30,
      0.00, 0.00, 1.00),
    nrow = 3, byrow = TRUE,
    dimnames = list(states, states)
  )
  rowSums(tm)  # should equal 1 for every row
  