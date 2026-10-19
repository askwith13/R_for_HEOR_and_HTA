# Extracted from ch05_data_sources.typ, lines 317-323
# Section: === Databases with `DBI`
# Chapter: 5

dbGetQuery(
  con,
  "SELECT * FROM claims.inpatient_episodes WHERE patient_id = $1",
  params = list("PT-00482")
)
