# Extracted from ch03_r_essentials.typ, lines 222-228
# Section: == 3.4 Writing functions, parameter lists and defensive programming
# Chapter: 3

# Fragile: positional arguments, easy to transpose by mistake
run_model <- function(p_progress, p_death, cost_well, cost_sick,
                       util_well, util_sick, discount_rate, horizon) {
  # ...
}
