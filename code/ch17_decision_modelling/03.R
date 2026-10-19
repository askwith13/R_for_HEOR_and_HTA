# Extracted from ch17_decision_modelling.typ, lines 220-257
# Section: == 17.6 Modelling workflow in R: inputs -> engine -> outputs -> reporting
# Chapter: 17

# --- inputs layer ---------------------------------------------------
params <- list(
  strategies = c("Regimen_A", "Regimen_B"),
  cost_drug  = c(Regimen_A = 450, Regimen_B = 980),   # per course, local currency
  p_cure     = c(Regimen_A = 0.86, Regimen_B = 0.91),
  qaly_cured = 1.0,
  qaly_fail  = 0.6
)

# --- engine layer ----------------------------------------------------
# Generic signature only -- the real decision-tree / Markov mechanics
# live in Chapters 18-22. Here the engine is a stand-in.
run_model <- function(params) {
  tibble::tibble(
    strategy    = params$strategies,
    total_cost  = params$cost_drug[params$strategies],
    total_qaly  = params$p_cure[params$strategies] * params$qaly_cured +
                   (1 - params$p_cure[params$strategies]) * params$qaly_fail
  )
}

engine_out <- run_model(params)

# --- results layer -----------------------------------------------------
# ICER and NMB formulas: see Section 4.4. Not re-derived here.
results <- engine_out |>
  dplyr::arrange(total_cost) |>
  dplyr::mutate(
    inc_cost  = total_cost - dplyr::first(total_cost),
    inc_qaly  = total_qaly - dplyr::first(total_qaly),
    icer      = inc_cost / inc_qaly,
    nmb       = total_qaly * 20000 - total_cost   # threshold = 20,000/QALY
  )

# --- reporting layer -----------------------------------------------------
# Tables, plots, narrative -- see Chapter 28 (Reproducible Reporting).
