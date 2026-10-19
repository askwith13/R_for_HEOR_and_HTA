# Extracted from ch22_des_dynamic_models.typ, lines 71-95
# Section: == 22.2 DES with `simmer`
# Chapter: 22

library(simmer)
set.seed(2024)

# average inter-arrival time = 10 minutes -> arrival rate lambda = 1/10
# average screening time     =  8 minutes -> service rate  mu    = 1/8

patient <- trajectory("TB screening") %>%
  seize("nurse", amount = 1) %>%
  timeout(function() rexp(1, rate = 1 / 8)) %>%
  release("nurse", amount = 1)

clinic <- simmer("tb_clinic") %>%
  add_resource("nurse", capacity = 1, queue_size = Inf) %>%
  add_generator("patient", patient, function() rexp(1, rate = 1 / 10))

clinic %>% run(until = 8 * 60 * 20)   # simulate 20 clinic-days of 8 hours each

arrivals  <- get_mon_arrivals(clinic)
resources <- get_mon_resources(clinic)

arrivals$waiting_time <- arrivals$end_time - arrivals$start_time - arrivals$activity_time
mean(arrivals$waiting_time)   # average minutes spent queueing for the nurse
mean(resources$server)        # fraction of time the nurse resource is occupied
