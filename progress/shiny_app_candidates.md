# Interactive Shiny App Candidates — R for HEOR and HTA

Working notes only, built chapter-by-chapter per Dr Aswath's request (Oct 19, 2026). 
**44 of 64 candidates have now been built** -- see `shiny_apps/` for the built apps and 
their verification notes; entries below marked `[BUILT]` have a corresponding folder. 
Covers Chapters 1-35 (full book); this file now reflects the complete planning pass.

## Selection criteria
A concept qualifies only if interactivity (sliders, live recalculation, what-if exploration) 
adds genuine pedagogical value beyond static prose/code/plots -- typically because a parameter's 
effect on a result is non-trivial, non-monotonic, or easiest understood by watching it change live. 
Procedural/administrative/taxonomic chapter content (installing software, agency landscapes, 
data governance policy, coding-style conventions) is deliberately excluded even where plentiful.

**Total candidates: 64 across 32 chapters with content (8 now built -- see table above).**
(Chapters 1, 2, 28, 29, 30 reviewed and judged to have none).

---

## Chapter 3. R Essentials for Health Economists

### Transition Matrix Explorer [BUILT]
- **Section:** 3.1
- **What it does:** Sliders set each cell of a 3-state (Healthy/Sick/Dead) transition matrix (constrained to row-sum-to-1); a live cohort-occupancy trace over N cycles previews the Markov machinery of Chapter 19, with a running rowSums() validity check.
- **Likely packages:** `shiny, ggplot2`

---

## Chapter 4. Core Concepts in Health Economics

### ICER Quadrant & Net Benefit Explorer [BUILT]
- **Section:** 4.4
- **What it does:** Drag ΔC/ΔE on the cost-effectiveness plane while a third slider sets the WTP threshold (λ); the app live-recomputes ICER, NMB, NHB and flags the quadrant. Directly illustrates why a negative ICER alone is ambiguous (dominant vs. dominated) while NMB/NHB are not.
- **Likely packages:** `shiny, ggplot2`

### Threshold Sensitivity Dashboard [BUILT]
- **Section:** 4.5
- **What it does:** A WTP slider (λ) spanning HTAIn/NICE/WHO-CHOICE conventions recomputes NMB and the cost-effective/not classification live for a fixed ΔC/ΔE pair, with jurisdiction markers showing exactly where a decision flips.
- **Likely packages:** `shiny, ggplot2`

### Discount Rate & Time Horizon Explorer [BUILT]
- **Section:** 4.6
- **What it does:** Sliders for discount rate and time horizon show the present-value decay curve update live, with NICE/CADTH/HTAIn preset buttons, making the equal-vs-differential discounting debate concrete.
- **Likely packages:** `shiny, ggplot2`

### Efficiency Frontier Builder [BUILT]
- **Section:** 4.7-4.8
- **What it does:** Edit cost/QALY for 3-5 treatments live; the app re-runs simple- and extended-dominance pruning and redraws the CE-plane with dominated points greyed out and the frontier connected. Best early-book candidate: the whole point of the section is a result that depends non-monotonically on inputs.
- **Likely packages:** `shiny, dplyr, ggplot2`
- **Built at:** `shiny_apps/efficiency_frontier_builder/`

---

## Chapter 5. Data Sources and Data Management

### Validation Rule Threshold Tuner
- **Section:** 5.6
- **What it does:** Sliders set bounds for each data-validation rule on the chapter's cost_qaly_tbl example; pass/fail counts update live, showing how loosening/tightening a rule changes what gets caught. (Moderate candidate — limited live value.)
- **Likely packages:** `shiny, pointblank or validate, dplyr`

---

## Chapter 6. Systematic Literature Review (SLR) Support in R

### Dedup Threshold Explorer
- **Section:** 6.2
- **What it does:** Drag a similarity-threshold slider (string_osa distance cutoff) over a loaded reference set and watch duplicate-flag counts change live; a toggle switches exact-title vs fuzzy matching.
- **Likely packages:** `shiny, synthesisr, dplyr`

---

## Chapter 7. Missing Data

### Missingness Mechanism Simulator [BUILT]
- **Section:** 7.1
- **What it does:** Pick MCAR/MAR/MNAR and drag a slider controlling how strongly missingness depends on the utility value; the app regenerates the dataset live and shows a complete-case mean diverging from truth under MNAR but not MCAR.
- **Likely packages:** `shiny, tidyverse, mice`

### Interactive Missingness Explorer
- **Section:** 7.2
- **What it does:** Filter a loaded extract by site/arm/variable via dropdowns; naniar::vis_miss()/gg_miss_var()/gg_miss_upset() plots regenerate live rather than being pre-generated as static figures.
- **Likely packages:** `shiny, naniar, visdat`

### Tipping-Point Delta Explorer [BUILT]
- **Section:** 7.5
- **What it does:** A delta slider (applied to imputed intervention-arm values) live-recomputes and re-plots the risk difference/ICER vs WTP, highlighting the tipping point — lets a reviewer directly probe how implausible a departure from MAR would need to be to flip the conclusion.
- **Likely packages:** `shiny, mice, dplyr`

---

## Chapter 8. Health-Related Quality of Life and Utilities

### EQ-5D Tariff Comparator [BUILT]
- **Section:** 8.2
- **What it does:** Set a 5-dimension EQ-5D health-state profile via sliders/dropdowns and select a country value set; the utility index recomputes live across two or more countries side by side, showing the same health state scoring differently under different tariffs.
- **Likely packages:** `shiny, eq5d`

### Age-Adjusted Utility & Decrement Explorer [BUILT]
- **Section:** 8.5
- **What it does:** Sliders for baseline utility, decrement size, and an additive-vs-multiplicative toggle, plus an age-band selector, replot the utility trajectory live — showing additive adjustment drifting toward implausible/negative values over a long horizon while multiplicative compresses toward (not past) zero.
- **Likely packages:** `shiny, dplyr, ggplot2`

---

## Chapter 9. Costs and Resource Use

### Cost Distribution & Model-Fit Explorer [BUILT]
- **Section:** 9.3-9.4
- **What it does:** Sliders for zero-inflation probability, gamma shape/scale, and outlier probability/scale regenerate a simulated cost dataset live, updating the histogram and mean/median gap, overlaying OLS vs gamma-GLM predicted means to show exactly when/how badly naive OLS misbehaves.
- **Likely packages:** `shiny, tidyverse, stats/glm`

### Censored-Cost Estimator Comparator [BUILT]
- **Section:** 9.6
- **What it does:** A censoring-rate slider (plus informative/administrative toggle) regenerates a censored cohort live and shows naive-mean, Lin's partitioned estimator, and IPCW diverging as censoring worsens — operationalising the chapter's bias-direction table as something the user watches happen.
- **Likely packages:** `shiny, survival, dplyr`

---

## Chapter 10. Survival Analysis for Economic Evaluation

### Parametric Hazard Shape Explorer [BUILT]
- **Section:** 10.2
- **What it does:** Select a distribution family (exponential/Weibull/Gompertz/log-logistic/log-normal/gen.gamma) and drag shape/scale sliders; survival/hazard curves overlay live against a loaded KM curve, extended to a user-set extrapolation horizon — makes visible why 'fits the trial period' and 'extrapolates plausibly' differ.
- **Likely packages:** `shiny, flexsurv, survival`
- **Built at:** `shiny_apps/parametric_hazard_shape_explorer/`

### Spline Knot-Count Explorer [BUILT]
- **Section:** 10.3
- **What it does:** A knot-count slider (k=0-3) for flexsurvspline() live-refits against the KM curve within the trial period and updates an AIC/BIC readout, showing more knots always reduce in-sample AIC while risking an erratic extrapolated tail.
- **Likely packages:** `shiny, flexsurv`

### Cure-Fraction vs. Follow-up-Length Simulator
- **Section:** 10.4
- **What it does:** Sliders for true simulated cure fraction and trial follow-up duration regenerate a censored cohort and refit a mixture cure model live, showing how short/administratively-censored follow-up can manufacture a spuriously large cure estimate indistinguishable from a genuine plateau.
- **Likely packages:** `shiny, flexsurvcure, flexsurv`

---

## Chapter 11. Meta-Analysis

### Pooling Model Playground [BUILT]
- **Section:** 11.1-11.2
- **What it does:** Switch between fixed-effect/random-effects pooling and tau-squared estimators (DL/REML/PM); forest plot, pooled estimate, CI width, and I2/tau2/Q all redraw live — lets the user watch the interval breathe as estimator choice changes, the core 'don't model-shop' lesson.
- **Likely packages:** `shiny, meta, metafor`

### Funnel Asymmetry Lab
- **Section:** 11.3
- **What it does:** A slider controls how many small 'missing' studies are synthetically suppressed; funnel plot, Egger's test, and trim-and-fill re-run live, showing the pooled estimate chase a moving target as suppression changes — makes concrete that trim-and-fill is a sensitivity check, not a correction.
- **Likely packages:** `shiny, meta, metafor`

---

## Chapter 12. Indirect Treatment Comparisons and Network Meta-Analysis

### Bucher ITC Calculator [BUILT]
- **Section:** 12.2
- **What it does:** Four sliders (d_AC, SE_AC, d_BC, SE_BC) let the user vary each trial's estimate/precision and watch the indirect A-vs-B estimate and its always-wider CI update live — targets the most commonly mis-learned fact that uncertainty never cancels in an indirect comparison.
- **Likely packages:** `shiny (pure arithmetic; optionally metafor/meta to overlay a forest plot)`
- **Built at:** `shiny_apps/bucher_itc_calculator/`

### Covariate Re-Centering Explorer
- **Section:** 12.6
- **What it does:** A slider moves the covariate value at which regression-adjusted network estimates are evaluated, sliding continuously between network-mean and target-population estimates; the league-table and forest plot update live — makes concrete the reviewer complaint that network-mean-centred estimates understate effect in a sicker target population.
- **Likely packages:** `shiny, gemtc (or netmeta/metafor for a lighter version)`

---

## Chapter 13. Population-Adjusted Indirect Comparisons

### MAIC Weight & ESS Explorer [BUILT]
- **Section:** 13.2
- **What it does:** Sliders adjust how far the IPD trial's covariate distribution sits from the AgD trial's target means; method-of-moments weights, ESS, and the weighted treatment effect recompute live — turns 'a large ESS loss is a credibility red flag' into something watched happening in real time.
- **Likely packages:** `shiny, base R optim, optionally survival`

---

## Chapter 14. Bayesian Methods for HEOR

### Prior-Likelihood-Posterior Tug-of-War [BUILT]
- **Section:** 14.2
- **What it does:** Sliders for the Beta prior's alpha/beta and a new cohort's observed successes/total redraw prior density, likelihood, and the conjugate posterior with its 95% credible interval live — the clearest way to make the prior-vs-data 'tug-of-war' metaphor tangible.
- **Likely packages:** `shiny, base R dbeta/qbeta (note SHELF for elicitation-based priors)`
- **Built at:** `shiny_apps/prior_likelihood_posterior_tug_of_war/`

---

## Chapter 15. Real-World Evidence and Causal Inference

### Extreme Weights & Trimming Simulator
- **Section:** 15.4
- **What it does:** A propensity-score trimming-bounds slider over a toy/uploaded cohort live-redraws the IPTW weight distribution and recomputes the ATE, showing extreme weights dominate before trimming and stabilize after.
- **Likely packages:** `shiny, WeightIt, cobalt`

### E-value Sensitivity Dashboard [BUILT]
- **Section:** 15.9
- **What it does:** User inputs an effect estimate and CI (RR/OR/HR/coefficient); the app live-computes the point-estimate and CI-limit E-values with a fragile-vs-robust gauge — turns a one-off calculation into a what-if tool usable directly during write-up.
- **Likely packages:** `shiny, EValue`

---

## Chapter 16. Regression Models for HEOR Data

### Link-Function Explorer [BUILT]
- **Section:** 16.1
- **What it does:** Sliders for a logistic-regression coefficient and intercept reshape the predicted-probability S-curve live, with a toggle between link (log-odds) and response (probability) scale — illustrates why raw GLM coefficients mean nothing until back-transformed.
- **Likely packages:** `shiny, ggplot2, base glm()`

### Overdispersion & Zero-Inflation Visualizer [BUILT]
- **Section:** 16.3
- **What it does:** Sliders for Poisson mean, negative-binomial dispersion (theta), and proportion of structural zeros morph a simulated count histogram between Poisson/NB/zero-inflated shapes, with the residual-deviance/df ratio updating live.
- **Likely packages:** `shiny, MASS, pscl, ggplot2`

### Quantile Regression Tau Slider [BUILT]
- **Section:** 16.4
- **What it does:** A tau slider (0-1) re-fits quantreg::rq() live on toy cost/LOS data and redraws the fitted quantile line against the scatter, showing the median vs. 90th-percentile ('costly tail') estimates diverge.
- **Likely packages:** `shiny, quantreg, ggplot2`

---

## Chapter 17. Principles of Decision Modelling

### Beta Distribution Fitter [BUILT]
- **Section:** 17.4
- **What it does:** Sliders for a trial's reported mean probability and 95% CI width recompute method-of-moments alpha/beta live and redraw the Beta density — shows a tighter CI (bigger trial) concentrating the distribution vs a wide CI from a small arm.
- **Likely packages:** `shiny, ggplot2, base R`

### Toy Regimen ICER Explorer [BUILT]
- **Section:** 17.6
- **What it does:** Sliders for cost_drug and p_cure for Regimen A/B feed the chapter's own skeletal run_model() function; the ICER/NMB table recalculates live as any input varies — a minimal demonstration of why separating inputs/engine/results layers matters.
- **Likely packages:** `shiny, dplyr, tibble`

---

## Chapter 18. Decision Trees

### Diagnostic Tree ICER Dashboard [BUILT]
- **Section:** 18.1-18.2
- **What it does:** Sliders for TB prevalence, each test's sensitivity/specificity, and costs of tests/outcomes recompute the rollback expected cost/QALYs for both strategies live, with the ICER and a CE-plane point updating instantly — runs the exact scenario the chapter's own pitfall poses (prevalence 0.30 -> 0.10) but never executes.
- **Likely packages:** `shiny, dplyr, tibble, ggplot2 (optionally rdecision for the tree structure)`

---

## Chapter 19. Markov Cohort Models

### Cohort Trace Builder [BUILT]
- **Section:** 19.1 & 19.3
- **What it does:** Sliders for each outbound transition probability (stay-probability auto-computed to sum to 1) redraw the 20-cycle state-occupancy trace live, making visible how small transition-probability changes compound over many cycles.
- **Likely packages:** `shiny, base R matrix algebra, ggplot2`

### Discounting & Half-Cycle Correction Comparator [BUILT]
- **Section:** 19.5
- **What it does:** A discount-rate slider and a beginning/end/life-table toggle recompute total discounted QALYs/costs live from a fixed cycle stream, turning the trapezoidal-averaging explanation into a visible before/after comparison.
- **Likely packages:** `shiny, heemod, ggplot2`

### Tunnel-State Risk Shape Explorer [BUILT]
- **Section:** 19.6
- **What it does:** Sliders set failure-risk at each tunnel sub-state (cycle 1, 2, 3+); flat vs front-loaded time-since-entry-dependent occupancy traces and final cost/QALY totals plot side by side, showing why ignoring state-time biases short-vs-long-course comparisons.
- **Likely packages:** `shiny, heemod (state_time), ggplot2`

### SoC vs. DMT Live ICER Dashboard [BUILT]
- **Section:** 19.10
- **What it does:** Sliders for each arm's transition probabilities, state costs, state utilities, and discount rate recompute the full discounted 10-year cost/QALY totals and ICER live, with a CE-plane point and WTP line — the single best match in the book to 'vary a transition probability or cost and watch the ICER update live.'
- **Likely packages:** `shiny, base R or heemod, dampack::calculate_icers(), ggplot2`
- **Built at:** `shiny_apps/soc_vs_dmt_icer_dashboard/`

---

## Chapter 20. Partitioned Survival Models

### Curve-Crossing Explorer [BUILT]
- **Section:** 20.1 & 20.5
- **What it does:** Shape/scale sliders for independently-fit PFS and OS Weibull curves live-replot both survival curves plus the derived P(Progressed) = S_OS(t) - S_PFS(t) line across an extendable time horizon, with the region where it goes negative shaded in red. Makes the chapter's central structural-flaw pitfall (curve crossing happens far out in the tail, easy to miss on a quick plot) directly visible and draggable into existence rather than described in prose.
- **Likely packages:** `shiny, ggplot2, base R (stats::pweibull or a hand-written weib_S())`

### PSM Oncology ICER Dashboard
- **Section:** 20.6
- **What it does:** Sliders for each arm's PFS/OS shape+scale and state costs/utilities feed the chapter's own `run_arm()` discounting loop; discounted cost, QALYs, and ICER recompute live for both arms with a cost-effectiveness-plane point, while a crossing-check readout (min(p_progressed) across the horizon) flags red if either arm's curves ever cross — combines this chapter's two main teaching points (worked CEA mechanics + the crossing pitfall) into one app.
- **Likely packages:** `shiny, flexsurv, dplyr, ggplot2`

### Waning Assumption Visualizer [BUILT]
- **Section:** 20.3
- **What it does:** A toggle (no waning / linear waning) plus a waning-onset and waning-duration slider reshapes the intervention arm's OS extrapolation live against a fixed "no waning" reference curve, showing directly how much of the lifetime QALY gain depends on an untested post-trial assumption about whether the treatment's benefit persists indefinitely.
- **Likely packages:** `shiny, flexsurv, ggplot2`

---

## Chapters reviewed with no genuine candidates

- **Chapter 1. Introduction to HEOR and HTA** — Definitional/institutional content (HEOR vs. market access, HTA agency landscape, lifecycle stages, why-R case). Nothing involves a continuously-varying parameter whose effect on a result benefits from live manipulation.
- **Chapter 2. Setting Up an R Environment for HEOR** — Tooling/infrastructure (R/RStudio/Quarto install, renv, Git, Stan/JAGS toolchains, Docker). No model output or parameter relationship for a user to explore -- correctness here is procedural, not a quantity varying continuously with an input.

Chapter 5 (Data Sources and Data Management) yielded one borderline candidate 
(Validation Rule Threshold Tuner, §5.6) — included above but flagged as moderate, 
not compelling, since its live value is mostly a pass/fail count ticking up or down.

---

## Chapter 21. Individual-Level State-Transition Models (Microsimulation)

### First-Order Noise Convergence Explorer [BUILT]
- **Section:** 21.4
- **What it does:** A slider for N (number of simulated patients, e.g. 100 to 50,000, log scale) re-runs the chapter's fixed-parameter microsimulation twice with two independent patient cohorts of that size and live-plots the gap between the two runs' headline outputs (mean cost, mean QALYs) shrinking as N grows — makes the first-order-vs-second-order distinction (§21.4) directly visible rather than asserted, and gives a concrete answer to "how many patients is enough?"
- **Likely packages:** `shiny, ggplot2`

### Common Random Numbers Variance-Reduction Demo
- **Section:** 21.5
- **What it does:** A toggle switches between independent-random-draws and common-random-numbers simulation of the same two-arm comparison; a live histogram of the incremental QALY difference across repeated simulation runs visibly narrows under CRN — directly demonstrates the variance-reduction claim in §21.5 rather than describing it in prose only.
- **Likely packages:** `shiny, ggplot2`

---

## Chapter 22. Discrete Event Simulation and Dynamic Models

### M/M/1 Queue Utilisation Explorer [BUILT]
- **Section:** 22.2
- **What it does:** Sliders for mean inter-arrival time and mean service time (equivalently, arrival rate lambda and service rate mu) drive a live `simmer` re-run of the §22.2 single-nurse clinic model; the app shows simulated average wait, average queue length, and nurse utilisation updating live, alongside the closed-form M/M/1 benchmark lines (W_q, L_q, L) computed from the same sliders — directly visualises the non-linear blow-up in wait time as utilisation rho approaches 1 (queueing theory's well-known non-monotonic/explosive behaviour near saturation), which is far more vivid watched live than read as a formula.
- **Likely packages:** `shiny, simmer, ggplot2`
- **Built at:** `shiny_apps/mm1_queue_utilisation_explorer/`

### SEIR Epidemic Curve and Herd-Effect Explorer [BUILT]
- **Section:** 22.4/22.6
- **What it does:** Sliders for R0 (beta/gamma), the latent-period rate sigma, and the intervention effectiveness `ve` re-run the §22.4/22.6 `deSolve::ode()` SEIR model live, re-plotting the infectious-compartment curve for both the baseline and intervention arms on one chart and recalculating cumulative infections averted. Makes the compounding/indirect-protection effect from the §22.4 pitfall directly visible: small changes in `ve` produce disproportionately large changes in the final epidemic size once R0 is close to 1, a genuinely non-linear relationship that a single static worked example cannot convey.
- **Likely packages:** `shiny, deSolve, ggplot2`

---

## Chapter 23. Budget Impact Analysis

### Budget Impact Scenario Explorer [BUILT]
- **Section:** 23.2-23.4
- **What it does:** Sliders for terminal uptake share (the peak market-share parameter in the linear/logistic diffusion curves), new-drug list price, and the per-patient hospitalization offset drive a live re-run of the chapter's `build_bia()` function, instantly recomputing and redrawing the year-by-year and cumulative budget-impact table/chart. The non-linear interaction between uptake-curve shape and net price materially changes WHEN cumulative spend crosses a given affordability threshold — far more intuitive to explore live via slider than to read across three separate static scenario tables (base case, faster uptake, managed-entry agreement) as the chapter currently presents them.
- **Likely packages:** `shiny, dplyr, ggplot2`

---

## Chapter 24. Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis

### Equity-Weighted ICER Explorer [BUILT]
- **Section:** 24.2
- **What it does:** Sliders for each subgroup's QALY gain and an adjustable equity weight (1.0 to 3.0) for the most-deprived group re-run the chapter's toy two-subgroup `icer_unweighted`/`icer_weighted` calculation live, redrawing both ICERs side by side and plotting the result as a point on a simplified equity-impact-plane quadrant chart. Makes the chapter's central "win-win vs genuine trade-off" distinction directly explorable — dragging the deprived group's QALY gain below the less-deprived group's instantly flips which quadrant the result lands in, a relationship the static toy example can only show once.
- **Likely packages:** `shiny, dplyr, ggplot2`

### ECEA Financial Risk Protection Dashboard
- **Section:** 24.3
- **What it does:** Sliders for the status-quo and new-policy out-of-pocket cost, the catastrophic-expenditure threshold (%), and the poverty line re-run the chapter's `ecea_frp()` function live across all five income quintiles, redrawing the CHE-cases-averted and poverty-cases-averted bar chart. Strong candidate because the quintile-by-quintile distribution genuinely depends non-trivially on where each cutoff falls relative to each quintile's income band — exactly the kind of threshold-crossing behaviour that is far clearer dragged live than read from a single static scenario.
- **Likely packages:** `shiny, dplyr, ggplot2`

### MCDA Weight Sensitivity Explorer
- **Section:** 24.4
- **What it does:** Four sliders (one per criterion: efficacy, safety, severity, economic value, constrained to sum to 1) re-run the chapter's `mcda_weighted_score()` function live against the same three-drug example, instantly re-ranking the drugs and showing how close the ranking is to flipping. Directly operationalizes the chapter's own pitfall box ("every MCDA result should be accompanied by a weight-sensitivity analysis") as something a reader can actually do rather than just be told to do.
- **Likely packages:** `shiny, dplyr`

---

## Chapter 25 additions (Handling Uncertainty)

### Tornado Diagram Parameter-Range Explorer [BUILT]
- **Section:** 25.2
- **What it does:** Sliders for each of the five one-way sensitivity analysis parameters' low/high bounds (New-regimen cure probability, shared p(Fail->Death), annual discount rate, New-regimen drug cost, shared on-treatment utility), re-running the chapter's `incremental_nmb()` function live to redraw the tornado diagram bars and re-sort them by swing width in real time. Makes concrete, interactively, the chapter's own observation that a tornado diagram ranks parameters by influence on the decision, not by how uncertain they intuitively feel -- a reader can directly widen or narrow any one parameter's range and watch its bar (and its rank) move.
- **Likely packages:** `shiny, ggplot2, forcats`

### PSA Distribution & CEAC Explorer [BUILT]
- **Section:** 25.4-25.5
- **What it does:** Sliders for the willingness-to-pay threshold ($0-$150,000/QALY) and for the assumed evidence strength behind the Beta-distributed failure probability (effective pseudo-count sample size), re-running the chapter's n=2000 PSA loop live and redrawing the CE plane, CEAC, and incremental-NMB histogram together. Directly operationalizes the chapter's own point that a reader's confidence in cost-effectiveness is WTP-threshold-dependent -- sliding the threshold line across the CE plane visibly moves the CEAC's reading at that exact threshold, making the single-threshold NMB histogram and the full CEAC curve legible as two views of the same underlying PSA draws.
- **Likely packages:** `shiny, ggplot2, dplyr`
- **Built at:** `shiny_apps/psa_distribution_ceac_explorer/`

### Threshold Analysis Breakeven Calculator
- **Section:** 25.6
- **What it does:** Sliders for the new regimen's incremental QALY gain and the WTP threshold re-compute the breakeven total cost live via the chapter's rearranged ICER formula (reused from Ch.24 §24.5's value-based-pricing relationship), displaying the result as a single live number alongside a marker on a cost-vs-ICER line plot. A simple, low-engineering-cost app that makes the "threshold analysis solves backward for one parameter" idea tangible without needing a full PSA re-run per interaction.
- **Likely packages:** `shiny`

### Structural Model Averaging Weight Explorer
- **Section:** 25.7
- **What it does:** A single slider for the weight assigned to the 4-state structure (with the 3-state structure's weight auto-set to 1 minus that value), re-computing the model-averaged NMB live from the chapter's own two fixed structure-specific NMB values ($8,044.05 and $5,357.89). Makes concrete, interactively, how sensitive the final blended answer is to a largely judgement-based weighting choice -- a reader can drag from "trust the simple structure completely" to "trust the detailed structure completely" and watch the averaged NMB move smoothly between the two endpoints, directly illustrating the chapter's own caution that model-averaging weights are often expert judgement, not a hard empirical fact.
- **Likely packages:** `shiny`

### Bootstrap Resampling Method Comparator
- **Section:** 25.8
- **What it does:** A toggle between "correct" (row-preserving) and "incorrect" (independent-column) bootstrap resampling, re-running B=500 replicates live on the chapter's own simulated trial dataset and overlaying both resulting incremental-NMB distributions on one histogram. Makes the chapter's own pitfall box viscerally obvious -- a reader can watch the independent-column version visibly widen relative to the correct version in real time, rather than just reading the stated ~17% SD inflation figure.
- **Likely packages:** `shiny, ggplot2`

---

## Chapter 26 additions (Value of Information Analysis)

### EVPI-vs-WTP Curve Explorer [BUILT]
- **Section:** 26.1-26.2
- **What it does:** A single WTP-threshold slider ($0-$150,000/QALY) re-running the chapter's `calculate_evpi()` function live against the existing Ch.25 PSA draws, redrawing the EVPI-vs-WTP curve and marking where the current slider value sits on it. Directly demonstrates the chapter's core finding that EVPI peaks near the WTP at which the CEAC crosses 50% -- a reader can drag the threshold and watch EVPI rise and fall in real time, making the EVPI-CEAC link far more concrete than a static table.
- **Likely packages:** `shiny, ggplot2`
- **Built at:** `shiny_apps/evpi_vs_wtp_curve_explorer/`

### GAM EVPPI Smoothness Explorer
- **Section:** 26.3
- **What it does:** A slider for `mgcv::gam()`'s `k=` basis-dimension argument, re-fitting the GAM regression of incremental NMB on `p_ontx_fail` live and redrawing both the fitted smooth curve against the raw PSA scatter and the resulting EVPPI number. Makes the chapter's own pitfall box (k too small underestimates EVPPI, too large overestimates it) directly visible and interactive -- a reader can watch the curve go from under-fit to over-fit and see the EVPPI number swing accordingly, reinforcing why REML's automatic smoothness selection is the recommended default.
- **Likely packages:** `shiny, mgcv, ggplot2`

### ENBS Trial-Size Comparator
- **Section:** 26.4, 26.6
- **What it does:** Two side-by-side sliders (sample size and trial cost) for a proposed study targeting `p_ontx_fail`, re-computing the moment-matching EVSI and resulting ENBS live, so a reader can directly search for the sample size that maximises ENBS rather than assuming "bigger is always better." Operationalizes the chapter's own non-obvious finding (§26.6) that a larger, costlier trial can have lower, even negative, ENBS than a smaller one.
- **Likely packages:** `shiny`

---

## Standing note for future chapters (28-35)

As each new chapter is drafted by the `heor-hta-book-writer` cron job, re-run this same 
review (read the chapter, identify genuine slider-and-live-recalculation candidates, be 
selective, say explicitly when a chapter has none) and append to this file rather than 
rebuilding it from scratch. Coverage currently extends through Chapter 27.

## Chapter 27. Model Calibration, Validation and Quality Assurance

### Calibration Target Search Explorer
- **Section:** 27.1
- **What it does:** A slider for the calibration target value (e.g. the registry's 5-year mortality rate, adjustable around the illustrative 32% base case) that live-reruns the `optim()` Nelder-Mead search for `p_hidden` and redraws both the random-search scatter and the converged value, letting a reader see how sensitive the calibrated parameter is to the exact target value chosen -- directly demonstrates why a calibration target's own uncertainty matters, not just its point estimate.
- **Likely packages:** `shiny, ggplot2`

### Extreme-Value Test Sandbox
- **Section:** 27.3
- **What it does:** A slider setting the "Well-on-treatment to Dead" transition probability anywhere from 0 to 1 (not just the extreme 0/1 values used in the chapter's own test), live-recomputing and plotting the resulting cohort survival trace, so a reader can watch the trace degrade continuously toward the mathematically predictable extreme and build intuition for why extreme-value testing works as a verification technique.
- **Likely packages:** `shiny, ggplot2`

Total candidates now: 56 across 25 chapters.

## Chapter 28. Reproducible Reporting

No genuine candidates identified. Checked per the mandatory per-tick scan: 28.1-28.8
cover Quarto/R Markdown mechanics, multi-format rendering, publication tables/graphics,
CHEERS checklist tracking, dossier assembly and report-automation scheduling -- all
procedural/workflow content (how to render, format, and schedule a document) rather than
a parameter whose live-varying effect on a model result is non-trivial or non-monotonic.
The closest candidate considered and rejected: a "colour palette CVD simulator" slider for
28.5 would only toggle between a small fixed set of simulation types rather than offering
genuine continuous/non-trivial exploration, so it does not meet the selection bar.

Total candidates remain 56 across 25 chapters with content (Chapter 28 adds a chapter with
zero candidates, consistent with how Chapters 1-2 were handled).

## Chapter 29. Interactive Models and Web Applications with Shiny

No genuine candidates identified. Checked per the mandatory per-tick scan: 29.1-29.8 are
THEMSELVES about how to build a Shiny app (architecture, UI design, modularity, model
linkage, downloads/audit trails, deployment, security, a capstone case study) rather than
a methodological HEOR concept whose parameter effects would benefit from being wrapped
in an interactive app -- the chapter teaches the tool used to build such apps, so adding a
"Shiny app candidate" entry about Shiny itself would be circular. Every illustrative code
example in the chapter already IS, in effect, a worked Shiny snippet (the toy ICER
calculator in 29.1, the TB model PSA explorer in 29.4 and 29.8), so there is no further
unaddressed interactivity gap to log here.

Total candidates remain 56 across 26 chapters with content (Chapter 29 adds a chapter with
zero candidates, consistent with how Chapters 1-2 and 28 were handled).

## Chapter 30. R Packages and Pipelines for Model Development

No genuine candidates identified. Checked per the mandatory per-tick scan: 30.1-30.7 cover
package scaffolding, documentation tooling, `targets` pipelines, CI, sharing mechanisms,
and licensing -- all procedural/infrastructure content about HOW to package and ship a
model, not a methodological HEOR parameter whose live-varying effect would benefit from an
interactive app. The closest candidate considered and rejected: a "targets dependency-graph
explorer" letting a user click a node and see which downstream targets would re-run --
interesting as a developer tool, but not a genuine HEOR-methodology exploration the way
e.g. a WTP-threshold slider or a transition-probability sandbox is, so it does not meet the
selection bar used throughout this file.

Total candidates remain 56 across 27 chapters with content (Chapter 30 adds a chapter with
zero candidates, consistent with how Chapters 1-2, 28, and 29 were handled).

## Chapter 31. Agency Requirements and Reference Cases

### Cross-Agency Decision Explorer [BUILT]
- **Section:** 31.5
- **What it does:** Sliders/dropdowns let the user pick an agency (NICE/CADTH/PBAC/ICER/HTAIn etc.) and vary a single ICER value; the app shows live whether that ICER falls below/above each agency's stated or inferred WTP threshold (where one is publicly stated -- explicitly showing "no threshold used by design" for IQWiG/G-BA rather than forcing a number), making the Section 31.5 comparison table's practical consequence ("the same ICER can be acceptable in one jurisdiction and inconclusive in another") directly visible rather than only read as a static table.
- **Likely packages:** `shiny, ggplot2, bslib`

Total candidates now 57 across 28 chapters with content.

## Chapter 32. Special Topics

### Durability / Waning-of-Effect Explorer [BUILT]
- **Section:** 32.6
- **What it does:** Sliders let the user vary the waning-start cycle and the per-cycle relapse hazard rate (or switch between the three structural scenarios -- durable forever, constant waning, accelerating waning -- from the chapter's R example) for a one-time curative gene/cell therapy, with a live-updating relapse-free-proportion curve over a 20-year horizon. Makes directly visible the chapter's key point that a single-scenario base case silently picks one of several plausible 20-year futures, and that the three scenarios look identical for the first several years (while trial follow-up still covers them) before diverging sharply -- the kind of divergence static prose/one fixed plot cannot convey as viscerally as dragging the waning-rate slider and watching the curve drop.
- **Likely packages:** `shiny, ggplot2, bslib, dplyr`

### TB Cascade-of-Care Attrition Explorer [BUILT]
- **Section:** 32.7
- **What it does:** Five sliders, one per cascade stage (diagnosis, treatment initiation, treatment completion, bacteriological cure), each 0-100%, with a live-updating waterfall/funnel chart showing the cohort shrinking stage by stage and the final population-level cure rate recalculating instantly. Directly demonstrates the chapter's compounding-attrition point -- that a 10-percentage-point improvement at one stage changes the final cured proportion by a different amount depending on which stage it's applied to and how much attrition has already occurred upstream -- letting a user discover this for themselves rather than only reading the worked numeric example.
- **Likely packages:** `shiny, ggplot2, bslib, dplyr`

Total candidates now 59 across 29 chapters with content.

## Chapter 33. Patient-Reported Outcomes and Preference Research

### IRT Item Characteristic Curve Explorer [BUILT]
- **Section:** 33.1
- **What it does:** Sliders let the user vary an item's discrimination (a) and difficulty (b) parameters, with a live-updating item characteristic curve (probability of a positive response vs. underlying trait level theta) overlaid against a fixed reference item. Makes directly visible the conceptual distinction the chapter draws between difficulty (where on the trait scale the item is most informative -- shifts the curve left/right) and discrimination (how sharply it distinguishes respondents just above vs. below that point -- changes the curve's steepness), which is otherwise easy to read as prose but hard to feel intuitively from the `mirt::itemplot()` static output alone.
- **Likely packages:** `shiny, ggplot2, bslib`

### MCID Threshold / Responder-Rate Explorer [BUILT]
- **Section:** 33.2
- **What it does:** A slider for the distribution-based MCID fraction (e.g. 0.3x to 0.8x baseline SD, the chapter's worked example uses 0.5x) applied to the same simulated treatment-arm PRO data, with a live-updating responder-rate percentage and histogram of patient-level changes with the MCID threshold marked as a vertical line. Directly demonstrates the chapter's key closing point -- that the specific threshold chosen is "doing a great deal of work" in determining how good a treatment looks under a responder-based model structure -- by letting the user watch the responder rate swing as they drag the threshold, rather than only reading the one fixed 52% result in the report-table.
- **Likely packages:** `shiny, ggplot2, bslib, dplyr`

Total candidates now 61 across 30 chapters with content.

## Chapter 34. Emerging Methods and the Future of HEOR in R

### Random Forest Risk-Threshold / Confusion-Matrix Explorer [BUILT]
- **Section:** 34.1
- **What it does:** A slider for the predicted-probability cutoff used to classify a patient as "high-cost" (default 0.5, applied to the fitted random forest's predicted probabilities on the chapter's worked example), with a live-updating confusion matrix and accuracy/sensitivity/specificity figures recalculating as the threshold moves. Directly demonstrates a point the chapter's static accuracy figure can't show on its own -- that a single "78% accuracy" number hides a sensitivity/specificity trade-off that shifts as the decision threshold moves, which matters directly for how many case-management slots a predictive-targeting programme would actually trigger at a given cutoff.
- **Likely packages:** `shiny, ggplot2, bslib, randomForest`

Total candidates now 62 across 31 chapters with content.

## Chapter 35. End-to-End Worked Case Studies

### Budget Impact Uptake/Price Explorer
- **Section:** 35.4
- **What it does:** This is the exact app the case study itself describes building, conceptually, rather than a new idea -- sliders for the LAI's annual price, the relapse-rate reduction, and a 5-year uptake trajectory (either five individual year-sliders or one "ramp speed" slider), with the year-by-year budget-impact table and cost-trajectory chart from §35.4 recomputing live as any input moves. Directly demonstrates the case study's own stated point: uptake speed, not price, is the dominant driver of the 5-year net impact in the base case -- letting a payer committee discover that for themselves by dragging the uptake slider rather than being told it in prose.
- **Likely packages:** `shiny, ggplot2, bslib`

### CEAC/WTP Threshold Explorer (Case Studies A and B combined)
- **Section:** 35.1, 35.2
- **What it does:** A single willingness-to-pay slider (0 to 500,000) that, for either the chronic-disease Markov model or the oncology PSM, highlights the corresponding point on that case study's own PSA-derived CEAC curve and restates the probability-cost-effective figure live. Makes directly visible the chapter's own observation that the accept/reject conclusion for Case Study A flips sharply between a WTP of 20,000 and 50,000, while Case Study B's ICER never approaches a conventional oncology threshold at any reasonable WTP -- a genuinely different qualitative story for each case study that a static CEAC plot states but a live slider lets a reader feel.
- **Likely packages:** `shiny, ggplot2, bslib`

Total candidates now 64 across 32 chapters with content.

## When we build these

Each app, when built, should get its own folder under a new top-level `shiny_apps/` 
directory (mirroring `code/`'s one-folder-per-concept convention), with its own `app.R` 
and a short README linking back to the exact book section it illustrates. Not yet built -- 
this file is the planning inventory only.
