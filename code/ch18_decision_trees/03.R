# Extracted from ch18_decision_trees.typ, lines 143-197
# Section: == 18.3 Using `rdecision`
# Chapter: 18

library(rdecision)

# Branch probabilities and payoffs, reusing §18.1's worked numbers exactly
p_tb <- 0.30
sens_smear <- 0.60; spec_smear <- 0.98
sens_xpert <- 0.90; spec_xpert <- 0.96
cost_smear_test <- 5; cost_xpert_test <- 25
cost_tp <- 100; cost_fn <- 300; cost_fp <- 100; cost_tn <- 0
qaly_tp <- 0.95; qaly_fn <- 0.70; qaly_fp <- 0.90; qaly_tn <- 0.97

# Decision node: choice of diagnostic algorithm
d1 <- DecisionNode$new("algorithm")

# One chance node per algorithm for disease status, one per status for
# the test-result branch (true-positive/false-negative under TB;
# false-positive/true-negative under no-TB)
c_smear_disease <- ChanceNode$new("smear: disease status")
c_smear_tb_test  <- ChanceNode$new("smear: test | TB")
c_smear_notb_test <- ChanceNode$new("smear: test | no TB")
c_xpert_disease <- ChanceNode$new("xpert: disease status")
c_xpert_tb_test  <- ChanceNode$new("xpert: test | TB")
c_xpert_notb_test <- ChanceNode$new("xpert: test | no TB")

# Leaves carry the incremental utility (QALY-equivalent) for the outcome
t_smear_tp <- LeafNode$new("Smear:TP"); t_smear_fn <- LeafNode$new("Smear:FN")
t_smear_fp <- LeafNode$new("Smear:FP"); t_smear_tn <- LeafNode$new("Smear:TN")
t_xpert_tp <- LeafNode$new("Xpert:TP"); t_xpert_fn <- LeafNode$new("Xpert:FN")
t_xpert_fp <- LeafNode$new("Xpert:FP"); t_xpert_tn <- LeafNode$new("Xpert:TN")

# Actions carry the per-test cost; Reactions carry branch probability + cost
a_smear <- Action$new(d1, c_smear_disease, cost = cost_smear_test, label = "Smear")
a_xpert <- Action$new(d1, c_xpert_disease, cost = cost_xpert_test, label = "Xpert")

r_smear_tb  <- Reaction$new(c_smear_disease, c_smear_tb_test,  p = p_tb, cost = 0, label = "TB")
r_smear_notb <- Reaction$new(c_smear_disease, c_smear_notb_test, p = NA_real_, cost = 0, label = "No TB")
r_smear_tp <- Reaction$new(c_smear_tb_test, t_smear_tp, p = sens_smear, cost = cost_tp, label = "+ve")
r_smear_fn <- Reaction$new(c_smear_tb_test, t_smear_fn, p = NA_real_, cost = cost_fn, label = "-ve")
r_smear_fp <- Reaction$new(c_smear_notb_test, t_smear_fp, p = 1 - spec_smear, cost = cost_fp, label = "+ve")
r_smear_tn <- Reaction$new(c_smear_notb_test, t_smear_tn, p = NA_real_, cost = cost_tn, label = "-ve")
# ... equivalent reactions for the Xpert branch, using sens_xpert/spec_xpert ...

tree <- DecisionTree$new(
  V = list(d1, c_smear_disease, c_smear_tb_test, c_smear_notb_test,
           t_smear_tp, t_smear_fn, t_smear_fp, t_smear_tn,
           c_xpert_disease, c_xpert_tb_test, c_xpert_notb_test,
           t_xpert_tp, t_xpert_fn, t_xpert_fp, t_xpert_tn),
  E = list(a_smear, a_xpert,
           r_smear_tb, r_smear_notb, r_smear_tp, r_smear_fn, r_smear_fp, r_smear_tn)
           # ... plus the equivalent Xpert reactions ...
)

results <- tree$evaluate(setvars = "expected", by = "strategy")
results
