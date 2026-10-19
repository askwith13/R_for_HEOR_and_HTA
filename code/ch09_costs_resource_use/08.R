# Extracted from ch09_costs_resource_use.typ, lines 246-263
# Section: === Two-part (hurdle-style) models for zero-inflated costs
# Chapter: 9

tb_costs <- tb_costs |> mutate(any_cost = as.integer(cost > 0))

# Part 1: probability of incurring any cost at all
part1 <- glm(any_cost ~ regimen + age, family = binomial(link = "logit"), data = tb_costs)

# Part 2: conditional mean cost, among those with cost > 0
part2 <- glm(cost ~ regimen + age, family = Gamma(link = "log"),
             data = tb_costs |> filter(cost > 0))

# Combine: predicted mean cost = P(cost>0) * E[cost | cost>0]
newdat <- newdat |> mutate(
  p_positive   = predict(part1, newdata = newdat, type = "response"),
  cond_mean    = predict(part2, newdata = newdat, type = "response"),
  pred_mean    = p_positive * cond_mean
)
newdat
