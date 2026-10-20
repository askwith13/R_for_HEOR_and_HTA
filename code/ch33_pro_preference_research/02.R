# Extracted from ch33_pro_preference_research.typ, lines 94-118
# Section: === Item response theory with `mirt`
# Chapter: 33

library(mirt)

set.seed(7)
n <- 400
n_items <- 5

# One latent trait ("mobility limitation") with items of varying
# difficulty and discrimination, generating binary (yes/no) responses
theta        <- rnorm(n)
difficulty   <- c(-1.5, -0.5, 0, 0.5, 1.5)
discrim      <- c(0.8, 1.2, 1.5, 1.0, 0.9)

binary_items <- sapply(seq_len(n_items), function(j) {
  p <- plogis(discrim[j] * (theta - difficulty[j]))
  rbinom(n, 1, p)
})
colnames(binary_items) <- paste0("item", seq_len(n_items))

irt_fit <- mirt(data = as.data.frame(binary_items), model = 1,
                 itemtype = "2PL")

coef(irt_fit, simplify = TRUE)
itemplot(irt_fit, item = 1)
