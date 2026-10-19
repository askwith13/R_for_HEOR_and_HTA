= Companion Website, Code Repository and Data Sets

All R code in this book is intended to live in a companion GitHub
repository, organised to mirror the book's chapter structure
(`ch01/`, `ch02/`, ... `ch35/`), with each chapter's code runnable
standalone given the chapter's own `renv.lock` file (see Chapter 2 §2.3
for why each chapter — not just the book as a whole — pins its own
package versions).

Planned repository contents, to be populated as each chapter is
finalised:

- `/code/` — one subfolder per chapter, containing every code listing
  in that chapter as a runnable `.R` or `.qmd` file, not just the
  excerpts shown in the printed text.
- `/data/` — the synthetic and openly-licensed example datasets used
  throughout (see Appendix F for the full data dictionary); no real
  patient-level or commercially sensitive trial data is used anywhere
  in this book.
- `/appendix-c-template/` — the full template R project structure from
  Appendix C, ready to fork for a new real-world analysis.
- `/solutions/` — worked solutions to end-of-chapter exercises
  (Appendix G).

Until the repository is published, each chapter's code lives
alongside its Typst source in this project's own `typst_project/`
folder and the parallel `Chapter Markdowns/` summaries, which together
serve as the working source of truth during drafting. A working local
draft of the `/code/` folder itself — one subfolder per chapter,
auto-extracted from each chapter's typeset code blocks and kept
current after every edit — already exists locally and is what gets
pushed into the public repository once it is published.

== Reporting errors

Health economic models are unforgiving of small coding errors —
a flipped sign in a discounting formula or a mis-specified
transition matrix can silently produce a materially wrong ICER. Any
reader who finds an error in this book's code or its statistical
claims should treat that as worth flagging immediately rather than
working around it quietly; the companion repository's issue tracker
will be the designated channel once published.
