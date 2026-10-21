# Contributing

This repository holds the companion materials for *R for Health
Economics and Outcomes Research (HEOR) and Health Technology
Assessment (HTA)* — runnable code, Shiny apps, a quiz bank, and
example data sets. There is no separate companion website; this
repository is the single destination for all of it.

## Reporting an error

Health economic models are unforgiving of small coding errors — a
flipped sign in a discounting formula or a mis-specified transition
matrix can silently produce a materially wrong ICER. If you find an
error in the book's code, its statistical claims, or the quiz bank,
please open an issue rather than working around it quietly. Include:

- The chapter/section number, or quiz question ID (e.g. `Q042`).
- What the book/code currently says or does.
- What you believe is correct, with a worked calculation or a
  citation to the source you're checking against, where possible.
- For a code issue: the exact error message or incorrect output you
  got running the file in `code/chNN_slug/`.

## What you can contribute

- **Code fixes** — a corrected `.R` file under `code/chNN_slug/`.
  Note that these files are auto-extracted from the book's own Typst
  source and regenerated on every edit, so a fix needs to be applied
  to both the extracted file (for immediate testing) and reported as
  an issue referencing the exact chapter/line so the underlying
  `.typ` source gets corrected too — a pull request touching only
  `code/` will be overwritten the next time the extractor runs.
- **Quiz corrections** — an issue (or PR) against `quiz/quiz_bank.csv`
  referencing the exact `question_id`.
- **Shiny apps** — new apps under `shiny_apps/`, one subfolder per
  app, following the convention in `shiny_apps/README.md`. See
  `progress/shiny_app_candidates.md` for the planned-but-unbuilt
  candidate list if you're looking for ideas.
- **Data sets** — a real or realistic synthetic file resolving one of
  the placeholder filenames listed in `data/README.md` and Appendix F,
  with a short data-dictionary entry describing its provenance. No
  real patient-level or commercially sensitive data will be accepted.

## What is not open to outside contribution

The book's own prose and typeset content (`typst_project/`,
`Chapter Markdowns/`) remain All Rights Reserved pending a publishing
decision by the author — see `LICENSE`. Corrections to prose/content
are very welcome as issues, but will be incorporated by the author
rather than merged as a direct PR to those files.

## Before submitting a PR

1. If your change touches a chapter's code, edit the chapter's `.typ`
   source under `typst_project/chapters/`, not the extracted file
   under `code/` directly (see above).
2. Run the chapter's own `renv.lock` (or at minimum, confirm every
   package your change relies on is genuinely installed and the code
   actually runs) before submitting — don't submit code you haven't
   executed.
3. Keep PRs scoped to one issue/chapter/question at a time.

## License

By contributing to `code/`, `appendix-c-template/`, `shiny_apps/`, or
`quiz/`, you agree your contribution is licensed under this
repository's MIT license for those folders (see `LICENSE`).
