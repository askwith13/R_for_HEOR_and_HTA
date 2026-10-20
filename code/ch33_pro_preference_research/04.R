# Extracted from ch33_pro_preference_research.typ, lines 235-251
# Section: == 33.3 Discrete choice experiments (`mlogit`, `apollo`, `logitr`)
# Chapter: 33

# Illustrative structure of a DCE dataset in long format.
# One row per alternative shown within each choice task, for each respondent.
# (Real coefficient estimates would come from fitting mlogit, apollo, or
#  logitr to actual survey data -- not shown here.)

dce_long <- data.frame(
  respondent_id = c(1, 1, 2, 2, 2, 2),
  choice_task    = c(1, 1, 1, 1, 2, 2),
  alternative    = c("A", "B", "A", "B", "A", "B"),
  efficacy_pct   = c(70, 55, 70, 55, 85, 60),
  side_effect_risk = c("moderate", "low", "moderate", "low", "high", "low"),
  dosing_freq    = c("weekly", "daily", "weekly", "daily", "daily", "weekly"),
  monthly_cost   = c(150, 90, 150, 90, 220, 110),
  chosen         = c(1, 0, 0, 1, 1, 0)
)
