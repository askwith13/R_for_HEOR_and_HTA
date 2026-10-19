# Extracted from ch22_des_dynamic_models.typ, lines 117-153
# Section: == 22.3 Competing events and time-to-event sampling
# Chapter: 22

library(simmer)
set.seed(2024)

# three competing hazards for a screened patient, in events per day:
#   default clinical pathway completion : rate 1/14
#   loss to follow-up                   : rate 1/60
#   self-referral to another provider   : rate 1/90

sample_next_event <- function() {
  times <- c(
    complete = rexp(1, rate = 1 / 14),
    ltfu     = rexp(1, rate = 1 / 60),
    referral = rexp(1, rate = 1 / 90)
  )
  list(event = names(times)[which.min(times)], time = min(times))
}

env <- simmer("competing_pathway_sim")

race_result <- NULL   # closure-captured slot holding the single resolved race per entity

patient <- trajectory("competing pathway") %>%
  set_attribute("outcome_code", function() {
    # resolve the race exactly ONCE per entity and remember both pieces
    race_result <<- sample_next_event()
    c(complete = 1, ltfu = 2, referral = 3)[[race_result$event]]
  }) %>%
  timeout(function() race_result$time) %>%   # reuse the time already resolved above, no resampling
  branch(
    function() get_attribute(env, "outcome_code"),
    continue = c(TRUE, TRUE, TRUE),
    trajectory("completed")  %>% timeout(0),
    trajectory("ltfu")       %>% timeout(0),
    trajectory("referred")   %>% timeout(0)
  )
