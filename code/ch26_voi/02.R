# Extracted from ch26_voi.typ, lines 280-295
# Section: == 26.2 Computing EVPI and EVPPI (BCEA, voi)
# Chapter: 26

calculate_evpi <- function(psa_results, wtp) {
  nmb_new <- wtp * psa_results[, "qaly_new"] - psa_results[, "cost_new"]
  nmb_soc <- wtp * psa_results[, "qaly_soc"] - psa_results[, "cost_soc"]

  nb_fixed_choice   <- max(mean(nmb_new), mean(nmb_soc))
  nb_perfect_info   <- mean(pmax(nmb_new, nmb_soc))

  nb_perfect_info - nb_fixed_choice
}

wtp_grid <- seq(0, 100000, by = 10000)
evpi_by_wtp <- sapply(wtp_grid, function(k) calculate_evpi(psa_results, k))

data.frame(wtp = wtp_grid, evpi = evpi_by_wtp)
