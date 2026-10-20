#import "../common.typ": *

= Appendix D. CHEERS 2022, ISPOR and NICE Checklists Mapped to R Workflows

This appendix maps the reporting checklists and methods-guidance documents referenced throughout this book to the specific R workflows this book teaches for satisfying them -- the same honest-scope approach Chapter 28 §28.6 takes toward CHEERS 2022: pointing to where each checklist's requirements are genuinely met by content already built, rather than reproducing exact item wording that should be independently verified against the published source before a real submission.

== CHEERS 2022

CHEERS 2022 (Consolidated Health Economic Evaluation Reporting Standards; Husereau, Drummond, Augustovski, et al., *Value in Health* 2022;25(1):10-31) is the current consensus reporting checklist for health economic evaluations -- cost-effectiveness, cost-utility, cost-minimisation, and cost-benefit analyses, whether trial-based or model-based. It comprises 28 items under six headings (title/abstract, introduction, methods, results, discussion, and other information including funding/conflicts). Chapter 28 §28.6 built a `cheers_checklist` tibble pattern for tracking item-by-item compliance programmatically rather than in a separate, drift-prone spreadsheet -- see that section for the full working code.

#ref-table(
  [CHEERS 2022 items this book is confident about by number, and the chapter/workflow that satisfies each],
  academic-table(
    columns: (0.6fr, 2fr, 1.6fr),
    align: (left, left, left),
    header: ([Item], [Topic], [Satisfied by]),
    body: (
      [1], [Title identifies the study as an economic evaluation and names the interventions compared], [Chapter 28 §28.6's title-pattern example],
      [9], [Model-based economic evaluation details -- structure, states, time horizon], [Chapters 17-24's decision-model documentation conventions],
      [13], [Discount rate], [Chapter 19 §19.5's discounting and half-cycle-correction workflow],
      [15], [Synthesis of effect estimates -- how treatment-effect or transition-probability evidence was pooled from the literature], [Chapter 11's meta-analysis workflow],
      [20, 26], [Statistical/regression analysis methods and corresponding results reporting], [Chapter 16's regression modelling and reporting conventions],
      [24], [Uncertainty characterisation], [Chapter 25's PSA/DSA workflow and visualisations (CE plane, CEAC, CEAF, NMB distribution)],
      [29], [Methods reported in enough detail for independent reproduction], [Chapter 2-3's reproducibility conventions and Chapter 30's packaged, pipelined, version-controlled model structure],
    ),
    footer: (table.cell(colspan: 3)[This is the same illustrative subset built in Chapter 28 §28.6, not the full 28-item list -- consult the published CHEERS 2022 statement directly for complete, authoritative item wording before any real submission.],),
  ),
)

#agency-note[
  CHEERS 2022 is the checklist most HTA bodies and health economics journals now expect authors to complete and submit alongside a cost-effectiveness manuscript, typically as a supplementary table stating the manuscript section/page where each item is addressed. Always check the submission target's current instructions for authors, since some journals mandate CHEERS compliance explicitly while others merely recommend it.
]

== ISPOR-SMDM Modeling Good Research Practices Task Force series

The ISPOR-SMDM Modeling Good Research Practices Task Force published a series of papers (jointly in *Medical Decision Making* and *Value in Health*, around 2012) covering model conceptualisation, structure, parameter estimation, model transparency and validation, and state-transition modelling specifically. This series is the methodological backbone this book has drawn on from Chapter 17 onward -- whichever model type is built, its task-force paper is the reference for what "good" looks like.

#ref-table(
  [ISPOR-SMDM task force themes and the chapters building R workflows around them],
  academic-table(
    columns: (2fr, 1fr),
    align: (left, center),
    header: ([Task force theme], [Primary chapter]),
    body: (
      [Model conceptualisation and problem scoping], [17],
      [Model structure and transparency], [17, 27],
      [Parameter estimation], [17, 25],
      [State-transition (Markov) modelling], [19],
      [Model transparency and validation], [27],
    ),
    footer: none,
  ),
)

== NICE DSU Technical Support Documents (TSDs)

The NICE Decision Support Unit's Technical Support Document series is the authoritative UK methods guidance underneath the NICE reference case, introduced in full in Chapter 31 §31.1 and drawn on repeatedly for specific modelling choices across Chapters 10-30. None of these documents prescribe R specifically -- NICE's templates are software-agnostic -- but they prescribe *outputs* (deterministic base case, scenario table, cost-effectiveness acceptability curve, one-way and probabilistic sensitivity results) that the R pipelines this book teaches naturally produce.

#ref-table(
  [NICE DSU TSDs referenced in this book, and the chapter building the matching R workflow],
  academic-table(
    columns: (0.7fr, 2.2fr, 1.1fr),
    align: (left, left, center),
    header: ([TSD], [Subject], [Chapter]),
    body: (
      [TSD 1], [Fixed-effect vs. random-effects model choice in evidence synthesis], [11],
      [TSD 12], [Probabilistic sensitivity analysis], [25],
      [TSD 14], [Survival analysis for economic evaluation (parametric extrapolation)], [10],
      [TSD 16], [Adjusting survival time estimates in the presence of treatment switching (RPSFTM, IPCW)], [15],
      [TSD 18], [Population-adjusted indirect comparisons (MAIC, STC, ML-NMR)], [13],
      [TSD 21], [Flexible survival extrapolation methods], [10],
    ),
    footer: (table.cell(colspan: 3)[Consult the DSU's published TSD series directly for exact current wording and methods recommendations -- NICE periodically revises individual TSDs, and this table reflects the content as drawn on in this book's chapters, not necessarily the latest published revision.],),
  ),
)

#pitfall[
  Citing a TSD in a submission's bibliography is not the same as satisfying it. Chapter 10 §10.2 notes explicitly that TSD 14 and TSD 21 are frequently cited as a reference without the actual diagnostics -- all six standard parametric fits, AIC/BIC tabulated side by side, visual overlay against the Kaplan-Meier curve, and clinical-plausibility discussion of the extrapolated tail -- being genuinely reported. A reviewer checking compliance looks for the diagnostics themselves, not the citation.
]

== Using these mappings

None of the three tables above is a substitute for reading the cited chapter in full, or for consulting the authoritative published document directly before a real submission. Their purpose is navigational: when a reviewer's comment references a specific CHEERS item, ISPOR-SMDM theme, or NICE DSU TSD number, these tables point back to the chapter where this book already built the matching R workflow, so the relevant code and reasoning can be located quickly rather than re-derived from scratch.
