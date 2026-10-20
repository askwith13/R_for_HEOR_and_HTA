# Extracted from ch25_handling_uncertainty.typ, lines 603-623
# Section: == 25.5 Visualising uncertainty: CE plane, CEAC, CEAF, NMB distributions
# Chapter: 25

# Illustrative 3-strategy CEAF sketch: psa_wide has one row per PSA iteration and
# one delta_qaly_X/delta_cost_X pair of columns per strategy X (vs a common reference)
strategies <- c("StandardRegimen", "ShortRegimen", "NewRegimenB")

ceaf_long <- do.call(rbind, lapply(wtp_grid, function(k) {
  nmb <- sapply(strategies, function(s) {
    mean(k * psa_wide[[paste0("delta_qaly_", s)]] - psa_wide[[paste0("delta_cost_", s)]] > 0)
  })
  data.frame(wtp = k, strategy = strategies, prob_best = nmb,
             is_frontier = nmb == max(nmb))
}))

ggplot(ceaf_long, aes(x = wtp, y = prob_best, colour = strategy)) +
  geom_line(alpha = 0.3) +                                   # each strategy's own CEAC, faint
  geom_line(data = subset(ceaf_long, is_frontier),
            aes(group = 1), colour = "black", linewidth = 1.2) +  # the frontier itself, bold
  labs(x = "Willingness-to-pay threshold ($/QALY)", y = "Probability most cost-effective",
       title = "Cost-effectiveness acceptability frontier (CEAF)") +
  theme_minimal()
