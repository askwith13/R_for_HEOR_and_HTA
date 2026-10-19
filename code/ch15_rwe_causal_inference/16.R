# Extracted from ch15_rwe_causal_inference.typ, lines 515-532
# Section: === Difference-in-differences (DiD)
# Chapter: 15

library(did)

atts <- att_gt(
  yname    = "culture_conversion_weeks",
  tname    = "quarter",
  idname   = "district_id",
  gname    = "rollout_quarter",     # period each district FIRST adopted the new regimen (0/Inf for never-treated)
  data     = district_panel,
  control_group = "nevertreated"     # or "notyettreated"
)

agg_simple <- aggte(atts, type = "simple")   # single overall ATT
summary(agg_simple)

agg_dyn <- aggte(atts, type = "dynamic")     # event-study style, by time since rollout
ggdid(agg_dyn)
