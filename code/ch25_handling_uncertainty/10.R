# Extracted from ch25_handling_uncertainty.typ, lines 557-568
# Section: == 25.5 Visualising uncertainty: CE plane, CEAC, CEAF, NMB distributions
# Chapter: 25

wtp <- 50000  # illustrative cost-effectiveness threshold, $/QALY

ggplot(psa_df, aes(x = delta_qaly, y = delta_cost)) +
  geom_point(alpha = 0.3, colour = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_abline(intercept = 0, slope = wtp, linetype = "dotted", colour = "firebrick") +
  labs(x = "Incremental QALYs", y = "Incremental cost ($)",
       title = "Cost-effectiveness plane") +
  theme_minimal()
