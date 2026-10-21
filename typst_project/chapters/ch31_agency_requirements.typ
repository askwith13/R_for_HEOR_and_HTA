#import "../common.typ": *

= Chapter 31. Agency Requirements and Reference Cases

#learning-objectives((
  [Explain NICE's reference case, the role of the DSU Technical Support Document series, and what NICE's submission template practically expects from an R-based model.],
  [Compare the methodological requirements of CADTH, PBAC, ICER, G-BA/IQWiG and HAS, and explain why a model built for one agency's reference case may need real rework for another.],
  [Describe HTAIn's reference case and PM-JAY's policy role in India, and the practical data and capacity considerations that shape an India-facing R model.],
  [Explain the iDSI reference case for LMIC settings, the move away from the 1-3x GDP-per-capita WTP heuristic, and the practical capacity advantages of an open-source R workflow in resource-constrained HTA settings.],
  [Compare evidence requirements (perspective, discount rate, WTP threshold, comparator rules, uncertainty-analysis expectations) across the major agencies covered in this chapter.],
  [Use a parameterised R model to respond efficiently and reproducibly to an Evidence Review Group's technical engagement critique.],
))

Chapter 30 closed with a model that can be built, packaged, documented, piped, tested, shared, and licensed -- the full technical toolkit for getting an R-based health-economic model out of one analyst's laptop and into a form other people can run, trust, and scrutinise. This chapter turns from *how* a model is built and shared to *what the agencies receiving it actually require*. Chapter 1 introduced the global HTA landscape at a high level, including a comparison table of the major agencies; this chapter goes deeper into each one's specific methodological requirements, and into the very practical question of what an R-based analyst's workflow needs to produce to satisfy each agency's submission template -- and how to respond, in R, when an Evidence Review Group comes back with a critique.

== 31.1 NICE: reference case, DSU technical support documents, and submission templates

Of all the agencies in the Chapter 1 comparison table, the UK's National Institute for Health and Care Excellence (NICE) has the most codified, most R-analyst-relevant set of requirements, which is why it opens this chapter. NICE's methodological preferences for the base-case analysis are collectively known as the *reference case* -- not a single document so much as a checklist embedded in its methods guide. The reference case specifies: an NHS and Personal Social Services (PSS) perspective on costs (meaning costs borne by other sectors -- social care outside PSS, patient out-of-pocket costs, productivity losses -- are reported separately if at all, not folded into the base case); quality-adjusted life years (QALYs), usually derived from the EQ-5D, as the measure of health outcome; a lifetime time horizon when the condition and treatment effects justify it; and an annual discount rate of 3.5% applied to both costs and outcomes (with exceptions for very long-term effects). NICE's cost-effectiveness threshold is not a hard rule but is conventionally referenced as a range of GBP20,000-GBP30,000 per QALY gained, with willingness to flex upward for end-of-life and some highly specialised technologies.

#difficult-terminology("reference case")[
  A reference case is an agency's defined "house style" for the base-case (primary) cost-effectiveness analysis -- a fixed set of choices (perspective, outcome measure, discount rate, time horizon) that every submission must follow unless explicitly justified otherwise. It exists so that models submitted by different companies, for different diseases, can be compared on a like-for-like basis by the committee. Scenario and sensitivity analyses can deviate from it; the base case cannot, without justification.
]

The authoritative methods guidance sitting underneath the reference case is the NICE Decision Support Unit (DSU) Technical Support Document (TSD) series, introduced in the Chapter 1 agency table and already drawn on repeatedly in Chapters 27-30 for specific modelling choices. TSD 12 on probabilistic sensitivity analysis is the one you will cite most often in a submission's PSA appendix, since NICE committees expect PSA as standard practice rather than an optional extra. The survival-analysis-focused documents and decision-modelling documents referenced elsewhere in this book's agency table are the other DSU documents an R-based HTA analyst will have open on a second monitor during a submission build. None of these documents prescribe R specifically -- NICE's templates are software-agnostic -- but they prescribe *outputs* (deterministic base case, scenario table, cost-effectiveness acceptability curve, one-way and probabilistic sensitivity results) that an R pipeline like the one built across Part VI naturally produces.

The Technology Appraisal (TA) process itself, recapped briefly here since Chapters 27-30 covered it in the context of building toward a submission, runs: company submission -> Evidence Review Group (ERG) critique -> technical engagement (a structured written exchange where the company responds to ERG and committee queries, often including requests for new analyses run on short notice) -> committee meeting -> guidance. The technical engagement stage is where an R-based workflow earns its keep most visibly: a committee or ERG query that would require days of rebuilding in a locked Excel workbook can often be answered same-day by re-running a parameterised R model with a changed assumption.

#agency-note[
  NICE's company submission template explicitly asks for a fully executable economic model to be provided alongside the written submission, not merely results -- the ERG's job is to independently interrogate it. This is the regulatory anchor for the model-packaging and reproducibility discipline covered in Chapter 30: an R model shared as a tangle of uncommented scripts with hard-coded file paths will fail the "transparent and consistent with the NICE reference case" bar before the ERG even reaches the economics.
]

Practically, what does the template expect from an R-based analyst? Four deliverables, at minimum: the deterministic base case (point estimates of costs, QALYs, incremental cost-effectiveness ratio against each relevant comparator); a structured table of scenario analyses showing how the ICER moves under each reference-case-deviation the company considers plausible; the full PSA output set (cost-effectiveness plane scatter, cost-effectiveness acceptability curve, and summary statistics across simulations); and a completed NICE submission checklist cross-referencing which reference-case element is satisfied where. None of this is exotic from an R standpoint -- it is the same simulation, summarisation, and plotting pipeline from Chapters 28-30, run and packaged to a fixed template rather than to an arbitrary report format.

#heor-practice[
  Build your R project so the base case, scenario analyses, and PSA are three *calls* into the same underlying model function with different argument sets, not three separately maintained scripts. NICE's technical engagement stage routinely asks for one more scenario than you originally planned for; if producing it means editing the model in three places, you will eventually make it correct in only two of them.
]

== 31.2 CADTH, PBAC, ICER, G-BA/IQWiG and HAS

Outside the UK, five agencies dominate the practical experience of most R-based HEOR analysts, and each has its own methodological personality distinct enough that a model built strictly to the NICE reference case will not drop in unchanged. This section tours each briefly, grounding every claim in the named guideline documents already introduced in the Chapter 1 agency comparison table.

Canada's CADTH (Canadian Agency for Drugs and Technologies in Health) publishes its own *Guidelines for the Economic Evaluation of Health Technologies in Canada*, which specifies a public healthcare payer perspective as the reference case, a lifetime time horizon by default, and -- distinctively relative to NICE -- an explicit expectation that CADTH's own reviewers will conduct an independent *reanalysis* of the submitted model using the company's own code wherever feasible, rather than relying solely on a critique narrative. This reanalysis culture is the single most important practical fact for an R-based submission to Canada: your model needs to run cleanly on someone else's machine, with someone else's parameter overrides, on the first attempt.

Australia's Pharmaceutical Benefits Advisory Committee (PBAC) works from the *PBAC Guidelines* (Version 5.0, 2016, as already cited in Chapter 29's discussion of its stepped economic evaluation process), which lay out a five-step submission structure and are unusually prescriptive about sensitivity and uncertainty analysis -- PBAC submissions are expected to present not just a PSA but a structured multivariate sensitivity narrative explaining *which* parameters drive uncertainty and why, reflecting PBAC's long institutional emphasis on uncertainty as a decision-relevant quantity in its own right rather than a compliance checkbox.

Germany's combination of the Federal Joint Committee (G-BA) and the Institute for Quality and Efficiency in Health Care (IQWiG) runs what the Chapter 1 table flagged as *early benefit assessment* (Fruhe Nutzenbewertung) under the AMNOG process -- methodologically distinctive because it is explicitly not a cost-effectiveness exercise in the NICE/CADTH sense. IQWiG's *General Methods* paper, its standing methods document, centres the assessment on patient-relevant outcomes (mortality, morbidity, health-related quality of life, safety) relative to an appropriate comparator therapy, with the *additional benefit* rating (from "major" down to "no proven additional benefit") feeding directly into price negotiation rather than into an ICER-versus-threshold decision. An R model built around QALYs and an ICER therefore needs substantial reworking -- not relabeling -- to serve a German submission, since the core decision-relevant output is a benefit categorisation, not a cost per QALY.

ICER (the Institute for Clinical and Economic Review) occupies a different institutional position again: it is a US non-government, non-statutory body, so its value-assessment framework reports do not bind any payer directly, yet they carry substantial influence over US payer and pharmacy-benefit negotiations precisely because no statutory US HTA body fills that role. ICER's reports typically present both a traditional cost-per-QALY analysis and an equal-value-of-life-years-gained variant, reflecting ongoing US debate over QALY-based valuation.

France's Haute Autorite de Sante (HAS) publishes its own *Economic Evaluation Guidance*, which like NICE centres cost-utility analysis and QALYs, but applies a different discount rate convention and a collective (broader societal) costing orientation for certain analyses rather than a strict payer-only perspective, alongside its distinctive *clinical added value* (ASMR) rating that, similarly to the German system, interacts with price negotiation rather than operating purely through a cost-effectiveness threshold.

#pitfall[
  Do not assume a single global reference case that you can satisfy once and relabel for each market. Discount rates, perspective (payer-only versus societal), comparator selection rules, and even the *type* of decision the economic analysis is meant to inform (threshold-based acceptance versus price negotiation input) genuinely differ across CADTH, PBAC, IQWiG/G-BA, HAS, and NICE. A model architected so that perspective, discount rate, and comparator are parameters rather than hard-coded constants (the pattern recommended in Chapter 30) turns a multi-market submission from a rebuild into a re-parameterisation -- but only if that flexibility was designed in from the start.
]

#agency-note[
  CADTH's reanalysis expectation and PBAC's Guidelines' emphasis on explaining sensitivity-analysis drivers are two of the more concrete, checkable requirements in this list: a CADTH submission package that cannot be independently re-run by a reviewer, or a PBAC submission whose sensitivity analysis is a table of numbers with no accompanying narrative of which parameters matter and why, both fall short of what each agency's guidance actually asks for -- independent of whether the underlying economics is sound.
]

== 31.3 HTA in India: HTAIn, the Indian reference case, and Ayushman Bharat PM-JAY

India's Health Technology Assessment in India (HTAIn) initiative, housed within the Department of Health Research and briefly introduced in the Chapter 1 agency table, is the youngest institution in this chapter's tour, and it is worth being honest about what that means in practice rather than overstating its methodological specificity. HTAIn has published its own *HTAIn Reference Case for Economic Evaluation*, drawing explicitly on ISPOR good-practice guidance for the core structural choices -- a public healthcare system perspective, QALYs or disability-adjusted life years depending on the assessment, and PSA expected as part of a complete submission, broadly similar in shape to the NICE/CADTH pattern this chapter opened with. But as the Chapter 1 table already flagged, the Indian reference case is still maturing: compared with NICE's multi-decade DSU TSD series or CADTH's established reanalysis culture, HTAIn's guidance leaves more methodological choices (discount rate conventions in edge cases, comparator selection rules for therapy areas without an established standard of care, handling of equity considerations) to case-by-case judgement rather than codified precedent. An analyst working on an India-facing submission should treat HTAIn's reference case as a genuine and binding starting point, not as a document with a NICE-DSU-equivalent depth of precedent to lean on for every modelling decision.

#difficult-terminology("Ayushman Bharat PM-JAY")[
  Ayushman Bharat Pradhan Mantri Jan Arogya Yojana (PM-JAY) is India's flagship public health insurance scheme, launched in 2018, providing eligible lower-income households with cashless hospitalisation cover up to a defined annual sum per family. It matters to HTA because it is the policy vehicle that many HTAIn technology assessments ultimately feed into: an assessment is not purely an academic cost-effectiveness exercise but an input into decisions about what PM-JAY's benefit package covers and at what reimbursement rate, which is the Indian analogue of what a NICE guidance recommendation does for the NHS.
]

For an R-based analyst actually doing this work -- and this book's own grounding in India-based CTD, Expand ELEVATE, and TB programme experience is directly relevant here -- the practical texture of an HTAIn-facing model differs from a UK or Canadian one in a few concrete ways. First, real-world Indian cost and outcomes data are often genuinely sparser or more heterogeneous than the registries and routinely-collected NHS/CIHI data that UK and Canadian models can lean on: unit costs for a given procedure can vary substantially between public, private, and PM-JAY empanelled-hospital tariffs, and utility weight sources suitable for an Indian population are a smaller, less standardised literature than the EQ-5D crosswalks NICE submissions draw on. This pushes HTAIn-facing models toward wider, more explicitly structured parameter uncertainty and toward scenario analyses that vary data source assumptions as a first-class sensitivity dimension, not an afterthought.

```r
# Example: parameterising a cost input by data-source scenario
# rather than hard-coding a single "the" unit cost -- a pattern
# that matters more for India-facing models than UK ones, given
# the wider spread across public, private, and PM-JAY tariffs.
# run_cea_model() is the same pure cost-effectiveness function
# from Chapters 17-27, re-parameterised, not a new model.
unit_cost_scenarios <- list(
  pmjay_tariff      = 4200,   # PM-JAY empanelled package rate (INR)
  public_tertiary   = 6800,   # observed public tertiary hospital cost
  private_estimate  = 15500   # published private-sector cost estimate
)

run_scenario <- function(unit_cost, ...) {
  # same model function as the base case, just re-parameterised
  run_cea_model(unit_cost = unit_cost, ...)
}

results <- lapply(unit_cost_scenarios, run_scenario)
```

Second, because HTAIn's reference case is still maturing and because a model built for an India submission is frequently adapted from, or benchmarked against, a model originally built to a different jurisdiction's reference case (a global HEOR team's NICE- or CADTH-shaped base model, repurposed for an India-facing submission), the parameterised, non-locked-Excel architecture argued for throughout Part VI pays off particularly clearly here. Swapping perspective, discount rate, comparator, and cost-source assumptions in a well-structured R model is a matter of changing function arguments and re-running; the same adaptation in a spreadsheet model built around one jurisdiction's hard-coded assumptions typically means rebuilding sheets.

#heor-practice[
  When adapting a model originally built to another agency's reference case for an HTAIn submission, keep an explicit, version-controlled record of exactly which parameters changed and why (perspective, discount rate, comparator, cost source) rather than treating the India version as "the same model, different numbers." The still-maturing state of HTAIn's own guidance means reviewers are more likely to ask you to justify these choices from first principles, and a clean audit trail is the fastest way to answer that query.
]

#agency-note[
  Treat any specific procedural claim about HTAIn beyond what is stated in its published Reference Case for Economic Evaluation document with appropriate caution: unlike NICE's DSU TSD series or PBAC's Guidelines Version 5.0, HTAIn does not yet have a comparably deep public library of topic-specific methods guidance, and an analyst should confirm current submission requirements directly with HTAIn rather than assuming precedent from other jurisdictions carries over.
]

== 31.4 HTA in LMICs: iDSI reference case, thresholds and capacity

Most of this chapter's agencies -- NICE, CADTH, PBAC, IQWiG/G-BA, HAS -- operate inside well-resourced health systems with decades of routinely collected cost and outcomes data, large standing analytical teams, and legal mandates that make HTA a condition of reimbursement. Lower- and middle-income countries (LMICs) are building HTA capacity without most of that infrastructure already in place. The *International Decision Support Initiative* (iDSI) was established specifically to fill this gap: a network of academic and technical partners (anchored at institutions including the University of York's Centre for Health Economics and Imperial College London) that produced a *reference case for economic evaluation* aimed at LMIC settings, alongside practical tools, training programmes, and country-level technical assistance (notably supporting priority-setting institutions in countries such as Indonesia, Rwanda, and Myanmar as they stood up national HTA functions).

#difficult-terminology("Reference case (LMIC context)")[
  A reference case is a standardised checklist of methodological choices -- perspective, discount rate, how to handle uncertainty, what comparators to include -- that a government or agency asks every economic evaluation submitted to it to follow. It exists so that two different models, built by two different teams, produce numbers that can be fairly compared against each other and against a common decision rule. NICE's methods guide is a reference case; iDSI's is a reference case aimed at countries that do not yet have their own.
]

The iDSI reference case covers familiar ground -- perspective, time horizon, discounting, handling of uncertainty -- but its most consequential and most debated recommendation concerns the *willingness-to-pay (WTP) threshold*: the cost-per-QALY (or cost-per-DALY-averted) figure below which an intervention is judged worth funding. For many years, the default heuristic recommended by the World Health Organization was that interventions costing less than one to three times a country's GDP per capita per DALY averted were "cost-effective." This 1-3x GDP-per-capita rule is now widely regarded in the health economics literature as poorly grounded: it was never derived from an actual opportunity-cost analysis of what a health system gives up to fund a new intervention, it produces thresholds that scale mechanically with national income rather than with the marginal productivity of the health budget, and in practice it has tended to label almost everything "cost-effective," which is of limited use for prioritisation. The WHO itself backed away from recommending it as a decision rule.

The methodologically more defensible alternative -- following work associated with the York Centre for Health Economics on NICE's own supply-side cost-effectiveness threshold, and analogous opportunity-cost estimation exercises attempted in several LMICs -- is to estimate the threshold from the *health opportunity cost* of displaced spending: given a fixed health budget, what health is forgone elsewhere in the system if a new, more expensive intervention is funded instead? This is conceptually cleaner but empirically much harder, requiring routine data linking health expenditure to health outcomes at the margin -- exactly the kind of data infrastructure many LMICs are still building. iDSI guidance has generally steered countries toward building local opportunity-cost evidence where feasible rather than importing a GDP-multiple threshold uncritically, while being realistic that in the interim, informal or provisional thresholds often still have to be used for individual appraisal decisions.

#agency-note[
  The iDSI Reference Case for Economic Evaluation in Global Health (2014, updated through subsequent iDSI methods guidance) is the primary citable document here, alongside WHO's own CHOICE programme materials, which explicitly caution against mechanical use of the 1-3x GDP-per-capita threshold as a standalone decision rule.
]

Capacity constraints shape how these reference cases get implemented in practice, not just what they recommend. Many LMIC HTA units have small technical teams -- sometimes a handful of analysts covering an entire national formulary -- without routine access to the registries, claims data, or costing studies that a NICE or CADTH submission can draw on. Two practical consequences follow directly from themes earlier in this book. First, model *transparency and transferability* matter more here than almost anywhere else: a well-parameterised R model (Chapters 17-27) that separates data inputs from structural assumptions can be adapted to local epidemiology and costs by a small team far more tractably than re-building a model from scratch, and can be audited by external reviewers without needing the original authors present. Second, the zero-licensing-cost nature of R relative to commercial platforms such as TreeAge Pro or discrete-event simulation suites (Chapter 30) is not a minor convenience in this setting -- it is often the determining factor in whether a national HTA unit can run independent re-analyses at all, rather than depending entirely on submissions it cannot verify.

#heor-practice[
  If you are supporting HTA capacity-building in an LMIC, prioritise reproducibility over sophistication. A simple, well-documented three-state Markov model in R that a local analyst can rerun, audit, and extend is worth more to a nascent HTA system than an elaborate but opaque model that only the original consultant can maintain.
]

#pitfall[
  Do not treat the 1-3x GDP-per-capita threshold as if it were still recommended current practice -- citing it uncritically as "the" LMIC cost-effectiveness threshold in a submission or paper is a dated framing that most contemporary health economists and the WHO itself have moved away from.
]

== 31.5 Comparing evidence requirements across agencies

Sections 31.1-31.3 introduced NICE, CADTH, PBAC, IQWiG/G-BA, HAS, ICER, and HTAIn individually. Submitting the same intervention to several of these agencies -- increasingly common for multinational launches -- means confronting real differences in what each one requires, not just cosmetic formatting differences. The table below collects the practical dimensions that most often require rework between submissions: analytic perspective, discounting convention, how (or whether) a WTP threshold is stated, comparator requirements, and expectations around uncertainty analysis.

#shiny-app-box("cross_agency_decision_explorer", [Pick an HTA agency and drag an ICER value and watch live whether it falls below or above that agency's stated or inferred WTP threshold.])

#ref-table(
  [Comparison of key methodological requirements across major HTA agencies],
  academic-table(
    columns: (1fr, 1.1fr, 0.9fr, 1.1fr, 1.1fr, 1.1fr),
    align: (left, left, left, left, left, left),
    header: ([*Agency*], [*Perspective*], [*Discount*], [*WTP threshold*], [*Comparator*], [*Uncertainty*]),
    body: (
      [NICE (UK)], [NHS/PSS], [3.5%], [GBP20-30k/QALY (implicit range)], [All relevant NHS comparators], [PSA standard],
      [CADTH (Canada)], [Payer primary; societal supplementary], [Per current guidance], [Not formally stated], [Canadian-practice comparators], [PSA + deterministic SA],
      [PBAC (Australia)], [Healthcare system; societal considered], [5% base case], [Not fixed; case-by-case], [Displaced therapy, justified], [Strong univariate + PSA tradition],
      [IQWiG/G-BA (Germany)], [SHI perspective; efficiency-frontier], [Set federally], [No cost/QALY threshold by design], [Fixed via G-BA consultation], [Sensitivity on efficiency frontier],
      [HAS (France)], [Collective; societal supplementary], [Varies by guidance], [Not published], [SMR/ASMR framework], [SA expected; PSA growing],
      [ICER (USA)], [Healthcare sector; modified societal], [US Panel convention], [Tens of thousands \$/QALY], [US-practice, public input], [PSA standard],
      [HTAIn (India)], [Societal], [Per Indian guidance], [Opportunity-cost/GDP-based, still refining], [Indian standard of care], [SA expected; PSA varies],
    ),
    footer: none,
  ),
) <tab-ch31-agency-comparison>

#heor-practice[
  This table is intentionally compressed to fit one page; the full reasoning behind each agency's approach -- including the real caveats and hedges about where public documentation is thin -- is in Sections 31.1-31.4 above. Treat this table as a quick-reference index back into that prose, not a substitute for it.
]


A few patterns are worth drawing out rather than reading the table as a flat list of trivia. Perspective and comparator choice are where genuine model rebuilding is most often required -- a societal perspective model needs productivity-loss and informal-care cost inputs that a payer-perspective model simply omits, and a comparator accepted in one jurisdiction's clinical practice may be irrelevant in another's. Discount rates, by contrast, are usually a single parameter change if your model is structured correctly -- which is precisely the point of the next section. And the presence or absence of an explicit WTP threshold does not track neatly with how "evidence-based" an agency is: IQWiG/G-BA's deliberate avoidance of a cost-per-QALY threshold in favour of the efficiency-frontier method is a considered methodological stance, not an omission.

#heor-practice[
  Structure your R model so that perspective, discount rate, and comparator set are *objects passed into a function*, not values baked into the model logic -- for example `run_model(perspective = "payer", disc_rate = 0.035, comparators = c("standard_care"))`. A model built this way can be re-pointed at a different agency's discount convention or PBAC's 5% base case in minutes. A rigid Excel workbook with these assumptions hardcoded into formula cells across multiple sheets typically needs a partial rebuild for every new agency submission -- exactly the fragility problem Chapter 30 raised about spreadsheet-based HTA models.
]

#agency-note[
  CADTH's current discount-rate and perspective guidance is set out in the *CADTH Guidelines for the Economic Evaluation of Health Technologies: Canada*. PBAC's requirements are detailed in the *PBAC Guidelines for preparing a submission* (Version 5.0, 2016), which sets out its comparator-justification and uncertainty-analysis expectations explicitly.
]

== 31.6 Responding to technical engagement and evidence review group critiques with R

Submitting a model is rarely the end of the process. At NICE, the submitted evidence goes to an independent *Evidence Review Group (ERG)* -- an academic team commissioned to critically appraise the manufacturer's model and clinical evidence -- whose report typically includes a list of clarification questions and requested exploratory analyses. These are worked through in a structured dialogue NICE calls *technical engagement*, where the committee and ERG raise specific, often very concrete, methodological challenges before a final recommendation is made. Equivalent critique-and-response stages exist elsewhere: CADTH's clinical and economic reviewers issue similar requests for reanalysis, PBAC's evaluation process generates "pre-PBAC response" requirements, and IQWiG's early benefit assessment process involves comparable rounds of methodological challenge from IQWiG and subsequently the G-BA.

#difficult-terminology("Evidence Review Group (ERG)")[
  An ERG is an independent team -- usually university-based health economists and clinicians, not NICE staff and not the manufacturer -- commissioned to critically check a company's submitted model and evidence before the appraisal committee makes a decision. Think of it as a structured, published peer review of the cost-effectiveness model, with the company given a formal opportunity to respond to its criticisms.
]

A typical ERG critique is not a vague objection; it is usually a precise, actionable instruction: "please rerun the base case using a 6% discount rate instead of 3.5%," or "please provide results using an alternative survival extrapolation to the one used in the base case," or "please explore the ICER under a wider set of PSA iterations with correlated parameter draws." Each of these is, computationally, a request to call your existing model function with different arguments -- _provided_ the model was built the parameterised way this book has argued for throughout Chapters 17-27, and packaged and tested the way Chapter 30 described. If discount rate, extrapolation choice, or correlation structure were hardcoded into the model's internals rather than passed in as arguments, satisfying this kind of request means re-engineering the model under deadline pressure, exactly when you can least afford to introduce an error. If they were parameterised from the start, it means changing one function argument and re-running.

The TB Markov model developed earlier in this book had a base-case incremental cost of -\$844.14 and incremental QALY gain of 0.1440 at its original discount rate. Suppose an ERG query asks for the ICER recalculated at a different discount rate. The workflow -- not the specific new numbers, which genuinely would differ and cannot be derived without rerunning the full model -- looks like this:

```r
# Base-case PSA/ICER run (original discount rate, e.g. 3.5%)
# run_tb_model() is the same pure TB Markov PSA function built
# across Chapters 17-27 and packaged in Chapter 30 -- not redefined
# here, called with its existing argument interface.
base_case <- run_tb_model(
  n_sim      = 10000,
  disc_rate  = 0.035,
  disc_costs = 0.035,
  disc_qalys = 0.035
)
# base_case$icer gives the committee's reference ICER,
# built on incr_cost = -844.14, incr_qaly = 0.1440

# ERG technical-engagement request: "please rerun at 6% discounting"
erg_scenario <- run_tb_model(
  n_sim      = 10000,
  disc_rate  = 0.06,
  disc_costs = 0.06,
  disc_qalys = 0.06
)

# Compare ICERs and re-render the Quarto evidence report (Ch.28)
# with the new scenario slotted in as an additional results section
quarto::quarto_render(
  "tb_model_report.qmd",
  execute_params = list(scenario = "erg_discount_6pct")
)
```

Because `run_tb_model()` accepts the discount rate as an argument rather than having it baked into the Markov transition or cost-accumulation logic, the ERG response becomes a same-day turnaround: rerun, inspect the new ICER and cost-effectiveness acceptability curve, and feed the result straight into the parameterised Quarto report from Chapter 28, which regenerates tables and plots without manual copy-paste. The committee receives a like-for-like comparison, generated by the same codebase and the same automated checks as the original submission -- which is itself a credibility signal, since reviewers can see that the "sensitivity analysis" was not a bespoke, one-off patch job.

#heor-practice[
  This is the moment the investment in Chapters 25-30 -- parameterisation, unit tests on the model function, version-controlled code, and an automated reporting pipeline -- actually pays off. A technical engagement deadline of a few working days is a bad time to discover that your discount rate or extrapolation choice was hardcoded three layers deep in the model logic. Build for this scenario from the start, not after the first ERG report arrives.
]

#pitfall[
  Resist the temptation to hand-edit a copy of the output table to reflect a requested scenario "just this once." Undocumented one-off edits break the link between code and reported numbers, and an ERG or committee member who asks how a number was derived deserves (and is entitled to expect) a reproducible answer traceable to a specific function call and code version.
]

Having covered how agencies generally evaluate submissions -- their reference cases, their comparative requirements, and how they interrogate a model once it arrives -- the book now turns to how these same principles play out differently across specific therapy areas: oncology, rare diseases, vaccines, diagnostics, digital health, gene therapies, and infectious disease modelling of the kind the TB case study has used throughout. That is the subject of Chapter 32.
