#import "../common.typ": *

= Chapter 2. Setting Up an R Environment for HEOR

#learning-objectives((
  [Install and configure R, an IDE (RStudio or Positron), and Quarto for reproducible HEOR reporting.],
  [Structure a new HEOR analysis project so that raw data, code, and outputs stay cleanly separated and auditable.],
  [Use `renv` to pin exact package versions so a model can be reproduced byte-for-byte years after submission.],
  [Set up Git/GitHub version control as both an audit trail and a lightweight QA mechanism mirroring agency technical review.],
  [Install the C++ toolchain required for Bayesian modelling with Stan/JAGS, and avoid the installation pitfalls that most commonly block analysts moving into Bayesian HEOR work.],
  [Understand when Docker is worth the overhead for a submission-critical model, versus when `renv` alone is sufficient.],
  [Navigate the R package ecosystem for HEOR by task area, with forward references to the chapters that cover each package in depth.],
))

== 2.1 Installing R, RStudio/Positron and Quarto

Every HEOR analysis in this book rests on three pieces of software: R itself, an integrated development environment (IDE), and Quarto for turning analysis into submission-ready documents. Installing these correctly, and understanding the role each plays, prevents a surprising fraction of the reproducibility headaches that plague health-economic modelling teams.

R is distributed through the Comprehensive R Archive Network (CRAN) at `cran.r-project.org`. On Windows, download and run the `.exe` installer; on macOS, use the `.pkg` installer matching your chip architecture (Apple Silicon vs Intel); on Linux, prefer your distribution's package manager or the CRAN apt/yum repositories over a source build, since these handle dependency resolution and security updates automatically. Install the latest patch release of the current major R version unless a specific project mandates otherwise — version pinning is handled later, at the project level, by `renv` (Section 2.3), not by freezing your system R.

For years, RStudio Desktop was the default IDE for R users, and it remains a fully capable, mature choice: integrated console, environment pane, plotting pane, and tight Quarto/R Markdown support. Posit (RStudio's parent company) has since released *Positron*, a VS Code–based IDE built on the same open extensibility model as Visual Studio Code, but with first-class R and Python data-science support built in rather than bolted on. For HEOR work specifically, Positron is gaining traction for several concrete reasons:

#list(
  [Many HTA submissions now combine R (statistical/economic modelling) with Python (machine-learning-based survival extrapolation, web-scraping literature data, or interfacing with external APIs) in the same project — Positron handles both languages natively in one workspace, without the friction of RStudio's R-first design.],
  [It inherits the entire VS Code extension ecosystem: Git integration, remote development over SSH, Docker/dev-container support, and GitHub Copilot-style tooling, which matter increasingly for teams working under version control and CI pipelines.],
  [Its data viewer, variable inspector, and plot pane are drop-in equivalents to RStudio's, so the learning curve for an RStudio user is shallow.],
)

Positron is still younger than RStudio and a handful of RStudio-specific add-ins have no Positron equivalent yet, so this book treats either IDE as acceptable; screenshots and keybinding references favour RStudio terminology where the two diverge, but all code runs identically in both.

Quarto is Posit's successor to R Markdown and ships either bundled with RStudio/Positron or as a standalone CLI installable from `quarto.org`. It compiles `.qmd` documents mixing prose and executable R (or Python, Julia, Observable JS) code chunks into HTML, PDF, Word, or slide formats — critical for HEOR, where a single analysis often must be rendered as an internal technical report, a submission-ready Word document for a HTA body, and a results dashboard, all from one source file. Confirm your installation with:

```r
quarto::quarto_version()
```

#heor-practice[
  Standardise on one Quarto version and one R version per *project*, not per analyst's machine. Record both in your project's README and, as Section 2.3 shows, let `renv` pin the R package versions precisely — the Quarto and R engine versions themselves should be noted explicitly since `renv` does not manage them.
]

== 2.2 Project structure for HEOR analyses

A consistent folder structure is not bureaucratic overhead — it is the single cheapest thing you can do to make an analysis auditable, handoff-ready, and defensible under HTA scrutiny. HEOR deliverables are frequently revisited months or years after initial submission (in response to reviewer queries, re-submissions, or country adaptations), often by someone other than the original analyst. A predictable layout means that person — possibly future you — can find the raw inputs, the code that transformed them, and the exact outputs without reverse-engineering a one-off script.

A structure that has proven robust across cost-effectiveness models, budget-impact analyses, and systematic literature reviews looks like this:

```r
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

The rationale behind each separation matters more than the names themselves:

#list(
  [*`data-raw/` is immutable.* Nothing in this folder is ever edited by hand or overwritten by a script. If a trial extract or vendor file changes, a new file (or new version) is added — the folder is a permanent, auditable record of what came in. Cleaning logic lives in code under `R/`, not in the data itself.],
  [*`data/` is derived, not authoritative.* Everything here should be fully reproducible by re-running the cleaning scripts against `data-raw/`. If `data/` were deleted entirely, the project should be able to regenerate it byte-for-byte.],
  [*`R/` separates logic from execution.* Functions used by more than one analysis script (cost calculations, utility mapping, plotting themes) belong here, loaded via `source()` or, for larger projects, packaged with `devtools::load_all()`. This avoids copy-pasted logic drifting out of sync across scripts.],
  [*`analysis/` contains the actual narrative* — Quarto documents or scripts that call functions from `R/` against data from `data/` and produce results. Each file here should, in principle, run top-to-bottom on a clean machine and reproduce its own output.],
  [*`output/` is disposable.* Nothing here is a source of truth; it is always regenerable by re-running `analysis/`. Treating output as disposable is what keeps the project honest — if you can't regenerate a table from scratch, something in the pipeline is undocumented.],
)

A convenient starting scaffold is `usethis::create_project()`, which creates the `.Rproj` file, a sensible `.gitignore`, and an R-project-aware working directory in one call:

```r
usethis::create_project("~/projects/my-heor-project")
```

From there, manually add the `data-raw/`, `data/`, `analysis/`, and `output/` directories (a small helper function wrapping `dir.create()` calls is worth writing once and reusing across projects).

#pitfall[
  Do not defer this structure until "the analysis is more final." The most common failure mode is a single sprawling script that reads a spreadsheet, cleans it, models it, and plots it in one pass — impossible to audit, and nearly impossible to hand off. Separating concerns from the first commit costs minutes; retrofitting it onto a 2,000-line script before a submission deadline costs days.
]

== 2.3 Package management with `renv`

R's package ecosystem evolves continuously, and HEOR analyses routinely have a shelf life of years — a submitted cost-effectiveness model may be queried, re-analysed, or audited long after its packages have moved on to incompatible new versions. Without intervention, simply running `install.packages("survival")` updates the package for *every* project on your machine, silently changing numerical behaviour (confidence interval methods, extrapolation defaults, random number handling) in ways that can alter results computed from the exact same code. `renv` solves this by giving every project its own private, isolated package library and a lockfile recording exact versions.

Initialise `renv` once per project, from the project root:

```r
renv::init()
```

This scans your scripts and Quarto documents for `library()`/`require()` calls, builds a private project library under `renv/library/`, and writes an initial `renv.lock` file. From that point, package installs made inside the project (`install.packages()`, `remotes::install_github()`, etc.) are captured in that private library and do not affect your system-wide R installation or other projects.

As the analysis develops and you add or update packages, record the current state with:

```r
renv::snapshot()
```

`snapshot()` inspects every package actually used in the project and writes their exact versions — plus, where resolvable, their source (CRAN, Bioconductor, GitHub, with commit hash) — into `renv.lock`. Conversely, to recreate the *exact* environment the lockfile describes, on a new machine or a colleague's laptop, run:

```r
renv::restore()
```

`restore()` reads `renv.lock` and installs precisely those package versions into the project's private library, regardless of what is currently installed elsewhere on the system.

The `renv.lock` file itself is plain JSON, version-controllable alongside your code, and human-readable: it records the R version the project was built under, the package repositories consulted, and for each package its name, version, and source hash. A fragment looks like:

```r
# (illustrative structure, not a function call)
# {
#   "R": { "Version": "4.3.2" },
#   "Packages": {
#     "survival": { "Package": "survival", "Version": "3.5-7",
#                    "Source": "Repository", "Repository": "CRAN" }
#   }
# }
```

#agency-note[
  NICE's Decision Support Unit has published explicit technical support documents (the DSU TSD series referenced throughout this book, e.g. TSD 14 and TSD 21 for survival extrapolation in Chapter 10) that assume a reviewer can inspect and re-run the submitted model's code — NICE's own technology appraisal process guide requires companies to submit the executable model itself, not only a written description of methods, specifically so the Evidence Review Group can verify calculations independently. CADTH's Guidelines for the Economic Evaluation of Health Technologies similarly requires an electronic copy of the model. Neither agency mandates R or `renv` specifically, but both mandate that *whatever* tool is used be inspectable and re-runnable by the reviewing team — which is precisely the gap `renv.lock` closes for an R-based submission. Committing `renv.lock` alongside your analysis code is what makes "re-run this years later" operationally possible, not just a nice-to-have.
]

#pitfall[
  The most common `renv` mistake is treating it as an optional add-on for "later," adopted only once a project is already underway. By the time collaborators have installed ad-hoc package versions by hand, `renv::init()` inherits an already-inconsistent environment, and reconciling it is far more work than starting clean. Run `renv::init()` as the *first* command in a new HEOR project, before a single `install.packages()` call — the discipline costs nothing up front and prevents an entire category of "it worked on my machine" failures later.
]

Finally, note that `renv` manages R packages, not the R interpreter version, system libraries, or Quarto itself — pair it with the version documentation practice recommended in Section 2.1 for full environment reproducibility.

== 2.4 Version control with Git and GitHub

Health economic models are not static deliverables; they are living software artifacts that get re-run dozens of times as evidence changes, reviewers request scenario analyses, and submission deadlines force last-minute parameter updates. Without version control, "the model" quickly fragments into a folder of files named `markov_model_v3_final_FINAL_usethisone.R`, with no record of which assumptions changed between versions or who approved them. Git solves this by tracking every change as a discrete, attributable commit, and GitHub (or an equivalent host) adds the collaborative layer — issues, pull requests, and review history — that turns a personal habit into a team process.

For HEOR work specifically, version control earns its keep in three ways. First, *auditability*: reimbursement submissions to bodies such as NICE, CADTH, or ICER (the US nonprofit, not the cost-effectiveness ratio) are frequently re-opened months later when a reviewer asks "what if the discount rate were 1.5% instead of 3.5%?" A clean commit history lets you answer "what changed between the submitted model and this scenario" with `git diff`, rather than by memory. Second, *branching for scenario analysis*: each deterministic or structural sensitivity analysis — a different time horizon, an alternative comparator, a revised utility source — belongs on its own branch, built from the same validated base model. This keeps the base case stable while exploratory work proceeds in parallel, and it makes clear which scenarios were ever merged back into the primary analysis. Third, *pull requests as quality control*: requiring every change to a submission-track model to go through a PR — with a named reviewer checking the diff line by line — mirrors the technical review step that payer bodies themselves apply to submitted models. It catches hard-coded values, accidental formula changes, and unreviewed shortcuts before they reach a regulator.

#heor-practice[
  Treat your Git workflow as a lightweight mirror of agency technical review: no commit to the `main`/`submission` branch without an approving PR from a second analyst. Tag the exact commit hash used to produce the submitted report's figures (`git tag submission-v1 <hash>`) so the evidentiary model can always be reconstructed byte-for-byte, even after further development continues on other branches.
]

The basic workflow for a new HEOR project is unremarkable but worth stating explicitly, since many analysts come from a non-software background:

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

GitHub's value beyond raw Git is largely social: it gives external statisticians, academic collaborators, or a payer's technical reviewers a place to comment on specific lines of code, request changes, and approve a merge without needing filesystem access to your machine. Private repositories (or an enterprise GitHub/GitLab instance, which many HTA consultancies and pharmaceutical sponsors require for data governance reasons) support this collaboration while keeping the codebase restricted to named contributors.

A `.gitignore` file needs particular care in this domain. Renv's `renv.lock` file should always be committed — it is the machine-readable record of package versions that makes the environment reproducible and is small, plain-text JSON. By contrast, the `renv/library` folder (the actual installed packages) and any `.Rproj.user` or `.Rhistory` files should be excluded, since they are large, machine-specific, and regenerable from the lockfile.

#pitfall[
  Never commit real patient-level data, even temporarily, even on a private repository. A patient-level dataset pulled into a project folder for a quick test and then "removed" in a later commit still exists in Git's history — `git log` and `git show` can retrieve it from any prior commit unless the history itself is rewritten and force-pushed, which is destructive and easy to get wrong. Add `data/raw/`, `*.csv` (or more targeted patterns for your actual raw-data paths), and any patient-level extracts to `.gitignore` from the very first commit, before any such file is ever staged. If synthetic or de-identified data is needed for the repository, generate it programmatically and label it unambiguously as synthetic in the filename and header.
]

== 2.5 Working with Stan, JAGS and C++ toolchains

From Chapter 14 onward, this book moves into Bayesian methods — probabilistic sensitivity analysis built on posterior distributions, network meta-analysis, and survival extrapolation models that borrow strength across data sources via hierarchical structure. These techniques are typically fit not with a built-in R function but with a dedicated probabilistic programming language: Stan or, in older or legacy codebases, JAGS (Just Another Gibbs Sampler). Both let you write the statistical model directly as a set of distributional statements and delegate the hard work of sampling from the posterior to an efficient external sampler — Hamiltonian Monte Carlo (via the No-U-Turn Sampler) in Stan's case, and Gibbs sampling in JAGS's case.

#difficult-terminology("posterior distribution")[
In Bayesian statistics, you start with a *prior* — your belief about a
parameter (say, a treatment's true effect size) before looking at the
current data, which might be deliberately vague ("anywhere from a
large harm to a large benefit is plausible") or informed by previous
studies. You then combine that prior with the data actually observed
in your trial or dataset, using the rules of probability, to get an
updated belief: the *posterior distribution*. It is not a single
number but a full distribution — a range of plausible values for the
parameter, each with an associated probability — because Bayesian
inference treats the parameter itself as uncertain and quantifies
exactly how uncertain, before and after seeing data. A simple analogy:
if your prior is "this coin is probably close to fair" and you then
flip it 20 times and see 15 heads, your posterior shifts the
diagnosis-of-fairness towards a biased coin, by an amount that depends
on how strong your prior was and how much data you collected. The
posterior is usually too mathematically complex to compute an exact
formula for in any realistic health-economic model, which is exactly
why dedicated samplers like Stan and JAGS exist — they approximate
the posterior by drawing thousands of representative random samples
from it rather than solving it analytically.
]

#difficult-terminology("hierarchical structure (\"borrowing strength\")")[
A hierarchical (or "multi-level") model structure is used when your
data naturally comes in related groups — for example, several
different trials of similar drugs, or several hospitals reporting the
same outcome. Rather than treating each group as completely separate
(ignoring that they are related) or pooling all the data together as
if the groups didn't exist (ignoring that they might genuinely differ),
a hierarchical model does something in between: it estimates a
group-specific effect for each group, but constrains those group
estimates to be drawn from a shared, overarching distribution that the
model also estimates. The practical consequence is "borrowing
strength" — a group with very little data of its own (a small trial,
or a hospital with few cases) gets pulled gently towards the overall
average, because the model recognises it as one draw from the same
underlying family as the data-rich groups, instead of relying purely
on its own sparse, noisy numbers. A classroom analogy: if you want to
estimate how good each of thirty schools' maths teaching is, but some
schools only have five students' scores while others have five
hundred, a hierarchical model lets the small schools' estimates
"borrow" precision from the overall district pattern, rather than
wildly over- or under-stating how good that one small school's
teaching really is based on five noisy data points alone.
]

#difficult-terminology("Hamiltonian Monte Carlo / No-U-Turn Sampler (NUTS)")[
Sampling from a posterior distribution (see the box above) means
drawing many representative random values from it so you can
summarise what the model believes, once data has been accounted for.
Hamiltonian Monte Carlo (HMC) is a particular, physics-inspired
algorithm for doing this efficiently in models with many parameters:
rather than wandering around the parameter space in small, nearly
random steps (which is slow and can get stuck), it simulates a
"puck" sliding across the probability landscape as if under gravity
and momentum, following smooth, informed trajectories that explore
the most probable regions much faster. The one dial every HMC
implementation needs is how far each simulated trajectory should run
before stopping; get this wrong and the sampler either wastes time
retracing its own path or stops too early to be useful. The No-U-Turn
Sampler (NUTS) is the clever auto-tuning addition that solves this:
it monitors the simulated trajectory and automatically stops it the
moment it starts curving back on itself (making a "U-turn"), so the
step length is chosen automatically rather than by manual trial and
error. You do not need to understand the physics to use Stan, which
implements HMC/NUTS under the hood — the practical takeaway is simply
that this is why Stan is usually faster and more reliable than older
samplers for complex Bayesian HEOR models, with little manual tuning
required.
]

#difficult-terminology("Gibbs sampling")[
Gibbs sampling is an older, simpler approach to the same sampling
problem that Hamiltonian Monte Carlo solves (see above): drawing
representative random values from a posterior distribution with
several unknown parameters at once. Instead of moving all parameters
together, it updates them one at a time, in turn: hold every other
parameter fixed at its current value, draw a new random value for just
one parameter conditional on those fixed values, then move on to the
next parameter and repeat, cycling through all of them over and over.
Over many such cycles, the sequence of values produced converges to
representative draws from the full joint posterior. It is
conceptually simple to implement and was, for a long time, the
workhorse behind BUGS and JAGS-style Bayesian software in health
economics and epidemiology, but it can be noticeably slower to explore
complex models than Hamiltonian Monte Carlo/NUTS, particularly when
parameters are strongly correlated with each other — one reason newer
R-based Bayesian HEOR work has shifted increasingly towards Stan.
]

The practical consequence for an R-based HEOR workflow is that Stan model code is compiled to C++ before it runs. The R packages `rstan` and `cmdstanr` are interfaces that generate this C++, hand it to a compiler, and then call the resulting executable — they are not pure-R implementations. This means your machine needs a working C++ toolchain, which is rarely installed by default and is the single most common installation obstacle analysts moving from base R or `survival`/`flexsurv`-style modelling report when they first try Bayesian HEOR work.

The toolchain requirement differs by operating system:

#list(
  [*Windows*: requires Rtools, a separate installer (matched to your R version, e.g. Rtools42 for R 4.2.x) that provides a `gcc`-based compiler and the Unix-like build utilities R's compilation toolchain expects. It is not installed by running `install.packages()`; it is a standalone download from CRAN's Rtools page and must be on the system `PATH`.],
  [*macOS*: requires the Xcode Command Line Tools, installed with `xcode-select --install` from a terminal, which provides `clang` and related build tools without requiring the full Xcode IDE.],
  [*Linux*: requires the standard GNU build toolchain, typically installed via the distribution's package manager, e.g. `sudo apt-get install build-essential` on Debian/Ubuntu, which supplies `gcc`, `g++`, and `make`.],
)

```bash
# macOS
xcode-select --install

# Debian/Ubuntu
sudo apt-get update && sudo apt-get install build-essential
```

Once the toolchain is present, `cmdstanr` is the interface this book recommends over the older `rstan`. `cmdstanr` is a lightweight wrapper around CmdStan, the Stan command-line interface, and is updated in step with the core Stan language; `rstan` bundles its own, often older, copy of Stan directly into the R package and has historically lagged behind in supporting newer Stan features and compiler versions. Installing `cmdstanr` additionally requires a one-time call to `cmdstanr::install_cmdstan()`, which downloads and compiles CmdStan itself — a step that can take several minutes and depends on the same toolchain described above.

```r
install.packages("cmdstanr",
  repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
cmdstanr::check_cmdstan_toolchain()
cmdstanr::install_cmdstan()
```

JAGS, used in some legacy HEOR network meta-analysis scripts via the `rjags` or `R2jags` packages, is architecturally different: it is a standalone program installed outside of R (from SourceForge, or via the distribution's package manager on Linux) rather than a C++ code generator, so it does not share Stan's compiler requirement — but it does require that the JAGS binary itself be installed and discoverable before `rjags` will load.

#agency-note[
  If a submission package to a payer body includes Bayesian NMA or survival extrapolation results, document the exact Stan/CmdStan or JAGS version used, alongside the R package versions captured in `renv.lock`. NICE DSU TSD 2 (the technical support document governing network meta-analysis methodology, covered in depth in Chapter 12) explicitly requires reporting of the software and convergence diagnostics used to fit a Bayesian NMA — not just the point estimates — because posterior samples from MCMC are not guaranteed bit-identical across sampler versions even with a fixed seed, and a reviewer reproducing your analysis on a different machine needs to know which toolchain generated the submitted numbers.
]

#pitfall[
  A frequent failure mode is installing `rstan` or `cmdstanr` successfully but hitting cryptic compiler errors only when the first model is actually compiled — because `install.packages()` succeeds without ever invoking the C++ compiler, while fitting a model does. Run `cmdstanr::check_cmdstan_toolchain()` (or `pkgbuild::has_build_tools(debug = TRUE)` for `rstan`) immediately after installing the toolchain, before writing any model code, so toolchain problems are caught early rather than mid-analysis under deadline pressure.
]

== 2.6 Containers (Docker) for reproducible models

`renv` (Section 2.3) solves a specific problem well: it pins the versions of R packages and records where they came from. But it solves only part of the reproducibility problem. The R packages installed by `renv::restore()` still have to compile or link against something — a particular R interpreter version, system libraries such as `libcurl`, `zlib`, or `libxml2`, a BLAS/LAPACK implementation for numerical linear algebra, fonts for PDF rendering, and an operating system that provides all of the above in a given configuration. None of this is captured by a `renv.lock` file. If a reviewer, a regulator's technical team, or a colleague two years from now tries to rebuild your analysis on a different Linux distribution, a different R minor version, or a Mac with Apple Silicon instead of an Intel chip, subtle numerical differences can appear even with *identical* package versions — different BLAS implementations alone can shift floating-point results in the eighth decimal place, which is usually immaterial for an ICER but can matter in a bootstrap or Markov trace with many iterations.

Docker addresses this by pinning the entire execution environment: the base operating system, the system libraries, the R version itself, and then the R packages on top. A container built from a `Dockerfile` today will — barring extreme edge cases such as architecture changes — produce bit-for-bit the same computational environment years later, regardless of what has changed on the host machine or in CRAN's current package index.

A minimal, HEOR-appropriate `Dockerfile` built on the Rocker Project's `rocker/r-ver` image, which pins an exact R version, looks like this:

```dockerfile
FROM rocker/r-ver:4.3.2

# System libraries needed by common HEOR packages
# (XML, curl, and SSL for reporting/network packages;
# a Fortran compiler for survival/optimisation routines)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /model

# Bring in the renv lockfile and restore from it
COPY renv.lock renv.lock
RUN Rscript -e "install.packages('renv'); renv::restore()"

COPY . .

CMD ["Rscript", "run_model.R"]
```

This pairs the two tools rather than treating them as alternatives: `renv.lock` still governs exactly which package versions are installed, while the `Dockerfile` governs everything renv cannot see.

#heor-practice[
  A practical rule of thumb for submission-critical models (NICE, ICER, CADTH, or similar HTA body submissions): if the deliverable includes an executable model that a third party is expected to independently re-run and reproduce your base-case and sensitivity-analysis outputs, build and ship a Docker image alongside the R code, not instead of it. NICE's technology appraisal process explicitly provides for the Evidence Review Group to request the submitted model and re-run it during the technical engagement stage — a containerized model removes "it depends on my machine's configuration" as a possible point of failure during that review. Tag the image with the model version and archive it (e.g. as a `.tar` export via `docker save`, or pushed to a registry with access controls) with the rest of the submission package. "It ran on my machine" is not an acceptable reproducibility standard when a cost-effectiveness claim underpins a reimbursement decision.
]

Docker is not always worth the overhead, however. For exploratory or internal analysis — scoping work, early-stage model structuring, or a one-off piece of academic research where the main deliverable is a paper rather than an auditable model — a well-maintained `renv.lock` file, used consistently with a documented R version, is usually sufficient and considerably lighter-weight to maintain. Docker adds real friction: a build step, image storage, the need for collaborators to have Docker installed and to understand basic container commands, and slower iteration during active development because every system-library change means a rebuild. The decision point is usually: *will someone outside this project, possibly without R expertise, need to re-run this exact model and get the exact same numbers?* If yes, containerize. If the risk is only "a package update broke something," `renv` alone addresses that.

#pitfall[
  Running `apt-get install` or `install.packages()` inside a `Dockerfile` without pinning versions defeats the purpose of using Docker at all — the image will build differently on different days as upstream repositories update. Always pin the base image tag (e.g. `rocker/r-ver:4.3.2`, never `rocker/r-ver:latest`), and let `renv::restore()` — driven by a committed lockfile — control package versions rather than a bare `install.packages()` call.
]

One further practical point: R package installation inside a container can be slow, because by default `install.packages()` and `renv::restore()` compile packages from source on Linux. Posit Package Manager (formerly RStudio Package Manager, often referenced by its public endpoint `packagemanager.posit.co`, historically "RSPM") serves pre-compiled binary builds of CRAN packages for specific Linux distributions. Pointing your container's R options at a Posit Package Manager binary repository snapshot — rather than CRAN's source-only mirrors — can cut a `renv::restore()` that takes twenty minutes down to under a minute, which matters considerably for CI pipelines and iterative image rebuilds. Posit Package Manager also lets you pin to a *dated snapshot* of CRAN, giving you an additional, complementary layer of reproducibility alongside `renv` and Docker.

#agency-note[
  If you are automating image builds (for example, rebuilding a model's Docker image nightly or on every `renv.lock` change via a CI pipeline), have the automation fail loudly — not silently fall back to `latest` tags or an un-pinned package source — the moment a pinned base image or snapshot date becomes unavailable. A silent fallback is exactly the kind of drift Docker was adopted to prevent.
]

== 2.7 Recommended package ecosystem (overview map)

The preceding sections set up the plumbing — R itself, RStudio or another IDE, renv, and optionally Docker. What actually gets installed into that environment is the subject of most of the rest of this book. R's package ecosystem for health economics and outcomes research has matured substantially over the past decade, to the point where nearly every stage of a cost-effectiveness analysis — from cleaning trial data through to generating a submission-ready report — has at least one well-maintained, peer-used package behind it. This section is meant as a map you can return to: a single reference point that tells you, for a given task, which package to reach for and which later chapter in this book covers it in depth.

#heor-practice[
  Do not install everything in this table at once "just in case." Install packages as your project needs them, and record each one in your `renv.lock` file as you go (Section 2.3). A project's dependency tree should reflect what the analysis actually uses, both for reproducibility and so that a reviewer of your code can infer the analytical approach from the `library()` calls alone.
]

#ref-table(
  [R package ecosystem for HEOR by task area, with the key packages for each and where in this book they are covered in depth.],
  academic-table(
    columns: (1.3fr, 2fr, auto),
    align: (left, left, left),
    header: ([*Task area*], [*Key packages*], [*Covered in*]),
    body: (
      [Data wrangling], [`tidyverse` (`dplyr`, `tidyr`, `ggplot2`, `purrr`), `data.table`], [Ch. 3-5],
      [Survival analysis], [`survival`, `flexsurv`, `flexsurvcure`], [Ch. 10],
      [Meta-analysis], [`meta`, `metafor`], [Ch. 11],
      [Network meta-analysis], [`netmeta`, `gemtc`, `multinma`], [Ch. 12],
      [Bayesian modelling], [`brms`, `rstan`, `cmdstanr`], [Ch. 14],
      [Decision-tree modelling], [`rdecision`, `heemod`], [Ch. 18],
      [Markov / cohort models], [`heemod`, `hesim`], [Ch. 19],
      [Uncertainty analysis / VOI], [`BCEA`, `dampack`, `voi`], [Ch. 25-26],
      [Missing data], [`mice`, `Amelia`, `missForest`], [Ch. 25],
      [Reporting], [Quarto, `gt`, `gtsummary`, `flextable`], [Ch. 28],
      [Interactive apps], [`shiny`, `golem`, `rhino`], [Ch. 29],
    ),
    footer: none,
  ),
) <tab-ch02-package-ecosystem>

A few orientation notes on how these areas relate to one another in practice:

#list(
  [*Data wrangling is the substrate everything else sits on.* Whether you ultimately build a Markov model with `heemod` or run a network meta-analysis with `netmeta`, the input data almost always passes through `tidyverse` or `data.table` pipelines first. Chapters 3–5 build this foundation before any health-economic modelling is introduced.],
  [*Survival analysis and decision modelling are tightly coupled.* `flexsurv` fits parametric survival curves to trial data; those fitted distributions frequently become the transition probabilities or extrapolated survival inputs for a `heemod` or `hesim` Markov model. Expect chapters 10, 18, and 19 to cross-reference each other heavily.],
  [*`heemod` and `hesim` overlap but are not interchangeable.* `heemod` has a gentler learning curve and a clear cohort-based Markov-model API; `hesim` is built for speed at scale (large PSA runs, individual-level microsimulation, and multi-state models) and integrates more directly with `flexsurv` objects. Chapter 19 covers the trade-offs and when to reach for each.],
  [*Evidence synthesis scales from pairwise to network to Bayesian.* `meta` and `metafor` handle classical pairwise meta-analysis; `netmeta` and `gemtc` extend this to networks of trials; `multinma` and `gemtc` both support Bayesian NMA, with `multinma` in particular designed with HTA-style population-adjustment methods in mind. `brms`, `rstan`, and `cmdstanr` sit one level below these as general-purpose Bayesian engines that some of the above packages call internally, and that chapter 14 also teaches you to use directly for custom Bayesian economic models.],
  [*Uncertainty analysis is usually the last mile, not a separate project.* `BCEA`, `dampack`, and `voi` all operate on the output of a probabilistic sensitivity analysis already run through a decision model — they do not run the model themselves. Chapters 25–26 assume you arrive with PSA output in hand.],
  [*Reporting tools are what turns a script into a deliverable.* Quarto (not a package in the traditional sense, but the rendering engine increasingly replacing R Markdown for this purpose) combined with `gt`, `gtsummary`, and `flextable` is how most modern HEOR teams produce submission-ready tables and reproducible reports directly from R code; chapter 28 builds a full reporting pipeline this way.],
)

#difficult-terminology("multi-state model")[
A simple survival model only tracks one transition — alive to dead —
and a basic Markov model usually tracks a small, fixed set of health
states (e.g. well, progressed, dead). A multi-state model generalises
both: it formally tracks a patient moving between any number of
defined health states over time, estimating both the *probability* of
each possible transition (e.g. from "stable disease" to "progression"
versus to "death" directly) and the *timing* of when it happens, using
the same survival-analysis machinery (hazard functions, covered in
Chapter 10) applied separately to each possible transition in the
diagram. A useful analogy is a subway map with multiple interchangeable
lines and stations: a simple survival model only asks "did the train
ever reach the depot (death)," while a multi-state model asks, for
every station (health state) a train currently sits at, which of the
several next stations it's most likely to travel to next, and how long
that leg of the journey typically takes. `hesim`'s multi-state-model
support (mentioned above) is what lets an R-based HEOR model represent
disease pathways that are richer than a simple two- or three-state
Markov structure — common, for example, in oncology models with
distinct progression, response and relapse states.
]

#pitfall[
  Package names in this space are easy to confuse because several solve adjacent but distinct problems: `meta` and `metafor` are not interchangeable with `netmeta` (pairwise vs. network evidence), and `mice` (multiple imputation by chained equations) is a fundamentally different missing-data strategy from `missForest` (a random-forest-based single imputation method) — the choice between them has real implications for your estimates' standard errors, not just a difference in syntax. Confirm you are using the package appropriate to your actual evidence structure and missingness mechanism before trusting its defaults.
]

#agency-note[
  If you are using an AI coding assistant to scaffold HEOR analysis code, be specific about which package you mean when a generic term like "run a meta-analysis" or "build a decision model" is ambiguous across several packages in the table above — an assistant without HEOR-specific context may default to the most commonly documented general-statistics package (e.g. plain `survival`) rather than the domain-appropriate one (e.g. `flexsurv` for parametric extrapolation), and the resulting code may run without error while answering the wrong question.
]
