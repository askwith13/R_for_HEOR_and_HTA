= Preface

== Why R for HEOR and HTA

Health economic models have historically lived in Excel and TreeAge,
with SAS handling the clinical-trial statistics feeding into them.
That world is changing, and not slowly. R now has a mature,
purpose-built ecosystem for every stage of the HEOR workflow —
`flexsurv` and `survival` for extrapolation, `heemod` and `hesim` for
cohort and individual-level state-transition models, `BCEA` and `voi`
for uncertainty and value-of-information analysis, `netmeta` and
`gemtc` for network meta-analysis, `shiny` for submission-ready
interactive model front-ends. HTA agencies, NICE chief among them,
now routinely receive and review R-based submissions, and several
publish explicit methodological guidance (the NICE DSU Technical
Support Documents) that assumes a modeller capable of implementing
the methods in code, not just describing them in a Word document.

R's advantages over the Excel/TreeAge default are not merely
aesthetic. Version control is native. A model's entire parameter set,
structural logic, and reporting pipeline can live in one reviewable,
re-runnable repository instead of a spreadsheet with hidden
formulas and undocumented macro buttons. Probabilistic sensitivity
analysis that would take an Excel model minutes per thousand
iterations runs in seconds. Reproducibility — increasingly a
condition of serious HTA submission, and squarely the subject of the
CHEERS 2022 reporting checklist — is close to automatic in R and
close to aspirational in Excel.

None of this makes R effortless. It trades spreadsheet transparency
(anyone can click a cell and see the formula) for code transparency
(anyone who can read R can see the logic, but first they have to be
able to read R). This book's purpose is to make that trade pay off
quickly rather than slowly.

== Who this book is for

This book assumes:

- Working competence in R at the level of being comfortable with data
  frames, basic data wrangling, and writing simple functions — not
  mastery, and Chapter 3 exists specifically to shore up anything
  shaky here.
- No prior formal health economics training. Chapter 4 builds the
  core concepts — QALYs, ICERs, discounting, perspective — from
  first principles, with R code alongside each concept as it is
  introduced.
- A practical, applied motivation: you need to build, review,
  critique, or commission health economic models and evidence
  syntheses as part of real work, whether in a pharmaceutical HEOR
  team, an HTA agency, an academic health economics group, a
  consultancy, or — a case this book treats as a first-class
  audience rather than a footnote — a public health programme in a
  low- or middle-income country assessing interventions against a
  national reference case and a genuinely binding budget constraint.

Readers coming from applied public health, programmatic disease
surveillance, or clinical data analysis backgrounds will recognise
much of the data-quality and real-world-evidence material in Part II
and Part III. That recognition is intentional: the skills that make
someone good at programmatic TB, HIV, or immunisation data analysis —
scepticism about data completeness, comfort with messy field data,
an instinct for what a confidence interval is actually telling you —
transfer directly into HEOR, and this book tries to make that
transfer explicit rather than leaving the reader to discover it
unaided.

== How to use this book

The book is organised to be read front-to-back by someone starting
from zero, but each Part is also written to stand largely on its own
for a reader who already has foundations and wants to go straight to,
say, network meta-analysis (Part III) or decision-tree and Markov
modelling (Part IV). Every chapter opens with explicit learning
objectives and closes with exercises; "HEOR in practice" boxes
throughout ground the method in a real submission scenario, "Common
pitfalls" boxes flag the mistakes that recur most often in actual
agency technical queries, and "Agency perspective" boxes state plainly
what a reviewer at NICE, CADTH, PBAC, or HTAIn is likely to be
checking for.

Part VIII's end-to-end case studies, including a TB programme
cost-effectiveness analysis built for an LMIC setting, are deliberately
placed last: by that point every technique used in them has already
been introduced on its own, and the case studies exist to show how
the pieces assemble into a real, submission-shaped analysis.

== A note on how this edition was produced

This draft edition is being written progressively, chapter by
chapter, with R code and HTA-practice content checked against
standard references (ISPOR-SMDM good-practice guidance, NICE DSU
Technical Support Documents, Briggs/Claxton/Sculpher, Drummond et al.)
as each chapter is completed, rather than delivered as a single
finished manuscript. Readers working through an early draft chapter
should treat package version numbers and function signatures as
subject to verification against the live CRAN package before
production use in a real submission — Chapter 2's `renv` and
reproducibility guidance exists precisely so that this kind of
drift between a book's print date and a package's current behaviour
never silently breaks a real model.
