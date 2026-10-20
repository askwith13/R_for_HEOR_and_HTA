#import "../common.typ": *

= Chapter 30. R Packages and Pipelines for Model Development

#learning-objectives((
  [Explain why and when a health-economic model should be turned into a proper installable R package rather than a loose folder of scripts.],
  [Use `usethis` and `devtools` to scaffold a package's standard structure and drive the edit-check-reload development workflow.],
  [Document functions with `roxygen2` and build a browsable documentation website for the package with `pkgdown`.],
  [Build a reproducible pipeline with `targets`, combined with `renv` for dependency-version locking, so a multi-step model only re-runs what has actually changed.],
  [Set up continuous integration with GitHub Actions so a model's test suite runs automatically on every code change.],
  [Choose an appropriate mechanism (private repo access, a tagged release, or a public repository) for sharing a packaged model with HTA agencies and reviewers.],
  [Explain the practical difference between permissive and copyleft open-source licenses, and apply this book's own licensing precedent as a worked example.],
))

Chapter 29 closed with a validated, auditable interactive Shiny front end sitting on top of the TB Markov model built across Chapters 17-27. That front end still depends, underneath, on a loose collection of R functions -- `run_markov_model()`, `run_psa()`, `build_ceac()`, and the rest -- that have grown organically across many chapters. This chapter is about the final step of maturing that model engine: turning it into a proper installable R package, documenting it so someone other than its author can understand it, wiring it into a reproducible pipeline, and deciding how to license and share it once it is ready to leave your own machine.

== 30.1 Why package your model

Most R-based health-economic models start life as a single script, or a loose folder of scripts: `data_prep.R`, `markov_model.R`, `psa.R`, `make_plots.R`, run in sequence by hand. This works for a first exploratory build. It stops working the moment the model needs to be reused for a second indication, handed to a colleague, submitted to a reimbursement agency, or revisited eighteen months later when the agency comes back with a technical query. At that point, a folder of scripts becomes a liability: nobody but the original author knows which script to run first, which version of `dplyr` it was written against, or whether the function called on line 214 of `psa.R` is the same one silently redefined further down in `make_plots.R`.

#difficult-terminology("R package")[
  An R package is a standardised bundle of R code, documentation, and metadata that R itself knows how to install, load, and check for internal consistency -- the same mechanism behind `dplyr` or `survival`. Turning your own model into a package means it gets the same treatment: a single `library(yourmodel)` call loads every function, in a known working state, instead of you manually `source()`-ing a dozen files in the right order and hoping nothing has drifted.
]

Packaging a model buys four things that matter specifically for HEOR work:

- *Versioning and citability.* A package has an explicit version number (Section 30.2). You can say "the results in this submission were produced with `heormodel` v1.2.0", and reproduce exactly that state later, rather than "whatever was in the folder on the server in March."
- *Explicit dependency management.* The package's `DESCRIPTION` file declares every other package it needs (`Imports`), so running the model elsewhere surfaces missing dependencies immediately, instead of failing three functions deep with a cryptic `could not find function` error.
- *Documentation that lives with the code.* Function help files (`roxygen2`, Section 30.3) are written next to the function they describe and are checked for consistency every time the package is built -- they cannot silently drift out of date the way a separate Word-document "user guide" does.
- *Portable, travelling tests.* The `testthat` unit tests discussed in Chapter 27 move with the package rather than sitting in a separate, easily-forgotten folder. Anyone who installs the package can run `devtools::check()` and get an immediate pass/fail on the model's internal logic.

Together with `renv` lockfiles (Section 30.4, and introduced earlier in the book), a real package turns "a folder of scripts that worked on my machine" into something an external statistician, an ERG, or a future version of yourself can install, load, and trust.

#heor-practice[
  A useful trigger question: "will this model be run more than once, by more than one person?" If the honest answer is no -- a single one-off exploratory analysis for an internal feasibility check -- a script is fine. If the model will be re-run for scenario updates, handed to a submission team, or revisited when an agency asks a clarification question months later, the packaging overhead pays for itself almost immediately.
]

#pitfall[
  Do not package prematurely. Full package scaffolding (`DESCRIPTION`, `NAMESPACE`, `man/`, `tests/`, roxygen comments on every function) is overhead that is wasted on a script you will run once and discard. Packaging too early can also lock in a function interface before you have actually explored the modelling problem, forcing needless rewrites. The right moment to package is when a model graduates from "exploration" to "something that will be reused, shared, or submitted" -- not before.
]

== 30.2 Package structure with `usethis` and `devtools`

Building an R package from scratch by hand -- writing a `DESCRIPTION` file, creating the right folder layout, generating a `NAMESPACE` -- is fiddly and easy to get wrong. The `usethis` package automates this scaffolding; `devtools` then drives the day-to-day development loop of editing, reloading, and checking the package. Together they are the standard route most R package authors use, and nothing here is specific to health economics -- the same workflow is used for general-purpose statistical packages.

A new package is created with (illustratively):

```r
usethis::create_package("~/projects/heormodel")
```

This produces the standard R package skeleton:

```
heormodel/
  DESCRIPTION
  NAMESPACE
  R/
  man/
  tests/
```

#difficult-terminology("DESCRIPTION file")[
  A plain-text file of package metadata, read by R itself -- not documentation for humans to browse, but a machine-readable manifest. It records the package's name, version, title, author, and, critically, the `Imports` and `Depends` fields listing every other package it needs to run. When you (or a collaborator, or an HTA agency reviewer) install the package, R reads this file to check all required dependencies are present before anything runs.
]

#difficult-terminology("semantic versioning")[
  A convention for version numbers in the form MAJOR.MINOR.PATCH, e.g. `1.2.0`. PATCH increases for bug fixes that don't change behaviour meaningfully; MINOR increases when new functionality is added but existing code still works as before; MAJOR increases when something changes in a way that could break code written against an earlier version (e.g. a function's arguments change). A health-economic model package versioned this way lets you say precisely which version produced a given set of results, and whether a later version is safe to re-run old analyses against.
]

Within that skeleton, `R/` holds function definitions, `man/` holds the generated help files (Section 30.3), `tests/` holds the `testthat` suite from Chapter 27, and `NAMESPACE` is a file R generates and maintains, listing which functions the package exposes to the outside world.

#difficult-terminology("NAMESPACE")[
  A file, usually auto-generated rather than hand-edited, that tells R exactly which functions in your package are available to a user who types `library(heormodel)`, and which are purely internal helpers. It is what prevents an internal helper function named, say, `clean()`, from silently clashing with a `clean()` function from an entirely different loaded package.
]

`usethis` provides small, targeted helper functions for ongoing scaffolding as the package grows:

```r
usethis::use_r("run_markov_model")   # creates R/run_markov_model.R
usethis::use_testthat()              # sets up tests/testthat/ structure
usethis::use_package("dplyr")        # adds dplyr to DESCRIPTION's Imports
```

`devtools` then drives the edit-check-reload cycle. `devtools::load_all()` simulates installing and loading the package from its current source, so you can test the latest edits without a full install each time. `devtools::check()` runs R CMD check, R's own standard validity check -- it verifies documentation is complete and consistent with function arguments, that any documentation examples actually run without error, that the `NAMESPACE` is internally consistent, and that the `testthat` suite passes. `devtools::install()` performs an actual local install, making the package available via a normal `library()` call elsewhere on the machine.

```r
devtools::load_all()   # load current source, no install needed
devtools::check()      # full R CMD check: docs, examples, tests, NAMESPACE
devtools::install()    # install locally
```

#heor-practice[
  Run `devtools::check()` before every meaningful commit, not just before a release. It is the single fastest way to catch a forgotten `@export` tag, an undocumented function argument, or a test that quietly started failing -- long before any of that surfaces in a submission deliverable.
]

#pitfall[
  The exact argument names and defaults for `usethis::create_package()` and related helpers have changed across package versions, and newer `usethis`/`devtools` releases occasionally rename or deprecate functions. Treat the calls above as illustrative of the workflow rather than a guaranteed-current API reference, and check `?usethis::create_package` (or the current CRAN documentation) against the version actually installed before relying on exact argument behaviour.
]

== 30.3 Documentation with `roxygen2` and `pkgdown`

A packaged model is only as useful as its documentation. Writing a traditional R help file (an `.Rd` file in `man/`) by hand is possible but painful -- it uses its own markup syntax, separate from the code it describes, and is trivially easy to let drift out of sync. `roxygen2` solves this by letting you write documentation as structured comments directly above the function they describe, using tags that start with `@`. Running `roxygen2::roxygenise()` reads those comments and generates both the `.Rd` help files and the `NAMESPACE` entries automatically.

```r
#' Run a cohort Markov model
#'
#' Simulates a cohort through a specified Markov state structure for a
#' given time horizon, returning per-cycle state occupancy and discounted
#' costs and QALYs.
#'
#' @param trans_matrix A square numeric matrix of transition probabilities.
#' @param cycle_length Numeric, length of one model cycle in years.
#' @param n_cycles Integer, number of cycles to simulate.
#' @param discount_rate Numeric, annual discount rate applied to costs
#'   and outcomes (default 0.035).
#'
#' @return A data frame with one row per cycle, giving state occupancy,
#'   discounted costs, and discounted QALYs.
#'
#' @export
run_markov_model <- function(trans_matrix, cycle_length, n_cycles,
                              discount_rate = 0.035) {
  # model logic here
}
```

#difficult-terminology("roxygen2 / @export tag")[
  `roxygen2` is the tool that converts the `#'`-prefixed comments above into formal help pages. The `@export` tag specifically tells it that this function should be listed in `NAMESPACE` as available to users of the package -- functions without `@export` remain internal helpers, invisible outside the package. Omitting `@export` on a function you intended users to call is a common cause of "but it worked when I ran the script directly" confusion after packaging.
]

Running `roxygen2::roxygenise()` (or, more commonly in practice, `devtools::document()`, which calls it for you) regenerates `man/run_markov_model.Rd` and updates `NAMESPACE` to match. Because the documentation is written in the same file as the function, a change to the function's arguments is far more likely to prompt an update to the matching `@param` line -- the two are no longer in separate places that silently diverge.

`roxygen2` documentation is primarily consumed through R's own `?run_markov_model` help lookup. `pkgdown` takes the same source material -- the roxygen-generated help pages, the package's `README`, and any longer-form vignettes -- and builds it into a static, browsable documentation *website*.

```r
pkgdown::build_site()
```

This produces a navigable site with a function reference (one page per documented function, generated straight from the roxygen comments), a home page from the `README`, and any vignettes rendered as articles. For a model that only the original analyst will ever touch, this is unnecessary polish. For a model shared across a wider team, handed to a contract research organisation, or made available to external collaborators or reviewers, a `pkgdown` site turns "please read these twelve R scripts" into a documentation page a non-R-fluent reviewer can click through.

#agency-note[
  NICE's Decision Support Unit technical support documents (the TSD series) repeatedly stress that a submitted model must be usable and checkable by an external reviewer without recourse to the original analyst -- this is the practical rationale behind the independent model-checking step built into NICE technical engagement, where the ERG attempts to run and interrogate the submitted model directly. Thorough `roxygen2` documentation, generated consistently with the code, is one of the more direct ways of meeting that expectation in an R-based submission.
]

#pitfall[
  The exact YAML configuration for a `pkgdown` site (in `_pkgdown.yml`) -- controlling navigation structure, themes, and which vignettes appear where -- varies by `pkgdown` version and is easy to get subtly wrong. Treat any specific YAML shown in tutorials, including the general idea above, as illustrative; consult the current `pkgdown` documentation for the configuration options actually supported by the installed version before relying on it.
]

== 30.4 Pipelines with `targets` and `renv`

A packaged, documented model (Sections 30.2-30.3) is still typically *run* as a sequence of steps: load data, clean it, calibrate parameters (Chapter 27), run the deterministic base case, run probabilistic sensitivity analysis, produce tables and figures. As introduced conceptually in the scheduling discussion in Chapter 28, re-running that entire sequence from scratch every time a single downstream step changes -- say, a tweak to one figure's formatting -- is wasteful once calibration or PSA takes real time to execute. The `targets` package addresses this directly by making the sequence an explicit, inspectable *pipeline*.

#difficult-terminology("pipeline / dependency graph")[
  Here, a pipeline is the set of computational steps needed to go from raw inputs to final results, together with the fact that some steps depend on the outputs of others (PSA depends on calibrated parameters; calibrated parameters depend on cleaned data). Represented formally, this is a dependency graph: a map of which steps feed into which. `targets` builds this graph explicitly from your code, rather than leaving it implicit in the order scripts happen to be run.
]

A `targets` pipeline is declared in a file named `_targets.R`, listing named targets and the function calls that produce them:

```r
# _targets.R (illustrative)
library(targets)

list(
  tar_target(raw_data, read_patient_data("data/raw_cohort.csv")),
  tar_target(clean_data, clean_cohort(raw_data)),
  tar_target(calibrated_params, calibrate_model(clean_data)),
  tar_target(psa_results, run_psa(calibrated_params, n_sims = 10000)),
  tar_target(ceac_plot, make_ceac(psa_results))
)
```

Running `tar_make()` executes this graph in dependency order. The feature that matters most in practice is what `targets` does on the *second* run: it checks whether the code or inputs behind each target have actually changed since the last run, and skips any target whose inputs are unchanged, reusing its previously stored result instead.

```r
tar_make()   # runs only targets whose code/inputs have changed
```

#difficult-terminology("build cache / memoisation")[
  This behaviour -- storing a step's result and reusing it next time instead of recomputing, as long as nothing it depends on has changed -- is a build cache (the general software-engineering term is memoisation). The practical payoff for a PSA with 10,000 simulations: fix a labelling typo in the CEAC plot code, re-run `tar_make()`, and only `ceac_plot` reruns; the ten-thousand-simulation PSA result is reused unchanged, saving what might otherwise be minutes or hours of needless recomputation.
]

`targets` makes the *code and execution order* reproducible -- the same pipeline, re-run, produces the same results from the same inputs, and anyone can see exactly which steps feed into which by reading `_targets.R`. It does not, by itself, guarantee that the *package versions* used to run that code stay fixed. That is `renv`'s job, introduced earlier in the book (Chapter 2, Chapter 28): `renv::snapshot()` records the exact version of every package in use in a lockfile (`renv.lock`), and `renv::restore()` lets anyone -- a collaborator, a future version of yourself, an agency reviewer attempting to rerun the model -- recreate that exact dependency environment.

Used together, `targets` and `renv` cover the two halves of reproducibility that matter for a submission-grade pipeline: `renv.lock` pins *which versions of which packages* were used, and `_targets.R` pins *what was run, in what order, and from what inputs* to produce the submitted results.

#agency-note[
  CADTH's guidance on economic evaluation submissions calls for sufficient detail on the analytic approach that an independent reviewer could, in principle, reproduce the submitted results. A `_targets.R` pipeline committed alongside an `renv.lock` file is a direct, literal answer to that expectation in an R-based submission: the dependency graph states precisely what was run and in what order, and the lockfile states precisely which package versions produced the submitted numbers.
]

#heor-practice[
  Commit both `_targets.R` and `renv.lock` to version control alongside the model package itself, and re-run `tar_make()` from a clean `_targets` cache directory before finalising any submission deliverable. A pipeline that only reproduces results on the original author's machine, with whatever packages happened to be installed at the time, is not meaningfully more reproducible than the loose folder of scripts this chapter opened by moving away from.
]

#pitfall[
  `tar_make()`'s change-detection is based on tracking the code and declared inputs of each target -- it is not magic, and it can be fooled by non-reproducible functions (for example, a random-number step without a fixed seed, or a function that reads from a file path outside the declared inputs). Exact `tar_target()` argument syntax and caching behaviour has evolved across `targets` versions; treat the calls shown here as illustrative of the workflow and check the current `targets` documentation before depending on specific caching semantics.
]

== 30.5 Continuous integration with GitHub Actions

Chapter 27 built a `testthat` suite for the model package, and Section 30.2 introduced `devtools::check()` as the command that runs those tests along with a battery of structural checks (documentation completeness, namespace consistency, example code that actually runs). Both of these are things *you* run, by hand, when you remember to. The problem is that models evolve: a collaborator tweaks a transition probability, you refactor a cost function, someone fixes a typo in a vignette that accidentally breaks a code chunk. Every one of those changes is an opportunity to introduce a bug that `devtools::check()` would have caught -- if anyone had thought to run it.

Continuous integration (CI) removes the "if anyone remembered" problem. The idea, borrowed wholesale from mainstream software engineering, is to automate the check so it runs itself, every time, with no human in the loop to forget.

#difficult-terminology("continuous integration (CI)")[
  Continuous integration is the practice of automatically building and testing code every time it changes, rather than relying on a person to remember to do it. In the HEOR context: every time you push an update to your model package on GitHub, a robot (not a person) spins up a clean computer, installs R and your package's dependencies, runs your test suite and `R CMD check`, and reports back pass or fail -- usually within a few minutes, without you lifting a finger beyond the original push.
]

GitHub Actions is GitHub's built-in CI service, free for public repositories and available at modest cost for private ones (the kind you'd use for an in-development HTA submission model). You tell it what to do via a configuration file written in YAML, placed in a specific folder in your repository.

#difficult-terminology("YAML workflow file")[
  YAML is a plain-text format for writing structured configuration -- think of it as a more human-readable cousin of a CSV or JSON file, built from indented key-value pairs rather than commas. A "workflow file" is a YAML file that tells GitHub Actions what sequence of steps to run (install R, install packages, run checks) and when to run them (on every push, only on the main branch, nightly, and so on). You write it once and rarely touch it again.
]

A GitHub Actions workflow for an R package conventionally lives at `.github/workflows/R-CMD-check.yaml` and, conceptually, does roughly the following. Treat the exact syntax below as illustrative rather than copy-paste-guaranteed -- GitHub Actions' supported actions and their version tags change over time, and the R-specific community actions (maintained by the `r-lib` project) are the authoritative, up-to-date source for exact syntax.

```yaml
# .github/workflows/R-CMD-check.yaml
name: R-CMD-check
on: [push, pull_request]
jobs:
  R-CMD-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: r-lib/actions/setup-r@v2
      - uses: r-lib/actions/setup-renv@v2   # restores renv.lock (Ch. 2 / Ch. 28)
      - uses: r-lib/actions/check-r-package@v2
```

Conceptually, four things happen on every push: (1) a "runner" -- a disposable virtual machine -- is provisioned; (2) R itself is installed; (3) your package's exact dependency versions are restored from `renv.lock` (the lockfile discussed in Chapter 2 and Chapter 28, which is precisely what makes this reproducible rather than "whatever package versions happen to be newest today"); and (4) `R CMD check` and your `testthat` suite run, with the result reported back as a green checkmark or a red cross directly on GitHub, next to the commit that triggered it.

```r
# Locally, this is the same check CI runs remotely on every push
devtools::check()
```

#heor-practice[
  Add a CI status badge to your package's `README.md` -- a small green "passing" or red "failing" icon, generated automatically by GitHub Actions and embedded via a short Markdown snippet. It costs nothing to add and gives any collaborator or reviewer glancing at the repository an instant signal: *does the code currently run without mechanical errors?* For a reviewer deciding whether to trust a model enough to start reading it in detail, a green badge is a small but real confidence boost.
]

#pitfall[
  A green CI badge means the code *runs* and the *existing* tests pass -- nothing more. As Section 27.5 emphasised, CI catches mechanical breakage (a function that errors, a test that now fails), not conceptual or clinical correctness. A model can pass every automated check while still using the wrong discount rate, misapplying a utility decrement, or mis-specifying a transition matrix. CI is a necessary complement to human review, including peer review and, eventually, agency scrutiny -- never a substitute for it. Do not let a green checkmark lull a reviewer (or yourself) into skipping the substantive read-through.
]

== 30.6 Sharing models with HTA agencies and reviewers

Packaging and testing a model (Sections 30.1-30.4) solves the problem of making the model *runnable* by someone other than its author. Sharing it with an HTA agency or an Evidence Review Group (ERG) reviewer raises a second, distinct problem: making sure the model they receive is *exactly* the model you intended to submit, and that it stays that way for the duration of their review.

There are three common mechanisms, in roughly increasing order of openness.

*Private repository with collaborator access.* For a model still under active development, or one tied to a confidential submission, the simplest route is to add the named reviewer (or their institutional GitHub account) as a collaborator on a private GitHub repository, with read-only access. This lets them browse code, open issues asking clarifying questions, and pull the package themselves to run it -- without making the model visible to the wider internet.

*A tagged release attached to the dossier.* Rather than pointing a reviewer at a live, continuously-changing repository, you create a *release*: a named, fixed snapshot of the repository at one specific point in its history, typically also exported as a downloadable zip archive. This archive can then be attached directly to the submission dossier assembled using the automation discussed in Chapter 28, so the model travels with the paperwork rather than as a separate, easily-decoupled link.

*Public repository, for genuinely open models.* Where the funder, journal, or the model owner's own policy calls for full openness (see Section 30.7), the repository is simply made public, with a permanent, citable release tag referenced in the accompanying report.

#difficult-terminology("tagged release")[
  In git (the version-control system underlying GitHub), every saved change is a "commit," and the sequence of commits on a project's main line of development is a "branch" (commonly called `main`). A *tag* is a permanent, human-readable label (e.g. `v1.0-submission`) attached to one specific commit, and a *release* packages that tagged commit as a stable, downloadable snapshot -- source code, and often a compiled version, frozen at that exact point. Critically, a release does not change after the fact: future commits to `main` do not alter what the release contains. This is different from simply giving someone a link to the repository's default view, which shows whatever is on `main` *right now*, including any changes made five minutes ago.
]

```r
# Illustrative: creating a package snapshot for a dossier release
usethis::use_version("minor")   # bumps DESCRIPTION version, e.g. 1.1.0 -> 1.2.0
# Then, on GitHub: Releases -> "Draft a new release" -> tag v1.2.0
# -> attach the dossier PDF and the source zip as release assets
```

Why insist on a tagged release rather than "whatever is on GitHub right now"? Reproducibility and fairness to the review process. If an ERG reviewer spends three weeks working through a model's logic, raises a clarification query, and in week two the sponsor pushes a bug fix to the live repository, the reviewer is now reviewing a moving target -- their earlier notes may no longer correspond to the code in front of them, and it becomes unclear which version any eventual recommendation actually pertains to. A tagged release pins the model: the thing the reviewer received, the thing they reviewed, and the thing cited in their report are provably one and the same artifact, identifiable by its commit hash and tag.

#agency-note[
  NICE's Technology Appraisal process requires that the economic model submitted as part of the company evidence submission be a fixed, reproducible artifact: the version assessed by the ERG during technical engagement must be traceable to a specific submission, with any subsequent model changes (e.g. responding to ERG clarification questions, or revisions following the committee meeting) submitted as explicitly versioned updates rather than silent edits to a previously-submitted file. A git tagged release, attached once to the dossier and never altered afterwards, is a natural technical mechanism for satisfying this expectation when the model's development has moved into a reproducible R package.
]

#pitfall[
  Never grant a reviewer access to a repository without first checking what the main branch currently contains. An in-progress feature branch, an unfinished refactor, or a half-written exploratory analysis sitting on `main` the day a reviewer clicks the link can derail or confuse a review that should only ever have been looking at the tagged, submitted version. Point reviewers at the release, not at the repository's front door.
]

== 30.7 Open-source model licensing and the open-source HEOR movement

Packaging, testing, and CI (Sections 30.1-30.6) make a model technically shareable. Licensing determines what anyone receiving it is legally *allowed to do* with it. This is a genuinely important decision -- and this book will not make it for you. The discussion below is conceptual orientation, not legal advice; any real licensing decision for a model intended for external use, commercial deployment, or public release should involve your organisation's legal or IP team before a license is attached.

With that caveat firmly in place, three licenses cover the large majority of cases encountered in open HEOR work.

#difficult-terminology("open-source license")[
  An open-source license is a legal document attached to a piece of code that grants others specific permissions -- typically to view, use, modify, and redistribute it -- that copyright law would otherwise withhold by default. Without an explicit license, "the code is on GitHub" does *not* mean anyone has the legal right to reuse it; silence is not permission. Choosing a license is choosing, deliberately, what you are giving permission for.
]

#difficult-terminology("permissive vs. copyleft license")[
  A *permissive* license (MIT, Apache 2.0, BSD) imposes very few conditions: others may reuse, modify, and even sell derivative works, usually as long as they keep the original copyright notice. A *copyleft* license (the GPL family) imposes a stronger condition: any derivative work that incorporates the licensed code must itself be released under the same copyleft license -- in effect, "if you build on this, your building must stay open too." The practical consequence is that copyleft code cannot be quietly absorbed into a closed, proprietary product, while permissively-licensed code can.
]

```r
# Illustrative: attaching a license to an R package with usethis
usethis::use_mit_license()     # permissive -- most common for HEOR model packages
# usethis::use_gpl3_license()  # copyleft -- an alternative, stronger-condition choice
```

#ref-table(
  [Three common license choices for HEOR model code and content],
  academic-table(
    columns: (1.2fr, 1.4fr, 1.4fr, 1.8fr),
    align: (left, left, left, left),
    header: ([*License*], [*Commercial reuse allowed?*], [*Derivatives must stay open?*], [*Typical use case*]),
    body: (
      [MIT License], [Yes], [No], [R packages, model code intended for broad reuse (incl. by industry)],
      [GPL-3], [Yes, but derivative must be GPL too], [Yes (copyleft)], [Code where the author wants all downstream forks to remain open],
      [CC-BY], [Yes, with attribution], [No], [Written content, data, reports -- not typically used for code],
    ),
    footer: none,
  ),
) <tab-ch30-licenses>

This book's own companion code repository is a worked example of applying more than one license within a single project. The R code -- packages, functions, example scripts accompanying each chapter -- is released under the MIT License: permissive, allowing readers to lift and reuse code freely, including in commercial consulting or industry submission work, which is exactly the use this book hopes for. The Typst source of the book's *prose* -- the chapters themselves, including this one -- is marked All Rights Reserved, reflecting that the author has not yet made a final decision about how the written content itself should eventually be published. Splitting the license this way, generously open for the code while reserving rights over the text, is a legitimate and common pattern; it is worth checking, for any repository you depend on, that the license file actually says what you assume it says, and that it says the same thing for code and for any accompanying prose or data.

#heor-practice[
  Add a `LICENSE` file at the root of any package repository you intend others to use, even internally. "No license specified" is frequently read, correctly, as "no permission granted" -- the single most common reason a potentially useful piece of health-economic code never gets reused outside the team that wrote it.
]

Beyond the mechanics of any one license, there is a broader current worth naming: a genuine, growing movement within HEOR and HTA toward open, auditable, reproducible models, as a deliberate alternative to closed proprietary spreadsheet or TreeAge models whose internal logic cannot be independently inspected by a reviewer, a competing analyst, or an interested clinician. An R package with a public test suite, visible CI history, and a clear license is, structurally, a much more auditable object than a locked Excel workbook emailed as an attachment -- every assumption is in readable code, every change is in a visible history, and every claim about "the model does X" can in principle be checked by running it. This is the same transparency-and-reproducibility thread this book has followed since Chapter 1, now arriving at its logical practical endpoint: a model that is not only *correct*, but *demonstrably and checkably* so, to anyone willing to read the code.

This closes Chapter 30, and with it Part VI, _Reporting, Communication and Deployment_. Part VII, _HTA in Practice_, opens with Chapter 31, _Agency Requirements and Reference Cases_, turning from how models are built and shared to what the agencies actually require once they arrive.
