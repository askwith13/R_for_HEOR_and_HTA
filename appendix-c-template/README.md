# Appendix C template: starter R project structure for a new HEOR analysis

This is the full template folder structure introduced in Chapter 2
§2.2 of *R for HEOR and HTA*, ready to fork for a new real-world
analysis — exactly what the book's planned Appendix C ("Template R
project structure and model scripts") and `companion_website.typ`'s
`/appendix-c-template/` both describe. Appendix C's own prose has not
been drafted yet (back-matter appendices are written after the main
35 chapters, per the book's pace), so this folder is built directly
from Chapter 2's already-finalised and Jev-passed guidance rather than
invented separately — if Appendix C's wording changes later, this
template's README should be reconciled against it, not the reverse.

## How to use this

```bash
cp -r appendix-c-template/my-heor-project ~/projects/my-new-analysis
cd ~/projects/my-new-analysis
Rscript -e 'renv::init()'   # do this FIRST, before any install.packages() call
```

## Folder layout and rationale (verbatim from Chapter 2 §2.2)

```
my-heor-project/
├── data-raw/        # original, untouched source files (CSV exports, trial extracts)
├── data/            # cleaned, analysis-ready datasets (derived, never hand-edited)
├── R/               # reusable functions (not top-level analysis scripts)
├── analysis/        # scripts/Quarto docs that run the actual analysis
├── output/          # figures, tables, rendered reports — fully disposable/regenerable
├── renv/            # renv's private package library (Section 2.3)
├── renv.lock        # the package manifest
└── my-heor-project.Rproj
```

- **`data-raw/` is immutable.** Nothing in this folder is ever edited
  by hand or overwritten by a script. If a trial extract or vendor
  file changes, a new file (or new version) is added — the folder is
  a permanent, auditable record of what came in. Cleaning logic lives
  in code under `R/`, not in the data itself.
- **`data/` is derived, not authoritative.** Everything here should be
  fully reproducible by re-running the cleaning scripts against
  `data-raw/`. If `data/` were deleted entirely, the project should be
  able to regenerate it byte-for-byte.
- **`R/` separates logic from execution.** Functions used by more than
  one analysis script (cost calculations, utility mapping, plotting
  themes) belong here, loaded via `source()` or, for larger projects,
  packaged with `devtools::load_all()`.
- **`analysis/` contains the actual narrative** — Quarto documents or
  scripts that call functions from `R/` against data from `data/` and
  produce results. Each file here should, in principle, run
  top-to-bottom on a clean machine and reproduce its own output.
- **`output/` is disposable.** Nothing here is a source of truth; it
  is always regenerable by re-running `analysis/`. Treating output as
  disposable is what keeps the project honest — if you can't
  regenerate a table from scratch, something in the pipeline is
  undocumented.

## Pitfalls to avoid (verbatim from Chapter 2)

- Do not defer this structure until "the analysis is more final." The
  most common failure mode is a single sprawling script that reads a
  spreadsheet, cleans it, models it, and plots it in one pass —
  impossible to audit, and nearly impossible to hand off.
- Run `renv::init()` as the *first* command in a new HEOR project,
  before a single `install.packages()` call. By the time collaborators
  have installed ad-hoc package versions by hand, `renv::init()`
  inherits an already-inconsistent environment.

## Git workflow (verbatim from Chapter 2 §2.4)

```bash
git init
git add .
git commit -m "Initial commit: project scaffold and renv lockfile"
git checkout -b scenario/alt-discount-rate
# ... make changes ...
git add R/run_model.R
git commit -m "Add 1.5% discount rate scenario per reviewer request"
git push origin scenario/alt-discount-rate
# open a pull request on GitHub for review before merging
```

Tag the exact commit hash used to produce a submitted report's figures
(`git tag submission-v1 <hash>`) so the evidentiary model can always
be reconstructed byte-for-byte, even after further development
continues on other branches.
