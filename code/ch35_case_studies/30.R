# Extracted from ch35_case_studies.typ, lines 945-957
# Section: === Costs and outcomes
# Chapter: 35

daly_per_untreated_case <- 0.26  # DALYs per case not successfully completing treatment
daly_per_completed_case <- 0.04  # residual DALYs even after successful completion

soc_dalys <- soc_completed*daly_per_completed_case +
               soc_uncompleted*daly_per_untreated_case
int_dalys <- int_completed*daly_per_completed_case +
               int_uncompleted*daly_per_untreated_case

incr_cost          <- int_total_cost - soc_total_cost
incr_dalys_averted <- soc_dalys - int_dalys
icer_per_daly      <- incr_cost / incr_dalys_averted
