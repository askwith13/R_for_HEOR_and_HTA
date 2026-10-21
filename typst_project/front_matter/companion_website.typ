= Companion GitHub Repository, Code, Shiny App, Quiz and Data Sets

This book has no separate companion website. Everything it points
readers to -- runnable code, the interactive Shiny apps, the quiz
bank, and the example data sets -- lives in one public GitHub
repository, organised to mirror the book's chapter structure
(`ch01/`, `ch02/`, ... `ch35/`), with each chapter's code runnable
standalone given the chapter's own `renv.lock` file (see Chapter 2
§2.3 for why each chapter -- not just the book as a whole -- pins its
own package versions).

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
- `/shiny_apps/` -- interactive Shiny apps illustrating selected
  concepts across the book (parameter sliders driving a live-updating
  ICER, CEAC, Markov trace, or similar), one subfolder per app, each
  README linking back to the exact book section it illustrates.
- `/quiz/` -- a 661-question quiz bank spanning all 35 chapters, as
  both a structured CSV/Markdown question bank and a runnable Shiny
  quiz app, intended as this book's self-assessment companion to
  worked examples and end-of-chapter review.

Until the repository is published, all of the above already exist and
are actively maintained inside this project's own working directory
(`typst_project/` for the book source, plus the sibling `code/`,
`shiny_apps/`, `quiz/`, `data/` and `appendix-c-template/` folders),
which together serve as the working source of truth during drafting
and are what gets pushed into the public repository once it is
published.

== Reporting errors

Health economic models are unforgiving of small coding errors --
a flipped sign in a discounting formula or a mis-specified
transition matrix can silently produce a materially wrong ICER. Any
reader who finds an error in this book's code or its statistical
claims should treat that as worth flagging immediately rather than
working around it quietly; the companion repository's issue tracker
will be the designated channel once published.
