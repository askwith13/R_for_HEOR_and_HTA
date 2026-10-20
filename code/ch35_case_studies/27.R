# Extracted from ch35_case_studies.typ, lines 872-891
# Section: === Cascade-of-care structure: standard of care vs. active case-finding
# Chapter: 35

set.seed(5803)

cohort_n <- 100000  # district population covered by the analysis

# Standard of care (SOC): passive case detection cascade
prev_active_tb_soc        <- 0.006  # active TB prevalence in the population
frac_self_present         <- 0.55   # symptomatic cases who self-present
frac_tested_given_present <- 0.92
frac_diag_given_tested    <- 0.85
frac_initiate_given_diag  <- 0.90
frac_complete_given_init  <- 0.80

soc_active_cases <- cohort_n * prev_active_tb_soc
soc_presenting   <- soc_active_cases * frac_self_present
soc_tested       <- soc_presenting * frac_tested_given_present
soc_diagnosed    <- soc_tested * frac_diag_given_tested
soc_initiated    <- soc_diagnosed * frac_initiate_given_diag
soc_completed    <- soc_initiated * frac_complete_given_init
