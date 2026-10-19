# Extracted from ch04_core_concepts.typ, lines 331-337
# Section: == 4.8 Coding a first simple CEA in R
# Chapter: 4

# Step 2: rank treatments from cheapest to most expensive --------------
ranked <- treatments |>
  arrange(cost)

ranked
