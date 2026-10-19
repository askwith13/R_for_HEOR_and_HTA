# Extracted from ch05_data_sources.typ, lines 280-306
# Section: === Databases with `DBI`
# Chapter: 5

library(DBI)
library(RPostgres)

con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "claims_warehouse",
  host     = Sys.getenv("CLAIMS_DB_HOST"),
  port     = 5432,
  user     = Sys.getenv("CLAIMS_DB_USER"),
  password = Sys.getenv("CLAIMS_DB_PASSWORD")
)

inpatient_costs <- dbGetQuery(con, "
  SELECT
    patient_id,
    admission_date,
    discharge_date,
    diagnosis_code,
    total_charge_usd
  FROM claims.inpatient_episodes
  WHERE admission_date >= '2022-01-01'
    AND diagnosis_code LIKE 'A15%'   -- respiratory TB, ICD-10
")

dbDisconnect(con)
