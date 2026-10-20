# R for HEOR and HTA — Quiz Question Bank

A complete question bank for a quiz application, drawn from all 27 written chapters of *R for Health Economics and Outcomes Research (HEOR) and Health Technology Assessment (HTA)*.

**Total questions: 426**
**Difficulty mix:** Easy 90 · Medium 218 · Hard 118
**Question types:** Standard MCQ 371 · Image-based 55

## How to use this file

- Each question is a standalone markdown block: a level-3 heading (`### Q### [Difficulty] [Type]`), the source chapter(s), the question text, four options (A-D), the correct answer letter, and a short explanation grounded in the book's actual content.
- **Image-type questions** currently contain an inline `IMAGE PLACEHOLDER: ...` description instead of a real image, describing exactly what chart/diagram/table should be shown. These placeholders are ready to be replaced with real rendered images (many of the referenced figures already exist as PNGs under `typst_project/images/` from the book's own image-rendering pass — see `progress/image_tracker.md`) when building the quiz app.
- Questions are numbered sequentially Q001–Q426 across the whole bank, grouped by chapter in book order, so the numbering is stable even if you filter/shuffle by chapter or difficulty in the app.
- `**Chapter(s):**` names the chapter(s) the question draws from — almost always one chapter per question; occasional integrative questions may cite two.

## Table of contents

- [Chapter 1: Introduction to HEOR and HTA](#chapter-1-introduction-to-heor-and-hta) — 15 questions
- [Chapter 2: Setting Up an R Environment for HEOR](#chapter-2-setting-up-an-r-environment-for-heor) — 15 questions
- [Chapter 3: R Essentials for Health Economists](#chapter-3-r-essentials-for-health-economists) — 15 questions
- [Chapter 4: Core Concepts in Health Economics (with R Illustrations)](#chapter-4-core-concepts-in-health-economics-with-r-illustrations) — 15 questions
- [Chapter 5: Data Sources and Data Management](#chapter-5-data-sources-and-data-management) — 15 questions
- [Chapter 6: Systematic Literature Review (SLR) Support in R](#chapter-6-systematic-literature-review-slr-support-in-r) — 15 questions
- [Chapter 7: Missing Data](#chapter-7-missing-data) — 15 questions
- [Chapter 8: Health-Related Quality of Life and Utilities](#chapter-8-health-related-quality-of-life-and-utilities) — 15 questions
- [Chapter 9: Costs and Resource Use](#chapter-9-costs-and-resource-use) — 15 questions
- [Chapter 10: Survival Analysis for Economic Evaluation](#chapter-10-survival-analysis-for-economic-evaluation) — 15 questions
- [Chapter 11: Meta-Analysis](#chapter-11-meta-analysis) — 15 questions
- [Chapter 12: Indirect Treatment Comparisons and Network Meta-Analysis](#chapter-12-indirect-treatment-comparisons-and-network-meta-analysis) — 15 questions
- [Chapter 13: Population-Adjusted Indirect Comparisons](#chapter-13-population-adjusted-indirect-comparisons) — 15 questions
- [Chapter 14: Bayesian Methods for HEOR](#chapter-14-bayesian-methods-for-heor) — 17 questions
- [Chapter 15: Real-World Evidence (RWE) and Causal Inference](#chapter-15-real-world-evidence-rwe-and-causal-inference) — 13 questions
- [Chapter 16: Regression Models for HEOR Data](#chapter-16-regression-models-for-heor-data) — 15 questions
- [Chapter 17: Principles of Decision Modelling](#chapter-17-principles-of-decision-modelling) — 15 questions
- [Chapter 18: Decision Trees](#chapter-18-decision-trees) — 15 questions
- [Chapter 19: Markov Cohort Models](#chapter-19-markov-cohort-models) — 15 questions
- [Chapter 20: Partitioned Survival Models](#chapter-20-partitioned-survival-models) — 15 questions
- [Chapter 21: Individual-Level State-Transition Models (Microsimulation)](#chapter-21-individual-level-state-transition-models-microsimulation) — 15 questions
- [Chapter 22: Discrete Event Simulation and Dynamic Models](#chapter-22-discrete-event-simulation-and-dynamic-models) — 15 questions
- [Chapter 23: Budget Impact Analysis](#chapter-23-budget-impact-analysis) — 15 questions
- [Chapter 24: Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis](#chapter-24-cost-benefit-distributional-and-extended-cost-effectiveness-analysis) — 15 questions
- [Chapter 25: Handling Uncertainty](#chapter-25-handling-uncertainty) — 23 questions
- [Chapter 26: Value of Information Analysis](#chapter-26-value-of-information-analysis) — 20 questions
- [Chapter 27: Model Calibration, Validation and Quality Assurance](#chapter-27-model-calibration-validation-and-quality-assurance) — 23 questions

---

## Chapter 1: Introduction to HEOR and HTA

### Q001 [Easy] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** According to Chapter 1, what question does HEOR's output ultimately answer?
- A) Is this intervention worth it, for whom, compared to what, and under what degree of uncertainty?
- B) How should a health system allocate its whole budget across competing priorities?
- C) How does demand for healthcare respond to changes in price?
- D) How is care best organised and delivered within a health system?
**Answer:** A
**Explanation:** The chapter gives this as "a useful operational definition" of HEOR's purpose, distinguishing it from public-finance and demand-theory questions (B and C) and from health services research (D).

### Q002 [Medium] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** Which discipline does HEOR lean on heavily for methods such as survival analysis, meta-analysis and causal inference, while still differing from it in its decision-relevant output?
- A) Market access
- B) Biostatistics and epidemiology
- C) Public finance
- D) Health services research
**Answer:** B
**Explanation:** The chapter states HEOR "leans on heavily" biostatistics and epidemiology for these methods, but HEOR's output is a decision-relevant value argument rather than a hypothesis test in isolation.

### Q003 [Easy] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** Which body is described as India's Health Technology Assessment agency, housed under the Department of Health Research, Ministry of Health and Family Welfare?
- A) ICER
- B) HTAIn
- C) PBAC
- D) HAS
**Answer:** B
**Explanation:** HTAIn (Health Technology Assessment in India) issues an Indian reference case and informs decisions under schemes such as Ayushman Bharat PM-JAY.

### Q004 [Medium] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** Per the chapter's agency table, what distinguishes ICER (Institute for Clinical and Economic Review) from agencies like NICE or CADTH?
- A) It is a non-government, foundation-funded body with no statutory authority
- B) It only reviews budget impact models, not cost-effectiveness
- C) It is the official UK government HTA body
- D) It exclusively evaluates diagnostic devices
**Answer:** A
**Explanation:** The chapter explicitly describes ICER as "a non-government, foundation-funded body whose cost-effectiveness reports carry significant influence... despite having no statutory authority."

### Q005 [Hard] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** Since 2025, how does the EU Joint Clinical Assessment change the European HTA landscape, per Chapter 1's agency note?
- A) It replaces all national HTA economic appraisals with a single EU-wide cost-effectiveness verdict
- B) It introduces a single EU-level clinical assessment report that national bodies must consider, while economic/pricing appraisal remains national and separate
- C) It applies retroactively to all technologies assessed since 2015
- D) It eliminates the need for a discount rate convention across member states
**Answer:** B
**Explanation:** The chapter states the EU HTA Regulation "decouples joint clinical assessment from still-national economic assessment," with national bodies still performing their own cost-effectiveness and pricing appraisals.

### Q006 [Medium] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** At which product lifecycle stage does the chapter say real-world evidence (RWE) studies become the characteristic form of evidence generated?
- A) Early pipeline / pre-clinical and Phase I-II
- B) Phase III / pre-launch
- C) Launch / initial HTA submission
- D) Post-launch
**Answer:** D
**Explanation:** The lifecycle table lists "RWE studies, ERG critique responses, managed entry agreement data" as the characteristic evidence generated at the post-launch stage.

### Q007 [Easy] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** What is a budget impact model, as distinguished from a cost-effectiveness model in Chapter 1?
- A) A model that only applies to diagnostic devices, never drugs
- B) A forecast of the net financial impact on a payer's budget over a defined horizon, separate from the cost-effectiveness case
- C) A model exclusively used for systematic literature reviews
- D) A synonym for the global value dossier
**Answer:** B
**Explanation:** The chapter describes budget impact models as forecasting "the net financial impact on a payer's budget over a defined horizon," and notes they are frequently the deciding document even when cost-effectiveness is favourable.

### Q008 [Hard] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** In the chapter's analogy for microsimulation versus cohort models, what key capability does a microsimulation have that an average cohort model lacks?
- A) It always runs faster than a cohort model
- B) It eliminates the need for randomly drawn parameters
- C) It can capture patient-to-patient variability and let a patient's own history affect their future risk
- D) It removes the need for a time horizon
**Answer:** C
**Explanation:** The chapter's flight-simulator analogy explains that microsimulation tracks individual patients with their own random draws, capturing variability and history-dependent risk that a cohort average cannot.

### Q009 [Medium] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** Which of the following is NOT listed in Chapter 1 as one of the concrete reasons R has become a credible alternative to Excel, TreeAge, or SAS in HEOR?
- A) Reproducibility by construction via renv and version control
- B) Statistical depth in packages like flexsurv, meta, metafor, netmeta, brms
- C) Guaranteed acceptance by all HTA agencies regardless of documentation quality
- D) Interoperability with reporting tools like Quarto and R Markdown
**Answer:** C
**Explanation:** The chapter explicitly states the deciding factor for agency acceptance "is not the tool itself but whether the model satisfies the agency's validation and transparency expectations" — R does not make acceptance automatic.

### Q010 [Medium] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** According to the chapter, in which situations does TreeAge or SAS remain attractive compared to R?
- A) TreeAge for point-and-click prototyping with non-programming stakeholders; SAS for regulated clinical trial pipelines with existing validated macros
- B) TreeAge for Bayesian meta-analysis; SAS for Shiny app deployment
- C) Both are described as strictly obsolete and never preferable to R
- D) TreeAge for machine learning; SAS for web scraping
**Answer:** A
**Explanation:** The chapter states TreeAge "remains attractive for teams who need a point-and-click interface... and fast prototyping," while SAS "retains deep institutional entrenchment in regulated clinical trial pipelines where validated, audited SAS macros already exist."

### Q011 [Easy] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** Which of the book's eight parts, per the workflow map in Chapter 1, covers survival analysis, meta-analysis, indirect comparisons, Bayesian methods and causal inference?
- A) Part II: Data
- B) Part III: Statistical methods
- C) Part IV: Decision-analytic modelling
- D) Part V: Uncertainty, VOI and validation
**Answer:** B
**Explanation:** Part III, Statistical methods, is described as covering "survival analysis, meta-analysis, indirect comparisons, Bayesian methods and causal inference."

### Q012 [Hard] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** Per Chapter 1's difficult-terminology box, what is the defining feature of a discrete event simulation compared to a fixed-cycle Markov cohort model?
- A) It advances time irregularly, jumping to whenever the next event actually happens, rather than checking every cycle on a fixed clock
- B) It cannot represent shared, limited resources like hospital beds
- C) It always has fewer health states than a Markov model
- D) It is only usable for budget impact analysis
**Answer:** A
**Explanation:** The chapter contrasts the Markov model's fixed-cycle checks with discrete event simulation's irregular, event-driven time advancement, useful when events are rare/irregular or resources are shared and limited.

### Q013 [Medium] [Image]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** IMAGE PLACEHOLDER: a horizontal flow diagram titled "The book's eight-part structure as a cumulative HEOR workflow," showing eight sequential boxes labelled Foundations, Data, Statistical methods, Decision-analytic modelling, Uncertainty/VOI/validation, Reporting/communication/deployment, HTA in practice, and Case studies, with arrows indicating each part builds on the one before it. Based on this workflow map, which part comes immediately before "Decision-analytic modelling"?
- A) Foundations
- B) Data
- C) Statistical methods
- D) Uncertainty, VOI and validation
**Answer:** C
**Explanation:** The chapter's ordered list places Part III (Statistical methods) immediately before Part IV (Decision-analytic modelling), since clinical/comparative-effectiveness parameters feed directly into model structures.

### Q014 [Hard] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** The chapter's pitfall box warns against conflating statistical significance with what?
- A) Clinical trial enrollment targets
- B) Economic or decision-relevant significance
- C) Regulatory approval timelines
- D) Sample size calculations
**Answer:** B
**Explanation:** The pitfall describes treating a p-value below 0.05 as equivalent to decision-relevant significance as a common conflation, since a statistically significant $40 cost difference across a large budget impact model can drive a very different reimbursement recommendation.

### Q015 [Medium] [MCQ]
**Chapter(s):** 1, Introduction to HEOR and HTA
**Question:** Which analytical deliverable does Chapter 1 say TB programme data quality and workforce-training initiatives for India's National TB Elimination Programme sit most naturally against?
- A) Network meta-analysis and Bayesian indirect comparisons
- B) Patient-preference / discrete choice experiments
- C) Budget impact, programme-cost and dynamic/infectious-disease modelling deliverables
- D) Quarto-based reporting pipelines only
**Answer:** C
**Explanation:** The chapter states this TB programme work sits "most naturally against the budget impact, programme-cost and dynamic/infectious-disease modelling deliverables," referencing Chapters 22-23 and 32.7.

## Chapter 2: Setting Up an R Environment for HEOR

### Q016 [Easy] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** According to Chapter 2, where is R itself distributed from?
- A) GitHub releases page
- B) The Comprehensive R Archive Network (CRAN)
- C) Posit Package Manager exclusively
- D) The RStudio installer bundle only
**Answer:** B
**Explanation:** The chapter states "R is distributed through the Comprehensive R Archive Network (CRAN) at cran.r-project.org."

### Q017 [Medium] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** What is Positron, as described in Chapter 2?
- A) A cloud-only HTA submission portal
- B) A VS Code-based IDE built by Posit with native R and Python data-science support
- C) A replacement for CRAN
- D) An R package for Bayesian modelling
**Answer:** B
**Explanation:** The chapter describes Positron as "a VS Code–based IDE built on the same open extensibility model as Visual Studio Code, but with first-class R and Python data-science support built in."

### Q018 [Medium] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** In the recommended HEOR project folder structure, what rule governs the `data-raw/` directory?
- A) It is immutable — never edited by hand or overwritten by a script
- B) It stores only rendered Quarto reports
- C) It is deleted at the end of every project
- D) It holds reusable R functions shared across scripts
**Answer:** A
**Explanation:** The chapter states "`data-raw/` is immutable. Nothing in this folder is ever edited by hand or overwritten by a script," and that it is a permanent, auditable record of what came in.

### Q019 [Easy] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** Which R function call does Chapter 2 recommend for scaffolding a new project's `.Rproj` file and `.gitignore` in one step?
- A) renv::init()
- B) usethis::create_project()
- C) devtools::load_all()
- D) quarto::quarto_version()
**Answer:** B
**Explanation:** The chapter shows `usethis::create_project("~/projects/my-heor-project")` as "a convenient starting scaffold" that creates the `.Rproj` file, a sensible `.gitignore`, and an R-project-aware working directory.

### Q020 [Medium] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** What specific problem does `renv` solve for an R-based HEOR project?
- A) It manages the operating system and system libraries
- B) It gives every project its own private, isolated package library and a lockfile recording exact versions
- C) It compiles Stan models to C++
- D) It replaces the need for Git entirely
**Answer:** B
**Explanation:** The chapter states that without renv, `install.packages()` updates a package "for every project on your machine," and renv "solves this by giving every project its own private, isolated package library and a lockfile recording exact versions."

### Q021 [Easy] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** Which command reads `renv.lock` and installs exactly those package versions into a project's private library?
- A) renv::init()
- B) renv::snapshot()
- C) renv::restore()
- D) renv::update()
**Answer:** C
**Explanation:** The chapter explains that `renv::restore()` "reads renv.lock and installs precisely those package versions into the project's private library, regardless of what is currently installed elsewhere on the system."

### Q022 [Hard] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** Per Chapter 2's agency note, what do NICE and CADTH both mandate regarding submitted economic models, without mandating a specific tool like R?
- A) That the model be built exclusively using Excel for comparability
- B) That the model be inspectable and re-runnable by the reviewing team
- C) That the model use at least 10,000 PSA iterations
- D) That all code be written in SAS for regulatory consistency
**Answer:** B
**Explanation:** The chapter states neither agency mandates R or renv specifically, "but both mandate that whatever tool is used be inspectable and re-runnable by the reviewing team."

### Q023 [Medium] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** Chapter 2 identifies three concrete benefits of version control (Git/GitHub) for HEOR work. Which of the following is NOT one of them?
- A) Auditability via commit history and git diff
- B) Branching for scenario analysis
- C) Pull requests as quality control mirroring agency technical review
- D) Automatic compilation of Stan models to C++
**Answer:** D
**Explanation:** The chapter lists auditability, branching for scenario analysis, and pull requests as quality control as the three ways version control earns its keep; Stan/C++ compilation is unrelated and covered in Section 2.5.

### Q024 [Hard] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** Why does Chapter 2 warn against ever committing real patient-level data to Git, even if later removed in a subsequent commit?
- A) Git automatically emails the data to all collaborators
- B) The data still exists in Git's history and can be retrieved via git log/git show unless history is rewritten and force-pushed
- C) GitHub charges extra storage fees for patient data
- D) Patient data cannot be stored in CSV format
**Answer:** B
**Explanation:** The chapter states a patient-level dataset "pulled into a project folder for a quick test and then 'removed' in a later commit still exists in Git's history," retrievable unless history is destructively rewritten and force-pushed.

### Q025 [Medium] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** What is the key architectural difference between Stan and JAGS described in Section 2.5?
- A) Stan model code is compiled to C++ requiring a compiler toolchain; JAGS is a standalone program installed outside R with no compiler requirement
- B) JAGS requires a GPU; Stan does not
- C) Stan only runs on Windows; JAGS only runs on Linux
- D) JAGS uses Hamiltonian Monte Carlo; Stan uses Gibbs sampling
**Answer:** A
**Explanation:** The chapter states Stan model code "is compiled to C++ before it runs," requiring a C++ toolchain, while JAGS "is a standalone program installed outside of R... so it does not share Stan's compiler requirement."

### Q026 [Medium] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** Which R package does Chapter 2 recommend over `rstan` as the interface to Stan, citing that it stays updated in step with core Stan rather than bundling an older copy?
- A) rjags
- B) cmdstanr
- C) R2jags
- D) brms
**Answer:** B
**Explanation:** The chapter states "`cmdstanr` is the interface this book recommends over the older `rstan`... `rstan` bundles its own, often older, copy of Stan directly into the R package."

### Q027 [Hard] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** What specific reproducibility gap does Docker close that `renv` alone cannot address, per Section 2.6?
- A) Docker manages R package version pinning more precisely than renv
- B) Docker pins the entire execution environment — OS, system libraries, BLAS/LAPACK implementation, and R version itself — which renv.lock does not capture
- C) Docker eliminates the need for a renv.lock file
- D) Docker automatically converts R code to Python
**Answer:** B
**Explanation:** The chapter explains renv.lock does not capture the R interpreter version, system libraries, or BLAS/LAPACK implementation, and that different BLAS implementations alone can shift floating-point results — Docker pins the entire environment including all of this.

### Q028 [Medium] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** What does Posit Package Manager (formerly RStudio Package Manager) provide that can cut a 20-minute `renv::restore()` down to under a minute?
- A) Pre-compiled binary builds of CRAN packages for specific Linux distributions
- B) A faster internet connection to CRAN's source mirrors
- C) Automatic parallelisation of model code via future/furrr
- D) A GUI replacement for the R console
**Answer:** A
**Explanation:** The chapter states Posit Package Manager "serves pre-compiled binary builds of CRAN packages for specific Linux distributions," avoiding source compilation that otherwise slows renv::restore() inside containers.

### Q029 [Easy] [MCQ]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** In the Chapter 2 package ecosystem table, which packages are listed for decision-tree modelling?
- A) survival, flexsurv
- B) rdecision, heemod
- C) BCEA, dampack, voi
- D) mice, Amelia, missForest
**Answer:** B
**Explanation:** The ref-table in Section 2.7 lists `rdecision` and `heemod` under the "Decision-tree modelling" task area, covered in Chapter 18.

### Q030 [Hard] [Image]
**Chapter(s):** 2, Setting Up an R Environment for HEOR
**Question:** IMAGE PLACEHOLDER: a diagram of a folder tree for "my-heor-project/" showing nested directories data-raw/, data/, R/, analysis/, output/, renv/, and files renv.lock and my-heor-project.Rproj, with annotation arrows explaining each folder's purpose. Based on Chapter 2's description of this structure, which folder should be fully regenerable by re-running the cleaning scripts, such that deleting it entirely and re-running those scripts reproduces it byte-for-byte?
- A) data-raw/
- B) data/
- C) R/
- D) renv/library/
**Answer:** B
**Explanation:** The chapter states "`data/` is derived, not authoritative. Everything here should be fully reproducible by re-running the cleaning scripts against `data-raw/`. If `data/` were deleted entirely, the project should be able to regenerate it byte-for-byte."

## Chapter 3: R Essentials for Health Economists

### Q031 [Easy] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** According to Chapter 3, what is true of even a single number like `42` in R?
- A) It is automatically a scalar object distinct from vectors
- B) It is a vector of length one, since R has no true scalars
- C) It must be explicitly declared as type "double"
- D) It can only be stored inside a list
**Answer:** B
**Explanation:** The chapter states "R has no true scalars: even a single number like `42` is a vector of length one."

### Q032 [Medium] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** What happens when you mix a logical vector and a character vector inside `c()`, per Chapter 3's discussion of implicit coercion?
- A) R throws an immediate error
- B) The logical vector is dropped silently
- C) The result becomes character, since the coercion hierarchy runs logical → integer → double → character
- D) R converts both to factors automatically
**Answer:** C
**Explanation:** The chapter states the coercion hierarchy is "roughly logical → integer → double → character," so a logical vector combined with a character vector becomes character — a frequent source of silent bugs.

### Q033 [Medium] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** How does single-bracket `[ ]` subsetting behave differently on a list versus a vector, per Chapter 3?
- A) Single-bracket on a list always returns a (sub-)list, even for one element, while $ and [[ ]] extract a single element
- B) Single-bracket on a list always returns a vector
- C) Single-bracket cannot be used on lists at all
- D) Single-bracket and double-bracket behave identically on lists
**Answer:** A
**Explanation:** The chapter states "single-bracket `[ ]` on a list always returns a (sub-)list, even for one element — a distinction that trips up almost everyone at least once," while `$` and `[[ ]]` extract a single element.

### Q034 [Hard] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** Chapter 3's pitfall box describes a base `data.frame` behavior involving `$` partial matching. What is the practical danger it illustrates?
- A) df$cos may silently return the cost column if no other column starts with "cos", and df[, "cost"] returns a bare vector not a one-column data frame
- B) data.frame objects cannot hold character columns
- C) Tibbles allow partial matching while data frames do not
- D) df$cos always throws an error in base R
**Answer:** A
**Explanation:** The chapter states base data.frame supports partial matching on `$`, so "df$cos may silently return the cost column," and `df[, "cost"]` "returns a bare numeric vector, not a one-column data frame" — both have caused real analysis errors.

### Q035 [Easy] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** Why do transition probability matrices for Markov cohort models naturally fit the R matrix data structure, per Chapter 3?
- A) Matrices can only store character data
- B) A transition probability matrix is a square matrix where rows sum to 1, and %*% propagates a cohort distribution one cycle forward
- C) Matrices are required to have exactly two rows
- D) Matrices cannot use dimnames for labeling states
**Answer:** B
**Explanation:** The chapter states "a transition probability matrix is naturally represented as a square matrix where rows sum to 1, and `%*%` (matrix multiplication) propagates a cohort distribution one cycle forward with a single operation."

### Q036 [Medium] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** Which three inspection functions does Chapter 3 say should become reflexive for examining R objects?
- A) head(), tail(), summary()
- B) class(), typeof(), str()
- C) print(), cat(), format()
- D) is.numeric(), is.list(), is.vector()
**Answer:** B
**Explanation:** The chapter states "class() reports the object's high-level class... typeof() reports R's internal storage type... and str() gives a compact recursive summary of structure and contents."

### Q037 [Medium] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** When should Chapter 3 recommend preferring `data.table` over `dplyr`/tidyverse for a HEOR analysis?
- A) Whenever fewer than 100 rows are involved
- B) Only when producing final submission reports in Word format
- C) When working with claims-scale or registry-scale data with millions of rows, or when runtime/memory genuinely becomes a bottleneck
- D) Only for Bayesian network meta-analysis
**Answer:** C
**Explanation:** The chapter states to "prefer `data.table` when working with claims-scale or registry-scale data (millions of rows, wide microsimulation outputs, repeated resampling such as PSA replications), when runtime or memory genuinely becomes a bottleneck."

### Q038 [Hard] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** Chapter 3's pitfall on data.table reference semantics warns that `dt2 <- dt1` behaves differently than for a data frame. What is the risk?
- A) dt2 and dt1 point to the same underlying object, so modifying one with := silently modifies the other unless copy(dt1) is used
- B) dt2 becomes immutable after assignment
- C) dt1 is automatically deleted after the assignment
- D) data.table forbids this kind of assignment entirely
**Answer:** A
**Explanation:** The chapter states data.table's in-place modification means "`dt2` and `dt1` point to the same underlying object, and modifying one with `:=` silently modifies the other," unless you explicitly use `copy(dt1)`.

### Q039 [Easy] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** What does `purrr::map()` always return, regardless of the input, per Chapter 3?
- A) A matrix
- B) A list
- C) A vector matching the input type
- D) A data frame
**Answer:** B
**Explanation:** The chapter states "the core function is `purrr::map()`, which always returns a list, regardless of what you feed it — this predictability is the whole point," unlike `sapply()` which silently simplifies output.

### Q040 [Medium] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** Per Chapter 3's heor-practice box, the `scenarios` list and `pmap_dbl()` pattern shown in Section 3.3 is described as the literal skeleton of what later technique?
- A) A PSA loop (Chapter 25), replacing the parameter grid with 1,000+ random draws
- B) A network meta-analysis in Chapter 12
- C) A Shiny app deployment in Chapter 29
- D) A Docker containerization workflow
**Answer:** A
**Explanation:** The chapter states this pattern "is not a toy exercise — it is the literal skeleton of a PSA loop," where the parameter grid becomes a 1,000+ row table of random draws and calc_total_cost() becomes the full cost-effectiveness model function.

### Q041 [Hard] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** Why does Chapter 3 recommend bundling 5+ related function arguments into a named list rather than a long positional argument signature?
- A) R cannot technically support more than 5 positional arguments
- B) Named access by $ or [[ ]] is self-documenting and immune to argument-order mistakes, unlike positional arguments which can be silently transposed
- C) Lists execute faster than positional arguments in all cases
- D) Positional arguments are deprecated in modern R versions
**Answer:** B
**Explanation:** The chapter warns that swapping the order of two positional arguments "several hundred lines away from the function definition" causes R to silently compute the wrong answer, while named list access via $ or [[ ]] avoids this.

### Q042 [Medium] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** What distinguishes `stop()` from `warning()` in Chapter 3's defensive programming guidance?
- A) stop() halts execution with an error; warning() flags a suspicious-but-not-necessarily-fatal condition without halting
- B) warning() always halts execution while stop() does not
- C) They are functionally identical in R
- D) stop() can only be used inside stopifnot()
**Answer:** A
**Explanation:** The chapter says to "reserve `warning()` for conditions that are suspicious but not necessarily fatal," such as an unusually high cost input you want flagged without halting a long PSA batch, whereas stop() halts execution with a specific message.

### Q043 [Hard] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** Per Chapter 3's agency note, why is it worse for a submitted HEOR model to silently accept an out-of-range probability than to error loudly?
- A) Silent acceptance returns a plausible-looking but wrong ICER, which is a far worse submission failure than an error caught before submission
- B) Loud errors are illegal under NICE's technology appraisal process
- C) Silent acceptance always crashes R entirely
- D) Agencies specifically prefer models that never validate inputs
**Answer:** A
**Explanation:** The chapter states "a model that silently accepts an out-of-range probability and returns a plausible-looking but wrong ICER is a far worse submission failure than one that errors loudly and gets caught before submission."

### Q044 [Medium] [MCQ]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** Chapter 3 distinguishes a censored time-to-event observation from a missing one. What is the correct way to represent censoring, per the chapter?
- A) Leave the progression date field as NA with no further annotation
- B) Carry censoring status as its own column, commonly a 0/1 event indicator, rather than inferring it from an NA date field
- C) Delete censored patients from the dataset entirely
- D) Impute a censored date using the dataset's mean progression time
**Answer:** B
**Explanation:** The chapter states a censored observation "needs to be carried as its own column (commonly a 0/1 event indicator) rather than inferred from an NA in the date field," since confusing censoring with missingness is a common source of silently wrong survival curves.

### Q045 [Hard] [Image]
**Chapter(s):** 3, R Essentials for Health Economists
**Question:** IMAGE PLACEHOLDER: an interactive flame graph (as produced by profvis::profvis()) showing a deliberately slow 500-iteration Markov-trace loop, with stacked horizontal bars of varying widths; the widest bars near the bottom of the stack are labelled rbind(), data.frame(), and as.data.frame(), together consuming well over half of total runtime, while the model/arithmetic logic bars are comparatively thin. Based on Chapter 3's explanation of how to read this figure and its accompanying ranking table, what should be fixed first before considering Rcpp or parallelisation?
- A) The model's arithmetic logic, since it is the most complex code
- B) The growing-object anti-pattern caused by calling rbind() inside the loop, which dominates total runtime via repeated reallocation and copying
- C) The random number generator seed
- D) The discount rate parameter
**Answer:** B
**Explanation:** The chapter's report-table ranks rbind(), data.frame(), and as.data.frame() as the top three time-consuming functions due to the loop reallocating and copying the growing result object each iteration, and explicitly states to "fix the growing-object pattern before considering Rcpp or parallelisation."

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

## Chapter 7: Missing Data

### Q091 [Easy] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Under Rubin's framework, which missing-data mechanism means the probability of a value being missing is pure noise, unrelated to both observed and unobserved data?
- A) MAR
- B) MCAR
- C) MNAR
- D) Informative censoring
**Answer:** B
**Explanation:** The chapter defines MCAR as missingness equivalent to "a coin flip applied independently to every record," unrelated to either observed or unobserved data.

### Q092 [Medium] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** A trial finds that non-response to a 12-week EQ-5D questionnaire is higher among patients who missed their clinic visit, and clinic attendance is associated with a *recorded* baseline severity score. What mechanism does this describe?
- A) MCAR, because the missingness pattern looks random
- B) MAR, because conditioning on the observed baseline severity explains the missingness
- C) MNAR, because the unobserved EQ-5D score itself drives missingness
- D) It cannot be classified without more statistical tests
**Answer:** B
**Explanation:** The chapter's worked example states that when missingness depends on an observed covariate (baseline severity) rather than the unobserved value itself, this is MAR.

### Q093 [Hard] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Why can MCAR, MAR, and MNAR never be distinguished using the observed data alone?
- A) Because R's `mice` package cannot compute the relevant test statistics
- B) Because the three mechanisms describe the behaviour of the *unobserved* values, and all three can produce an identical pattern of missing cells
- C) Because Little's MCAR test always returns a significant result on real data
- D) Because regulatory guidance forbids testing missingness mechanisms
**Answer:** B
**Explanation:** The text states these three scenarios "can produce an identical pattern of missing cells," and since the mechanism is a statement about unobserved values, it can never be confirmed or refuted by observed data alone.

### Q094 [Easy] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Which R package function implements Little's formal statistical test for the MCAR assumption?
- A) `visdat::vis_dat()`
- B) `naniar::gg_miss_upset()`
- C) `naniar::mcar_test()`
- D) `mice::pool()`
**Answer:** C
**Explanation:** `naniar::mcar_test()` implements Little's MCAR test, comparing means across missingness patterns to assess consistency with MCAR.

### Q095 [Medium] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** According to the chapter's pitfall note, what is the correct interpretation of a *non-significant* result from `mcar_test()`?
- A) It proves the data are MCAR and complete-case analysis is safe
- B) It only means the test found no evidence against MCAR; it is structurally blind to MNAR
- C) It confirms the data are MNAR
- D) It means multiple imputation is unnecessary
**Answer:** B
**Explanation:** The pitfall explicitly warns that a non-significant result "does not certify your data as MCAR" and that the test cannot detect MNAR, since missingness there depends on the unobserved value itself.

### Q096 [Medium] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Under what condition does the chapter consider complete-case (listwise deletion) analysis a defensible choice?
- A) Whenever more than 20% of data are missing
- B) Whenever a disease-specific instrument was used
- C) When missingness is genuinely MCAR and the proportion missing is small (under roughly 5%)
- D) Whenever the dataset includes cost and QALY variables
**Answer:** C
**Explanation:** The chapter states complete-case analysis is "a perfectly defensible choice" only when missingness is genuinely MCAR and the missing proportion is small, e.g. under 5%.

### Q097 [Hard] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Why does naive mean-imputation produce standard errors that are systematically too small?
- A) Because mean imputation always overestimates the true population mean
- B) Because filling every gap with the identical constant mechanically shrinks the completed dataset's variance, hiding the fact that each missing value was never truly known
- C) Because R's `mean()` function has a known numerical bug
- D) Because mean imputation only works for binary variables
**Answer:** B
**Explanation:** The chapter explains that filling gaps with the same `mean_fill` constant mechanically shrinks variance, so the resulting SE understates the true uncertainty of not knowing the missing values.

### Q098 [Medium] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** In `mice`, which imputation method is the default and generally preferred choice for continuous variables like cost or utility, and why?
- A) `"logreg"`, because it respects binary outcomes
- B) `"polyreg"`, because it models unordered categories
- C) `"pmm"` (predictive mean matching), because it imputes using observed donor values rather than inventing numbers outside the plausible range
- D) `"norm"`, because it always produces normally distributed imputations
**Answer:** C
**Explanation:** The text states PMM is the default and preferred for continuous variables precisely because it draws from observed donor values, keeping imputations within a plausible range.

### Q099 [Hard] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** In Rubin's rules for pooling multiply-imputed estimates, what does the "between-imputation variance" component capture that single imputation discards?
- A) The usual sampling variance from any one completed dataset
- B) How much the estimate itself varies depending on which imputed values happened to be drawn across the m datasets
- C) The measurement error of the original instrument
- D) The variance explained by the regression model's R-squared
**Answer:** B
**Explanation:** Between-imputation variance reflects how much estimates fluctuate across the m imputed datasets due to not knowing the true missing values — exactly the piece single imputation discards.

### Q100 [Medium] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** Why is the degrees of freedom for a pooled multiple-imputation estimate often a non-whole number (e.g. 47.3) that is smaller than for a complete single dataset of the same size?
- A) It is a software rounding artifact with no statistical meaning
- B) It explicitly discounts for the extra uncertainty from not knowing the true missing values, especially when imputed datasets disagree with each other
- C) It reflects the number of variables in the dataset divided by the number of imputations
- D) `pool()` always sets degrees of freedom to m − 1
**Answer:** B
**Explanation:** The difficult-terminology box explains the fractional degrees of freedom is a deliberate penalty reflecting genuine extra uncertainty, growing larger (df shrinking more) as between-imputation disagreement increases.

### Q101 [Hard] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** In a tipping-point sensitivity analysis for a cost-effectiveness ICER, what does the analysis report?
- A) The exact p-value of the primary multiple imputation model
- B) The delta (offset) applied to imputed values at which the ICER crosses the willingness-to-pay threshold, interpreted against clinical plausibility
- C) The proportion of patients lost to follow-up
- D) The value of λ that should be used in all future analyses
**Answer:** B
**Explanation:** Tipping-point analysis systematically shifts imputed values by a delta and reports the delta at which the ICER crosses λ, with the clinical judgement of whether that delta is plausible determining the conclusion's robustness.

### Q102 [Hard] [MCQ]
**Chapter(s):** 7 (Missing Data)
**Question:** The chapter identifies two "additional headaches" that missing cost and QALY data bring beyond a simple missing covariate. What are they?
- A) Measurement error and recall bias
- B) Distributional shape (skewness, zero-inflation) and the bounded ([0,1]-ish) nature of utilities
- C) Sample size and statistical power
- D) Currency conversion and inflation adjustment
**Answer:** B
**Explanation:** Section 7.6 states cost data are right-skewed and zero-inflated, while utilities are bounded (e.g., floor near −0.59, ceiling at 1), both of which an unconstrained imputation model can violate.

### Q103 [Medium] [Image]
**Chapter(s):** 7 (Missing Data)
**Question:** IMAGE PLACEHOLDER: a `naniar::vis_miss()`-style heatmap of a trial economic dataset, rows clustered by missingness pattern, showing that patients missing their 12-week EQ-5D score are the same patients missing their 12-week cost record. What does this co-occurrence pattern most plausibly support?
- A) Independent MCAR noise in each column
- B) A shared-cause MAR or MNAR story rather than independent MCAR noise
- C) That the dataset should be discarded entirely
- D) That Little's MCAR test is unnecessary
**Answer:** B
**Explanation:** The chapter states that clustering of co-missing utility and cost variables in `naniar::vis_miss()` "would support a shared-cause MAR or MNAR story rather than independent MCAR noise in each column."

### Q104 [Easy] [Image]
**Chapter(s):** 7 (Missing Data)
**Question:** IMAGE PLACEHOLDER: a ranked bar chart showing the number of missing values per variable in a trial dataset, produced with one `naniar` function. Which function generates this specific plot?
- A) `naniar::gg_miss_upset()`
- B) `naniar::gg_miss_var()`
- C) `visdat::vis_dat()`
- D) `naniar::mcar_test()`
**Answer:** B
**Explanation:** `gg_miss_var()` "plots the number (or proportion) of missing values per variable as a simple ranked bar chart," described as the fastest way to triage which columns need scrutiny.

### Q105 [Hard] [Image]
**Chapter(s):** 7 (Missing Data)
**Question:** IMAGE PLACEHOLDER: an UpSet-style plot showing combinations of co-missing variables across a wide claims dataset with cost, utility, and comorbidity fields. The chapter recommends this plot type specifically for which situation?
- A) When there are fewer than two variables with missingness
- B) When you have more than two or three variables with missingness, where a pairwise correlation plot becomes unreadable
- C) Only when all variables are binary
- D) Only for datasets with exactly one missing variable
**Answer:** B
**Explanation:** `naniar::gg_miss_upset()` "goes further and shows... combinations of co-missing variables — essential once you have more than two or three variables with missingness."

## Chapter 8: Health-Related Quality of Life and Utilities

### Q106 [Easy] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** In the HEOR sense used throughout the book, a utility is anchored so that which two values represent full health and death respectively?
- A) 100 and 0
- B) 1 and 0
- C) 10 and −10
- D) 1 and −1
**Answer:** B
**Explanation:** The chapter states a utility is "a single number that expresses how good or bad a health state is, anchored so that 1 represents full health and 0 represents dead."

### Q107 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Why does NICE's reference case require a generic preference-based instrument like EQ-5D for the base-case QALY calculation rather than a disease-specific instrument?
- A) Disease-specific instruments are always more expensive to administer
- B) A common, cross-disease utility currency is needed so "1 QALY" means the same thing when comparing a TB regimen against a cardiology or oncology intervention competing for the same budget
- C) Disease-specific instruments cannot be scored by computer software
- D) NICE guidance bans disease-specific instruments from trials entirely
**Answer:** B
**Explanation:** The chapter explains resource-allocation bodies compare interventions across disease areas against one WTP threshold, which "is only coherent if '1 QALY' means the same thing regardless of which disease produced it" — requiring a common generic instrument.

### Q108 [Medium] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** What is the central function of the CRAN `eq5d` package used for?
- A) Fitting beta regression models to utility data
- B) Converting respondent-level EQ-5D dimension scores into a single utility index using a specified country's value set
- C) Performing Little's MCAR test on utility data
- D) Running discrete choice experiment conditional logit models
**Answer:** B
**Explanation:** `eq5d()` "takes a data frame of respondent-level dimension scores... and an argument specifying which national value set to apply, returning a single utility index."

### Q109 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Why does scoring the same EQ-5D health-state profile with a UK value set versus a US value set produce different utility numbers?
- A) The two countries' populations use different numbers of dimensions
- B) The two populations' revealed preferences for health-state descriptions (e.g. extreme pain/discomfort) are not identical, since value sets are country-specific
- C) The US value set has not been validated by the EuroQol Group
- D) US respondents are not asked time trade-off questions
**Answer:** B
**Explanation:** The chapter states value sets reflect the preferences of the population in which they were elicited, and "different countries' general publics do not value the same health-state descriptions identically."

### Q110 [Medium] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** What is the purpose of a "mapping" or "crosswalk" algorithm in utility estimation?
- A) To convert currency units between countries for cost reporting
- B) To predict an EQ-5D-equivalent utility from a disease-specific instrument score, using a model fit in an external dataset where both instruments were collected
- C) To impute missing baseline covariates in a regression model
- D) To test whether missingness is MCAR
**Answer:** B
**Explanation:** Mapping fits a statistical model in an external dataset with both instruments, then applies that algorithm to a trial's disease-specific scores to generate the utility currency the HTA model needs.

### Q111 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** What is the key difference between direct (response) mapping and indirect (utility/value) mapping?
- A) Direct mapping models each EQ-5D dimension separately via ordinal regression, then runs predictions through the value set; indirect mapping regresses the already-computed utility index directly against disease-specific scores
- B) Direct mapping is always more accurate and should be preferred universally
- C) Indirect mapping requires fitting five separate ordinal regression models
- D) Direct mapping cannot be validated by cross-validation
**Answer:** A
**Explanation:** Direct mapping models the five ordered dimension responses (e.g. via `MASS::polr()`) and composes through the value set; indirect mapping regresses the single utility index directly, losing EQ-5D's compositional structure.

### Q112 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Why is fitting `lm()` (OLS) directly to a raw EQ-5D utility index considered theoretically poor, despite being common in the mapping literature?
- A) `lm()` cannot run on data with more than 200 observations
- B) OLS allows predicted values above 1.0 or in otherwise impossible regions, and its homoscedastic-normal-error assumption misdescribes a boundary-spiked, skewed outcome
- C) OLS requires the outcome variable to be strictly binary
- D) R does not support linear regression on utility data
**Answer:** B
**Explanation:** The text states OLS "allows predicted values above 1.0" and its constant-variance normal-error assumption is "a poor description of a variable with a boundary spike," motivating beta regression, censored regression, or mixture models instead.

### Q113 [Medium] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Under a multiplicative age/sex-adjustment approach to disease-specific utility, why is this generally preferred over a purely additive adjustment in long-horizon cohort models?
- A) Multiplicative adjustments are easier to code than additive ones
- B) Multiplicative approaches naturally compress toward (but rarely cross) zero, avoiding the risk of implausible negative utilities after stacking many decrements over 20–30 years
- C) Additive adjustments cannot be implemented in R
- D) Multiplicative adjustment eliminates the need for background mortality data
**Answer:** B
**Explanation:** The chapter notes additive adjustment "is more prone to producing negative or clearly implausible utilities" over a long horizon, since "there is no multiplicative floor stopping the cumulative subtraction from running arbitrarily low."

### Q114 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Why must background (all-cause) mortality be layered onto disease-specific mortality in a long-horizon Markov model?
- A) Because disease-specific mortality data are never available
- B) Without it, the model implicitly assumes a cohort member who survives the modelled disease never dies of anything else, overstating survival, QALYs, and costs in later cycles
- C) Because NICE prohibits disease-specific mortality estimates
- D) Because background mortality replaces the need for discounting
**Answer:** B
**Explanation:** The chapter explains that omitting age/sex-specific all-cause mortality "overstates survival and therefore overstates total QALYs and costs accrued in later cycles."

### Q115 [Easy] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** In a Time Trade-Off (TTO) elicitation, if a respondent is indifferent between living T years in an impaired health state and living x years (x < T) in full health, how is the utility of the impaired state calculated?
- A) utility = T − x
- B) utility = x/T
- C) utility = T/x
- D) utility = 1 − (x/T)
**Answer:** B
**Explanation:** The chapter states "at that indifference point, the utility of the impaired health state is simply x/T."

### Q116 [Medium] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** In a Standard Gamble (SG) elicitation, what does the indifference probability p represent?
- A) The proportion of respondents who preferred the gamble
- B) The utility of the health state, read off directly as the probability of full health at which the respondent is indifferent between the certain health state and the gamble
- C) The probability that the respondent misunderstood the question
- D) The confidence interval width around the TTO estimate
**Answer:** B
**Explanation:** The text states "the utility of the health state is then read off directly as that indifference probability p" once the respondent is indifferent between the certain state and the gamble.

### Q117 [Hard] [MCQ]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** Why can a Discrete Choice Experiment (DCE) alone not directly produce utilities anchored at dead = 0 and full health = 1?
- A) DCE choice data cannot be analysed statistically
- B) DCE yields utilities only on an arbitrary scale anchored between the best and worst profiles shown, requiring a TTO/SG anchoring component to reach the dead=0/full-health=1 metric
- C) DCE requires face-to-face interviews that are logistically impossible
- D) DCE can only be used for disease-specific instruments
**Answer:** B
**Explanation:** The chapter states a DCE alone "only yields utilities on an arbitrary scale," so many value-set studies combine DCE with a TTO/SG component "specifically to anchor the resulting scale."

### Q118 [Medium] [Image]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** IMAGE PLACEHOLDER: a histogram of EQ-5D-type utility scores for a mild-severity subgroup, showing roughly 25% of observations piled exactly at 1.0 and a left-skewed spread below it, as summarised in the chapter's table "Mean (SD) EQ-5D-type utility and ceiling-spike proportion by disease severity subgroup." What does this ceiling spike primarily justify?
- A) Using ordinary least squares without modification
- B) Rejecting OLS in favour of methods such as beta regression, censored (Tobit) regression, or finite mixture models that respect the boundary and skew
- C) Discarding the mild-severity subgroup entirely
- D) Treating all utilities above 0.8 as missing data
**Answer:** B
**Explanation:** Section 8.4 states the visible ceiling spike at 1.0 is "the whole reason OLS was rejected in favour of beta regression," alongside censored regression and mixture models as alternatives.

### Q119 [Hard] [Image]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** IMAGE PLACEHOLDER: a line chart plotting general-population EQ-5D norm utility against age band (18–44 through 75+), declining from about 0.93 to 0.72, with a second line showing an age-adjusted disease-specific utility starting at 0.80 at age 45–54. According to the chapter's worked multiplicative age-adjustment, what is the age-adjusted disease utility at the 75+ band?
- A) 0.800 (unchanged)
- B) approximately 0.655
- C) approximately 0.72
- D) approximately 1.000
**Answer:** B
**Explanation:** The chapter's table computes 0.80 × (0.72/0.88) ≈ 0.655 as the age-adjusted disease utility in the 75+ band, following the multiplicative norm-ratio formula.

### Q120 [Medium] [Image]
**Chapter(s):** 8 (Health-Related Quality of Life and Utilities)
**Question:** IMAGE PLACEHOLDER: a methods-section table comparing TTO, Standard Gamble, and DCE side by side on elicited quantity, theoretical basis, and anchoring to dead=0. Which method's theoretical basis is explicitly rooted in von Neumann–Morgenstern expected utility theory?
- A) Time Trade-Off (TTO)
- B) Standard Gamble (SG)
- C) Discrete Choice Experiment (DCE)
- D) Random utility theory does not apply to any of the three
**Answer:** B
**Explanation:** The chapter's comparison table lists SG's theoretical basis as "von Neumann-Morgenstern expected utility theory," distinguishing it from TTO (practical/intuitive) and DCE (random utility theory).

## Chapter 9: Costs and Resource Use

### Q121 [Easy] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** The chapter decomposes costing into three steps. What are they?
- A) Collection, cleaning, and reporting
- B) Identification, measurement, and valuation
- C) Discounting, inflation, and conversion
- D) Sampling, imputation, and pooling
**Answer:** B
**Explanation:** Section 9.1 states costing is "conventionally decomposed into three steps... identification... measurement... and valuation."

### Q122 [Medium] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** Why does the chapter recommend keeping quantity and unit cost as separate columns rather than pre-multiplying into a single "total cost" field?
- A) R cannot multiply two numeric columns together
- B) Separating them enables deterministic and probabilistic sensitivity analysis on unit cost or quantity independently, and re-valuation under a different country's cost list
- C) Total cost columns are not supported by `dplyr`
- D) Separate columns reduce the file size of the dataset
**Answer:** B
**Explanation:** The heor-practice note states keeping quantity and unit cost separate "is what allows deterministic sensitivity analysis on the unit cost alone, probabilistic sensitivity analysis... and re-valuation under a different country's cost list."

### Q123 [Hard] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** What is the common analyst error the chapter flags regarding unit costs from multiple facility types (e.g., district hospital vs. primary health centre)?
- A) Using INR instead of USD throughout
- B) Averaging the raw unit costs before joining to resource-use quantities, rather than averaging total costs or weighting by caseload
- C) Failing to round unit costs to the nearest integer
- D) Applying PPP conversion to unit costs instead of total costs
**Answer:** B
**Explanation:** The pitfall notes "averaging unit costs first silently assumes equal patient volume at each facility" — total costs should be averaged (or weighted by caseload) instead.

### Q124 [Medium] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** When inflating and currency-converting unit costs, what is the correct order of operations?
- A) Convert currency first, then inflate to a common price year
- B) Inflate to a common price year within the source currency first, then convert currency
- C) Order does not matter as long as both steps are eventually applied
- D) Apply PPP conversion twice to cancel out exchange-rate volatility
**Answer:** B
**Explanation:** The chapter states explicitly: "inflate to a common price year within the source currency first, then convert currency... second. Reversing the order mixes an inflation index computed in one currency with a conversion factor computed in another."

### Q125 [Medium] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** When is a PPP (purchasing power parity) conversion factor preferred over a nominal exchange rate for currency conversion?
- A) When comparing real resource burden across countries of different income levels, such as benchmarking an Indian TB-programme analysis against global literature unit costs
- B) Whenever reporting to a NICE-facing submission exclusively
- C) Only when converting from USD to EUR
- D) PPP should never be used in HEOR analyses
**Answer:** A
**Explanation:** The chapter states PPP conversion factors "are the standard choice when the purpose is comparing real resource burden across countries of different income levels," unlike nominal exchange rates which reflect market trading value.

### Q126 [Hard] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** What is the key geometric difference between how cost data and utility data violate OLS assumptions?
- A) Costs have a spike at a ceiling like utilities do
- B) Costs are bounded only below at 0 with no upper ceiling and heavy right tails (spike at the floor), while utilities are bounded on [0,1]-ish with a ceiling spike at 1
- C) Costs are always normally distributed while utilities are skewed
- D) There is no meaningful difference between the two data types
**Answer:** B
**Explanation:** The chapter states costs are "bounded only below at 0, have no natural upper ceiling, and the 'spike' sits at the floor," contrasting with utilities' two-sided [0,1] bound with a ceiling spike at 1.

### Q127 [Medium] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** Why does the chapter insist that structural zeros in cost data (e.g., no hospitalisation at all) should not be treated as missing data?
- A) Because R cannot represent zero values in a numeric vector
- B) Because the zeros represent genuine events that never happened, and treating them as missing (imputing or dropping) biases the estimate just as treating them as an ordinary low continuous value (e.g., plain log-OLS) does
- C) Because zero-cost patients should always be excluded from cost-effectiveness analysis
- D) Because structural zeros only occur in LMIC settings
**Answer:** B
**Explanation:** The chapter explicitly distinguishes these as "structural zeros (the event never happened), not missing data," warning that both imputing/dropping them and fitting a single continuous-only model are wrong.

### Q128 [Hard] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** Why does exponentiating a prediction from a model fit as `lm(log(cost) ~ ...)` fail to recover the arithmetic mean cost needed for an ICER?
- A) Exponentiation is mathematically undefined for cost data
- B) Exponentiating a log-OLS prediction recovers the median (geometric mean) on the original scale, not the arithmetic mean, which is what sums like total programme cost require
- C) `lm()` cannot fit models with a `log()` transformation applied to the outcome
- D) The arithmetic mean is always smaller than the geometric mean
**Answer:** B
**Explanation:** The pitfall states this "recovers the median (geometric mean)... not the arithmetic mean," and total cost/ICER calculations are built from sums requiring the arithmetic mean — hence the need for Duan's smearing estimator if working on the log scale.

### Q129 [Medium] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** What practical advantage does a gamma GLM with a log link have over a log-OLS model for cost data?
- A) It requires fewer observations to fit
- B) It models the mean of cost directly via the log link, exponentiated back by `type = "response"`, so no retransformation step or smearing correction is needed
- C) It eliminates the need to check for zero-cost patients
- D) It assumes constant variance just like OLS
**Answer:** B
**Explanation:** The chapter states the gamma GLM "models the mean of cost directly... so there is no retransformation step and no smearing correction needed," unlike log-OLS.

### Q130 [Easy] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** In a two-part (hurdle-style) model for zero-inflated costs, how is expected cost decomposed?
- A) E(cost) = mean(cost) × proportion of zeros
- B) E(cost | x) = P(cost > 0 | x) × E(cost | cost > 0, x)
- C) E(cost | x) = P(cost = 0 | x) + E(cost | cost > 0, x)
- D) E(cost | x) = median(cost) / variance(cost)
**Answer:** B
**Explanation:** The chapter states explicitly that two-part models "decompose expected cost cleanly as E(cost | x) = P(cost > 0 | x) × E(cost | cost > 0, x)."

### Q131 [Easy] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** What is the key distinction between prevalence-based and incidence-based cost-of-illness (COI) studies?
- A) Prevalence-based sums all costs in a defined period across everyone with the condition; incidence-based follows newly diagnosed patients over their full episode
- B) Prevalence-based only applies to LMICs; incidence-based only applies to high-income countries
- C) They are two names for the same methodology
- D) Incidence-based studies never use micro-costing
**Answer:** A
**Explanation:** The chapter defines prevalence-based COI as summing costs in a calendar period regardless of diagnosis timing, versus incidence-based COI following a cohort of newly diagnosed patients through their full episode.

### Q132 [Hard] [MCQ]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** Why is a naive mean of observed costs biased in a longitudinal study with censored (incomplete follow-up) patients?
- A) Because R's `mean()` function ignores NA values by default
- B) Because costs accrue over time, so a patient censored early has had less opportunity to accumulate cost than one followed to completion, making simple averaging conflate "cheap" with "short follow-up"
- C) Because censored patients always have zero cost
- D) Because censoring only affects QALYs, not costs
**Answer:** B
**Explanation:** The chapter explains that "simply summing observed costs without any time adjustment conflates 'this patient was cheap' with 'this patient was only followed for three weeks.'"

### Q133 [Hard] [Image]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** IMAGE PLACEHOLDER: a histogram of simulated TB programme cost data (n=1,200) as shown in the chapter's figure, showing a visible spike of zero-cost patients at the floor, a heavy right tail from rare catastrophic cases, and a mean well above the median. What is the primary modelling implication of this distributional signature?
- A) Ordinary least squares on raw cost is a poor default; gamma GLMs or two-part models are more appropriate
- B) The data should be discarded because it is simulated
- C) A simple t-test on raw cost is sufficient
- D) The zero-cost patients should be removed before any analysis
**Answer:** A
**Explanation:** The chapter states this is "exactly the pattern that makes 'fit OLS on raw cost' a poor default," motivating the gamma GLM and two-part model approaches of Section 9.4.

### Q134 [Medium] [Image]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** IMAGE PLACEHOLDER: the chapter's unit-cost reference table for a TB programme (item, unit cost, currency = INR, price year = 2023) as published alongside a costing analysis. Per CHEERS 2022 item 15, what must be reported alongside such a table?
- A) Only the total programme budget for the year
- B) The currency, price date, and the conversion method applied (nominal exchange rate or PPP) if costs were converted
- C) The number of patients enrolled in the trial
- D) The statistical software version used
**Answer:** B
**Explanation:** The chapter states CHEERS 2022 item 15 "requires explicit reporting of currency, price date, and the conversion method applied," directly alongside any cost table.

### Q135 [Hard] [Image]
**Chapter(s):** 9 (Costs and Resource Use)
**Question:** IMAGE PLACEHOLDER: the chapter's summary table comparing censored-cost-handling methods (naive mean, complete-case/drop censored, Lin et al.'s partitioned estimator, IPCW) by bias direction under informative follow-up. According to the table, which method is biased *upward* because it over-represents patients followed to completion?
- A) Lin et al.'s partitioned estimator
- B) Inverse-probability-of-censoring weighting (IPCW)
- C) Complete-case analysis (dropping censored patients)
- D) Naive mean of observed cost
**Answer:** C
**Explanation:** The table states complete-case analysis is "biased upward: discards exactly the shortest-followed patients, over-representing those followed to completion," unlike the naive mean (biased downward) or Lin's/IPCW (consistent under non-informative censoring).

## Chapter 10: Survival Analysis for Economic Evaluation

### Q136 [Easy] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** What does the hazard function describe, as distinguished from the Kaplan-Meier survival probability?
- A) The cumulative fraction of patients who have died since the start of follow-up
- B) The instantaneous risk of the event happening right now, given survival to this point
- C) The total number of patients still enrolled in the trial
- D) The proportion of patients censored before the end of follow-up
**Answer:** B
**Explanation:** The chapter's speedometer-vs-odometer analogy makes this explicit: survival probability is a cumulative, backward-looking summary, while the hazard is a forward-looking, instantaneous rate re-calculated continuously as time passes.

### Q137 [Easy] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** In `survival::survfit(Surv(time, status) ~ arm, data = trial_df)`, what does the `~ arm` term accomplish?
- A) It converts the survival times to a parametric distribution
- B) It stratifies the Kaplan-Meier curve by treatment arm
- C) It applies inverse-probability-of-censoring weights
- D) It fits a Cox proportional hazards model instead of a KM curve
**Answer:** B
**Explanation:** §10.1 states the `~ arm` term stratifies the KM curve by treatment arm, which is essential since HEOR work usually compares extrapolated survival between an intervention and a comparator.

### Q138 [Easy] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** Which of the six standard parametric distributions fitted with `flexsurvreg()` assumes a constant hazard over time?
- A) Gompertz
- B) Exponential
- C) Log-logistic
- D) Generalised gamma
**Answer:** B
**Explanation:** §10.2 describes the exponential distribution as having a constant hazard, one parameter, and being "almost never plausible for a chronic disease but a useful lower-bound sanity check."

### Q139 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** According to the chapter's pitfall in §10.2, why is comparing AIC/BIC across the six standard parametric distributions insufficient on its own for choosing an extrapolation model?
- A) AIC/BIC cannot be computed for distributions with more than two parameters
- B) AIC/BIC only measure fit within the observed data range and say nothing about divergence once extrapolated
- C) AIC and BIC always select the same model, so comparing both is redundant
- D) AIC/BIC require the proportional hazards assumption to hold
**Answer:** B
**Explanation:** The chapter warns that two distributions can have near-identical AIC within a trial's follow-up window yet diverge wildly once projected over a longer horizon, so the extrapolated curve must always be plotted and checked separately.

### Q140 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** In `flexsurv::flexsurvspline()`, what does setting `k = 0` internal knots produce?
- A) An error, since at least one knot is required
- B) A model equivalent to one of the standard parametric families (e.g. Weibull-equivalent on the hazard scale)
- C) A non-parametric Kaplan-Meier estimate
- D) A mixture cure model with zero cure fraction
**Answer:** B
**Explanation:** §10.3 explains that `k = 0` collapses the Royston-Parmar spline to a standard parametric family depending on the `scale=` argument, defaulting to the Weibull-equivalent on the hazard scale, making it a useful flexibility baseline.

### Q141 [Hard] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** In a mixture cure model fitted with `flexsurvcure(mixture = TRUE)`, how is overall survival S(t) structured?
- A) S(t) = π^(1 − S_u(t)), where π is the cure fraction
- B) S(t) = π + (1 − π) × S_u(t), where π is the cure fraction and S_u(t) is the uncured-group survival
- C) S(t) is identical to the ordinary Weibull survival function
- D) S(t) = π × S_u(t), ignoring the uncured subgroup entirely
**Answer:** B
**Explanation:** §10.4 gives the mixture-cure structure explicitly as S(t) = π + (1 − π)S_u(t): a cured fraction with survival fixed at 1 forever, blended with an uncured fraction following the chosen parametric distribution. (The π^(1−S_u(t)) form is the non-mixture structure instead.)

### Q142 [Hard] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** The chapter's pitfall on cure models warns that a fitted cure fraction can be spuriously inflated. What is the single most common cause it identifies?
- A) Using the non-mixture rather than mixture cure structure
- B) Fitting the uncured population with a log-normal distribution instead of Weibull
- C) Short or administratively-censored follow-up that makes the KM curve flatten near the end for reasons unrelated to true biological cure
- D) Omitting covariates from the `anc` argument
**Answer:** C
**Explanation:** The pitfall explicitly states that short or administratively-censored follow-up is the single most common cause of a spuriously large cure estimate, because censoring can flatten the KM curve in the same visual way genuine cure would.

### Q143 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** What is the defining feature of a "landmark" extrapolation approach described in §10.5?
- A) It uses only parametric curves for the entire observed and extrapolated period
- B) It uses the empirical Kaplan-Meier estimate for the observed trial duration, then splices in a parametric/spline extrapolation only beyond a chosen landmark time
- C) It fits a single Weibull curve across both the active-treatment and surveillance phases
- D) It requires reconstructing individual patient data from a published curve
- E) (not applicable)
**Answer:** B
**Explanation:** The chapter describes the landmark approach as trusting the real, observed KM curve for as long as good data exist, then handing off to a fitted parametric curve only for the unobserved tail beyond that point.

### Q144 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** Per the piecewise-model pitfall in §10.5, how should cut-points for a piecewise/landmark model ideally be chosen?
- A) By testing many cut-points and selecting the one with the best-looking kink in the KM curve
- B) By maximizing I-squared across candidate cut-points
- C) Pre-specified from a clinical rationale, such as the end of a fixed treatment course or a protocol-defined visit
- D) Automatically, using the AIC-minimizing time point from `flexsurvspline()`
**Answer:** C
**Explanation:** The pitfall equates eyeballing the KM curve for the best-looking kink with moving a regression breakpoint until R² improves — a multiple-comparisons problem — and recommends pre-specified clinical cut-points instead.

### Q145 [Easy] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** What does `survival::cox.zph()` test?
- A) Whether the Kaplan-Meier curve differs significantly between arms
- B) Whether the scaled Schoenfeld residuals from a fitted Cox model are correlated with time
- C) Whether a cure fraction is statistically supported
- D) Whether two parametric distributions have equivalent AIC
**Answer:** B
**Explanation:** §10.7 states `cox.zph()` tests whether scaled Schoenfeld residuals are correlated with time; under the proportional hazards assumption, residuals should fluctuate randomly around zero, while a trend indicates a time-varying effect.

### Q146 [Hard] [Image]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** IMAGE PLACEHOLDER: a chart showing the observed Kaplan-Meier curve (black step function) with all six standard parametric families (exponential, Weibull, Gompertz, log-logistic, log-normal, generalised gamma) overlaid within the trial follow-up window, closely clustering together, as in the figure referenced in §10.2. Based on the chapter's text accompanying this figure, why might such visual clustering within the observed window be misleading for model selection?
- A) It proves all six distributions are equally valid for any extrapolation horizon
- B) The divergence between distributions that matters for extrapolation typically only becomes visible once curves are projected beyond the observed data
- C) It shows that the Kaplan-Meier estimator is invalid once six parametric curves are fitted
- D) It means the log-likelihood cannot be computed for any of the six models
**Answer:** B
**Explanation:** The figure caption in §10.2 notes that within the trial's follow-up window the fits visually cluster close to the KM curve and each other, but the divergence that matters for extrapolation only becomes visible once the curves are projected beyond the observed data.

### Q147 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** In the context of competing risks, what is the key practical advantage of the subdistribution (Fine-Gray) hazard over the cause-specific hazard for a cost-effectiveness model?
- A) It is easier to compute by hand
- B) It directly models the cumulative incidence function — the actual probability mass flowing into each state in the presence of competing risks
- C) It eliminates the need for a transition matrix in `mstate`
- D) It assumes competing events never occur
**Answer:** B
**Explanation:** §10.10 explains the subdistribution hazard keeps patients who had a competing event in the risk set and directly models the cumulative incidence function, which is usually the quantity a cost-effectiveness model needs rather than a hypothetical cause-specific rate.

### Q148 [Medium] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** What critical extra ingredient, beyond a digitized Kaplan-Meier curve, does the Guyot et al. (2012) IPD-reconstruction algorithm require?
- A) A pre-fitted Weibull model
- B) The numbers-at-risk table printed beneath the curve
- C) A multi-state transition matrix
- D) The original patient-level trial protocol
**Answer:** B
**Explanation:** §10.11 states the numbers-at-risk table beneath the curve is "the critical extra ingredient the original KM figure alone does not give you," anchoring how many individuals are censored versus experiencing events between risk-table intervals.

### Q149 [Hard] [MCQ]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** According to §10.12, what distinguishes NICE DSU TSD 21 from TSD 14?
- A) TSD 21 replaces TSD 14 entirely and makes the six standard parametric distributions obsolete
- B) TSD 21 extends TSD 14 by covering flexible spline-based (Royston-Parmar) models and cure models, which the standard six-distribution family cannot represent
- C) TSD 21 only applies to diagnostic test accuracy studies
- D) TSD 21 is concerned exclusively with proportional hazards testing
**Answer:** B
**Explanation:** The chapter describes TSD 21 as extending TSD 14's logic by covering Royston-Parmar spline models and cure models — structural assumptions, like a cured fraction, that none of TSD 14's six standard distributions can represent.

### Q150 [Easy] [Image]
**Chapter(s):** 10 — Survival Analysis for Economic Evaluation
**Question:** IMAGE PLACEHOLDER: a Kaplan-Meier curve plotted against a chosen parametric fit (Gompertz), solid where fitted to real trial-period data and dashed where it is pure extrapolation beyond a 36-month follow-up window, with a vertical dotted line marking the trial's end, as described in the §10.1 figure. What does everything to the right of the vertical dotted line represent?
- A) Additional observed trial data not yet included in the KM curve
- B) A model assumption rather than an observation, which should be labelled as such in any submission
- C) Background general-population mortality only
- D) Data that failed the proportional hazards test
**Answer:** B
**Explanation:** The figure caption explicitly states that everything to the right of the trial's end marker "is a model assumption, not an observation, and should be labelled as such in any submission."

## Chapter 11: Meta-Analysis

### Q151 [Easy] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** What key assumption distinguishes a fixed-effect (common-effect) meta-analysis model from a random-effects model?
- A) Fixed-effect models require binary outcomes, random-effects models require continuous outcomes
- B) A fixed-effect model assumes every study estimates the same true effect, while a random-effects model assumes each study estimates its own true effect drawn from a distribution of effects
- C) Fixed-effect models always produce narrower confidence intervals and are therefore preferred
- D) Random-effects models cannot be fitted with the `meta` package
**Answer:** B
**Explanation:** §11.1 states the fixed-effect model assumes all studies share one true effect with differences being pure sampling noise, while the random-effects model assumes each study's true effect is drawn from a distribution of true effects across settings.

### Q152 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** Why does the chapter recommend REML over DerSimonian-Laird (DL) as the primary τ² estimator in most HEOR meta-analyses?
- A) DL cannot be computed in R
- B) REML is a closed-form, non-iterative method while DL requires numerical optimization
- C) DL is known to understate τ² — and hence understate the confidence interval width — with few studies or rare binary events, while REML produces less biased variance estimates in that situation
- D) REML always produces statistically significant pooled effects
**Answer:** C
**Explanation:** §11.1 explains DL tends to understate τ² (and CI width) with small numbers of studies or rare events, while REML is generally preferred because it produces less biased variance estimates, particularly with few studies — a common situation in TB meta-analyses.

### Q153 [Easy] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** Which statistic rescales the information in Q and τ² into a percentage representing the share of total variability due to real between-study disagreement rather than sampling noise?
- A) I²
- B) The p-value from Egger's test
- C) SUCRA
- D) The diagnostic odds ratio
**Answer:** A
**Explanation:** §11.2 describes I² as solving the readability problem of τ² by rescaling the same information into a percentage of total variability attributable to genuine between-study disagreement, which is why I² is the most frequently quoted heterogeneity statistic.

### Q154 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** How does a prediction interval differ from a confidence interval around a pooled random-effects estimate?
- A) A prediction interval is always narrower because it only concerns one future study
- B) A prediction interval accounts for both uncertainty in the average effect and genuine study-to-study variation, so it is wider than the confidence interval
- C) A confidence interval and prediction interval are mathematically identical under random effects
- D) A prediction interval is only defined for fixed-effect models
**Answer:** B
**Explanation:** §11.2 explains that because individual studies' true effects genuinely vary, the prediction interval — answering what range a brand-new study's true effect would plausibly fall in — must be wider than the confidence interval, which only reflects precision of the average.

### Q155 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** What does asymmetry in a funnel plot (a gap in one bottom corner) visually suggest?
- A) That the random-effects model fits better than the fixed-effect model
- B) Possible publication bias or small-study effects, where smaller studies with unfavourable results may be missing
- C) That the I² statistic has been miscalculated
- D) That the pooled estimate must be discarded entirely
**Answer:** B
**Explanation:** §11.3 describes asymmetry — a gap where small, unfavourable-result studies "should" be but aren't — as the visual signature of concern for publication bias or small-study effects.

### Q156 [Hard] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** According to §11.3's pitfall, why is it problematic to run Egger's test or trim-and-fill mechanically whenever a funnel plot is available?
- A) These methods only work for continuous outcomes
- B) With fewer than ten studies (common in TB-programme meta-analyses), both methods have poor power and can produce misleading corrections driven by one or two outlying studies
- C) Egger's test cannot be computed in either the `meta` or `metafor` package
- D) Trim-and-fill always increases, never decreases, the pooled estimate
**Answer:** B
**Explanation:** The pitfall states that with fewer than ten studies, both Egger's test and trim-and-fill have poor power and can produce misleading corrections, so the funnel plot should instead be described qualitatively with the limitation flagged.

### Q157 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** In `metafor::rma()`, what does the `mods=` argument enable?
- A) Specification of the summary measure (RR, OR, MD, SMD)
- B) Addition of study-level moderators (predictors) to explain between-study heterogeneity, i.e. meta-regression
- C) Selection between fixed- and random-effects pooling
- D) Back-transformation of pooled proportions to the natural scale
**Answer:** B
**Explanation:** §11.4 describes `mods=` as accepting a formula of study-level moderators (e.g. mean age, region) to explain heterogeneity, partitioning total heterogeneity into the portion explained by moderators (QM) and residual heterogeneity.

### Q158 [Hard] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** What is "ecological bias" in the context of meta-regression, as warned about in §11.4's pitfall?
- A) Bias caused by excluding environmental/geographic covariates from the model
- B) The error of interpreting a between-study (aggregate-level) association as if it were a within-study (patient-level) association
- C) Bias arising only when fewer than ten studies are pooled
- D) A bias specific to double-arcsine transformed proportions
**Answer:** B
**Explanation:** The pitfall explains that meta-regression coefficients describe between-study associations, so a finding like "trials with older average age show smaller effects" says nothing reliable about whether an individual older patient benefits less — conflating the two is ecological bias.

### Q159 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** Why must hazard ratios be pooled on the log scale rather than their natural scale, per §11.5?
- A) Because `metagen()` only accepts log-transformed inputs
- B) Because HRs are ratios bounded below by zero and skewed, while the log scale is much closer to a normal distribution, suitable for inverse-variance pooling
- C) Because NICE DSU TSD 14 requires it as a reporting formality
- D) Because the log scale eliminates the need for standard errors
**Answer:** B
**Explanation:** §11.5 states that HRs are pooled on the log scale "where the sampling distribution is much closer to normal," since HRs themselves are bounded below by zero and skewed.

### Q160 [Hard] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** Why is pooling sensitivity and specificity separately considered wrong in a diagnostic test accuracy meta-analysis (§11.6)?
- A) Sensitivity and specificity cannot both be estimated from the same 2x2 table
- B) The two measures are not independent — a study reading a threshold more liberally will tend to show higher sensitivity and lower specificity together, so their negative correlation must be modelled jointly
- C) `mada::reitsma()` only accepts one of the two measures as input
- D) Sensitivity and specificity have different units and cannot be compared
**Answer:** B
**Explanation:** The chapter explains sensitivity and specificity move together depending on threshold choice, so a bivariate random-effects model that respects this negative correlation (via `reitsma()`) is needed rather than pooling each measure as if independent.

### Q161 [Medium] [Image]
**Chapter(s):** 11 — Meta-Analysis
**Question:** IMAGE PLACEHOLDER: a forest plot from `meta::forest()` showing nine studies with weight-sized confidence intervals, a pooled random-effects diamond at the bottom, and a prediction interval, as described in the §11.2 figure. What is the single most useful diagnostic purpose of this plot, according to the chapter text?
- A) It replaces the need to calculate I² or τ²
- B) It should be read before any summary statistic, because a cluster of overlapping intervals with one clear outlier tells a different, more actionable story than a diffuse spread of non-overlapping intervals, even with similar I²
- C) It only shows statistical significance, not effect direction
- D) It is used exclusively for diagnostic test accuracy reviews
**Answer:** B
**Explanation:** §11.2 states the forest plot "remains the single most useful diagnostic in this chapter" and should be read before any summary statistic for exactly the reason given in option B.

### Q162 [Medium] [Image]
**Chapter(s):** 11 — Meta-Analysis
**Question:** IMAGE PLACEHOLDER: an SROC (summary receiver operating characteristic) curve from `mada::reitsma()`, showing study-level sensitivity/false-positive-rate pairs as triangles plus a pooled summary point with 95% confidence and prediction regions, as in the §11.6 figure. What role does the SROC curve play in a diagnostic test accuracy review?
- A) It is the diagnostic analogue of the funnel plot for assessing publication bias
- B) It is the bivariate analogue of the forest plot, tracing the implied sensitivity/specificity trade-off while capturing the two correlated axes at once
- C) It shows only the pooled diagnostic odds ratio
- D) It replaces the need for a bivariate random-effects model
**Answer:** B
**Explanation:** §11.6 explicitly describes the SROC curve as "the bivariate analogue of the forest plot" for pairwise meta-analysis, capturing the correlated sensitivity/specificity axes simultaneously.

### Q163 [Easy] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** Which transformation is recommended in §11.7 when pooling proportions that include studies with values near 0 or 1 (e.g. rare resistance patterns)?
- A) Logit transformation
- B) Log transformation
- C) Double-arcsine (Freeman-Tukey) transformation
- D) Z-transformation
**Answer:** C
**Explanation:** The chapter states that when some studies have proportions near 0 or 1, the logit transform can behave poorly, and the double-arcsine (Freeman-Tukey) transformation — `measure = "PFT"` in `escalc()` — is the usual alternative.

### Q164 [Hard] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** According to §11.7's pitfall, why might very high I² (often exceeding 90%) when pooling prevalence or incidence across sites not necessarily indicate a broken model?
- A) High I² in proportion meta-analyses is always a software calculation error
- B) True prevalence genuinely differs by geography, population risk, and surveillance intensity, so a single pooled figure may misrepresent genuinely different underlying populations
- C) I² cannot be computed for log-transformed rates
- D) High I² only occurs with the double-arcsine transformation
**Answer:** B
**Explanation:** The pitfall explains that high heterogeneity is the norm rather than the exception in prevalence/incidence pooling because true prevalence genuinely differs across settings — this reflects real variation, not necessarily model failure.

### Q165 [Medium] [MCQ]
**Chapter(s):** 11 — Meta-Analysis
**Question:** What does NICE DSU TSD 1 (Dias et al., 2011), referenced in §11.1, state about the choice between fixed-effect and random-effects models?
- A) A fixed-effect model should be the default unless random effects are statistically significant
- B) A fixed-effect model should only be used when there is a specific, justified reason to believe all studies share a single true effect, which must be stated explicitly
- C) Random-effects models are prohibited in HTA submissions
- D) The choice should be made after inspecting which model gives a narrower confidence interval
**Answer:** B
**Explanation:** The agency-note in §11.1 states TSD 1 takes the random-effects-as-default position, requiring explicit justification whenever a fixed-effect model is used instead.

## Chapter 12: Indirect Treatment Comparisons and Network Meta-Analysis

### Q166 [Easy] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** Why is a "naive" indirect comparison (comparing absolute outcomes from two unrelated trials directly) considered invalid?
- A) It requires a Bayesian framework that most software cannot run
- B) It destroys randomisation protection and is highly vulnerable to confounding by differences in baseline risk, trial era, region, and outcome definition between the two trials
- C) It can only be used for continuous outcomes, not binary ones
- D) It always produces narrower confidence intervals than anchored comparisons
**Answer:** B
**Explanation:** §12.1's pitfall states naive indirect comparison destroys randomisation and is vulnerable to confounding from differing baseline risk, era, region and outcome definitions, and is explicitly flagged as invalid by NICE DSU TSD 2.

### Q167 [Easy] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** In the Bucher method, if trial 1 gives an A-vs-C estimate and trial 2 gives a B-vs-C estimate, how is the indirect A-vs-B estimate calculated?
- A) By multiplying the two hazard ratios
- B) By subtracting the B-vs-C estimate from the A-vs-C estimate on the treatment-effect scale
- C) By averaging the two estimates
- D) By taking the geometric mean of the two confidence intervals
**Answer:** B
**Explanation:** §12.2 gives the Bucher formula d̂(AB) = d̂(AC) − d̂(BC): if A is better than C by d̂(AC) and B is better than C by d̂(BC), then A is better than B by their difference.

### Q168 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** In the Bucher method, how is the variance of the indirect A-vs-B estimate calculated from the two independent trial variances?
- A) Var(AB) = Var(AC) − Var(BC)
- B) Var(AB) = Var(AC) + Var(BC)
- C) Var(AB) = Var(AC) × Var(BC)
- D) Var(AB) = max(Var(AC), Var(BC))
**Answer:** B
**Explanation:** §12.2.2 explains the variances add, not subtract, because the two trials are statistically independent; Var(X−Y) = Var(X) + Var(Y) for independent variables, since the minus sign affects the expectation but not the variance.

### Q169 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What is the "similarity" or "transitivity" assumption that the Bucher method relies on?
- A) That all trials must use the exact same sample size
- B) That trial 1 and trial 2 must be similar enough in all effect modifiers that their respective C arms can be treated as exchangeable
- C) That the outcome must be measured on a log scale
- D) That both trials must have been published in the same year
**Answer:** B
**Explanation:** §12.2.4 defines transitivity as requiring the two trials be similar enough in everything that could modify the relative treatment effect, so the C arm in trial 1 can be treated as exchangeable with the C arm in trial 2.

### Q170 [Easy] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What format does `netmeta()` expect its input data to be in?
- A) Arm-based, one row per treatment arm
- B) Contrast-based, one row per treatment comparison per study
- C) Wide format, one column per study
- D) Raw patient-level individual data only
**Answer:** B
**Explanation:** §12.3.2 states `netmeta()` expects contrast-based data (one row per comparison per study), and the companion function `pairwise()` converts arm-level extractions into this format.

### Q171 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What does the `reference.group` argument in `netmeta()` control?
- A) Which treatment's data is excluded from the analysis
- B) Which treatment all relative effects in the summary output are reported against
- C) Whether the model is fixed-effect or random-effects
- D) The summary measure used (OR, RR, HR)
**Answer:** B
**Explanation:** §12.3.3 explains `reference.group` fixes which treatment all relative effects are reported against, so setting it to the standard-of-care makes the output read naturally as "each regimen vs standard of care."

### Q172 [Hard] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** Why do most Bayesian NMA packages (`gemtc`, `multinma`) require at least 4 MCMC chains, per the convergence pitfall in §12.4?
- A) Four chains is a regulatory requirement under NICE DSU TSD 2
- B) A Rhat near 1.00 only shows chains have mixed with each other, not that the full posterior has been explored; dispersed starting values in multiple chains guard against chains converging together on similarly wrong values
- C) Fewer than 4 chains cannot be run in JAGS
- D) Four chains are needed to compute SUCRA values
**Answer:** B
**Explanation:** The pitfall warns Rhat near 1.00 is not a complete convergence check, particularly for the heterogeneity parameter τ, and that running multiple chains from dispersed starting values is the standard safeguard against chains getting "stuck at similar but wrong values together."

### Q173 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What is the key practical difference that lets `multinma` combine evidence that `gemtc` typically cannot in the same network?
- A) `multinma` can use JAGS while `gemtc` cannot
- B) `multinma` accepts individual patient data (IPD), aggregate data (AgD), or a mixture of both within the same network
- C) `multinma` does not require any prior specification
- D) `multinma` only supports binary outcomes
**Answer:** B
**Explanation:** §12.4 states `multinma`'s main practical advantage over `gemtc` is accepting IPD, AgD, or a mixture within the same network, relevant when a submission combines a trial with patient-level access and comparator trials known only from aggregate results.

### Q174 [Hard] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What is the essential difference between node-splitting and the design-by-treatment interaction test for assessing network consistency (§12.5)?
- A) Node-splitting is global across the whole network, while design-by-treatment interaction tests only one edge at a time
- B) Node-splitting tests one specific comparison at a time for direct-vs-indirect agreement, while design-by-treatment interaction is a global test across the whole network's design structure
- C) They are mathematically identical tests implemented in different packages
- D) Node-splitting can only be run in `netmeta`, and design-by-treatment interaction only in `gemtc`
**Answer:** B
**Explanation:** §12.5 describes node-splitting as a local method examining one edge at a time, while design-by-treatment interaction testing is the standard global method testing consistency across the whole network simultaneously — they are complementary, not competing.

### Q175 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** According to the pitfall in §12.5, what does a non-significant node-split p-value on every edge of a network fail to guarantee?
- A) That the network has enough studies to compute I²
- B) That the network is free of inconsistency, since node-splitting can miss patterns of inconsistency spread diffusely across the network rather than concentrated on one comparison
- C) That the common-effect model is preferred over random-effects
- D) That SUCRA values can be validly computed
**Answer:** B
**Explanation:** The pitfall explicitly warns that a node-split p-value comfortably above 0.05 on every edge does not mean the network is free of inconsistency, because diffuse inconsistency spread across the network is exactly what the global design-by-treatment test is built to catch.

### Q176 [Hard] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** Per §12.7, why is a constant (proportional-hazards) hazard ratio often the wrong assumption for an oncology survival network?
- A) Oncology trials never report hazard ratios
- B) Immunotherapies and targeted agents commonly show hazard ratios that are far from 1 early on and move toward 1 or cross over late, violating a constant-HR assumption
- C) The flexsurv package cannot fit hazard ratios for oncology data
- D) NICE DSU TSD 18 prohibits the use of hazard ratios in networks
**Answer:** B
**Explanation:** The chapter explains that hazard ratios in oncology trials are frequently far from 1 early (while treatment effect is building or early toxicity dominates) and move toward 1 or cross over late, which the proportional-hazards NMA's constant-HR assumption cannot represent.

### Q177 [Hard] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What does the chapter's pitfall in §12.7 state about implementing the full Jansen (2011) / TSD 18 fractional polynomial NMA of survival curves in R?
- A) It is fully implemented as a single function in the `flexsurv` package
- B) There is no widely adopted, actively maintained CRAN package implementing the full method end-to-end; it is genuinely bespoke analysis typically built in a Bayesian framework (WinBUGS/JAGS/Stan)
- C) It is implemented identically in both `gemtc` and `netmeta`
- D) It requires no Bayesian modelling at all, only `flexsurvspline()`
**Answer:** B
**Explanation:** The pitfall explicitly states there is no widely adopted CRAN package implementing the full multi-arm, multi-study fractional polynomial NMA end-to-end, and that any code presenting a single named function as doing this whole job should be treated with suspicion.

### Q178 [Medium] [MCQ]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What is SUCRA, as introduced in §12.8?
- A) A test statistic for publication bias in networks
- B) A single number between 0 and 1 summarising the full distribution of a treatment's rank across MCMC iterations, with 1 meaning certain to be best
- C) A measure of between-study heterogeneity specific to Bayesian NMA
- D) The Bayesian equivalent of Egger's test
**Answer:** B
**Explanation:** §12.8 defines SUCRA (Surface Under the Cumulative RAnking curve) as a single number between 0 and 1 summarising each treatment's rank distribution from the MCMC sample, where 1 means certain to be best and 0 certain to be worst.

### Q179 [Medium] [Image]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** IMAGE PLACEHOLDER: a network geometry diagram from `netgraph()` showing four treatment nodes (A, B, C, D) connected by edges of varying thickness proportional to the number of studies, with C sitting at the network's hub, as in the §12.3.4 figure. What question does inspecting this network geometry answer that a numerical summary table does not?
- A) The exact pooled odds ratio for every pairwise comparison
- B) Whether the network is a simple star, a connected loop allowing consistency checks, or contains a treatment connected only through one thin edge — and whether every treatment of interest is even connected to the network at all
- C) The exact value of τ² for the random-effects model
- D) The DIC value comparing fixed vs random effects models
**Answer:** B
**Explanation:** §12.3.4 states that reviewing the network geometry reveals whether the structure is a simple star, a connected loop, or has a thinly-connected treatment, and makes visible whether every treatment of interest is even connected to the network through shared comparators at all.

### Q180 [Hard] [Image]
**Chapter(s):** 12 — Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** IMAGE PLACEHOLDER: a rankogram showing stacked probability bars for four treatments (A, B, C, D) across possible rank positions (1=best to 4=worst), derived from 10,000 simulated draws of a fitted `netmeta` random-effects model, as in the §12.8 figure. What critical caveat does the chapter's pitfall attach to interpreting a treatment's high SUCRA or P-score shown by such a rankogram?
- A) Rankograms cannot be produced for frequentist NMA models
- B) A treatment can carry the top rank while its credible/confidence interval overlaps substantially with lower-ranked treatments, meaning the ranking should never be presented without the underlying effect estimates and their uncertainty
- C) Rankograms are only valid when all comparisons in the network are direct, not indirect
- D) SUCRA and P-score always disagree with each other in the same network
**Answer:** B
**Explanation:** §12.8's pitfall explicitly warns that a high rank with a wide, overlapping interval usually reflects a thinly-evidenced comparison rather than a clinically meaningful difference, and a ranking metric should never be presented without the accompanying forest-plot or league-table uncertainty.

## Chapter 13: Population-Adjusted Indirect Comparisons

### Q181 [Easy] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** In the context of population-adjusted indirect comparisons, what distinguishes an "effect modifier" from a "prognostic factor"?
- A) A prognostic factor changes the relative treatment effect; an effect modifier shifts outcomes equally in both arms
- B) An effect modifier changes the relative treatment effect itself; a prognostic factor predicts outcome risk regardless of treatment, shifting both arms similarly
- C) There is no meaningful distinction; both terms describe the same statistical phenomenon
- D) A prognostic factor only matters in unanchored comparisons, while an effect modifier only matters in anchored comparisons
**Answer:** B
**Explanation:** The chapter defines a prognostic factor as one that shifts outcomes up or down similarly in both arms, while an effect modifier changes the treatment effect itself depending on the covariate's value (§13.1).

### Q182 [Medium] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** Why does imbalance in a pure prognostic factor NOT bias an anchored indirect comparison, while imbalance in an effect modifier does?
- A) Prognostic imbalance is always smaller in magnitude than effect-modifier imbalance
- B) Prognostic effects are differenced away on each side of the common comparator anchor before the two relative effects are compared, whereas effect-modifier imbalance means the two trials' relative effects estimate different quantities
- C) Prognostic factors cannot be measured in AgD trials, so they are irrelevant by definition
- D) Anchored comparisons never use any patient-level covariate information
**Answer:** B
**Explanation:** Per §13.1, within-trial contrasts cancel prognostic effects at the anchor, but effect-modifier imbalance means the two trials are not estimating the same relative-effect quantity, so the indirect comparison is biased.

### Q183 [Medium] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** How does MAIC's method-of-moments weighting mechanism determine the odds-weight $w_i = exp(z_i^T alpha)$ for each IPD patient?
- A) $\alpha$ is fit by maximum likelihood on the AgD trial's individual patient outcomes
- B) $\alpha$ is chosen so the weighted IPD sample's covariate means exactly equal the AgD trial's reported means
- C) $\alpha$ is set equal to the AgD trial's published hazard ratio
- D) $\alpha$ is estimated by a Cox model fit separately in each trial
**Answer:** B
**Explanation:** Per §13.2, $\alpha$ solves a convex method-of-moments problem so that the weighted IPD covariate means match the AgD trial's reported moments — no AgD individual patient data or outcomes are ever used.

### Q184 [Easy] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** What does the effective sample size (ESS) formula $\mathrm{ESS} = (\sum_i w_i)^2 / \sum_i w_i^2$ tell an analyst?
- A) The number of covariates successfully matched between trials
- B) How many unweighted patients would give the same amount of statistical information as the weighted sample
- C) The number of patients excluded from the IPD trial after matching
- D) The statistical power of the weighted Cox model
**Answer:** B
**Explanation:** §13.2 defines ESS as answering "how many unweighted patients would give this much statistical information," and a large drop from the original N signals that a few extreme weights dominate the estimate.

### Q185 [Medium] [Image]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** IMAGE PLACEHOLDER: a love plot showing absolute standardized mean differences (SMDs) between the IPD trial and the AgD trial's reported target, before (red) and after (green) MAIC odds-weighting, as in Figure @fig-ch13-maic-love-plot of §13.2. Based on the chapter's description of this figure, what should the SMD for every *matched* covariate equal after weighting?
- A) Approximately 0.5, representing moderate residual imbalance
- B) Exactly zero, by construction of the method-of-moments calibration
- C) A value depending on the covariate's correlation with the outcome
- D) It cannot be determined without knowing the ESS
**Answer:** B
**Explanation:** The chapter states that MAIC drives every *matched* covariate's SMD to exactly zero by construction; the real diagnostic concern is whether any *unmatched* effect modifier remains imbalanced.

### Q186 [Medium] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** An IPD trial starts with N = 400 patients. After MAIC weighting on two effect modifiers, the ESS is calculated as 120. What does this specific result imply, per the chapter's worked example?
- A) The MAIC weighting failed and must be re-estimated
- B) Roughly 70% of the effective statistical information was lost, likely because a handful of extreme weights dominate the result, widening the confidence interval beyond what N=400 would suggest
- C) The AgD trial's reported means were incorrect
- D) The weighted Cox model cannot be fit with this ESS
**Answer:** B
**Explanation:** §13.2's worked example explicitly states that ESS=120 from N=400 means roughly 70% of effective information was thrown away, flagging that a small number of extreme weights are carrying the estimate and that the CI will be wider than the nominal N suggests.

### Q187 [Easy] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** How does MAIC extend its reweighting logic to time-to-event (survival) outcomes?
- A) It requires an entirely new estimation framework distinct from the odds-weight calculation
- B) The same odds-weights $w_i$ are used as case weights in a weighted Kaplan–Meier curve and a weighted Cox model
- C) It converts survival times into binary outcomes before weighting
- D) It discards all weighting and refits an unweighted Cox model on the matched subset only
**Answer:** B
**Explanation:** Per §13.2, "MAIC's reweighting logic extends directly to survival outcomes by using the odds-weights $w_i$ as case weights in a weighted Kaplan–Meier curve and a weighted Cox model — no new estimation machinery is needed."

### Q188 [Hard] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** Why does the chapter recommend robust (sandwich-type) standard errors, rather than the naive weighted-Cox standard errors, when reporting a MAIC-weighted Cox model?
- A) Robust SEs are always smaller and make the result look more precise
- B) The weights themselves are estimated quantities with their own uncertainty, and ordinary Cox variance formulas do not account for that extra uncertainty, which would make the reported CI artificially narrow
- C) Robust SEs are required whenever the outcome is binary rather than time-to-event
- D) The `coxph()` function cannot compute naive standard errors when weights are supplied
**Answer:** B
**Explanation:** §13.2 explains that because the MAIC weights were themselves estimated in the matching step, naive Cox SEs ignore that added uncertainty, making the CI look falsely precise; `cluster()` or a full bootstrap over the weighting-plus-outcome pipeline are the standard fixes.

### Q189 [Easy] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** What is the fundamental mechanistic difference between MAIC and STC in how they address effect-modifier imbalance between an IPD trial and an AgD trial?
- A) MAIC reweights IPD patients to match the AgD trial's covariate moments; STC fits an outcome regression on the IPD trial and predicts the outcome at the AgD trial's reported covariate means
- B) MAIC and STC are mathematically identical procedures with different names
- C) MAIC requires AgD patient-level data; STC does not
- D) STC always requires fewer covariates than MAIC
**Answer:** A
**Explanation:** Per §13.3, "Where MAIC asks 'how do I reweight my patients to look like theirs?', STC asks 'what does my outcome model say would happen to a population with their average characteristics?'"

### Q190 [Hard] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** The chapter's worked simulation shows a treatment with a true, constant log-odds effect of 0.7 (true OR ≈ 2.0) across mild and severe-disease subgroups, with no real effect modification. Fitting a logistic regression recovers a conditional OR of about 1.98, but averaging predicted probabilities across the population and converting to an odds ratio gives a marginal OR of about 1.82. What does this gap illustrate?
- A) The logistic model was misspecified and needs a treatment-by-severity interaction term
- B) Non-collapsibility: conditional and marginal effects differ on the odds-ratio/hazard-ratio scale even when the model is perfectly specified, because odds ratios do not average the way risk differences do
- C) A coding error in the simulation that would disappear with a larger sample size
- D) Evidence that severity is a genuine effect modifier that must be included in the matching set
**Answer:** B
**Explanation:** §13.3 explicitly uses this simulation to demonstrate non-collapsibility: "Nothing is wrong with the model; odds ratios themselves simply don't average the way risk differences do" — this is why STC must simulate across the full covariate distribution rather than plug in means.

### Q191 [Medium] [Image]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** IMAGE PLACEHOLDER: a histogram of MAIC odds-weights for a 400-patient IPD trial matched on baseline ECOG status and prior-therapy count, as described in the §13.2 worked example, showing roughly 15 patients at the extreme ends of the covariate distribution receiving weights 8–12 times the mean weight while most patients are weighted near zero. What statistical consequence does this weight distribution most directly produce?
- A) A reduction in bias with no effect on precision
- B) An ESS substantially lower than the raw IPD sample size (illustratively ≈120 out of 400), because a small number of extreme weights dominate the weighted estimate
- C) An automatic violation of the proportional hazards assumption
- D) A requirement to switch from MAIC to ML-NMR
**Answer:** B
**Explanation:** The chapter's heor-practice box uses exactly this extreme-weight pattern to produce the illustrative ESS of 120 from N=400, explicitly linking a small number of highly weighted patients to large information loss (§13.2).

### Q192 [Medium] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** Why can't MAIC or STC be directly extended when a network contains three or more treatments with a mix of IPD and AgD-only trials?
- A) Both methods already handle arbitrary network sizes without modification
- B) Both operate structurally on exactly two trials (one IPD, one AgD) connected by a single comparison, so extending them to a network would require a separate MAIC/STC per AgD trial, losing internal consistency and a single coherent ranking
- C) AgD trials cannot be included in any network meta-analysis
- D) IPD trials are incompatible with Bayesian network meta-analysis software
**Answer:** B
**Explanation:** §13.4 states that MAIC and STC "share a structural limitation: both operate on exactly two trials... connected by a single comparison," and running separate pairwise analyses would throw away network internal consistency — the gap ML-NMR closes.

### Q193 [Hard] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** What is the role of `multinma::add_integration()` and Sobol' sequences in ML-NMR?
- A) They replace the need for any IPD trials in the network
- B) They generate structured (not purely random) sample points via a Gaussian copula from each AgD trial's reported covariate means, SDs, and correlations, so the individual-level model's predictions can be numerically integrated over that trial's covariate distribution rather than evaluated at a single mean
- C) They compute the R-hat convergence diagnostic for the ML-NMR model
- D) They convert AgD trials into IPD trials automatically
- **Answer:** B
**Explanation:** §13.4 explains that `add_integration()` builds Quasi-Monte Carlo integration points via a Gaussian copula and Sobol' sequences from each AgD study's covariate distribution, enabling numerical integration rather than STC's single-mean plug-in.

### Q194 [Medium] [MCQ]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** According to NICE DSU TSD 18, what is the stated rough method preference ordering among MAIC, STC, and ML-NMR, data permitting?
- A) MAIC > STC > ML-NMR, because MAIC is simplest to implement
- B) STC > MAIC > ML-NMR
- C) ML-NMR > STC > MAIC, because ML-NMR preserves network internal consistency and uses the full covariate distribution, while MAIC discards information via reweighting
- D) All three methods are considered equally preferable by TSD 18
**Answer:** C
**Explanation:** §13.5's agency-note states TSD 18's ordering is "roughly, ML-NMR > STC > MAIC," explicitly warning against choosing MAIC merely because it is simplest to implement.

### Q195 [Hard] [Image]
**Chapter(s):** 13 (Population-Adjusted Indirect Comparisons)
**Question:** IMAGE PLACEHOLDER: a schematic diagram/table comparing MAIC, STC, and ML-NMR across three dimensions — data requirement, key assumption, and typical use case — as summarized in the comparison table of §13.4. Which statement correctly characterizes the key assumption distinguishing MAIC from STC in this comparison?
- A) MAIC's validity rests on the weighting/matching model being correctly specified; STC's validity rests on the outcome regression model being correctly specified
- B) Both methods share an identical key assumption about outcome functional form
- C) MAIC assumes no effect modifiers exist; STC assumes all covariates are prognostic
- D) STC requires AgD trial covariate correlations; MAIC does not use AgD data at all
**Answer:** A
**Explanation:** The method-comparison table (tab-ch13-method-comparison) lists MAIC's key assumption as correct specification of the weighting/matching model including all relevant effect modifiers, and STC's as correct specification of the outcome regression model, including functional form and treatment-by-covariate interactions.

## Chapter 14: Bayesian Methods for HEOR

### Q196 [Easy] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** In the Bayesian framework introduced in §14.1, how does the posterior $p(\theta|y)$ relate to the prior $\pi(\theta)$ and likelihood $L(\theta|y)$?
- A) Posterior = Prior minus Likelihood
- B) Posterior is proportional to Likelihood times Prior
- C) Posterior equals the Prior whenever the sample size is large
- D) Posterior and Likelihood are mathematically identical concepts
**Answer:** B
**Explanation:** §14.1 states the core relationship analysts use day to day: "posterior ∝ likelihood × prior," with the denominator of Bayes' theorem simply rescaling the product to integrate to one.

### Q197 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** How does a Bayesian 95% credible interval differ in interpretation from a frequentist 95% confidence interval, per §14.1?
- A) They are identical in interpretation; only the computation method differs
- B) A credible interval is a direct probability statement that, given the data and prior, there is a 95% probability θ lies in the interval; a confidence interval is a statement about the long-run behavior of the estimation procedure
- C) A confidence interval is always narrower than a credible interval
- D) Credible intervals cannot be computed for continuous parameters
**Answer:** B
**Explanation:** The chapter contrasts the two directly: the frequentist CI describes repeated-sampling long-run coverage of a procedure, while the Bayesian credible interval is a direct probability statement about θ itself given the observed data and prior.

### Q198 [Easy] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** The chapter's TB treatment-success example uses an informative prior of Beta(150, 42). What is the source and interpretation of this prior, per §14.2?
- A) It is an arbitrary default with no clinical basis, chosen purely for mathematical convenience
- B) It encodes findings from a prior national TB survey (78% success), treated as 192 "pseudo-observations" carried forward rather than discarded
- C) It represents a completely flat, non-informative belief about treatment success
- D) It was derived directly from the new cohort's own observed data
**Answer:** B
**Explanation:** §14.2 explains that Beta(150,42) comes from a prior national TB survey finding 78% success, and using it as a prior "is not cheating — it is using the discipline's accumulated evidence," representing 192 pseudo-observations.

### Q199 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** A weakly informative Normal(0, 2.5) prior is placed on a log hazard ratio. What does this prior actually express, per §14.2?
- A) Strong certainty that the hazard ratio equals exactly 1
- B) That hazard ratios roughly between 0.007 and 150 are conceivable, ruling out numerically absurd values without favoring any particular plausible value
- C) Complete prior ignorance equivalent to a flat uniform prior on an unbounded scale
- D) That the hazard ratio must lie strictly between 0.5 and 2.0
**Answer:** B
**Explanation:** §14.2 states this prior "says hazard ratios somewhere between roughly 0.007 and 150 are conceivable, but a hazard ratio of a trillion is not," keeping the sampler well-behaved without pulling toward a specific value.

### Q200 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** Using the Beta-Binomial conjugate update in §14.2 with prior Beta(150, 42), and a new cohort of n=40 patients with y=34 successes, what is the resulting posterior distribution?
- A) Beta(34, 6)
- B) Beta(184, 48)
- C) Beta(150, 82)
- D) Beta(40, 34)
**Answer:** B
**Explanation:** The conjugate Beta-Binomial update gives $\alpha_\text{post} = \alpha_\text{prior} + y = 150+34=184$ and $\beta_\text{post} = \beta_\text{prior} + (n-y) = 42+6=48$, exactly as computed in §14.2's worked example.

### Q201 [Hard] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** Why does the chapter caution against reflexively choosing a "flat" or improper prior just to appear neutral, using the example of a Uniform(0,1000) prior on an odds ratio?
- A) Flat priors are computationally impossible to implement in Stan or JAGS
- B) A prior that is flat on one scale can be highly informative — and in a distorting way — on a transformed scale; a Uniform(0,1000) prior on an OR puts almost all its mass above an OR of 10, which is rarely a neutral starting point
- C) Flat priors always produce a biased posterior mean regardless of sample size
- D) Flat priors are only appropriate for binary outcomes, never continuous ones
**Answer:** B
**Explanation:** §14.2's pitfall box makes exactly this point: a seemingly neutral flat prior on an odds-ratio scale concentrates almost all its mass above OR=10, which is a strong and distorting assumption in practice.

### Q202 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** How does Hamiltonian Monte Carlo (HMC) improve on basic Metropolis-Hastings sampling, per §14.3?
- A) HMC eliminates the need for a prior distribution entirely
- B) HMC uses the gradient of the negative log-posterior to steer proposals toward high-density regions (like a particle rolling across an energy surface), enabling big, informed steps even in high dimensions, rather than wandering via small random proposals
- C) HMC only works for discrete parameters, unlike Metropolis-Hastings
- D) HMC always converges in exactly one iteration
**Answer:** B
**Explanation:** §14.3 describes HMC as treating the negative log-posterior as an energy surface and using its gradient to steer proposals, producing "big, informed steps even in high dimensions" versus Metropolis-Hastings' slow random perturbations.

### Q203 [Easy] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** What R-hat (Gelman-Rubin statistic) threshold does the chapter describe as the "traditional acceptable" value, versus the more conservative threshold increasingly expected by methodologically careful reviewers?
- A) Traditional: R-hat < 2.0; conservative: R-hat < 1.5
- B) Traditional: R-hat < 1.05; conservative: R-hat < 1.01
- C) Traditional: R-hat < 1.01; conservative: R-hat < 1.05
- D) There is no standard threshold; it depends entirely on the model
**Answer:** B
**Explanation:** §14.4 states "R-hat < 1.05 is the traditional 'acceptable' threshold... R-hat < 1.01 is the more conservative threshold recommended by newer Stan-ecosystem guidance."

### Q204 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** R-hat and effective sample size (ESS) are reported together in MCMC diagnostics. What distinct question does each answer, per §14.4?
- A) They answer the identical question and are reported together only for redundancy
- B) R-hat asks "have my chains converged to the same place?"; ESS asks "once converged, how much information do I actually have about this parameter?"
- C) R-hat measures model fit; ESS measures prior informativeness
- D) ESS is only relevant for JAGS models, while R-hat is only relevant for Stan models
**Answer:** B
**Explanation:** The chapter states explicitly that you "can have excellent R-hat with dismal ESS if chains converge quickly to the right region but then mix very slowly within it" — a common pattern for variance components in hierarchical NMA models.

### Q205 [Hard] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** What causes "divergent transitions" in Stan's HMC/NUTS sampler when fitting a hierarchical model with a funnel-shaped posterior (Neal's funnel), and what is the standard fix?
- A) Divergences are caused by too few MCMC chains; the fix is to run more chains
- B) The step size that works in the funnel's wide region is too large for its narrow neck, causing the sampler to "crash into the walls"; the standard fix is a non-centered parameterisation that expresses individual deviations as independent unit-scaled quantities multiplied by the variance parameter afterward
- C) Divergences only occur with vague priors and are fixed by switching to JAGS
- D) Divergences indicate the likelihood function was misspecified and cannot be fixed by reparameterisation
**Answer:** B
**Explanation:** §14.4's difficult-terminology box on Neal's funnel explains that a single step size cannot navigate both the funnel's wide and narrow regions, and that non-centered parameterisation "straightens the funnel out into geometry the sampler can explore efficiently."

### Q206 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** What is the purpose of a posterior predictive check (PPC), as distinct from a convergence diagnostic like R-hat?
- A) PPCs check whether the sampler worked; convergence diagnostics check whether the model is a good description of the data
- B) PPCs simulate new data from the fitted model's posterior and compare it to observed data to assess whether the model is a reasonable description of the data-generating process; convergence diagnostics only check whether the sampler worked
- C) PPCs and convergence diagnostics are interchangeable and test the same thing
- D) PPCs are only applicable to Bayesian network meta-analysis models, not simpler Bayesian regressions
**Answer:** B
**Explanation:** §14.4 states plainly: "Convergence diagnostics tell you whether your sampler worked. They say nothing about whether your model is any good. For that you need posterior predictive checks."

### Q207 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** Per §14.5–14.6, why can a Bayesian posterior sample be used directly as a PSA sample, with "no extra distribution-fitting step in between"?
- A) Because posterior draws are always normally distributed by the Central Limit Theorem
- B) Because each MCMC draw is already a complete, internally consistent joint sample across every parameter, preserving correlations that a separately-fitted distribution (e.g., refitting a normal to the posterior mean and SD) would discard
- C) Because PSA requires independent parameter draws, which posterior samples automatically provide
- D) Because Bayesian models never require probabilistic sensitivity analysis
**Answer:** B
**Explanation:** The chapter emphasizes that re-fitting a distribution to posterior summary statistics "throws away exactly the correlation structure that made the Bayesian synthesis worth doing" (§14.5), so the raw posterior draws are used as the PSA sample directly.

### Q208 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** In a SHELF (Sheffield Elicitation Framework) exercise, what is the key distinction between "the facilitator" and "the experts," per §14.7?
- A) The facilitator holds the relevant clinical/domain knowledge, while experts run the elicitation session
- B) The facilitator is a trained elicitation specialist with no personal stake in the parameter's value who runs the session without offering their own opinion; the experts are the substantive content specialists who hold domain knowledge but typically lack training in thinking probabilistically
- C) There is no meaningful distinction; both roles are performed by the same person in SHELF
- D) The facilitator always outranks the experts and makes the final numeric judgment alone
**Answer:** B
**Explanation:** §14.7 explicitly separates these roles: the facilitator counteracts cognitive biases and never offers their own opinion of the "right" answer, while experts hold the clinical knowledge but need help translating intuition into probabilistic quantiles.

### Q209 [Hard] [Image]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** IMAGE PLACEHOLDER: a `bayesplot::mcmc_trace()` plot showing 4 overlapping chains for parameters theta on the natural and logit scale, described in §14.4 as a "fat hairy caterpillar." What visual pattern indicates a healthy, well-mixed chain in this type of plot?
- A) Four bands that are clearly separated from one another with no overlap
- B) Four overlapping bands with no trend, no chain visibly separated from the others, and no long flat stretches where the sampler got stuck
- C) A single smooth, declining line with no fluctuation
- D) Bands that narrow progressively toward zero width over time
**Answer:** B
**Explanation:** The chapter describes a healthy trace plot as looking like "a 'fat hairy caterpillar' — four overlapping bands with no trend, no chain visibly separated from the others, and no long flat stretches where the sampler got stuck" (§14.4).

### Q210 [Medium] [Image]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** IMAGE PLACEHOLDER: a `bayesplot::ppc_dens_overlay()` plot comparing an observed outcome density to 50 posterior-predictive replicate densities, as in Figure @fig-ch14-ppc-dens-overlay of §14.4. What pattern in this figure would indicate the model fits well?
- A) Replicated curves showing a completely different mode than the observed data
- B) A tight bundle of replicated curves hugging the observed curve
- C) Replicated curves spread uniformly across the entire possible outcome range
- D) Exactly one replicated curve matching the observed data perfectly while all others diverge
**Answer:** B
**Explanation:** §14.4 states: "A model that fits well produces a tight bundle of replicated curves hugging the observed curve," while systematic misfit (wrong dispersion, skew, or mode) shows up as visibly diverging replicate curves.

### Q211 [Hard] [Image]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** IMAGE PLACEHOLDER: a `SHELF::plotfit()` figure overlaying fitted beta, normal, skew-normal, gamma, and log-normal distributions against three elicited quantiles (25th/50th/75th percentiles = 0.30/0.45/0.60) for a response-rate parameter, as in Figure @fig-ch14-shelf of §14.7. The normal/skew-normal families have the lowest least-squares (ssq) score, yet the chapter says the beta fit should be used instead. Why?
- A) The beta distribution always has the lowest ssq score mathematically
- B) The normal/skew-normal fits can assign positive density outside [0,1], which is nonsensical for a probability parameter; the beta fit respects the bounded support of the parameter being elicited despite its slightly higher ssq
- C) SHELF's software does not actually support fitting normal distributions
- D) The response rate parameter is not bounded, so any family is equally valid
**Answer:** B
**Explanation:** The figure caption explicitly states that although normal/skew-normal fits score lower ssq, they can assign density outside [0,1]; "the beta fit... is the one that should feed the prior, precisely because it respects the support of the parameter being elicited" (§14.7).

### Q212 [Medium] [MCQ]
**Chapter(s):** 14 (Bayesian Methods for HEOR)
**Question:** Why does the chapter caution against thinning or subsampling a posterior sample (e.g., taking every 10th draw) before passing it into a decision model, per §14.5?
- A) Thinning is computationally impossible in R
- B) Thinning is usually unnecessary and can quietly reduce the effective precision of PSA results, unless autocorrelation diagnostics specifically indicate thinning is needed for storage reasons
- C) Thinning always introduces bias into the posterior mean
- D) Thinning is required by NICE DSU TSD 18 for every Bayesian PSA
**Answer:** B
**Explanation:** §14.5's pitfall box states thinning "is usually unnecessary and can quietly reduce the effective precision of your PSA results," and recommends passing the full post-warm-up sample through unless thinning is driven by genuine storage or autocorrelation concerns.

## Chapter 15: Real-World Evidence (RWE) and Causal Inference

### Q213 [Easy] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** What two-part test does the FDA's 2023 RWD guidance use to assess whether a real-world data source is fit for a regulatory decision, per §15.1?
- A) Cost and availability
- B) Relevance (right population, exposure, outcome, follow-up) and reliability (accurate, complete, traceable, with transparent provenance)
- C) Sample size and statistical power
- D) Randomization and blinding
**Answer:** B
**Explanation:** §15.1 states the FDA framework asks whether data is "relevant to the clinical question... and... reliable (accurate, complete, traceable, with transparent provenance)" — the EMA's DARWIN EU asks the same two questions in different words.

### Q214 [Medium] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** In the target trial emulation (TTE) example in §15.2, why is `time_zero` set to `regimen_start` rather than `diagnosis_dt`?
- A) Because diagnosis dates are never recorded in programme registers
- B) Because setting time zero correctly, so eligibility, exposure assignment, and follow-up all begin simultaneously, avoids immortal time bias — the opposite choice would inflate apparent drug benefit by crediting treatment-free follow-up time to the treated group
- C) Because regimen_start is always earlier than diagnosis_dt
- D) Because TTE requires excluding all patients with any lead-in time
**Answer:** B
**Explanation:** The chapter's code comment states explicitly "time_zero = regimen_start # NOT diagnosis_dt -- avoids immortal time bias," and the lead_in_days column is described as the audit diagnostic for exactly this risk (§15.2).

### Q215 [Easy] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** Which observational study design is described in §15.2 as "efficient for rare outcomes" but "acutely sensitive to how controls are selected"?
- A) Cohort design
- B) Case-control design
- C) Target trial emulation
- D) Regression discontinuity
**Answer:** B
**Explanation:** §15.2 states that case-control designs are "efficient for rare outcomes... but acutely sensitive to how controls are selected — control selection that does not mirror the case-generating mechanism produces selection bias that no amount of post-hoc adjustment repairs."

### Q216 [Medium] [Image]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** IMAGE PLACEHOLDER: a DAG with nodes regimen, success, hiv, nutrition, site_capacity, and urban as in §15.3, showing arrows success ← regimen, hiv, nutrition, site_capacity; regimen ← hiv, site_capacity; nutrition ← regimen; site_capacity ← urban. Running `dagitty::adjustmentSets()` on this graph with exposure=regimen and outcome=success returns which minimal sufficient adjustment set, and why is `nutrition` excluded?
- A) {hiv, nutrition, site_capacity}; nutrition is included because it predicts the outcome
- B) {hiv, site_capacity}; nutrition is excluded because it is a mediator (caused by regimen) on the causal pathway, and adjusting for it would block part of the regimen's true causal effect
- C) {urban}; urban is the only true confounder in this DAG
- D) The empty set {}; no adjustment is needed because this is a randomized comparison
**Answer:** B
**Explanation:** §15.3 states that running `adjustmentSets()` on this exact DAG "returns {hiv, site_capacity} as the minimal sufficient set... nutrition is correctly excluded because it is a mediator, not a confounder."

### Q217 [Easy] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** How is the propensity score $e(x)$ formally defined in §15.4, and what did Rosenbaum and Rubin establish about it?
- A) $e(x) = P(Y=1|X=x)$; it is sufficient to predict the outcome without any covariates
- B) $e(x) = P(T=1|X=x)$; conditioning on it is sufficient to balance observed confounders between treated and untreated groups, provided no unmeasured confounding
- C) $e(x)$ is the expected cost of treatment given covariates x
- D) $e(x)$ is only defined for randomized trials, not observational data
**Answer:** B
**Explanation:** §15.4 defines the propensity score as $e(x) = P(T=1|X=x)$ and states Rosenbaum and Rubin's insight that conditioning on it, rather than the full covariate vector, is sufficient to balance observed confounders given the no-unmeasured-confounding assumption.

### Q218 [Hard] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** In the §15.4 toy IPTW example (6 patients, treated outcomes Y=10,8,12 with PS=0.5,0.4,0.6 and control outcomes Y=4,6,2 with the same PS values), what is the IPTW estimate of the average treatment effect (ATE)?
- A) 0.0 weeks (no difference)
- B) 6.167 weeks (weighted treated mean 10.000 minus weighted control mean 3.833)
- C) 10.0 weeks
- D) 20.0 weeks
**Answer:** B
**Explanation:** Summing treated contributions (20+20+20)/6 = 10.000 and control contributions (8+10+5)/6 = 3.833 gives $\hat\tau_\text{IPTW} = 10.000 - 3.833 = 6.167$ weeks, exactly as computed by hand in §15.4.

### Q219 [Medium] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** What makes an Augmented Inverse Probability Weighting (AIPW) estimator "doubly robust," per §15.5?
- A) It requires both the propensity model and the outcome model to be correctly specified simultaneously, or the estimate is invalid
- B) The estimate stays consistent if *either* the propensity model or the outcome model is correctly specified, not necessarily both — a meaningfully weaker assumption than either method alone requires
- C) It doubles the sample size by bootstrapping twice
- D) It is robust only to missing data, not to confounding
**Answer:** B
**Explanation:** §15.5 states that doubly robust estimators "combine both models so the estimate stays consistent if *either* the propensity model or the outcome model is correctly specified — not necessarily both."

### Q220 [Hard] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** Why were g-methods (g-computation, marginal structural models via IPTW, g-estimation of structural nested models) developed specifically, per §15.5?
- A) To replace propensity score matching entirely in all observational studies
- B) To handle time-varying treatment and time-varying confounding, where today's treatment affects tomorrow's confounder, which in turn affects tomorrow's treatment decision — a treatment-confounder feedback loop that standard regression adjustment cannot handle without bias
- C) To eliminate the need for a DAG before fitting any model
- D) To correct for measurement error in the outcome variable only
**Answer:** B
**Explanation:** §15.5 states g-methods "were developed by James Robins specifically to handle *time-varying treatment and time-varying confounding*... a 'treatment-confounder feedback' loop that standard regression adjustment cannot handle without introducing bias."

### Q221 [Medium] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** When using `ivreg::ivreg()` with `diagnostics = TRUE`, what conventional threshold on the first-stage F-statistic flags a "weak instrument," per §15.6?
- A) F-statistic below roughly 10
- B) F-statistic above 100
- C) F-statistic exactly equal to 1
- D) There is no numerical threshold; it is purely a qualitative judgment
**Answer:** A
**Explanation:** §15.6 states "A first-stage F-statistic below roughly 10 is the conventional (if debated) threshold for flagging a 'weak instrument,' below which 2SLS estimates become unreliable and badly biased toward the plain OLS estimate."

### Q222 [Medium] [Image]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** IMAGE PLACEHOLDER: an `rdrobust::rdplot()` scatter plot of culture conversion time against CD4 count, with a vertical line at the policy cutoff CD4=200, showing a visible downward jump in outcome just below the cutoff as in Figure @fig-ch15-rd-plot of §15.6. To what population does the estimated effect at this cutoff apply, and what check should accompany it?
- A) The effect applies to the entire CD4 range from 0 to 600 and requires no further checks
- B) The effect is local — identified only for patients near CD4=200 and should not be extrapolated to patients far from it — and should be accompanied by a manipulation/density check (e.g., via the `rddensity` package) to confirm patients could not manipulate which side of the cutoff they landed on
- C) The effect applies only to patients with CD4 exactly equal to 0
- D) No check is needed because RD designs are immune to confounding by definition
**Answer:** B
**Explanation:** §15.6's pitfall box states RD estimates are "local" and should never be extrapolated far from the cutoff, and recommends the `rddensity` manipulation check to rule out patients gaming which side of the cutoff they land on.

### Q223 [Hard] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** Why does the chapter recommend `did::att_gt()` over a naive two-way fixed effects (TWFE) regression for difference-in-differences when treatment adoption is staggered across districts, per §15.7?
- A) TWFE cannot be computed in R for panel data
- B) Naive TWFE regression implicitly compares already-treated districts against each other as pseudo-controls under staggered adoption, producing the well-documented "negative weighting" bias; `att_gt()` estimates separate group-time average treatment effects and avoids this
- C) `att_gt()` is simpler to code and produces identical results to TWFE in all cases
- D) TWFE is only invalid for continuous outcomes, not binary ones
**Answer:** B
**Explanation:** §15.7 explains that under staggered rollout, naive TWFE "implicitly compares already-treated districts against each other as pseudo-controls," a bias documented by Goodman-Bacon and others, which `att_gt()`'s group-time ATT approach avoids.

### Q224 [Medium] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** An observational comparison of two TB regimens finds an odds ratio of 2.10 (95% CI 1.40–3.20) for treatment success, with an E-value of 3.64 for the point estimate and 2.13 for the CI limit closest to the null. How should these E-values be interpreted, per §15.9?
- A) The finding is fragile; almost any unmeasured confounder could explain it away
- B) An unmeasured confounder would need a fairly strong, double-sided association (risk-ratio scale) with both exposure and outcome to fully explain away the result, even at the more conservative CI-limit value of 2.13 — a relatively robust finding compared to, e.g., an E-value near 1.5
- C) E-values of this size indicate the study must have been randomized
- D) The E-value here proves no unmeasured confounder exists
**Answer:** B
**Explanation:** §15.9 states an E-value of 1.5 signals a fragile finding while an E-value of 8 signals robustness; the chapter's own worked table flags findings with CI-limit E-values around 2 as "reasonably robust," distinct from the more sensitive culture-conversion HR with CI-limit E-value 1.53.

### Q225 [Medium] [MCQ]
**Chapter(s):** 15 (Real-World Evidence and Causal Inference)
**Question:** Per §15.8 and NICE DSU TSD 16, what determines whether RPSFTM or IPCW is the more defensible method for adjusting survival estimates in the presence of treatment switching?
- A) RPSFTM is always preferred regardless of why switching occurred
- B) IPCW is favoured when switching is driven by observed, measured time-varying covariates (since it can model and reweight on them); RPSFTM is favoured when it is not, because it is robust to time-dependent confounding by design but relies on a strong common-treatment-effect assumption
- C) Both methods are interchangeable and TSD 16 expresses no preference
- D) IPCW should always be used because it requires no assumptions about switching
**Answer:** B
**Explanation:** §15.8 states TSD 16 "recommends which to use depending on whether switching is driven by observed time-varying covariates (favour IPCW) or not (favour RPSFTM)," noting RPSFTM's robustness to unmeasured time-dependent confounding comes at the cost of a strong common-effect assumption, while IPCW requires the switch-driving covariates to actually be measured.
</content>

## Chapter 16: Regression Models for HEOR Data

### Q226 [Easy] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** In the generalised linear model (GLM) framework, what are the three ingredients that define a GLM?
- A) A sample size, a significance level, and a p-value
- B) A distribution from the exponential family, a linear predictor, and a link function
- C) A training set, a test set, and a validation set
- D) A fixed effect, a random effect, and an interaction term
**Answer:** B
**Explanation:** The chapter states a GLM has three ingredients: a distribution for the outcome from the exponential family, a linear predictor (η = β0 + β1x1 + ...), and a link function connecting the two (g(μ) = η).

### Q227 [Easy] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** Which family/link combination does the chapter recommend for binary outcomes like treatment success or mortality?
- A) Gamma family with a log link
- B) Poisson family with a log link
- C) Binomial family with a logit link
- D) Gaussian family with an identity link
**Answer:** C
**Explanation:** The chapter states binary outcomes use the binomial family with a logit link — logistic regression — because the logit link keeps predicted probabilities between 0 and 1.

### Q228 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** Why does the chapter recommend negative binomial regression as the "safer default in practice" over Poisson regression for TB programme count data?
- A) Negative binomial models are always faster to fit in R
- B) Poisson regression cannot handle a log link function
- C) TB programme count data is almost always overdispersed (variance exceeds the mean), violating Poisson's equal mean-variance assumption
- D) Negative binomial regression does not require the `glm()` function
**Answer:** C
**Explanation:** The text explains that count outcomes like hospitalisations are almost always overdispersed in real programme data, and Poisson's assumption that mean equals variance is routinely violated, making negative binomial the safer default.

### Q229 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** What is the single most common GLM reporting error the chapter warns against in its pitfall box?
- A) Forgetting to set `family = ` in `glm()`
- B) Reporting raw link-scale coefficients (e.g. log-odds) unchanged instead of exponentiating them
- C) Using `lme4` instead of `glm()`
- D) Fitting a Poisson model to continuous outcome data
**Answer:** B
**Explanation:** The pitfall box states that a GLM's raw coefficients live on the link scale (e.g. log-odds for logistic models), and reporting them unchanged means almost nothing to a stakeholder; coefficients must always be exponentiated before presenting results.

### Q230 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** In `lme4::glmer(success ~ regimen + age + (1 | clinic_id), family = binomial())`, what does the `(1 | clinic_id)` term represent?
- A) A fixed effect of clinic on the outcome
- B) A random intercept, giving each clinic its own baseline log-odds drawn from a shared normal distribution
- C) An interaction term between clinic and regimen
- D) A quantile regression term set to the median
- E) (not applicable)
**Answer:** B
**Explanation:** The chapter describes `(1 | clinic_id)` as the random intercept: one baseline log-odds per clinic drawn from a shared normal distribution, rather than a fixed-effect dummy per clinic.

### Q231 [Hard] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** What does the intraclass correlation coefficient (ICC) measure in a mixed-effects model, and what does an ICC near 0 imply?
- A) The correlation between two fixed-effect covariates; near 0 means multicollinearity is absent
- B) The proportion of total outcome variance attributable to the grouping factor (e.g. clinic); near 0 means clinics barely differ and a plain GLM would have been fine
- C) The strength of the treatment effect; near 0 means the drug has no effect
- D) The goodness-of-fit of the model; near 0 means a perfect fit
**Answer:** B
**Explanation:** The chapter defines ICC as the proportion of total outcome variance attributable to the grouping factor versus variance between patients within the same clinic, and states an ICC near 0 means clinics barely differ and a plain GLM would have been fine.

### Q232 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** Ignoring clustering and fitting a naive GLM to hierarchical data primarily causes which problem?
- A) Standard errors become too small, because clustered observations are treated as more independent than they are
- B) Coefficients become biased toward zero
- C) The model fails to converge
- D) Standard errors become too large, making true effects look non-significant
**Answer:** A
**Explanation:** The text states that ignoring clustering "specifically makes [standard errors] too small, because the model treats twenty patients from one clinic as twenty independent pieces of information when they're closer to a handful."

### Q233 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** What is the key conceptual difference between a zero-inflated model and a hurdle model for count data with excess zeros?
- A) Zero-inflated models mix two kinds of zeros (structural and sampling); hurdle models treat crossing from zero to any event as a separate mechanism from the counting process above one
- B) Hurdle models can only be fit with Poisson, zero-inflated models only with negative binomial
- C) There is no real difference; they are two names for the same model
- D) Zero-inflated models require continuous outcomes, hurdle models require binary outcomes
**Answer:** A
**Explanation:** The chapter explains that a zero-inflated model mixes "structural" zeros (could never have an event) with ordinary sampling zeros, while a hurdle model treats clearing the zero/any-event hurdle as a distinct first step before a truncated count model for how many events occur.

### Q234 [Hard] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** In the `pscl::zeroinfl()` formula `ae_count ~ arm + age | arm`, what does the right-hand side of the `|` model?
- A) The dispersion parameter theta
- B) The probability of being a structural zero
- C) The count of events among those who could never have one
- D) The confidence interval for the rate ratio
**Answer:** B
**Explanation:** The chapter states the formula has two parts separated by `|`: the left side models the count given membership in the "can have events" group, and the right side models the probability of being a structural zero.

### Q235 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** A capacity planner asks "what should we provision for the costly tail of length-of-stay?" Which R approach from the chapter directly answers this, and how?
- A) `glm.nb()`, by estimating an extra dispersion parameter
- B) `quantreg::rq()` with `tau = 0.9`, modelling the 90th percentile of the cost distribution directly
- C) `MASS::polr()`, by modelling ordered categories
- D) `grf::causal_forest()`, by estimating heterogeneous treatment effects
**Answer:** B
**Explanation:** The chapter explains that quantile regression via `quantreg::rq()` models a chosen percentile directly, and gives the example that a capacity planner asking about the costly tail wants the 90th or 95th percentile, achieved by setting `tau = 0.9`.

### Q236 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** What is the "proportional-odds assumption" underlying both `MASS::polr()` and `ordinal::clm()`?
- A) That every predictor must be binary
- B) That the sample size is large enough for asymptotic normality
- C) That the effect of each predictor is the same across every cut-point of the ordinal scale
- D) That residual deviance equals degrees of freedom
**Answer:** C
**Explanation:** The chapter defines the proportional-odds assumption as the effect of each predictor being the same across every cut-point of the ordinal scale, e.g. a treatment's effect moving "poor" to "fair" is assumed equal to its effect moving "good" to "excellent."

### Q237 [Hard] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** What distinguishes `grf::causal_forest()` from `randomForest::randomForest()` or `ranger::ranger()` as used in this chapter?
- A) Causal forests cannot use continuous covariates
- B) Random forests estimate individual-level treatment effects; causal forests only predict outcomes
- C) Causal forests are grown specifically to estimate individual-level treatment effects given covariates X, outcome Y, and treatment indicator W, whereas plain random forests just predict an outcome without estimating a treatment effect
- D) There is no meaningful difference between the two approaches
**Answer:** C
**Explanation:** The chapter states that `randomForest()`/`ranger()` predict an outcome and do not estimate a treatment effect, while `grf::causal_forest()` is tuned specifically to estimate individual-level treatment effects from X, Y, and W.

### Q238 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** In `glmnet::glmnet(x, y, alpha = , lambda = )`, what does setting `alpha = 1` versus `alpha = 0` correspond to?
- A) `alpha = 1` is ridge regression; `alpha = 0` is LASSO
- B) `alpha = 1` is LASSO, shrinking many coefficients exactly to zero; `alpha = 0` is ridge regression
- C) Both settings are identical and only affect computation speed
- D) `alpha = 1` fits a Poisson model; `alpha = 0` fits a Gaussian model
**Answer:** B
**Explanation:** The chapter states `alpha = 1` is the LASSO (shrinks many coefficients exactly to zero for automatic variable selection), `alpha = 0` is ridge regression, and values in between are the elastic net.

### Q239 [Medium] [MCQ]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** According to the chapter, what is the correct way to formally test for effect modification (a treatment effect that differs by subgroup)?
- A) Compare two separate within-subgroup p-values
- B) Fit an interaction term (e.g. `treatment * hiv_status`) in a single regression model
- C) Run a t-test comparing the two subgroup means
- D) Compute the ICC for the subgroup variable
**Answer:** B
**Explanation:** The chapter explicitly states that the formal test for effect modification is an interaction term in a regression model — not a pair of separate within-subgroup analyses — illustrated with `treatment * hiv_status`.

### Q240 [Hard] [Image]
**Chapter(s):** 16 (Regression Models for HEOR Data)
**Question:** IMAGE PLACEHOLDER: a histogram showing the distribution of per-patient estimated treatment effects (tau_hat) from `grf::causal_forest()`, bimodal with one cluster near zero and another around 0.25-0.3, with a solid red vertical line marking the single average effect, as described in §16.5's figure. What does the bimodal spread in this figure demonstrate?
- A) The causal forest model has failed to converge and should be refit
- B) Evidence of real heterogeneity of treatment effect — a single average effect (the red line) would mask that some patients benefit far more than others
- C) That the treatment has no effect on any patient
- D) That the sample size was too small to estimate tau_hat reliably
**Answer:** B
**Explanation:** The figure caption states the bimodal spread — one cluster near zero, another around 0.25-0.3 — is itself evidence of real heterogeneity, since a single average effect line would mask that some patients benefit far more than others.

## Chapter 17: Principles of Decision Modelling

### Q241 [Easy] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** What does the PICOTS framework add to the four core framing terms (population, comparators, perspective, time horizon) already introduced in Chapter 4?
- A) It replaces perspective and time horizon entirely with new terms
- B) It splits "comparators" into intervention vs. comparator and adds outcomes, timing, and setting as explicit fields
- C) It is used only for Markov models, not decision trees
- D) It is a statistical test for model fit
**Answer:** B
**Explanation:** The chapter describes PICOTS as extending PICO for economic evaluation, splitting "comparators" into intervention vs. comparator and adding outcomes, timing, and setting as explicit fields to the same four ideas from §4.6.

### Q242 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** In the TB regimen PICOTS example, why is "Timing" (follow-up to 12 months post-treatment-completion) explicitly distinguished from the model's "time horizon"?
- A) They are actually the same concept and the distinction is just terminology
- B) Timing describes the follow-up window of the evidence informing the model, while the time horizon is how far forward the model itself projects, which may need to extend well beyond 12 months
- C) Timing refers only to calendar dates, while time horizon refers only to discount rates
- D) Time horizon is always shorter than the evidence's follow-up timing
**Answer:** B
**Explanation:** The chapter explicitly notes that PICOTS "Timing" describes the evidence's follow-up window, while the time horizon is a separate modelling choice about how far forward the model projects, possibly well beyond 12 months to capture downstream relapse and retreatment costs.

### Q243 [Easy] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** What is the purpose of a "model concept document" per the chapter?
- A) To store the final R code for the model
- B) To let clinical and economic stakeholders sign off on the decision question before anyone invests time building the answer
- C) To replace the need for a PSA (probabilistic sensitivity analysis)
- D) To document only the discount rate used
**Answer:** B
**Explanation:** The chapter states the model concept document's purpose is to let stakeholders sign off on the question before anyone invests time building the answer, listing the decision problem, PICOTS elements, intended model type, data sources, and audience.

### Q244 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** Per the five questions in §17.2 for choosing a model type, which model type is favoured when "a patient's future risk depends on their individual history... in a way a cohort-level model cannot capture"?
- A) Decision tree
- B) Markov cohort model
- C) Partitioned survival model
- D) Individual-level (microsimulation) model
**Answer:** D
**Explanation:** The chapter's fourth question explicitly states that dependence on individual history (time already in a state, prior treatment lines, accumulated events) favours individual-level microsimulation modelling (Chapter 21).

### Q245 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** Applying the five model-type questions to the TB regimen example (on treatment, cured, failed, relapsed, retreatment, death states with cycling), which model type does the chapter conclude is the natural choice?
- A) Decision tree, because it's a one-off decision
- B) Partitioned survival model, because of oncology-style survival curves
- C) Markov cohort model, because the disease has discrete, recurring states that patients can cycle between
- D) Discrete event simulation, because of resource constraints
**Answer:** C
**Explanation:** The heor-practice box concludes that "Question 2 dominates" for the TB regimen example — discrete, clinically meaningful recurring states with cycling (failure leads back to retreatment) — making a Markov cohort model the natural choice, built in Chapter 19.

### Q246 [Hard] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** Which model type does the chapter identify as "the only model type in Part IV that routinely models resource constraints explicitly"?
- A) Decision tree
- B) Markov cohort model
- C) Individual-level microsimulation
- D) Discrete event simulation
**Answer:** D
**Explanation:** The fifth model-choice question states that shared, limited resources, queues, or patient interactions favour discrete event simulation (ch. 22), described as "the only model type in Part IV that routinely models resource constraints explicitly."

### Q247 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** In §17.3, which of the following is NOT one of the three structural-assumption questions the chapter says come up in almost every state-transition model?
- A) Can patients move backward between states?
- B) Is there a tunnel state?
- C) What happens at the end of the model's time horizon?
- D) What discount rate should be applied to future costs?
**Answer:** D
**Explanation:** The three structural-assumption questions listed are about backward movement, tunnel states, and what happens at the end of the time horizon; discount rate is not among them (it is covered elsewhere in the book, e.g. Chapter 4/22).

### Q248 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** What R package and function does §17.3 use to render a model structure diagram, and what underlying graph language does it use?
- A) `ggplot2::ggplot()`, using grid graphics
- B) `DiagrammeR::grViz()`, using the DOT graph description language (Graphviz)
- C) `igraph::plot.igraph()`, using adjacency matrices
- D) `heemod::plot_model()`, using YAML
**Answer:** B
**Explanation:** The chapter states the `DiagrammeR` package's `grViz()` function renders diagrams written in the DOT graph description language, the same language used by Graphviz, well suited to drawing health-state diagrams.

### Q249 [Hard] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** Why does the chapter recommend the Beta distribution (rather than the Normal) for transition probabilities in PSA?
- A) Beta distributions are computationally faster to sample in R
- B) A Normal distribution can return draws below 0 or above 1, producing a model error or nonsensical result, while Beta is bounded on [0, 1]
- C) Beta distributions always have a smaller variance than Normal distributions
- D) NICE requires Beta distributions by regulation regardless of parameter type
**Answer:** B
**Explanation:** The heor-practice box explains that a transition probability must stay between 0 and 1 in every PSA draw; a Normal distribution can violate this bound, whereas the Beta distribution is defined on [0, 1] and matches the binomial likelihood typically generating the estimate.

### Q250 [Hard] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** In the worked method-of-moments beta-fitting example (mean 0.85, 95% CI 0.80-0.90), what are the resulting approximate alpha and beta shape parameters?
- A) alpha ≈ 0.85, beta ≈ 0.15
- B) alpha ≈ 29.24, beta ≈ 165.68
- C) alpha ≈ 165.68, beta ≈ 29.24
- D) alpha ≈ 1.96, beta ≈ 0.0255
**Answer:** C
**Explanation:** The worked R example computes alpha_p ≈ 165.68 and beta_p ≈ 29.24, and the check confirms Beta(165.68, 29.24) reproduces a mean of 0.85 and SE of 0.0255, matching the trial's reported CI.

### Q251 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** According to the chapter's parameter taxonomy, what distribution is conventionally used for relative treatment effects such as hazard ratios in PSA?
- A) Beta on the probability scale
- B) Dirichlet
- C) Normal on the log scale (e.g. log hazard ratio), matching the scale of the meta-analytic standard error
- D) Gamma on the raw hazard-ratio scale
**Answer:** C
**Explanation:** The chapter states relative treatment effects usually use a normal distribution on the log scale, because that is the scale on which the meta-analytic standard error from Chapters 11-12 was estimated.

### Q252 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** What is the key distinction the chapter draws between a technical model documentation (TMD) report and the executable R model code?
- A) The TMD is optional while the code is mandatory for NICE submissions
- B) A commented script explains *how* the model computes, while the TMD explains *why* it is built the way it is, for a reader who may never open the script
- C) The TMD only covers costs, while the code covers everything else
- D) There is no meaningful distinction; either can substitute for the other
**Answer:** B
**Explanation:** The chapter states documentation and code are not substitutes for each other: a commented script explains how the model computes, while the TMD report explains why it is built the way it is, for a reader who may never open the script.

### Q253 [Easy] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** What are the four layers the chapter recommends for organising an R decision-model project (§17.6)?
- A) Data, Code, Tests, Documentation
- B) Inputs, Engine, Results, Reporting
- C) Population, Intervention, Comparator, Outcome
- D) Scoping, Structure, Parameters, Validation
**Answer:** B
**Explanation:** The chapter describes an architecture of four layers — an inputs layer, an engine layer, a results layer, and a reporting layer — each doing one job and talking to the next through a clean interface.

### Q254 [Medium] [MCQ]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** Which CRAN package does the chapter name as implementing the inputs/engine/output architecture specifically for Markov cohort models, covered properly in Chapter 19?
- A) `rdecision`
- B) `heemod`
- C) `DiagrammeR`
- D) `quantreg`
**Answer:** B
**Explanation:** The chapter states that `heemod` is a mature CRAN package that implements exactly this inputs/engine/output separation for Markov cohort models, while `hesim` does something similar across a broader range of model types including partitioned survival.

### Q255 [Hard] [Image]
**Chapter(s):** 17 (Principles of Decision Modelling)
**Question:** IMAGE PLACEHOLDER: a left-to-right DiagrammeR/Graphviz DOT diagram with boxes "On Treatment" (light blue), "Cured" (light green), "Treatment Failure" (light salmon), and "Death" (grey), with arrows labelled "treatment success," "treatment failure," "re-registration" (Fail back to On Treatment), and three "mortality" arrows into Death from every other state, as rendered by `grViz()` in §17.3. Which structural-assumption answer is directly visible in this diagram?
- A) The model uses a tunnel state for a fixed treatment course length
- B) Patients can move backward between states (Fail -> OnTx via re-registration) and Death is absorbing and reachable from every other state
- C) The model has a societal perspective
- D) The time horizon is lifetime
**Answer:** B
**Explanation:** The chapter states the diagram already answers two of the three structural questions visibly: backward movement exists (`Fail -> OnTx`) and death is absorbing and reachable from everywhere, with no tunnel state in this simplified version.

## Chapter 18: Decision Trees

### Q256 [Easy] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** What are the three node types in a decision tree, and their typical shapes?
- A) Decision (square), chance (circle), terminal (triangle/end of branch)
- B) Root (diamond), leaf (circle), branch (square)
- C) Input (hexagon), process (rectangle), output (oval)
- D) Strategy (triangle), state (square), transition (circle)
**Answer:** A
**Explanation:** The chapter states every tree has three kinds of nodes: a decision node (drawn as a square, the strategy choice), a chance node (a circle, where nature decides the outcome), and a terminal node (a triangle or end of branch, carrying the accumulated payoffs).

### Q257 [Easy] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** In the TB diagnostic worked example, what is the TB prevalence among symptomatic presenters used in the branch-probability calculations?
- A) 0.10
- B) 0.30
- C) 0.60
- D) 0.98
**Answer:** B
**Explanation:** The chapter states "Among symptomatic presenters, TB prevalence is p = 0.30," which is used to compute the disease-status branch of both the smear and Xpert trees.

### Q258 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** What sensitivity and specificity values does the chapter assign to the Xpert MTB/RIF algorithm?
- A) Sensitivity 0.60, specificity 0.98
- B) Sensitivity 0.90, specificity 0.96
- C) Sensitivity 0.96, specificity 0.90
- D) Sensitivity 0.30, specificity 0.70
**Answer:** B
**Explanation:** The chapter states Xpert has sensitivity 0.90 and specificity 0.96, compared with smear microscopy's sensitivity 0.60 and specificity 0.98.

### Q259 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** What does the "rollback" (or "folding back") algorithm do in decision tree analysis?
- A) It randomly samples branch probabilities for a Monte Carlo simulation
- B) It works from the terminal nodes backward, replacing branches below each chance node with their probability-weighted average payoff until only the decision node remains
- C) It reverses the order of strategies in the output table
- D) It discounts future costs and QALYs to present value
**Answer:** B
**Explanation:** The chapter defines rollback/folding back as working from terminal nodes backward, replacing branches below a chance node with their probability-weighted average payoff, repeating until one EV per strategy remains at the decision node.

### Q260 [Hard] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** Based on the worked hand-calculation in §18.1, what are the expected cost and expected QALYs for the Smear-only strategy?
- A) $63.80 and 0.95454
- B) $60.40 and 0.93302
- C) $5.00 and 0.97000
- D) $158.00 and 1.00000
**Answer:** B
**Explanation:** The chapter's worked calculation sums 0.18×105 + 0.12×305 + 0.014×105 + 0.686×5 = $60.40 for expected cost, and 0.18×0.95 + 0.12×0.70 + 0.014×0.90 + 0.686×0.97 = 0.93302 for expected QALYs for Smear-only.

### Q261 [Hard] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** What is the approximate ICER of Xpert MTB/RIF versus Smear-only testing, per the chapter's worked example, and what does it imply?
- A) Approximately $158 per QALY gained; cheap insurance against missed diagnoses at almost any plausible willingness-to-pay threshold
- B) Approximately $3.40 per QALY gained; dominated by Smear-only
- C) Approximately $63.80 per QALY gained; too expensive to adopt
- D) Approximately $1580 per QALY gained; borderline cost-effective
**Answer:** A
**Explanation:** The chapter computes ICER = (63.80 - 60.40) / (0.95454 - 0.93302) ≈ $158 per QALY gained, and states this is "cheap insurance against missed diagnoses by almost any plausible willingness-to-pay threshold."

### Q262 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** Why does the chapter caution in its §18.1 pitfall box against pricing a diagnostic test only by sensitivity and specificity?
- A) Sensitivity and specificity are always reported incorrectly in published studies
- B) Prevalence sets how often the TP/FN branches versus FP/TN branches are even reached, so the same test's value changes dramatically with the underlying disease prevalence
- C) Specificity does not matter for cost calculations
- D) Sensitivity and specificity cannot be combined with cost data mathematically
**Answer:** B
**Explanation:** The pitfall box states that prevalence sets how often you reach the TP/FN branches versus FP/TN branches, so a highly sensitive test saves far more QALYs at high prevalence than at low prevalence — rerunning the tree at p=0.10 would move the ICER.

### Q263 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** In the §18.2 tidy-data-frame implementation, what R expression directly computes the rollback (expected value) once `path_prob` has been calculated?
- A) `mean(path_prob + cost)`
- B) `sum(path_prob * cost)` / `sum(path_prob * qaly)`, grouped by strategy
- C) `lm(cost ~ path_prob)`
- D) `t.test(cost, qaly)`
**Answer:** B
**Explanation:** The chapter states that with `path_prob` computed, the rollback is one `summarise()` call computing `ev_cost = sum(path_prob * cost)` and `ev_qaly = sum(path_prob * qaly)`, grouped by strategy — a direct translation of the hand arithmetic.

### Q264 [Hard] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** In `rdecision`, which three R6 node classes does the chapter introduce, and what does each represent?
- A) `RootNode`, `BranchNode`, `LeafNode` — representing start, middle, and end of any tree
- B) `DecisionNode` (root-level choice), `ChanceNode` (nature decides), `LeafNode` (terminal outcome carrying utility/cost)
- C) `InputNode`, `EngineNode`, `OutputNode` — representing the four-layer workflow from Chapter 17
- D) `StateNode`, `TransitionNode`, `CycleNode` — used only for Markov models
**Answer:** B
**Explanation:** The chapter introduces `DecisionNode` (the root-level choice point, e.g. "which algorithm?"), `ChanceNode` (a point where nature decides), and `LeafNode` (a terminal outcome carrying an incremental utility and cost).

### Q265 [Hard] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** In `rdecision`, what does setting `p = NA_real_` for one `Reaction` out of a `ChanceNode` accomplish?
- A) It causes the tree to fail evaluation until a numeric probability is supplied
- B) The package fills that probability in at evaluation time as one minus the sum of the other reactions from that same chance node, enforcing that branch probabilities sum to 1
- C) It tells `rdecision` to use a Dirichlet prior for that branch
- D) It marks that branch as a tunnel state
**Answer:** B
**Explanation:** The chapter explains that leaving one reaction's probability as `p = NA_real_` is idiomatic `rdecision` convention; the package fills it in at evaluation time as one minus the sum of the other reactions from that chance node, a built-in version of the "sum to 1" check.

### Q266 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** According to §18.3, what does `rdecision` buy over the from-scratch §18.2 data-frame approach, beyond identical arithmetic?
- A) Faster CPU execution only
- B) Repeatable evaluation over resampled inputs for PSA, graphical rendering of the tree structure for submission dossiers, and native cost/effect tracking enabling direct ICER/NMB extraction
- C) The ability to model Markov transitions directly within the same tree object
- D) Automatic discounting of future costs
**Answer:** B
**Explanation:** The chapter lists three benefits: `evaluate()` can be re-run over resampled parameters for PSA, the tree can be rendered graphically for a submission appendix, and cost/effect as native node attributes let ICER/NMB come directly out of `evaluate()`'s output.

### Q267 [Easy] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** What is the chapter's recommended practice for validating an `rdecision`-built tree against the hand/data-frame version?
- A) Discard the hand-rolled version once the package version is built
- B) Keep the hand-rolled §18.2 version in the repository as an independent cross-check, confirming both agree to the last rupee and fourth decimal of a QALY
- C) Only trust the `rdecision` version since it is peer-reviewed software
- D) Re-derive the ICER formula from scratch each time
**Answer:** B
**Explanation:** The heor-practice box recommends keeping the hand-rolled version as an independent cross-check, running both on the same inputs and confirming expected costs and QALYs agree to the last rupee and fourth decimal of a QALY.

### Q268 [Medium] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** Per §18.4, which criterion from Chapter 17 §17.2 determines when a decision tree (rather than a Markov model) is the right tool?
- A) The availability of individual patient-level data
- B) The one-off/short-horizon test: consequences resolve within a single episode of care with no need to track recurring health states over months or years
- C) Whether resource constraints like queues are present
- D) Whether the outcome is continuous or binary
**Answer:** B
**Explanation:** The chapter restates the §17.2 criterion by name: a tree suits a question when consequences resolve within a single episode of care with no need to track a cohort moving between recurring health states over time; crossing into cycling states moves you into Markov territory.

### Q269 [Hard] [MCQ]
**Chapter(s):** 18 (Decision Trees)
**Question:** In §18.5, what specifically "crosses the interface" when a decision tree hands off to a downstream Markov model?
- A) The full patient-level dataset used to build the tree
- B) A vector of state-occupancy probabilities: the probability mass arriving at each leaf node becomes the initial occupancy of the corresponding Markov starting state at cycle zero
- C) The tree's R6 class objects directly, reused as Markov nodes
- D) Only the aggregate ICER value
**Answer:** B
**Explanation:** The chapter is explicit that what crosses the interface is "not patients, not probabilities-as-abstractions, but a vector of state-occupancy probabilities" — each leaf's arriving probability mass becomes the initial occupancy of the corresponding Markov state at time 0.

### Q270 [Hard] [Image]
**Chapter(s):** 18 (Decision Trees)
**Question:** IMAGE PLACEHOLDER: a decision-tree diagram as in §18.1, with a square decision node "Algorithm" branching into "Smear" and "Xpert," each leading to a circular chance node for disease status (TB/No TB), then a second circular chance node for test result, ending in four triangular terminal nodes per strategy labelled TP, FN, FP, TN with attached cost and QALY payoffs. Which node type carries the accumulated cost and QALY payoffs in this diagram?
- A) The decision node (square)
- B) The first chance node (disease status)
- C) The terminal node (triangle / end of branch) — e.g. TP, FN, FP, TN
- D) The second chance node (test result)
**Answer:** C
**Explanation:** The chapter defines the terminal node as carrying the payoffs — here a cost and a QALY value — accumulated by the time that path is reached, as seen in the TP/FN/FP/TN outcomes of the TB diagnostic tree.

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

## Chapter 25: Handling Uncertainty

### Q361 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** According to the ISPOR-SMDM Task Force-6 taxonomy (Briggs, Weinstein et al.), which of the following is explicitly described as *not* a form of uncertainty at all?
- A) Parameter uncertainty
- B) Structural uncertainty
- C) Heterogeneity
- D) Methodological uncertainty
**Answer:** C
**Explanation:** The chapter states heterogeneity is "the one that is *not* uncertainty at all" — it reflects real, explainable variation across patient subgroups, not imprecision in an estimate, and should be handled via subgroup analysis rather than folded into a PSA distribution.

### Q362 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the TB model's one-way sensitivity analysis (§25.2), why is the discount rate varied in *both* arms simultaneously, rather than only in the New arm?
- A) Because the discount rate is the most influential parameter overall
- B) Because it is a shared biological/convention quantity that does not plausibly differ by which regimen a patient is on
- C) Because `optim()` requires symmetric parameter changes
- D) Because the discount rate only affects the SoC arm's cost calculations
**Answer:** B
**Explanation:** The text explains that parameters like the discount rate, p(Fail→Death), and on-treatment utility are shared quantities that genuinely apply identically to both arms, whereas cure probability and drug cost are specific to the regimen being evaluated; varying a shared parameter in only one arm manufactures an artificial incremental difference.

### Q363 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the worked tornado diagram example, the discount rate's "low" bound (1.5%) produces a *higher* incremental NMB (\$8,690) than its "high" bound (5%, \$7,615). What is the correct explanation given in the text?
- A) A coding error in the discount formula that was never corrected
- B) Lower discount rates increase future QALY gains' value disproportionately relative to up-front costs, since Cured-state QALYs accrue mostly in later cycles
- C) The New regimen's cost structure is inversely related to the discount rate
- D) Discount rates only affect costs, not QALYs, in this model
**Answer:** B
**Explanation:** The text notes that a lower discount rate means future QALY gains (reached mainly in later cycles via the Cured state) are discounted less, boosting their value — which is exactly why tornado-plotting code must use `pmin()`/`pmax()` rather than assuming "low parameter value always gives the low bar end."

### Q364 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What is the primary reason net monetary benefit (NMB) is preferred over the ICER as the outcome plotted in a tornado diagram?
- A) NMB is always a larger number, making bars easier to see
- B) NMB is a ratio and therefore more interpretable
- C) The ICER is a ratio that can behave discontinuously (jumping from very large positive to very large negative) when the denominator changes sign, while NMB is a smooth linear combination
- D) NMB does not require a willingness-to-pay threshold
**Answer:** C
**Explanation:** The chapter's difficult-terminology box explains that ICERs misbehave when incremental QALY gain is near zero or changes sign, while NMB (λ×QALY − Cost) has no such discontinuity since it's a linear combination, not a ratio.

### Q365 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What distinguishes a scenario analysis from a one-way sensitivity analysis?
- A) Scenario analysis uses random draws from distributions; one-way sensitivity analysis does not
- B) Scenario analysis varies one named, coherent bundle of simultaneous parameter changes motivated by a real-world narrative, while one-way sensitivity analysis moves exactly one parameter at a time to isolate its individual influence
- C) Scenario analysis is only used for structural uncertainty
- D) One-way sensitivity analysis always produces more scenarios than scenario analysis
- **Answer:** B
**Explanation:** The text explicitly distinguishes the two: a scenario ("optimistic," "pessimistic") bundles several simultaneous changes under one narrative, whereas a one-way sensitivity analysis isolates a single parameter's influence, holding everything else at base case.

### Q366 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In R's `modifyList()`-based scenario engine, what is the key benefit of specifying only the parameters a scenario actually changes, rather than copy-pasting a whole parameter list per scenario?
- A) It runs the model faster
- B) It automatically adjusts the willingness-to-pay threshold
- C) Every scenario automatically tracks later base-case revisions for everything it did not explicitly override, avoiding stale hand-edited values
- D) It eliminates the need for a base case at all
**Answer:** C
**Explanation:** The heor-practice box warns that copy-pasting entire parameter lists risks leaving stale values when the base case is later revised; `modifyList()` with minimal overrides guarantees unchanged parameters always inherit the current base case.

### Q367 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Which probability distribution is the standard convention for PSA sampling of a single transition probability such as `p_ontx_fail`?
- A) Normal distribution
- B) Dirichlet distribution
- C) Beta distribution, because it is bounded on [0,1] and its parameters can be read directly as pseudo-counts of success/failure
- D) Uniform distribution
**Answer:** C
**Explanation:** §25.4 states that any probability or proportion parameter is bounded 0-1 and the Beta(a,b) distribution is standard precisely because it shares that bound by construction, with a and b readable as pseudo-counts.

### Q368 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Why is the Dirichlet distribution, rather than independent Beta draws per cell, required for sampling a whole row of a transition matrix in PSA?
- A) The Dirichlet distribution runs faster in R
- B) A transition-matrix row is a vector of probabilities constrained to sum to exactly 1, which independent per-cell Beta draws would violate
- C) Dirichlet distributions are easier to parameterise than Beta distributions
- D) Transition matrices cannot use Beta distributions at all
**Answer:** B
**Explanation:** The chapter explains that a transition-matrix row is not a single bounded scalar but a vector constrained to sum to 1, and the Dirichlet is the multivariate generalisation of Beta that respects this sum-to-one structural constraint.

### Q369 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Why does naively applying a normal distribution to a probability parameter in PSA constitute a dangerous pitfall?
- A) Normal distributions are computationally expensive
- B) A normal distribution can sample a negative "probability" or one exceeding 1 — syntactically valid but nonsensical once fed into a transition matrix, and may go unnoticed if the parameter's influence on the ICER is modest
- C) Normal distributions cannot be used in R's `rnorm()` function
- D) Normal distributions always produce biased mean estimates
- **Answer:** B
**Explanation:** The pitfall box warns explicitly that a normal distribution applied to a bounded probability parameter can produce out-of-range draws that are numerically valid but meaningless, and such errors can go unnoticed for a long time if the parameter's influence is modest.

### Q370 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What does a "convergence check" in PSA assess, and what signals that enough iterations have been run?
- A) Whether the transition matrix rows sum to 1; signalled by zero rounding error
- B) Monte Carlo error via a running summary statistic (e.g. mean incremental cost); signalled by the running estimate no longer changing by a practically meaningful amount as more iterations are added
- C) Whether the model crashes; signalled by no error messages
- D) The correlation between cost and QALY parameters; signalled by a correlation near zero
**Answer:** B
**Explanation:** The chapter describes tracking a running summary statistic across increasing iteration counts and looking for the diminishing-returns point where Monte Carlo error has shrunk below the precision the decision needs — illustrated by the TB model's running mean stabilising by N=1000-1500.

### Q371 [Medium] [Image]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** IMAGE PLACEHOLDER: a tornado diagram of one-way sensitivity analysis on incremental NMB for the New TB regimen vs SoC, bars sorted by swing width descending, as in §25.2 / fig-ch25-tornado. Based on the chapter's reported swing values, which parameter's bar should appear widest (at the top) of the tornado diagram?
- A) Annual discount rate
- B) New-regimen cost per cycle
- C) New-regimen cure probability p(OnTx→Cured)
- D) On-treatment utility, shared
**Answer:** C
**Explanation:** The chapter's OWSA table reports a swing of \$7,945 for cure probability, dwarfing the discount rate (\$1,076), drug cost (\$827), and utility (\$642) swings by a factor of three or more, so it occupies the top (widest) bar.

### Q372 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What is the purpose of a two-way sensitivity analysis that a pair of separate one-way analyses cannot reveal?
- A) It runs faster than two one-way analyses combined
- B) It reveals whether a joint, simultaneous combination of two pessimistic (or optimistic) parameter values flips the decision, which separate one-at-a-time analyses on each parameter cannot show
- C) It replaces the need for a tornado diagram
- D) It only works for parameters measured in dollars
**Answer:** B
**Explanation:** The text explains that two separate one-way analyses could each look reassuring individually while hiding an unfavourable joint corner of the parameter space — exactly what the two-way grid (cure probability × cost) is designed to check.

### Q373 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the cost-effectiveness acceptability curve (CEAC), what does a value near 1 at a given willingness-to-pay (WTP) threshold mean?
- A) The intervention is almost never cost-effective at that threshold
- B) The intervention is cost-effective in nearly every simulated PSA draw at that threshold
- C) The PSA has not converged
- D) The ICER equals exactly the WTP threshold
**Answer:** B
**Explanation:** The chapter defines the CEAC as, for each WTP value k, the proportion of PSA draws with positive incremental NMB at that threshold; a value near 1 means the intervention comes out favoured in nearly all draws.

### Q374 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What distinguishes the cost-effectiveness acceptability frontier (CEAF) from an ordinary CEAC when three or more strategies are compared?
- A) The CEAF is simply the CEAC of the most expensive strategy
- B) The CEAF traces, at each WTP threshold, the acceptability value of whichever strategy currently has the highest probability of being optimal — an upper envelope across all strategies' curves, which can switch strategy as the threshold moves
- C) The CEAF ignores willingness-to-pay thresholds entirely
- D) The CEAF is only valid for exactly two strategies
**Answer:** B
**Explanation:** The difficult-terminology box explains that with 3+ strategies the decision shifts to "which strategy is most likely optimal," and the CEAF is the composite upper envelope of each strategy's own CEAC, computed by BCEA's `multi.ce()`.

### Q375 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the threshold analysis worked example (§25.6), what quantity is being solved for, and using what approach?
- A) The exact willingness-to-pay threshold at which two different models agree, found via grid search
- B) The maximum total discounted cost ("breakeven price") the new regimen could have and still be cost-effective at a stated WTP, solved algebraically by rearranging the ICER formula
- C) The number of PSA iterations needed for convergence, found via simulation
- D) The optimal number of health states in the Markov model, found via AIC
**Answer:** B
**Explanation:** The chapter rearranges ICER = WTP into cost_new = cost_comp + WTP × (qaly_new − qaly_comp), directly extending Chapter 24's value-based-pricing relationship, to solve algebraically for the breakeven cost (\$8,455.34 in the worked example).

### Q376 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Why does the chapter caution against treating a threshold analysis result as a fixed, settled truth?
- A) Threshold analyses are always wrong by construction
- B) The breakeven number holds every other parameter at its base-case value, so it inherits all the same base-case uncertainty that PSA quantifies — it should be reported alongside a PSA, not as a replacement for one
- C) Threshold analysis cannot be computed in R
- D) WTP thresholds change every year automatically
**Answer:** B
**Explanation:** The pitfall box explains that the breakeven number will itself shift if the comparator's own cost or QALY estimate moves, so threshold analysis answers "breakeven at the point-estimate base case" while PSA/CEAC answers how confident to be once uncertainty is accounted for.

### Q377 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the structural uncertainty worked example, collapsing the 4-state TB model into a 3-state model (removing the explicit Fail state) changed the incremental NMB from \$8,044.05 to \$5,357.89. What does the chapter say this demonstrates?
- A) The 3-state structure is simply wrong and should never be reported
- B) The direction of the conclusion (New preferred) is robust across both structures, but the magnitude is not — the simpler structure understates New's advantage because it removes the costly, low-utility Fail state that New's lower failure probability most benefits from avoiding
- C) Structural uncertainty is identical to parameter uncertainty
- D) Model averaging is mandatory whenever two structures disagree
**Answer:** B
**Explanation:** The text states that under both structures New is cheaper and more effective (robust direction), but the magnitude is not robust because collapsing Fail removes the costly/low-utility state from the ledger for both arms, understating the advantage New gains from its lower failure rate.

### Q378 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Why does model averaging combine NMB values across structures rather than ICER values, per §25.7?
- A) ICERs cannot be computed for multiple structures
- B) NMB is a linear combination of cost and effect and therefore behaves additively under weighted combination, whereas an ICER is a ratio of two uncertain quantities and ratios do not average sensibly
- C) NMB values are always positive, making averaging easier
- D) ICERs require a willingness-to-pay threshold but NMB does not
**Answer:** B
**Explanation:** The chapter explicitly states that NMB is a single linear combination of cost and effect, so a weighted sum of NMBs is itself a meaningful NMB, whereas an ICER's ratio nature makes weighted averaging not meaningful — this is why the worked example averages NMB, not ICER.

### Q379 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** Per Bojke, Claxton, Sculpher and Palmer (2009), cited in §25.7, under what condition should candidate model structures NOT be combined via model averaging?
- A) When both structures use the same discount rate
- B) When the structures do not share comparators, the time horizon, the outcome definition, and the discount rate — e.g. one uses a 10-year horizon and QALYs while another uses a lifetime horizon and life-years
- C) When fewer than three structures are being compared
- D) When expert elicitation was not used to derive the weights
**Answer:** B
**Explanation:** The pitfall box states that model averaging only makes sense when structures answer the same decision question with genuinely comparable outputs; mismatched horizons or outcome definitions make a weighted average a blend of two different questions, not a defensible estimate.

### Q380 [Hard] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** In the §25.8 patient-level trial bootstrap, why must the resampling draw whole *rows* (patient cost-and-QALY pairs together) rather than resampling the cost column and QALY column independently?
- A) Resampling rows is computationally faster in R
- B) Independent column resampling breaks the within-patient correlation between cost and QALY, which the pitfall demonstrates inflated the bootstrap NMB standard deviation by roughly 17% and produced an artificially wider, wrong sampling distribution
- C) R's `sample()` function cannot resample two columns at once
- D) Row-wise resampling is only needed when sample sizes exceed 1,000
**Answer:** B
**Explanation:** The pitfall explicitly quantifies the consequence: resampling columns independently rather than row-wise inflated the bootstrap NMB standard deviation from \$530.72 to \$619.18 (~17%) and widened the 95% interval, because it destroys genuine within-patient cost-QALY correlation.

### Q381 [Medium] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What is the fundamental difference between the non-parametric bootstrap (§25.8) and the parametric PSA approach used earlier in the chapter?
- A) The bootstrap requires fewer than 100 iterations; PSA requires thousands
- B) PSA assumes a distributional form (Beta, Gamma, Normal) fit to parameters; the non-parametric bootstrap makes no such assumption and instead resamples the actual observed trial data with replacement
- C) The bootstrap can only be applied to cost data, never QALYs
- D) PSA is used only for structural uncertainty, the bootstrap only for parameter uncertainty
**Answer:** B
**Explanation:** The difficult-terminology box explains that parametric methods (like PSA) assume a distributional form and estimate its parameters, while the non-parametric bootstrap treats the observed sample as a stand-in for the population and estimates a sampling distribution purely by resampling.

### Q382 [Easy] [Image]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** IMAGE PLACEHOLDER: a cost-effectiveness plane scatter plot of 2,000 PSA draws (incremental QALY on x-axis, incremental cost on y-axis) with a dotted willingness-to-pay line through the origin, as in §25.5 / fig-ch25-ce-plane. What does a PSA draw falling *below* the dotted WTP line on this plane represent?
- A) A draw where the new strategy is dominated
- B) A draw where the new strategy is cost-effective at that WTP threshold (positive incremental NMB)
- C) A draw with zero incremental QALYs
- D) A draw that should be excluded as an outlier
**Answer:** B
**Explanation:** The WTP line through the origin divides the plane into "cost-effective" (below the line, where cost is less than WTP times QALY gain) and "not cost-effective" (above it) regions for every draw simultaneously.

### Q383 [Easy] [MCQ]
**Chapter(s):** 25 — Handling Uncertainty
**Question:** What is the standard distribution choice for cost parameters in PSA, and why?
- A) Beta, because costs are bounded between 0 and 1
- B) Normal, because costs are symmetric around their mean
- C) Gamma or lognormal, because costs can never be negative and are typically right-skewed with a long tail of high-cost patients
- D) Uniform, because the plausible cost range is usually unknown
**Answer:** C
**Explanation:** §25.4 states costs can never be negative and are empirically right-skewed, so Gamma and lognormal — both non-negative, right-skewed distributions — are the standard choices, with Gamma fully specified via method-of-moments from a mean and SE.

---

## Chapter 26: Value of Information Analysis

### Q384 [Easy] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What does the Expected Value of Perfect Information (EVPI) represent, per the "two crystal balls" analogy in §26.1?
- A) The cost of running a specific future clinical trial
- B) The dollar value of upgrading from the current PSA's distribution of plausible values to certain knowledge of every parameter's true value before deciding
- C) The probability that the current decision is correct
- D) The variance of the incremental NMB distribution
**Answer:** B
**Explanation:** The difficult-terminology box frames EVPI as the expected gain, averaged over every possible true parameter combination, from always getting to make the fully-informed choice instead of committing to one fixed choice today — "a ceiling, not a forecast."

### Q385 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** Which formula correctly represents EVPI as given in §26.1?
- A) EVPI = E_θ[max_d NB(d,θ)] − max_d E_θ[NB(d,θ)]
- B) EVPI = max_d NB(d,θ) − E_θ[NB(d,θ)]
- C) EVPI = Var(NB) / n
- D) EVPI = E_θ[NB(d,θ)] × P(d is optimal)
**Answer:** A
**Explanation:** The chapter gives EVPI as the expected net benefit of an oracle who picks the best strategy for each draw, minus the net benefit of committing to the single best strategy in expectation — exactly E_θ[max_d NB(d,θ)] − max_d E_θ[NB(d,θ)], which is always ≥ 0.

### Q386 [Easy] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** In the worked six-draw illustrative EVPI example (§26.1), what was the computed EVPI per patient at WTP = \$50,000?
- A) \$0 (no value to further information)
- B) \$8,044.05 (equal to the base-case incremental NMB)
- C) \$858.33
- D) \$299,325
**Answer:** C
**Explanation:** Averaging the "best for this draw" NMB column gives \$300,183.33, versus the fixed-choice value of \$299,325 (always choosing New); the difference, EVPI, is \$858.33 per patient.

### Q387 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** Why can EVPI be computed directly from existing PSA draws with "no new simulation at all," according to §26.1-26.2?
- A) EVPI only requires knowing the mean of the PSA distribution, not individual draws
- B) EVPI only needs the per-iteration cost and QALY values already produced by the PSA, reused to form NMB for each strategy and compared draw-by-draw
- C) EVPI is a fixed theoretical constant independent of data
- D) R's `optim()` function computes EVPI automatically
**Answer:** B
**Explanation:** The chapter states EVPI is computed by re-using the per-iteration cost and QALY values from the existing `psa_results` structure, comparing nmb_new and nmb_soc draw-by-draw with no additional model runs required.

### Q388 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** According to §26.2, what shape does EVPI typically follow as a function of the willingness-to-pay (WTP) threshold, and why?
- A) It increases monotonically with WTP with no peak
- B) It is constant across all WTP values
- C) It is low at very low and very high WTP (where the decision is nearly unanimous across draws) and peaks near the WTP where the CEAC crosses 50%, i.e. where the decision is closest to a coin-flip
- D) It decreases monotonically with WTP, reaching zero at high thresholds only
**Answer:** C
**Explanation:** The chapter explains that at extreme WTP values the "right" decision is clear-cut across nearly every draw so EVPI is near zero, while EVPI peaks near the WTP at which the CEAC is closest to 50% — the point where draws are most evenly split.

### Q389 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What is the key difference between EVPI and EVPPI?
- A) EVPPI is always larger than EVPI
- B) EVPI resolves uncertainty in all parameters at once; EVPPI resolves uncertainty in only one parameter (or a chosen subset), leaving the rest exactly as uncertain as before
- C) EVPPI requires no PSA draws at all, unlike EVPI
- D) EVPI applies only to costs, EVPPI only to QALYs
**Answer:** B
**Explanation:** The chapter states EVPPI is a strictly smaller quantity than EVPI (resolving one parameter can never be worth more than resolving everything), and it is the quantity relevant for prioritising which specific future study to fund.

### Q390 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** Why does naive EVPPI estimation require a "nested" simulation that is far more computationally expensive than EVPI?
- A) EVPPI requires re-fitting the PSA distributions from scratch
- B) For each of many candidate values of the parameter of interest (outer loop), a full inner-loop PSA over every other parameter must be re-run to estimate conditional expected net benefit — e.g. 1,000 outer × 1,000 inner draws yields a million model evaluations for one parameter's EVPPI
- C) EVPPI can only be computed using Bayesian MCMC
- D) EVPPI requires collecting new patient-level trial data before any calculation can begin
**Answer:** B
**Explanation:** The chapter explicitly describes this nested structure and gives the million-evaluation example, contrasting it with EVPI's zero-additional-model-runs requirement, which motivates the regression-based shortcut in §26.3.

### Q391 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What statistical insight underlies Strong, Oakley and Brennan's (2014) regression-based EVPPI approach described in §26.3?
- A) EVPI only ever needed the expected net benefit conditional on a given value, which can be estimated by regression (e.g. a GAM) directly on existing PSA draws rather than by brute-force nested simulation
- B) Regression models are faster to fit than Markov models
- C) GAMs eliminate the need for willingness-to-pay thresholds
- D) Linear regression is always sufficient, so GAMs are unnecessary
**Answer:** A
**Explanation:** The chapter describes this as "a clever piece of statistical judo": since the conditional expectation nested simulation estimates the hard way is exactly what a regression's fitted value estimates by construction, fitting a GAM to existing PSA draws gets the same quantity with zero additional model runs.

### Q392 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** Why is a Generalized Additive Model (GAM), rather than ordinary linear regression, the standard tool for the EVPPI regression step?
- A) GAMs always run faster than linear models
- B) The true relationship between a parameter like `p_ontx_fail` and net monetary benefit is not guaranteed to be a straight line; a GAM fits a flexible smooth curve that can bend to follow genuine curvature while a straight line cannot
- C) Linear regression cannot be used with `mgcv`
- D) GAMs do not require a smoothness penalty
**Answer:** B
**Explanation:** The difficult-terminology box explains that NMB might rise steeply then flatten with respect to the failure probability, a shape a straight line cannot follow but a GAM's flexible smooth term (`s(x)` in `mgcv::gam()`) can.

### Q393 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What is the predictable bias direction when `mgcv`'s smoothness parameter `k` is set too small versus too large in a GAM-based EVPPI calculation, per the §26.3 pitfall?
- A) Too small k overstates EVPPI; too large k understates it
- B) Too small k forces an overly rigid fit that smooths real curvature away as noise, understating EVPPI; too large k lets the curve chase sampling noise as if it were a real relationship, overstating EVPPI
- C) Both too-small and too-large k always overstate EVPPI
- D) The value of k has no effect on the EVPPI estimate, only on computation time
**Answer:** B
**Explanation:** The pitfall explicitly states: too small a k understates EVPPI by smoothing away genuine relationship as noise; too large a k overstates EVPPI by letting the curve fit sampling noise as if it were a real signal — the defence is REML-based automatic smoothness selection plus visual diagnostic checking.

### Q394 [Medium] [Image]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** IMAGE PLACEHOLDER: a GAM fit diagnostic scatter plot of raw PSA draws with the mgcv::gam() fitted smooth curve (red) overlaid against p_ontx_fail and incremental NMB, as in §26.3 / fig-ch26-gam-diagnostic. What EVPPI value for `p_ontx_fail` does the chapter report from running this fit on the actual PSA draws?
- A) \$120.00
- B) \$4.00
- C) \$847.01
- D) \$30,000,000
**Answer:** C
**Explanation:** The figure caption states that running the GAM fit on the actual PSA draws gives an EVPPI for p_ontx_fail of \$847.01, close to and independently confirming the \$900 illustrative figure used in worked examples elsewhere in the chapter.

### Q395 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What concrete, policy-relevant question does EVSI (Expected Value of Sample Information) answer that EVPPI cannot?
- A) What is the most we should ever pay to resolve all parameter uncertainty?
- B) What would a specific, real, finite proposed study of a given sample size actually be worth, as opposed to the idealised infinite-sample thought experiment EVPPI represents?
- C) Which model structure is more clinically plausible?
- D) What is the base-case ICER of the decision problem?
**Answer:** B
**Explanation:** §26.4 states EVSI asks what a specific, finite study (e.g. n=200 patients) would actually be worth, which is exactly what a research funder needs, whereas EVPPI is an idealised "what if we knew this parameter perfectly" thought experiment.

### Q396 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** In the moment-matching approach to EVSI (§26.4), what statistical identity is exploited to avoid simulating hypothetical future datasets?
- A) The central limit theorem
- B) The law of total variance: Var(θ) = E[Var(θ|data)] + Var(E[θ|data]), which allows the expected posterior variance reduction from a given sample size to be derived without simulating a single hypothetical patient
- C) Bayes' theorem applied directly to the ICER
- D) The delta method for standard errors
**Answer:** B
**Explanation:** The difficult-terminology box explains that moment-matching uses the law of total variance to estimate the second term (how much the central estimate moves) from existing PSA samples and back out the expected leftover posterior variance by subtraction, with no simulated patients needed.

### Q397 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** In the Beta-Binomial moment-matching worked example for `p_ontx_fail` ~ Beta(8,92), what fraction of the prior variance is expected to be resolved by a future trial of n=200 patients?
- A) About 95.2%
- B) About 33.3%
- C) About 66.4%
- D) About 100%
**Answer:** C
**Explanation:** The chapter computes the expected posterior variance after observing ~16 failures in 200 patients (Beta(24,276)) and finds the reduction is roughly 0.000729 to 0.0002445, about 66.4% of the original variance — closely matching the "effective sample size" heuristic of 1 − 100/300 ≈ 66.7%.

### Q398 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What is the key assumption and main risk of the Gaussian approximation approach to EVSI described in §26.4?
- A) It assumes net benefit is normally distributed, which is fast and convenient but can be materially wrong when net benefit is skewed or multimodal, such as from a rare high-cost failure branch
- B) It requires simulating thousands of hypothetical datasets, making it the slowest of the three EVSI methods
- C) It can only be used for binary outcome parameters
- D) It is only valid when EVPPI equals zero
**Answer:** A
**Explanation:** The chapter states the Gaussian approximation is the fastest of the three approaches but its normality assumption can be misleading for skewed or multimodal net-benefit distributions, such as the TB model's rare high-cost failure branch — best paired with a visual check.

### Q399 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What is the Expected Net Benefit of Sampling (ENBS), and what counter-intuitive finding does the ENBS worked example (comparing a 200-patient vs 2,000-patient trial) illustrate?
- A) ENBS = EVSI × trial cost; the finding is that larger trials always have higher ENBS
- B) ENBS = EVSI − trial cost; the finding is that a larger, more expensive study can have a lower — even negative — ENBS than a smaller, cheaper study targeting the same parameter, due to diminishing returns in variance reduction
- C) ENBS = EVPPI / trial cost; the finding is that ENBS is always positive if EVPPI is positive
- D) ENBS is identical to EVPI once trial costs are included
**Answer:** B
**Explanation:** The worked example gives ENBS of \$29,950,000 for the small (n=200, \$50,000 cost) trial versus −\$2,150,000 for the large (n=2,000, \$45M cost) trial — the large trial's EVSI gain (\$12.85M) doesn't cover its \$44.95M cost premium, a genuinely non-obvious VOI output.

### Q400 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** What question does the Value of Implementation (EVI), introduced in §26.5, answer that is fundamentally different from EVPI, EVPPI, EVSI, and ENBS?
- A) How much would it cost to run a larger confirmatory trial?
- B) How much is it costing a health system that an already-correct decision isn't yet being fully carried out in practice, due to slow real-world adoption — independent of any remaining parameter uncertainty
- C) Which model structure best fits the calibration target?
- D) How many PSA iterations are needed for convergence?
**Answer:** B
**Explanation:** The difficult-terminology box contrasts information-focused VOI ("might the decision be wrong?") with implementation-focused VOI ("is the correct decision actually being carried out?") — EVI quantifies the aggregate foregone benefit from the gap between a guideline being issued and full real-world uptake.

### Q401 [Hard] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** In the §26.5 worked value-of-implementation example (5-year linear ramp to 80% terminal uptake, 10,000 eligible patients/year, \$8,044.05 incremental NMB/patient), what was the total value-of-implementation figure over the 5-year horizon?
- A) \$16,088,100
- B) \$67,570,020
- C) \$209,145,300
- D) \$8,044.05
**Answer:** C
**Explanation:** Summing the value lost per year across years 1-5 (8,400/6,800/5,200/3,600/2,000 un-switched patients each multiplied by the \$8,044.05 per-patient NMB) gives a total of \$209,145,300, undiscounted, over the ramp-up horizon.

### Q402 [Medium] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** Per the pitfall in §26.4, why can EVSI be close to zero even for a large, well-funded proposed trial?
- A) Large trials always have EVSI of zero by statistical definition
- B) EVSI is a property of the specific proposed study, not just the parameter; a trial that re-measures a parameter whose EVPPI is already near zero, or that targets a parameter the decision barely responds to, can have near-zero EVSI regardless of sample size
- C) EVSI can only be positive for trials under 500 patients
- D) Large trials automatically have negative ENBS
**Answer:** B
**Explanation:** The pitfall states this exact point: no amount of additional precision on an already-unimportant parameter changes the decision, so even a trial of several thousand patients can have EVSI near zero if badly targeted — exactly the finding VOI exists to catch before money is committed.

### Q403 [Easy] [MCQ]
**Chapter(s):** 26 — Value of Information Analysis
**Question:** In §26.6's illustrative EVPPI ranking across four TB model parameters, which parameter had the highest EVPPI and was therefore flagged as the strongest candidate for a dedicated trial?
- A) Discount rate (\$4/patient)
- B) Cost of a failure event, `cost_fail` (\$120/patient)
- C) On-treatment health-state utility (\$340/patient)
- D) On-treatment failure probability, `p_ontx_fail` (\$900/patient)
**Answer:** D
**Explanation:** The illustrative ranking table shows p_ontx_fail with the highest EVPPI (\$900/patient), flagged "High — strong candidate for a dedicated trial," versus the discount rate's negligible \$4/patient despite being just as contested in seminars.

---

## Chapter 27: Model Calibration, Validation and Quality Assurance

### Q404 [Easy] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What is a "calibration target" as defined in §27.1?
- A) The parameter value an analyst hopes to obtain from optimisation
- B) An external, independently-measured outcome (e.g. a registry's reported mortality rate) that the model should be able to reproduce if its hidden parameters are set correctly, ideally from a different data source than whatever built the rest of the model
- C) The willingness-to-pay threshold used in PSA
- D) The seed value used in `set.seed()` for reproducibility
**Answer:** B
**Explanation:** The difficult-terminology box uses the "fitting a key to a lock" analogy: the target is fixed and known, calibration tries parameter values until the model's output matches it, and the target should come from a different data source or the exercise merely confirms the model reproduces its own inputs.

### Q405 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Why is random search calibration described as inefficient for models with more than a few unknown parameters?
- A) R's `runif()` function is slow for more than one parameter
- B) The number of draws needed to maintain the same coverage grows exponentially with the number of parameters — the "curse of dimensionality"
- C) Random search cannot be parallelized
- D) Random search always gets stuck in local optima
**Answer:** B
**Explanation:** The chapter explicitly states random search is easy to parallelize and avoids local optima, but with five or more unknown parameters the same grid density becomes computationally prohibitive due to the curse of dimensionality — with only one parameter, 500 draws is already overkill.

### Q406 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What numerical method does R's `optim()` with `method = "Nelder-Mead"` use to find the calibrated parameter value, and why is it suited to this TB model calibration?
- A) Gradient descent using analytic derivatives of the Markov transition probabilities
- B) A "simplex" of trial points that iteratively reflects, expands, or shrinks toward better-performing points, without needing calculus derivatives — suited here because the model output from discrete Markov cycles is not a smooth analytic function of p_hidden
- C) Exhaustive grid search over all possible parameter combinations
- D) Markov Chain Monte Carlo sampling from a posterior distribution
**Answer:** B
**Explanation:** The difficult-terminology box describes Nelder-Mead's "foggy valley" analogy — a simplex of trial points converging toward the minimum — and explains it is preferred here because it does not require the function to be differentiable, unlike gradient-based methods.

### Q407 [Easy] [Image]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** IMAGE PLACEHOLDER: a scatter plot of 500 random-search p_hidden candidates against their squared distance from the 32% mortality target, with a red point marking the best random-search draw and a dashed green line marking the Nelder-Mead result, as in §27.1 / fig-ch27-calibration-landscape. What converged value does the dashed green line mark?
- A) 0.32
- B) 0.15
- C) 0.084
- D) 0.01
**Answer:** C
**Explanation:** The figure caption states the dashed green line marks the Nelder-Mead-converged value of 0.084, visibly sitting near the bottom of the response curve that random search also explored.

### Q408 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Per the §27.1 pitfall, why is a single calibration target considered a "weak test"?
- A) Single targets always produce biologically implausible parameter values
- B) If p_hidden is calibrated only to match one target, many different combinations of other model parameters could also have been adjusted to hit that same number — the calibration is underdetermined and may be compensating for an error elsewhere in the model
- C) A single target cannot be expressed as a percentage
- D) Single-target calibration always requires Bayesian methods
**Answer:** B
**Explanation:** The pitfall explicitly states the calibration is underdetermined with just one target, and recommends calibrating against multiple independent targets simultaneously and checking the parameter set reproduces all of them, not just the one checked.

### Q409 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What key advantage does Bayesian calibration have over random search or Nelder-Mead point-estimate calibration?
- A) It always converges faster than Nelder-Mead
- B) It produces a full posterior distribution over the calibrated parameter, naturally capturing calibration uncertainty that flows through to more honest downstream cost-effectiveness uncertainty, rather than treating the calibrated value as known with certainty
- C) It does not require specifying a prior
- D) It eliminates the need for a calibration target entirely
**Answer:** B
**Explanation:** The chapter states that Bayesian calibration treats p_hidden as a random variable with a prior updated to a posterior, capturing calibration uncertainty that propagates downstream, unlike plain optimization which implicitly treats the point estimate as certain.

### Q410 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** How does Approximate Bayesian Computation (ABC) handle calibration when the likelihood function is too complex or expensive to write down explicitly?
- A) It derives a closed-form likelihood using the delta method
- B) It repeatedly draws candidate parameters from the prior, runs the full simulation, and keeps only draws whose simulated outcome is close enough to the observed target, treating surviving draws as an approximate posterior
- C) It requires converting all parameters to the log scale first
- D) It only works when the prior is uniform
**Answer:** B
**Explanation:** The difficult-terminology box explains ABC's "many physical keys" analogy: draws producing simulated outcomes within an acceptable distance of the target are kept, others rejected, and the surviving set approximates the posterior without ever formally computing a likelihood.

### Q411 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What advantage does Incremental Mixture Importance Sampling (IMIS) have over naive ABC rejection sampling?
- A) IMIS requires no prior distribution at all
- B) IMIS iteratively builds a mixture of distributions concentrated around regions of parameter space that fit well in earlier iterations, progressively focusing sampling effort — reaching a usable posterior with far fewer total model runs than naive rejection ABC
- C) IMIS always produces a single point estimate rather than a distribution
- D) IMIS does not require any model runs at all
**Answer:** B
**Explanation:** The chapter describes IMIS as sample-efficient because it starts like ABC but progressively concentrates sampling toward well-fitting regions rather than searching the whole prior space with equal density throughout.

### Q412 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** In §27.2, why can a model that is beautifully calibrated to match every target perfectly still be structurally wrong?
- A) Calibration automatically fixes any structural error present in the model
- B) Calibration can mask structural error by forcing a fit of a single parameter to the target; the model could have the wrong number of health states, wrong transitions, or inappropriate cycle length while still hitting the calibration target
- C) Perfect calibration is mathematically impossible, so this scenario cannot occur
- D) Structural errors only manifest in microsimulation, not cohort models
**Answer:** B
**Explanation:** §27.2 opens by distinguishing calibration ("what parameter value fits the target?") from structural cross-validation ("is this the right model structure?"), noting calibration can force a fit and mask a genuinely wrong model shape.

### Q413 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** In the §27.2 cross-validation worked example, the TB model (calibrated only to cohort 1's 5-year mortality of 32%) is checked against cohort 2's independent 3-year mortality of 21%. What does a close match between the predicted and held-out values provide evidence of?
- A) That the calibration target was chosen correctly by definition
- B) That the model's structure — not just the single calibrated parameter — captures the underlying disease process reasonably well, because it generalizes to data it never saw during fitting
- C) That no further validation is needed
- D) That the discount rate was set correctly
**Answer:** B
**Explanation:** The chapter states that if the predicted 3-year mortality comes out close to the held-out 21% target, that is reassuring evidence the model's structure generalizes, because the held-out cohort's data was never used anywhere in the calibration step.

### Q414 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Per the §27.2 pitfall, what condition must hold for a structural cross-validation "held-out" check to be genuinely informative?
- A) The held-out data must come from exactly the same patients as the training data
- B) The held-out data must be genuinely independent of whatever was used to build the model's structural assumptions in the first place — not overlapping patients or already-known information from the model's design phase
- C) The held-out data must always be larger than the training data
- D) The held-out check only needs to use the same outcome measure, regardless of data source
**Answer:** B
**Explanation:** The pitfall warns that if both the training target and the "held-out" check come from the same registry, overlapping patients, or were already known during the model's structural design phase, the check is not really independent and will look falsely reassuring.

### Q415 [Easy] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What is the distinction drawn in §27.3 between calibration/cross-validation and "verification"?
- A) Verification is a subset of calibration
- B) Verification asks whether the code correctly implements the intended model, independent of any external calibration target — a model can be perfectly calibrated by chance while still containing a coding error
- C) Verification only applies to microsimulation models
- D) Verification and calibration are synonymous terms for the same activity
**Answer:** B
**Explanation:** The chapter states a model can be perfectly calibrated to a real-world target purely by chance while still containing a coding error (e.g. a transition matrix whose rows don't sum to 1), and verification catches this by testing the code's internal logic rather than external fit.

### Q416 [Easy] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** In the `testthat` unit test for transition matrix row-sums, why is `tolerance = 1e-8` used rather than requiring an exact match to 1?
- A) To make the test pass regardless of the matrix's correctness
- B) Floating-point arithmetic rarely produces an exact 1.000000000 when probabilities are summed, so a strict comparison would fail correct code due to rounding noise, while 1e-8 is tight enough to catch genuine errors (e.g. a row summing to 0.95)
- C) Because R's `rowSums()` function is inherently imprecise above 1e-8
- D) Because the TB model has exactly 8 health states
**Answer:** B
**Explanation:** The text explains this exact rationale: a tolerance of 1e-8 tolerates harmless floating-point noise while still catching a genuine row-sum error such as a row summing to 0.95 from an omitted transition.

### Q417 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Why does the extreme-value test in §27.3 set the "Well" state's mortality probability to exactly 1, and why is this described as a stronger test than setting a cost parameter to zero?
- A) Because p=1 mortality is clinically realistic for TB patients
- B) The model's behaviour at p=1 is mathematically determinate (zero survivors after cycle 1), so any deviation reveals a bug; a zero-cost test is weaker because many cost structures trivially "pass" (total cost zero) without exercising meaningful logic
- C) Setting mortality to 1 is required by `testthat` syntax
- D) Zero-cost tests always fail regardless of correctness
**Answer:** B
**Explanation:** The pitfall explains that extreme-value tests are informative only when the extreme value is mathematically determinate and forces the test to exercise meaningful model logic; a transition probability of exactly 1 forces a specific, checkable cohort trace, unlike a trivially uninformative zero-cost test.

### Q418 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What distinct class of error does a "replication" check (§27.3) catch that unit tests do not?
- A) Logical errors in the transition matrix construction
- B) Platform-dependent behaviour, uncontrolled randomness, or silent dependency on the state of a previous script run — caught by confirming identical code, seed, and inputs produce identical numeric output across machines/sessions
- C) Errors in the willingness-to-pay threshold selection
- D) Errors only present in Bayesian calibration workflows
**Answer:** B
**Explanation:** The chapter explains replication confirms identical code/seed/inputs give identical output across machines or sessions, catching package version differences, unfixed random seeds, or hidden dependency on prior script state — a different error class than unit tests target.

### Q419 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What does the AdViSHE framework's "Implementation validation" domain correspond to, per the §27.4 reference table?
- A) Whether the model structure is a sensible representation of the disease
- B) The verification question from §27.1-27.3 — whether the model runs correctly, free of mechanical errors — treated as one domain among several rather than the whole of validation
- C) Whether the model has had independent peer review
- D) Whether parameter sources are appropriate
**Answer:** B
**Explanation:** The chapter explicitly states AdViSHE's Implementation validation domain is "essentially the verification question from 27.1-27.3," and that AdViSHE treats it as one domain among several rather than the whole of validation.

### Q420 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** According to §27.4, how does Eddy, Hollingworth, Caro, Tsevat, McDonald and Wong's (2012) ISPOR-SMDM Task Force-7 report further subdivide "validation," beyond the verification/validation split?
- A) Into cost validation and effect validation
- B) Into face validity, internal validity, cross-validation, and external (predictive) validity
- C) Into Bayesian and frequentist validation
- D) Into single-parameter and multi-parameter validation
**Answer:** B
**Explanation:** The chapter states Task Force-7 separates validation into face validity, internal validity (verification, in their terminology), cross-validation, and external (predictive) validity — the taxonomy that structures §27.6.

### Q421 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What is "second-modeler black-box replication," described in §27.5, and why is it considered strong evidence?
- A) A second analyst reviews the original code line by line looking for bugs
- B) A second analyst, given only the same inputs/assumptions/target outputs but deliberately NOT the original code, builds an independent implementation from scratch — matching results is strong evidence largely immune to a shared coding error since the implementations share no code
- C) An automated CI pipeline that reruns the same code on a different server
- D) A peer reviewer's qualitative judgment on whether the model "looks right"
**Answer:** B
**Explanation:** The chapter explicitly distinguishes this from a pull-request code review: the second analyst does not see the original code, so a matching ICER from the independent build is strong operational-validation evidence immune to a shared implementation error.

### Q422 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Per the §27.5 pitfall, why is a "green CI badge" (all `testthat` checks passing) not equivalent to genuine human code review?
- A) CI tests are always slower than human review
- B) CI tests only catch what someone thought to test for and say nothing about whether a change is clinically or economically sensible; human review catches conceptual/judgment errors no automated test anticipated
- C) CI badges only apply to Python code, not R
- D) CI pipelines cannot check transition matrix row-sums
**Answer:** B
**Explanation:** The pitfall states directly that CI catches mechanical regressions but says nothing about clinical/economic sensibility, and warns not to let a green CI badge substitute for a human reviewer reading the diff and rationale.

### Q423 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** What is the key terminological trap flagged in §27.6 regarding "cross-validation"?
- A) Cross-validation always requires a minimum sample size of 1,000
- B) The term is a naming collision: the statistical/ML sense (splitting one dataset into folds to estimate out-of-sample predictive performance, Chapter 16) differs structurally from the health-economic-modeling sense (comparing one entire decision model's outputs against other, separately built models of the same problem, with no data-splitting involved)
- C) Cross-validation in health economics always uses k=10 folds
- D) Cross-validation is only valid for microsimulation models, not cohort models
**Answer:** B
**Explanation:** The difficult-terminology box explicitly warns of this naming collision and instructs readers to infer which sense is meant from context — a statistics chapter means the ML sense, a model-validation chapter (like Ch.27) means the model-comparison sense.

### Q424 [Medium] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** In the §27.6 illustrative external-validity worked example, the TB Markov model predicts 78% 10-year survival for the New regimen, while an illustrative real-world cohort observed 74%. What is the relative (percentage) difference between these figures, as computed in the text?
- A) 4%
- B) 5.41%
- C) 78%
- D) 0.54%
**Answer:** B
**Explanation:** The chapter computes (78−74)/74 × 100 ≈ 5.41%, alongside the absolute difference of 4 percentage points — demonstrating the exact calculation an external-validity exercise performs.

### Q425 [Easy] [Image]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** IMAGE PLACEHOLDER: a bar or point comparison chart showing model-predicted (78%) vs illustrative observed (74%) 10-year survival for the New regimen, as in §27.6 / fig-ch27-external-validity. What caution does the chapter attach to this comparison, per the accompanying pitfall?
- A) The comparison proves the model is definitively correct
- B) A single cohort's outcome is one noisy data point; close agreement could be coincidental and disagreement could reflect a differing real-world population rather than a flawed model — external validity checks are evidence to weigh, not a verdict to declare
- C) External validity checks should replace all other forms of validation
- D) The 4-percentage-point gap definitively proves the model is flawed
**Answer:** B
**Explanation:** The pitfall explicitly warns not to treat a close match as proof of correctness or a gap as proof of flaw, since a single cohort comparison is one noisy data point — evidence to weigh, not a verdict to declare from one comparison.

### Q426 [Hard] [MCQ]
**Chapter(s):** 27 — Model Calibration, Validation and Quality Assurance
**Question:** Per §27.6, why is "face validity" described as necessary but not sufficient on its own for establishing model credibility?
- A) Because face validity requires statistical hypothesis testing
- B) Face validity is a qualitative, expert-judgment check of whether the model's structure looks plausible without running any numbers; an implausible structure isn't worth validating numerically, but a structurally sensible model can still produce numerically wrong outputs
- C) Because face validity can only be assessed after external validity
- D) Because face validity requires access to patient-level trial data
- **Answer:** B
**Explanation:** The difficult-terminology box states face validity is "the simplest and least rigorous form of validation" — a necessary first filter, since an implausible structure isn't worth numerically validating, but insufficient alone because a plausible-looking structure can still yield wrong outputs.

### Q427 [Easy] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** According to the chapter, what is the key structural difference between Quarto and classic R Markdown?
- A) Quarto is a standalone multi-language CLI publishing system, while R Markdown is built on the rmarkdown/knitr R packages
- B) Quarto only supports PDF output, while R Markdown supports all formats
- C) Quarto requires Python, while R Markdown requires only R
- D) Quarto cannot use YAML front matter, while R Markdown requires it
**Answer:** A
**Explanation:** The chapter explains Quarto as a standalone, multi-language command-line publishing tool, in contrast to classic R Markdown which relies on the rmarkdown and knitr R packages.

### Q428 [Easy] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** In a Quarto/.qmd document's code chunk options, what does the `echo` option control?
- A) Whether the code chunk's source code is displayed in the rendered output
- B) Whether the chunk is executed at all
- C) Whether warnings are suppressed
- D) The caption text shown under a table
**Answer:** A
**Explanation:** The chapter lists chunk options including echo, eval, warning, fig-cap, and tbl-cap; echo governs whether the underlying code itself appears in the rendered document (distinct from eval, which controls execution).

### Q429 [Medium] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** Which mechanism does the chapter describe for overriding a Quarto report's `params:` values from the command line without editing the .qmd file?
- A) `quarto render --execute-params` or `-P key:value`
- B) Editing the rendered HTML file directly after render
- C) Setting environment variables prefixed with QUARTO_PARAM_
- D) Using `knitr::opts_chunk$set()` inside the YAML header
**Answer:** A
**Explanation:** The chapter describes using `quarto render --execute-params` or the shorthand `-P key:value` flag to override parameter defaults declared in the report's `params:` YAML block, without touching the source file.

### Q430 [Medium] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** The chapter's pitfall box about parameterised reports warns about what specific risk?
- A) Rendering interactively without supplying overrides can leave stale default `params` values baked into the output
- B) Parameterised reports cannot be rendered to Word format
- C) `quarto::quarto_render()` cannot be called from inside an R driver loop
- D) Scenario data frames must be stored in a database, not a data frame
**Answer:** A
**Explanation:** The pitfall box specifically warns that rendering a parameterised report interactively (e.g., clicking "Render" in the IDE) without passing execution-time overrides will silently use the stale defaults declared in the YAML `params:` block.

### Q431 [Easy] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** How does a Quarto document specify that it should render to multiple output formats (e.g., HTML, Word, and PDF) from one source file?
- A) By listing multiple targets under the `format:` YAML key
- B) By duplicating the .qmd file once per format
- C) By setting `output: all` in the chunk options
- D) By calling `rmarkdown::render()` three times with no arguments
**Answer:** A
**Explanation:** The chapter shows that listing several targets under the `format:` YAML key lets one .qmd source be rendered to HTML, Word, PDF, and PowerPoint as needed.

### Q432 [Medium] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** What must be installed before a Quarto document can be rendered to PDF, per the chapter?
- A) A LaTeX distribution, via `tinytex::install_tinytex()` or `tlmgr_install()`
- B) The `officedown` package only
- C) Microsoft Word
- D) Nothing extra — PDF rendering works out of the box with no dependencies
**Answer:** A
**Explanation:** PDF output via Quarto requires a LaTeX engine, which the chapter sets up using `tinytex::install_tinytex()` or `tlmgr_install()` for missing LaTeX packages.

### Q433 [Medium] [Image]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** IMAGE PLACEHOLDER: A comparison table listing four R table-formatting packages (gt, gtsummary, flextable, kableExtra) as rows and their primary use-case niche as a column. Based on the chapter's comparison, which package is described as the go-to choice specifically for Word/PPT-native editable table output?
- A) flextable
- B) gtsummary
- C) kableExtra
- D) gt
**Answer:** A
**Explanation:** The chapter's comparison table positions flextable as the package suited to Word/PPT-native output, versus gtsummary for clinical summaries, gt as a general-purpose table package, and kableExtra for lightweight LaTeX/HTML tables.

### Q434 [Hard] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** Using the chapter's worked example with an incremental cost of -$844.14 and incremental QALYs of 0.1440, the ICER is calculated as -844.14/0.1440 ≈ -5862.08. What does this negative ICER indicate about the treatment being evaluated, per the chapter's terminology box?
- A) The treatment is dominant — it is both cheaper and more effective, so there is no cost-effectiveness tradeoff to weigh
- B) The treatment is cost-saving per QALY in the conventional sense that the ICER formula normally implies
- C) The treatment is dominated and should be rejected
- D) The negative sign indicates a calculation error that must be corrected before reporting
**Answer:** A
**Explanation:** The chapter's terminology box clarifies that a negative ICER here reflects dominance (lower cost AND higher effectiveness), not a per-QALY "cost-saving" ratio — a negative ICER is only meaningful as "dominant" when cost is negative and QALYs are positive, since there's no tradeoff being traded off.

### Q435 [Medium] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** Using the chapter's base-case figures (incremental cost = -$844.14, incremental QALYs = 0.1440, WTP = $50,000/QALY), the net monetary benefit is calculated as NMB = 0.1440×50000 − (−844.14) = 8044.14. Which statement correctly describes the NMB calculation shown?
- A) NMB equals (incremental QALYs × WTP threshold) minus incremental cost
- B) NMB equals incremental cost divided by incremental QALYs
- C) NMB equals WTP threshold minus incremental cost only
- D) NMB is calculated independently of the WTP threshold
**Answer:** A
**Explanation:** The chapter's formula for NMB is incremental QALYs multiplied by the WTP threshold, minus incremental cost; subtracting the negative incremental cost of -844.14 adds it back, yielding 8044.14.

### Q436 [Easy] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** What is `theme_heor()` in the chapter's publication-ready graphics section?
- A) A reusable custom ggplot2 theme built on `theme_minimal()` and applied via `theme_set()`
- B) A built-in viridis colour palette function
- C) A CHEERS 2022 checklist template
- D) A Quarto YAML output format
**Answer:** A
**Explanation:** The chapter builds `theme_heor()` as a reusable ggplot2 theme extending `theme_minimal()`, then applies it globally to plots using `theme_set()`.

### Q437 [Hard] [Image]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** IMAGE PLACEHOLDER: A figure showing a simulated three-arm cost-effectiveness plane rendered twice — once under the ggplot2 default colour palette and once under the viridis palette — each shown under normal vision and under simulated deuteranopia (via colorspace::simulate_cvd()). Based on the chapter's description of this figure, what is the key finding demonstrated?
- A) Under the default palette, two of the three treatment arms become visually indistinguishable under simulated deuteranopia, while all three remain distinguishable under viridis
- B) The viridis palette makes all three arms indistinguishable under deuteranopia, while the default palette keeps them distinct
- C) Colour palette choice has no effect on distinguishability under simulated colour-vision deficiency
- D) Only tritanopia simulation reveals a difference between the two palettes
**Answer:** A
**Explanation:** The chapter describes this embedded figure as concretely demonstrating that two of three arms collapse into visually similar colours under the default ggplot2 palette once deuteranopia is simulated, whereas the colour-blind-safe viridis palette keeps all three arms distinguishable — moving the colour-blind-safe-palette argument from assertion to demonstration.

### Q438 [Easy] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** Per the chapter, why is setting a `dpi` argument in `ggsave()` unnecessary for vector formats like PDF, EPS, or SVG?
- A) Vector formats scale cleanly without a fixed resolution, unlike raster formats which need a resolution such as 300 dpi for print
- B) Vector formats always default to 72 dpi regardless of the setting
- C) `ggsave()` cannot export vector formats at all
- D) Journals never accept vector formats for figures
**Answer:** A
**Explanation:** The chapter notes that 300 dpi is a common minimum for raster figures in print journals, but vector formats (PDF/EPS/SVG) have no resolution to set since they scale cleanly at any size.

### Q439 [Medium] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** What is CHEERS 2022, as implemented in this chapter's `cheers_checklist` example?
- A) A 28-item checklist for reporting health economic evaluations, published by Husereau, Drummond, Augustovski, et al. in Value in Health
- B) A 28-chapter R package for building HEOR models
- C) A statistical test for comparing ICERs across subgroups
- D) A Quarto template specifically for PowerPoint output
**Answer:** A
**Explanation:** The chapter cites CHEERS 2022 (Husereau et al., Value in Health 2022;25(1):10-31) as a 28-item reporting checklist, and builds a `cheers_checklist` tracking data frame via `tribble()` to track item-by-item compliance programmatically rather than on paper.

### Q440 [Medium] [MCQ]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** The chapter's pitfall box on Quarto dossiers built from child documents via `{{< include >}}` warns about which specific risk?
- A) Shared R-session state means two child documents both creating an object named `results` can cause the second to silently overwrite the first
- B) Child documents cannot access shared `params:` values set in the parent dossier
- C) `{{< include >}}` only works for HTML output, never Word or PDF
- D) Each child document must be rendered to a separate file before inclusion
**Answer:** A
**Explanation:** The chapter warns that because included child documents share the same R session/environment, object-name collisions (e.g., two children both defining `results`) can cause one to overwrite the other unless session state is carefully managed.

### Q441 [Hard] [Image]
**Chapter(s):** 28 — Reproducible Reporting
**Question:** IMAGE PLACEHOLDER: A flowchart showing a batch-rendering loop: a data frame with one row per programme/district feeds into purrr::pwalk() (or an equivalent for-loop) calling quarto::quarto_render() once per row, with a tryCatch() wrapper shown around each individual render call. Based on the chapter's description, what is the purpose of the tryCatch() wrapper in this flow?
- A) To ensure one failing district's report render does not halt the entire batch of remaining reports
- B) To automatically retry failed renders exactly three times before giving up
- C) To convert all rendering errors into successful HTML output
- D) To replace the need for a scenarios data frame entirely
**Answer:** A
**Explanation:** The chapter's pitfall box on automating routine reports recommends wrapping each batch render call in `tryCatch()` specifically so that one district's failure doesn't stop the loop from rendering reports for the remaining districts/programmes.

### Q442 [Easy] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** In the basic Shiny architecture for a model front-end, which statement correctly describes the roles of `ui` and `server`?
- A) `ui` defines the layout and widgets the user sees; `server` contains the reactive logic that computes and renders outputs
- B) `server` defines the layout; `ui` contains all the reactive calculations
- C) `ui` and `server` are interchangeable names for the same object
- D) `ui` runs once per session while `server` runs only once when the app starts
**Answer:** A
**Explanation:** Shiny apps are split into a `ui` object (layout/widgets) and a `server` function (reactive logic that produces outputs from inputs) — this ui/server split is the foundational structure described in 29.1.

### Q443 [Easy] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** In the toy ICER calculator app, if `input$treatment_cost` is 5000, comparator cost is fixed at 2000, and QALY gain is 0.15, what ICER does the app compute?
- A) $3,000 per QALY
- B) $20,000 per QALY
- C) $33,333 per QALY
- D) $7,000 per QALY
**Answer:** B
**Explanation:** The incremental cost is 5000 − 2000 = 3000, and ICER = incremental cost / QALY gain = 3000 / 0.15 = $20,000 per QALY, exactly as worked through in 29.1.

### Q444 [Medium] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** A developer writes `cost <- input$treatment_cost * 1.1` directly in the body of the server function, outside any `reactive({})`, `render*({})`, or `observe({})` block. What happens?
- A) The code runs once at app startup and never updates
- B) R throws "Error: Operation not allowed without an active reactive context."
- C) It works fine because `input$x` is a plain list, not reactive
- D) Shiny automatically wraps it in a reactive expression
**Answer:** B
**Explanation:** As described in the 29.1 pitfall, accessing a reactive value or expression outside an active reactive context (reactive, render*, or observe) throws exactly this error — reactive values can only be read from within reactive consumers.

### Q445 [Easy] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** For a single-screen HEOR model tool with inputs on one side and results on the other, which layout does the chapter recommend as the default?
- A) `navbarPage()`
- B) `sidebarLayout()`
- C) `bslib::page_navbar()`
- D) `fluidRow()` with no layout function
**Answer:** B
**Explanation:** 29.2 recommends `sidebarLayout()` (inputs left, results right) as the right default for a single-screen tool, reserving `navbarPage()`/`bslib::page_navbar()` for multi-tab apps once there is more than one result view.

### Q446 [Medium] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** A model parameter is "treatment regimen," with named options like "Standard 6-month" and "Shortened 4-month." Which widget best matches a non-programmer reviewer's mental model of this parameter?
- A) `sliderInput()`, because regimens are ordered
- B) `numericInput()`, so the reviewer types an exact code
- C) `selectInput()` with descriptive labels rather than internal codes like "std"
- D) `textInput()`, letting the reviewer type the regimen name freely
**Answer:** C
**Explanation:** 29.2 states widget choice should match the parameter's mental model — `selectInput()` for named categories — and explicitly warns against making a reviewer type an internal code like "std" when a label like "Standard 6-month" will do.

### Q447 [Medium] [Image]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** IMAGE PLACEHOLDER: A comparison table with three columns (Plain Shiny modules, golem, rhino) and five rows (setup overhead, best-fit use case, testing convention, front-end styling, learning curve), showing plain modules as lowest overhead/easiest, golem as package-structured for apps reused across years of submissions, and rhino as the most opinionated with a first-class JS/Sass build pipeline. Based on this table, which framework should a team choose if the app needs custom JavaScript/CSS styling and has a larger development team?
- A) Plain Shiny modules
- B) golem
- C) rhino
- D) None of these support custom styling
**Answer:** C
**Explanation:** Per 29.3, rhino is the newer, more opinionated framework with a stricter folder structure and a JS/Sass build pipeline for custom front-end styling as a first-class feature, making it the best fit for larger teams needing custom styling, versus golem's fit for apps reused across years/submissions.

### Q448 [Medium] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** A CE-summary module appears twice on the same page, once for the "standard regimen" scenario and once for the "shortened regimen" scenario. What Shiny mechanism prevents the two instances' input/output IDs from colliding?
- A) Giving each instance a different R script file
- B) `moduleServer()` combined with `NS(id)` namespacing
- C) Running each instance in a separate Shiny session
- D) Renaming all widgets manually with `paste0()` each time
**Answer:** B
**Explanation:** 29.3 explains that Shiny modules bundle a reusable UI+server pair using `moduleServer()` for server logic and `NS(id)` for namespacing, so IDs don't collide when the same module appears twice on one page.

### Q449 [Hard] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** An app has a cheap deterministic ICER recalculation and an expensive 1,000+ draw Monte Carlo PSA. Why does the chapter recommend tying the PSA specifically to an `actionButton()` via `eventReactive()` rather than a plain `reactive({})`?
- A) `eventReactive()` is required syntax for any calculation involving randomness
- B) A plain `reactive({})` would re-run the expensive PSA on every slider tweak, whereas `eventReactive()` only recomputes when the button is explicitly clicked
- C) `reactive({})` cannot call Monte Carlo functions at all
- D) `eventReactive()` runs the PSA faster by parallelizing draws automatically
**Answer:** B
**Explanation:** 29.4 distinguishes cheap, continuously-updating calculations (plain `reactive({})`, fine to re-run on every tweak) from expensive ones like a full PSA, which are tied to an `actionButton()` via `eventReactive()` specifically to avoid re-running the costly computation on every input change.

### Q450 [Medium] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** Why does the chapter recommend wrapping `req(psa_results())` inside `renderPlot()` for a PSA scatter plot?
- A) It speeds up plot rendering
- B) It holds the plot blank until the "Run PSA" button has been clicked at least once, rather than throwing an error
- C) It forces the PSA to run automatically on app load
- D) It validates that PSA results are numeric
**Answer:** B
**Explanation:** As described in 29.4, `req(psa_results())` inside `renderPlot()` silently holds the plot blank before the PSA has been triggered, avoiding an error state when no results exist yet.

### Q451 [Easy] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** Using the book's base-case numbers (incremental cost −$844.14, incremental QALY 0.1440) at a willingness-to-pay of $50,000/QALY, what is the incremental net monetary benefit (NMB)?
- A) $7,200.00
- B) $8,044.14
- C) $50,844.14
- D) $844.14
**Answer:** B
**Explanation:** NMB = WTP × incremental QALY − incremental cost = 50000 × 0.1440 − (−844.14) = 7200 + 844.14 = $8,044.14, exactly the figure the chapter carries forward in its Shiny PSA example.

### Q452 [Medium] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** Why does the chapter insist that a `downloadHandler()`'s content function call the SAME `quarto::quarto_render()` pipeline from Chapter 28, rather than a separate export route?
- A) Quarto only works inside `downloadHandler()`
- B) It guarantees the downloaded document matches exactly what the reviewer saw on screen
- C) It reduces the app's memory footprint
- D) Separate export routes are not technically possible in Shiny
**Answer:** B
**Explanation:** 29.5 states that reusing the identical Quarto pipeline, rather than an ad-hoc export route, guarantees the downloaded report matches exactly what was displayed in the app, which matters for audit integrity.

### Q453 [Medium] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** An audit trail logs parameter changes and model runs keyed on Shiny's `session$token`. What pitfall does the chapter warn against regarding what gets logged?
- A) `session$token` identifies the reviewer personally, so it should never be logged
- B) Logging every input indiscriminately can silently write sensitive free-text content (e.g. a comment box) to a plain-text file with no access control
- C) `session$token` changes every few seconds, making logs unreliable
- D) CSV logs cannot store timestamps
**Answer:** B
**Explanation:** 29.5 warns that a blanket "log every input" habit can accidentally capture sensitive content if a future version adds a free-text or upload field; the fix is to log parameter values and event names only, not everything indiscriminately.

### Q454 [Medium] [Image]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** IMAGE PLACEHOLDER: A comparison table with three columns (shinyapps.io, Posit Connect, Docker + own server) and six rows (setup effort, ongoing maintenance, cost, on-premises data residency, scheduled-reports support, typical IT/governance fit), showing shinyapps.io as minutes of setup with low maintenance and no on-premises data, and Docker+own server as full control but highest maintenance burden. Which deployment route natively supports hosting scheduled Quarto reports alongside a live Shiny explorer on the same server?
- A) shinyapps.io
- B) Posit Connect
- C) Docker + a plain Linux server only
- D) None of the three support scheduled reports
**Answer:** B
**Explanation:** 29.6 states that Posit Connect hosts Shiny apps alongside scheduled Quarto reports using the same mechanism from Chapter 28, letting a live explorer and a weekly automated PDF live on the identical server — a capability the table highlights as distinct from the other two routes.

### Q455 [Hard] [MCQ]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** A discount-rate input is validated with `validate(need(rate >= 0 && rate <= 10, "Discount rate must be between 0% and 10%"))` inside the main results `reactive({})`. A separate `downloadHandler()` reads `input$rate` directly to build the report. What pitfall does the chapter flag here?
- A) `validate()`/`need()` cannot be used with numeric inputs
- B) `validate()`/`need()` only runs inside the reactive expression it's written in, so the unvalidated downloadHandler can let an out-of-range value slip into the downloaded report even though it was blocked on screen
- C) `downloadHandler()` automatically inherits validation from any other reactive in the app
- D) `req()` must be used instead of `validate()` in all cases
**Answer:** B
**Explanation:** 29.7's pitfall is precisely that validation is scoped to the reactive expression it's written in — a separate output reading the same raw input without its own validation can bypass the on-screen check, so the chapter recommends centralising validation rather than repeating ad-hoc per-output checks.

### Q456 [Easy] [Image]
**Chapter(s):** 29 — Interactive Models and Web Applications with Shiny
**Question:** IMAGE PLACEHOLDER: A reactive-dependency diagram showing an input widget (e.g. a slider) feeding into a reactive value, which flows into a reactive({}) expression, which in turn feeds a render*({}) output displayed in the UI, with an observeEvent() shown branching off to trigger a side effect. Which component in this diagram is responsible for producing a cached, auto-updating calculation rather than a one-off side effect?
- A) The input widget itself
- B) `reactive({})`
- C) `observeEvent()`
- D) The UI output element
**Answer:** B
**Explanation:** 29.1 describes `reactive({})` expressions as producing cached, auto-updating calculations driven by reactive inputs, distinct from `observeEvent()`/`observe()`, which exist for triggering side effects rather than returning cached values.


### Q457 [Medium] [MCQ]
**Chapter(s):** 1 -- Introduction to HEOR and HTA
**Question:** Health economics draws on three parent disciplines — welfare economics, demand theory, and public finance. According to the chapter, how does HEOR narrow its focus relative to these broader fields?
- A) HEOR ignores all three disciplines and relies solely on clinical trial statistics
- B) HEOR asks whether one specific intervention is worth paying for compared to an alternative, rather than how a whole health budget should be allocated (public finance) or how price affects overall healthcare demand (demand theory)
- C) HEOR replaces welfare economics entirely with meta-analysis and causal inference methods
- D) HEOR is identical in scope to public finance, just applied to hospitals instead of governments
**Answer:** B
**Explanation:** The difficult-terminology box on "welfare economics, demand theory, public finance" explains that welfare economics judges whether a policy makes society better or worse off, demand theory models how purchases respond to price, and public finance studies government taxation and spending allocation. HEOR borrows selectively from all three but narrows its question to whether *this one* intervention is worth paying for compared to its comparators, rather than system-wide budget allocation or price-demand questions.

### Q458 [Medium] [MCQ]
**Chapter(s):** 3 -- R Essentials for Health Economists
**Question:** In R's S3 object-oriented system, how does a generic function like `print()` know which method to run for a particular object?
- A) R dispatches based on a naming convention, matching the generic to a function named like `print.my_model` according to the object's `class` attribute, with no formal structure enforced
- B) R checks a formally declared class definition that enumerates every required field and its type before dispatching
- C) R compiles a lookup table at package install time mapping every object to a single hard-coded method
- D) R always calls the base method first and only overrides it if the object has no attributes at all
**Answer:** A
**Explanation:** As explained in the "S3 / S4 objects" difficult-terminology box in §3.4, S3 is the older, lightweight OOP system: an object simply carries a `class` attribute (a label), and functions named by convention (e.g. `print.my_model`) are automatically dispatched to when a generic like `print()` is called on an object of that class. There is no formal definition enforced anywhere, which is why S3 is easy to get wrong silently — unlike S4, which requires explicitly declaring a class's required fields and types in advance.

### Q459 [Easy] [MCQ]
**Chapter(s):** 3 -- R Essentials for Health Economists
**Question:** Per §3.2, why does `data.table`'s `DT[i, j, by]` syntax dramatically outperform `dplyr` once a dataset reaches into the millions of rows, such as a national claims database?
- A) It automatically deletes duplicate rows before any computation runs
- B) It relies on an internal C-level radix sort and hash-based grouping, which order and group data far faster than a comparison-based sort at scale
- C) It converts every column to a tibble first, which R can process more quickly than a data.table
- D) It only ever processes a random 10% sample of the rows unless told otherwise
**Answer:** B
**Explanation:** The "radix sort / hash-based grouping" difficult-terminology box in §3.2 explains that `data.table` uses a highly optimized C-level radix sort (ordering data digit/character/byte at a time rather than comparing whole values pairwise, like sorting exam papers into alphabetical piles by letter) plus hash-based grouping (a quick numeric "fingerprint" lookup for the `by =` step) — together making it dramatically faster and more memory-efficient than `dplyr` at claims- or registry-scale data (millions of rows).

### Q460 [Easy] [MCQ]
**Chapter(s):** 4 -- Core Concepts in Health Economics (with R Illustrations)
**Question:** A non-inferiority trial is designed to show which of the following?
- A) That the new treatment is significantly better than the comparator on the primary outcome
- B) That the new treatment is not worse than the comparator by more than a pre-agreed margin
- C) That the new treatment and comparator are exactly, perfectly equal
- D) That the comparator is unsafe and should be withdrawn
**Answer:** B
**Explanation:** Per §4.2's difficult-terminology box, a non-inferiority trial deliberately asks "not meaningfully worse, within a pre-agreed margin" rather than "is it better," and because no finite trial can rule out every conceivable tiny difference, the result is always "not worse by more than margin X," never "identical."

### Q461 [Medium] [MCQ]
**Chapter(s):** 4 -- Core Concepts in Health Economics (with R Illustrations)
**Question:** In a cost-benefit analysis (CBA), if 100,000 people are each willing to pay $50 for a risk reduction expected to prevent one death across that group, what is the implied value-of-a-statistical-life estimate, and what does it represent?
- A) $50 — the price any single identified person's life is worth
- B) $5 million — the price of saving exactly one named individual from certain death
- C) $5 million — the aggregate amount a population puts toward preventing one anonymous, statistical death among them
- D) $100,000 — the number of people whose risk was reduced, used directly as the monetary value
**Answer:** C
**Explanation:** Per §4.2's difficult-terminology box, the VSL is a population-level figure derived by extrapolating aggregate willingness-to-pay (here $50 x 100,000 = $5 million) for a risk reduction expected to prevent one statistical death — it is explicitly not the value of any one real, identified person's life, and CBA uses it to monetize mortality risk reduction alongside other costs and benefits.

### Q462 [Medium] [MCQ]
**Chapter(s):** 4 -- Core Concepts in Health Economics (with R Illustrations)
**Question:** How does the Simpson's-rule variant of half-cycle correction in a Markov model improve on the simple half-cycle correction (averaging only cycle-start and cycle-end occupancy)?
- A) It eliminates the need for discounting entirely
- B) It adds a mid-cycle occupancy point and fits a curved (parabolic) segment through start, mid, and end points instead of a straight line
- C) It replaces the Markov model with a discrete event simulation
- D) It removes the need for a time horizon assumption
**Answer:** B
**Explanation:** Per §4.6's difficult-terminology box, the simple half-cycle correction approximates occupancy with a straight line between cycle-start and cycle-end values, while Simpson's rule also samples the cycle's midpoint and fits a parabolic segment through all three points, tracking a genuinely curving occupancy trend more closely, especially for longer cycles or fast-changing transition probabilities.

### Q463 [Hard] [MCQ]
**Chapter(s):** 4 -- Core Concepts in Health Economics (with R Illustrations)
**Question:** In the chapter's four-treatment `dplyr` frontier pipeline (Standard Care, Drug A, Drug B, Drug C), why is Drug B excluded from the final efficiency frontier table at Step 3, before any ICER is ever computed for it?
- A) Drug B is extendedly dominated by a mix of Drug A and Drug C
- B) Drug B costs more (£5,100) than Drug A (£4,800) while delivering fewer QALYs (0.74 vs 0.81), so it is simply dominated
- C) Drug B's ICER against Standard Care exceeds the willingness-to-pay threshold
- D) Drug B was never included in the original `treatments` tibble
**Answer:** B
**Explanation:** The worked §4.8 example shows `remove_simple_dominance()` dropping Drug B at Step 3 because a cheaper option (Drug A) already delivers equal-or-greater QALYs — textbook simple dominance per §4.7 — so Drug B never receives an ICER and the surviving frontier is Standard Care -> Drug A -> Drug C with rising ICERs of GBP18,947 then GBP30,000.

### Q464 [Easy] [MCQ]
**Chapter(s):** 5 -- Data Sources and Data Management
**Question:** In the ADaM naming convention described in Chapter 5, what is the difference between `TRT01P` and `TRT01A`?
- A) `TRT01P` records planned (as-randomised) treatment while `TRT01A` records actual (as-received) treatment
- B) `TRT01P` is the primary endpoint flag while `TRT01A` is an adverse-event flag
- C) `TRT01P` applies to Phase I trials while `TRT01A` applies to all other phases
- D) `TRT01P` is a population flag while `TRT01A` is a derivation audit code
**Answer:** A
**Explanation:** §5.1 explains that paired ADaM variables like `TRT01P`/`TRT01A` distinguish planned treatment (as randomised) from actual treatment (as received), a distinction that matters for whether a model reflects intention-to-treat versus as-treated/per-protocol assumptions.

### Q465 [Medium] [MCQ]
**Chapter(s):** 5 -- Data Sources and Data Management
**Question:** According to Chapter 5's comparison of real-world data source families, why is administrative claims data considered excellent for costing and utilisation analysis but poor for clinical granularity?
- A) Claims data are generated as a byproduct of the reimbursement process, capturing billing codes (ICD/CPT/HCPCS) rather than direct clinical measurements such as lab values or severity grades
- B) Claims data are collected prospectively around a specific clinical question, so only core outcome variables are recorded
- C) Claims data are stored exclusively in unstructured free text, making numeric cost extraction impossible
- D) Claims data require natural-language processing before any cost information can be retrieved
**Answer:** A
**Explanation:** §5.2 explains that claims data are a byproduct of billing rather than research, giving them excellent scale/completeness for utilisation and costing but no direct clinical detail (no lab values, no severity grades), with diagnosis codes sometimes shaped by reimbursement incentives ("upcoding").

### Q466 [Medium] [MCQ]
**Chapter(s):** 5 -- Data Sources and Data Management
**Question:** Per Chapter 5's pitfall box on `readr`, what hidden failure mode arises from its default column-type guessing behaviour?
- A) It only samples the first 1,000 rows, so a type change (e.g. a numeric ID becoming alphanumeric, or a currency value with a thousands separator) appearing later in the file can silently coerce values to `NA` or character from that point onward
- B) It automatically converts all character columns to factors, which breaks downstream `dplyr` joins
- C) It refuses to import any file exceeding 1,000 rows without an explicit `col_types` argument
- D) It silently drops any column containing a missing value coded as `-99`
**Answer:** A
**Explanation:** The pitfall box in §5.4 warns that `readr`'s type guessing samples only the first 1,000 rows by default, so a late-appearing type change parses cleanly up to that point and then silently coerces afterward — hence the recommendation to always pass explicit `col_types` and inspect `problems()`.

### Q467 [Hard] [MCQ]
**Chapter(s):** 5 -- Data Sources and Data Management
**Question:** In Chapter 5's worked `pointblank`/`assertr`/`validate` example on the `cost_qaly_tbl` (Standard care, New regimen, Combination), which row fails validation, and on how many separate rule checks?
- A) The "Combination" row fails twice: once for a negative cost and once for a utility (QALY) value exceeding 1
- B) The "New regimen" row fails once, for a missing follow-up count
- C) The "Standard care" row fails twice, for both a negative cost and a null strategy value
- D) All three rows fail at least one rule because none have a non-null `n_missing_followup`
**Answer:** A
**Explanation:** §5.6's worked example sets `cost = -340` and `qaly = 1.04` for the "Combination" row; the reporting table shows this row failing both the `cost >= 0` rule and the `qaly <= 1` rule, each with a 66.7% pass rate across the three rows, before any dominance comparison is attempted.

### Q468 [Easy] [Image]
**Chapter(s):** 5 -- Data Sources and Data Management
**Question:** IMAGE PLACEHOLDER: a two-column comparison table mapping data source types (RCT/SDTM-ADaM, Registry, Administrative claims, EHR, Survey, Published literature) against what each is "typically well suited to" versus "typically poorly suited to" as HEOR model inputs. Based on this table from Chapter 5, which data source is identified as typically well suited to supplying health utilities and QALY weights, but poorly suited to objective clinical endpoints or resource-use costing?
- A) Survey data
- B) Administrative claims
- C) Electronic health records (EHR)
- D) Registry data
**Answer:** A
**Explanation:** The source-hierarchy table in §5.2 lists survey data as well suited to "health utilities, QALY weights, patient-reported outcomes" but poorly suited to "resource-use costing, objective clinical endpoints" — consistent with the text's framing of surveys as the structural source of self-reported QALY-generating utility data.

### Q469 [Easy] [MCQ]
**Chapter(s):** 6 -- Systematic Literature Review (SLR) Support in R
**Question:** Per PRISMA-S expectations discussed in §6.1, what should a reproducible search-strategy log (e.g., the `search_log` tibble) record for each database searched?
- A) Only the final combined hit count across all databases
- B) The database name, platform/interface, exact Boolean string, date range, limits applied, and date run
- C) A single "master" Boolean string assumed to be equivalent across all databases
- D) The reviewers' names and their individual screening decisions
**Answer:** B
**Explanation:** §6.1 states that PRISMA-S asks for the database name, platform/interface, full Boolean string, date range, limits applied, and date run for every source searched — not just the final count — and demonstrates this with the `search_log` tibble written to `search_strategy_log.csv`.

### Q470 [Medium] [MCQ]
**Chapter(s):** 6 -- Systematic Literature Review (SLR) Support in R
**Question:** In the chapter's worked screening-agreement example (§6.2), Cohen's kappa for title/abstract agreement between two reviewers is 0.71 despite 96.4% raw percent agreement on 3,198 records. What does the chapter say this illustrates about kappa versus raw percent agreement?
- A) Kappa and percent agreement always give identical results, so either can be reported
- B) Percent agreement is always the more conservative and informative statistic
- C) Kappa corrects for the level of agreement expected by chance alone, so it is more informative than a high percent-agreement figure when most records are easy "obvious excludes"
- D) A kappa of 0.71 indicates near-perfect agreement, stronger than the 96.4% figure suggests
**Answer:** C
**Explanation:** The difficult-terminology box on Cohen's kappa explains that two reviewers who decide mostly at random can still show ~80-90% raw agreement if most records are obvious excludes; kappa strips out that chance-agreement artefact, making 0.71 a "solid but not pristine" result (substantial, per the 0.6-0.8 band) — exactly why 115 conflicts in the table still needed reconciliation.

### Q471 [Hard] [Image]
**Chapter(s):** 6 -- Systematic Literature Review (SLR) Support in R
**Question:** IMAGE PLACEHOLDER: a red/amber/green "traffic light" grid generated by `robvis::rob_traffic_light()` from the chapter's `rob2_data` worked example, with one row per study (Nguyen2021, Alvarez2020, Okafor2022) and one column per RoB 2.0 domain (D1-D5) plus an Overall column. Based on the chapter's §6.5 worked example and required input schema, which column must be present as the final column of the data frame passed to `rob_traffic_light()`/`rob_summary()` for the function calls to work as documented?
- A) A `Notes` column with free-text reviewer comments
- B) A `Weight` column giving each study's weighting, as the last column in the data frame
- C) A `P_value` column from the study's primary analysis
- D) A duplicate `Study` column repeated at the end for alignment
**Answer:** B
**Explanation:** §6.5 explicitly notes that `robvis` expects the weight as the LAST column; the chapter's own revision history recorded that earlier worked `rob2_data`/`robins_data` examples were initially missing this required `Weight` column, which was added after being confirmed against the CRAN reference manual.

### Q472 [Medium] [MCQ]
**Chapter(s):** 7 -- Missing Data
**Question:** Under the ICH E9(R1) estimand framework, a trial defines "treatment success" to include both clinical improvement AND early discontinuation due to side effects, so that a patient who stops treatment early is automatically counted as a treatment failure regardless of their clinical status. Which intercurrent-event strategy does this illustrate?
- A) Treatment-policy strategy
- B) Hypothetical strategy
- C) Composite strategy
- D) Principal-stratum strategy
**Answer:** C
**Explanation:** Per the chapter's difficult-terminology box on ICH E9(R1) intercurrent-event strategies, the composite strategy folds the intercurrent event itself into the definition of the outcome (e.g., "treatment failure" includes both clinical worsening and stopping due to side effects, counted the same way). This differs from treatment-policy (counts whatever happened regardless of discontinuation), hypothetical (asks what would have happened had the intercurrent event not occurred), and principal-stratum (restricts the question to an unobservable subgroup defined by behavior under both treatments).

### Q473 [Medium] [MCQ]
**Chapter(s):** 8 -- Health-Related Quality of Life and Utilities
**Question:** In the context of fitting `lm()` to EQ-5D utility indices via ordinary least squares, what does the homoscedasticity assumption require, and why is it problematic for utility data?
- A) It requires the error scatter around the fitted line to be roughly constant across the predicted range, but utility data are bounded at 1.0 with a ceiling spike and left-skewed tail, so error variance differs across the scale
- B) It requires the outcome variable to be normally distributed with mean zero, which utility data satisfy because EQ-5D scores are symmetric around 0.5
- C) It requires that predictor variables be uncorrelated with one another, a property unrelated to the shape of the utility distribution
- D) It requires residuals to sum to exactly zero across all observations, a condition that beta regression relaxes but ordinary least squares cannot achieve
**Answer:** A
**Explanation:** Section 8.3's difficult-terminology box defines homoscedasticity as the assumption that prediction error scatter is roughly the same magnitude everywhere on the scale (its opposite being heteroscedasticity). The chapter notes EQ-5D utility values are bounded above at 1.0, often spiked at that ceiling, and left-skewed with a long tail toward poor health states — meaning error variance is unlikely to be constant, making ordinary least squares `lm()` a theoretically poor choice for the mapping literature's common practice of fitting it directly to utility indices.

### Q474 [Easy] [MCQ]
**Chapter(s):** 9 -- Costs and Resource Use
**Question:** Per Chapter 9's difficult-terminology box, what makes a "leverage point" in a cost dataset especially dangerous compared to an outlier in a bounded utility score?
- A) Leverage points only occur when costs are measured with missing data
- B) Because cost has no upper bound, a single extreme value can drag the sample mean up without any ceiling limiting the damage, unlike a utility bounded near 1
- C) Leverage points are always caused by data-entry errors and should simply be deleted
- D) Leverage points affect the median far more than the mean, which is why trimmed means are avoided
**Answer:** B
**Explanation:** The chapter's "leverage points" box explains that a single isolated extreme cost value (e.g. one prolonged ICU admission for drug-resistant TB) can disproportionately pull the mean upward because, unlike a beta-distributed utility bounded on roughly [0,1], cost is unbounded above, so there is no ceiling limiting how much one leverage point can distort the average — and therefore an ICER built on that mean.

### Q475 [Medium] [MCQ]
**Chapter(s):** 9 -- Costs and Resource Use
**Question:** According to Chapter 9's difficult-terminology box, how does a bootstrapped estimate quantify the uncertainty around a statistic like a mean cost, without relying on a normal-distribution assumption?
- A) It repeatedly draws new samples of the same size from the original data, with replacement, recalculates the statistic each time, and uses the spread of those recalculated values as the uncertainty estimate
- B) It fits a gamma distribution to the positive costs and derives a standard error algebraically from the fitted parameters
- C) It removes the top and bottom 5% of cost values before computing a single trimmed mean
- D) It draws one additional patient at random and recomputes the mean with that patient added
**Answer:** A
**Explanation:** The chapter describes bootstrapping as resampling the original sample with replacement thousands of times, computing the statistic (e.g. the mean) on each resample, and using the spread of that collection of means as the uncertainty estimate — a non-parametric alternative suited to cost data's skewed, non-normal distribution.

### Q476 [Medium] [MCQ]
**Chapter(s):** 9 -- Costs and Resource Use
**Question:** Chapter 9 describes step-down allocation as a sequential hospital/programme cost-accounting technique. Which department is allocated first in the sequence, and on what basis?
- A) The clinical service line treating the most patients, allocated based on patient outcomes
- B) The department that provides services to the most other departments but receives services from none in return (e.g. general administration), allocated out using a driver like floor space, staff headcount, or visit counts
- C) The department with the single largest annual budget, allocated proportionally to total programme expenditure
- D) All departments simultaneously, divided evenly regardless of how many other departments they serve
**Answer:** B
**Explanation:** Per the chapter's "step-down allocation" box, the technique starts with the department that serves the most other departments but is served by none (e.g. general administration), allocates its cost out using a sensible driver, then moves step-by-step to the next department until every shared overhead has been pushed down to the clinical service lines — used in the chapter's hybrid costing example to allocate TB programme overheads top-down while drugs/tests are micro-costed bottom-up.

### Q477 [Easy] [MCQ]
**Chapter(s):** 10 -- Survival Analysis for Economic Evaluation
**Question:** In §10.1, what is the key distinction the chapter draws between the Kaplan-Meier estimator and classical actuarial life tables?
- A) The KM estimator can only be stratified by treatment arm, while life tables can include any covariate
- B) The KM estimator recalculates conditional survival probabilities at exact event times, while life tables group events into fixed intervals
- C) Life tables require `flexsurv`, while the KM estimator only requires base R
- D) The KM estimator assumes a constant hazard, while life tables allow the hazard to vary
**Answer:** B
**Explanation:** §10.1 describes life tables (actuarial estimators) as the discrete-time cousin of the KM estimator, grouping events into fixed intervals (e.g. yearly) rather than recalculating at the exact event times the KM estimator uses — the latter is almost always preferred in HEOR work because source data are individual patient data, not grouped registry counts.

### Q478 [Medium] [MCQ]
**Chapter(s):** 10 -- Survival Analysis for Economic Evaluation
**Question:** According to §10.2, which of the six standard `flexsurvreg()` distributions is described as nesting the exponential, Weibull and log-normal as special cases?
- A) Gompertz
- B) Log-logistic
- C) Generalised gamma
- D) Exponential
**Answer:** C
**Explanation:** §10.2 describes the generalised gamma (`dist = "gengamma"`) as a flexible three-parameter family that nests exponential, Weibull and log-normal as special cases, useful as an umbrella comparison model at the cost of being harder to interpret and sometimes unstable to fit with sparse data.

### Q479 [Medium] [MCQ]
**Chapter(s):** 10 -- Survival Analysis for Economic Evaluation
**Question:** In `flexsurv::flexsurvspline()` (§10.3), what happens when the model is fitted with `k = 0` internal knots?
- A) The model fails to converge because at least one knot is required
- B) It collapses to one of the standard parametric families, depending on the `scale = ` argument
- C) It automatically selects the knot count that minimises AIC
- D) It becomes equivalent to a Cox proportional hazards model
**Answer:** B
**Explanation:** §10.3 states that `k = 0` (zero internal knots) collapses to one of the standard parametric families depending on the `scale = ` argument (`"hazard"`, `"odds"`, or `"normal"` -- defaulting to the Weibull-equivalent on the hazard scale), making it a useful baseline before adding flexibility.

### Q480 [Hard] [MCQ]
**Chapter(s):** 10 -- Survival Analysis for Economic Evaluation
**Question:** §10.4 contrasts the mixture and non-mixture cure model forms fitted by `flexsurvcure::flexsurvcure()`. Which statement correctly distinguishes them?
- A) The mixture form models S(t) = pi^(1-S_u(t)); the non-mixture form models S(t) = pi + (1-pi) x S_u(t)
- B) The mixture form models S(t) = pi + (1-pi) x S_u(t), an explicit blend of cured and uncured survival; the non-mixture form models S(t) = pi^(1-S_u(t)), arising from a latent-process generative story
- C) Both forms are mathematically identical and differ only in computational implementation
- D) The mixture form can only include covariates on the cure fraction, while the non-mixture form can only include covariates on the uncured survival
**Answer:** B
**Explanation:** §10.4 gives the mixture form as S(t) = pi + (1-pi) x S_u(t), an explicit blend read directly as "proportion cured," and the non-mixture form as S(t) = pi^(1-S_u(t)), arising from a different generative story (a latent number of malignant/infectious cells, each with independent elimination probability) more common in oncology cure-modelling traditions.

### Q481 [Medium] [MCQ]
**Chapter(s):** 10 -- Survival Analysis for Economic Evaluation
**Question:** §10.7 describes `survival::cox.zph()` as testing proportional hazards via scaled Schoenfeld residuals. According to the chapter's pitfall note, what is a key limitation of a non-significant `cox.zph()` result?
- A) It proves the PH assumption holds with certainty
- B) It is merely absence of evidence, since the test has low power in small or heavily censored trials -- exactly the oncology trials HEOR models often rely on
- C) It only applies to the `arm` covariate and cannot be interpreted for other covariates like age
- D) It indicates the Schoenfeld residuals were not computed correctly
**Answer:** B
**Explanation:** §10.7's pitfall states that a non-significant `cox.zph()` test is not proof of PH -- it is merely absence of evidence, with low power in small or heavily censored trials, while conversely very large samples can flag trivial, clinically irrelevant trends as significant.

### Q482 [Hard] [MCQ]
**Chapter(s):** 10 -- Survival Analysis for Economic Evaluation
**Question:** §10.10 distinguishes the cause-specific hazard from the subdistribution (Fine-Gray) hazard in competing-risks analysis. Why does the chapter say the subdistribution hazard / cumulative incidence function is usually the quantity a cost-effectiveness model wants?
- A) It is computationally faster to estimate than the cause-specific hazard
- B) It treats competing events as censoring, simplifying the risk set
- C) It keeps patients who experienced a competing event in the risk set and directly models the actual probability mass flowing into each state, rather than a hypothetical hazard in a world without competing events
- D) It is the only hazard type supported by the `mstate` package
**Answer:** C
**Explanation:** §10.10 explains the subdistribution hazard keeps patients who had the competing event in the risk set (as if destined never to have the event of interest) and directly models the cumulative incidence function -- the model needs the actual probability mass flowing into each state, not a hypothetical cause-specific hazard that assumes competing events don't happen.

### Q483 [Hard] [Image]
**Chapter(s):** 10 -- Survival Analysis for Economic Evaluation
**Question:** IMAGE PLACEHOLDER: a diagram showing the extrapolated hazard function (not survival) for a standard Weibull fit versus a one-knot Royston-Parmar spline, fitted to the same simulated trial data, tracking closely within the observed 0-36 month follow-up but diverging sharply once extrapolated. Per §10.12's discussion of TSD 21, why does this hazard-scale plot reveal something an extrapolated survival-scale plot alone would hide?
- A) Hazard plots are easier to digitize for IPD reconstruction than survival plots
- B) TSD 21 requires the extrapolated hazard function to be shown because a spline model can fit the observed KM curve closely while behaving erratically once extrapolated, a divergence that is often obscured on the smoother cumulative survival scale
- C) The hazard scale is the only scale on which AIC and BIC can be validly compared
- D) Survival curves cannot be extrapolated at all, only hazard functions can
**Answer:** B
**Explanation:** §10.12 states TSD 21 is explicit that flexible methods trade extrapolation parsimony for in-sample fit, and asks for the extrapolated hazard function to be shown, not just the extrapolated survival curve, because divergence between models is easier to spot on the hazard scale than on the cumulative, smoother survival scale.

### Q484 [Medium] [MCQ]
**Chapter(s):** 10 -- Survival Analysis for Economic Evaluation
**Question:** In §10.11, what is the critical extra ingredient that the Guyot et al. (2012) algorithm (implemented in `IPDfromKM`) uses, beyond the digitized Kaplan-Meier curve coordinates, to reconstruct individual patient data?
- A) The trial's original CONSORT diagram
- B) The numbers-at-risk table printed beneath the curve, which anchors how many individuals are censored versus experiencing events between intervals
- C) The p-value from the trial's log-rank test
- D) A separately published hazard ratio for the comparator arm
**Answer:** B
**Explanation:** §10.11 explains that the numbers-at-risk table is the critical extra ingredient the KM figure alone does not provide, because it anchors how many individuals are being censored versus experiencing events between risk-table intervals, letting the algorithm back-solve the KM product-limit formula in reverse.

### Q485 [Easy] [MCQ]
**Chapter(s):** 10 -- Survival Analysis for Economic Evaluation
**Question:** Per §10.9, how should background (general-population) mortality be used when extrapolating a disease-specific survival curve over a lifetime horizon?
- A) As a soft benchmark reported only in a scenario analysis, never applied to the base case
- B) As a hazard floor applied at every model cycle, via `pmax(disease_hazard, bg_hazard)`, so predicted survival never falls below the general-population curve for the matching age-sex strata
- C) As a replacement for the parametric model once the trial's follow-up window ends
- D) Only to validate the cure fraction in a `flexsurvcure()` model
**Answer:** B
**Explanation:** §10.9 states that background mortality becomes a constraint, not just a convenience: a national life table sets the ceiling on hazard via `combined_hazard <- pmax(disease_hazard, bg_hazard)`, applied at every model cycle rather than only at the point where extrapolation begins.

### Q486 [Easy] [MCQ]
**Chapter(s):** 11 -- Meta-Analysis
**Question:** In `metabin()`, setting `method = "MH"` selects the Mantel-Haenszel method for pooling. How does this method combine 2x2 tables from several studies?
- A) It averages each study's own calculated risk ratio, giving every study equal weight
- B) It works directly from the raw event counts, weighting each study roughly by how much statistical information (events) it contributed
- C) It discards studies with fewer than 5 events before pooling
- D) It transforms every study's odds ratio onto the log scale and then takes a simple arithmetic mean
**Answer:** B
**Explanation:** The chapter's difficult-terminology box explains that the Mantel-Haenszel method works directly from raw event counts rather than averaging per-study ratios, weighting each study by its contributed "information" (e.g., a study with 200 events pulls the pooled estimate harder than one with 5), likening it to computing a batting average from total runs/innings rather than averaging season averages. It is specifically a fixed-effect pooling method.

### Q487 [Medium] [MCQ]
**Chapter(s):** 11 -- Meta-Analysis
**Question:** Section 11.2 states that the Q-statistic, if there were truly no heterogeneity, would follow a known chi-squared distribution with k-1 degrees of freedom. What does a Q value that is large relative to this reference distribution indicate?
- A) That the pooled effect estimate is biased and should not be reported
- B) That the studies disagree with each other by more than chance alone would explain, i.e., genuine heterogeneity
- C) That the fixed-effect model must be abandoned in favour of the Mantel-Haenszel method
- D) That I-squared cannot be calculated for this dataset
**Answer:** B
**Explanation:** The chi-squared distribution box explains it is the "yardstick" for the Q-statistic: if all studies truly estimated the same effect, Q would behave like a draw from a chi-squared distribution with k-1 df. An observed Q larger than this reference distribution would typically produce is evidence that disagreement between studies exceeds chance, i.e., genuine heterogeneity -- the same logic as a chi-squared test comparing observed vs. expected counts.

### Q488 [Medium] [MCQ]
**Chapter(s):** 11 -- Meta-Analysis
**Question:** `mada::reitsma()` fits a bivariate model for diagnostic test accuracy data, described in the chapter as a generalised linear mixed model operating on logit-sensitivity/logit-specificity pairs. In this model, what do the "random" effects represent, and what does "generalised" refer to?
- A) Random effects represent measurement error in the reference standard; "generalised" means the model ignores study-level clustering
- B) Random effects let each study's true sensitivity and specificity wobble around a shared overall pair of values; "generalised" means the outcome is modelled on a logit-transformed, bounded scale rather than as a plain continuous normal variable
- C) Random effects are the fixed overall sensitivity and specificity; "generalised" means the model uses ordinary least squares instead of maximum likelihood
- D) Random effects represent random sampling of which studies to include; "generalised" means the SROC curve is drawn using random thresholds
**Answer:** B
**Explanation:** The difficult-terminology box explains a mixed model combines fixed effects (shared overall parameters, e.g. average sensitivity) with random effects (study-specific wobble around that average, with the wobble size estimated from data). "Generalised" means the outcome need not be continuous/normal -- here it is a logit-transformed, bounded proportion (sensitivity/specificity), the same logit-link trick used elsewhere in the book, letting `reitsma()` borrow strength across studies while respecting threshold differences.

### Q489 [Medium] [MCQ]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** The `netmeta` package's graph-theoretical frequentist NMA solves the network's weighted least-squares system using a Moore-Penrose pseudoinverse of a "Laplacian-type matrix." Why is this generalised inverse needed instead of an ordinary matrix inverse?
- A) Because the network's Laplacian-type matrix is not square and well-behaved in the way ordinary matrix inversion requires, since a network with indirect evidence routes has more than one algebraically valid way of distributing information between treatments
- B) Because JAGS cannot compute ordinary matrix inverses and `netmeta` must match its numerical routines
- C) Because odds ratios cannot be inverted algebraically, only hazard ratios can
- D) Because the pseudoinverse is required only when a network contains more than four treatments
**Answer:** A
**Explanation:** Per §12.3.1's difficult-terminology box, ordinary matrix inversion only works on square, well-behaved matrices, but a treatment network's system of equations is not well-behaved in that sense when indirect routes exist. The Moore-Penrose pseudoinverse still produces a single least-squares answer, analogous to solving for voltage at every node of an electrical resistor network (the "electrical network" approach to NMA).

### Q490 [Hard] [MCQ]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** In the electrical-circuit analogy used to explain `netmeta`'s graph-theoretical NMA method, what does a small, imprecise trial correspond to in the circuit?
- A) A high-resistance wire connecting the two treatment nodes it compares
- B) A node with no outgoing edges
- C) A short circuit between the reference treatment and every other node
- D) A capacitor storing between-study heterogeneity
**Answer:** A
**Explanation:** The §12.3.1 difficult-terminology box explains that treatments are nodes, trials are wires, and "resistance" corresponds to each trial's imprecision -- small, imprecise trials act like high-resistance wires, consistent with the mathematics of solving for voltage at every node of a circuit.

### Q491 [Medium] [MCQ]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** According to the chapter's difficult-terminology explanation, what is the key practical difference between the generalized gamma and generalized F distributions when fitting flexible survival curves in `flexsurv`?
- A) The generalized gamma can mimic exponential, Weibull, or log-normal shapes depending on its shape parameters, while the generalized F is even more flexible, adding a further parameter on top
- B) The generalized gamma is only usable for binary outcomes, while the generalized F is exclusively for continuous outcomes
- C) The generalized F distribution cannot be fit using `flexsurv` and requires a separate Bayesian package
- D) The generalized gamma assumes proportional hazards while the generalized F explicitly rejects that assumption
**Answer:** A
**Explanation:** Per §12.7's difficult-terminology box, the generalized gamma family contains exponential, Weibull, and log-normal as special cases depending on its extra shape parameters, while the generalized F adds a further parameter on top for even greater flexibility -- at the cost of needing more data to estimate reliably and a greater risk of implausible extrapolations.

### Q492 [Easy] [MCQ]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** Per the chapter's difficult-terminology box, what trade-off do analysts accept when choosing a flexible model like the generalized gamma or generalized F over a simpler parametric survival curve?
- A) These flexible families need more data to estimate their extra parameters reliably and are more prone to implausible long-term extrapolations when fitted to short follow-up
- B) They cannot be compared against simpler models using any information criterion
- C) They require individual patient data and cannot be fit to aggregate data at all
- D) They can only be used within a network meta-analysis, never for a single trial arm
**Answer:** A
**Explanation:** The chapter states these flexible families are "best used as a model-selection safety net (checking whether a simpler curve is good enough) rather than a default first choice," precisely because their added flexibility trades off against data requirements and extrapolation risk.

### Q493 [Medium] [MCQ]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** What does "exchangeability," as defined in the chapter's difficult-terminology box, formally require before several studies can be validly pooled together?
- A) That, once measured/adjusted-for differences are accounted for, there is no remaining systematic reason to treat any one study's true effect as fundamentally different in kind from any other's -- the studies' identities could be relabelled without needing to change the model
- B) That every study in the network directly compares the same pair of treatments
- C) That all studies report their outcomes on an identical numeric scale (e.g. all odds ratios, never hazard ratios)
- D) That the between-study variance tau-squared is estimated as exactly zero
**Answer:** A
**Explanation:** The §12.7 difficult-terminology box defines exchangeability using the classroom-averaging analogy: once known differences are adjusted for, any remaining apparent difference between studies should be attributable to random noise rather than a hidden structural gap -- otherwise pooling risks combining numbers that "simply don't belong together."

### Q494 [Hard] [MCQ]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** A Royston-Parmar spline model, as described in the chapter's difficult-terminology box, differs from standard parametric survival models (exponential, Weibull) in which specific way?
- A) It fits a flexible curve built from smoothly-joined spline pieces to the log cumulative hazard over time, with the number of knots chosen by the analyst as a flexibility-versus-overfitting trade-off, rather than assuming one fixed formula for the whole curve
- B) It assumes the hazard ratio between treatments is constant over all follow-up time by construction
- C) It can only be fit using a Bayesian engine such as JAGS or Stan, never `flexsurv`
- D) It requires individual patient-level covariate data and cannot be fit to a single trial arm alone
**Answer:** A
**Explanation:** Per the §12.7 difficult-terminology box, the Royston-Parmar model is described as being "built out of smoothly-joined pieces (splines)" fit to the log cumulative hazard, likened to a flexible French curve, with the number of knots trading off flexibility against over-fitting -- and the chapter's own code example fits it in R using `flexsurvspline()` with `k = 2` knots.

### Q495 [Medium] [MCQ]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** In the Bucher method worked example (Regimen A vs C: log HR = -0.52, SE = 0.18; Regimen B vs C: log HR = -0.28, SE = 0.21), what is the correct computation of the indirect A-vs-B standard error, and why is this operation the one most commonly got wrong?
- A) SE = sqrt(0.18^2 + 0.21^2) ~ 0.277 -- the variances of the two independent trial estimates must be added, even though the point estimates themselves are combined by subtraction, because Var(X - Y) = Var(X) + Var(Y) for independent X and Y
- B) SE = 0.21 - 0.18 = 0.03, because standard errors subtract in the same direction as the point estimates
- C) SE = sqrt(0.18^2 - 0.21^2), producing a negative value that is then treated as zero
- D) SE = (0.18 + 0.21) / 2 = 0.195, the simple average of the two component standard errors
**Answer:** A
**Explanation:** Per §12.2.2's pitfall box, the single most common manual error is subtracting the two variances by analogy with the point-estimate subtraction; the correct operation is always addition, because the two trials are independent sources of uncertainty and the minus sign affects only the expectation, not the variance. The worked example in §12.2.3 confirms SE ~ 0.2767.

### Q496 [Easy] [MCQ]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** Per §12.1's pitfall box, why is it invalid to compare the absolute outcomes of two unrelated trials directly (e.g., "Trial 1 found 78% cure with Regimen A, Trial 2 found 71% cure with Regimen B, therefore A is better")?
- A) This "naive" indirect comparison destroys randomisation and is highly vulnerable to confounding by differences in baseline risk, trial era, region, and outcome definition between the two trials
- B) Percentages can never be compared across two different trials under any circumstances
- C) It is technically valid but merely considered bad style by NICE DSU TSD 2
- D) It is invalid only when the two trials use different sample sizes
**Answer:** A
**Explanation:** The chapter explicitly flags naive/unadjusted cross-trial comparison as invalid practice per NICE DSU TSD 2 (Dias et al. 2011) because it discards the comparability of patient populations that randomisation was designed to protect, and will not be accepted as a primary HTA analysis.

### Q497 [Easy] [MCQ]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** In `netmeta::netrank()`, what does the `small.values` argument control, and what is the consequence of setting it incorrectly?
- A) It specifies whether a smaller outcome value represents a better treatment ("good") or a worse one ("bad"); getting it backwards silently inverts the entire treatment ranking with no error thrown
- B) It sets the minimum number of studies required before a treatment can be ranked, and setting it too low raises a convergence error
- C) It controls the number of MCMC iterations retained for the P-score calculation, and setting it incorrectly only affects runtime
- D) It specifies the smallest edge-weight threshold below which a comparison is dropped from the league table, with no effect on rankings
**Answer:** A
**Explanation:** Per §12.3.5's pitfall, `small.values` must match the direction of the outcome scale ("good" when smaller is better, e.g. a hazard ratio for treatment failure); `netrank()` has no way to infer this from the data, so getting it backwards silently inverts the ranking without any error.

### Q498 [Medium] [MCQ]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** A network meta-analysis finds that trials with a higher mean baseline severity (a study-level covariate) show larger treatment effects. According to the §12.6 pitfall on ecological bias, what can this finding reliably be interpreted to mean?
- A) Nothing reliable about whether an individual high-severity patient does better on the treatment than an individual low-severity patient within the same trial -- that is a different quantity, and confusing an across-study aggregate relationship with a within-trial patient-level effect is the single most common error in reviewing network meta-regressions
- B) That every individual patient with higher baseline severity in every trial responds better to treatment than lower-severity patients in that same trial
- C) That the covariate should immediately be dropped from the model because any significant regression coefficient in an NMA indicates a coding error
- D) That the finding proves the network violates the consistency assumption and should not be reported at all
**Answer:** A
**Explanation:** The §12.6 pitfall states this is "precisely the situation Chapter 13 exists to address properly": a study-level covariate is an aggregate summary of enrolled patients, not a patient-level measurement, so an across-study regression relationship cannot be read as the within-trial, patient-level effect of the same characteristic -- an ecological-bias error that is "arguably more urgent" at network level than in pairwise meta-regression.

### Q499 [Medium] [Image]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** IMAGE PLACEHOLDER: A rankogram (stacked bar chart) for a four-treatment network (A, B, C, D), showing each treatment's probability of occupying rank 1 (best) through rank 4 (worst) on treatment failure, with Treatment A showing the largest probability mass at rank 1, followed in order by B, D, and C. Based on the chapter's §12.8 description of this exact figure, which statement correctly matches the ranking shown?
- A) Treatment A has the highest probability of being ranked best, consistent with the P-scores reported in the chapter's SUCRA/P-score table, where A also had the top P-score of 0.92
- B) Treatment C has the highest probability of being ranked best, since it is the reference/standard-of-care comparator anchoring the network
- C) All four treatments show an identical, flat probability distribution across every rank, indicating the network could not distinguish between them
- D) Treatment D has the highest probability of being ranked best, as it was the most recently added regimen to the network
**Answer:** A
**Explanation:** Per §12.8's figure caption and the accompanying §12.3.5/§12.8 P-score table, Treatment A has the highest probability mass at rank 1 and the top P-score (0.92), followed by B (0.67), D (0.32), and C (0.08) -- consistent across both the rankogram and the P-score ranking derived from the same worked arm-level TB data.

### Q500 [Medium] [MCQ]
**Chapter(s):** 13 -- Population-Adjusted Indirect Comparisons
**Question:** In the context of STC's non-collapsibility pitfall, a fitted logistic regression model is used to "predict the treatment effect" by plugging in the AgD trial's reported mean covariate values (e.g., age = 61.4, severity index = 2.1). What kind of treatment effect does this produce, and why is it problematic for an indirect comparison?
- A) It produces a marginal effect, which is exactly what the AgD trial reports, so plugging in the means is the correct approach
- B) It produces a conditional effect at those specific covariate values, which on a nonlinear (odds-ratio) scale differs from the marginal/population-average effect the AgD trial actually reports, even under a correctly specified model
- C) It produces an unbiased estimate of the marginal effect only because logistic regression is linear in the covariates
- D) It produces no usable effect at all, since logistic regression coefficients cannot be evaluated at specific covariate values
**Answer:** B
**Explanation:** Per the §13.3 difficult-terminology box, a conditional effect is the treatment effect for patients sharing one specific set of covariate values (read off the fitted regression at those values), while a marginal effect is averaged across the whole population's covariate mix -- the quantity an aggregate-data trial's reported odds ratio or hazard ratio represents. On nonlinear scales these differ even with a perfectly specified model (non-collapsibility); plugging in covariate means yields only the conditional effect, biasing the comparison unless the full simulation-and-averaging step is performed.

### Q501 [Easy] [MCQ]
**Chapter(s):** 14 -- Bayesian Methods for HEOR
**Question:** In a conventional (non-Bayesian) PSA workflow, what is the "fiddly" manual step typically needed to impose correlation between parameters (e.g. cost and utility) that are drawn independently, which a Cholesky decomposition is the standard recipe for?
- A) Rounding each draw to the nearest whole number before use
- B) Combining independent random draws into a new set of draws with a specified correlation structure baked in
- C) Converting all parameters to the same measurement units
- D) Discarding draws that fall outside the 95% confidence interval
**Answer:** B
**Explanation:** §14.6 explains that a Cholesky decomposition breaks a correlation/covariance matrix into a "square root" matrix that, when multiplied by independent random draws, produces a new vector with the desired correlation structure -- the standard way to "inject" correlation into otherwise-independent simulated numbers for a conventional PSA.

### Q502 [Medium] [MCQ]
**Chapter(s):** 14 -- Bayesian Methods for HEOR
**Question:** Per the chapter's §14.6 discussion, why does using posterior MCMC draws directly as a PSA sample avoid the need for a Cholesky decomposition, even though PSA parameters such as treatment effects are typically correlated?
- A) MCMC draws are always independent of each other, so no correlation step is ever needed
- B) Each row of the joint posterior sample already comes out with the correct correlations intact, so there is nothing left to "inject"
- C) Cholesky decomposition only applies to cost parameters, not treatment effects
- D) Bayesian models do not produce correlated parameters, only frequentist models do
**Answer:** B
**Explanation:** The chapter states that a genuine Bayesian joint posterior sample sidesteps the fiddly Cholesky step entirely "because the posterior draws already come out correlated correctly without needing any decomposition trick" -- each row of the posterior sample is one coherent, correctly-correlated PSA iteration.

### Q503 [Hard] [MCQ]
**Chapter(s):** 14 -- Bayesian Methods for HEOR
**Question:** A hierarchical NMA model shows R-hat of 1.00 on every parameter but an effective sample size (ESS) of only 150 for a key treatment-effect parameter, with zero divergent transitions reported. According to §14.4's diagnostic guidance, what is the correct interpretation and next step?
- A) The model is fully trustworthy because R-hat below 1.01 is the only diagnostic that matters
- B) The chains have converged to the same region but are mixing slowly within it, so the model should be run longer or reparameterised despite the good R-hat, since ESS below roughly 400 is a trigger for action
- C) The low ESS indicates the sampler encountered funnel-shaped geometry, so divergent transitions must be present even though none were reported
- D) ESS and R-hat always move together, so this combination of results is impossible and indicates a software bug
**Answer:** B
**Explanation:** §14.4 explicitly warns that a chain "can have excellent R-hat and still unusable ESS if it mixes slowly within a converged region" -- a distinct failure mode -- and gives the rule of thumb that ESS below roughly 400 (combined across chains) for any parameter to be reported should trigger running the model longer or reparameterising it, regardless of how good R-hat looks.

### Q504 [Hard] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** In a TB real-world evidence study of culture conversion, some patients switch to rescue medication partway through follow-up (an intercurrent event). Under the ICH E9(R1) estimand framework described in the chapter, which strategy explicitly asks "what would have happened if the intercurrent event had not occurred at all"?
- A) Treatment-policy
- B) Hypothetical
- C) Composite
- D) While-on-treatment
**Answer:** B
**Explanation:** The chapter's difficult-terminology box on "ICH E9(R1) estimand strategies + intercurrent events" defines the hypothetical strategy as asking what would have happened if the intercurrent event hadn't occurred, distinct from treatment-policy (counts whatever happens regardless of switching), composite (folds the event into the outcome definition), and while-on-treatment (only considers the pre-event period).

### Q505 [Medium] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** A TB clinician informally senses a patient is sicker than any recorded covariate captures and, on that gut feeling alone, escalates them to a stronger regimen. According to the chapter's discussion of endogeneity, what happens if a plain regression of outcome on regimen is then fitted?
- A) The estimate remains unbiased because regimen status is fully observed in the data
- B) The regimen variable becomes endogenous, and the regression attributes some of the unmeasured severity's effect to the regimen itself, biasing the estimate
- C) Nutrition becomes a confounder instead of a mediator
- D) The parallel trends assumption for difference-in-differences is violated
**Answer:** B
**Explanation:** The "endogeneity / endogenous variable" box uses exactly this example: when a hidden factor (clinician gut-feel severity) drives both treatment and outcome, the treatment variable is "tangled up" with it, so a plain regression misattributes the hidden factor's effect to treatment -- the problem instrumental variables are built to sidestep.

### Q506 [Medium] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** An analyst runs `summary(iv_fit, diagnostics = TRUE)` on an `ivreg()` model and obtains a statistically significant Wu-Hausman test result. What does this result most directly indicate?
- A) The instrument is weak, with a first-stage F-statistic below 10
- B) The OLS and 2SLS estimates disagree by more than chance would explain, suggesting the plain OLS estimate is biased by unmeasured confounding and the IV estimate should be trusted instead
- C) The exclusion restriction has been formally proven to hold
- D) There are more instruments than endogenous regressors, triggering an over-identification check
**Answer:** B
**Explanation:** The "Wu-Hausman test" box states it compares the OLS and 2SLS estimates of the same effect; a significant result means they disagree more than chance explains, evidence the OLS estimate is biased and the (noisier) IV estimate should be preferred.

### Q507 [Hard] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** An IV model for TB regimen effect uses two instruments (distance to facility and facility rollout quarter) for one endogenous treatment variable, making the model over-identified. The Sargan test returns a significant p-value. What can be correctly concluded?
- A) Both instruments are definitively invalid and must both be discarded
- B) The instrument set is weak, and 2SLS will be biased toward the OLS estimate
- C) At least one instrument in the set likely violates its exclusion restriction, though the test cannot identify which one specifically
- D) The treatment variable is not actually endogenous, so plain OLS should be used instead
**Answer:** C
**Explanation:** The "Sargan (over-identification) test" box explains the test is only possible when instruments outnumber endogenous regressors, and a significant result is "a warning sign that at least one of your instruments may not be valid -- though it can't tell you which one, only that something in the set is inconsistent with the others."

### Q508 [Easy] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** Per the FDA's real-world data guidance described in §15.1, what two-part test determines whether a real-world data source is fit for purpose for a regulatory or HTA decision?
- A) Internal validity and external validity
- B) Relevance and reliability
- C) Sensitivity and specificity
- D) Completeness and timeliness
**Answer:** B
**Explanation:** §15.1 states the FDA's 2023 guidance "sets out a two-part test... is the data relevant to the clinical question... and is it reliable (accurate, complete, traceable, with transparent provenance)," which the EMA's DARWIN EU initiative mirrors as "data quality and study design robustness."

### Q509 [Medium] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** In the chapter's target trial emulation code example, the `time_zero` column is set equal to `regimen_start` rather than `diagnosis_dt`. Why?
- A) `regimen_start` always occurs earlier, maximizing available follow-up time
- B) Using `diagnosis_dt` as time zero would include person-time before treatment actually began, reintroducing immortal time bias
- C) WHO treatment-outcome definitions require diagnosis dates to be excluded from any TTE analysis
- D) `regimen_start` is a mandatory input for `dagitty::adjustmentSets()`
**Answer:** B
**Explanation:** §15.2 explains that setting `time_zero` to `regimen_start` (not `diagnosis_dt`) "avoids immortal time bias" by ensuring eligibility, exposure assignment, and follow-up all begin simultaneously, as target trial emulation requires.

### Q510 [Medium] [Image]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** IMAGE PLACEHOLDER: A two-panel figure. The left panel shows a DAG built with `ggdag::dagify()` for a TB regimen comparison, with nodes Regimen, Tx success, HIV status, Nutrition (mediator), Site capacity, and Urban site; arrows run from HIV status and Site capacity into Regimen; from Regimen, HIV status, Nutrition, and Site capacity into Tx success; from Regimen into Nutrition; and from Urban site into Site capacity. The right panel shows the same DAG with two nodes highlighted red, representing the output of `ggdag_adjustment_set()`. Based on `dagitty::adjustmentSets()` applied to this DAG (exposure = regimen, outcome = success), which two nodes should be highlighted red as the minimal sufficient adjustment set?
- A) HIV status and Site capacity
- B) HIV status and Nutrition
- C) Nutrition and Urban site
- D) Site capacity and Urban site
**Answer:** A
**Explanation:** §15.3 states that running `adjustmentSets()` on this exact DAG "returns `{hiv, site_capacity}` as the minimal sufficient set," while Nutrition is correctly excluded because it is a mediator (on the causal pathway from regimen to success), not a confounder.

### Q511 [Easy] [Image]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** IMAGE PLACEHOLDER: A love plot for a toy TB cohort (n = 600) showing absolute standardized mean differences (SMD) for several baseline covariates and the propensity score itself, plotted as red dots (unadjusted) and teal dots (after inverse-probability-of-treatment weighting), with a dashed vertical reference line. Based on the conventional balance threshold used throughout §15.4, at what SMD value is that dashed reference line drawn?
- A) 0.01
- B) 0.1
- C) 0.5
- D) 1.0
**Answer:** B
**Explanation:** §15.4 states "SMDs below 0.1 for every covariate is the conventional threshold for 'good balance,'" and the love plot figure caption describes covariates collapsing "from well above the conventional 0.1 threshold (dashed line) to effectively zero after weighting."

### Q512 [Hard] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** Using the chapter's toy IPTW cohort -- treated patients with outcomes Y = 10, 8, 12 and propensity scores e(x) = 0.5, 0.4, 0.6, and control patients with outcomes Y = 4, 6, 2 and the same respective propensity scores -- what is the resulting IPTW estimate of the average treatment effect (in weeks)?
- A) 3.833
- B) 6.167
- C) 10.000
- D) 2.333
**Answer:** B
**Explanation:** §15.4's worked example sums treated contributions (20+20+20=60, mean 10.000) and control contributions (8+10+5=23, mean 3.833), giving the IPTW estimate = 10.000 - 3.833 = 6.167 weeks, confirmed by the reproducible R snippet returning 6.166667.

### Q513 [Medium] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** Why does the chapter describe doubly robust (DR) estimators like AIPW as removing a "single point of failure" that plain propensity-score weighting and plain outcome regression each have?
- A) DR estimators require larger samples but always produce narrower confidence intervals
- B) The DR estimate stays consistent if either the propensity model or the outcome model is correctly specified, not necessarily both
- C) DR estimators eliminate the need to specify a DAG before adjustment
- D) DR estimators automatically handle time-varying confounding without requiring g-methods
**Answer:** B
**Explanation:** §15.5 states that matching/weighting depend entirely on the propensity model being correct and outcome regression depends entirely on the outcome model being correct, whereas "doubly robust... estimators... combine both models so the estimate stays consistent if either the propensity model or the outcome model is correctly specified -- not necessarily both."

### Q514 [Easy] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** What causal question does a marginal structural model (MSM), fit via time-varying inverse-probability-of-treatment weighting, answer?
- A) What is the effect of a single baseline covariate on treatment assignment at time zero
- B) What would the average outcome look like across the whole population if everyone followed a particular treatment strategy over time
- C) Whether a collider has been incorrectly adjusted for in a DAG
- D) Whether staggered treatment timing biases a two-way fixed effects regression
**Answer:** B
**Explanation:** The "marginal structural models" difficult-terminology box states an MSM asks "what would the outcome look like, on average across the whole population, if everyone followed a particular treatment strategy over time," handling time-varying confounding by reweighting rather than by directly adding the confounder to the outcome model.

### Q515 [Easy] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** In two-stage least squares instrumental variable analysis using `ivreg()`, what is the conventional (if debated) threshold for the first-stage F-statistic below which an instrument is flagged as "weak," making 2SLS estimates unreliable and biased toward the OLS estimate?
- A) 1
- B) 5
- C) 10
- D) 30
**Answer:** C
**Explanation:** §15.6 states "a first-stage F-statistic below roughly 10 is the conventional (if debated) threshold for flagging a 'weak instrument,' below which 2SLS estimates become unreliable and badly biased toward the plain OLS estimate."

### Q516 [Medium] [Image]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** IMAGE PLACEHOLDER: An `rdrobust::rdplot()` scatter plot of culture conversion time (weeks) against CD4 count, showing binned means and fitted local-polynomial curves on either side of a vertical dashed line at CD4 = 200, with a visible downward jump in the fitted curve just below the cutoff. Based on the chapter's regression discontinuity example, what does the jump at CD4 = 200 represent, and what key diagnostic check must be run before trusting it?
- A) It represents the average treatment effect for the entire TB programme population, and no further checks are needed
- B) It is a local effect identified only for patients near the cutoff, and a manipulation/density check (e.g. via the `rddensity` package) must confirm patients could not manipulate which side of the cutoff they landed on
- C) It represents pure selection bias that should be corrected by propensity score matching instead
- D) It reflects seasonal variation and should be adjusted with Newey-West standard errors
**Answer:** B
**Explanation:** §15.6's pitfall box states RD estimates are "local... identified only for patients near the cutoff" and should never be extrapolated, and that `rdrobust`'s manipulation/density check is needed to confirm patients (or clinicians ordering repeat tests) could not manipulate which side of the cutoff a patient landed on.

### Q517 [Medium] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** A national TB programme rolls out a new regimen to different districts at different times (staggered adoption). According to the chapter, why is a naive two-way fixed effects (TWFE) difference-in-differences regression unreliable in this setting, and what does the chapter recommend instead?
- A) TWFE cannot include covariates like age or BMI; use `lm()` with interaction terms instead
- B) TWFE implicitly compares already-treated districts against each other as pseudo-controls, producing a "negative weighting" bias; use `did::att_gt()` instead
- C) TWFE requires a perfectly balanced panel with no missing quarters; use `segmented()` instead
- D) TWFE cannot produce valid standard errors for panel data; use `sandwich::NeweyWest()` instead
**Answer:** B
**Explanation:** §15.7 states that under staggered rollout, "naive TWFE regression is now well known to produce badly biased estimates (the 'negative weighting' problem documented by Goodman-Bacon and others), because it implicitly compares already-treated districts against each other as pseudo-controls," and recommends `did::att_gt()` as "the modern fix."

### Q518 [Easy] [MCQ]
**Chapter(s):** 15 -- Real-World Evidence (RWE) and Causal Inference
**Question:** Per §15.9's discussion of E-values, what does an E-value of 1.5 for an observed association suggest, compared to an E-value of 8 for a different finding?
- A) An E-value of 1.5 indicates a very robust finding, while 8 indicates a fragile one
- B) An E-value of 1.5 means a fairly weak unmeasured confounder could plausibly explain away the result (fragile), while 8 means an implausibly strong confounder would be needed (robust)
- C) Both values indicate equally robust findings, since E-values are scale-invariant across effect measures
- D) E-values can only be computed for randomized controlled trials, not observational RWE studies
**Answer:** B
**Explanation:** §15.9 states: "An E-value of 1.5 means a fairly weak unmeasured confounder could plausibly account for the whole effect -- treat the finding as fragile. An E-value of 8 means an unmeasured confounder would need an implausibly strong, double-sided association to explain the result away -- a much more robust finding."

### Q519 [Easy] [MCQ]
**Chapter(s):** 16 -- Regression Models for HEOR Data
**Question:** In the context of §16.3's discussion of overdispersed count data, what is a Type I error?
- A) Fitting a Poisson model when a negative binomial model is needed
- B) Concluding there is a real effect or difference when, in truth, none exists and what was observed was just random noise
- C) Failing to detect a true treatment effect because the sample size was too small
- D) Reporting a coefficient on the link scale instead of exponentiating it
**Answer:** B
**Explanation:** The chapter's difficult-terminology box defines a Type I error as a "false positive" -- concluding a real effect exists when the underlying truth is a null effect. The conventional alpha = 0.05 threshold is the agreed-upon acceptable rate of this false alarm.

### Q520 [Medium] [MCQ]
**Chapter(s):** 16 -- Regression Models for HEOR Data
**Question:** The chapter's pitfall box on overdispersion states that fitting plain Poisson regression to overdispersed or zero-heavy count data mainly causes which problem, and with what consequence for Type I error?
- A) Point estimates become biased upward, which decreases the Type I error rate
- B) Standard errors come out too small, which inflates the Type I error rate above the nominal level
- C) The model fails to converge, so no Type I error rate can be assessed
- D) Standard errors become too large, which deflates power but leaves Type I error unaffected
**Answer:** B
**Explanation:** §16.3 explains that point estimates from a misspecified Poisson model often look reasonable, but the standard errors are usually too small; this makes p-values look smaller than they should, inflating the nominal 5% Type I error rate to something larger (e.g., 15-20%) because the model is overconfident about its own precision.

### Q521 [Medium] [MCQ]
**Chapter(s):** 16 -- Regression Models for HEOR Data
**Question:** According to the chapter, what does a Brant-type test formally evaluate for a proportional-odds model (e.g., fit with `MASS::polr()`)?
- A) Whether the model's residual deviance exceeds its degrees of freedom, indicating overdispersion
- B) Whether the random-effects variance differs significantly from zero across clinics
- C) Whether a predictor's effect, estimated separately at each cut-point of the ordinal outcome, is statistically consistent with coming from one shared, constant effect across all cut-points
- D) Whether the outcome variable truly has ordered categories rather than unordered ones
**Answer:** C
**Explanation:** §16.4's difficult-terminology box describes the Brant-type test as comparing coefficients estimated separately at each cut-point of an ordinal outcome and producing a p-value testing whether those estimates are consistent with one shared, constant effect -- i.e., testing the proportional-odds assumption itself.

### Q522 [Hard] [MCQ]
**Chapter(s):** 16 -- Regression Models for HEOR Data
**Question:** The chapter notes that a Brant-type test "is not bundled directly into `MASS::polr()`." If such a formal test returns a small p-value for a given predictor, what does the chapter recommend instead of reporting a single pooled odds ratio for that predictor?
- A) Switching to `glm.nb()` to account for overdispersion in the ordinal outcome
- B) Re-fitting the model with a random intercept for each cut-point
- C) Considering a partial proportional-odds model, or reporting cut-point-specific effects
- D) Ignoring the result, since proportional odds is assumed to hold by default in `polr()`
**Answer:** C
**Explanation:** Both the §16.4 pitfall box and the Brant-type test terminology box state that if the proportional-odds assumption clearly fails for a predictor, the analyst should consider a partial proportional-odds model or report cut-point-specific effects rather than trust a single pooled odds ratio.

### Q523 [Medium] [MCQ]
**Chapter(s):** 16 -- Regression Models for HEOR Data
**Question:** Per the chapter's difficult-terminology box in §16.6, in a DAG where "disease severity -> treatment choice," "disease severity -> outcome," and "treatment choice -> outcome" are all drawn, why is disease severity classified as a confounder?
- A) Because it is "acyclic," meaning it cannot be measured directly
- B) Because it feeds into both the exposure (treatment choice) and the outcome being measured
- C) Because it is downstream of treatment choice and must therefore be adjusted for
- D) Because the arrow between treatment choice and outcome is undirected
**Answer:** B
**Explanation:** The chapter defines a confounder in DAG terms as a variable that is a common cause of both the exposure and the outcome -- here, disease severity has arrows into both treatment choice and outcome, which is precisely why it must be adjusted for, versus a downstream consequence of treatment which must not be adjusted for.

### Q524 [Easy] [Image]
**Chapter(s):** 16 -- Regression Models for HEOR Data
**Question:** IMAGE PLACEHOLDER: a scatterplot showing the distribution of per-patient estimated treatment effects (tau_hat) produced by `grf::causal_forest()` on a simulated TB-regimen dataset, with a bimodal spread -- one cluster of points near zero and another cluster around 0.25-0.3 -- and a solid red line marking the single average treatment effect. What does the bimodal spread in this figure illustrate?
- A) That the `causal_forest()` model failed to converge and needs more trees
- B) Evidence of real treatment-effect heterogeneity that a single average effect would mask
- C) That roughly half of patients were misclassified as untreated
- D) That the propensity score model used by `causal_forest()` was poorly specified
**Answer:** B
**Explanation:** The figure caption in §16.5 states the bimodal spread is itself evidence of real heterogeneity -- some patients benefit far more than others -- and that a single average effect (the solid red line) would mask this pattern, which is the entire motivation for using `causal_forest()` over a doubly-robust average-effect estimator.

### Q525 [Hard] [MCQ]
**Chapter(s):** 16 -- Regression Models for HEOR Data
**Question:** A TB programme dataset has `ae_count` with over 60% of patients recording zero adverse events, consistent with the §16.3 heor-practice example. The sponsor fits `pscl::zeroinfl(ae_count ~ arm + age | arm, data = tb_ae, dist = "negbin")`. What do the left-hand side (`arm + age`) and right-hand side (`arm`, after the `|`) of this formula each model?
- A) The left side models the probability of being a structural zero; the right side models the count given a patient can have events
- B) The left side models the count process (how many events, given the patient can have events); the right side models the probability of being a structural zero
- C) Both sides model the same count outcome but with different link functions for robustness
- D) The left side is the random effect specification; the right side is the fixed effect specification
**Answer:** B
**Explanation:** §16.3 explains the two-part `count | zero` formula syntax of `zeroinfl()`: the left side of `|` models the count outcome for patients in the "can have events" group, while the right side models the probability that a given observation is a structural zero -- and `dist = "negbin"` additionally lets the count part absorb ordinary overdispersion.

### Q526 [Medium] [MCQ]
**Chapter(s):** 17 -- Principles of Decision Modelling
**Question:** A trial arm reports a response proportion whose confidence interval is visibly asymmetric around the point estimate, and the proportion itself is close to 100%. What does the chapter say this pattern suggests about how the interval was likely constructed, and why does the alternative method handle this case better?
- A) It suggests a simple normal (symmetric) approximation was used, which is preferred near 0% or 100% because it is easier to invert into Beta shape parameters
- B) It suggests a Wilson score interval was used, derived by inverting a hypothesis-testing statistic rather than assuming symmetry, which keeps the interval within the valid 0-100% range
- C) It suggests a log-normal transformation was applied to the sample size, which has no effect on interval symmetry near the boundaries
- D) It suggests a data-entry error, since valid confidence intervals for proportions are always symmetric regardless of sample size or proportion
**Answer:** B
**Explanation:** Section 17.4's difficult-terminology box on the Wilson interval explains that the simple normal-approximation CI assumes symmetry and can produce nonsensical intervals outside 0-100% when the proportion is near an extreme or the sample is small. The Wilson (Wilson score) interval instead inverts a hypothesis-testing statistic, stays within the valid range, and typically looks asymmetric around the point estimate -- so an asymmetric, extreme-proportion CI is a working clue that a Wilson-type method was used, which matters when back-fitting a Beta distribution for PSA.

### Q527 [Medium] [MCQ]
**Chapter(s):** 19 -- Markov Cohort Models
**Question:** When updating a Beta(a, b) prior for a transition probability with observed data of s successes and f failures, the chapter explains that the posterior is "conjugate" because it:
- A) Requires MCMC simulation to approximate the updated distribution
- B) Comes out as another Beta distribution, Beta(a + s, b + f), obtained by simply adding observed counts to the prior's pseudo-counts
- C) Converts automatically into a Dirichlet distribution regardless of the prior's shape
- D) Produces a posterior mean that always equals the prior mean, unaffected by the data
**Answer:** B
**Explanation:** Per the "conjugate posterior" difficult-terminology box in Section 19.8, a conjugate prior is a special case where prior and data distributions are mathematically matched so the posterior lands in the same family as the prior with a simple closed-form update rather than simulation. For a Beta(a, b) prior with a and b as pseudo-counts, observing s successes and f failures yields a Beta(a + s, b + f) posterior -- no MCMC needed. The Dirichlet distribution is the analogous conjugate posterior for a whole multinomial transition row, not a universal conversion target.

### Q528 [Medium] [MCQ]
**Chapter(s):** 21 -- Individual-Level State-Transition Models (Microsimulation)
**Question:** In a microsimulation, increasing the number of simulated patients per PSA parameter draw (e.g., from a few hundred to 10,000) reduces which specific source of noise, according to the law of large numbers?
- A) Second-order (parameter) uncertainty, because more patients means the posterior draws become more precise
- B) First-order (patient-level) uncertainty, because averaging over more individual trajectories cancels out individual-level random noise without making any single patient's path more predictable
- C) Both first- and second-order uncertainty equally, since more patients always shrinks total variance
- D) Structural uncertainty, because a larger cohort validates the model's chosen state structure
**Answer:** B
**Explanation:** As the chapter explains using the coin-flip analogy, the law of large numbers means that averaging outcomes over many simulated patients makes the average converge on the true expected value for fixed parameters -- not because individual patients become less random, but because their individual-level noise cancels out. This fixes "not enough simulated patients" but does nothing to reduce genuine second-order parameter uncertainty, which comes from not knowing the true parameter values.

### Q529 [Easy] [MCQ]
**Chapter(s):** 22 -- Discrete Event Simulation and Dynamic Models
**Question:** In a discrete event simulation (DES) of a single-nurse TB-screening clinic, what does the nurse's "capacity" represent?
- A) The maximum number of attributes an entity can carry
- B) The number of entities the resource can serve simultaneously
- C) The total number of events in the simulation's event queue
- D) The duration of the `timeout()` call for screening
**Answer:** B
**Explanation:** Per the "Resource and its capacity" difficult-terminology box in §22.1, a resource (nurse, X-ray machine, bed) is anything finite that entities compete to use, and its capacity is how many entities it can serve simultaneously -- one nurse has capacity 1. When all capacity is in use, arriving entities wait in that resource's queue.

### Q530 [Medium] [MCQ]
**Chapter(s):** 22 -- Discrete Event Simulation and Dynamic Models
**Question:** Basic SIR/SEIR compartmental models built with `deSolve::ode()` rely on the "homogeneous mixing assumption." What does this assumption state, and why can it be problematic for a disease like TB?
- A) It assumes every susceptible person is equally likely to contact every infectious person, which breaks down when transmission is concentrated within households or correctional facilities rather than spread evenly
- B) It assumes the recovery rate gamma never changes over the simulated time horizon, which is unrealistic for diseases with evolving treatment protocols
- C) It assumes the population size N is constant, which fails whenever births or deaths occur during the simulated period
- D) It assumes R0 is always greater than 1, which prevents the model from ever reaching a disease-free equilibrium
**Answer:** A
**Explanation:** The "Homogeneous mixing assumption" box in §22.4 states that basic compartmental models assume every individual in a compartment has an equal chance of contacting every individual in every other compartment, making the maths tractable but breaking down when real contact structure is clustered -- e.g. TB transmission concentrated within households or correctional facilities rather than spread evenly across a district.

### Q531 [Medium] [MCQ]
**Chapter(s):** 22 -- Discrete Event Simulation and Dynamic Models
**Question:** According to §22.4, what distinguishes a "network epidemic model" from a standard compartmental (SIR/SEIR) model, and which `EpiModel` function is associated with building such network-based simulations?
- A) The population is represented as a graph of nodes connected by contact edges, with infection spreading only along existing edges; this is supported via `EpiModel`'s `netsim()`/`netest()` functions
- B) The population is divided into age-stratified compartments with transition rates between age bands; this is supported via `deSolve::ode()`'s multi-compartment solver
- C) The population is modelled as a single well-stirred pool with no internal structure at all; this is supported via `EpiModel`'s `dcm()` function
- D) The population is simulated one individual at a time with no interaction between individuals, identical to the microsimulation models of Chapter 21
**Answer:** A
**Explanation:** The "Network epidemic model" box in §22.4 defines it as a model where the population is a graph of individuals (nodes) connected by contacts or partnerships (edges), with infection spreading only along existing edges rather than between any two randomly chosen individuals -- representing real contact structure like household clusters or partnership networks. The chapter ties `EpiModel`'s network-based simulation path to `netsim()`/`netest()`, distinct from the deterministic compartmental `dcm()` path.

### Q532 [Easy] [MCQ]
**Chapter(s):** 23 -- Budget Impact Analysis
**Question:** According to Chapter 23, what does ISPOR good-practice guidance recommend regarding discounting in a base-case budget impact analysis?
- A) Costs should be discounted at the same long-run societal rate used in cost-effectiveness analysis
- B) Costs should typically be presented undiscounted, since the budget is set and spent in nominal terms year by year
- C) Only the new intervention's acquisition cost should be discounted, not the offset
- D) Discounting should be applied only if the horizon exceeds five years
**Answer:** B
**Explanation:** Section 23.1's pitfall box and Section 23.3 both state that ISPOR guidance recommends BIA cash flows typically be presented undiscounted in the base case, because a payer's budget is set and spent in nominal terms year by year, unlike the present-value basis of CEA.

### Q533 [Easy] [MCQ]
**Chapter(s):** 23 -- Budget Impact Analysis
**Question:** In the chapter's `build_bia()` R function, which three arguments can be changed with a single function call to generate a scenario analysis without rebuilding the model?
- A) `years`, `eligible_pop`, and `cost_soc`
- B) `uptake_share`, `cost_new`, and `offset_new`
- C) `patients_on_new`, `patients_on_soc`, and `budget_impact`
- D) `cost_current_mix`, `cost_new_mix`, and `cumulative_bi`
**Answer:** B
**Explanation:** Section 23.4 explains that because `build_bia()` already takes `uptake_share`, `cost_new`, and `offset_new` as arguments, every scenario (faster uptake, a managed-entry agreement) is a one-line parameter change to the same function rather than a hand-edited copy of the model.

### Q534 [Medium] [MCQ]
**Chapter(s):** 23 -- Budget Impact Analysis
**Question:** In the chapter's base-case worked model (10,000 eligible patients/year, SoC at $500/patient-year, new drug at $2,000/patient-year with a $300/patient-year hospitalization offset, uptake 5/15/30/45/55% over years 1-5), what is the budget impact in Year 3?
- A) $1,800,000
- B) $3,600,000
- C) $5,400,000
- D) $8,600,000
**Answer:** B
**Explanation:** In Year 3, 3,000 patients are on the new drug at a net cost of $1,700 ($5,100,000) and 7,000 remain on SoC at $500 ($3,500,000), giving a new-mix total of $8,600,000 versus a flat current-mix cost of $5,000,000, for a budget impact of $3,600,000, as worked through step-by-step in Section 23.3.

### Q535 [Medium] [MCQ]
**Chapter(s):** 23 -- Budget Impact Analysis
**Question:** Section 23.2 gives a worked market-share example with 1,000 eligible patients, Drug A ($500/patient-year) and Drug B ($800/patient-year) at a 70:30 reference-scenario split. In the new scenario, the new intervention (cost $1,200/patient-year) captures 20% of the population by year 2, drawn proportionally from both existing drugs. Why is the resulting budget impact of $122,000 smaller than the naive "20% x 1,000 x $1,200 = $240,000" figure?
- A) Because the new intervention's price was discounted by the payer before the calculation
- B) Because the budget impact nets out the cost the payer was already going to incur for patients who would otherwise have been on Drug A or Drug B
- C) Because only half of the 1,000 patients are actually eligible for the new intervention
- D) Because the calculation applies a discount rate to year-2 costs
**Answer:** B
**Explanation:** The chapter's difficult-terminology box on market share explains that the new intervention's cost to the payer is not simply patients-times-price; it is that amount minus whatever cost the payer was already going to incur for patients who would otherwise have been on an existing therapy. The reference-scenario cost ($590,000) subtracted from the new-scenario cost ($712,000) gives the true net impact of $122,000, not the gross $240,000.

### Q536 [Medium] [Image]
**Chapter(s):** 23 -- Budget Impact Analysis
**Question:** IMAGE PLACEHOLDER: a line chart titled "Illustrative uptake curves over a 5-year BIA horizon" showing two curves, both converging to a terminal market share of 0.35 by year 5 -- a straight "linear" line rising in equal increments each year, and a "logistic" curve that starts below the linear line in early years, then crosses above it in the middle years before levelling off as it approaches the same terminal share. Based on the chapter's description of these two uptake functional forms, which best characterizes the logistic curve's shape relative to the linear ramp?
- A) It rises faster than the linear ramp in every year of the horizon
- B) It starts slower, accelerates through the middle years, and then levels off as the addressable market saturates
- C) It is a mirror image of the linear ramp, falling where the linear ramp rises
- D) It reaches the terminal share exactly one year earlier than the linear ramp
**Answer:** B
**Explanation:** Section 23.2 describes the S-shaped logistic diffusion curve as starting slowly, accelerating through early adoption, and then levelling off as the addressable market saturates -- the same qualitative shape used to describe technology adoption in many fields -- in contrast to the linear ramp's equal year-on-year increments.

### Q537 [Hard] [MCQ]
**Chapter(s):** 23 -- Budget Impact Analysis
**Question:** Section 23.3's pitfall box identifies a second common BIA error distinct from improperly discounting costs. What is it?
- A) Using `cumprod()` instead of `cumsum()` to build the eligible-population cascade
- B) Reporting the new drug's acquisition cost and hospitalization offset as separate line items instead of netting them
- C) Modelling diffusion as if every patient who starts the new drug stays on it, with no allowance for discontinuation or non-adherence, which overstates new-drug spend and understates realised offsets
- D) Applying the payer's societal perspective instead of the budget holder's specific perspective
**Answer:** C
**Explanation:** The pitfall box in Section 23.3 warns that modelling uptake as if every patient started and stayed on the new drug, ignoring discontinuation or non-adherence, means the effective exposed population is smaller than the raw uptake share suggests -- overstating new-drug spend and understating any downstream offset actually realised.

### Q538 [Easy] [MCQ]
**Chapter(s):** 24 -- Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** In extended cost-effectiveness analysis (ECEA), a household's health spending is classified as catastrophic health expenditure (CHE) when it exceeds what, under the convention used in the chapter's worked example?
- A) A fixed absolute dollar amount regardless of income
- B) 10% of the household's income or total consumption
- C) The national poverty line
- D) 50% of the household's total annual healthcare budget
**Answer:** B
**Explanation:** The chapter's difficult-terminology box on CHE defines it as spending exceeding a fixed fraction of household income/consumption, with 10% as the convention used in the worked example (noting some national studies use 25% or 40%), explicitly comparing this arbitrary-but-policy-relevant threshold to a p-value convention.

### Q539 [Medium] [MCQ]
**Chapter(s):** 24 -- Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** A household earning $1,000/year pays $150 out of pocket for a hospitalization, while a household earning $10,000/year pays the identical $150. Using the 10%-of-income CHE convention, what does the chapter's worked illustration conclude?
- A) Neither household has catastrophic expenditure, since both paid the same dollar amount
- B) Both households have catastrophic expenditure, since the dollar cost is identical
- C) Only the poorer household (15% of income) crosses the catastrophic threshold; the richer household (1.5% of income) does not
- D) Only the richer household crosses the threshold because its total spending capacity is higher
**Answer:** C
**Explanation:** The chapter illustrates precisely this point: $150 is 15% of $1,000 income (catastrophic, over the 10% convention) but only 1.5% of $10,000 income (not catastrophic) -- identical absolute spending, opposite welfare classification, which is why ECEA tracks financial risk protection by income quintile rather than in aggregate.

### Q540 [Medium] [MCQ]
**Chapter(s):** 24 -- Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** EVIDEM's two-part structure separates its MCDA Core Model from its Contextual Tool. What is the key methodological reason EVIDEM's developers kept these two parts separate rather than scoring everything numerically?
- A) The Contextual Tool's criteria (e.g. ethical principles, political priorities) were judged unsuitable for forcing into a number, since doing so would misrepresent the nature of that judgement
- B) Numeric scoring is computationally infeasible for more than 15 criteria
- C) Canadian HTA bodies legally require a two-part submission format
- D) The Core Model criteria are quantifiable only in Europe, not Canada
**Answer:** A
**Explanation:** The chapter's EVIDEM difficult-terminology box states that EVIDEM's developers judged forcing a number onto considerations like "is it ethically acceptable to prioritize this population" would misrepresent that judgement's nature, hence the Contextual Tool's ~6 considerations are deliberated qualitatively rather than scored, while the ~14-15-criterion Core Model is weighted and scored numerically.

### Q541 [Hard] [MCQ]
**Chapter(s):** 24 -- Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** A condition's patients have an expected remaining QALY count under current care such that the absolute QALY shortfall is 10 QALYs and the proportional QALY shortfall is 0.90. Under NICE's Table 6.1 severity-weight bands described in the chapter (weight 1.7 if proportional >=0.95 or absolute >=18; weight 1.2 if proportional >=0.85 or absolute >=12; otherwise weight 1), what severity weight applies, and why?
- A) 1.0, because neither measure alone reaches the top band
- B) 1.2, because the proportional shortfall of 0.90 falls in the 0.85-0.95 band even though the absolute shortfall (10) does not reach 12
- C) 1.7, because the two measures are averaged together
- D) 1.2, because the absolute shortfall of 10 alone triggers that band
**Answer:** B
**Explanation:** NICE's rule takes whichever of the two shortfall measures implies the higher weight, not an average or a requirement that both agree. Here the absolute shortfall (10) is below the 12-QALY cutoff for weight 1.2, but the proportional shortfall (0.90) clears the 0.85 cutoff, so the condition qualifies for the 1.2 weight via the proportional measure alone -- exactly the "two measures can disagree about which severity band a condition falls into" point the chapter makes with its elderly-vs-young-patient illustration.

### Q542 [Medium] [MCQ]
**Chapter(s):** 24 -- Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** According to the chapter's table of managed entry agreement (MEA) types, what distinguishes a coverage-with-evidence-development (CED) outcomes-based agreement from a patient-level (pay-for-performance) outcomes-based agreement?
- A) CED requires no post-launch data at all, while patient-level agreements require a registry
- B) CED measures population-level outcomes (e.g. survival, response rate) in a defined post-launch cohort, often via a registry, informing a future re-appraisal; patient-level agreements tie payment/refund to an individual patient's own clinical response
- C) CED is used only for financial-based discounts, while patient-level agreements are purely confidential price concessions
- D) CED is the more operationally demanding type because it requires auditing every individual patient's biomarker response
**Answer:** B
**Explanation:** The chapter's difficult-terminology box on outcomes-based MEAs and its MEA-types table distinguish CED (a conditional reimbursement decision generating population-level evidence, commonly via a registry, feeding a formal re-appraisal) from patient-level agreements (narrower, tied to each individual patient's own response against a pre-agreed clinical criterion) -- and notes patient-level agreements are the more operationally demanding of the two.

### Q543 [Easy] [MCQ]
**Chapter(s):** 24 -- Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** What is the fundamental difference between cost-benefit analysis (CBA) and cost-effectiveness analysis (CEA), as stated in the chapter?
- A) CBA only applies to medicines, while CEA applies to all health technologies
- B) CBA measures both cost and benefit in money, producing a single interpretable net-benefit figure; CEA measures benefit in natural health units (QALYs, life-years), producing a ratio that is only interpretable relative to a threshold or comparator
- C) CBA is used exclusively by NICE, PBAC, and CADTH, while CEA is used in transport and environmental regulation
- D) CBA and CEA are mathematically identical except for the discount rate applied
**Answer:** B
**Explanation:** The chapter's opening difficult-terminology box states this directly: CBA's monetization of both sides lets it report a standalone net benefit, while CEA's cost-per-QALY ratio requires an external threshold or comparator to interpret -- which is also why CEA dominates formal drug/device HTA while CBA dominates transport/environmental/occupational regulation.

### Q544 [Medium] [MCQ]
**Chapter(s):** 24 -- Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** In the chapter's toy two-subgroup DCEA worked example (1,000 patients each in a most-deprived Q1 group and a least-deprived Q5 group, $2,000/patient cost in both, QALY gains of 0.12 and 0.08 per patient respectively, with a 1.5x equity weight applied only to Q1), why does equity weighting make the intervention look more cost-effective overall rather than less?
- A) Because the equity weight was applied to the subgroup that was already receiving the larger QALY gain
- B) Because equity weighting always reduces the total cost of an intervention
- C) Because Q5's QALYs were discounted to zero
- D) Because the equity weight is applied to cost, not QALYs, lowering the numerator
**Answer:** A
**Explanation:** The chapter states this is the direction-dependent point of the illustration: because the 1.5x weight was applied to Q1, which already had the larger per-patient QALY gain (0.12 vs 0.08), up-weighting pushed the equity-weighted ICER down ($15,384.62/QALY vs $20,000/QALY unweighted) -- a "win-win" case on the equity impact plane. Had the smaller gain instead belonged to the up-weighted group, the two ICERs would move in opposite directions, producing a genuine efficiency-equity trade-off.

### Q545 [Medium] [MCQ]
**Chapter(s):** 24 -- Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** In the chapter's ECEA worked example of universal public finance for TB treatment in India, moving from a status-quo out-of-pocket cost of $150/episode to a new-policy cost of $20/episode shifts the catastrophic-expenditure income cutoff from $1,500 to $200. Given the quintile income bands (Q1 $300-700, Q2 $700-1,100, Q3 $1,100-1,700, Q4 $1,700-2,700, Q5 $2,700-5,300), which quintile is only partially catastrophic under the status quo, and what fraction of its households does that represent?
- A) Q1, with 100% of households catastrophic
- B) Q2, with 50% of households catastrophic
- C) Q3, with two-thirds (~13,333 of 20,000) of households catastrophic
- D) Q4, with one-third of households catastrophic
**Answer:** C
**Explanation:** The chapter's hand-worked arithmetic shows Q1 and Q2 are entirely below the $1,500 cutoff (100% catastrophic each), Q3 ($1,100-$1,700) straddles the cutoff so only the (1500-1100)/(1700-1100) = 2/3 share below it -- 13,333.3 of 20,000 households -- is catastrophic, and Q4/Q5 sit entirely above the cutoff (0% catastrophic).

### Q546 [Hard] [MCQ]
**Chapter(s):** 24 -- Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** In the chapter's three-drug MCDA worked example (weights: efficacy 0.35, safety 0.25, severity 0.20, economic 0.20), Drug C scores highest on efficacy (90) and severity (80) but lowest on safety (50) among the three drugs. Why does the chapter note that the gap between Drug B and Drug C widens under the weighted-product rule compared to the weighted-sum rule, even though the overall ranking (B > C > A) stays the same?
- A) The weighted product cannot be computed when any score is above 80
- B) The weighted-product rule raises each score to the power of its weight and multiplies them, so it punishes Drug C's relatively weak safety score (50) more heavily than the additive weighted-sum rule, which can offset a weak criterion with strong ones elsewhere
- C) The weighted-sum rule ignores the safety criterion entirely
- D) Drug C's weighted-product score was miscalculated in the chapter and should actually exceed Drug B's
**Answer:** B
**Explanation:** The chapter explains the weighted product is multiplicative (score = product of s_i^w_i) and is far less forgiving of a weak score on any single criterion than the compensatory, additive weighted sum; applied to the worked numbers (Drug B=68.48 vs Drug C=64.53 under the product, versus 69.5 vs 68.0 under the sum), Drug C's weaker safety score (50) is penalized more under the product, widening Drug B's lead even though the ranking order doesn't flip.

### Q547 [Easy] [Image]
**Chapter(s):** 24 -- Cost-Benefit, Distributional and Extended Cost-Effectiveness Analysis
**Question:** IMAGE PLACEHOLDER: A grouped bar chart titled "Financial risk protection outcomes by income quintile," showing two bars per quintile (Q1 poorest through Q5 richest) -- catastrophic-health-expenditure (CHE) cases averted in blue and poverty cases averted in orange -- for a universal public finance of TB treatment policy versus status quo. The blue and orange bars are large for Q1-Q3 and essentially zero for Q4 and Q5. Based on the chapter's ECEA worked example, what does this quintile-level pattern demonstrate that a single pooled total (e.g. "53,333 CHE cases averted") would hide?
- A) That the policy has no effect anywhere except a small gain in Q5
- B) That financial risk protection accrues almost entirely to the three poorest quintiles, a pro-poor distributional pattern invisible in the aggregate figure alone
- C) That CHE cases averted and poverty cases averted are always numerically equal within each quintile
- D) That the richest quintile (Q5) bears the largest share of out-of-pocket cost reduction
**Answer:** B
**Explanation:** The chapter's heor-practice box states explicitly that financial risk protection results should be reported by quintile, not only pooled, because the pooled total of 53,333 CHE cases averted hides that essentially all of the protection accrues to the three poorest quintiles with zero effect on Q4 and Q5 -- information a ministry needs to compare a universal subsidy against a means-tested one targeted at the bottom three quintiles.

### Q548 [Medium] [MCQ]
**Chapter(s):** 25 -- Handling Uncertainty
**Question:** A reported relative-effect estimate covers two correlated outcomes (e.g. log hazard ratios for Cure and Failure) with a known covariance matrix. Per §25.4's difficult-terminology box, what distinguishes sampling these jointly from a multivariate normal distribution versus sampling each with its own independent univariate normal?
- A) The multivariate normal uses a single standard deviation for both outcomes, while independent sampling allows each its own standard deviation
- B) The multivariate normal's covariance matrix lets off-diagonal terms preserve whether the two log-effects tend to move together, which independent per-outcome sampling discards entirely
- C) Independent sampling is only invalid when both parameters are bounded between 0 and 1
- D) The multivariate normal can only be used when the two outcomes have identical means and variances
**Answer:** B
**Explanation:** The chapter's difficult-terminology box on the multivariate normal distribution explains that its covariance matrix diagonal gives each quantity's own variance while off-diagonal entries capture covariances between pairs; sampling jointly preserves correlation, whereas separate univariate draws "would, by construction, ignore any relationship between the quantities."

### Q549 [Hard] [MCQ]
**Chapter(s):** 25 -- Handling Uncertainty
**Question:** §25.4 notes that when two PSA parameters are known to be correlated (e.g. from a reported covariance matrix), independent sampling is not a safe default. What specifically can go wrong if a true positive correlation between two relative-effect parameters is ignored and they are instead sampled independently in PSA?
- A) The model will fail to run because of a dimension mismatch in the transition matrix
- B) Independent sampling will always exactly double the reported Monte Carlo error
- C) Independent sampling can generate jointly implausible combinations (e.g. a very favourable Cure effect paired with a very unfavourable Failure effect) that understate the true joint uncertainty when the parameters actually track together
- D) Independent sampling converts the Beta distribution into a Dirichlet distribution automatically
**Answer:** C
**Explanation:** The chapter states that ignoring a genuine positive correlation "can produce combinations that are jointly implausible... when in reality the two track together," understating true joint uncertainty -- the specific failure mode the Cholesky-based multivariate normal sampling (§19.8, referenced in §25.4) is designed to fix.

### Q550 [Easy] [MCQ]
**Chapter(s):** 25 -- Handling Uncertainty
**Question:** According to the ISPOR-SMDM Task Force-6 taxonomy discussed in §25.1, which type of uncertainty is explicitly described as "not a form of uncertainty at all," and is instead handled by stratified subgroup analysis rather than by PSA?
- A) Parameter uncertainty
- B) Structural uncertainty
- C) Methodological uncertainty
- D) Heterogeneity
**Answer:** D
**Explanation:** §25.1 states heterogeneity is "real, explainable variation across patient subgroups" rather than imprecision in an estimate, and the pitfall box warns against pooling it into a single PSA distribution; it should instead be addressed by running the model separately per subgroup.

### Q551 [Medium] [MCQ]
**Chapter(s):** 25 -- Handling Uncertainty
**Question:** In §25.2's worked one-way sensitivity analysis on the TB regimen-choice model, the New-regimen cure probability produced a swing of $7,945 in incremental NMB -- roughly three times larger than any other parameter tested. What is the stated reason cure probability dominates the tornado diagram?
- A) It is the parameter with the widest plausible range tested
- B) It drives both Cured-state QALY accrual and how much Fail/Death-state cost and QALY loss is avoided, a "double lever" no single cost or utility parameter has
- C) It is the only parameter shared between both treatment arms
- D) It has the largest standard error of all parameters in the model
**Answer:** B
**Explanation:** The chapter explains the swing "dwarfs every other parameter's swing... given that cure probability drives both the Cured-state QALY accrual and how much Fail/Death-state cost and QALY loss is avoided, a double lever that a single cost or utility parameter does not have."

### Q552 [Easy] [MCQ]
**Chapter(s):** 25 -- Handling Uncertainty
**Question:** Why does §25.2 state that tornado diagrams typically plot incremental net monetary benefit (NMB) rather than the ICER on the horizontal axis?
- A) NMB is always positive, so it is easier to plot on a log scale
- B) The ICER is a ratio, and a small incremental QALY denominator near zero (or changing sign) makes the ICER jump discontinuously, whereas NMB is a smooth linear combination with no such discontinuity
- C) Regulators require NMB rather than ICER for all submissions
- D) NMB does not require a willingness-to-pay threshold to calculate
**Answer:** B
**Explanation:** The difficult-terminology box on NMB explains that ratios like the ICER "misbehave arithmetically" when the denominator is small or changes sign, causing a jump between very large positive and negative values, while NMB "has no such discontinuity (it is a simple linear combination, not a ratio)."

### Q553 [Medium] [MCQ]
**Chapter(s):** 25 -- Handling Uncertainty
**Question:** Per §25.4's standard PSA distribution conventions table, which distribution family is the standard choice for a cost parameter, and why?
- A) Normal, because costs are assumed symmetric around their mean
- B) Beta, because costs are bounded between 0 and 1
- C) Gamma or lognormal, because costs are non-negative and typically right-skewed, with a long tail of high-cost patients
- D) Dirichlet, because costs must sum to a fixed total across categories
**Answer:** C
**Explanation:** §25.4 states costs "can never be negative, and empirically, cost data is almost always right-skewed," making Gamma (common in dampack/heemod templates, parameterised via method-of-moments shape/rate) or lognormal the standard choices.

### Q554 [Hard] [Image]
**Chapter(s):** 25 -- Handling Uncertainty
**Question:** IMAGE PLACEHOLDER: a running-mean convergence plot (as in §25.4's Monte Carlo error check) showing mean discounted cost at N = 100, 500, 1000, 1500, and 2000 PSA iterations, with the line visibly flattening after roughly N=1000-1500. What does this flattening pattern indicate about the PSA?
- A) The model has reached a structural equilibrium and no further scenarios need testing
- B) Monte Carlo error has shrunk to the point where additional iterations no longer change the reported summary statistic by a practically meaningful amount, i.e. the result has converged
- C) The willingness-to-pay threshold has been correctly calibrated
- D) The parameter distributions were misspecified and need to be re-fit
**Answer:** B
**Explanation:** §25.4 describes exactly this diminishing-returns pattern as the convergence check for Monte Carlo error: "the point at which adding more iterations stops changing that running estimate by a practically meaningful amount." In the worked example, cost fluctuated by under $1 per 500 additional iterations once N reached 1000-1500.

### Q555 [Medium] [MCQ]
**Chapter(s):** 25 -- Handling Uncertainty
**Question:** §25.6 defines threshold analysis as distinct from one-way sensitivity analysis. What specifically differentiates the two techniques?
- A) Threshold analysis solves algebraically or numerically for the exact value of a parameter at which the ICER equals a specific target, whereas one-way sensitivity analysis reports the ICER at several chosen values across a range
- B) Threshold analysis can only be applied to the discount rate, while one-way sensitivity analysis can be applied to any parameter
- C) Threshold analysis requires thousands of Monte Carlo draws, while one-way sensitivity analysis is always closed-form
- D) Threshold analysis reports a curve of ICERs, while one-way sensitivity analysis reports a single breakeven number
**Answer:** A
**Explanation:** The difficult-terminology box in §25.6 states a one-way sensitivity analysis "reports the ICER at each of several chosen values of a parameter," whereas threshold analysis "solves algebraically (or numerically, by search...) for the exact value at which the ICER equals a specific target," producing a single number rather than a table or curve.

### Q556 [Easy] [MCQ]
**Chapter(s):** 25 -- Handling Uncertainty
**Question:** In §25.8's discussion of the non-parametric bootstrap applied to patient-level trial cost-QALY data, why must whole patient rows (cost and QALY together) be resampled with replacement, rather than resampling the cost column and QALY column separately?
- A) Resampling columns separately would violate R's matrix dimension requirements
- B) Resampling whole rows preserves the within-patient correlation between cost and QALY, since patients with poor outcomes often also incur higher costs
- C) Resampling columns separately would make the bootstrap parametric instead of non-parametric
- D) R's `sample()` function cannot resample two columns at different rates
**Answer:** B
**Explanation:** §25.8 explains that cost and QALY are usually correlated within the same patient, and that resampling must occur "resampling whole rows (a patient's cost and QALY together), never the cost column and the QALY column separately" -- otherwise real information about how the two move together is discarded and the uncertainty estimate is wrong.

### Q557 [Easy] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** According to §26.1, which health-economic paper provides the foundational argument that a reimbursement decision should be based on expected (mean) net benefit alone, regardless of statistical significance?
- A) Felli and Hazen (1998), "Sensitivity Analysis and the Expected Value of Perfect Information"
- B) Claxton (1999), "The Irrelevance of Inference: A Decision-Making Approach to the Stochastic Evaluation of Health Care Technologies"
- C) Strong, Oakley and Brennan (2014), "Estimating Multiparameter Partial Expected Value of Perfect Information"
- D) Jalal and Alarid-Escudero (2018), "A General Gaussian Approximation Approach for Value of Information Analysis"
**Answer:** B
**Explanation:** §26.1 grounds VOI's decision-theoretic framing in Claxton's 1999 Journal of Health Economics paper, which argues decisions should rest on expected net benefit, leaving the distribution of net benefit to answer the separate question of whether more information is worth acquiring.

### Q558 [Easy] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** Per §26.1, what two things does EVPI account for that earlier threshold-proximity and entropy-based sensitivity measures (per Felli and Hazen, 1998) captured only one of?
- A) The sample size of the PSA and the number of model parameters
- B) The willingness-to-pay threshold and the discount rate
- C) The likelihood that more information would change the decision and the size of the payoff gained if it did
- D) The cost of running a trial and the time horizon of the model
**Answer:** C
**Explanation:** §26.1 explains Felli and Hazen's reasoning for proposing EVPI: it jointly captures both the probability that new information flips the decision and the magnitude of the gain if it does, whereas older measures captured only one of the two.

### Q559 [Medium] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** In the §26.1 worked six-draw EVPI illustration (WTP = $50,000/QALY), the fixed choice is to always pick New because its mean NMB ($299,325) exceeds SoC's mean NMB ($295,041.67). What is the resulting EVPI per patient?
- A) $617.00
- B) $4,283.33
- C) $858.33
- D) $0 (New always wins)
**Answer:** C
**Explanation:** Averaging the "best for this draw" column gives $300,183.33, and subtracting the fixed-choice NMB of $299,325 yields an EVPI of $858.33 per patient -- two of the six draws (3 and 6) would have favoured SoC despite New winning on average.

### Q560 [Medium] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** Why does naive EVPPI estimation require a nested simulation while EVPI does not, according to §26.1?
- A) EVPPI must re-run the model for each outer-loop candidate value of the parameter of interest, each requiring a full inner-loop PSA over every other parameter
- B) EVPPI requires a larger number of PSA draws than EVPI to converge
- C) EVPPI needs a Bayesian posterior update that EVPI does not
- D) EVPPI must simulate a future trial dataset before it can be computed
**Answer:** A
**Explanation:** §26.1 describes EVPPI's naive computation as an outer loop over candidate values of a parameter crossed with an inner-loop PSA over all other parameters -- e.g. 1,000 outer x 1,000 inner draws = a million model evaluations for one parameter -- unlike EVPI, which reuses existing PSA draws directly with no new model runs.

### Q561 [Easy] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** Per the §26.1 pitfall box, when can a single parameter's EVPPI legitimately approach the model's total EVPI?
- A) Never -- EVPPI is always capped well below EVPI by mathematical necessity
- B) Only when the parameter follows a Beta distribution
- C) When nearly all of a model's decision uncertainty traces back to that one dominant parameter -- but this is model-specific, not a general equivalence
- D) Only after a GAM regression with k set very high
**Answer:** C
**Explanation:** The pitfall warns that EVPPI approaching EVPI is a property of that specific model's uncertainty structure (e.g. one dominant parameter), not a general rule -- models with several co-dominant parameters can have an EVPI far exceeding any single parameter's EVPPI.

### Q562 [Medium] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** According to §26.2, at what point along a willingness-to-pay (WTP) grid does EVPI tend to peak?
- A) At WTP = $0, since EVPI is always maximised when cost dominates the comparison
- B) Near the WTP value at which Chapter 25's CEAC crosses the 50% mark -- the point the decision is closest to a toss-up
- C) At the highest WTP value in the grid, since QALY gains always dominate at that extreme
- D) EVPI is constant across all WTP values for a correctly specified model
**Answer:** B
**Explanation:** §26.2 explains that EVPI is small at both WTP extremes (where the decision is nearly unanimous across draws) and rises to a peak near the WTP at which the CEAC is closest to 50%, i.e. where draws are most evenly split between favouring New and SoC.

### Q563 [Easy] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** Per §26.2, which two R packages are purpose-built to wrap EVPI/EVPPI/EVSI calculations, though the chapter states neither is installed on its drafting machine?
- A) `ggplot2` and `dplyr`
- B) `BCEA` and `voi`
- C) `mgcv` and `heemod`
- D) `survival` and `flexsurv`
**Answer:** B
**Explanation:** §26.2 names `BCEA` (already used in Chapter 25 for the CE plane/CEAC/CEAF) and `voi`, the newer, more actively maintained package built specifically around VOI methods including GAM-regression EVPPI, while being explicit that neither is installed and so no function call from either is demonstrated.

### Q564 [Medium] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** Per the §26.2 heor-practice box, why is reporting EVPI across a plausible range of WTP thresholds, rather than only at the headline $50,000/QALY figure, recommended?
- A) Because EVPI is only well-defined at round-number WTP thresholds
- B) Because the WTP threshold itself is often contested, and since EVPI is threshold-dependent, anchoring to one value can materially misstate the value of further research
- C) Because regulatory agencies require EVPI to be plotted, not tabulated
- D) Because `calculate_evpi()` cannot run at a single WTP value
**Answer:** B
**Explanation:** The heor-practice box notes WTP-threshold conventions vary across jurisdictions (cross-referencing Chapter 4), and a VOI analysis anchored to only one WTP value risks understating or overstating the true value of research if the real decision-relevant threshold lies elsewhere on the curve.

### Q565 [Medium] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** Per the §26.2 agency-note, what is notable about the NICE Decision Support Unit's coverage of VOI methodology compared to other NICE DSU methodological topics?
- A) VOI has its own numbered Technical Support Document, TSD 14
- B) VOI is not covered by its own numbered TSD in the DSU's TSD 1-27 series; the 2005 pilot study report remains the primary NICE-commissioned VOI reference
- C) NICE has formally rejected VOI as a methodology for its technology appraisals
- D) VOI methodology is only documented in NICE's manufacturer submission template, not in any DSU publication
**Answer:** B
**Explanation:** The agency-note confirms (against the DSU's current full TSD list) that VOI, unlike several other DSU topics, lacks its own numbered TSD -- the "Pilot Study of Value of Information Analysis to Support Research Recommendations for NICE" (NICE DSU, June 2005) is the primary reference instead.

### Q566 [Easy] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** Per §26.3, why is a Generalized Additive Model (GAM) preferred over a plain linear regression when estimating EVPPI by regressing net monetary benefit on a parameter of interest?
- A) GAMs always run faster than linear models in R
- B) The true relationship between a parameter and net benefit is not guaranteed to be a straight line, and a forced straight-line fit would systematically mis-estimate the conditional mean and therefore EVPPI
- C) GAMs do not require the `mgcv` package to be installed
- D) Linear regression cannot be fit to PSA draws at all
**Answer:** B
**Explanation:** §26.3 explains that net benefit may rise steeply then flatten (e.g. as failure probability falls), a curve a straight line cannot follow -- a GAM's flexible smooth term, fit via `mgcv::gam()` with `s(x)`, bends to follow the data's genuine shape while penalising excessive wiggle.

### Q567 [Hard] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** Per §26.3, Strong, Oakley and Brennan's regression-based EVPPI paper reports that GAMs perform adequately up to roughly how many simultaneous parameters of interest before Gaussian process regression becomes the preferred alternative?
- A) Around one parameter
- B) Around four parameters
- C) Around ten parameters
- D) GAMs remain preferred regardless of parameter count
**Answer:** B
**Explanation:** §26.3 states the Strong, Oakley and Brennan (2014) paper demonstrates GAMs perform adequately for up to around four parameters of interest at once, with Gaussian process regression preferred for higher-dimensional cases.

### Q568 [Hard] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** In the §26.3 EVPPI pitfall box about `mgcv`'s `k=` smoothness argument, what is the directional effect of setting `k` too small versus too large?
- A) Too small k overstates EVPPI by chasing sampling noise; too large k understates EVPPI by over-smoothing
- B) Too small k understates EVPPI because genuine curvature gets smoothed away as noise; too large k overstates EVPPI because Monte Carlo scatter gets mistaken for a real relationship
- C) Both too small and too large k always understate EVPPI
- D) The direction of bias from k is unpredictable and cannot be characterised
**Answer:** B
**Explanation:** The pitfall explains that an overly rigid, nearly-straight curve (k too small) smooths away genuine curvature and understates EVPPI, while an overly flexible curve (k too large) chases sampling noise and overstates EVPPI -- the defence is visual diagnostic plots plus `method = "REML"` automatic smoothness selection rather than hand-picked k.

### Q569 [Medium] [Image]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** IMAGE PLACEHOLDER: A scatterplot of raw PSA draws (p_ontx_fail on the x-axis, incremental NMB on the y-axis) with a red `mgcv::gam()`-fitted smooth curve overlaid, tracking the scatter closely with no visible under- or over-fitting. Per the figure caption in §26.3, what EVPPI value for `p_ontx_fail` does running this GAM fit on the actual PSA draws produce?
- A) $4.00
- B) $300.00
- C) $598.00
- D) $847.01
**Answer:** D
**Explanation:** The figure caption states that running the fit on the actual PSA draws gives an EVPPI for `p_ontx_fail` of $847.01, closely confirming the ~$900 illustrative figure used in the worked examples throughout §26.4-26.6.

### Q570 [Medium] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** Per §26.4's moment-matching worked example, `p_ontx_fail` follows a Beta(8, 92) prior. For a proposed n=200-patient trial expected to observe about 16 failures, what is the updated (expected posterior) Beta distribution, and roughly what fraction of the prior variance does this reduce?
- A) Beta(24, 276); approximately 66.4% variance reduction
- B) Beta(8, 292); approximately 95.2% variance reduction
- C) Beta(16, 184); approximately 50% variance reduction
- D) Beta(24, 276); approximately 33.6% variance reduction
**Answer:** A
**Explanation:** Observing r failures in n patients updates Beta(a,b) to Beta(a+r, b+n-r), giving Beta(8+16, 92+184) = Beta(24,276); the prior variance of ~0.000729 falls to a posterior variance of ~0.0002445, a reduction of about 66.4%, closely matching the effective-sample-size heuristic 1 - 100/300 ~ 66.7%.

### Q571 [Medium] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** Per §26.4, which of the three EVSI approximation approaches is described as assuming net benefit is approximately normally distributed, trading that assumption for the lowest computational cost of the three?
- A) Moment-matching
- B) Importance sampling
- C) Gaussian approximation
- D) Nested Monte Carlo simulation
**Answer:** C
**Explanation:** §26.4 describes the Gaussian approximation (based on Jalal and Alarid-Escudero, 2018) as the fastest of the three EVSI methods, converting the normality assumption directly into a closed-form EVSI with almost no simulation -- but warns it can mislead when net benefit is skewed or multimodal, as with the TB model's rare high-cost failure branch.

### Q572 [Hard] [MCQ]
**Chapter(s):** 26 -- Value of Information Analysis
**Question:** In §26.6's worked ENBS comparison of two proposed trials targeting `p_ontx_fail` (decision-relevant population of 50,000 patients), the small trial (n=200, EVSI/patient=$600, cost=$50,000) and large trial (n=2,000, EVSI/patient=$857, cost=$45,000,000) yield which ENBS outcome, and what is the chapter's stated implication?
- A) Small trial ENBS = $29,950,000; large trial ENBS = -$2,150,000 -- demonstrating that a larger, costlier study can have lower (even negative) expected net benefit than a smaller one targeting the same parameter
- B) Both trials have positive ENBS, with the large trial's ENBS roughly 50% higher than the small trial's
- C) Small trial ENBS = -$2,150,000; large trial ENBS = $29,950,000 -- showing larger trials are always worth funding
- D) Both trials have negative ENBS, implying neither should be funded and implementation support should be prioritised instead
**Answer:** A
**Explanation:** Scaling EVSI to the 50,000-patient population gives total EVSI of $30.0M (small) and $42.85M (large); subtracting trial costs of $50,000 and $45M respectively gives ENBS of $29,950,000 and -$2,150,000 -- the large trial's EVSI gain over the small trial ($12.85M) does not cover its $44.95M cost premium, a genuine non-obvious VOI finding per §26.6.

### Q573 [Medium] [MCQ]
**Chapter(s):** 27 -- Model Calibration, Validation and Quality Assurance
**Question:** In §27.1's TB model example, Nelder-Mead optimization (via R's `optim()`) is used instead of a gradient-based optimizer to calibrate `p_hidden`. Why is Nelder-Mead specifically well-suited to this problem, according to the chapter?
- A) Because the model's output, resulting from discrete Markov cycles, is not a smooth analytic function of `p_hidden`, so a derivative-free method is needed
- B) Because Nelder-Mead always converges faster than gradient-based methods regardless of the function's smoothness
- C) Because Nelder-Mead guarantees a global optimum even when the calibration target is underdetermined
- D) Because `optim()` only implements Nelder-Mead and no gradient-based alternatives
**Answer:** A
**Explanation:** The chapter's difficult-terminology box on Nelder-Mead optimization explains it as a simplex-based, derivative-free search method, and the text notes this matters here "because our model output (a result of discrete Markov cycles) is not a smooth analytic function of `p_hidden`" -- gradient methods need differentiability that the model doesn't provide, while Nelder-Mead is slower to converge but does not require it.

### Q574 [Easy] [MCQ]
**Chapter(s):** 27 -- Model Calibration, Validation and Quality Assurance
**Question:** According to §27.3, what is the purpose of writing `testthat` unit tests for a health-economic model, such as checking that every row of a Markov transition matrix sums to 1?
- A) To check that the model's code behaves as intended, independent of whether it happens to match any external calibration target
- B) To replace the need for calibrating any hidden parameters against a registry target
- C) To establish face validity by having clinical experts review the model's logic
- D) To compare the model's structure against a competing, independently built model of the same decision problem
**Answer:** A
**Explanation:** The chapter's difficult-terminology box defines unit testing as writing small automated checks that confirm specific code behaves as expected, analogous to a hospital's routine quality-control check on a diagnostic machine. §27.3 stresses that verification (unit tests, extreme-value tests, replication) is a separate, more basic question from calibration -- a model could be perfectly calibrated to a target by chance while still containing a coding bug like a transition matrix whose rows don't sum to 1, so unit tests check the code's correctness on its own terms.

### Q575 [Medium] [MCQ]
**Chapter(s):** 28 -- Reproducible Reporting
**Question:** According to the chapter, why is a colour-blind-safe palette (such as viridis) designed to vary lightness and blue-yellow contrast rather than relying on hue (red/green) alone?
- A) Because hue-based palettes render inconsistently between HTML and PDF output
- B) Because red-green confusion is the most common form of colour vision deficiency, so varying lightness/blue-yellow contrast keeps categories distinguishable even when hue information is lost
- C) Because `ggplot2`'s default theme does not support hue-based scales
- D) Because journals require all figures to be printed in true greyscale
**Answer:** B
**Explanation:** §28.5's difficult-terminology box on "colour-blind-safe palette" explains that red-green confusion (deuteranopia/protanopia) affects roughly 1 in 12 men and 1 in 200 women, so such palettes vary lightness and blue-yellow contrast as well as hue -- like traffic lights differing in brightness and position, not just hue -- so the signal survives even if hue information is lost.

### Q576 [Easy] [MCQ]
**Chapter(s):** 28 -- Reproducible Reporting
**Question:** What is "checklist-based reporting," as described in §28.6 in relation to CHEERS 2022?
- A) A requirement that all R code chunks be hidden from the final report
- B) A fixed list of items a report of a given study type must address, with authors expected to state explicitly where each item is covered, functioning like a pilot's pre-flight checklist
- C) A method for automatically generating LaTeX tables from a data frame
- D) A Quarto YAML option that validates numeric results against the underlying model
**Answer:** B
**Explanation:** The difficult-terminology box defines checklist-based reporting as a journal/funder/agency publishing a fixed list of items a report must address, explicitly compared to a pilot's pre-flight checklist -- not a guarantee the flight goes well, but a guarantee obviously necessary steps weren't forgotten.

### Q577 [Medium] [MCQ]
**Chapter(s):** 28 -- Reproducible Reporting
**Question:** What distinguishes a "targets pipeline" (via the `targets` R package) from simply running a `cron` job that re-executes a full reporting script?
- A) A targets pipeline tracks dependencies between analysis steps and only re-runs the steps whose inputs have actually changed, skipping the rest, analogous to a smart build system like `make`
- B) A targets pipeline can only run on Linux, whereas `cron` works cross-platform
- C) A targets pipeline replaces `quarto::quarto_render()` entirely with a Python-based renderer
- D) A targets pipeline eliminates the need for a `_targets.R` file by inferring dependencies from YAML front matter
**Answer:** A
**Explanation:** §28.8's difficult-terminology box describes `targets` as declaring the workflow (data loading, model fitting, report rendering) as named, interdependent steps in `_targets.R`, run via `targets::tar_make()`, which re-runs only steps whose inputs changed -- likened explicitly to `make` for software.

### Q578 [Hard] [MCQ]
**Chapter(s):** 28 -- Reproducible Reporting
**Question:** In the chapter's worked TB model example, the incremental cost is -$844.14 and the incremental QALY is 0.1440. Why does the chapter caution against reporting the resulting ICER of approximately -$5,862 per QALY as a plain "cost saving of $5,862 per QALY gained"?
- A) Because the ICER should instead be computed as incremental QALY divided by incremental cost
- B) Because a negative ICER is ambiguous on its own -- it could also arise from a strategy that is more costly and less effective -- so the dominance relationship (cheaper and more effective) must be stated explicitly by checking the cost-effectiveness plane quadrant
- C) Because `gt::fmt_currency()` cannot correctly format negative dollar values
- D) Because the willingness-to-pay threshold of $50,000 was not used in the ICER calculation
**Answer:** B
**Explanation:** The "dominant / dominance" difficult-terminology box in §28.4 explains that the same negative ICER number could, in a different scenario, signal the opposite situation (more costly and less effective), so the correct habit is always to check which quadrant of the cost-effectiveness plane the incremental results fall into before quoting an ICER.

### Q579 [Easy] [MCQ]
**Chapter(s):** 28 -- Reproducible Reporting
**Question:** Which R package does the chapter recommend as the strongest choice when a publication table's destination format is Word or PowerPoint and it must contain native, directly editable Office elements such as merged cells and specific borders?
- A) `gtsummary`
- B) `kableExtra`
- C) `flextable`
- D) `viridis`
**Answer:** C
**Explanation:** §28.4 identifies `flextable` as the strongest choice when the destination is Word or PowerPoint and the table must look and behave exactly right once there, integrating with `officer`/`officedown` from §28.3.

### Q580 [Medium] [MCQ]
**Chapter(s):** 28 -- Reproducible Reporting
**Question:** A report's YAML front matter declares `params: wtp_threshold: 50000` and the analyst renders the document by clicking "Render" in an IDE without supplying any overrides. According to the pitfall in §28.2, what happens?
- A) The render fails immediately because no parameters were explicitly passed
- B) The report is produced using the YAML block's default parameter values, which may silently differ from the intended scenario's values
- C) Quarto automatically substitutes the most recently used `execute_params` from the last command-line render
- D) The `params` list becomes empty and all `params$...` references throw an error
**Answer:** B
**Explanation:** The §28.2 pitfall warns that YAML `params:` values are defaults used whenever rendering interactively without overrides, and it's easy to forget this and ship a report built with stale defaults rather than intended scenario values -- hence the advice to print the actual `params` list used, visibly, in the rendered output.

### Q581 [Medium] [MCQ]
**Chapter(s):** 28 -- Reproducible Reporting
**Question:** Why does PDF output via Pandoc require a working LaTeX installation on the rendering machine, unlike HTML or Word output?
- A) Because LaTeX is the typesetting engine Pandoc uses under the hood specifically for PDF rendering, analogous to needing a C compiler installed separately to compile a C program
- B) Because PDF files must be generated by converting an intermediate Word document first
- C) Because `quarto::quarto_render()` only supports PDF output on Windows
- D) Because `tinytex` replaces the need for Pandoc entirely when targeting PDF
**Answer:** A
**Explanation:** The "LaTeX" difficult-terminology box in §28.3 states that PDF rendering via Pandoc is not a pure-R, pure-Quarto process -- it requires a working LaTeX installation, just as compiling a C program requires a separately installed C compiler; `tinytex` is the slimmed-down distribution R users typically install for this purpose.

### Q582 [Hard] [MCQ]
**Chapter(s):** 28 -- Reproducible Reporting
**Question:** In §28.7's dossier example, each appendix (`_appendix_clinical.qmd`, `_appendix_costs.qmd`, etc.) is included into a parent document via `{{< include >}}`. What pitfall does the chapter flag about this mechanism?
- A) Child documents cannot read the parent's `params:` block, so each must redeclare its own parameters
- B) Included child documents share the parent's R session state, so two appendices defining an object with the same name (e.g. both calling their data frame `df`) can silently overwrite each other
- C) `{{< include >}}` only works with R Markdown `.Rmd` files, not Quarto `.qmd` files
- D) Each included child document resets figure and table numbering back to 1, breaking cross-references
**Answer:** B
**Explanation:** The §28.7 pitfall explains that child documents share the parent's R session state, including figure/table numbering and variables defined in earlier-included children, so same-named objects across appendices can silently overwrite one another -- the recommended fix is namespacing objects per appendix (e.g. `clinical_df`, `cost_df`).

### Q583 [Medium] [Image]
**Chapter(s):** 28 -- Reproducible Reporting
**Question:** IMAGE PLACEHOLDER: A figure showing a simulated three-arm cost-effectiveness plane under the ggplot2 default qualitative palette (top row) versus the viridis palette (bottom row), each displayed under normal vision (left) and a simulated deuteranopia colour-vision deficiency (right). Under the default palette, two of the three arms become visually indistinguishable once deuteranopia is simulated; under viridis, all three arms remain distinguishable. Based on this figure and the surrounding text, which two arms become confusable under the default palette once deuteranopia is simulated?
- A) "Standard of Care" and "Novel combination"
- B) "Novel combination" and "Shortened 4-month"
- C) "Shortened 4-month" and "Standard of Care"
- D) All three arms remain distinguishable under both palettes
**Answer:** B
**Explanation:** The figure caption in §28.5 states that under the default palette, "Novel combination" and "Shortened 4-month" become visually indistinguishable once deuteranopia is simulated, while all three arms remain distinguishable under viridis.

### Q584 [Medium] [MCQ]
**Chapter(s):** 28 -- Reproducible Reporting
**Question:** In the §28.8 district-looping example, `purrr::pwalk()` is used instead of `purrr::pmap()` to render one TB report per district. Why?
- A) `pwalk()` runs renders in parallel across CPU cores, while `pmap()` is strictly sequential
- B) The point of the loop is the side effect of writing rendered report files to disk, not collecting a return value, and `pwalk()` (like `walk()`) signals that side-effect intent, whereas `pmap()`/`map()` collect outputs
- C) `pmap()` cannot accept a data frame as its argument source, only a list of vectors
- D) `pwalk()` automatically wraps each call in `tryCatch()` to prevent batch failures
**Answer:** B
**Explanation:** §28.8 explains that `pwalk()` is the multi-argument sibling of `walk()`, drawing each call's arguments from a data frame row; both `walk`/`pwalk` are used instead of `map`/`pmap` because the loop's purpose is the side effect of writing files to disk, not collecting a return value -- signalling that intent to later readers of the code.

### Q585 [Easy] [MCQ]
**Chapter(s):** 29 -- Interactive Models and Web Applications with Shiny
**Question:** In the TB model Shiny app, what distinguishes an "observer" (created with `observeEvent({...})` or `observe({...})`) from a reactive expression?
- A) An observer runs for its side effects, such as logging or saving a file, rather than returning a value for display
- B) An observer can only be used inside `downloadHandler()` blocks
- C) An observer automatically caches its result exactly like `reactive({})` does
- D) An observer is the only construct that can read `input$treatment_cost`
**Answer:** A
**Explanation:** Section 29.1's difficult-terminology box on "observer" describes it as code that runs for its side effects (logging a message, saving a file, popping up a warning) rather than returning a value -- "a reactive expression is 'a formula that produces a number,' an observer is 'an action that happens when something changes.'"

### Q586 [Medium] [MCQ]
**Chapter(s):** 29 -- Interactive Models and Web Applications with Shiny
**Question:** According to Section 29.3, what does "hot-reloading" refer to in the context of `golem` and `rhino` Shiny development tooling?
- A) Restarting the production server automatically every time PSA iterations exceed 10,000 draws
- B) Saving a changed source file automatically refreshing the running app in the browser without manually re-launching it
- C) A caching mechanism that lets `reactive({})` expressions skip recomputation when inputs are unchanged
- D) Automatically migrating an app from plain Shiny modules to the `golem` package structure
**Answer:** B
**Explanation:** The difficult-terminology box on "hot-reloading" in Section 29.3 defines it as a development convenience where saving a changed source file automatically refreshes the running app in the browser, likened to `shiny::runApp()` with auto-reload enabled sparing you from repeatedly clicking "Run App."

### Q587 [Medium] [MCQ]
**Chapter(s):** 29 -- Interactive Models and Web Applications with Shiny
**Question:** Per Section 29.6's description of Docker image / containerization, what specific problem does building and running a Shiny app inside a Docker container avoid?
- A) The need to ever use `renv::snapshot()` to pin package versions
- B) The classic "it worked on my machine" problem, since the same image runs identically on a laptop, test server, and production server
- C) The requirement for a reverse proxy to handle HTTPS traffic
- D) The need for input validation using `req()`/`validate()`/`need()`
**Answer:** B
**Explanation:** The chapter defines a Docker image as a self-contained snapshot of the OS, R installation, and packages built from a Dockerfile, and states that containerization means the laptop, test server, and production server "all run the exact same environment, which avoids the classic 'it worked on my machine' problem."

### Q588 [Medium] [MCQ]
**Chapter(s):** 29 -- Interactive Models and Web Applications with Shiny
**Question:** In Section 29.6's discussion of self-hosted Docker deployment, what role does a reverse proxy (commonly nginx or Apache) play?
- A) It runs the Markov model's PSA draws in parallel to speed up computation
- B) It replaces the need for a Dockerfile entirely
- C) It receives public HTTPS traffic and forwards it internally to the Shiny container, handling certificates and routing so the app never deals with raw internet traffic directly
- D) It validates user inputs before they reach `run_markov_model()`
**Answer:** C
**Explanation:** The chapter describes a reverse proxy as a server sitting in front of the actual application, forwarding incoming requests while handling HTTPS encryption, load balancing, and hiding the internal server address -- "like a receptionist who takes every visitor's request and relays it to the right office."

### Q589 [Medium] [MCQ]
**Chapter(s):** 29 -- Interactive Models and Web Applications with Shiny
**Question:** Section 29.7 explains why input validation (via `req()`/`validate()`/`need()`) matters for a web-hosted health-economic model. Why is an unvalidated bad input described as "far more dangerous" than a crash?
- A) Because crashes are always caused by invalid inputs, so validation prevents all server downtime
- B) Because the model may run without error yet produce a meaningless result, such as a negative QALY gain or an ICER of zero, which a reviewer may not notice
- C) Because validation is required by Posit Connect's licensing terms
- D) Because `validate()` automatically logs every input to the audit trail
**Answer:** B
**Explanation:** Section 29.7 states that without input validation, "a model may run without error but produce a meaningless result (a negative QALY gain, an ICER of zero), which is far more dangerous than an obvious crash because a reviewer may not notice."

### Q590 [Hard] [MCQ]
**Chapter(s):** 29 -- Interactive Models and Web Applications with Shiny
**Question:** Section 29.7 defines "penetration testing" and notes that a full formal penetration test is usually reserved for apps handling real patient-level data. For the TB model Shiny app (which uses no real patient data), what lighter checklist does the chapter describe as the practical equivalent most teams can realistically do?
- A) Confirm no server files are browsable, confirm authentication actually blocks unauthenticated access, and confirm input validation cannot be bypassed by unusual values (blank, negative, extremely large, or non-numeric text)
- B) Run `renv::snapshot()` and verify the Dockerfile's base image hash matches production
- C) Deploy to shinyapps.io's free tier instead of Posit Connect to minimize attack surface
- D) Replace all `numericInput()` widgets with `selectInput()` so users cannot type arbitrary values
**Answer:** A
**Explanation:** The difficult-terminology box on "penetration testing" states that a deliberate authorised attempt to find security weaknesses is formally called penetration testing, but "the practical equivalent most teams can realistically do is a lighter checklist: confirm no server files are browsable, confirm authentication actually blocks unauthenticated access, and confirm input validation cannot be bypassed by unusual values."

### Q591 [Medium] [MCQ]
**Chapter(s):** 12 -- Indirect Treatment Comparisons and Network Meta-Analysis
**Question:** In a four-treatment network (A, B, C, D) with C chosen as the reference treatment, how many "basic parameters" does the network have, and what do they represent?
- A) Six basic parameters, one for every possible pairwise comparison among the four treatments
- B) Three basic parameters -- the effects of A, B, and D each relative to the reference C -- from which every other pairwise comparison (e.g. A vs D) can be derived
- C) Four basic parameters, one per treatment, each representing that treatment's absolute effect in isolation
- D) One basic parameter, since a network ultimately reduces to a single pooled treatment effect
**Answer:** B
**Explanation:** The §12.3.3 difficult-terminology box on "basic parameters (of a network)" explains that rather than separately estimating all six pairwise comparisons among four treatments, one treatment is picked as reference (here C) and the basic parameters are just the effects of each other treatment relative to that reference (A-vs-C, B-vs-C, D-vs-C) -- always one fewer than the number of treatments. Every other comparison the league table reports (like D-vs-A) is then derived algebraically from these basic parameters rather than estimated separately.


### Q592 [Easy] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** Per §30.1, what is an R package fundamentally, in contrast to a loose folder of scripts?
- A) A single large script that runs all model functions in sequence
- B) A standardised bundle of R code, documentation, and metadata that R itself can install, load, and check for internal consistency
- C) A compiled binary executable that no longer requires R to run
- D) A cloud-hosted version of the model with no local installation needed
**Answer:** B
**Explanation:** §30.1 defines an R package as a standardised bundle of code, documentation, and metadata that R knows how to install, load, and check for consistency -- the same mechanism behind packages like `dplyr` or `survival` -- replacing the need to manually `source()` a dozen scripts in the right order.

### Q593 [Easy] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** According to §30.2, what is the `DESCRIPTION` file of an R package?
- A) A human-readable Word document describing the model's clinical rationale
- B) A plain-text, machine-readable manifest read by R itself, recording the package name, version, and the `Imports`/`Depends` fields listing required dependencies
- C) The main R script containing the model's core functions
- D) A log file automatically generated after every `devtools::check()` run
**Answer:** B
**Explanation:** §30.2 states the `DESCRIPTION` file is a plain-text file of package metadata read by R, not documentation for humans to browse -- it records name, version, title, author, and the `Imports`/`Depends` fields so R can check required dependencies are present before anything runs.

### Q594 [Medium] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** Under semantic versioning (MAJOR.MINOR.PATCH) as described in §30.2, a health-economic model package moves from version 1.2.0 to 1.3.0. What does this change most likely indicate?
- A) A bug fix was applied that does not change behaviour meaningfully
- B) New functionality was added, but existing code still works as before
- C) A change was made that could break code written against the earlier version
- D) The package was simply renamed with no functional change
**Answer:** B
**Explanation:** §30.2 explains that under semantic versioning, PATCH increases for non-behaviour-changing bug fixes, MINOR increases when new functionality is added while existing code still works, and MAJOR increases when a change could break code written against an earlier version. Going from 1.2.0 to 1.3.0 is a MINOR bump.

### Q595 [Medium] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** Per §30.2, what specific problem does the `NAMESPACE` file solve for an R package?
- A) It stores the version-controlled history of every commit made to the package
- B) It prevents an internal helper function (e.g., one named `clean()`) from silently clashing with a same-named function from a different loaded package, by controlling which functions are exposed to users
- C) It records the exact versions of all dependencies for reproducibility
- D) It generates the browsable documentation website for the package
**Answer:** B
**Explanation:** §30.2 describes `NAMESPACE` as an auto-generated file that tells R which functions are available to a user of `library(heormodel)` versus which are purely internal helpers, which is what prevents an internal helper like `clean()` from clashing with a `clean()` function from an entirely different package.

### Q596 [Medium] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** In the `roxygen2` worked example for `run_markov_model()` in §30.3, what specific consequence follows from omitting the `@export` tag on a function the author intended users to call?
- A) The function is automatically deleted from the `R/` folder
- B) The function remains an internal helper, invisible outside the package -- a common cause of "but it worked when I ran the script directly" confusion
- C) `devtools::check()` will refuse to run until the tag is added
- D) The function's documentation is rendered in red text on the `pkgdown` site
**Answer:** B
**Explanation:** §30.3's terminology box states that `@export` tells `roxygen2` a function should be listed in `NAMESPACE` as user-available; functions without it remain internal helpers invisible outside the package, which is called out as a common source of confusion after packaging.

### Q597 [Hard] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** In the `targets` pipeline example of §30.4 (raw_data -> clean_data -> calibrated_params -> psa_results -> ceac_plot), what does the "pipeline / dependency graph" concept formally capture?
- A) The physical order in which R scripts are saved on disk
- B) The set of computational steps needed to go from raw inputs to final results, together with which steps depend on the outputs of others
- C) A record of which collaborator last edited each function
- D) The list of CRAN mirrors used to download package dependencies
**Answer:** B
**Explanation:** §30.4 defines a pipeline as the set of computational steps from raw inputs to final results plus the fact that some steps depend on others' outputs (e.g., PSA depends on calibrated parameters, which depend on cleaned data) -- `targets` builds this dependency graph explicitly from the code rather than leaving it implicit in script run order.

### Q598 [Medium] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** Per the build cache / memoisation example in §30.4, if a labelling typo in the CEAC plot code is fixed and `tar_make()` is re-run, what happens to the 10,000-simulation PSA step?
- A) It automatically reruns because any change to the pipeline file triggers a full rebuild
- B) It is skipped and its previously stored result is reused, because its own inputs have not changed
- C) It reruns with a reduced number of simulations to save time
- D) `targets` deletes the cached PSA result to force fresh validation
**Answer:** B
**Explanation:** §30.4 explains that `targets`' build cache (memoisation) stores a step's result and reuses it as long as nothing it depends on has changed; fixing a labelling typo in the downstream CEAC plot code means only `ceac_plot` reruns, while the ten-thousand-simulation `psa_results` target is reused unchanged.

### Q599 [Easy] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** Per §30.5, what is continuous integration (CI) as applied to an R-based health-economic model package?
- A) A manual checklist a reviewer completes once before a submission deadline
- B) The practice of automatically building and testing code every time it changes, without relying on a person to remember to run the checks
- C) A method for calibrating transition probabilities automatically
- D) A licensing framework for open-source R packages
**Answer:** B
**Explanation:** §30.5 defines CI as automatically building and testing code every time it changes -- in the HEOR context, every push to GitHub triggers a robot that installs R and dependencies, runs the test suite and `R CMD check`, and reports pass or fail without the author needing to remember to do it.

### Q600 [Easy] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** Per §30.5, what is a YAML workflow file used for in the context of GitHub Actions CI for an R package?
- A) It stores the model's probabilistic sensitivity analysis results
- B) It is a plain-text configuration file telling GitHub Actions what sequence of steps to run and when to run them (e.g., on every push)
- C) It is the compiled output of `devtools::check()`
- D) It replaces the `DESCRIPTION` file for package metadata
**Answer:** B
**Explanation:** §30.5 describes YAML as a human-readable structured configuration format, and a "workflow file" as a YAML file telling GitHub Actions what sequence of steps to run (install R, install packages, run checks) and when (every push, only on main, nightly, etc.).

### Q601 [Hard] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** Per §30.6, why does the chapter recommend pointing an ERG reviewer at a tagged release rather than the live repository's default `main` branch view?
- A) Tagged releases load faster on GitHub's servers than the default branch view
- B) A tagged release is a fixed snapshot that does not change after the fact, so the model a reviewer received, reviewed, and cited in their report are provably the same artifact -- whereas `main` shows whatever changes have been pushed up to that moment
- C) GitHub does not allow read-only collaborator access to the default branch
- D) Tagged releases automatically include a `pkgdown` documentation site while `main` does not
**Answer:** B
**Explanation:** §30.6 explains that a release packages a tagged commit as a stable, downloadable snapshot that does not change after the fact; this matters because if the sponsor pushes a bug fix mid-review, a reviewer looking at `main` would be reviewing a moving target, whereas a tagged release pins exactly what was reviewed and cited.

### Q602 [Medium] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** Per §30.7, what does an "open-source license" legally accomplish when attached to a piece of code?
- A) It automatically transfers copyright ownership to whoever downloads the code
- B) It grants others specific permissions (e.g., to view, use, modify, redistribute) that copyright law would otherwise withhold by default -- code with no license attached carries no such permission, regardless of being publicly visible on GitHub
- C) It guarantees the code has passed `devtools::check()` and all tests
- D) It is required only for packages intended for commercial use
**Answer:** B
**Explanation:** §30.7 states that without an explicit license, "the code is on GitHub" does not mean anyone has the legal right to reuse it -- silence is not permission. A license is a legal document granting permissions that copyright law would otherwise withhold.

### Q603 [Medium] [MCQ]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** Per §30.7's distinction between permissive and copyleft licenses, what is the key practical consequence of licensing a package under the GPL family (copyleft) rather than MIT (permissive)?
- A) GPL-licensed code cannot legally be used by anyone outside the original author's organisation
- B) Any derivative work incorporating the GPL-licensed code must itself be released under the same copyleft license, so it cannot be quietly absorbed into a closed, proprietary product
- C) GPL licensing automatically expires after five years, unlike MIT
- D) MIT-licensed code requires payment of a royalty for commercial reuse, while GPL code does not
**Answer:** B
**Explanation:** §30.7 explains that copyleft licenses (the GPL family) require any derivative work to be released under the same license -- "if you build on this, your building must stay open too" -- meaning copyleft code cannot be quietly absorbed into a closed, proprietary product, unlike permissively-licensed (MIT/Apache/BSD) code.

### Q604 [Hard] [Image]
**Chapter(s):** 30 -- R Packages and Pipelines
**Question:** IMAGE PLACEHOLDER: the ref-table from §30.7 comparing three common license choices (MIT License, GPL-3, CC-BY) across the columns "Commercial reuse allowed?", "Derivatives must stay open?", and "Typical use case". Based on this table, which license is described as typically used for written content, data, and reports rather than code?
- A) MIT License
- B) GPL-3
- C) CC-BY
- D) Apache 2.0
**Answer:** C
**Explanation:** The §30.7 comparison table lists CC-BY as allowing commercial reuse with attribution, not requiring derivatives to stay open, with a typical use case of "written content, data, reports -- not typically used for code," distinguishing it from the code-oriented MIT and GPL-3 entries.

### Q605 [Easy] [MCQ]
**Chapter(s):** 31 -- Agency Requirements and Reference Cases
**Question:** What is a "reference case" in HTA methodology?
- A) A legal contract between an agency and a manufacturer specifying price
- B) An agency's defined "house style" for the base-case analysis -- a fixed set of choices (perspective, outcome measure, discount rate, time horizon) every submission must follow unless justified otherwise
- C) A database of past appraisal decisions used only for audit purposes
- D) A single numeric cost-effectiveness threshold published by the WHO
**Answer:** B
**Explanation:** As defined in the difficult-terminology box in Section 31.1, a reference case is a fixed set of methodological choices that allows submissions from different companies and diseases to be compared on a like-for-like basis; scenario/sensitivity analyses may deviate from it, but the base case cannot without justification.

### Q606 [Medium] [MCQ]
**Chapter(s):** 31 -- Agency Requirements and Reference Cases
**Question:** What is Ayushman Bharat PM-JAY, and why does it matter for HTAIn's work?
- A) A private health insurance provider that commissions independent ERG critiques in India
- B) India's DSU Technical Support Document series equivalent to NICE's TSDs
- C) India's flagship public health insurance scheme providing cashless hospitalisation cover to lower-income households; HTAIn assessments feed into decisions about what its benefit package covers and at what reimbursement rate
- D) A WHO-run threshold-setting committee for South Asian countries
**Answer:** C
**Explanation:** Per Section 31.3's difficult-terminology box, PM-JAY is India's 2018-launched flagship public health insurance scheme, and it is the policy vehicle that HTAIn technology assessments ultimately feed into -- the Indian analogue of what a NICE guidance recommendation does for the NHS.

### Q607 [Medium] [MCQ]
**Chapter(s):** 31 -- Agency Requirements and Reference Cases
**Question:** How does the iDSI reference case for LMIC settings relate to an agency reference case like NICE's, and what is its most debated recommendation?
- A) It is unrelated to the NICE concept; its main recommendation is a mandatory societal perspective
- B) It is the same general concept (a standardised checklist of methodological choices so evaluations can be fairly compared) but aimed at countries without their own, and its most debated element is the willingness-to-pay threshold -- historically the 1-3x GDP-per-capita heuristic
- C) It replaces QALYs with life-years as the only permitted outcome measure
- D) It is a legally binding international treaty enforced by the WHO on all LMIC governments
**Answer:** B
**Explanation:** Section 31.4's difficult-terminology box states a reference case is a standardised checklist (perspective, discount rate, uncertainty handling, comparators) so different models can be fairly compared, and that iDSI's version targets countries lacking their own; the chapter identifies the WTP threshold -- especially the now-deprecated 1-3x GDP-per-capita heuristic -- as its most consequential and debated recommendation.

### Q608 [Easy] [MCQ]
**Chapter(s):** 31 -- Agency Requirements and Reference Cases
**Question:** What is an Evidence Review Group (ERG) in the NICE Technology Appraisal process?
- A) A NICE internal staff committee that sets the final GBP20,000-30,000/QALY threshold
- B) The manufacturer's own in-house health economics team
- C) An independent team, usually university-based health economists and clinicians (not NICE staff, not the manufacturer), commissioned to critically check a company's submitted model and evidence before the committee decides
- D) A patient advocacy panel that votes on whether a drug should be reimbursed
**Answer:** C
**Explanation:** Section 31.6's difficult-terminology box defines the ERG as an independent, usually academic team performing a structured, published peer review of the submitted cost-effectiveness model, with the company then given a formal chance to respond via technical engagement.

### Q609 [Hard] [MCQ]
**Chapter(s):** 31 -- Agency Requirements and Reference Cases
**Question:** Why is a "reference case" (as generically defined) distinct from the "Reference case (LMIC context)" discussion in Section 31.4, even though both boxes define the same underlying term?
- A) The LMIC box redefines a reference case as a legally binding treaty rather than a methodological checklist
- B) They describe the same core concept, but Section 31.4's box emphasizes that iDSI's reference case is specifically aimed at countries that do not yet have their own established one, unlike NICE's or CADTH's long-standing in-house versions
- C) The generic reference case concept applies only to discount rates, while the LMIC version applies only to WTP thresholds
- D) The LMIC reference case box states that iDSI's reference case overrides and replaces NICE's for any multinational submission
**Answer:** B
**Explanation:** Both difficult-terminology boxes describe a reference case as a standardised methodological checklist enabling fair comparison across submissions; the distinguishing point raised in 31.4 is that the iDSI reference case exists precisely because many LMICs lack their own established reference case, unlike the mature NICE/CADTH versions covered earlier in the chapter.

### Q610 [Medium] [MCQ]
**Chapter(s):** 31 -- Agency Requirements and Reference Cases
**Question:** According to the Section 31.5 agency comparison table, which agency's approach deliberately avoids stating a cost-per-QALY threshold "by design" rather than simply omitting one?
- A) NICE (UK)
- B) PBAC (Australia)
- C) IQWiG/G-BA (Germany)
- D) ICER (USA)
**Answer:** C
**Explanation:** The table and surrounding prose state IQWiG/G-BA uses an efficiency-frontier method with "no cost/QALY threshold by design" -- the chapter explicitly notes this is a considered methodological stance (tied to the AMNOG early benefit assessment process), not an omission.

### Q611 [Medium] [Image]
**Chapter(s):** 31 -- Agency Requirements and Reference Cases
**Question:** IMAGE PLACEHOLDER: The Section 31.5 six-column agency comparison table (Agency, Perspective, Discount, WTP threshold, Comparator, Uncertainty) listing NICE, CADTH, PBAC, IQWiG/G-BA, HAS, ICER, and HTAIn. Based on this table, which agency's discount rate is explicitly listed as a fixed base-case percentage different from NICE's 3.5%?
- A) CADTH -- "Per current guidance"
- B) PBAC -- "5% base case"
- C) HAS -- "Varies by guidance"
- D) HTAIn -- "Per Indian guidance"
**Answer:** B
**Explanation:** Among the table's entries, PBAC (Australia) is the one with an explicit fixed numeric discount rate stated in the table -- "5% base case" -- unlike CADTH, HAS, and HTAIn, whose discount conventions are described only qualitatively ("per current guidance," "varies by guidance," "per Indian guidance").

### Q612 [Hard] [MCQ]
**Chapter(s):** 31 -- Agency Requirements and Reference Cases
**Question:** The chapter's R code example for an HTAIn-facing model parameterises a cost input across three scenarios: pmjay_tariff, public_tertiary, and private_estimate. What practical India-specific issue is this pattern designed to address?
- A) The requirement to report results in both INR and USD simultaneously
- B) The wide spread in unit costs for a given procedure across public, private, and PM-JAY empanelled-hospital tariffs, given sparser and more heterogeneous Indian cost data than UK/Canadian registries
- C) A legal mandate that all HTAIn submissions must include exactly three discount rate scenarios
- D) The need to convert QALYs into DALYs for every HTAIn submission
**Answer:** B
**Explanation:** Section 31.3 explains that Indian unit costs vary substantially between public, private, and PM-JAY empanelled-hospital tariffs, and that data sparsity relative to NHS/CIHI registries pushes HTAIn-facing models toward treating data-source assumptions as a first-class sensitivity dimension -- illustrated by the unit_cost_scenarios code example.

### Q613 [Easy] [MCQ]
**Chapter(s):** 31 -- Agency Requirements and Reference Cases
**Question:** According to Section 31.2, why can a model built strictly to NICE's reference case not simply be "relabeled" for a German IQWiG/G-BA submission under AMNOG?
- A) Because Germany requires all models to be built in a different programming language than R
- B) Because IQWiG's early benefit assessment is explicitly not a cost-effectiveness exercise -- it centres patient-relevant outcomes relative to a comparator and produces an additional-benefit rating that feeds into price negotiation, not an ICER-versus-threshold decision
- C) Because Germany does not allow QALYs to be measured using the EQ-5D instrument
- D) Because German law requires a 10% discount rate on all cost inputs
**Answer:** B
**Explanation:** The chapter states that AMNOG's early benefit assessment centres patient-relevant outcomes and produces an "additional benefit" rating used in price negotiation rather than a cost-per-QALY decision, so a NICE-style QALY/ICER model needs substantial reworking -- not relabeling -- for a German submission.
