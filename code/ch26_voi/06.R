# Extracted from ch26_voi.typ, lines 996-1013
# Section: == 26.6 Using VOI to design research and prioritise data collection
# Chapter: 26

# Illustrative ENBS comparison: small vs. large trial of p_ontx_fail
decision_population <- 50000   # patients affected before next policy review

evsi_per_patient_small <- 600    # n = 200, from the §26.4 moment-matching calc
evsi_per_patient_large <- 857    # n = 2000, same effective-sample-size logic

evsi_total_small <- evsi_per_patient_small * decision_population
evsi_total_large <- evsi_per_patient_large * decision_population

cost_small_trial <- 50000        # small single-site trial, n = 200
cost_large_trial <- 45000000     # large multi-site trial, n = 2000

enbs_small <- evsi_total_small - cost_small_trial
enbs_large <- evsi_total_large - cost_large_trial

enbs_small; enbs_large
