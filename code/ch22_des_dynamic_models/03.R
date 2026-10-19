# Extracted from ch22_des_dynamic_models.typ, lines 159-168
# Section: == 22.3 Competing events and time-to-event sampling
# Chapter: 22

patient_simple <- trajectory("simple triage") %>%
  branch(
    function() sample(1:3, 1, prob = c(0.7, 0.2, 0.1)),
    continue = c(TRUE, TRUE, TRUE),
    trajectory("screened")   %>% seize("nurse") %>% timeout(8) %>% release("nurse"),
    trajectory("ltfu")       %>% timeout(0),
    trajectory("referred")   %>% timeout(0)
  )
