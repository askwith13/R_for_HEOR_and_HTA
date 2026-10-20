# Extracted from ch25_handling_uncertainty.typ, lines 633-643
# Section: == 25.5 Visualising uncertainty: CE plane, CEAC, CEAF, NMB distributions
# Chapter: 25

k <- 50000  # same WTP threshold as the CE-plane example
psa_df$inmb <- k * psa_df$delta_qaly - psa_df$delta_cost  # incremental NMB per draw

ggplot(psa_df, aes(x = inmb)) +
  geom_histogram(bins = 40, fill = "slateblue", alpha = 0.7) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "firebrick") +
  labs(x = "Incremental net monetary benefit ($)", y = "Count of PSA draws",
       title = "Distribution of incremental NMB at WTP = $50,000/QALY") +
  theme_minimal()
