# Extracted from ch05_data_sources.typ, lines 333-349
# Section: === Public and institutional APIs
# Chapter: 5

library(httr2)
library(jsonlite)

# Example: WHO Global Health Observatory API (public, no key required)
resp <- request("https://ghoapi.azureedge.net/api") |>
  req_url_path_append("TB_e_inc_num") |>   # TB incidence indicator code
  req_url_query(`$filter` = "SpatialDim eq 'IND'") |>
  req_perform()

resp_check_status(resp)   # raises an informative error on 4xx/5xx

tb_incidence <- resp |>
  resp_body_json(simplifyVector = TRUE)

tb_incidence_df <- tb_incidence$value   # the JSON payload's tabular "value" array
