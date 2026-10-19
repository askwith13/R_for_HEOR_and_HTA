# Front Matter — Summary

**Status:** complete (title page, foreword, preface, companion website
section, conventions section all drafted and compiled to PDF without
errors).

## Title page
Title: "R for Health Economics and Outcomes Research (HEOR) and Health
Technology Assessment (HTA)". Author: Dr Aswath Karunakaran. Marked as
a progressively-compiled draft edition.

## Foreword
Frames HEOR as sitting between biostatistics, actuarial modelling, and
practical budget-holder honesty. Names the canonical references
(Briggs/Claxton/Sculpher; Drummond et al.) as foundational but not
R-focused, and states this book's purpose as closing that specific gap.
Explicitly commits to treating LMIC/programmatic public-health readers
(the author's own background) as a first-class audience, not an
afterthought.

## Preface
Three sections:
- **Why R**: argues R's advantages over Excel/TreeAge/SAS — version
  control, reproducibility, CHEERS 2022 alignment, PSA speed — while
  being honest that R trades spreadsheet-click transparency for
  code-reading transparency.
- **Who this book is for**: assumes basic R competence (shored up in
  Ch.3) and zero formal health-econ background (built from scratch in
  Ch.4). Explicitly frames public-health/programmatic-data backgrounds
  (TB, HIV, immunisation analysts) as directly transferable into HEOR.
- **How to use this book**: front-to-back for beginners, or Part-by-Part
  for readers with existing foundations. Describes the recurring
  callout box system (HEOR in practice / Common pitfall / Agency
  perspective) and flags Part VIII's case studies (including a TB
  programme CEA for an LMIC setting) as deliberately placed last.
- **Note on how this edition was produced**: states explicitly that the
  book is written progressively, chapter by chapter, with each
  chapter's R code/HTA claims checked against standard references as
  drafted — and warns readers to verify package versions/function
  signatures against live CRAN before real submission use.

## Companion website, code repository and data sets
Describes planned GitHub repo structure (`/code/ch01../ch35/`,
`/data/`, `/appendix-c-template/`, `/solutions/`), each chapter pinning
its own `renv.lock`. No real patient-level data anywhere — synthetic/
openly-licensed datasets only (cross-references Appendix F). States
that until publication, the Typst project + Chapter Markdowns folders
serve as the working source of truth.

## Conventions, package versions and reproducibility notes
- Typographic conventions: monospace for code/packages, `#>` for R
  console output, math notation (ICER = ΔC/ΔE, discount rate r, time
  horizon T).
- Describes the three callout box types in Typst terms (defined as
  reusable functions in `book.typ`: `heor-practice()`, `pitfall()`,
  `agency-note()`, plus `learning-objectives()`).
- States package versions are pinned per-chapter in `renv.lock`, NOT
  hardcoded in prose, because key packages (`flexsurv`, `hesim`,
  `heemod`, `BCEA`, `netmeta`, `mice`) update too fast for a printed
  version number to stay accurate.
- Reproducibility baseline: every example runs from clean R + named
  packages + that chapter's renv.lock; no external credentials/
  infrastructure dependency; synthetic data only.
- States explicitly that the book rotates among NICE/CADTH/PBAC/HTAIn
  as worked-example agencies rather than silently defaulting to one
  high-income reference case throughout — Chapter 31 does the full
  comparison.

## Reusable Typst infrastructure established in `book.typ`
- Page setup: A4, 2.8cm/3cm margins, Libertinus Serif 11pt, numbered
  headings (1.1 style), justified paragraphs.
- Heading styles: level-1 headings force a page break and render at
  22pt bold; level-2 at 15pt bold.
- Four reusable callout functions ready for every subsequent chapter:
  `heor-practice(body)`, `pitfall(body)`, `agency-note(body)`,
  `learning-objectives(items)` — defined once in `book.typ`, available
  to every chapter file included after it.
- `#outline()` auto-generates the Table of Contents from heading
  structure — chapters do not need to hand-maintain a TOC entry.

## Open items / carried forward to Chapter 1 drafting
- Chapter `.typ` files should use the four callout functions above by
  name — they are defined once in `book.typ`, not redefined per
  chapter.
- Each chapter file goes in `typst_project/chapters/chNN_slug.typ` and
  gets one `#include` line appended to `book.typ` once approved.
- Notation fixed here (r for discount rate, T for horizon, ΔC/ΔE for
  ICER numerator/denominator) must be reused consistently — this is
  exactly what rubric dimension 5 (internal consistency) checks.
