# Extracted from ch21_microsimulation.typ, lines 224-232
# Section: == 21.6 Using `hesim` for individual-level models
# Chapter: 21

trans_model <- create_IndivCtstmTrans(
  params     = tb_params,
  input_data = input_data,
  trans_mat  = tmat,
  clock      = "reset",
  start_age  = input_data$age
)
