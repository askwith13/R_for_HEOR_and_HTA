# Extracted from ch21_microsimulation.typ, lines 85-97
# Section: == 21.3 Efficient implementation: vectorisation, data.table, parallel computing
# Chapter: 21

# Naive: one iteration of overhead per patient, per cycle
for (p in 1:n_patients) {
  if (state[p] == "sick" && runif(1) < p_death[p]) {
    state[p] <- "dead"
  }
}

# Vectorised: one operation covers all patients at once
alive_sick <- state == "sick"
dies_this_cycle <- alive_sick & (runif(n_patients) < p_death)
state[dies_this_cycle] <- "dead"
