# Extracted from ch25_handling_uncertainty.typ, lines 577-593
# Section: == 25.5 Visualising uncertainty: CE plane, CEAC, CEAF, NMB distributions
# Chapter: 25

wtp_grid <- seq(0, 100000, by = 1000)
ceac_df <- data.frame(
  wtp  = wtp_grid,
  prob_ce = sapply(wtp_grid, function(k) {
    mean(k * psa_df$delta_qaly - psa_df$delta_cost > 0)   # share of draws with positive NMB at k
  })
)

ggplot(ceac_df, aes(x = wtp, y = prob_ce)) +
  geom_line(colour = "darkgreen", linewidth = 1) +
  labs(x = "Willingness-to-pay threshold ($/QALY)",
       y = "Probability cost-effective",
       title = "Cost-effectiveness acceptability curve (CEAC)") +
  ylim(0, 1) +
  theme_minimal()
