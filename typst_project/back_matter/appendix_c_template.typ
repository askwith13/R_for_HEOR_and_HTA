#import "../common.typ": *

= Appendix C. Template R Project Structure and Model Scripts

Chapter 2 §2.2 introduced the folder structure this book recommends for a new real-world HEOR analysis, and §2.3-§2.4 covered `renv` package pinning and the Git workflow built around it. Rather than repeating that material a second time here, this appendix exists to confirm it as a working, forkable template, not just prose.

== The template, as a working folder

A complete, forkable copy of that structure -- `data-raw/`, `data/`, `R/`, `analysis/`, `output/`, a `renv.lock`, and a `.Rproj` file -- ships in this book's companion repository at `appendix-c-template/my-heor-project/`, built directly from Chapter 2's finalised guidance rather than drafted separately, so the two never drift out of sync.

```bash
cp -r appendix-c-template/my-heor-project ~/projects/my-new-analysis
cd ~/projects/my-new-analysis
Rscript -e 'renv::init()'   # do this FIRST, before any install.packages() call
```

#ref-table(
  [The Appendix C template folder layout, as introduced in Chapter 2 §2.2],
  academic-table(
    columns: (1.4fr, 2.6fr),
    align: (left, left),
    header: ([Folder], [Purpose]),
    body: (
      [`data-raw/`], [Original, untouched source files (trial extracts, vendor CSVs). Immutable -- never hand-edited or overwritten by a script.],
      [`data/`], [Cleaned, analysis-ready datasets. Derived, not authoritative: fully reproducible by re-running the cleaning scripts against `data-raw/`.],
      [`R/`], [Reusable functions (cost calculations, utility mapping, plotting themes) shared across more than one analysis script.],
      [`analysis/`], [The actual narrative -- scripts or Quarto documents that call functions from `R/` against data from `data/` and produce results.],
      [`output/`], [Figures, tables, and rendered reports. Fully disposable: always regenerable by re-running `analysis/`.],
      [`renv/`, `renv.lock`], [The pinned package library and its manifest, per Chapter 2 §2.3.],
    ),
    footer: none,
  ),
)

== Pitfalls and Git workflow

The two most consequential pitfalls from Chapter 2's original discussion are worth restating here, since they are the two most common failure modes in practice: deferring this structure "until the analysis is more final" (which almost always produces one sprawling, unauditable script instead), and installing packages before running `renv::init()` (which locks in an already-inconsistent environment). Chapter 2 §2.4's Git workflow -- branch per scenario, tag the exact commit used for a submitted report's figures -- applies to any project built from this template exactly as described there; see Chapter 2 for the full worked example.
