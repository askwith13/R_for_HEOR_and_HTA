# Quiz Questions: Chapters 22–24

## Chapter 22: Discrete Event Simulation and Dynamic Models

### Q316 [Easy] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** In `simmer`'s documentation, what is the term for one simulated individual moving through a DES model (e.g., one patient or one specimen)?
- A) A cohort
- B) An entity (or arrival)
- C) A compartment
- D) A node
**Answer:** B
**Explanation:** The chapter's difficult-terminology box defines an entity — called an "arrival" in `simmer`'s own documentation — as one simulated individual, distinct from a microsimulation "patient" because it can wait behind, and be served alongside, other entities.

### Q317 [Easy] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** What is the "event queue" in a DES engine?
- A) The physical line of patients waiting for a nurse
- B) The simulation engine's internal time-ordered to-do list of scheduled events
- C) A record of which resources are currently at full capacity
- D) The sequence of annual cycles in a Markov model
**Answer:** B
**Explanation:** The text is explicit that the event queue is not the patients' waiting line but the engine's internal to-do list ordered by time, which `simmer` manages for you and which explains why DES output is driven by *when* things happen rather than a fixed clock tick.

### Q318 [Medium] [Image]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** IMAGE PLACEHOLDER: a diagram of a single-nurse M/M/1 queue showing patient arrivals, a waiting line, and the nurse resource at capacity 1, as described in section 22.2. Based on the chapter's worked example (arrival rate λ = 1/10/min, service rate μ = 1/8/min), what is the nurse's utilisation (ρ)?
- A) 0.5
- B) 0.8
- C) 1.25
- D) 0.2
**Answer:** B
**Explanation:** Utilisation ρ = λ/μ = (1/10)/(1/8) = 0.8, meaning the nurse is busy 80% of the time — exactly the figure given in the chapter's closed-form M/M/1 benchmark.

### Q319 [Easy] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** What is a DES "attribute," as defined in section 22.1?
- A) The capacity of a resource
- B) A piece of data an entity carries with it, equivalent to a patient-level covariate in microsimulation
- C) The name assigned to a trajectory object
- D) The random seed used for the simulation run
**Answer:** B
**Explanation:** The chapter defines an attribute as data an entity carries through the model (e.g., `smear_positive = 1`, `age = 34`), explicitly calling it the DES equivalent of a patient-level covariate from the microsimulation chapter.

### Q320 [Medium] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** What is a "trajectory" in `simmer`?
- A) The time path of the S, I, and R compartments in an SIR model
- B) The template path an entity follows (e.g., arrive → queue for nurse → be screened → leave), built once and reused by every arriving entity
- C) The queue length over the duration of a simulation run
- D) The function that draws inter-arrival times
**Answer:** B
**Explanation:** The chapter describes a trajectory as the template path an entity follows, built once as an R object with `trajectory()` and then sent to every arriving patient as a copy — the DES analogue of Chapter 20's state-transition diagram, but tied to resources and durations.

### Q321 [Hard] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** Using the chapter's M/M/1 closed-form benchmark with λ = 1/10 per minute and μ = 1/8 per minute, what is the expected steady-state wait in queue, W_q?
- A) 8 minutes
- B) 40 minutes
- C) 32 minutes
- D) 4 minutes
**Answer:** C
**Explanation:** The heor-practice box computes W_q = ρ/(μ − λ) = 0.8/(1/8 − 1/10) = 0.8/0.025 = 32 minutes, which a long enough `simmer` run of the model should converge toward.

### Q322 [Medium] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** According to the chapter's pitfall box, what is the single most common `simmer` coding error when using `rexp()` for inter-arrival or service times?
- A) Forgetting to call `set.seed()`
- B) Passing a mean inter-event time where `rexp()` expects a rate parameter
- C) Using `seize()` before `add_resource()`
- D) Omitting `release()` after `seize()`
**Answer:** B
**Explanation:** `rexp(n, rate)` is parameterised by rate, not mean; an average inter-arrival time of 10 minutes is `rate = 1/10`, not `rate = 10`, and swapping this silently produces an absurdly congested or absurdly empty model rather than an error.

### Q323 [Hard] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** Section 22.3 identifies a genuine gap in `simmer`'s API when modelling competing time-to-event hazards (e.g., "complete screening" vs. "lost to follow-up" vs. "referral"). What is that gap?
- A) `simmer` cannot model resources with capacity greater than 1
- B) `timeout()` only accepts one pre-resolved duration; it has no native primitive to race multiple clocks and take the minimum
- C) `branch()` cannot be used inside a trajectory more than once
- D) `simmer` cannot record per-entity waiting times
**Answer:** B
**Explanation:** The text states this is "a genuine gap in simmer's API" — `timeout()` has no "race these N clocks and take the minimum" primitive, so the race must be resolved manually in R (via `which.min()`) before being handed to `timeout()`.

### Q324 [Medium] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** What does `simmer`'s documented `branch()` primitive do?
- A) Races several continuous-time hazards and resolves the minimum automatically
- B) Selects among N discrete sub-trajectories using an option function returning an integer, with fixed or attribute-dependent probabilities
- C) Merges two independent simulation runs into one dataset
- D) Converts a DES trajectory into a Markov transition matrix
**Answer:** B
**Explanation:** `branch()` is described as the right tool for genuinely categorical competing outcomes with fixed or attribute-dependent probabilities (e.g., 70%/20%/10% split), as opposed to racing continuous-time hazard clocks, which needs the manual workaround in Q323.

### Q325 [Medium] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** In the chapter's SIR model, what does the basic reproduction number R₀ equal?
- A) β × γ
- B) γ/β
- C) β/γ
- D) 1/(β + γ)
**Answer:** C
**Explanation:** The text defines R₀ = β/γ as the average number of secondary infections one infectious person generates in a fully susceptible population; the worked toy example uses β = 0.4, γ = 0.2, giving R₀ = 2.

### Q326 [Medium] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** In the SEIR extension of the SIR model, what does the parameter σ represent?
- A) The transmission rate per contact
- B) The rate of progression from the latent (Exposed) compartment to active infectiousness, so 1/σ is the mean latent period
- C) The recovery/removal rate from the Infectious compartment
- D) The birth rate into the Susceptible compartment
**Answer:** B
**Explanation:** The chapter defines σ as the rate of progression from latent to active disease, explicitly stating that 1/σ is the mean latent period — the added mechanism that captures TB's delay between infection and infectiousness.

### Q327 [Medium] [Image]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** IMAGE PLACEHOLDER: the infectious-compartment (I) epidemic curve over 180 days from the toy SIR model in section 22.4 (R₀ = 2, population 10,000, one initial case), showing a rise-peak-decline shape. According to the chapter's worked numbers, around what day does the infectious compartment peak, and what fraction of the population is infectious at that peak?
- A) Day 90; about 50%
- B) Day 45; about 15%
- C) Day 180; about 80%
- D) Day 10; about 2%
**Answer:** B
**Explanation:** The text states that for this toy parameterisation the peak occurs around day 45, with roughly 15% of the population infectious at once, before the susceptible pool is depleted and the epidemic declines.

### Q328 [Medium] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** Within the `EpiModel` package, which function family simulates disease spread over an explicit, fitted contact network (built with `netest()`/`ergm`/`tergm`)?
- A) `dcm()`
- B) `icm()`
- C) `netsim()`
- D) `ode()`
**Answer:** C
**Explanation:** The chapter describes `EpiModel`'s spectrum: `dcm()` for deterministic compartmental models (equivalent to `deSolve`), `icm()` for stochastic individual-level models without an explicit network, and `netsim()` for full stochastic network models built on a `netest()`-fitted contact network.

### Q329 [Hard] [MCQ]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** Per the chapter's pitfall (citing Pitman et al.'s ISPOR-SMDM Task Force-5 report), what is the specific methodological risk of using a static model for an infectious-disease intervention?
- A) It overstates the intervention's cost because it double-counts administration costs
- B) It systematically mis-estimates benefit because it misses indirect/herd protection — one person's treatment also reduces risk to those they would otherwise have infected
- C) It cannot compute a QALY at all
- D) It requires a longer time horizon than a dynamic model
**Answer:** B
**Explanation:** A static model assumes the force of infection is unaffected by the intervention and so misses indirect protection, which can make it substantially understate benefit, particularly for interventions delivered at a scale that meaningfully dents transmission (e.g., mass vaccination or population-wide active case finding).

### Q330 [Hard] [Image]
**Chapter(s):** 22 — Discrete Event Simulation and Dynamic Models
**Question:** IMAGE PLACEHOLDER: SEIR epidemic curves for the no-intervention baseline vs. the 30%-effective TB screening/preventive-therapy programme over a 10-year horizon, as in section 22.6 (figure `fig-ch22-seir`). Per the chapter's worked arithmetic, approximately how many infections per 100,000 population are averted by the programme over 10 years?
- A) About 873
- B) About 4,979
- C) About 4,106
- D) About 1,264
**Answer:** C
**Explanation:** The no-intervention run accumulates ~4,979 infections per 100,000 and the 30%-effective programme accumulates ~873, a difference of about 4,106 infections averted (~82% reduction), with the gap widening over time because averted infections also avert the onward infections they would have caused.

## Chapter 23: Budget Impact Analysis

### Q331 [Easy] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** How does the chapter distinguish the core question of budget impact analysis (BIA) from cost-effectiveness analysis (CEA)?
- A) BIA asks whether an intervention is good value per QALY over a lifetime; CEA asks what it costs the budget next year
- B) BIA asks what a specific payer's cash budget will do over the next 1–5 years; CEA asks whether the intervention is good value per QALY, typically over a lifetime
- C) They ask the identical question but BIA uses a different discount rate
- D) BIA only applies to vaccines, CEA only applies to drugs
**Answer:** B
**Explanation:** The chapter states a payer wants to know what adding an intervention will do to cash budget over the next one to five years, which is a fundamentally different question from CEA's lifetime, societal/system-perspective cost-per-QALY judgement — a drug can be cost-effective yet unaffordable in the short term, or vice versa.

### Q332 [Easy] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** Per ISPOR's 2014 Budget Impact Analysis Good Practice II Task Force report (Sullivan et al.), how should BIA cash flows typically be presented?
- A) Discounted at the societal discount rate, exactly like a CEA
- B) Undiscounted, because a payer's budget is set and spent in nominal terms year by year
- C) As a single lifetime net present value
- D) Only as a ratio of cost to QALYs
**Answer:** B
**Explanation:** The chapter's pitfall box is explicit that ISPOR guidance recommends BIA cash flows be presented undiscounted in the base case, since the budget is spent in nominal terms year by year, not in present-value terms as in CEA.

### Q333 [Medium] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** Which of the following is one of the five core structural requirements the chapter attributes to the Sullivan et al. (2014) ISPOR BIA Good Practice report?
- A) The eligible population must be assumed to switch to the new intervention entirely on day one
- B) An explicit comparison of a reference scenario (without the new intervention) against a new scenario, with budget impact reported as the difference between them
- C) Costs must be discounted at the same rate as a lifetime CEA
- D) Health outcomes (QALYs) must be included in the budget impact calculation
**Answer:** B
**Explanation:** The agency-note lists five requirements, including an explicit comparison of a "world without" (reference) scenario against a "world with" (new) scenario, reporting budget impact as the year-by-year difference — the opposite of assuming instant 100% uptake or including QALYs.

### Q334 [Medium] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** According to the chapter's pitfall box, why is it wrong to build a BIA by simply re-running the CEA model's cohort over a shorter horizon?
- A) The CEA cohort represents incident patients, assumes 100% uptake, and uses discounted costs — none of which match a BIA's mixed prevalent-plus-incident population, gradual uptake, and undiscounted nominal costs
- B) CEA models cannot be coded in R
- C) The CEA model always uses a Markov structure, which BIA forbids
- D) BIA requires microsimulation, which CEA models never use
**Answer:** A
**Explanation:** The text lists three specific mismatches: the CEA cohort is typically incident-only rather than mixed prevalent-plus-incident, CEA usually assumes full uptake among eligible patients, and CEA costs are discounted whereas BIA cash flows are typically undiscounted.

### Q335 [Medium] [Image]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** IMAGE PLACEHOLDER: an eligible-population cascade funnel diagram narrowing from total covered lives through disease prevalence, diagnosis, label criteria, and contraindications to the final eligible population, as in section 23.2. Which R function is used in the chapter's cascade example to turn successive proportions into a running cumulative proportion?
- A) `cumsum()`
- B) `cumprod()`
- C) `rowSums()`
- D) `prod()` applied once to the whole vector
**Answer:** B
**Explanation:** The chapter's `population_cascade` example uses `mutate(cumulative_proportion = cumprod(proportion_of_prior_step))` to compute the running cumulative proportion applied to the covered-lives base at each narrowing step.

### Q336 [Medium] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** In the chapter's two-period market-share illustration (1,000 patients; reference scenario 70% Drug A at \$500, 30% Drug B at \$800; new scenario 20% new drug at \$1,200 displacing both proportionally), what is the correctly netted year-2 budget impact?
- A) \$240,000 (20% × 1,000 × \$1,200)
- B) \$712,000
- C) \$590,000
- D) \$122,000
**Answer:** D
**Explanation:** Reference scenario cost is \$590,000 and new scenario cost is \$712,000, so the netted budget impact is \$712,000 − \$590,000 = \$122,000 — much smaller than the naive \$240,000 "gross cost of the new drug" figure, because some of that cost replaces spending the payer was already incurring on Drugs A and B.

### Q337 [Medium] [Image]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** IMAGE PLACEHOLDER: linear vs. logistic (S-shaped) uptake/diffusion curves over a 5-year BIA horizon, both reaching a terminal market share of 0.35, as in figure `fig-ch23-uptake-curves` (section 23.2). What distinguishes the logistic curve's shape from the linear ramp?
- A) It reaches peak share faster than the linear ramp in year 1
- B) It starts slower, accelerates through the middle years, and levels off as it approaches the terminal share, rather than rising in equal increments
- C) It decreases over time while the linear ramp increases
- D) It has no terminal share and keeps rising indefinitely
**Answer:** B
**Explanation:** The chapter describes the logistic diffusion curve as starting slowly, accelerating through early adoption, and then levelling off as the addressable market saturates — the classic S-shape — in contrast to the linear ramp's equal increments each year.

### Q338 [Medium] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** Why does ISPOR guidance call for the uptake/diffusion trajectory to be explicitly stated and justified rather than assumed as an instant step-change?
- A) Because regulators require a minimum 10-year horizon for all BIAs
- B) Because real-world adoption is shaped by prescriber familiarity, guideline updates, prior-authorization processes, and launch sequencing, not instantaneous switching
- C) Because logistic curves are mathematically easier to code than step functions
- D) Because CEA models already specify the uptake curve
- **Answer:** B
**Explanation:** The chapter explains that the 20% market share example "does not appear instantly" — real-world adoption follows a diffusion curve shaped by these operational and behavioural factors, which must be evidenced (analogous launch curves, expert elicitation, market research), not assumed.

### Q339 [Medium] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** In the chapter's `build_bia()` R function, how is the net per-patient cost of the new drug computed?
- A) `cost_new + offset_new`
- B) `cost_new - offset_new`
- C) `cost_new * uptake_share`
- D) `cost_soc - offset_new`
**Answer:** B
**Explanation:** The function computes `net_cost_new <- cost_new - offset_new`, reflecting that patients on the new drug avoid a downstream hospitalization cost offset, so with `cost_new = 2000` and `offset_new = 300` the net per-patient cost is \$1,700.

### Q340 [Hard] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** Using the base-case `build_bia()` model (10,000 eligible patients/year, SoC \$500, new drug net cost \$1,700, uptake 5/15/30/45/55% over years 1–5), what is the cumulative 5-year budget impact?
- A) \$6,600,000
- B) \$25,000,000
- C) \$43,000,000
- D) \$18,000,000
**Answer:** D
**Explanation:** Summing the year-by-year budget impacts (\$600,000; \$1,800,000; \$3,600,000; \$5,400,000; \$6,600,000) gives \$18,000,000, which cross-checks against the new-mix total (\$43,000,000) minus the current-mix total (\$25,000,000).

### Q341 [Medium] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** In section 23.4's scenario analyses, how is the "faster uptake" scenario implemented relative to the base case?
- A) By changing `cost_new` while keeping uptake shares fixed
- B) By supplying a larger `uptake_share` vector (10/25/40/55/65%) to the same `build_bia()` function, with all other parameters unchanged
- C) By removing the hospitalization offset entirely
- D) By extending the time horizon to 10 years
**Answer:** B
**Explanation:** The chapter calls the faster-uptake scenario "a pure 'what-if' on the diffusion curve" — it feeds larger `patients_on_new` values into the same formula via a different `uptake_share` argument, producing a larger budget impact every year, with no new arithmetic principle.

### Q342 [Hard] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** Under the managed-entry-agreement (MEA) scenario (new drug re-priced to \$1,500, offset unchanged at \$300), what is the resulting cumulative 5-year budget impact, and how much lower is it than the base case?
- A) \$18,000,000; no change from base case
- B) \$10,500,000; \$7,500,000 lower than the base case's \$18,000,000
- C) \$35,500,000; \$17,500,000 higher
- D) \$5,000,000; \$13,000,000 lower
**Answer:** B
**Explanation:** With the net cost per patient falling to \$1,200, the five annual budget impacts sum to \$10,500,000, a reduction of \$7,500,000 from the base case's \$18,000,000 — confirmed both bottom-up (summing yearly impacts) and top-down (new-mix total minus current-mix total).

### Q343 [Medium] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** What does the chapter's agency-note say payer review templates (and NICE/CADTH guidelines) typically require regarding drug-acquisition cost and offset cost?
- A) They must be pre-netted into a single line before submission
- B) They must be reported as separate line items so the reviewer can independently judge the offset assumption's credibility
- C) Only the offset line needs to be reported
- D) Netting is required inside the R code and the report alike
**Answer:** B
**Explanation:** The chapter states that most payer templates require acquisition cost and any claimed offset to be shown as separate lines rather than netted together, even though netting inside the R code itself (to compute `net_cost_new`) is fine — reviewers want to interrogate the offset assumption on its own terms.

### Q344 [Medium] [Image]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** IMAGE PLACEHOLDER: a bar chart of annual budget impact rising from \$600,000 (Year 1) to \$6,600,000 (Year 5) with a line overlay of cumulative budget impact climbing to \$18,000,000 by Year 5, as in figure `fig-ch23-annual-cumulative-bi` (section 23.5). What is this chart's main purpose, per the chapter?
- A) To replace the year-by-year table entirely
- B) To let a payer answer "when does spend accelerate" at a glance, alongside annual (non-cumulative) figures
- C) To show the discounted present value of the budget impact
- D) To compare the BIA result against the CEA ICER
**Answer:** B
**Explanation:** The chapter describes this chart as the natural companion to the year-by-year table, letting payers see cumulative budget impact rising visually across the horizon alongside the annual figures so the "when does spend accelerate" question is answered at a glance.

### Q345 [Easy] [MCQ]
**Chapter(s):** 23 — Budget Impact Analysis
**Question:** In the chapter's base-case example, which input is identified as the one the five-year budget impact result is most sensitive to?
- A) The discount rate
- B) The uptake/diffusion curve
- C) The time horizon length alone
- D) The choice of R package used to build the model
**Answer:** B
**Explanation:** The chapter states unambiguously that the uptake curve is the result's most sensitive input — moving from the base case's 55% year-5 share to the faster-uptake scenario's 65% materially increases spend, while a price concession (MEA) on the same uptake path claws back \$7,500,000.

## Chapter 24: Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis

### Q346 [Easy] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** How does cost-benefit analysis (CBA) differ from cost-effectiveness analysis (CEA) in what it does with the benefit side of the value equation?
- A) CBA measures benefit in QALYs just like CEA, but uses a different discount rate
- B) CBA converts both cost and health benefit into the same monetary unit, enabling a single net monetary figure; CEA measures benefit in health units and reports a ratio
- C) CBA never includes cost at all
- D) CBA and CEA are identical except for the time horizon
**Answer:** B
**Explanation:** The chapter states CBA makes the "more demanding choice" of converting both costs and health benefits into money so a net benefit figure can be compared against zero, whereas CEA measures benefit in QALYs/life-years and reports a cost-per-QALY ratio only interpretable against a threshold.

### Q347 [Medium] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** What is the value of a statistical life (VSL), as the chapter is careful to clarify?
- A) The price an insurer would charge to insure one named individual's life
- B) An aggregation of small individual willingness-to-pay amounts for small mortality-risk reductions, scaled up to an implied value per statistical death avoided — not a price on any identified person's life
- C) The discounted lifetime earnings of an average worker
- D) A fixed international constant set by the WHO
**Answer:** B
**Explanation:** The chapter is emphatic that VSL is not an attempt to price any individual's life; it aggregates WTP for small risk reductions across a population into an implied value for one statistical death avoided, illustrated by the 100,000-person, \$100-each example yielding a \$10 million VSL.

### Q348 [Medium] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** In the chapter's canonical VSL illustration, 100,000 people would each pay \$100 for a programme that reduces each person's annual mortality risk by 1 in 100,000. What VSL does this imply?
- A) \$100,000
- B) \$1,000,000
- C) \$10,000,000
- D) \$100,000,000
**Answer:** C
**Explanation:** Total willingness to pay is 100,000 × \$100 = \$10,000,000, and because the summed risk reduction implies exactly one fewer death per year on average across the group, the implied VSL is \$10 million.

### Q349 [Easy] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** Per the chapter's listed figures, roughly what range do current US federal agency VSL estimates (DOT, EPA, HHS) span?
- A) \$500,000 to \$1 million
- B) Roughly \$6 million to \$20 million
- C) Exactly \$10 million for every agency
- D) \$1 million to \$2 million
**Answer:** B
**Explanation:** The chapter cites DOT's \$13.2 million, EPA's \$7.4 million, and HHS's central \$13.1 million with a low of \$6.1 million and high of \$19.9 million — a spread the text explicitly calls "roughly \$6 million to \$20 million," a more than threefold range.

### Q350 [Medium] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** What is the well-known equity problem with the human capital approach to monetizing health, per the chapter?
- A) It overvalues the health of retirees and children relative to workers
- B) It systematically values the health of non-earners (children, retirees, unpaid caregivers) near zero, and values identical health gains more highly for higher earners
- C) It cannot be computed from wage and life-table data
- D) It always produces a higher valuation than willingness-to-pay
**Answer:** B
**Explanation:** The chapter states the human capital approach values health by discounted future earnings, which records essentially none of a retiree's or child's quality-of-life gain and values the same health gain differently purely by market wage — the main reason WTP displaced it as the preferred modern method.

### Q351 [Medium] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** What practical difficulty does the willingness-to-pay (WTP) approach to monetizing health face, per the chapter's difficult-terminology box?
- A) It cannot be used for mortality risk, only morbidity
- B) Stated-preference surveys are vulnerable to hypothetical bias, and WTP is mechanically capped by a person's ability to pay, reintroducing an income-related distortion
- C) It always produces identical valuations to the human capital approach
- D) It requires no survey or behavioural data at all
**Answer:** B
**Explanation:** The chapter notes WTP surveys can diverge from real-money behaviour (hypothetical bias) and that a poor person's WTP for an identical health gain is capped by a smaller budget than a rich person's — a different, but still real, equity distortion from human capital's wage-based one.

### Q352 [Medium] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** What finding from Asaria and colleagues' DCEA analysis of bowel cancer screening reminder strategies does the chapter cite as illustrating why a population-average ICER can mask unequal distribution?
- A) A targeted strategy produced both more total health gain and less inequality than a universal strategy
- B) A targeted strategy produced a smaller total health gain but a larger reduction in health inequality across deprivation groups than a universal strategy
- C) Both strategies produced identical health gains and identical equity effects
- D) A universal strategy was found to increase inequality while producing no health gain
**Answer:** B
**Explanation:** The chapter cites this as the DCEA literature's most-cited applied example of an efficiency-equity divergence — exactly the kind of trade-off a single population-average ICER cannot reveal.

### Q353 [Medium] [Image]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** IMAGE PLACEHOLDER: an equity impact plane quadrant chart with total health benefit on one axis and net equity impact on the other, as in section 24.2 (figure `fig-ch24-equity-plane`). In which quadrant(s) does equity weighting do genuine analytical "work" by changing which option looks best?
- A) Win-win and lose-lose only
- B) The two quadrants where total health improves but equity worsens, or equity improves but total health worsens (the genuine trade-off cases)
- C) Only the win-win quadrant
- D) Equity weighting never changes which option is preferred
**Answer:** B
**Explanation:** The chapter explains that in the win-win and lose-lose quadrants there is no genuine trade-off to make, so equity weighting only matters analytically in the "efficient but unfair" and "fair but less efficient" quadrants, where giving more weight to equity can actually change the preferred option.

### Q354 [Hard] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** In the chapter's two-subgroup toy equity-weighting example (1,000 patients each in Q1 and Q5, \$2,000/patient cost, QALY gains of 0.12 and 0.08 respectively, equity weight 1.5 applied to Q1 only), what are the unweighted and equity-weighted ICERs?
- A) \$20,000/QALY unweighted; \$15,384.62/QALY equity-weighted
- B) \$15,384.62/QALY unweighted; \$20,000/QALY equity-weighted
- C) \$20,000/QALY for both
- D) \$30,000/QALY unweighted; \$25,000/QALY equity-weighted
**Answer:** A
**Explanation:** Total cost is \$4,000,000 and total unweighted QALYs are 200, giving \$20,000/QALY; applying the 1.5× weight to Q1's QALYs raises weighted QALYs to 260, giving an equity-weighted ICER of \$15,384.62/QALY — the intervention looks more cost-effective once equity is counted because the already-larger gain happened to go to the up-weighted group.

### Q355 [Medium] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** Per the chapter's agency-note, does NICE apply a formal numeric equity weight inside its standard reference-case cost-utility analysis?
- A) Yes, NICE applies a mandatory 1.5x weight to all deprived-population QALYs
- B) No — NICE's reference case remains an unweighted QALY; equity considerations enter instead via mechanisms like the severity modifier, with DCEA used as a supplementary analytical tool
- C) Yes, but only for oncology appraisals
- D) NICE abolished cost-utility analysis entirely in 2022
**Answer:** B
**Explanation:** The chapter states NICE's reference case stays with "a QALY is a QALY," and equity enters through separate mechanisms such as the severity modifier, while DCEA/formal equity weighting remain supplementary tools (academic analyses, some non-UK ECEA work) rather than mandatory reference-case steps.

### Q356 [Hard] [Image]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** IMAGE PLACEHOLDER: a bar chart of catastrophic-health-expenditure (CHE) cases averted and poverty cases averted by income quintile, as in figure `fig-ch24-ecea-frp` (section 24.3). In the chapter's India TB universal-public-finance worked example, approximately how many total CHE cases are averted, and how is that effect distributed across quintiles?
- A) 53,333 total CHE cases averted, concentrated entirely in the three poorest quintiles (Q1–Q3), with zero effect in Q4 and Q5
- B) 100,000 total CHE cases averted, evenly spread across all five quintiles
- C) 6,500 total CHE cases averted, concentrated in Q5 (richest)
- D) 0 CHE cases averted; only poverty cases are affected
**Answer:** A
**Explanation:** The worked example computes 53,333.3 catastrophic cases averted (20,000 in Q1, 20,000 in Q2, 13,333 in Q3, zero in Q4 and Q5), exactly the pro-poor distributional pattern the chapter says the pooled total alone would hide.

### Q357 [Hard] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** In the same ECEA worked example, how many poverty cases are averted by moving from status-quo OOP cost (\$150) to the new policy's OOP cost (\$20), given a \$400/year poverty line?
- A) 7,500 poverty cases averted
- B) 1,000 poverty cases averted
- C) 6,500 poverty cases averted
- D) 20,000 poverty cases averted
**Answer:** C
**Explanation:** Status-quo poverty cases are 7,500 (0.375 of Q1's households) and new-policy poverty cases are 1,000 (0.05 of Q1's households), so the policy averts 7,500 − 1,000 = 6,500 poverty cases, again concentrated in Q1.

### Q358 [Medium] [Image]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** IMAGE PLACEHOLDER: a bar chart comparing weighted-sum vs. weighted-product MCDA scores for Drugs A, B, and C, as in table `tab-ch24-mcda-scores` (section 24.4). What key structural difference between the weighted-sum and weighted-product combination rules explains why the weighted product punishes Drug C's safety score more heavily?
- A) Weighted sum multiplies scores raised to the power of their weight; weighted product adds weighted scores
- B) Weighted sum is compensatory (a low score on one criterion can be offset by high scores elsewhere); weighted product is multiplicative, so a low score on any one criterion drags the whole product down disproportionately
- C) Weighted product ignores criterion weights entirely
- D) There is no meaningful difference between the two methods
**Answer:** B
**Explanation:** The chapter defines weighted sum as score = Σ(wᵢ·sᵢ), which is compensatory, versus weighted product as score = Π(sᵢ^wᵢ), which is far less forgiving of a weak score on any single criterion — illustrated by Drug C's relatively weak safety score (50) being punished more under the product rule.

### Q359 [Hard] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** In the chapter's three-drug MCDA worked example (weights: efficacy 0.35, safety 0.25, severity 0.20, economic 0.20), which drug has the highest weighted-sum score, and why?
- A) Drug C (90 efficacy, 80 severity) because it leads on the two highest-weighted criteria
- B) Drug A, because it has the most balanced scores across all four criteria
- C) Drug B (69.5), because its strong safety score (90) carries more weight (25%) than the criteria on which Drug C leads
- D) All three drugs tie at the same weighted-sum score
**Answer:** C
**Explanation:** Hand-calculated weighted sums are Drug A 67.5, Drug B 69.5, Drug C 68.0; Drug B wins because its strong safety score is multiplied by a larger weight (0.25) than the weight on severity (0.20), where Drug C leads instead.

### Q360 [Hard] [MCQ]
**Chapter(s):** 24 — Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** In the chapter's NICE severity-modifier worked example (general population QALE 20.4, condition QALE 4.2, incremental cost \$2,400, incremental QALY 0.08), what severity weight applies and what is the resulting severity-adjusted ICER?
- A) Weight 1.7; ICER \$17,647/QALY
- B) Weight 1.2; ICER \$25,000/QALY
- C) Weight 1.0; ICER \$30,000/QALY
- D) Weight 1.2; ICER \$30,000/QALY
**Answer:** B
**Explanation:** The absolute shortfall (16.2 QALYs) falls in the "12 to 18" band (weight 1.2), which is higher than the weight implied by the proportional shortfall (0.794, under the 0.85 threshold, weight 1); taking the higher of the two gives weight 1.2, turning the unweighted ICER of \$30,000/QALY into a severity-adjusted \$2,400/(0.08×1.2) = \$25,000/QALY.
