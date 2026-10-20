#import "../common.typ": *

= Chapter 1. Introduction to HEOR and HTA

#learning-objectives((
  [Define Health Economics and Outcomes Research (HEOR) and distinguish it from adjacent disciplines it is often confused with.],
  [Describe the global Health Technology Assessment (HTA) ecosystem, including the major national and regional agencies and India's HTAIn.],
  [Map the evidence needs a product generates across its lifecycle, from early pipeline decisions to post-launch re-assessment.],
  [List the typical analytical deliverables an HEOR team produces and who consumes each one.],
  [Articulate the case for R as a primary HEOR tool, including where it still lags proprietary alternatives.],
  [Locate R's role across the end-to-end HEOR workflow that the rest of this book builds on, chapter by chapter.],
))

== What HEOR is and what it is not

Health Economics and Outcomes Research (HEOR) is the discipline that
generates and synthesises evidence on the clinical, economic and
humanistic value of a health intervention, so that payers, clinicians,
patients and policymakers can decide whether — and how — it should be
funded, prescribed or reimbursed. It sits deliberately between three
fields it borrows from but is not reducible to any one of them:

- *Health economics* proper, which studies how scarce health-care
  resources are allocated, using tools such as welfare economics,
  demand theory and public finance. HEOR narrows this to intervention-
  level value questions rather than system-level allocation theory.
- *Biostatistics and epidemiology*, which HEOR leans on heavily
  (survival analysis, meta-analysis, causal inference — all covered
  in Part III of this book) but HEOR's output is a decision-relevant
  value argument, not a hypothesis test in isolation.
- *Health services research*, which studies how care is organised and
  delivered; HEOR instead asks whether a specific technology is worth
  paying for, relative to its comparators, in a specific decision
  context.

A useful operational definition: HEOR produces the evidence base that
answers "is this intervention worth it, for whom, compared to what,
and under what degree of uncertainty?" Everything else in this book —
R code, statistical models, decision trees, Shiny apps — exists only
in service of answering that question more rigorously and more
reproducibly.

#difficult-terminology("welfare economics, demand theory, public finance")[
These are the three parent disciplines health economics proper draws on,
each a large field in its own right. *Welfare economics* studies how to
judge whether a policy change makes society better or worse off overall
— think of it as the branch of economics concerned with "who wins, who
loses, and does the gain outweigh the loss." *Demand theory* models how
much of something people buy at different prices (and how that changes
as income or preferences shift) — the supply-and-demand curves from an
introductory economics course. *Public finance* studies how governments
raise money (taxation) and decide how to spend it across competing
priorities (roads, schools, hospitals). HEOR borrows selectively from
all three but narrows its focus dramatically: rather than asking "how
should a health system allocate its whole budget" (a public-finance
question) or "how does demand for healthcare respond to price" (a
demand-theory question), HEOR asks a much more contained question —
"is *this one* intervention worth paying for, compared to what we'd
otherwise do with that money?" You do not need to have studied any of
the three to follow this book; they are named here only because an HTA
dossier or health-economics textbook may invoke them as HEOR's
intellectual ancestry.
]

#pitfall[
  A common conflation, especially among analysts moving into HEOR from
  general biostatistics or health-services backgrounds, is to treat
  statistical significance (a p-value below 0.05 for a treatment
  effect) as equivalent to economic or decision-relevant significance.
  A statistically significant mean cost difference of \$40 per patient
  across a 20,000-patient budget impact model, or a trial result
  extrapolated with a parametric survival curve well past the observed
  follow-up window, can drive a very different reimbursement
  recommendation than the p-value alone would suggest. HEOR's job is
  precisely this translation step — from clinical/statistical evidence
  to decision-relevant value — and it is where most of this book's
  methodological content concentrates.
]

#difficult-terminology("parametric survival curve (extrapolation)")[
A clinical trial only follows patients for a finite period — typically
a few years at most — but a cost-effectiveness model usually needs to
know what happens to survival, and therefore to costs and QALYs, over
a patient's whole remaining lifetime. "Extrapolation" is the general
term for projecting beyond what was actually observed. A *parametric*
survival curve is one specific way to do this: instead of just
plotting the raw, jagged step-function of who-died-when in the trial
(a Kaplan-Meier curve, covered properly in Chapter 10), you fit a
smooth mathematical formula — common choices are named after their
shape, such as Weibull, log-normal or log-logistic — that describes
how the risk of the event changes over time. Once that formula is
fitted to the observed trial data, it can be evaluated at any time
point you like, including years past the last observed patient,
simply by plugging in a larger value for time. The practical analogy
is a weather forecast: you have reliable five-day data, but you want
a projection for month six, so you fit a model to the pattern you've
seen and use it to project forward — the forecast is only as
trustworthy as the assumption that the underlying pattern (the shape
of the curve) continues to hold, which is exactly why HTA agencies
scrutinise which parametric shape was chosen and demand sensitivity
analyses across plausible alternatives.
]

HEOR is also not the same as *market access*, although the two
functions collaborate closely in industry settings. Market access is
the commercial and regulatory function that negotiates price,
reimbursement status and formulary listing; HEOR supplies the
evidence (economic models, systematic literature reviews, real-world
evidence studies) that market access teams use in those negotiations
and that agencies scrutinise in their technical appraisal.

== The HTA ecosystem

Health Technology Assessment (HTA) is the formal, usually
government-mandated or government-commissioned process by which a
jurisdiction decides whether a health technology (a drug, device,
diagnostic or procedure) should be covered by public or social
insurance funds, and on what terms. HTA agencies are the primary
institutional consumers of HEOR output, and the methodological
choices in this book are shaped throughout by what these agencies
expect to see in a submission.

The major agencies an HEOR analyst will encounter, and the general
character of each:

- *NICE* (National Institute for Health and Care Excellence, England
  and Wales) runs one of the most methodologically prescriptive
  processes globally, publishing the NICE reference case and a
  detailed series of Decision Support Unit (DSU) Technical Support
  Documents (TSDs) that this book cites repeatedly — for survival
  extrapolation (TSD 14, TSD 21), network meta-analysis (TSD 2) and
  population-adjusted indirect comparisons (TSD 18), among others.
- *CADTH* (Canada's Drug Agency, historically the Canadian Agency for
  Drugs and Technologies in Health) performs a broadly similar
  reimbursement review function for Canada, with its own reference
  case and reanalysis culture.
- *PBAC* (Pharmaceutical Benefits Advisory Committee, Australia)
  advises the Australian government on Pharmaceutical Benefits
  Scheme listing, with a strong tradition of structured uncertainty
  and stepped economic evaluation.
- *IQWiG* (Institute for Quality and Efficiency in Health Care) and
  the *G-BA* (Federal Joint Committee) jointly run Germany's early
  benefit assessment (AMNOG) process, which emphasises patient-
  relevant outcomes and additional-benefit categorisation ahead of
  price negotiation.
- *HAS* (Haute Autorité de Santé, France) assesses clinical and
  economic value (via the Transparency Committee and the Economic
  and Public Health Evaluation Committee) feeding into price
  negotiation with the French health insurance system.
- *ICER* (Institute for Clinical and Economic Review, United States)
  is a non-government, foundation-funded body whose cost-effectiveness
  reports carry significant influence over US payer and
  pharmacy-benefit-manager decisions despite having no statutory
  authority.
- *HTAIn* (Health Technology Assessment in India), housed under the
  Department of Health Research, Ministry of Health and Family
  Welfare, is the body most directly relevant to India-based HEOR
  analysts: it issues an Indian reference case for economic evaluation
  and informs technology inclusion decisions under schemes such as
  Ayushman Bharat Pradhan Mantri Jan Arogya Yojana (PM-JAY). HTAIn's
  methodological guidance is still maturing relative to NICE or
  CADTH, which in practice means Indian HEOR analyses often triangulate
  HTAIn's own reference case with ISPOR good-practice guidance and
  precedent from more established agencies — a pattern Chapter 31
  revisits in depth.

#ref-table(
  [Major HTA agencies/bodies an HEOR analyst routinely encounters, their jurisdiction, general evaluative stance, and a key reference document cited elsewhere in this book.],
  academic-table(
    columns: (auto, 1.4fr, 1.6fr, 1.8fr),
    align: (left, left, left, left),
    header: ([*Agency*], [*Jurisdiction*], [*Threshold / evaluative approach*], [*Key reference document*]),
    body: (
      [NICE], [England and Wales], [Explicit reference-case, methodologically prescriptive], [NICE reference case; DSU TSDs (e.g. TSD 14, TSD 21, TSD 2, TSD 18)],
      [CADTH], [Canada], [Reference case with reanalysis culture], [Guidelines for the Economic Evaluation of Health Technologies],
      [PBAC], [Australia], [Stepped economic evaluation, strong uncertainty tradition], [PBAC Guidelines],
      [IQWiG / G-BA], [Germany], [Early benefit assessment (AMNOG), patient-relevant outcomes], [IQWiG General Methods],
      [HAS], [France], [Clinical + economic value via dedicated committees], [HAS Economic Evaluation Guidance],
      [ICER], [United States], [Non-government cost-effectiveness reports, no statutory authority], [ICER Value Assessment Framework],
      [HTAIn], [India], [Indian reference case, still maturing], [HTAIn Reference Case for Economic Evaluation],
    ),
    footer: (table.cell(colspan: 4)[*Note.* Since 2025, EU Joint Clinical Assessment adds a shared clinical-assessment layer; national bodies above still perform their own economic/pricing appraisal.],),
  ),
) <tab-ch01-hta-agencies>

#agency-note[
  Since 2025 the *EU Joint Clinical Assessment* (EU HTA Regulation,
  in force from January 2025 for oncology and advanced-therapy
  medicinal products, with wider scope phasing in through 2030)
  introduces a single European Union-level clinical assessment report
  that national HTA bodies must then take into account in their own
  (still separate) appraisals of cost-effectiveness and pricing. This
  decouples joint *clinical* assessment from still-national *economic*
  assessment — a structural distinction every analyst preparing a
  European submission now needs to track, because it changes which
  evidence goes into which document and on what timeline.
]

#figure(
  image("../images/conceptual/ch01_eu_jca_flow.png", width: 90%),
  caption: [Since 2025, the EU Joint Clinical Assessment produces a single shared clinical-assessment report that feeds into multiple still-separate national economic and pricing appraisals — each national body (NICE, IQWiG/G-BA, HAS, and others) runs its own economic evaluation and reaches its own reimbursement decision from the same upstream clinical evidence base.],
) <fig-ch01-eu-jca-flow>

A single technology can therefore face half a dozen or more
functionally distinct appraisal processes across markets, each with
its own reference case, discount rate convention, preferred
comparator set and willingness-to-pay stance — one of the strongest
practical arguments for building economic models in a flexible,
scriptable, re-parameterisable tool rather than a single fixed
spreadsheet.

== Evidence needs across the product lifecycle

HEOR evidence generation is not a one-off event triggered by a launch
date; it is continuous across a technology's life, and the type of
evidence that is credible, available and decision-relevant changes
at each stage:

+ *Early pipeline / pre-clinical and Phase I-II*: indication selection,
  early value proposition modelling, target product profile
  cost-effectiveness thresholds, often using modelled (not yet
  observed) efficacy assumptions.
+ *Phase III / pre-launch*: pivotal trial-based economic models,
  systematic literature reviews and network meta-analyses to position
  the asset against comparators, early health-related quality-of-life
  (utility) evidence collection alongside the trial.
+ *Launch / initial HTA submission*: the full value dossier — economic
  model, budget impact model, systematic review, and (where relevant)
  indirect treatment comparison — submitted to one or more HTA
  agencies and payers.
+ *Post-launch*: real-world evidence studies to confirm or update
  trial-based assumptions (particularly long-term survival
  extrapolation and real-world adherence/persistence), responses to
  evidence review group critiques, managed entry agreement data
  collection.
+ *Re-assessment / loss of exclusivity*: re-appraisal as new
  comparators enter, as biosimilars or generics launch, or as a
  scheduled HTA review cycle requires updated modelling.

#ref-table(
  [Evidence generation and typical analytical deliverables by product lifecycle stage.],
  academic-table(
    columns: (1.5fr, 2.2fr, 1.4fr),
    align: (left, left, left),
    header: ([*Lifecycle stage*], [*Characteristic evidence generated*], [*R workflow emphasis*]),
    body: (
      [Early pipeline / Phase I-II], [Indication selection, early value proposition, target product profile thresholds], [Quick decision-tree/Markov prototypes (Ch. 18-19)],
      [Phase III / pre-launch], [Pivotal trial-based models, SLRs/NMAs, early utility collection], [Evidence synthesis inputs (Part III)],
      [Launch / initial HTA submission], [Full value dossier: economic model, BIM, SLR, ITC], [Validated, documented, PSA-ready models (Ch. 25, 27)],
      [Post-launch], [RWE studies, ERG critique responses, managed entry agreement data], [RWE pipelines, causal inference (Ch. 15)],
      [Re-assessment / LOE], [Re-appraisal against new comparators, biosimilars/generics], [Updated modelling on existing codebase],
    ),
    footer: none,
  ),
) <tab-ch01-lifecycle-deliverables>

This sequencing matters for a very practical reason covered
throughout this book: at each stage the *type* of R workflow needed
differs — early-stage work favours quick, assumption-heavy
decision-tree or simple Markov prototypes (Chapters 18-19); launch
submissions demand fully validated, documented, PSA-ready models
(Chapters 25, 27); post-launch work leans on real-world data pipelines
and causal inference methods (Chapter 15) that a pre-launch team may
never have needed.

== Typical deliverables

An HEOR function, whether inside a pharmaceutical company, a
consultancy, a government technical unit or an academic health
economics group, typically produces some combination of:

- *Global value dossiers* — the master evidence package (AMCP format
  or similar) from which country-specific submissions are adapted.
- *Economic models* — cost-effectiveness or cost-utility models
  (decision trees, Markov models, partitioned survival models,
  microsimulations — Part IV of this book) that estimate incremental
  cost per QALY, DALY averted, or other outcome of interest.
- *Budget impact models* — separate from cost-effectiveness models,
  these forecast the net financial impact on a payer's budget over a
  defined horizon (Chapter 23), and are frequently the deciding
  document in resource-constrained settings even when the
  cost-effectiveness case is favourable.
- *Systematic literature reviews and network meta-analyses* — the
  evidence synthesis backbone for both the clinical case and the
  economic model's comparative-effectiveness inputs (Chapters 6,
  11-13).
- *Real-world evidence (RWE) studies* — observational analyses using
  registries, claims or electronic health record data to answer
  questions trials cannot (Chapter 15).
- *Payer submissions and technical engagement responses* — the
  formatted documents and rebuttals an agency's evidence review
  process demands (Chapters 28, 31).

#difficult-terminology("microsimulation")[
Most economic models described so far implicitly track a *cohort* —
an average, representative group of patients moving through health
states together, where everyone in the "progressed disease" state at
year 3 is treated as identical for costing and QALY purposes. A
microsimulation instead tracks many individual, simulated patients one
at a time, each with their own randomly drawn characteristics and
their own randomly drawn sequence of events (does *this* particular
patient progress this cycle, or not, based on a random draw against
their personal risk?). Run enough individual patients through the
model and average their outcomes, and you recover the same
population-level answer a cohort model would give — but along the
way you also capture patient-to-patient variability (some patients do
much better or worse than the average) and can model things a cohort
average cannot, such as a patient's own history affecting their future
risk. A useful analogy is a flight simulator running thousands of
individual passenger journeys with their own delays and connections,
rather than reporting only the airline's average on-time performance:
both describe the same system, but the individual-level version
answers questions ("what fraction of passengers miss their
connection?") the average alone cannot.
]

Tuberculosis programme data quality and analysis for India's National
TB Elimination Programme, and workforce-training initiatives built
around it, sit most naturally against the budget impact, programme-
cost and dynamic/infectious-disease modelling deliverables (Chapters
22-23, 32.7), which this book returns to with TB-specific worked
examples wherever the general method permits it.

== Why R: the case for open-source and reproducible HEOR

For much of HEOR's history, the dominant modelling tools were Excel
(ubiquitous, transparent to reviewers cell-by-cell, but fragile and
hard to validate at scale), TreeAge Pro (a widely used commercial
decision-modelling GUI), and SAS (entrenched in regulated clinical
and RWE pipelines, particularly in the US). R has become a credible,
and increasingly preferred, alternative for several concrete reasons:

- *Reproducibility by construction.* An R script, paired with
  `renv` package-version locking (Chapter 2) and version control
  (Git), gives an exact, re-runnable record of every assumption and
  transformation — something a large interlinked Excel workbook with
  manual copy-paste steps cannot reliably guarantee.
- *Statistical depth.* R's package ecosystem for survival analysis
  (`flexsurv`), meta-analysis (`meta`, `metafor`, `netmeta`),
  Bayesian modelling (`brms`, Stan) and causal inference (`MatchIt`,
  `WeightIt`) is both broader and more actively maintained by the
  academic biostatistics community than equivalent capability inside
  TreeAge or Excel, and typically ahead of what is readily available
  in SAS procedures for newer methods.
- *Cost.* R, RStudio/Positron and essentially the entire package
  ecosystem used in this book are free and open source, compared to
  substantial per-seat licensing for TreeAge or SAS — a material
  consideration for government technical units, academic groups and
  LMIC HTA bodies including HTAIn-adjacent work.
- *Transparency for reviewers.* A well-structured R project
  (Chapter 2) lets an external reviewer or evidence review group trace
  every number in a submitted model back to a specific line of code
  and a specific input — the standard increasingly expected by NICE's
  DSU and by open-science-minded reviewers more broadly.
- *Interoperability with reporting.* Quarto and R Markdown (Chapter 28)
  let the same codebase that runs the model also generate the Word,
  PDF, HTML or PowerPoint submission documents, removing an entire
  category of transcription error between "the model" and "the
  report."

None of this means R is strictly superior in every respect. TreeAge
remains attractive for teams who need a point-and-click interface for
non-programming stakeholders and fast prototyping without a coding
layer; SAS retains deep institutional entrenchment in regulated
clinical trial pipelines where validated, audited SAS macros already
exist; and Python has a comparably open-source, reproducible profile
to R, with particular strength in machine learning and large-scale
data engineering (Chapter 34 returns to where Python-R interoperation
and newer ML methods fit into an HEOR R workflow).

#heor-practice[
  Several HTA agencies now explicitly accept, and in some cases
  prefer, submissions built with open-source tools, provided the
  model is adequately documented and validated. NICE's DSU has
  published R-based worked examples for survival extrapolation (TSD
  21) and other technical guidance; several published NICE
  single-technology appraisals have used R-built partitioned survival
  and Markov models rather than Excel or TreeAge. The deciding factor
  for agency acceptance is not the tool itself but whether the model
  satisfies the agency's validation and transparency expectations
  (Chapter 27) — R makes that easier to demonstrate, but does not make
  it automatic.
]

== Where R fits in the HEOR workflow

The remainder of this book is organised around a simple mental model
of the HEOR workflow, and each part maps onto a stage of it:

#figure(
  image("../images/conceptual/ch01_book_workflow_map.png", width: 100%),
  caption: [The book's eight-part structure as a cumulative HEOR workflow. Each part assumes fluency with everything upstream of it.]
) <fig-ch01-workflow>

+ *Foundations* (Part I, this part): the R environment, R language
  essentials, and the core health-economic concepts (QALYs, ICERs,
  discounting) that every later chapter assumes.
+ *Data* (Part II): getting trial, registry, claims, literature,
  utility and cost data into a clean, analysis-ready state — the
  unglamorous but decisive step that determines whether everything
  downstream is trustworthy.
+ *Statistical methods* (Part III): survival analysis, meta-analysis,
  indirect comparisons, Bayesian methods and causal inference — the
  methods that convert raw data into the clinical and comparative-
  effectiveness parameters a model needs.
+ *Decision-analytic modelling* (Part IV): the model structures
  themselves — decision trees, Markov cohort models, partitioned
  survival models, microsimulation, discrete event simulation, budget
  impact and distributional/extended CEA — that combine those
  parameters into decision-relevant outputs.
+ *Uncertainty, VOI and validation* (Part V): quantifying how
  confident we should be in a model's conclusions, and demonstrating
  that confidence is warranted through calibration and validation.
+ *Reporting, communication and deployment* (Part VI): turning a
  validated model into a submission-ready, reviewable, and where
  useful interactive (Shiny) artefact.
+ *HTA in practice* (Part VII): agency-specific requirements, special
  therapeutic-area considerations, and patient-preference methods that
  do not fit cleanly into the generic workflow above.
+ *Case studies* (Part VIII): end-to-end worked examples, including a
  TB programme cost-effectiveness analysis for an LMIC setting,
  tying every preceding part together in one script-driven project.

#difficult-terminology("discrete event simulation")[
A Markov cohort model (and, usually, a microsimulation built on top of
one) advances time in fixed, regular steps — a "cycle" — typically a
month or a year, checking at every single cycle boundary whether each
patient has moved to a new health state. A discrete event simulation
instead advances time irregularly, jumping straight to whenever the
*next* thing actually happens (the next relapse, hospital admission,
or death, whichever comes first for whichever patient), rather than
re-checking everyone on a fixed clock. This matters most when events
are rare and irregularly timed, or when the model needs to represent
shared, limited resources — a fixed number of hospital beds or
specialist appointment slots that patients queue for — something a
simple fixed-cycle cohort model struggles to represent naturally.
Think of the difference between a factory manager who inspects every
machine on the hour regardless of what is happening (a fixed-cycle
approach) versus one who is alerted the instant any machine actually
breaks down or finishes a job (an event-driven approach); the second
is more efficient and more realistic when events are sporadic rather
than evenly spaced.
]

#difficult-terminology("distributional / extended cost-effectiveness analysis")[
A standard cost-effectiveness analysis produces one headline number —
the population-average cost per QALY gained — which can quietly hide
very different results for different groups within that population. A
distributional (or "extended") cost-effectiveness analysis
deliberately breaks that average apart, reporting costs, health gains
and sometimes financial-risk-protection effects separately by
subgroup: by income quintile, by region, by disease severity, or by
insurance status, for example. The point is to let a decision-maker
see *who* gains and *who* pays, not just whether the average trade-off
looks favourable — a programme can look excellent on average while
concentrating nearly all of its benefit in one already-advantaged
group, which a single pooled ICER would never reveal. A simple
analogy: a company's average employee salary can rise even if every
individual salary stayed flat, just because a few new high earners
joined — the average conceals the distribution. Extended CEA is the
health-economics equivalent of insisting on seeing the full salary
breakdown by group, not just the company-wide average, before judging
whether a policy is actually equitable.
]

Each part builds cumulatively on R skills and HEOR concepts introduced
earlier — by the time this book reaches decision-analytic modelling
in Part IV, it assumes fluency with the data-wrangling and statistical
foundations from Parts I-III, rather than re-explaining them.
