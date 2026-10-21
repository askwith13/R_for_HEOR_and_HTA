#import "../common.typ": *

= Companion GitHub Repository, Code, Shiny App, Quiz and Data Sets

This book has no separate companion website. Everything it points
readers to -- runnable code, the interactive Shiny apps, the quiz
bank, and the example data sets -- lives in one public GitHub
repository, organised to mirror the book's chapter structure
(`ch01/`, `ch02/`, ... `ch35/`), with each chapter's code runnable
standalone given the chapter's own `renv.lock` file (see Chapter 2
§2.3 for why each chapter -- not just the book as a whole -- pins its
own package versions).

#agency-note[
  Repository: #link("https://github.com/askwith13/R_for_HEOR_and_HTA")[github.com/askwith13/R\_for\_HEOR\_and\_HTA]. Clone it, open any chapter's `code/chNN_slug/` folder or any app's `shiny_apps/` subfolder, and run -- nothing in this book depends on data or infrastructure you don't already have once you've cloned the repository.
]

Repository contents:

- `/code/` -- one subfolder per chapter, containing every code
  listing in that chapter as a runnable `.R` file, not just the
  excerpts shown in the printed text.
- `/data/` -- the synthetic and openly-licensed example datasets used
  throughout (see Appendix F for the full data dictionary); no real
  patient-level or commercially sensitive trial data is used anywhere
  in this book.
- `/appendix-c-template/` -- the full template R project structure
  from Appendix C, ready to fork for a new real-world analysis.
- `/shiny_apps/` -- 64 interactive Shiny apps illustrating specific
  concepts across the book (parameter sliders driving a live-updating
  ICER, CEAC, Markov trace, or similar), one subfolder per app, each
  README linking back to the exact book section it illustrates -- see
  Appendix G for the full list, and look for the small "Try it live"
  boxes beside the relevant topic throughout the chapters.
- `/quiz/` -- a 661-question quiz bank spanning all 35 chapters, as
  both a structured CSV/Markdown question bank and a runnable Shiny
  quiz app, intended as this book's self-assessment companion to
  worked examples and end-of-chapter review.

== Reporting errors

Health economic models are unforgiving of small coding errors --
a flipped sign in a discounting formula or a mis-specified
transition matrix can silently produce a materially wrong ICER. Any
reader who finds an error in this book's code or its statistical
claims should treat that as worth flagging immediately rather than
working around it quietly; the companion repository's issue tracker,
and its `CONTRIBUTING.md` file, are the designated channel.

== Citing this book

The companion repository includes a `CITATION.cff` file with
machine-readable citation metadata, which GitHub reads automatically
to generate an APA or BibTeX citation via its "Cite this repository"
button.
