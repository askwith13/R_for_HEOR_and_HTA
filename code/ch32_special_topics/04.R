# Extracted from ch32_special_topics.typ, lines 260-296
# Section: == 32.6 Gene and cell therapies and outcome-based agreements
# Chapter: 32

# Illustrative, hypothetical durability/waning-of-effect parameterisation
# for a one-time gene therapy's "cured"/remission state. NOT real trial data.
library(dplyr)

cycles <- 0:40                      # 40 six-month cycles = 20 years
waning_start_cycle <- 10            # waning assumed to begin at year 5

# Three competing structural assumptions for the post-waning relapse hazard
durability_scenarios <- tibble::tibble(
  cycle = rep(cycles, times = 3),
  scenario = rep(c("durable_forever", "constant_waning", "accelerating_waning"),
                  each = length(cycles))
) %>%
  mutate(
    relapse_hazard = case_when(
      scenario == "durable_forever"                         ~ 0,
      scenario == "constant_waning" & cycle < waning_start_cycle   ~ 0,
      scenario == "constant_waning" & cycle >= waning_start_cycle  ~ 0.01,
      scenario == "accelerating_waning" & cycle < waning_start_cycle ~ 0,
      scenario == "accelerating_waning" & cycle >= waning_start_cycle ~
        0.005 * (cycle - waning_start_cycle + 1)
    )
  )

# Convert each scenario's hazard sequence into cumulative probability
# of remaining relapse-free by each cycle (discrete-time survival)
durability_scenarios <- durability_scenarios %>%
  group_by(scenario) %>%
  mutate(remain_relapse_free = cumprod(1 - relapse_hazard)) %>%
  ungroup()

durability_scenarios %>%
  filter(cycle %in% c(0, 10, 20, 30, 40)) %>%
  select(scenario, cycle, relapse_hazard, remain_relapse_free) %>%
  arrange(scenario, cycle)
