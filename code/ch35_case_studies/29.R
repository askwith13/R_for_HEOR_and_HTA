# Extracted from ch35_case_studies.typ, lines 923-941
# Section: === Costs and outcomes
# Chapter: 35

cost_acf_screen_per_person <- 3.2    # per person screened door-to-door
cost_test_xpert            <- 14.0   # per Xpert test performed
cost_tx_per_initiation     <- 95.0   # full first-line course, per patient initiating
cost_tx_completion_support <- 18.0   # ACF-linked adherence support, per ACF completer
cost_untreated_case        <- 150.0  # excess downstream cost per uncompleted case

soc_cost <- soc_tested*cost_test_xpert + soc_initiated*cost_tx_per_initiation
acf_cost <- acf_screened*cost_acf_screen_per_person +
              acf_tested*cost_test_xpert +
              acf_initiated*cost_tx_per_initiation +
              acf_completed*cost_tx_completion_support

soc_uncompleted <- soc_active_cases - soc_completed
int_uncompleted <- soc_active_cases - int_completed

soc_total_cost <- soc_cost + soc_uncompleted*cost_untreated_case
int_total_cost <- soc_cost + acf_cost + int_uncompleted*cost_untreated_case
