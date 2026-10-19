# Extracted from ch05_data_sources.typ, lines 400-404
# Section: === Public and institutional APIs
# Chapter: 5

resp <- request("https://api.example-registry.org/v1/indicators") |>
  req_headers(Authorization = paste("Bearer", Sys.getenv("REGISTRY_API_KEY"))) |>
  req_perform()
