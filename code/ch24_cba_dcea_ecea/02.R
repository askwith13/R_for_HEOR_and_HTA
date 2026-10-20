# Extracted from ch24_cba_dcea_ecea.typ, lines 501-551
# Section: == 24.3 Extended cost-effectiveness analysis: financial risk protection
# Chapter: 24

library(dplyr)

ecea_frp <- function(
    quintile_income_bands = list(
      Q1 = c(300, 700),    Q2 = c(700, 1100),  Q3 = c(1100, 1700),
      Q4 = c(1700, 2700),  Q5 = c(2700, 5300)
    ),
    pop_per_quintile = 20000,
    oop_status_quo   = 150,   # $ per TB episode, status quo
    oop_new_policy    = 20,   # $ per TB episode, after universal public finance
    che_threshold     = 0.10, # 10% of income convention
    poverty_line      = 400   # $ per year
) {
  che_income_cutoff <- function(oop) oop / che_threshold

  frac_below <- function(cutoff, lo, hi) {
    pmax(0, pmin(1, (cutoff - lo) / (hi - lo)))
  }
  frac_in_interval <- function(lo, hi, a, b) {
    left  <- max(lo, a); right <- max(min(hi, b), left)
    (right - left) / (hi - lo)
  }

  bands <- tibble(
    quintile = names(quintile_income_bands),
    income_lo = sapply(quintile_income_bands, `[`, 1),
    income_hi = sapply(quintile_income_bands, `[`, 2)
  )

  thresh_sq  <- che_income_cutoff(oop_status_quo)
  thresh_new <- che_income_cutoff(oop_new_policy)

  bands %>%
    mutate(
      che_cases_sq    = frac_below(thresh_sq,  income_lo, income_hi) * pop_per_quintile,
      che_cases_new   = frac_below(thresh_new, income_lo, income_hi) * pop_per_quintile,
      che_averted     = che_cases_sq - che_cases_new,
      pov_cases_sq    = frac_in_interval(income_lo, income_hi,
                                          poverty_line, poverty_line + oop_status_quo) * pop_per_quintile,
      pov_cases_new   = frac_in_interval(income_lo, income_hi,
                                          poverty_line, poverty_line + oop_new_policy) * pop_per_quintile,
      pov_averted     = pov_cases_sq - pov_cases_new
    ) %>%
    select(quintile, che_cases_sq, che_cases_new, che_averted,
           pov_cases_sq, pov_cases_new, pov_averted)
}

frp_result <- ecea_frp()
frp_result
