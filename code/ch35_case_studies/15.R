# Extracted from ch35_case_studies.typ, lines 445-533
# Section: === 35.3.3 Screening strategy and full simulation engine
# Chapter: 35

p_healthy_to_lowpolyp_base   <- 0.020
p_lowpolyp_to_highpolyp_base <- 0.08
p_highpolyp_to_preclin_base  <- 0.12
p_preclin_to_clinical_base   <- 0.30   # annual risk of symptomatic presentation
p_clinical_crc_death_base    <- 0.22   # annual CRC death hazard once clinical
p_other_death_base           <- 0.012  # background (other-cause) mortality

screen_interval  <- 10
sens_polyp       <- 0.90
sens_preclin_crc <- 0.95
spec             <- 0.90

cost_screen_test    <- 450
cost_polypectomy    <- 900
cost_fp_workup      <- 350
cost_preclin_tx     <- 6000
cost_clinical_tx_yr <- 9000
disc_rate           <- 0.03

u_healthy <- 1.00; u_lowpolyp <- 0.99; u_highpolyp <- 0.97
u_preclin <- 0.90; u_clinical <- 0.68; u_dead <- 0.00

run_arm <- function(N, frailty, screening = TRUE) {
  state <- rep(1L, N); cost <- numeric(N); qaly <- numeric(N)
  alive <- rep(TRUE, N)
  early_tx_persist <- rep(FALSE, N)

  for (cyc in 1:n_cycles) {
    disc <- 1 / (1 + disc_rate)^(cyc - 1)

    # accrue utility for the cycle, for patients alive at cycle start
    util_vec <- c(u_healthy, u_lowpolyp, u_highpolyp, u_preclin, u_clinical, u_dead, u_dead)
    qaly[alive] <- qaly[alive] + util_vec[state[alive]] * disc

    early_tx_flag <- rep(FALSE, N)
    if (screening && (cyc %% screen_interval == 1)) {
      is_alive <- alive
      cost[is_alive] <- cost[is_alive] + cost_screen_test * disc

      has_lowpolyp  <- is_alive & state == 2L
      has_highpolyp <- is_alive & state == 3L
      has_preclin   <- is_alive & state == 4L
      healthy_now   <- is_alive & state == 1L

      det_low  <- has_lowpolyp  & (runif(N) < sens_polyp)
      det_high <- has_highpolyp & (runif(N) < sens_polyp)
      det_pre  <- has_preclin   & (runif(N) < sens_preclin_crc)

      state[det_low | det_high] <- 1L                      # polypectomy cures
      cost[det_low | det_high]  <- cost[det_low | det_high] + cost_polypectomy * disc

      state[det_pre] <- 5L                                 # treated early, at early-tx cost
      cost[det_pre]  <- cost[det_pre] + cost_preclin_tx * disc
      early_tx_flag  <- det_pre

      fp <- healthy_now & (runif(N) < (1 - spec))           # false positives: cost only
      cost[fp] <- cost[fp] + cost_fp_workup * disc
    }
    early_tx_persist <- early_tx_persist | early_tx_flag

    # natural-history progression, scaled by each patient's frailty
    r_h  <- p_healthy_to_lowpolyp_base   * frailty
    r_l  <- p_lowpolyp_to_highpolyp_base * frailty
    r_hp <- p_highpolyp_to_preclin_base  * frailty
    r_pc <- p_preclin_to_clinical_base
    r_cd <- ifelse(early_tx_persist, p_clinical_crc_death_base * 0.55, p_clinical_crc_death_base)

    u <- runif(N); s <- state
    trans_h  <- alive & s == 1L & u < pmin(r_h,  1)
    trans_l  <- alive & s == 2L & u < pmin(r_l,  1)
    trans_hp <- alive & s == 3L & u < pmin(r_hp, 1)
    trans_pc <- alive & s == 4L & u < pmin(r_pc, 1)
    trans_cd <- alive & s == 5L & u < pmin(r_cd, 1)

    state[trans_h] <- 2L; state[trans_l] <- 3L
    state[trans_hp] <- 4L; state[trans_pc] <- 5L

    clinical_now <- alive & state == 5L
    cost[clinical_now] <- cost[clinical_now] + cost_clinical_tx_yr * disc

    state[trans_cd] <- 6L; alive[trans_cd] <- FALSE

    die_other <- alive & (runif(N) < p_other_death_base)
    state[die_other] <- 7L; alive[die_other] <- FALSE
  }
  data.frame(cost = cost, qaly = qaly)
}
