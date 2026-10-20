# Extracted from ch35_case_studies.typ, lines 172-191
# Section: === Step (e): probabilistic sensitivity analysis
# Chapter: 35

library(ggplot2)

psa_df <- as.data.frame(psa)
ggplot(psa_df, aes(x = inc_qaly, y = inc_cost)) +
  geom_point(alpha = 0.3, colour = "steelblue") +
  geom_abline(slope = 50000, intercept = 0, linetype = "dashed") +
  labs(x = "Incremental QALYs", y = "Incremental cost",
       title = "Cost-effectiveness plane: add-on therapy vs SoC") +
  theme_minimal()

wtp_grid <- seq(0, 150000, by = 5000)
ceac <- sapply(wtp_grid, function(w) mean(w * psa_df$inc_qaly - psa_df$inc_cost > 0))

ggplot(data.frame(wtp = wtp_grid, p_ce = ceac), aes(wtp, p_ce)) +
  geom_line(colour = "darkred") +
  labs(x = "Willingness-to-pay per QALY", y = "Probability cost-effective",
       title = "Cost-effectiveness acceptability curve") +
  theme_minimal()
