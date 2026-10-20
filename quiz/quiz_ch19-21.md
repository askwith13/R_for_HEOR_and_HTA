# Quiz: Chapters 19-21 (Markov Cohort Models, Partitioned Survival Models, Microsimulation)

## Chapter 19: Markov Cohort Models

### Q271 [Easy] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** In the chapter's running TB example, what real-world duration does one Markov cycle represent?
- A) One month
- B) Six months
- C) One year
- D) Five years
**Answer:** B
**Explanation:** Section 19.1 defines the cycle as "a fixed unit of model time (here, six months, matching the typical duration of intensive-phase decision-making in TB care)."

### Q272 [Easy] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** What does the "Markov assumption" (memorylessness) state about a cohort model's transition probabilities?
- A) They depend only on the patient's current state, not on how they got there or how long they have been there
- B) They must always equal 0.5 for a fair model
- C) They depend only on the patient's age, never on their current state
- D) They must be identical across all health states
**Answer:** A
**Explanation:** Section 19.1 defines the Markov assumption as memorylessness: "the probability of each future transition depends only on the *current* state, never on how a patient got there or how long they have been in it."

### Q273 [Medium] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** According to the §19.1 pitfall box, what is one of the most common and dangerous bugs in building a Markov transition matrix?
- A) Using too many decimal places in probabilities
- B) A row that does not sum exactly to 1, silently leaking or fabricating probability mass each cycle
- C) Naming states in lowercase instead of uppercase
- D) Starting the cohort in more than one state at time 0
**Answer:** B
**Explanation:** The pitfall explains that a row not summing to 1 causes probability mass to "silently leak out of (or is fabricated into) the cohort every cycle," an error that compounds invisibly over many cycles.

### Q274 [Easy] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** What characterizes a "time-homogeneous" transition matrix, as defined in §19.2?
- A) It changes every cycle based on calendar year
- B) The same transition probabilities apply regardless of cycle number or how long the cohort has been running
- C) It only applies to the first cycle of the model
- D) It requires a different matrix for each patient
**Answer:** B
**Explanation:** Section 19.2 states the §19.1 matrix is time-homogeneous because "the same four probabilities apply in cycle 1, cycle 10, and cycle 20, regardless of how long the cohort has been running or how old a given patient is."

### Q275 [Medium] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** Why does §19.2 say a single fixed probability of treatment failure can bias a comparison between a 4-month and a 6-month TB regimen?
- A) Because failure risk is classically front-loaded, so a single averaged probability overstates late-cycle risk and understates early-cycle risk, mattering for how much cost/QALY is already "banked" when failure occurs
- B) Because longer regimens always have lower absolute costs
- C) Because transition matrices cannot be compared across regimens of different lengths at all
- D) Because the cure state is absorbing in both regimens
**Answer:** A
**Explanation:** Section 19.2 explains TB failure risk is "front-loaded," so a flat average probability misrepresents the timing of failure, which matters because "the *timing* of failure within the course matters for how much cost and QALY loss is already 'banked' by the time it happens."

### Q276 [Medium] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** In the §19.3 base-R code, what does `stopifnot(all(abs(rowSums(P) - 1) < 1e-9))` accomplish?
- A) It normalizes every row to sum to 1 automatically
- B) It is a defensive check that halts execution unless every row of the transition matrix sums (within floating-point tolerance) to exactly 1
- C) It discounts the trace by the per-cycle discount rate
- D) It applies half-cycle correction to the trace
**Answer:** B
**Explanation:** The code comment labels this line "Defensive check: every row must sum to exactly 1," directly operationalizing the §19.1 pitfall about verifying row sums before running any cycles.

### Q277 [Medium] [Image]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** IMAGE PLACEHOLDER: a stacked-area chart titled "Full 20-cycle state-occupancy trace from the base-R cohort loop," with bands for On Treatment, Cured, Treatment Failure, and Death stacked over cycles 0-20, as described in the §19.3 figure caption. Based on the chapter's narrative of this trace, which description is correct?
- A) On Treatment mass drains rapidly in the first 1-2 cycles, most settling into Cured, with Death's share climbing monotonically across all 20 cycles
- B) Death's share decreases steadily as cured patients return to Death over time
- C) Treatment Failure grows to dominate the trace by cycle 20
- D) On Treatment remains the largest state throughout all 20 cycles
**Answer:** A
**Explanation:** The figure caption states "Mass drains rapidly out of On Treatment in the first 1-2 cycles, with most of it settling into Cured... Death's share (grey) climbs monotonically across all 20 cycles, as it must for an absorbing state."

### Q278 [Easy] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** In `heemod::define_transition()`, what does the keyword `C` mean when used in place of an explicit probability value?
- A) It denotes the "Cured" state by abbreviation
- B) It means "fill in whatever makes this row sum to 1" -- the complementary remainder probability
- C) It forces that cell's value to be a constant across all cycles
- D) It marks the cell as a calibration target
**Answer:** B
**Explanation:** Section 19.4 explains that `define_transition()` "crucially supports the keyword `C` to mean 'fill in whatever makes this row sum to 1' -- exactly the complementary 'remainder' probability computed by hand in §19.1."

### Q279 [Medium] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** Per §19.4, when should a modeller choose `hesim` over `heemod` for a cohort model?
- A) Only when the model has fewer than four states
- B) When patient subgroups, covariate-varying transition probabilities, or PSA machinery built into the object model from the start are needed
- C) Only when no CRAN package is available
- D) Whenever half-cycle correction is not required
**Answer:** B
**Explanation:** Section 19.4 states: "Choose `hesim` over `heemod` when you need patient subgroups, covariate-varying transition probabilities, or PSA machinery built into the object model from the start, rather than bolted on afterward."

### Q280 [Medium] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** NICE's reference case specifies a 3.5% annual discount rate. What is the approximate equivalent per-six-month-cycle rate used in §19.5?
- A) 3.5%
- B) 7.0%
- C) About 1.735%
- D) 0.35%
**Answer:** C
**Explanation:** Section 19.5 converts the annual rate using $(1.035)^{0.5} - 1 \approx 0.01735$, "i.e. about 1.735% per half-year cycle."

### Q281 [Hard] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** What specifically does half-cycle correction (the trapezoidal/life-table method) fix in a cohort Markov trace?
- A) The bias from assuming transitions happen only at cycle boundaries, by averaging each cycle's start- and end-of-cycle occupancy instead of using one endpoint for the whole interval
- B) The row-sum-to-1 violation caused by copy-paste errors
- C) The double-counting of background and disease-specific mortality
- D) The lack of Dirichlet correlation among transition matrix cells
**Answer:** A
**Explanation:** Section 19.5 explains the raw trace assumes patients occupy a state for the whole cycle, when transitions actually occur at varying points within it; the trapezoidal/life-table fix "approximates each cycle's contribution as the *average* of the occupancy at the start and at the end of the cycle."

### Q282 [Medium] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** The §19.6 pitfall box warns against a common tunnel-state implementation error. What is it?
- A) Tracking cycles since model start rather than cycles since entry into the current state, which mishandles the Fail -> OnTx back-edge
- B) Using `heemod`'s `model_time` variable instead of `state_time`
- C) Defining too many tunnel sub-states for a short treatment course
- D) Applying half-cycle correction twice to tunnel states
**Answer:** A
**Explanation:** The pitfall states a tunnel implementation "must reset the counter at every (re-)entry event, not read it off the global cycle index, or failure/relapse patients will be assigned the wrong column of the tunnel," since the Fail -> OnTx back-edge means a re-entering patient restarts their own on-treatment clock.

### Q283 [Hard] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** Per §19.7, which approach to combining disease-specific and background mortality does NICE DSU guidance recommend as the more defensible default?
- A) The maximum-of-two-probabilities approach, because it is simpler
- B) Simply adding the two probabilities together
- C) The additive-hazard approach -- converting both probabilities to hazards, summing them, then converting back -- because hazards are additive by construction
- D) Ignoring background mortality entirely in lifetime-horizon models
- **Answer:** C
**Explanation:** Section 19.7 states "NICE DSU guidance... recommends the hazard-based combination as the more defensible default, reserving the max-probability shortcut for cases where background mortality is negligible next to disease-specific risk."

### Q284 [Medium] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** Why does §19.8 recommend a Dirichlet distribution, rather than independent Betas per cell, for PSA sampling of a transition matrix row?
- A) Because Dirichlet draws are always faster to compute than Beta draws
- B) Because sampling each cell independently from its own Beta would, in general, produce a row that no longer sums to 1, breaking the Markov constraint
- C) Because Beta distributions cannot be used for probabilities at all
- D) Because the Dirichlet distribution is required by `heemod`'s `define_transition()` syntax
**Answer:** B
**Explanation:** Section 19.8 explains that "every row of a transition matrix must sum to exactly 1... Sampling each cell of a row from its own independent Beta distribution... will, in general, produce a row that no longer sums to 1," and the Dirichlet is "specifically defined over vectors whose entries sum to 1."

### Q285 [Hard] [MCQ]
**Chapter(s):** 19 (Markov Cohort Models)
**Question:** In the §19.10 worked chronic-disease CEA (DMT vs SoC), what ICER (per QALY) results from the discounted 10-year totals?
- A) About £7,600 per QALY
- B) About $24,685 per QALY
- C) About $56,918 per QALY
- D) About $1.12 per QALY
**Answer:** B
**Explanation:** The worked example computes incremental cost of $27,600.92 divided by incremental QALYs of 1.1181, giving "an ICER of $27600.92 / 1.1181 = 24685$ per QALY gained."

## Chapter 20: Partitioned Survival Models

### Q286 [Easy] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** What are the three health states in a standard Partitioned Survival Model (PSM)?
- A) Well, Diseased, Dead
- B) Pre-progression (on treatment, alive), Post-progression (alive, progressed), Death
- C) On Treatment, Cured, Treatment Failure
- D) Healthy, Undetected, Detected
**Answer:** B
**Explanation:** Section 20.1 states "The model has three health states: pre-progression (on treatment, alive, not yet progressed), post-progression (alive, progressed), and death."

### Q287 [Easy] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** In a PSM, how is state occupancy obtained, as opposed to a Markov model?
- A) It is estimated via a transition matrix, exactly as in Chapter 19
- B) It is read directly off two independently fitted survival curves (PFS and OS), with no transitions estimated or elicited
- C) It requires individual patient simulation
- D) It is calculated from a life table only
**Answer:** B
**Explanation:** Section 20.1 states "No transitions are estimated or elicited. Occupancy falls straight out of the two curves" -- PFS and OS.

### Q288 [Medium] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** What is the formula for P(Progressed) at time t in a PSM, using the PFS survival function $S_{PFS}(t)$ and OS survival function $S_{OS}(t)$?
- A) $S_{PFS}(t) \times S_{OS}(t)$
- B) $1 - S_{OS}(t)$
- C) $S_{OS}(t) - S_{PFS}(t)$
- D) $S_{PFS}(t) + S_{OS}(t)$
**Answer:** C
**Explanation:** Section 20.1 gives $P(\text{Progressed}) = S_{OS}(t) - S_{PFS}(t)$.

### Q289 [Medium] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** Why does §20.1's pitfall box call curve crossing a "structural flaw" rather than a coding bug?
- A) Because Markov models have the exact same flaw
- B) Because the formula $S_{OS}(t) - S_{PFS}(t)$ has no constraint forcing it to stay non-negative, unlike Markov occupancy which is a probability by construction
- C) Because flexsurvreg() always produces crossing curves
- D) Because PSMs do not use parametric extrapolation
- **Answer:** B
**Explanation:** The pitfall states the formula "has no constraint forcing it to stay non-negative... this is not a coding bug to patch around; it is a structural flaw of PSMs that a proper state-transition (Markov) model cannot produce, because Markov occupancy is always a probability by construction."

### Q290 [Easy] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** Which R function, already introduced in Chapter 10, is used (twice, independently) to fit PFS and OS curves in §20.2?
- A) `define_transition()`
- B) `flexsurvreg()`
- C) `create_IndivCtstmTrans()`
- D) `calculate_icers()`
**Answer:** B
**Explanation:** Section 20.2 states "Nothing new is needed to fit the curves -- this is the same `flexsurvreg()` workflow from Chapter 10, run twice: once on PFS data, once on OS data."

### Q291 [Medium] [Image]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** IMAGE PLACEHOLDER: a two-panel figure titled "State-occupancy trace for the §20.6 PSM, SOC vs new drug," each panel a stacked area bounded below by the OS curve, with PFS, Progressed, and Dead bands summing to 100% across a 10-year horizon. What visual check does this figure serve, per §20.5/20.6?
- A) Confirming the discount rate was applied correctly
- B) Confirming the PFS and Progressed/Dead boundaries never cross within either panel -- the visual counterpart of the no-crossing check
- C) Confirming that costs are higher in the new-drug arm
- D) Confirming that utility weights sum to 1
**Answer:** B
**Explanation:** The figure caption explicitly states the PFS and Progressed/Dead boundaries "never cross within either panel over the full 10-year horizon -- the visual counterpart of the no-crossing check reported alongside the discounted cost and QALY totals."

### Q292 [Hard] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** What does a "treatment waning" assumption specify, as discussed in §20.3?
- A) That the treatment's hazard ratio holds forever, unchanged, across the lifetime horizon
- B) That the treatment's survival benefit tapers, often linearly, to zero over some stated number of years after the trial ends
- C) That PFS and OS curves must use the same parametric family
- D) That the discount rate declines over time
**Answer:** B
**Explanation:** Section 20.3 defines waning: "the treatment's benefit tapers -- often linearly -- to zero over some stated number of years after the trial ends."

### Q293 [Medium] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** According to §20.3's agency note, what does NICE DSU TSD 14 require of analysts regarding extrapolated relative treatment effects?
- A) Nothing -- any extrapolation choice is acceptable without justification
- B) To justify their chosen extrapolation, including any assumption about whether/how the treatment effect wanes, rather than defaulting to indefinite benefit
- C) To always assume the hazard ratio is zero after trial follow-up ends
- D) To avoid using hazard ratios altogether
**Answer:** B
**Explanation:** The agency note states NICE DSU TSD 14 "requires analysts to justify their chosen extrapolation -- including any assumption about whether and how a treatment effect wanes after the trial period -- rather than defaulting to indefinite benefit."

### Q294 [Medium] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** In the custom `psm_occupancy()` function shown in §20.4, what does the `pmax(0, s_os - s_pfs)` expression accomplish?
- A) It applies half-cycle correction
- B) It floors the progressed-state probability at zero, serving as a first line of defence against curve crossing
- C) It discounts the progressed-state probability
- D) It converts probabilities into hazards
**Answer:** B
**Explanation:** The chapter states: "That `pmax(0, ...)` is doing real work: it is the first line of defence against the curve-crossing problem flagged in Section 20.1."

### Q295 [Easy] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** Per §20.4, what is the chapter's recommended "safest habit" when a package's API for a PSM-specific feature (like `hesim`'s PSM module) is a moving target across versions?
- A) Copy code from an old blog post
- B) Fit curves with the stable `flexsurvreg()`, then check the installed package's own vignette before calling anything PSM-specific
- C) Avoid `hesim` entirely and always hand-code every PSM
- D) Pin the package to a version from several years ago
**Answer:** B
**Explanation:** The agency note recommends: "fit your survival curves with the stable, well-documented `flexsurvreg()`, then check the installed package's own vignette... before calling anything PSM-specific, rather than trusting code you found in an older blog post."

### Q296 [Medium] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** Per §20.5, which limitation applies to a PSM but NOT to a Markov cohort model?
- A) Both can represent tunnel states and multiple progression lines equally well
- B) A PSM has a fixed three-state structure with no room for tunnel states or multiple progression lines that `heemod::define_state()` could add to a Markov model
- C) PSMs always require fewer parameters than Markov models
- D) PSMs cannot use parametric survival curves
**Answer:** B
**Explanation:** Section 20.5 states: "A PSM has exactly three states -- PFS, Progressed, Death. There is no room for the tunnel states or multiple progression lines that `heemod::define_state()` could add to a Markov model."

### Q297 [Hard] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** Why does §20.5 say PSM extrapolation uncertainty from the two arms "compound rather than cancel"?
- A) Because PFS and OS curves for each arm are fit completely independently, so nothing in the model enforces consistency between arms beyond what the analyst imposes
- B) Because both arms always use the exact same parametric family
- C) Because Markov models fit each arm's curves jointly, unlike PSMs
- D) Because PSMs do not allow any treatment-effect assumption at all
**Answer:** A
**Explanation:** Section 20.5 explains "A PSM... fits each arm's PFS and OS curves completely independently. Nothing in the model enforces consistency between arms... Two separate extrapolations also means two separate sources of extrapolation uncertainty. They compound rather than cancel."

### Q298 [Medium] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** In the §20.6 worked oncology CEA, what ICER (£ per QALY) results from comparing the new drug to standard of care (SOC)?
- A) About £7,937 per QALY
- B) About £10,077 per QALY
- C) About £25,371 per QALY
- D) About £18,014 per QALY
**Answer:** C
**Explanation:** The chapter computes the incremental cost of £7,936.57 divided by the incremental QALY gain of 0.3128, giving "ICER = 7936.57 / 0.3128 \approx 25371 £/QALY."

### Q299 [Hard] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** What common limitation do BOTH the Chapter 19 Markov cohort model and the Chapter 20 PSM share, as noted at the end of §20.6?
- A) Neither can apply discounting
- B) They track the mean proportion of a hypothetical cohort in each state, cycle by cycle, which breaks down once a patient's own history (e.g., cumulative exposure, time already progression-free) matters
- C) Neither can represent more than two health states
- D) Both require individual patient-level random number streams
**Answer:** B
**Explanation:** The chapter's closing passage states both models "track the *mean* proportion of a hypothetical cohort in each state... That's enough when cost and outcomes depend only on current state. It breaks down once a patient's own history matters."

### Q300 [Medium] [MCQ]
**Chapter(s):** 20 (Partitioned Survival Models)
**Question:** Per §20.2's heor-practice note, how should an analyst choose the parametric family (Weibull, log-normal, etc.) separately for PFS and OS curves?
- A) By AIC/BIC alone, ignoring clinical plausibility
- B) By forcing both curves into the same family for tidiness
- C) By AIC/BIC *and* clinical plausibility, assessed separately for each curve, without forcing both into the same family
- D) By always defaulting to the exponential distribution
**Answer:** C
**Explanation:** The heor-practice box instructs: "Fit PFS and OS independently, pick the best-fitting family for each by AIC/BIC *and* clinical plausibility separately... do not force both curves into the same family just for tidiness."

## Chapter 21: Individual-Level State-Transition Models (Microsimulation)

### Q301 [Easy] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** What is microsimulation, as defined in §21.1?
- A) A model that only tracks aggregate cohort proportions
- B) Simulating one patient at a time, cycle by cycle, keeping track of each patient's own state, time, and accumulated history
- C) A method exclusively for fitting survival curves
- D) A deterministic sensitivity analysis technique
**Answer:** B
**Explanation:** Section 21.1 defines microsimulation (individual patient simulation, IPS) as simulating "one patient at a time, cycle by cycle, keeping track of each patient's own state, time, and accumulated history."

### Q302 [Easy] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** Which of the following is NOT one of the three situations §21.1 lists as pushing a model toward microsimulation?
- A) Risk that depends on cumulative exposure
- B) Risk that depends on time already spent in a state
- C) Costs or outcomes that depend on treatment-line history
- D) The model having more than four health states
- **Answer:** D
**Explanation:** Section 21.1's pitfall explicitly warns: "Do not reach for microsimulation just because a model is 'complex' or has many health states... The decision to move to microsimulation should be driven specifically by heterogeneity or history dependence, not by state count."

### Q303 [Medium] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** Per §21.2, what is "patient heterogeneity" as distinct from "history dependence"?
- A) Heterogeneity is between-patient variation existing at model entry (age, sex, comorbidities); history dependence is within-patient variation emerging during the simulation based on what already happened
- B) They are two names for exactly the same concept
- C) Heterogeneity only applies to costs; history dependence only applies to utilities
- D) Heterogeneity is the clock-reset time scale; history dependence is the clock-forward time scale
**Answer:** A
**Explanation:** Section 21.2 states heterogeneity "already exists when a patient enters the model," while history dependence is "what happens next depends on what has already happened to that same patient... they emerge during the simulation, not at baseline."

### Q304 [Medium] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** In a multi-state model's time-scale terminology (§21.2), what distinguishes "clock-forward" from "clock-reset" time?
- A) Clock-forward measures time since model entry overall; clock-reset measures time since the patient most recently entered the current state, resetting at every transition
- B) Clock-forward only applies to PSA; clock-reset only applies to the base case
- C) Clock-forward is used exclusively in Markov cohort models; clock-reset is used exclusively in PSMs
- D) They are interchangeable terms for the discount rate
**Answer:** A
**Explanation:** Section 21.2 explains "clock-forward" measures "time since the patient entered the model overall," remaining Markov, while "clock-reset" measures "time since the patient most recently entered their *current* state," resetting at every transition, making it semi-Markov.

### Q305 [Hard] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** In `hesim`'s `IndivCtstmTrans` class, what does the `clock` argument control?
- A) The number of PSA samples to draw
- B) Whether transitions use "forward" (time since model start), "reset" (time since entering current state), or a "mix" across transitions
- C) The computer's system clock for random seed generation
- D) The discount rate applied to costs vs QALYs
**Answer:** B
**Explanation:** Section 21.2 states the `clock` argument "accepts 'forward', 'reset', or a mix of the two across different transitions," giving a direct way to specify history-dependence per transition.

### Q306 [Medium] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** Per §21.3, what is the correct build order for an efficient microsimulation model?
- A) Parallelize first, then vectorize, then move to data.table
- B) Write a correct but slow version first and validate it, then vectorize the patient loop, then move history into data.table, then parallelize the PSA loop last
- C) Parallelize the patient loop before vectorizing anything
- D) Skip vectorization entirely and rely only on parallel computing
**Answer:** B
**Explanation:** The heor-practice box lays out exactly this sequence: write a slow correct version, validate, vectorize the patient loop, move to data.table, "only once (1)-(3) are done, wrap the whole single-PSA-sample function in `mclapply()` across PSA samples."

### Q307 [Medium] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** Why does §21.3 say parallel computing should target the PSA loop rather than the inner patient loop?
- A) Because patients cannot be simulated at all in R
- B) Because each PSA sample runs an entire self-contained simulation with no dependency on other samples ("embarrassingly parallel"), while patient-level parallelization is complicated by shared random-number streams needed for CRN
- C) Because `data.table` cannot be used inside a parallel loop
- D) Because the patient loop is already infinitely fast
**Answer:** B
**Explanation:** Section 21.3 states the PSA loop is "embarrassingly parallel" since "one PSA sample's result never depends on another's," while patient-level parallelization is "a harder parallelisation target" due to shared random-number streams for CRN (deferred to §21.5).

### Q308 [Medium] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** What is "first-order uncertainty" in a microsimulation, per §21.4?
- A) Parameter uncertainty from PSA draws of hazard ratios or costs
- B) Patient-level variability -- different simulated patients taking different paths purely from chance, with all parameters fixed
- C) Uncertainty about which R package to use
- D) Structural uncertainty about model type choice
**Answer:** B
**Explanation:** Section 21.4 defines first-order uncertainty as patient-level variability: with "every parameter in the model" fixed, "each one takes a different path through the state structure, purely because of chance draws."

### Q309 [Hard] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** Per §21.4, what is the correct fix if a PSA on a microsimulation model shows a noisier, flatter cost-effectiveness acceptability curve than the true parameter uncertainty justifies?
- A) Switch to a different PSA method entirely
- B) Simulate more patients per parameter draw, shrinking first-order noise relative to the genuine parameter-uncertainty spread
- C) Reduce the number of PSA parameter draws
- D) Remove the discount rate from the calculation
**Answer:** B
**Explanation:** The pitfall states "The fix is not a different PSA method -- it is simply simulating more patients per parameter draw until first-order noise is small relative to the spread you are trying to characterise."

### Q310 [Hard] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** What is "common random numbers" (CRN), as explained in §21.5?
- A) Using a different independent random stream for each treatment arm to maximize variance
- B) Reusing the identical random-number stream across arms, so the same simulated patient under different strategies has chance-driven noise that cancels out of the incremental comparison
- C) A method for calibrating transition probabilities to registry data
- D) A technique exclusively for discounting future costs
**Answer:** B
**Explanation:** Section 21.5 explains that with CRN "you reuse the identical stream across arms... the part of the outcome driven by chance (not by treatment) is correlated across arms, and it cancels out when you compute the incremental difference."

### Q311 [Medium] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** Per the §21.5 pitfall, what breaks CRN's variance-reduction benefit when adding a third treatment strategy?
- A) Adding a third arm is always safe and requires no precautions
- B) If the new arm's code calls a different number of random functions before reaching the key step (e.g., one extra `rnorm()` call), every subsequent draw shifts out of alignment, silently breaking the cross-arm correlation
- C) CRN automatically re-aligns itself across any number of arms
- D) A third arm requires doubling the discount rate
**Answer:** B
**Explanation:** The pitfall warns that an extra random-number call "shifts out of alignment with the other arms, and the correlation that CRN relies on silently breaks... It will just no longer be variance-reduced."

### Q312 [Medium] [Image]
**Chapter(s):** 21 (Microsimulation)
**Question:** IMAGE PLACEHOLDER: a bar chart titled "Detection pathway by arm" comparing No screening vs Screening arms across categories (self-presentation, screening detection, detected within 2 years), from the §21.7 common-random-numbers microsimulation of a TB screening programme (N=1,000 patients, 20 annual cycles). What is the correct interpretation of this chart per the chapter text?
- A) Screening increases the total number of patients eventually detected
- B) Screening shifts detections earlier -- 78 more patients detected within 2 years of onset -- without changing the total number eventually detected
- C) Screening has no effect on detection timing or totals
- D) Self-presentation detections increase under screening
**Answer:** B
**Explanation:** The figure caption states screening "shifts detections earlier — 78 more patients detected within 2 years of onset — without changing the total number eventually detected, exactly the timing-shift mechanism."

### Q313 [Hard] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** In the §21.7 worked TB screening example, why does the "Patients ever Undetected TB" count (312) come out identical across both arms?
- A) Because screening prevents TB onset entirely
- B) Because CRN means both arms progress the same patients through disease onset using the same random draws in the same cycles, so onset itself does not differ between arms
- C) Because the model caps undetected TB cases at 312 by design
- D) Because self-presentation and screening detection are mutually exclusive by definition
**Answer:** B
**Explanation:** The chapter states: "The 'Patients ever Undetected TB' row is identical across arms by construction: CRN means both arms progress the same patients through disease onset in the same cycles, so any difference in the remaining rows is attributable to the detection rule, not to simulation noise."

### Q314 [Easy] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** Which `hesim` method must be called FIRST, before `$sim_stateprobs()`, `$sim_qalys()`, or `$sim_costs()` can be used on an `IndivCtstm` object?
- A) `$sim_disease()`
- B) `create_StateVals()`
- C) `expand()`
- D) `hesim_data()`
**Answer:** A
**Explanation:** Section 21.6 states "`$sim_disease()` must run first -- it generates and stores each patient's individual path through the state structure... before the other sim_ methods can use it."

### Q315 [Hard] [MCQ]
**Chapter(s):** 21 (Microsimulation)
**Question:** Why does the §21.7 chapter deliberately avoid attaching a precise ICER to the TB screening worked example?
- A) Because R cannot compute division
- B) Because the example is illustrative/synthetic, not fitted to real TB epidemiology, so an invented cost-effectiveness figure would not be honest; the mechanism (a timing shift in detection) is what can be honestly demonstrated
- C) Because screening is never cost-effective
- D) Because ICERs cannot be calculated from microsimulation models in principle
**Answer:** B
**Explanation:** The chapter states explicitly: "this sketch is illustrative, not fitted to real TB epidemiology, so it is not honest to attach a precise ICER to it... this worked example stops at the mechanism rather than inventing a monetary result."
