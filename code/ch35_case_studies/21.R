# Extracted from ch35_case_studies.typ, lines 748-772
# Section: === Simulating an observational dataset with confounding
# Chapter: 35

set.seed(4702)

n <- 2400

age        <- round(rnorm(n, mean = 58, sd = 10))
bmi        <- round(rnorm(n, mean = 31, sd = 5), 1)
hba1c_base <- round(rnorm(n, mean = 8.6, sd = 1.1), 1)
egfr       <- round(rnorm(n, mean = 78, sd = 16))
cv_disease <- rbinom(n, 1, 0.22)

# Treatment assignment confounded by clinical severity and renal function
lp_treat <- -3.1 + 0.05*bmi + 0.35*hba1c_base - 0.02*age +
              0.015*egfr - 0.25*cv_disease
p_treat <- plogis(lp_treat)
treat   <- rbinom(n, 1, p_treat)

# True outcome model: SGLT2i add-on gives an additional -0.55 percentage-point
# HbA1c reduction vs. standard intensification, plus genuine covariate effects
noise <- rnorm(n, 0, 0.8)
hba1c_change <- -0.55*treat + 0.015*(hba1c_base - 8.6) -
                  0.01*bmi + 0.002*age + noise

dat <- data.frame(age, bmi, hba1c_base, egfr, cv_disease, treat, hba1c_change)
