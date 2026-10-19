# Extracted from ch15_rwe_causal_inference.typ, lines 729-771
# Section: == 15.10 OHDSI/OMOP workflows in R
# Chapter: 15

library(DatabaseConnector)
library(FeatureExtraction)
library(CohortMethod)

connection_details <- createConnectionDetails(
  dbms             = "postgresql",
  server           = "cdm-server.example.org/omop_cdm",
  user             = Sys.getenv("OMOP_DB_USER"),
  password         = Sys.getenv("OMOP_DB_PASSWORD"),
  port             = 5432
)

# Define covariate settings: demographics + comorbidity history
covariate_settings <- createDefaultCovariateSettings(
  addDescendantsToExclude = TRUE
)

# Cohorts 1 (target drug) and 2 (comparator) must already exist as
# cohort_definition_id values in a cohort table built upstream
# (via ATLAS or hand-written cohort-definition SQL against OMOP tables)
cm_data <- getDbCohortMethodData(
  connectionDetails    = connection_details,
  cdmDatabaseSchema    = "omop_cdm",
  targetId             = 1,
  comparatorId         = 2,
  outcomeIds           = 3,     # e.g. treatment failure / default
  cohortDatabaseSchema = "results_schema",
  cohortTable          = "cohort",
  covariateSettings    = covariate_settings
)

ps_model <- createPs(cohortMethodData = cm_data)
matched_pop <- matchOnPs(ps_model, maxRatio = 1)

outcome_model <- fitOutcomeModel(
  population = matched_pop,
  cohortMethodData = cm_data,
  outcomeId = 3,
  modelType = "cox"
)
summary(outcome_model)
