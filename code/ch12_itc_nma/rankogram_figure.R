library(netmeta)
library(ggplot2)
library(tidyr)
library(dplyr)

tb_arms <- data.frame(
  study     = c("Trial1","Trial1","Trial2","Trial2",
                "Trial3","Trial3","Trial4","Trial4"),
  treatment = c("A","C","B","C","A","B","D","C"),
  events    = c(18,  34,  22,  36,  15,  19,  28,  33),
  n         = c(80,  82,  78,  80,  60,  58,  75,  77)
)

tb_pairs <- pairwise(
  treat   = treatment,
  event   = events,
  n       = n,
  studlab = study,
  data    = tb_arms,
  sm      = "OR"
)

net_tb <- netmeta(
  TE, seTE, treat1, treat2, studlab,
  data = tb_pairs,
  sm = "OR",
  common = FALSE, random = TRUE
)

set.seed(42)
rankogram_tb <- rankogram(net_tb, nsim = 10000, small.values = "good")

rm <- rankogram_tb$ranking.matrix.random
print(rm)

df <- as.data.frame(rm) |>
  mutate(treatment = rownames(rm)) |>
  pivot_longer(-treatment, names_to = "rank", values_to = "probability") |>
  mutate(
    rank = as.integer(gsub("[^0-9]", "", rank)),
    treatment = factor(treatment, levels = c("D", "A", "B", "C"))  # best-to-worst by P-score/SUCRA order
  )

treat_colors <- c(
  "A" = "#2b6cb0",  # blue
  "B" = "#c05621",  # orange
  "C" = "#2f855a",  # green
  "D" = "#805ad5"   # purple
)

p <- ggplot(df, aes(x = factor(rank), y = probability, fill = treatment)) +
  geom_col(width = 0.7) +
  facet_wrap(~treatment, nrow = 1, labeller = label_both) +
  scale_fill_manual(values = treat_colors, guide = "none") +
  labs(
    x = "Rank (1 = best, i.e. lowest odds of treatment failure)",
    y = "Probability",
    title = "Rankogram: probability each treatment occupies each rank",
    subtitle = "Frequentist NMA (netmeta), 10,000 simulated draws, random-effects model"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("/home/aswath/R_for_HEOR_and_HTA/typst_project/images/r_generated/ch12_rankogram.png",
       p, width = 11, height = 4.2, dpi = 220)

cat("\nDone.\n")
