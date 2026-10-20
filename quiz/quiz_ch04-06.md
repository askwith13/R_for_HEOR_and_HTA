# Quiz Questions: Chapters 4–6

## Chapter 4: Core Concepts in Health Economics (with R Illustrations)

### Q046 [Easy] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** According to §4.1, why is a health technology never "cost-effective" in some free-standing, absolute sense?
- A) Because cost-effectiveness can only be judged after a drug has been on the market for five years
- B) Because it is cost-effective only relative to the alternative use of the same resources that is displaced
- C) Because only randomized controlled trials can establish cost-effectiveness
- D) Because cost-effectiveness depends solely on a drug's list price
**Answer:** B
**Explanation:** §4.1 states that a technology is cost-effective *relative to* the alternative use of the same money — funding one technology means the budget that could have funded something else is displaced, so every evaluation is fundamentally comparative.

### Q047 [Medium] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** Per §4.1, which statement about indirect (productivity) costs is accurate?
- A) All major HTA bodies, including NICE, require indirect costs in the base case
- B) Indirect costs are banned from economic evaluation in every jurisdiction
- C) Most European HTA reference cases, including NICE, exclude productivity costs from the base case on distributional-fairness grounds, while some WTP/societal-perspective and CBA frameworks include them
- D) Indirect costs refer only to hospital bed-days and diagnostic tests
**Answer:** C
**Explanation:** The text explicitly notes that NICE and most European reference cases exclude productivity costs from the base case for distributional-fairness reasons, whereas some societal-perspective WTP frameworks and CBA applications include them.

### Q048 [Medium] [Image]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** IMAGE PLACEHOLDER: a grouped bar chart comparing CMA, CEA, CUA, CBA and CCA, with each bar segment labelled by its effect-measure unit (equivalent effects, natural clinical units, QALYs, monetary value, and multiple disaggregated outcomes respectively) as described in §4.2. Which analysis type is represented by the bar labelled solely "QALYs"?
- A) Cost-minimization analysis (CMA)
- B) Cost-utility analysis (CUA)
- C) Cost-benefit analysis (CBA)
- D) Cost-consequence analysis (CCA)
**Answer:** B
**Explanation:** §4.2 defines CUA as the form of cost-effectiveness analysis in which effects are expressed in quality-adjusted life years (QALYs), the generic preference-weighted outcome that supports cross-programme comparison.

### Q049 [Medium] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** Using the §4.3 worked example — 2.0 years at utility 1.0 plus 3.0 years at utility 0.6 — what is the total QALY accumulation?
- A) 2.6 QALYs
- B) 3.0 QALYs
- C) 3.8 QALYs
- D) 5.0 QALYs
**Answer:** C
**Explanation:** QALY = Σ(tᵢ × uᵢ) = (2.0 × 1.0) + (3.0 × 0.6) = 2.0 + 1.8 = 3.8 QALYs over five calendar years, exactly as computed in the chapter's R snippet.

### Q050 [Hard] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** Per the §4.3 pitfall box, what is the correct way to use a published DALY-based burden estimate as the effectiveness denominator of a cost-effectiveness ratio?
- A) Divide cost by the raw DALY count accrued under the intervention
- B) Subtract intervention QALYs from comparator QALYs, DALY-style
- C) Convert the estimate to "DALYs averted" (comparator DALYs minus intervention DALYs) and sanity-check the sign before it reaches the ICER formula
- D) Treat DALYs and QALYs as interchangeable without conversion since both are life-year metrics
**Answer:** C
**Explanation:** The chapter warns that a DALY is a burden (minimized, not maximized) while a QALY is a good; porting a DALY estimate into a cost-effectiveness ratio requires explicitly converting it to "DALYs averted" rather than using the raw DALY count or the wrong subtraction direction.

### Q051 [Medium] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** In the §4.3 "difficult terminology" box, a respondent says they would accept a 25% chance of death in exchange for a 75% chance of being cured rather than live with their current health state. Which elicitation method does this describe, and what utility does it imply?
- A) Time trade-off; utility = 0.25
- B) Standard gamble; utility = 0.75
- C) Time trade-off; utility = 0.75
- D) Standard gamble; utility = 0.25
**Answer:** B
**Explanation:** Standard gamble offers a choice between the impaired state for certain versus a gamble with probability p of full recovery and (1−p) of death; the indifference probability p is read as the utility, so a 75% recovery chance implies a utility of 0.75.

### Q052 [Medium] [Image]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** IMAGE PLACEHOLDER: a cost-effectiveness plane (ΔE on the x-axis, ΔC on the y-axis) with two orange points sharing an identical ICER of −£2,500/QALY — one in the north-west quadrant (ΔC<0, ΔE>0) and one in the south-east quadrant (ΔC>0, ΔE<0) — as in the §4.4 pitfall figure. What does the north-west point represent?
- A) A dominated treatment that should be rejected
- B) A dominant treatment — more effective and less costly — that should be adopted
- C) A treatment requiring extended-dominance analysis before a decision can be made
- D) A treatment that is cost-effective only above the willingness-to-pay threshold
**Answer:** B
**Explanation:** §4.4's pitfall explains that in the north-west quadrant (more effective, less costly), ΔC<0 and ΔE>0 give a negative ICER meaning the treatment is dominant and should be adopted — the opposite real-world meaning from the south-east quadrant's identical negative ratio.

### Q053 [Medium] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** In the §4.4 anticoagulant worked example (ΔE = 0.28 QALYs, ΔC = £16,800), what does an NMB of −£11,200 at λ = £20,000/QALY indicate?
- A) The drug is cost-effective at this threshold
- B) The drug is not cost-effective at this threshold, consistent with its £60,000/QALY ICER exceeding £20,000
- C) The ICER and NMB give contradictory conclusions
- D) NMB cannot be computed when ΔE is positive
**Answer:** B
**Explanation:** NMB = ΔE×λ − ΔC = (0.28×£20,000) − £16,800 = −£11,200; a negative NMB means not cost-effective at that threshold, matching the ICER of £60,000/QALY exceeding the £20,000 threshold — NMB and ICER are mathematically consistent conclusions here.

### Q054 [Hard] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** How does Claxton and colleagues' empirical estimate of the NHS's marginal productivity compare to NICE's historical reference range, per §4.5?
- A) It suggested a much higher threshold of £50,000–£60,000 per QALY
- B) It suggested a supply-side threshold of roughly £12,000–£15,000 per QALY, below NICE's £20,000–£30,000 range
- C) It confirmed NICE's £20,000–£30,000 range was exactly correct
- D) It argued thresholds should be abandoned entirely in favour of DALYs
**Answer:** B
**Explanation:** §4.5 states Claxton's work estimating health forgone per pound spent elsewhere in the NHS suggested a supply-side threshold closer to £12,000–£15,000/QALY, considerably below NICE's £20,000–£30,000 reference range, triggering debate about whether NICE's range was too generous.

### Q055 [Medium] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** Why did the WHO substantially retire its 1–3x GDP-per-capita heuristic for LMIC cost-effectiveness thresholds, per §4.5?
- A) GDP per capita became too difficult to measure in most countries
- B) Bertram et al. (2016, WHO Bulletin) argued it has no sound empirical basis, is unrelated to actual budget/opportunity cost, and labels too many interventions "cost-effective" relative to what systems can afford
- C) The rule was replaced because NICE adopted it instead
- D) WHO found the heuristic set thresholds too low for LMICs
**Answer:** B
**Explanation:** The chapter cites the 2016 WHO Bulletin piece by Bertram et al. recommending retirement of the GDP-multiple heuristic because it lacks empirical grounding, ignores actual budget constraints, and over-labels interventions as cost-effective.

### Q056 [Easy] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** Per §4.6, what distinguishes the societal perspective from the healthcare payer perspective in an economic evaluation?
- A) The societal perspective only includes drug acquisition costs
- B) The societal perspective additionally includes productivity losses, informal caregiver time, and patient out-of-pocket costs beyond what the payer perspective captures
- C) The healthcare payer perspective includes more cost categories than the societal perspective
- D) There is no practical difference between the two perspectives
**Answer:** B
**Explanation:** §4.6 defines the healthcare payer perspective as including only payer-borne costs, while the societal perspective additionally captures productivity losses, informal care time, and patient out-of-pocket costs.

### Q057 [Easy] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** What discount rate does NICE's Health Technology Evaluations Manual (PMG36, 2022) specify as the reference-case base case for both costs and health effects, per §4.6?
- A) 1.5% for both
- B) 5% for costs, 3.5% for effects
- C) 3.5% for both, with 1.5% for effects permitted only in narrow long-term, large-benefit cases
- D) 0% (no discounting)
**Answer:** C
**Explanation:** The chapter states NICE specifies 3.5% per annum equal discounting for costs and effects, with a 1.5% sensitivity rate for health effects allowed only in narrowly defined long-term, substantial-benefit circumstances.

### Q058 [Medium] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** Why does a Markov cohort model require half-cycle correction, per §4.6?
- A) Because transitions between health states occur continuously through a cycle, so naive cycle-start or cycle-end accounting over- or under-states time spent in each state by roughly half a cycle
- B) Because discount rates change every cycle
- C) Because QALYs cannot be computed without it
- D) Because it corrects for publication bias in trial data
**Answer:** A
**Explanation:** The chapter explains that assuming the whole cohort occupies its cycle-start state for the entire cycle overstates (or cycle-end understates) time in each state by about half a cycle, since real transitions happen continuously; half-cycle correction adjusts for this.

### Q059 [Medium] [MCQ]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** Per §4.7, when is a treatment C said to be "extendedly dominated"?
- A) When C is more costly and less effective than a single alternative
- B) When C's point lies above the line connecting two neighbouring non-dominated treatments B and D, meaning a mix of B and D could achieve C's effectiveness at lower cost
- C) When C has the lowest cost among all compared treatments
- D) When C's ICER cannot be calculated at all
**Answer:** B
**Explanation:** §4.7 describes extended dominance geometrically: if C's point lies above the line connecting neighbouring non-dominated options B and D on the cost-effectiveness plane, a blend of B and D could match C's effectiveness more cheaply, so C is excluded from the efficient set even though no single option dominates it.

### Q060 [Medium] [Image]
**Chapter(s):** 4 — Core Concepts in Health Economics
**Question:** IMAGE PLACEHOLDER: a cost-effectiveness plane plotting four treatments from §4.8 (Standard Care £1,200/0.62 QALYs, Drug A £4,800/0.81, Drug B £5,100/0.74, Drug C £9,000/0.95), with Drug B shown above-and-left of Drug A and a blue frontier line connecting Standard Care → Drug A → Drug C. Why is Drug B excluded from the frontier?
- A) Drug B is extendedly dominated by a mix of Drug A and Drug C
- B) Drug B is simply dominated by Drug A: it costs more (£5,100 vs £4,800) while delivering fewer QALYs (0.74 vs 0.81)
- C) Drug B was never included in the original cost/QALY data
- D) Drug B has the highest ICER of all four treatments
**Answer:** B
**Explanation:** §4.8's `remove_simple_dominance()` step drops Drug B because it costs more than Drug A while delivering fewer QALYs — textbook simple dominance — before any ICER or extended-dominance check is even run.

## Chapter 5: Data Sources and Data Management

### Q061 [Easy] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** Per §5.1, what is the key difference between CDISC SDTM and ADaM?
- A) SDTM is for analysis-ready derived data; ADaM is for raw collected data
- B) SDTM organises collected trial data into standardised domains; ADaM is analysis-ready derived data built from SDTM
- C) They are two names for the exact same data standard
- D) ADaM only applies to adverse event data
**Answer:** B
**Explanation:** The chapter states SDTM is the standard for collected data organised into domains (DM, AE, LB, etc.), while ADaM is analysis-ready derived data built from SDTM, feeding statistical analysis — the relationship is strictly directional (SDTM → ADaM).

### Q062 [Medium] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** Why is ADSL described in §5.1 as the "cornerstone" ADaM dataset?
- A) It contains only adverse-event records
- B) It carries one row per subject with derived flags and population indicators that get merged onto every other analysis dataset so subgroup/population definitions stay consistent
- C) It replaces the need for a statistical analysis plan
- D) It is generated directly from claims data
**Answer:** B
**Explanation:** §5.1 explains ADSL carries derived flags (ITT, safety population, baseline severity, etc.) that are merged onto every other analysis dataset, keeping population definitions consistent across all outputs in a submission.

### Q063 [Medium] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** In ADaM naming conventions described in §5.1, what is the difference between `TRT01P` and `TRT01A`?
- A) `TRT01P` is the primary diagnosis; `TRT01A` is the adverse event flag
- B) `TRT01P` is planned (as-randomised) treatment; `TRT01A` is actual (as-received) treatment
- C) They are interchangeable synonyms for the same variable
- D) `TRT01P` applies only to the placebo arm
**Answer:** B
**Explanation:** The chapter distinguishes planned treatment (as randomised, `TRT01P`) from actual treatment received (`TRT01A`) — a distinction that matters for whether the model reflects intention-to-treat versus per-protocol/as-treated assumptions.

### Q064 [Easy] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** Per §5.2, what is the main structural limitation of disease registry data?
- A) Registries never record longitudinal follow-up
- B) Registry populations are the patients who were diagnosed, referred, and consented into the registry — rarely a random or representative sample of all patients with the condition
- C) Registries only contain billing codes, not clinical detail
- D) Registries cannot be used for any HEOR modelling purpose
**Answer:** B
**Explanation:** §5.2 states registries have relatively high data quality on core variables but suffer a selection limitation: enrolled patients are not a random sample of everyone with the condition.

### Q065 [Medium] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** What is the "great weakness" of administrative claims data identified in §5.2?
- A) Claims data lack scale and completeness of utilization records
- B) Claims record diagnosis/procedure codes attached to billing events rather than direct clinical measurements, and codes can be driven by reimbursement incentives ("upcoding") rather than clinical precision
- C) Claims data cannot be linked to drug acquisition costs
- D) Claims data are only available for inpatient admissions
**Answer:** B
**Explanation:** The chapter explains claims data's great strength is utilisation scale, but its great weakness is clinical granularity — codes reflect billing events, sometimes "upcoded," rather than direct lab values or severity grades.

### Q066 [Medium] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** Per §5.7, what does India's Digital Personal Data Protection Act (DPDPA), 2023 establish for anyone handling government health programme patient-level data?
- A) A requirement that all health data be stored only outside India
- B) Principles including processing data only for a specified lawful purpose with consent, collecting no more data than necessary, reasonable security safeguards, and grievance redress mechanisms
- C) A mandate that all patient data must be fully public
- D) An exemption for TB programme data from any privacy obligation
**Answer:** B
**Explanation:** §5.7 describes DPDPA 2023 as establishing purpose limitation and consent, data minimisation, reasonable security safeguards, and grievance redress — converging data minimisation and purpose limitation from best practice into statutory obligation.

### Q067 [Hard] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** Per §5.3, what mechanism underlies publication bias as a threat to literature-derived model parameters?
- A) Journals only publish papers written by famous authors
- B) Trials/studies with null or unfavourable results are systematically less likely to be published at all, or are published later, in lower-visibility journals, or with selective outcome reporting
- C) Publication bias only affects meta-analyses, never single trials
- D) Publication bias is eliminated automatically by peer review
**Answer:** B
**Explanation:** The chapter defines publication bias as the systematic underrepresentation of null/unfavourable results in the published literature — through non-publication, delay, lower-visibility placement, or selective outcome reporting — which can make an ad hoc literature-based model overestimate treatment effect.

### Q068 [Medium] [Image]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** IMAGE PLACEHOLDER: a funnel plot with study effect size on the x-axis and precision (inverse standard error) on the y-axis, as described in §5.3's "difficult terminology" box, showing small studies missing from one side of the funnel. What does this asymmetric pattern suggest?
- A) That all included studies were adequately powered
- B) Possible publication bias — small studies with unfavourable or null results may be missing, leaving a gap on one side of the normally symmetric funnel
- C) That the meta-analysis used too many databases
- D) That Egger's test is unnecessary once a funnel plot is drawn
**Answer:** B
**Explanation:** §5.3 explains that a symmetric, upside-down-funnel pattern is expected absent bias; if small studies with unfavourable results are more likely to go unpublished, the plot becomes visibly lopsided — the signature publication-bias checks via funnel plot and Egger's test.

### Q069 [Medium] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** Per the §5.4 pitfall on `readr`, why is explicitly pinning `col_types` important?
- A) `readr` cannot read CSV files without it
- B) `readr`'s type guessing samples only the first 1,000 rows by default, so a column that changes character partway through (e.g. an ID turning alphanumeric at row 1,200) can silently coerce to NA or character from that point on
- C) `col_types` is required only for Excel files, not CSVs
- D) Explicit column types make the import run slower
**Answer:** B
**Explanation:** The chapter warns that `readr`'s default 1,000-row sampling for type guessing can miss a late format change, silently corrupting data; pinning `col_types` and checking `problems()` catches this.

### Q070 [Medium] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** Per §5.4, what is the difference between applying `as_factor()` versus `zap_labels()` to a `haven_labelled` column?
- A) `as_factor()` deletes the column; `zap_labels()` renames it
- B) `as_factor()` converts labels into factor levels (keeping coded meaning); `zap_labels()` strips labels and keeps only the plain numeric value
- C) Both functions perform identically
- D) `zap_labels()` is used only for date columns
**Answer:** B
**Explanation:** The chapter shows `as_factor()` turning value labels into factor levels while `zap_labels()` strips labels to leave plain numeric data — a deliberate column-by-column decision analysts must make rather than letting the labelled class leak unexamined into pipelines.

### Q071 [Easy] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** Per §5.4's "difficult terminology" box on SQL injection, how do parameterised queries prevent this vulnerability?
- A) By encrypting the entire database
- B) By sending the query's fixed structure and user-supplied values to the database as two separate pieces, so a value is always treated as literal data, never as part of the query's logic
- C) By disabling all user input entirely
- D) By requiring every query to run twice for verification
**Answer:** B
**Explanation:** The chapter explains SQL injection arises from pasting untrusted text directly into a query string; parameterised queries (via `dbGetQuery()`'s `params` argument) keep structure and data separate so malicious or malformed input cannot alter query logic.

### Q072 [Medium] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** Per §5.5, what must a complete data dictionary document for every variable, at minimum?
- A) Only the variable's name
- B) Variable name/label, type and units, value code mappings, missing-value codes, and derivation logic for computed variables
- C) Only the file format the dataset was stored in
- D) Only the analyst's initials and the import date
**Answer:** B
**Explanation:** §5.5 lists these five elements explicitly: name/label, type/units, value code mappings, missing-value codes and their meaning, and derivation logic for any non-raw variable.

### Q073 [Medium] [Image]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** IMAGE PLACEHOLDER: a `pointblank` agent interrogation report table (as in §5.6) for the three-row `cost_qaly_tbl`, with the "Combination" row highlighted red for failing both `col_vals_gte(cost, 0)` and `col_vals_lte(qaly, 1)`. Why does this row fail twice?
- A) Because its strategy name is misspelled
- B) Because it has a negative cost (−340) and a utility above 1 (1.04), both impossible values that must be caught before dominance analysis
- C) Because it is missing a follow-up count
- D) Because pointblank requires exactly four rows
**Answer:** B
**Explanation:** §5.6's worked example gives the "Combination" row cost = −340 (violating `cost >= 0`) and qaly = 1.04 (violating `qaly <= 1`), so `interrogate()` flags it on both rules before any dominance comparison from Chapter 4 is attempted.

### Q074 [Hard] [MCQ]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** Per §5.7, what distinguishes HIPAA's "Safe Harbor" de-identification route from "Expert Determination"?
- A) Safe Harbor requires a statistician's risk assessment; Expert Determination uses an enumerated list of identifiers
- B) Safe Harbor is a mechanical, auditable list of 18 identifier categories to remove/generalise; Expert Determination has a qualified statistician formally assess and document that re-identification risk is "very small," useful when Safe Harbor's blunt removals would destroy analytic value
- C) Both routes are identical in US law
- D) Safe Harbor only applies to European data subjects
**Answer:** B
**Explanation:** The chapter describes Safe Harbor as mechanical and blunt (removing 18 enumerated identifier categories) and Expert Determination as a qualified expert's documented statistical risk assessment, appropriate when Safe Harbor's removals (e.g. exact dates) would destroy analytic value needed for survival analysis.

### Q075 [Medium] [Image]
**Chapter(s):** 5 — Data Sources and Data Management
**Question:** IMAGE PLACEHOLDER: a small table/heat-map illustrating the §5.7 pitfall — a TB programme extract cross-tabulating facility name, exact diagnosis date, drug-resistance pattern, and sub-district, with one cell containing only a single patient highlighted. What problem does this illustrate?
- A) The dataset has too many missing values
- B) The "quasi-identifier" problem: dropping name/ID columns alone does not de-identify data, because a combination of other fields can still re-identify a specific patient
- C) The data violates currency-inflation conventions
- D) The dataset needs a larger sample size
**Answer:** B
**Explanation:** §5.7's pitfall box explains that dropping name and ID columns is not de-identification; a rare combination of facility, exact date, drug-resistance pattern, and geography can re-identify a specific patient even with no name column — the well-documented quasi-identifier problem requiring small-cell suppression or generalisation.

## Chapter 6: Systematic Literature Review (SLR) Support in R

### Q076 [Easy] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** Per §6.1, what does PRISMA-S ask a systematic review to document for every database searched?
- A) Only the final count of included studies
- B) Database name, platform/interface, full Boolean string, date range, limits applied, and date run
- C) Only the names of the reviewers
- D) Only the journal impact factors of retrieved articles
**Answer:** B
**Explanation:** §6.1 states PRISMA-S, the search-reporting extension to PRISMA 2020, requires exactly these elements for every source searched — not just a remembered final tally — so the search is reproducible.

### Q077 [Medium] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** What is the purpose of `litsearchr`'s keyword co-occurrence network, per §6.1?
- A) To automatically translate a search string across every database syntax
- B) To take a seed set of known-relevant papers, extract candidate keyphrases, and build a network so analysts can spot synonyms/related terms (e.g. "DR-TB" next to "multidrug-resistant tuberculosis") before finalising the Boolean search string
- C) To screen abstracts automatically without human review
- D) To generate the PRISMA flow diagram directly
**Answer:** B
**Explanation:** The chapter describes `litsearchr` as helping identify candidate search terms via keyword co-occurrence networks from a seed/naive search, which analysts then screen against clinical judgment before building the final Boolean query.

### Q078 [Medium] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** Per §6.2, why is exact title matching alone insufficient for deduplicating multi-database reference exports?
- A) Exact matching always removes too many unique records
- B) It will miss records that differ by punctuation, case, or trailing journal abbreviation, so fuzzy matching on title/author/year (and ideally DOI matching first) is needed
- C) Exact matching is illegal under PRISMA guidelines
- D) Databases never produce duplicate records
**Answer:** B
**Explanation:** The chapter notes that combining results across databases typically produces 20-40% duplicates, and exact title match alone misses records differing by minor formatting; a cheap DOI-match pass followed by fuzzy string similarity is the recommended approach.

### Q079 [Medium] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** Per §6.2, how should the two-stage screening process be structured?
- A) Full-text screening first (strict), then title/abstract screening (lenient)
- B) Title/abstract screening first (fast, generous, errs toward inclusion), then full-text screening on survivors (slower, decisive, with documented exclusion reasons)
- C) Both stages should be done simultaneously by a single reviewer
- D) Screening should skip title/abstract entirely and go straight to full-text
**Answer:** B
**Explanation:** The chapter describes screening as a two-stage filter: fast, inclusion-leaning title/abstract screening first, followed by slower, decisive full-text screening on the survivors with documented reasons for exclusion.

### Q080 [Hard] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** Per the §6.2 "difficult terminology" box, why can't raw percent agreement between two screeners be trusted on its own?
- A) Percent agreement is mathematically impossible to calculate
- B) If most records are obvious excludes, two reviewers deciding largely at random will still agree often purely by chance; Cohen's kappa corrects for this baseline chance-agreement rate
- C) Percent agreement only applies to full-text screening, not title/abstract
- D) Kappa and percent agreement always produce identical values
**Answer:** B
**Explanation:** The chapter explains that when most decisions are obvious excludes, two reviewers can show high percent agreement just by both landing on "exclude" by chance; Cohen's kappa strips out that chance-agreement artefact, so a kappa of 0.71 (substantial but not pristine) is more informative than the 96.4% raw agreement figure.

### Q081 [Medium] [Image]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** IMAGE PLACEHOLDER: a PRISMA 2020 flow diagram generated by `PRISMA_flowdiagram()`, showing boxes for 3,418 records identified, 220 duplicates removed, 3,198 screened, 2,238 excluded at title/abstract, 42 full-text retrieved, 19 full-text excluded, and 23 studies included, as in §6.3. Why does the chapter insist every number in this diagram trace back to a line of code rather than being hand-typed?
- A) Hand-typed diagrams render faster in PowerPoint
- B) It eliminates exactly the kind of untraceable discrepancy a reproducible SLR workflow is meant to prevent, and lets a reviewer's question about missing records be answered by re-running the script
- C) PRISMA 2020 forbids software-generated diagrams
- D) Only the final "studies included" number needs to be accurate
**Answer:** B
**Explanation:** §6.3 states that building the diagram from counts computed directly in the screening pipeline (row counts before/after deduplication, screening_log tallies) avoids untraceable discrepancies and lets reviewers' questions be answered by re-running the code rather than digging through memory or email threads.

### Q082 [Medium] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** Per §6.3, what reconciliation check should an analyst assert in code regarding full-text exclusion reasons?
- A) That the number of reviewers equals the number of databases searched
- B) That the sum of itemised exclusion reasons (e.g. wrong population, no cost outcome, conference abstract only, duplicate publication) equals the single full-text-excluded count on the flow diagram
- C) That every excluded study must have exactly one exclusion reason listed per database
- D) That exclusion reasons are optional and can be omitted from the appendix
**Answer:** B
**Explanation:** The chapter shows `sum(exclusion_reasons$n)` must equal the `full_text_excluded` count, and recommends asserting this with `stopifnot()` or a test rather than eyeballing it, since mismatches are exactly the kind of error that surfaces in peer review.

### Q083 [Easy] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** Per §6.3, what does the `PRISMA2020` package's `PRISMA_flowdiagram()` function map onto directly?
- A) The Cochrane RoB 2.0 signalling questions
- B) The PRISMA 2020 statement's Item 16a flow-diagram template fields (records identified, duplicates removed, records screened/excluded, reports sought/retrieved, reports assessed, studies included)
- C) The HIPAA Safe Harbor identifier list
- D) The CDISC define.xml metadata schema
**Answer:** B
**Explanation:** §6.3's agency-note states that `PRISMA_flowdiagram()` maps field-for-field onto the PRISMA 2020 statement's Item 16a template, making it the most mechanical way to guarantee compliance with that checklist item.

### Q084 [Medium] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** Per §6.4, why should a data extraction template be designed as one row per study-outcome combination (long format) rather than one row per study?
- A) Long format is required by all spreadsheet software
- B) Most SLRs extract multiple outcomes and multiple comparisons per study, and a wide format forces awkward column explosion later
- C) Long format uses less disk space than wide format
- D) Reviewers cannot read wide-format tables
**Answer:** B
**Explanation:** The chapter explains that because studies typically report multiple outcomes/comparisons, a long (one row per study-outcome) format avoids the column explosion a wide, one-row-per-study format would require.

### Q085 [Medium] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** Per §6.4, what is the advantage of using `waldo::compare()` to reconcile two independent reviewers' extraction tibbles?
- A) It automatically resolves all discrepancies without human adjudication
- B) It reports exactly which cells differ between the two tibbles, which is far more actionable for an adjudication meeting than a manual side-by-side spreadsheet read
- C) It replaces the need for a third-reviewer adjudication step
- D) It only works on numeric columns, not text fields
**Answer:** B
**Explanation:** The chapter states `waldo::compare()` pinpoints exactly which cells differ between reviewer_a and reviewer_b's tibbles, making discrepancies actionable for adjudication rather than requiring a manual side-by-side read.

### Q086 [Medium] [Image]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** IMAGE PLACEHOLDER: a `robvis::rob_traffic_light()` grid for the three RoB 2.0 studies in §6.5 (Nguyen2021, Alvarez2020, Okafor2022), one row per study and one column per domain D1–D5, coloured green ("Low"), amber ("Some concerns") per the data given. What does this traffic-light grid typically accompany in an SLR or HTA submission?
- A) The search strategy appendix only
- B) A methods annex or SLR appendix reporting risk-of-bias assessment per PRISMA 2020 Item 18
- C) The PRISMA flow diagram's duplicate-removal stage
- D) The data dictionary's missing-value codes
**Answer:** B
**Explanation:** §6.5 states the red/amber/green traffic-light grid goes directly into an SLR appendix or HTA dossier methods annex, serving as standard, recognisable evidence that risk-of-bias assessment (PRISMA 2020 Item 18) was done transparently.

### Q087 [Medium] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** Per §6.5, what does `robvis::rob_summary()` produce, and where is it typically used?
- A) A per-study traffic light grid used only in appendices
- B) A weighted horizontal bar chart showing the proportion of studies at each judgment level per domain, typically placed in the main body of the review to summarise bias across the whole evidence base
- C) A PRISMA flow diagram for screening counts
- D) A funnel plot for detecting publication bias
**Answer:** B
**Explanation:** The chapter distinguishes `rob_traffic_light()` (per-study grid, often in an appendix) from `rob_summary()` (weighted bar chart across the whole evidence base), the latter typically appearing in the review's main body.

### Q088 [Hard] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** Per §6.5, how does specifying `tool = "ROBINS-I"` in `robvis` differ from `tool = "ROB2"`?
- A) ROBINS-I only works with RCTs; ROB2 only works with non-randomized studies
- B) ROBINS-I requires a different domain structure and vocabulary (e.g. seven domains D1–D7, judgment categories like "Moderate"/"Serious"/"Critical") appropriate for non-randomized studies, versus ROB2's five RCT domains
- C) Both tools use identical domain columns and vocabulary
- D) ROBINS-I cannot produce a traffic-light plot, only a summary bar chart
**Answer:** B
**Explanation:** The chapter's two worked examples show RoB 2.0 using five domains (D1-D5) with "Low/Some concerns/High" vocabulary for RCTs, while ROBINS-I uses seven domains (D1-D7) with a different vocabulary ("Moderate," "Serious," "Critical") appropriate for non-randomized studies — `robvis` requires specifying the correct tool and domain columns for each.

### Q089 [Medium] [MCQ]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** Per §6.6, what is the purpose of computing a `quanteda`-based relevance score across protocol-defined key terms for a batch of abstracts?
- A) To automatically exclude low-scoring abstracts from the review entirely
- B) To reorder the screening queue so the most plausibly relevant abstracts are screened first, speeding up time-to-inclusion-decision without changing what counts as included
- C) To replace the need for any human screening decisions
- D) To generate the final PRISMA flow diagram counts
**Answer:** B
**Explanation:** §6.6 explicitly states that text mining reorders the screening queue so likely-includes are screened early, which speeds up the process operationally but does not change which abstracts ultimately count as included — screening decisions remain human.

### Q090 [Hard] [Image]
**Chapter(s):** 6 — Systematic Literature Review (SLR) Support in R
**Question:** IMAGE PLACEHOLDER: a diagram showing two human reviewers independently screening a full abstract list in parallel, versus an alternative (crossed-out) workflow where only a single reviewer screens a "high-relevance" ML-flagged tier while skipping the rest, as discussed in the §6.6 pitfall. What is the only legitimate use of ML relevance scores or topic clusters in a Cochrane-conformant review?
- A) To let one reviewer screen only the highest-scoring abstracts and skip the rest
- B) To exclude low-scoring abstracts outright without human review
- C) To re-order the queue that both independent human reviewers still work through in full, since dual independent screening of every title/abstract and full text remains required
- D) To replace Cohen's kappa calculations entirely
**Answer:** C
**Explanation:** The chapter's pitfall is explicit: term-frequency scores, topic clusters, and active-learning rankings are prioritisation aids only, and using them to exclude abstracts outright or let a single reviewer skip the "low-relevance" tier breaks Cochrane's dual independent screening requirement — the only legitimate use is re-ordering the queue both reviewers still fully work through.
