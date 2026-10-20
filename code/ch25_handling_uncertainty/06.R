# Extracted from ch25_handling_uncertainty.typ, lines 366-394
# Section: == 25.3 Scenario analysis scripts
# Chapter: 25

# Generic scenario-analysis engine: works with ANY model_fun(params) -> named vector
run_scenarios <- function(base_params, scenario_overrides, model_fun) {
  out <- lapply(names(scenario_overrides), function(nm) {
    p   <- modifyList(base_params, scenario_overrides[[nm]])  # override only the named cells
    res <- model_fun(p)
    data.frame(scenario = nm, as.list(res))
  })
  do.call(rbind, out)
}

base_params <- list(
  p_ontx_cure = 0.75, p_ontx_fail = 0.08, p_ontx_death = 0.02,
  p_fail_retreat = 0.60, p_fail_death = 0.15, p_cured_death = 0.01,
  cost_ontx = 500, cost_cured = 50, cost_fail = 800,
  u_ontx = 0.65, u_cured = 0.90, u_fail = 0.50
)

scenarios <- list(
  "Optimistic"  = list(p_ontx_cure = 0.85, p_ontx_fail = 0.05,
                        p_ontx_death = 0.01, cost_fail = 600),
  "Base case"   = list(),                       # empty override = pure base case
  "Pessimistic" = list(p_ontx_cure = 0.65, p_ontx_fail = 0.15,
                        p_ontx_death = 0.03, cost_fail = 1200)
)

scenario_results <- run_scenarios(base_params, scenarios, run_tb_model)
print(scenario_results)
