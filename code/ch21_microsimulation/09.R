# Extracted from ch21_microsimulation.typ, lines 272-320
# Section: == 21.7 Worked example: a screening programme
# Chapter: 21

set.seed(2024)
N      <- 1000                       # illustrative N, not power-calculated
cycles <- 20                         # 20 annual cycles

# Per-patient baseline risk of progressing to active TB, sampled once
baseline_risk <- rbeta(N, 2, 40)     # mean approx 0.048 per cycle

# Shared random draws, reused identically across both strategies (CRN)
u_progress <- matrix(runif(N * cycles), nrow = N)   # progression draws
u_present  <- matrix(runif(N * cycles), nrow = N)   # self-presentation draws
u_screen   <- matrix(runif(N * cycles), nrow = N)   # screening-detection draws

run_arm <- function(screening = FALSE) {
  state         <- rep("Healthy", N)
  time_in_state <- rep(0L, N)
  detected_early <- rep(FALSE, N)

  for (t in 1:cycles) {
    undetected <- state == "Undetected TB"

    # Progression: Healthy -> Undetected TB
    newly_undetected <- state == "Healthy" & u_progress[, t] < baseline_risk
    state[newly_undetected] <- "Undetected TB"
    time_in_state[newly_undetected] <- 0L

    # Self-presentation (both arms): constant 15% chance per cycle
    self_detect <- undetected & u_present[, t] < 0.15

    # Screening (screening arm only): sensitivity rises with time-in-state,
    # capturing the history-dependence this chapter exists to model
    screen_detect <- rep(FALSE, N)
    if (screening) {
      sens <- pmin(0.1 + 0.08 * time_in_state, 0.8)
      screen_detect <- undetected & !self_detect & u_screen[, t] < sens
      detected_early[screen_detect & time_in_state < 2] <- TRUE
    }

    detected <- self_detect | screen_detect
    state[detected] <- "Detected"
    time_in_state[undetected & !detected] <-
      time_in_state[undetected & !detected] + 1L
  }
  list(state = state, detected_early = detected_early)
}

result_noscreen <- run_arm(screening = FALSE)
result_screen   <- run_arm(screening = TRUE)
