# Extracted from ch02_r_environment.typ, lines 47-57
# Section: == 2.2 Project structure for HEOR analyses
# Chapter: 2

my-heor-project/
├── data-raw/        # original, untouched source files (CSV exports, trial extracts)
├── data/            # cleaned, analysis-ready datasets (derived, never hand-edited)
├── R/               # reusable functions (not top-level analysis scripts)
├── analysis/        # scripts/Quarto docs that run the actual analysis
├── output/          # figures, tables, rendered reports — fully disposable/regenerable
├── renv/            # renv's private package library (Section 2.3)
├── renv.lock        # the package manifest
└── my-heor-project.Rproj
