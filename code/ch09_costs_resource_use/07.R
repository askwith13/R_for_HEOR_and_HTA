# Extracted from ch09_costs_resource_use.typ, lines 206-225
# Section: === Generalised linear models on the cost scale
# Chapter: 9

# Restrict to patients with cost > 0 for the gamma GLM
pos_costs <- tb_costs |> filter(cost > 0)

fit_gamma <- glm(
  cost ~ regimen + age,
  family = Gamma(link = "log"),
  data   = pos_costs
)

summary(fit_gamma)

# Contrast against naive OLS on the same (untransformed) scale
fit_ols <- lm(cost ~ regimen + age, data = pos_costs)

# Compare predicted mean cost for the MDR regimen at mean age
newdat <- tibble(regimen = c("first_line", "mdr_regimen"), age = mean(pos_costs$age))
predict(fit_gamma, newdata = newdat, type = "response")
predict(fit_ols,   newdata = newdat)
