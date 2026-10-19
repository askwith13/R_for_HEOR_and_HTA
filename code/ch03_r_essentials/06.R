# Extracted from ch03_r_essentials.typ, lines 133-146
# Section: == 3.3 Functional programming with `purrr` and vectorization
# Chapter: 3

n_patients <- 1000
cost_per_visit <- rep(185.50, n_patients)
n_visits <- sample(1:12, n_patients, replace = TRUE)

# Avoid: explicit loop
total_cost_loop <- numeric(n_patients)
for (i in seq_len(n_patients)) {
  total_cost_loop[i] <- cost_per_visit[i] * n_visits[i]
}

# Prefer: vectorized
total_cost_vec <- cost_per_visit * n_visits
