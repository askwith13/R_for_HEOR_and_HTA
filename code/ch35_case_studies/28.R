# Extracted from ch35_case_studies.typ, lines 897-915
# Section: === Cascade-of-care structure: standard of care vs. active case-finding
# Chapter: 35

# Active case-finding (ACF), added on top of SOC, targeting non-presenters
frac_acf_screened              <- 0.70
frac_acf_tested_given_screened <- 0.95
frac_diag_given_acf_tested     <- 0.85
frac_initiate_given_acf_diag   <- 0.90
frac_complete_given_acf_init   <- 0.82  # ACF-linked adherence support

soc_non_presenting <- soc_active_cases - soc_presenting
acf_screened  <- soc_non_presenting * frac_acf_screened
acf_tested    <- acf_screened * frac_acf_tested_given_screened
acf_diagnosed <- acf_tested * frac_diag_given_acf_tested
acf_initiated <- acf_diagnosed * frac_initiate_given_acf_diag
acf_completed <- acf_initiated * frac_complete_given_acf_init

int_diagnosed <- soc_diagnosed + acf_diagnosed
int_initiated <- soc_initiated + acf_initiated
int_completed <- soc_completed + acf_completed
