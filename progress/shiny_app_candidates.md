# Interactive Shiny App Candidates — R for HEOR and HTA

Working notes only, built chapter-by-chapter per Dr Aswath's request (Oct 19, 2026). 
**No apps have been built yet** -- this is a selectivity-first inventory to build from later, 
not a backlog to execute immediately. Covers Chapters 1-19 (current book progress); 
extend this file as each new chapter is drafted (see the standing note at the bottom).

## Selection criteria
A concept qualifies only if interactivity (sliders, live recalculation, what-if exploration) 
adds genuine pedagogical value beyond static prose/code/plots -- typically because a parameter's 
effect on a result is non-trivial, non-monotonic, or easiest understood by watching it change live. 
Procedural/administrative/taxonomic chapter content (installing software, agency landscapes, 
data governance policy, coding-style conventions) is deliberately excluded even where plentiful.

**Total candidates so far: 35 across 17 chapters** 
(Chapters 1, 2 reviewed and judged to have none).

---

## Chapter 3. R Essentials for Health Economists

### Transition Matrix Explorer
- **Section:** 3.1
- **What it does:** Sliders set each cell of a 3-state (Healthy/Sick/Dead) transition matrix (constrained to row-sum-to-1); a live cohort-occupancy trace over N cycles previews the Markov machinery of Chapter 19, with a running rowSums() validity check.
- **Likely packages:** `shiny, ggplot2`

---

## Chapter 4. Core Concepts in Health Economics

### ICER Quadrant & Net Benefit Explorer
- **Section:** 4.4
- **What it does:** Drag ΔC/ΔE on the cost-effectiveness plane while a third slider sets the WTP threshold (λ); the app live-recomputes ICER, NMB, NHB and flags the quadrant. Directly illustrates why a negative ICER alone is ambiguous (dominant vs. dominated) while NMB/NHB are not.
- **Likely packages:** `shiny, ggplot2`

### Threshold Sensitivity Dashboard
- **Section:** 4.5
- **What it does:** A WTP slider (λ) spanning HTAIn/NICE/WHO-CHOICE conventions recomputes NMB and the cost-effective/not classification live for a fixed ΔC/ΔE pair, with jurisdiction markers showing exactly where a decision flips.
- **Likely packages:** `shiny, ggplot2`

### Discount Rate & Time Horizon Explorer
- **Section:** 4.6
- **What it does:** Sliders for discount rate and time horizon show the present-value decay curve update live, with NICE/CADTH/HTAIn preset buttons, making the equal-vs-differential discounting debate concrete.
- **Likely packages:** `shiny, ggplot2`

### Efficiency Frontier Builder
- **Section:** 4.7-4.8
- **What it does:** Edit cost/QALY for 3-5 treatments live; the app re-runs simple- and extended-dominance pruning and redraws the CE-plane with dominated points greyed out and the frontier connected. Best early-book candidate: the whole point of the section is a result that depends non-monotonically on inputs.
- **Likely packages:** `shiny, dplyr, ggplot2`

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

### Missingness Mechanism Simulator
- **Section:** 7.1
- **What it does:** Pick MCAR/MAR/MNAR and drag a slider controlling how strongly missingness depends on the utility value; the app regenerates the dataset live and shows a complete-case mean diverging from truth under MNAR but not MCAR.
- **Likely packages:** `shiny, tidyverse, mice`

### Interactive Missingness Explorer
- **Section:** 7.2
- **What it does:** Filter a loaded extract by site/arm/variable via dropdowns; naniar::vis_miss()/gg_miss_var()/gg_miss_upset() plots regenerate live rather than being pre-generated as static figures.
- **Likely packages:** `shiny, naniar, visdat`

### Tipping-Point Delta Explorer
- **Section:** 7.5
- **What it does:** A delta slider (applied to imputed intervention-arm values) live-recomputes and re-plots the risk difference/ICER vs WTP, highlighting the tipping point — lets a reviewer directly probe how implausible a departure from MAR would need to be to flip the conclusion.
- **Likely packages:** `shiny, mice, dplyr`

---

## Chapter 8. Health-Related Quality of Life and Utilities

### EQ-5D Tariff Comparator
- **Section:** 8.2
- **What it does:** Set a 5-dimension EQ-5D health-state profile via sliders/dropdowns and select a country value set; the utility index recomputes live across two or more countries side by side, showing the same health state scoring differently under different tariffs.
- **Likely packages:** `shiny, eq5d`

### Age-Adjusted Utility & Decrement Explorer
- **Section:** 8.5
- **What it does:** Sliders for baseline utility, decrement size, and an additive-vs-multiplicative toggle, plus an age-band selector, replot the utility trajectory live — showing additive adjustment drifting toward implausible/negative values over a long horizon while multiplicative compresses toward (not past) zero.
- **Likely packages:** `shiny, dplyr, ggplot2`

---

## Chapter 9. Costs and Resource Use

### Cost Distribution & Model-Fit Explorer
- **Section:** 9.3-9.4
- **What it does:** Sliders for zero-inflation probability, gamma shape/scale, and outlier probability/scale regenerate a simulated cost dataset live, updating the histogram and mean/median gap, overlaying OLS vs gamma-GLM predicted means to show exactly when/how badly naive OLS misbehaves.
- **Likely packages:** `shiny, tidyverse, stats/glm`

### Censored-Cost Estimator Comparator
- **Section:** 9.6
- **What it does:** A censoring-rate slider (plus informative/administrative toggle) regenerates a censored cohort live and shows naive-mean, Lin's partitioned estimator, and IPCW diverging as censoring worsens — operationalising the chapter's bias-direction table as something the user watches happen.
- **Likely packages:** `shiny, survival, dplyr`

---

## Chapter 10. Survival Analysis for Economic Evaluation

### Parametric Hazard Shape Explorer
- **Section:** 10.2
- **What it does:** Select a distribution family (exponential/Weibull/Gompertz/log-logistic/log-normal/gen.gamma) and drag shape/scale sliders; survival/hazard curves overlay live against a loaded KM curve, extended to a user-set extrapolation horizon — makes visible why 'fits the trial period' and 'extrapolates plausibly' differ.
- **Likely packages:** `shiny, flexsurv, survival`

### Spline Knot-Count Explorer
- **Section:** 10.3
- **What it does:** A knot-count slider (k=0-3) for flexsurvspline() live-refits against the KM curve within the trial period and updates an AIC/BIC readout, showing more knots always reduce in-sample AIC while risking an erratic extrapolated tail.
- **Likely packages:** `shiny, flexsurv`

### Cure-Fraction vs. Follow-up-Length Simulator
- **Section:** 10.4
- **What it does:** Sliders for true simulated cure fraction and trial follow-up duration regenerate a censored cohort and refit a mixture cure model live, showing how short/administratively-censored follow-up can manufacture a spuriously large cure estimate indistinguishable from a genuine plateau.
- **Likely packages:** `shiny, flexsurvcure, flexsurv`

---

## Chapter 11. Meta-Analysis

### Pooling Model Playground
- **Section:** 11.1-11.2
- **What it does:** Switch between fixed-effect/random-effects pooling and tau-squared estimators (DL/REML/PM); forest plot, pooled estimate, CI width, and I2/tau2/Q all redraw live — lets the user watch the interval breathe as estimator choice changes, the core 'don't model-shop' lesson.
- **Likely packages:** `shiny, meta, metafor`

### Funnel Asymmetry Lab
- **Section:** 11.3
- **What it does:** A slider controls how many small 'missing' studies are synthetically suppressed; funnel plot, Egger's test, and trim-and-fill re-run live, showing the pooled estimate chase a moving target as suppression changes — makes concrete that trim-and-fill is a sensitivity check, not a correction.
- **Likely packages:** `shiny, meta, metafor`

---

## Chapter 12. Indirect Treatment Comparisons and Network Meta-Analysis

### Bucher ITC Calculator
- **Section:** 12.2
- **What it does:** Four sliders (d_AC, SE_AC, d_BC, SE_BC) let the user vary each trial's estimate/precision and watch the indirect A-vs-B estimate and its always-wider CI update live — targets the most commonly mis-learned fact that uncertainty never cancels in an indirect comparison.
- **Likely packages:** `shiny (pure arithmetic; optionally metafor/meta to overlay a forest plot)`

### Covariate Re-Centering Explorer
- **Section:** 12.6
- **What it does:** A slider moves the covariate value at which regression-adjusted network estimates are evaluated, sliding continuously between network-mean and target-population estimates; the league-table and forest plot update live — makes concrete the reviewer complaint that network-mean-centred estimates understate effect in a sicker target population.
- **Likely packages:** `shiny, gemtc (or netmeta/metafor for a lighter version)`

---

## Chapter 13. Population-Adjusted Indirect Comparisons

### MAIC Weight & ESS Explorer
- **Section:** 13.2
- **What it does:** Sliders adjust how far the IPD trial's covariate distribution sits from the AgD trial's target means; method-of-moments weights, ESS, and the weighted treatment effect recompute live — turns 'a large ESS loss is a credibility red flag' into something watched happening in real time.
- **Likely packages:** `shiny, base R optim, optionally survival`

---

## Chapter 14. Bayesian Methods for HEOR

### Prior-Likelihood-Posterior Tug-of-War
- **Section:** 14.2
- **What it does:** Sliders for the Beta prior's alpha/beta and a new cohort's observed successes/total redraw prior density, likelihood, and the conjugate posterior with its 95% credible interval live — the clearest way to make the prior-vs-data 'tug-of-war' metaphor tangible.
- **Likely packages:** `shiny, base R dbeta/qbeta (note SHELF for elicitation-based priors)`

---

## Chapter 15. Real-World Evidence and Causal Inference

### Extreme Weights & Trimming Simulator
- **Section:** 15.4
- **What it does:** A propensity-score trimming-bounds slider over a toy/uploaded cohort live-redraws the IPTW weight distribution and recomputes the ATE, showing extreme weights dominate before trimming and stabilize after.
- **Likely packages:** `shiny, WeightIt, cobalt`

### E-value Sensitivity Dashboard
- **Section:** 15.9
- **What it does:** User inputs an effect estimate and CI (RR/OR/HR/coefficient); the app live-computes the point-estimate and CI-limit E-values with a fragile-vs-robust gauge — turns a one-off calculation into a what-if tool usable directly during write-up.
- **Likely packages:** `shiny, EValue`

---

## Chapter 16. Regression Models for HEOR Data

### Link-Function Explorer
- **Section:** 16.1
- **What it does:** Sliders for a logistic-regression coefficient and intercept reshape the predicted-probability S-curve live, with a toggle between link (log-odds) and response (probability) scale — illustrates why raw GLM coefficients mean nothing until back-transformed.
- **Likely packages:** `shiny, ggplot2, base glm()`

### Overdispersion & Zero-Inflation Visualizer
- **Section:** 16.3
- **What it does:** Sliders for Poisson mean, negative-binomial dispersion (theta), and proportion of structural zeros morph a simulated count histogram between Poisson/NB/zero-inflated shapes, with the residual-deviance/df ratio updating live.
- **Likely packages:** `shiny, MASS, pscl, ggplot2`

### Quantile Regression Tau Slider
- **Section:** 16.4
- **What it does:** A tau slider (0-1) re-fits quantreg::rq() live on toy cost/LOS data and redraws the fitted quantile line against the scatter, showing the median vs. 90th-percentile ('costly tail') estimates diverge.
- **Likely packages:** `shiny, quantreg, ggplot2`

---

## Chapter 17. Principles of Decision Modelling

### Beta Distribution Fitter
- **Section:** 17.4
- **What it does:** Sliders for a trial's reported mean probability and 95% CI width recompute method-of-moments alpha/beta live and redraw the Beta density — shows a tighter CI (bigger trial) concentrating the distribution vs a wide CI from a small arm.
- **Likely packages:** `shiny, ggplot2, base R`

### Toy Regimen ICER Explorer
- **Section:** 17.6
- **What it does:** Sliders for cost_drug and p_cure for Regimen A/B feed the chapter's own skeletal run_model() function; the ICER/NMB table recalculates live as any input varies — a minimal demonstration of why separating inputs/engine/results layers matters.
- **Likely packages:** `shiny, dplyr, tibble`

---

## Chapter 18. Decision Trees

### Diagnostic Tree ICER Dashboard
- **Section:** 18.1-18.2
- **What it does:** Sliders for TB prevalence, each test's sensitivity/specificity, and costs of tests/outcomes recompute the rollback expected cost/QALYs for both strategies live, with the ICER and a CE-plane point updating instantly — runs the exact scenario the chapter's own pitfall poses (prevalence 0.30 -> 0.10) but never executes.
- **Likely packages:** `shiny, dplyr, tibble, ggplot2 (optionally rdecision for the tree structure)`

---

## Chapter 19. Markov Cohort Models

### Cohort Trace Builder
- **Section:** 19.1 & 19.3
- **What it does:** Sliders for each outbound transition probability (stay-probability auto-computed to sum to 1) redraw the 20-cycle state-occupancy trace live, making visible how small transition-probability changes compound over many cycles.
- **Likely packages:** `shiny, base R matrix algebra, ggplot2`

### Discounting & Half-Cycle Correction Comparator
- **Section:** 19.5
- **What it does:** A discount-rate slider and a beginning/end/life-table toggle recompute total discounted QALYs/costs live from a fixed cycle stream, turning the trapezoidal-averaging explanation into a visible before/after comparison.
- **Likely packages:** `shiny, heemod, ggplot2`

### Tunnel-State Risk Shape Explorer
- **Section:** 19.6
- **What it does:** Sliders set failure-risk at each tunnel sub-state (cycle 1, 2, 3+); flat vs front-loaded time-since-entry-dependent occupancy traces and final cost/QALY totals plot side by side, showing why ignoring state-time biases short-vs-long-course comparisons.
- **Likely packages:** `shiny, heemod (state_time), ggplot2`

### SoC vs. DMT Live ICER Dashboard
- **Section:** 19.10
- **What it does:** Sliders for each arm's transition probabilities, state costs, state utilities, and discount rate recompute the full discounted 10-year cost/QALY totals and ICER live, with a CE-plane point and WTP line — the single best match in the book to 'vary a transition probability or cost and watch the ICER update live.'
- **Likely packages:** `shiny, base R or heemod, dampack::calculate_icers(), ggplot2`

---

## Chapters reviewed with no genuine candidates

- **Chapter 1. Introduction to HEOR and HTA** — Definitional/institutional content (HEOR vs. market access, HTA agency landscape, lifecycle stages, why-R case). Nothing involves a continuously-varying parameter whose effect on a result benefits from live manipulation.
- **Chapter 2. Setting Up an R Environment for HEOR** — Tooling/infrastructure (R/RStudio/Quarto install, renv, Git, Stan/JAGS toolchains, Docker). No model output or parameter relationship for a user to explore -- correctness here is procedural, not a quantity varying continuously with an input.

Chapter 5 (Data Sources and Data Management) yielded one borderline candidate 
(Validation Rule Threshold Tuner, §5.6) — included above but flagged as moderate, 
not compelling, since its live value is mostly a pass/fail count ticking up or down.

---

## Standing note for future chapters (20-35)

As each new chapter is drafted by the `heor-hta-book-writer` cron job, re-run this same 
review (read the chapter, identify genuine slider-and-live-recalculation candidates, be 
selective, say explicitly when a chapter has none) and append to this file rather than 
rebuilding it from scratch. Natural strong candidates expected ahead: Chapter 20 
(Partitioned Survival Models), Chapter 25 (PSA — tornado diagrams, CEACs, the Dirichlet/
Cholesky machinery flagged but deferred from Ch.19 §19.8), Chapter 26 (VOI/EVPI/EVPPI), 
and the budget-impact-model chapters, all of which are classically well-suited to live 
parameter exploration.

## When we build these

Each app, when built, should get its own folder under a new top-level `shiny_apps/` 
directory (mirroring `code/`'s one-folder-per-concept convention), with its own `app.R` 
and a short README linking back to the exact book section it illustrates. Not yet built -- 
this file is the planning inventory only.
