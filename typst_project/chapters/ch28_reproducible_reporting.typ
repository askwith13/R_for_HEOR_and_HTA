#import "../common.typ": *

= Chapter 28. Reproducible Reporting

#learning-objectives((
  [Explain the difference between Quarto and classic R Markdown, and build a Quarto document whose YAML front matter and code chunks render a live HEOR summary report.],
  [Write a parameterised Quarto/R Markdown report and loop its rendering across multiple scenarios, subgroups or sites.],
  [Produce the same analysis as Word, PDF, HTML and PowerPoint output, including native editable Office elements via `officedown`/`officer`.],
  [Choose among `gt`, `gtsummary`, `flextable` and `kableExtra` for a publication-ready results table, and justify the choice by destination format.],
  [Build a reusable `ggplot2` theme and apply colour-blind-safe palettes, saving figures at print resolution.],
  [Track CHEERS 2022 checklist compliance programmatically rather than by hand.],
  [Assemble a multi-section HTA submission dossier from parameterised Quarto child documents.],
  [Automate routine, recurring reports across programmes or districts, and choose a sensible scheduling mechanism for the pipeline.],
))

Chapter 27 closed on a reminder that calibration and validation evidence is only as useful as the report that carries it to a decision-maker. A beautifully validated TB Markov model that lives only in an analyst's R console, with figures copy-pasted into a Word document by hand, is a model whose evidence trail breaks the moment someone asks "show me exactly how this number was produced." This chapter is about closing that gap: turning R code, model output and narrative text into a single document that regenerates itself from source, every time, byte-for-byte traceable back to the code that created it.

== 28.1 Quarto and R Markdown for HEOR reports

The tool of choice for this in modern R-based HEOR work is Quarto, which has effectively superseded classic R Markdown for new projects, though R Markdown remains extremely common in legacy codebases and some submission templates still expect `.Rmd` files.

=== R Markdown and Quarto: what changed and what didn't

R Markdown (`.Rmd` files, powered by the `rmarkdown` and `knitr` packages) pioneered "literate programming" for R: a plain-text document mixing prose (written in Markdown) with executable R code blocks, rendered to HTML, PDF or Word via Pandoc. Quarto (`.qmd` files) is Posit's (RStudio's) next-generation evolution of the same idea, built as a standalone, language-agnostic command-line tool rather than an R package. The practical consequences for an HEOR analyst:

- Quarto documents can mix R, Python and Julia code chunks in the same file -- useful if your health-economic model is in R but a colleague's survival-extrapolation code is in Python.
- Quarto's YAML front matter and chunk-option system is richer and more consistent across formats (HTML, PDF, Word, PowerPoint, websites, books -- this very book is built with Typst, a different tool, but the same literate-document idea).
- Quarto is installed as a separate command-line application (not an R package), and is driven from R via the `quarto` R package (a thin wrapper that calls the Quarto CLI) or directly from a terminal with `quarto render`.
- Existing `.Rmd` files generally render under Quarto with little or no change, so migration is usually incremental rather than a rewrite.

#difficult-terminology("YAML")[
  YAML ("YAML Ain't Markup Language") is a plain-text format for writing structured settings -- key-value pairs, lists, nested options -- in a way that is meant to be readable by humans, not just machines. In a Quarto or R Markdown document it appears as a block at the very top of the file, fenced by three dashes (`---`) above and below, called the _front matter_. Think of it as the document's "settings panel": it tells the renderer the title, author, output format(s), and any parameters, before a single line of the report's actual content is read. Indentation in YAML is meaningful (like in Python), and a stray extra space is a common source of cryptic rendering errors -- if a render fails immediately with no R error, check the YAML first.
]

A minimal Quarto YAML header for an HEOR report might look like:

```yaml
---
title: "Cost-Effectiveness of New-Regimen TB Treatment vs Standard of Care"
subtitle: "Base-case and scenario results, 4-state Markov cohort model"
author: "HEOR Modelling Team"
date: today
format:
  html:
    toc: true
    embed-resources: true
  docx: default
  pdf:
    documentclass: article
execute:
  echo: false
  warning: false
---
```

Note that `format` can list more than one output target in a single file -- Quarto will render the same source to HTML, Word and PDF in one `quarto render` call, each obeying its own sub-options (SS28.3 goes into this in detail).

#difficult-terminology("chunk")[
  A "chunk" (or "code cell") is a fenced block of executable code embedded inside the narrative document, marked off from the surrounding prose by triple backticks and a language tag, e.g. a line reading ```` ```{r} ````. When the document is rendered, every chunk is actually run by R (or Python, etc.), and its output -- a table, a plot, printed text -- is inserted into the final document at that exact point. This is the core idea of literate programming: the numbers in the report are not typed in by the analyst, they are _computed live_ each time the document is built, so the report can never drift out of sync with the model it describes.
]

Each chunk can carry its own options, written either in the classic `{r, option=value}` header or, in Quarto's preferred style, as special `#|` comment lines inside the chunk:

```r
#| label: fig-markov-trace
#| echo: false
#| warning: false
#| fig-cap: "State-occupancy trace, New-regimen vs SoC"

plot_markov_trace(model_results)
```

Commonly used chunk options for HEOR reporting:

- `echo` -- whether the R code itself is shown in the output (usually `false` for a report meant for clinicians or payers, `true` for an internal technical appendix).
- `eval` -- whether the chunk is executed at all (useful for temporarily disabling a slow bootstrap or PSA chunk during drafting).
- `warning` / `message` -- whether R warnings/messages leak into the rendered document (almost always suppressed in a final report).
- `fig-cap`, `fig-width`, `fig-height` -- captioning and sizing for figures.
- `tbl-cap` -- captioning for tables produced by chunk output.

#difficult-terminology("render")[
  "Rendering" is the act of running every code chunk in the document, capturing its output, and weaving the result together with the prose into a finished file (HTML page, Word document, PDF, etc.) via Pandoc. It's conceptually the same step as "compiling" a program, except the output is a formatted document rather than an executable. You trigger it by running `quarto render report.qmd` from a terminal, or by clicking "Render" in RStudio/Positron, or programmatically from R with `quarto::quarto_render()`.
]

=== A worked example: rendering an HEOR summary report

Suppose the base-case results from the TB 4-state Markov model (Chapters 25 and 27) are saved as a small data frame. A minimal but complete Quarto document to turn that into a shareable report looks like this.

```yaml
---
title: "TB Treatment Cost-Effectiveness Summary"
format:
  html:
    toc: true
  docx: default
execute:
  echo: false
---
```

A chunk later in the same document builds and formats the base-case table:

```r
#| label: tbl-base-case
#| tbl-cap: "Base-case incremental results, New-regimen vs SoC"

library(gt)

base_case <- data.frame(
  Arm = c("SoC", "New-regimen", "Incremental"),
  Cost = c(5000.00, 4155.86, -844.14),
  QALY = c(3.210, 3.354, 0.1440)
)

gt(base_case) |>
  fmt_currency(columns = Cost, currency = "USD") |>
  fmt_number(columns = QALY, decimals = 4)
```

The incremental net monetary benefit at a willingness-to-pay of \$50,000 per QALY is computed inline from the same two numbers (`` `r format(0.1440 * 50000 - (-844.14), big.mark = ",")` ``), confirming that the New-regimen strategy dominates standard of care -- it is both cheaper and more effective.

Running `quarto render tb_summary.qmd` from the project directory (with both `html` and `docx` listed in the YAML `format:` key) produces `tb_summary.html` and `tb_summary.docx` from this single source file -- one source of truth, two deliverables, no manual re-typing of numbers into a Word document.

#heor-practice[
  Keep one `.qmd` file per _deliverable_, not per analysis. A good pattern is to have your heavy modelling code (Markov model, PSA, DSA) live in plain `.R` scripts or functions that save tidy result objects (`.rds` files) to disk, and have the Quarto report do nothing but `readRDS()` those objects and format them. This keeps render times short -- nobody wants to re-run a 10,000-iteration PSA every time a typo in a sentence is fixed -- and keeps the report's git history focused on _presentation_ changes rather than being swamped by model-code diffs.
]

#pitfall[
  `echo: false` hides code from the _rendered_ document, but it does not stop the code from running, and it does not strip sensitive content (patient-level data previews, API keys pasted into a chunk for convenience, internal file paths) from error messages if a chunk fails during rendering. Before sending a report outside the team, render it once from a clean environment (`quarto render` in a fresh R session, not from your already-populated RStudio workspace) so you catch any hidden dependency on objects that happen to exist in your session but are not reproducibly created by the document itself.
]

== 28.2 Parameterised reports

A single base-case report is rarely the end of the story in HEOR work: a submission package might need the same analysis repeated for several subgroups (e.g. drug-sensitive vs drug-resistant TB), several price-sensitivity scenarios, or one report per implementing country or site in a multi-country costing study. Writing a separate `.qmd` file for each of these by hand is exactly the kind of copy-paste risk reproducible reporting is meant to eliminate. The fix is a _parameterised report_.

#difficult-terminology("parameterised report")[
  A parameterised report is a single report template written so that certain inputs -- a subgroup name, a willingness-to-pay threshold, a country's unit costs -- are left as _variables_ ("parameters") rather than hard-coded, in the same way a SQL query with a `WHERE region = :region` placeholder can be re-run for any region without rewriting the query. The report is rendered once per parameter set, and each render produces its own output file, all sharing identical structure and logic but populated with different numbers.
]

In Quarto (and R Markdown), parameters are declared under a `params:` key in the YAML front matter, and become available inside the document as elements of a list called `params`:

```yaml
---
title: "Cost-Effectiveness Results"
format: html
params:
  scenario_name: "Base case"
  wtp_threshold: 50000
  drug_price_multiplier: 1.0
---
```

Inside the document, those values are used directly in R code:

```r
#| label: calc-nmb

inc_cost <- -844.14 * params$drug_price_multiplier
inc_qaly <- 0.1440
nmb <- inc_qaly * params$wtp_threshold - inc_cost
```

For R Markdown documents the same `params:` mechanism works, and used to require RStudio's "Knit with Parameters" dialog or a call to `rmarkdown::render(..., params = list(...))`; Quarto keeps the YAML syntax but drives it from the command line.

=== Rendering a single parameterised report

From a terminal, overriding one or more parameters at render time:

```bash
quarto render tb_report.qmd \
  --execute-params params.yml \
  --output tb_report_resistant_subgroup.html
```

where `params.yml` is a small YAML file holding just the overrides for that run:

```yaml
scenario_name: "Drug-resistant TB subgroup"
wtp_threshold: 50000
drug_price_multiplier: 1.35
```

Quarto also accepts individual `-P key:value` overrides on the command line for quick one-off changes, e.g. `quarto render tb_report.qmd -P wtp_threshold:100000`, without needing a separate params file.

=== Looping render calls to generate one report per scenario

The real value of parameterisation shows up when a _driver script_ loops over a table of scenarios and calls the renderer once per row, generating a whole folder of reports unattended. This is most conveniently driven from R using the `quarto` package's `quarto_render()` function, which wraps the same CLI command used above:

```r
library(quarto)

scenarios <- data.frame(
  scenario_name = c("Base case", "Drug-resistant subgroup", "High drug price (+35%)"),
  wtp_threshold = c(50000, 50000, 50000),
  drug_price_multiplier = c(1.00, 1.00, 1.35)
)

for (i in seq_len(nrow(scenarios))) {
  scn <- scenarios[i, ]
  safe_name <- gsub("[^A-Za-z0-9]+", "_", scn$scenario_name)

  quarto_render(
    input = "tb_report.qmd",
    output_file = paste0("tb_report_", safe_name, ".html"),
    execute_params = list(
      scenario_name = scn$scenario_name,
      wtp_threshold = scn$wtp_threshold,
      drug_price_multiplier = scn$drug_price_multiplier
    )
  )
}
```

The equivalent for a classic R Markdown document uses `rmarkdown::render()` with its own `params =` argument in the same loop structure; the parameterisation idea is identical, only the rendering function and a couple of argument names differ.

#heor-practice[
  Always write the scenario identifiers _into the output filename_ (as the loop above does with `safe_name`) and, ideally, into a visible line in the rendered report itself (e.g. a line stating "Scenario: Drug-resistant subgroup, WTP = \$50,000/QALY, price multiplier = 1.35"). Reviewers routinely receive a folder of twelve near-identical reports; if the only way to tell them apart is the filename, a single rename or a copy into an email attachment can silently scramble which results belong to which scenario.
]

#pitfall[
  Parameters declared in the YAML `params:` block are given _default_ values that are used whenever you render interactively (e.g. clicking "Render" in an IDE) without supplying overrides. It is easy to forget this and ship a report that was actually rendered with the stale defaults rather than the intended scenario values. When looping programmatically, always pass every parameter explicitly in `execute_params`/`params =`, and consider adding a sanity-check chunk near the top of the report that prints the actual `params` list that was used, so it is visible in the rendered output rather than hidden in the render call.
]

== 28.3 Producing Word, PDF, HTML and PowerPoint outputs

HEOR deliverables rarely stay in one format. A health technology assessment (HTA) submission body may want an editable Word document for track-changes review, a PDF for the final locked submission, an HTML dashboard for internal exploration, and a PowerPoint deck of headline slides for a committee meeting -- often all from the same underlying analysis. Quarto's `format:` key in the YAML front matter is what controls this, and the same source document can target several formats at once.

```yaml
---
title: "TB Treatment Cost-Effectiveness: Committee Summary"
format:
  html:
    toc: true
    embed-resources: true
  docx:
    reference-doc: templates/heor_word_template.docx
  pdf:
    documentclass: article
    toc: false
  pptx:
    reference-doc: templates/heor_slide_template.pptx
---
```

Running `quarto render` with no arguments renders _all_ formats listed under `format:`; `quarto render report.qmd --to docx` renders just the Word version. The `reference-doc` option (for both `docx` and `pptx`) points Pandoc at an existing Word or PowerPoint template file whose styles (fonts, heading colours, table styles, logo placement) are copied into the new document -- this is the standard way to make a rendered report match an organisation's or journal's house style without writing any Word-specific code.

=== PDF output and the LaTeX requirement

#difficult-terminology("LaTeX")[
  LaTeX is a typesetting system -- a much older and more specialised cousin of Word -- that produces very precisely laid-out documents, and is the engine Pandoc uses under the hood whenever Quarto or R Markdown render to PDF. Unlike HTML or Word output, PDF rendering via Pandoc is not a pure-R, pure-Quarto process: it requires a working LaTeX installation on the machine doing the rendering, in the same way that compiling a C program requires a C compiler to be installed separately from the source code editor. A full LaTeX distribution (TeX Live, MiKTeX) is large (several gigabytes); R users almost always install a slimmed-down distribution instead.
]

The standard slimmed-down option for R users is `tinytex`, installed and then used to provision the actual LaTeX engine with:

```r
install.packages("tinytex")
tinytex::install_tinytex()
```

After this one-time setup, `quarto render report.qmd --to pdf` (or an R Markdown document with `output: pdf_document`) will work without further configuration. If a PDF render fails with an error about a missing LaTeX package (a `.sty` file), `tinytex::tlmgr_install("package-name")` installs just that missing piece rather than requiring a full distribution reinstall.

#pitfall[
  PDF rendering errors from LaTeX are notoriously unreadable to anyone without LaTeX experience -- a stray special character (`%`, `&`, `_`, `$`) inside R-generated text (a drug name, a file path, a footnote) can produce a wall of LaTeX log output with no obvious connection to the real cause. Favour generating tables and text through packages that properly escape such characters for the target format (`gt`, `gtsummary`, `kableExtra` with `escape = TRUE`, discussed in SS28.4) rather than hand-building LaTeX or Markdown table syntax, and test a PDF render early in a project rather than only at submission deadline.
]

=== Native editable Word and PowerPoint elements with officer/officedown

Pandoc's built-in Word/PowerPoint conversion handles headings, paragraphs and simple tables well, but HEOR reviewers often want to directly edit a _specific_ table cell, reflow a chart inside PowerPoint, or insert a native Word cross-reference or table of contents field -- things that round-trip conversion via Pandoc does not fully support. The `officedown` package (built on top of the lower-level `officer` package) extends R Markdown/Quarto's Word and PowerPoint rendering to insert genuinely native, editable Office XML elements rather than Pandoc's generic conversion.

A Word-targeted document using `officedown` declares it in the YAML:

```yaml
---
title: "TB Model Results -- Editable Word Report"
output:
  officedown::rdocx_document:
    reference_docx: templates/heor_word_template.docx
---
```

and can then embed an `officer`-built table or a native Word block directly in a chunk, e.g. using `officer::fp_text()`/`officer::fp_par()` to control run- and paragraph-level formatting. The general exact signature of `officedown`'s table-of-contents helper is not independently re-verified here and should be checked against the current package documentation before use.

```r
library(officer)
library(flextable)

ft <- flextable(base_case) |>
  flextable::autofit()

ft   # printed inside an officedown Word chunk renders as a fully
     # native, directly editable Word table, not an embedded image
```

#agency-note[
  CHEERS 2022 (Husereau et al., _Value in Health_, 2022), the consolidated health economic evaluation reporting standards checklist, does not mandate a specific file format -- but its items on study perspective through characterising uncertainty each require specific, clearly labelled numeric results and tables to be reported in the manuscript or its appendices in a form the reader (and, for a journal submission, often a copy-editor working in Word) can directly inspect and quote. In practice this means a submission-ready HEOR report needs at minimum an editable Word or a clean, correctly captioned PDF/HTML version carrying every CHEERS-required table, and reproducible-reporting tooling of the kind in this chapter is the most reliable way to guarantee all of those tables stay numerically consistent with the underlying model across every output format generated.
]

== 28.4 Publication-ready tables (gt, gtsummary, flextable, kableExtra)

A model can be perfectly validated and a report perfectly parameterised, and still land badly if its tables look unpolished or, worse, are hand-typed and silently diverge from the numbers the model actually produced. R has four widely used packages for publication-quality tables, and -- honestly -- they overlap rather than neatly dividing the territory, but each has a clear sweet spot.

- *gtsummary* -- the natural first choice for clinical/epidemiological _summary_ tables (baseline characteristics, regression model summaries, survival summaries) built directly from a data frame or model object via `gtsummary::tbl_summary()`, with sensible defaults for medical journals.
- *gt* -- a general-purpose "grammar of tables" package for building any publication table (not just automated summaries) from a data frame via `gt::gt()`, with solid output across HTML, PDF (via LaTeX) and Word.
- *flextable* -- the strongest choice when the _destination_ is Word or PowerPoint and the table must look and behave exactly right once there (merged cells, specific borders, native Office formatting), including via `officedown`'s `officer`/`flextable` integration from SS28.3.
- *kableExtra* -- a lightweight package for dressing up simple tables (built on `knitr::kable()`) for quick, clean LaTeX or HTML output via `kableExtra::kbl()`, well suited to appendix tables or fast internal reports where full `gt`/`flextable` styling is overkill.

#ref-table(
  [Four R table-formatting packages: honest comparison of use-cases],
  academic-table(
    columns: (auto, 1.6fr, 1.4fr, 1.6fr),
    align: (left, left, left, left),
    header: ([*Package*], [*Best for*], [*Output formats*], [*Notes*]),
    body: (
      [`gtsummary`], [Clinical/epi summary tables (baseline characteristics, regression tables)], [HTML, PDF, Word, RTF (via `gt`/`flextable` print engines)], [Opinionated defaults; less suited to fully custom, non-summary layouts],
      [`gt`], [General publication tables built from any data frame], [HTML, PDF (LaTeX), Word (via integration packages), RTF], [Most actively developed "grammar of tables"; PDF output needs a working LaTeX install],
      [`flextable`], [Word- and PowerPoint-native tables with precise formatting], [Word, PowerPoint, HTML, PDF], [Best fidelity when destination is Office documents; integrates with `officer`/`officedown`],
      [`kableExtra`], [Lightweight appendix/quick-report tables], [HTML, LaTeX/PDF], [No native Word output; simplest syntax for basic styling needs],
    ),
    footer: (table.cell(colspan: 4)[Boundaries overlap in practice; the comparison reflects each package's strongest, most idiomatic use rather than a hard restriction.],),
  ),
) <tab-ch28-pkg-compare>

=== Worked example: an ICER summary table

Using the TB 4-state Markov model's base-case results from Chapters 25 and 27 -- incremental cost −\$844.14, incremental QALY 0.1440 -- the incremental cost-effectiveness ratio and incremental net monetary benefit at a willingness-to-pay of \$50,000 per QALY gained are computed directly, showing the arithmetic rather than asserting a pre-formatted number:

```r
inc_cost <- -844.14
inc_qaly <- 0.1440
wtp      <- 50000

icer <- inc_cost / inc_qaly          # -844.14 / 0.1440
nmb  <- inc_qaly * wtp - inc_cost    # (0.1440 * 50000) - (-844.14)

icer   # -5862.083...
nmb    # 8044.14
```

$ "ICER" = (-844.14) / 0.1440 approx -5862.08 $ dollars per QALY gained -- a negative ICER here signals that New-regimen is _dominant_ (cheaper and more effective), so the conventional "cost per QALY gained" framing is reported alongside the dominance conclusion rather than in place of it. The incremental net monetary benefit, $ "NMB" = (0.1440 times 50000) - (-844.14) = 8044.14 $ dollars, matches the Chapter 25/27 figure of \$8,044 and confirms internal consistency.

```r
library(gt)

icer_table <- data.frame(
  Arm = c("SoC", "New-regimen", "Incremental"),
  Cost = c(5000.00, 4155.86, -844.14),
  QALY = c(3.2100, 3.3540, 0.1440),
  check.names = FALSE
)

gt(icer_table) |>
  fmt_currency(columns = Cost, currency = "USD") |>
  fmt_number(columns = QALY, decimals = 4) |>
  tab_header(title = "TB model: incremental cost-effectiveness results")
```

#report-table(
  [TB 4-state Markov model: base-case ICER and NMB summary (New-regimen vs SoC)],
  academic-table(
    columns: (auto, auto, auto),
    align: (left, right, right),
    header: ([*Arm*], [*Cost (USD)*], [*QALY*]),
    body: (
      [SoC], [\$5,000.00], [3.2100],
      [New-regimen], [\$4,155.86], [3.3540],
      [Incremental], [-\$844.14], [0.1440],
    ),
    footer: (table.cell(colspan: 3)[ICER = -844.14 / 0.1440 ≈ -\$5,862 per QALY gained (New-regimen dominant: cheaper and more effective). Incremental NMB at WTP = \$50,000/QALY = (0.1440 × 50,000) − (−844.14) = \$8,044.],),
  ),
) <tab-ch28-icer>

The same underlying data frame renders equally well through the other three packages, with a different emphasis each time. A `gtsummary` rendering of the same comparison would typically start from `gtsummary::tbl_summary()` applied to arm-level patient data rather than an already-aggregated data frame, since its design centre is summarising raw observations by group rather than formatting pre-computed scalars -- for a two-row aggregate table like this one, `gt` or `flextable` is the more natural tool. A Word-native version via `flextable` looks like:

```r
library(flextable)

flextable(icer_table) |>
  flextable::colformat_double(j = "Cost", digits = 2) |>
  flextable::colformat_double(j = "QALY", digits = 4) |>
  flextable::set_caption("TB model: incremental cost-effectiveness results") |>
  flextable::autofit()
```

and a quick LaTeX/HTML appendix version via `kableExtra`:

```r
library(knitr)
library(kableExtra)

kbl(icer_table, caption = "TB model: incremental cost-effectiveness results",
    digits = 4) |>
  kable_styling(full_width = FALSE, bootstrap_options = "striped")
```

#heor-practice[
  Decide the destination format _before_ choosing a table package, not after. A table built with `gtsummary`/`gt` for an HTML dashboard and later needed in a Word submission document may need re-rendering through a different code path (`gt`'s Word support is more limited than its HTML/PDF support); if Word is the known final destination, building the table in `flextable` from the start -- even for exploratory HTML drafts -- avoids a late rewrite.
]

#pitfall[
  None of these four packages validate the _numbers_ inside the table -- they only format whatever data frame they are given. A sign error upstream in the model code (e.g. accidentally reporting `cost_new - cost_soc` in one script and `cost_soc - cost_new` in another) will render through `gt` or `flextable` just as cleanly as a correct table, with no warning. Always compute the table's input data frame from the same saved model-result object used elsewhere in the report (as in the chunk above, which recomputes ICER and NMB from the same two numbers rather than retyping a previously reported value), so a single upstream fix propagates everywhere automatically.
]

#difficult-terminology("dominant / dominance (health economics)")[
  In cost-effectiveness analysis, a strategy is said to "dominate" its comparator when it is both less costly _and_ at least as effective -- there is no trade-off to weigh, so it is preferred regardless of the willingness-to-pay threshold. This is why the negative ICER in the worked example above is not reported as a literal "cost saving of \$5,862 per QALY" in the usual ICER sense; a negative ICER arising from dominance needs the dominance relationship stated explicitly, because the same negative number could instead (in a different scenario) signal the opposite situation -- a strategy that is more costly and less effective -- where the correct habit is to always check which quadrant of the cost-effectiveness plane the incremental results fall into before quoting an ICER at all.
]

== 28.5 Publication-ready graphics (ggplot2 themes, colour-blind-safe palettes)

A figure that looks fine on your laptop screen can fail completely once it is shrunk to fit a two-column journal page, printed in black-and-white, or viewed by a colleague with colour vision deficiency. This section covers three habits that turn an exploratory `ggplot2` plot into one you can submit to a journal, an HTA body, or a ministry report without last-minute panic: a reusable custom theme, colour palettes that remain distinguishable for colour-blind readers, and saving at the resolution the publisher actually asks for.

=== A consistent custom theme

Relying on the default `theme_gray()` for every figure in a dossier means every reviewer sees slightly different grid lines, fonts and label sizes depending on which script produced which plot. Building one theme object once and reusing it everywhere removes that inconsistency.

```r
library(ggplot2)

theme_heor <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "grey88", linewidth = 0.3),
      axis.title = element_text(face = "bold"),
      plot.title = element_text(face = "bold", size = rel(1.1)),
      plot.subtitle = element_text(colour = "grey40"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold"),
      strip.background = element_rect(fill = "grey92", colour = NA),
      strip.text = element_text(face = "bold")
    )
}

theme_set(theme_heor())
```

`theme_set()` makes `theme_heor()` the default for every subsequent plot in the session, so individual scripts producing the cost-effectiveness plane, the Markov trace, or the tornado diagram for the TB model all inherit the same typography without repeating the `theme()` block each time. You can still override specific elements per-plot with `+ theme(legend.position = "none")` where needed.

#heor-practice[
  Keep `theme_heor()` (or whatever you name it) in a small shared R file (e.g. `R/theme_heor.R`) that every report and figure script `source()`s, rather than pasting the theme definition into each Quarto document. When a journal's house style changes, you edit one file instead of hunting through a dozen report scripts.
]

=== Colour-blind-safe palettes

#difficult-terminology("colour-blind-safe palette")[
  A colour-blind-safe (or colour-blind-friendly) palette is a set of colours chosen so that the categories they represent remain distinguishable even for readers with the common forms of colour vision deficiency -- most often red-green confusion (deuteranopia/protanopia), affecting roughly 1 in 12 men and 1 in 200 women. The default `ggplot2` palette uses hues (red, green, blue) that can become hard to tell apart under exactly this kind of deficiency. A colour-blind-safe palette instead varies lightness and blue-yellow contrast as well as hue, so two lines that look "red vs green" to most viewers still look "dark vs light" to a red-green colour-blind viewer. Think of it like choosing traffic-light colours that differ in brightness and position, not just hue, so the signal survives even if the hue information is lost.
]

The `viridis` package provides perceptually uniform, colour-blind-safe palettes originally built for `matplotlib` and now widely used in R:

```r
library(viridis)

ggplot(markov_trace, aes(x = cycle, y = proportion, colour = state)) +
  geom_line(linewidth = 0.9) +
  scale_colour_viridis_d(option = "D") +   # discrete scale, "viridis" option
  labs(x = "Cycle (months)", y = "Proportion of cohort",
       colour = "Health state",
       title = "Markov cohort trace: New-regimen arm")
```

`scale_colour_viridis_d()` (discrete) and `scale_colour_viridis_c()` (continuous) are the two variants you will use most; the equivalent fill-scale functions are `scale_fill_viridis_d()` and `scale_fill_viridis_c()`.

To check whether an _existing_ plot or palette survives a colour-blind simulation rather than build a new palette from scratch, the `colorspace` package offers simulation functions such as `colorspace::simulate_cvd()`, and the `colorblindr` package (an add-on built on top of `colorspace` and `cowplot`, not independently re-verified here against its exact current function signatures) is commonly used for a side-by-side normal-vision-vs-simulated-deficiency comparison grid.

```r
library(colorspace)

p <- ggplot(ce_plane, aes(incr_cost, incr_qaly, colour = arm)) +
  geom_point(size = 2) +
  scale_colour_viridis_d()

# quick single-simulation preview of how the plot's colours look
# under a deuteranopia (red-green) colour-vision simulation
simulate_cvd(c("#440154", "#21918c", "#fde725"), deutan(1))
```

#pitfall[
  GitHub-only packages (not distributed via CRAN) can be finicky to install in a restricted or offline environment, since they typically require the `remotes` or `devtools` package plus a working internet connection to GitHub rather than a simple `install.packages()` call. If a GitHub-only colour-blind-simulation add-on fails to install, fall back to `colorspace::simulate_cvd()` for a quick simulated-vision preview, or simply default to a known colour-blind-safe palette family (viridis, or the `RColorBrewer` "Dark2"/"Set2" qualitative palettes, which were also designed with colour-vision deficiency in mind) and skip the simulation step rather than blocking your report on a brittle dependency.
]

#heor-practice[
  Never rely on colour alone to distinguish lines or bars in a figure that may be printed in greyscale or viewed by a colour-blind reviewer. Pair colour with a second visual channel -- line type (`linetype =`), point shape (`shape =`), or direct text labels on the lines -- so the figure survives both greyscale printing and colour vision deficiency simultaneously.
]

=== Saving at print resolution

A figure that looks sharp in the RStudio plot pane can look blurry once dropped into a Word or PDF submission document, because the viewer and the file are rendered at different resolutions. `ggplot2::ggsave()` takes explicit `width`, `height`, `units` and `dpi` arguments so you control the physical print size directly, rather than hoping the on-screen preview matches what a printer or PDF embed will produce.

```r
ggsave(
  filename = "figures/markov_trace_newregimen.png",
  plot     = last_plot(),
  width    = 16, height = 10, units = "cm",
  dpi      = 300
)

# vector output for a journal that accepts PDF or EPS figures
ggsave("figures/markov_trace_newregimen.pdf",
       width = 16, height = 10, units = "cm")
```

A `dpi` of 300 is a common minimum for raster (PNG/TIFF) figures in print journals; some journals request 600 dpi for line art. When a journal accepts vector formats (PDF, EPS, SVG) there is no resolution to set at all -- the figure is defined by mathematical paths rather than a pixel grid, so it scales cleanly to any size, which is generally the safer choice for simple line and bar charts.

#pitfall[
  Fonts and point sizes that look proportionate on a 13-inch laptop screen can look tiny or enormous once the same plot is saved at a fixed physical `width`/`height` in centimetres or inches. Always open the saved file (not the RStudio plot pane) at its intended final size before submission -- a 16 cm-wide figure with `base_size = 11` text in the theme can render axis labels that are barely legible once printed at that size. Adjust `base_size` in your theme function, not by resizing the canvas after the fact.
]

#agency-note[
  Most peer-reviewed health economics journals (e.g. _Value in Health_, _PharmacoEconomics_) and submission portals for HTA bodies such as NICE specify minimum figure resolution and accepted file formats in their author/submission guidelines -- check the specific target journal's or agency's current instructions before finalising `dpi` and file format, since requirements (300 dpi raster vs vector PDF/EPS, RGB vs CMYK colour space) vary by venue and are revised from time to time.
]

== 28.6 CHEERS 2022 reporting checklist implementation

#difficult-terminology("checklist-based reporting")[
  Checklist-based reporting means a journal, funder or agency publishes a fixed list of items that a report of a particular study type must address (not necessarily in that order), and authors are expected to state explicitly where in their manuscript each item is covered -- often in a companion table. It exists because health economic evaluations combine clinical, epidemiological, economic and modelling content from many sub-disciplines, and it is easy to omit something reviewers consider essential (e.g. the discount rate used, or how uncertainty was characterised) without anyone noticing until late in peer review. A checklist is like a pre-flight checklist for a pilot: not a guarantee the flight will go well, but a guarantee that the obviously necessary steps were not simply forgotten.
]

CHEERS 2022 (Consolidated Health Economic Evaluation Reporting Standards, Husereau, Drummond, Augustovski, et al., _Value in Health_ 2022;25(1):10-31) is the current consensus reporting checklist for health economic evaluations -- cost-effectiveness analyses, cost-utility analyses, cost-minimisation and cost-benefit analyses, whether trial-based or model-based (such as the TB Markov cohort model used throughout this book). It updates the original 2013 CHEERS statement and comprises 28 items organised under broad headings covering the title and abstract, introduction, methods, results, discussion, and other relevant information (including funding and conflicts of interest).

Rather than reproduce all 28 item texts here -- which risks mis-stating wording not independently re-verified against the published checklist -- this section focuses on the items most relevant to content already built earlier in this book, and shows a general pattern for tracking checklist compliance programmatically. For the authoritative item wording, authors should consult the published CHEERS 2022 statement directly before submission.

A few items this chapter is confident about by number and general content, because they map directly onto work done in earlier chapters:

- *Item 1* asks that the title identify the study as an economic evaluation and name the interventions compared -- directly satisfied by a title such as "Cost-effectiveness of a New TB Treatment Regimen versus Standard of Care: A Markov Cohort Model".
- *Item 15*, on synthesis methods (how estimates of effect, such as treatment efficacy or transition probabilities, were derived or pooled from the literature), is exactly the evidence-synthesis work covered in Chapter 11.
- *Items 20 and 26*, covering statistical/regression analysis methods and the corresponding results reporting, correspond to the regression modelling and reporting conventions covered in Chapter 16.

#agency-note[
  CHEERS 2022 (Husereau D, Drummond M, Augustovski F, et al. Consolidated Health Economic Evaluation Reporting Standards 2022 (CHEERS 2022) Statement. _Value in Health_ 2022;25(1):10-31) is the checklist most HTA bodies and health economics journals now expect authors to complete and submit alongside a cost-effectiveness manuscript, typically as a supplementary "CHEERS checklist" table stating the manuscript section/page where each item is addressed. Always check the submission target's current instructions for authors, since some journals mandate CHEERS compliance explicitly while others merely recommend it.
]

=== Building a checklist-tracking table in R

Rather than ticking items off by hand in a spreadsheet that drifts out of sync with the report as it evolves, build the checklist as a data frame alongside the rest of the analysis pipeline, with one row per item and a column recording which report section addresses it. This is a mapping/organising table of checklist references rather than a freshly computed analytic result, so it is presented as a `ref-table` rather than a `report-table`.

```r
library(tibble)
library(dplyr)

cheers_checklist <- tribble(
  ~item, ~topic,                                  ~report_section,
  1,     "Title identifies economic evaluation",   "Title page",
  2,     "Structured abstract",                     "Abstract",
  6,     "Study population",                        "Methods - Target population",
  9,     "Model-based economic evaluation details", "Methods - Markov model structure",
  13,    "Discount rate",                            "Methods - Discounting",
  15,    "Synthesis of effect estimates",           "Methods - Evidence synthesis (ch. 11)",
  18,    "Characterising heterogeneity",             "Methods - Subgroup analysis",
  20,    "Statistical analysis methods",             "Methods - Regression analysis (ch. 16)",
  23,    "Base-case results",                        "Results - Base-case ICER",
  24,    "Uncertainty characterisation",             "Results - PSA / sensitivity analysis",
  26,    "Statistical analysis results",             "Results - Regression output (ch. 16)",
  28,    "Funding source",                           "Declarations"
)

# flag items not yet mapped to any section -- a living to-do list
cheers_checklist %>%
  filter(report_section == "") %>%
  select(item, topic)
```

This `cheers_checklist` table is deliberately a small illustrative subset of the full 28 items (not a complete reproduction of the published checklist), intended to show the pattern: each row is one checklist item, and the `report_section` column is kept up to date as the Quarto report (built with the parameterised-rendering pattern from SS28.2) evolves, so the checklist never falls out of sync with the manuscript it describes.

#ref-table(
  [Illustrative subset of CHEERS 2022 items cross-referenced to report sections and earlier chapters],
  academic-table(
    columns: (auto, 1.8fr, 1.8fr),
    align: (left, left, left),
    header: ([*Item*], [*Topic*], [*Addressed in*]),
    body: (
      [1], [Title identifies economic evaluation], [Title page],
      [15], [Synthesis of effect estimates], [Methods -- Evidence synthesis, Chapter 11],
      [20], [Statistical analysis methods], [Methods -- Regression analysis, Chapter 16],
      [24], [Uncertainty characterisation], [Results -- PSA / sensitivity analysis],
      [26], [Statistical analysis results], [Results -- Regression output, Chapter 16],
      [28], [Funding source], [Declarations],
    ),
    footer: (table.cell(colspan: 3)[Illustrative subset only -- consult the published CHEERS 2022 statement (Husereau et al., 2022) for the complete 28-item list and exact wording.],),
  ),
) <tab-ch28-cheers>

#heor-practice[
  Render the checklist table itself from the `cheers_checklist` data frame inside the Quarto report (e.g. as a `gt` or `kableExtra` table, following the publication-table conventions from SS28.4), rather than maintaining it as a separate static document. A checklist that lives in the same `.qmd` source as the analysis gets regenerated -- and so re-verified -- every time the report is rendered.
]

#pitfall[
  A checklist item marked "addressed" in the `report_section` column is not the same as an item addressed _well_. Treat `cheers_checklist` as a coverage tracker that catches omissions, not a substitute for a careful read-through against the actual CHEERS 2022 item wording before submission -- reviewers will judge adequacy, not just presence.
]

== 28.7 Automating dossier and submission appendices

#difficult-terminology("dossier")[
  In HTA and regulatory contexts, a dossier is the full submission package an agency requires to evaluate a health technology -- typically far longer than a journal manuscript, comprising a main clinical and economic summary plus a series of technical appendices (model documentation, full search strategies, statistical analysis plans, sensitivity analysis results, and so on). Think of it as the difference between a short magazine article and the full case file behind it: the dossier is the case file, assembled from many separately authored sections.
]

#difficult-terminology("child document")[
  A child document is a smaller Quarto (`.qmd`) or R Markdown (`.Rmd`) file that is included inside a larger "parent" document at render time, rather than copy-pasted into it. The parent document stays short and acts as a table of contents that pulls each section in; each child document can still be edited, tested, and even rendered on its own. This mirrors how this very book's parent `book.typ` file `#include`s each chapter file in Typst -- the structure here is the same idea applied to Quarto reports.
]

A full HTA submission dossier for the TB New-regimen model might need a clinical-effectiveness summary, a model-structure appendix, a cost-inputs appendix, a sensitivity-analysis appendix and a budget-impact appendix -- five or more sections, each with its own tables and figures, that together could run to dozens of pages. Writing all of that as one monolithic `.qmd` file quickly becomes unmanageable: section authors step on each other's edits, and a typo in one appendix forces a re-render of the entire document just to check it. Quarto's child-document mechanism, combined with the parameterised-rendering pattern introduced in SS28.2, lets you assemble the dossier from independently maintained component files instead.

=== Structuring the dossier as child documents

Each appendix lives in its own `.qmd` file, and a parent document includes them with the `{{< include >}}` shortcode:

```markdown
---
title: "HTA Submission Dossier -- New TB Regimen vs Standard of Care"
format: pdf
params:
  country: "India"
  perspective: "payer"
---

# Executive summary

{{< include _executive_summary.qmd >}}

# Appendix A: Clinical effectiveness evidence

{{< include _appendix_clinical.qmd >}}

# Appendix B: Markov model structure and assumptions

{{< include _appendix_model_structure.qmd >}}

# Appendix C: Cost inputs

{{< include _appendix_costs.qmd >}}

# Appendix D: Sensitivity and scenario analyses

{{< include _appendix_sensitivity.qmd >}}
```

Each `_appendix_*.qmd` child file is a complete, independently renderable Quarto document in its own right (so a single analyst can preview just their section while drafting it), but when included via `{{< include >}}` it contributes its content into the parent's single combined render -- one shared bibliography, one shared set of cross-references, one final PDF or Word file.

Because the parent document carries the same `params:` block introduced for single reports in SS28.2, parameters set once at the top (country, payer perspective, willingness-to-pay threshold, etc.) are visible to every included child document that reads `params$...`, so the whole dossier -- appendices included -- regenerates consistently for a different country or perspective without editing each child file by hand.

```r
quarto::quarto_render(
  input = "dossier_parent.qmd",
  execute_params = list(country = "India", perspective = "societal"),
  output_file = "dossier_india_societal.pdf"
)
```

#heor-practice[
  Keep each appendix child document runnable and testable on its own (its own `params:` defaults, its own ability to render standalone) even though it is normally rendered as part of the parent. This lets whoever owns the cost-inputs appendix iterate quickly without re-rendering the entire multi-appendix dossier every time they tweak a unit cost.
]

#pitfall[
  Child documents included with `{{< include >}}` share the parent document's R session state, including figure/table numbering and any variables defined in earlier-included children. If two appendices happen to define a variable or object with the same name (e.g. both calling their main data frame `df`), the second include can silently overwrite the first. Namespacing objects per appendix (`clinical_df`, `cost_df`, `sens_df`, ...) avoids this class of bug.
]

#agency-note[
  NICE's Technology Appraisal process requires a company submission comprising a main document plus a detailed economic model and supporting appendices (see NICE's "Guide to the processes of technology appraisal" and the associated submission templates); PBAC in Australia and similarly structured HTA bodies elsewhere have comparable multi-section dossier requirements. Checking the specific agency's current submission template structure before deciding how many appendix child documents to create -- and in what order -- saves rework later, since agencies often mandate a fixed section ordering.
]

== 28.8 Automating routine reports across programmes or districts

The parameterised single-report pattern from SS28.2 renders one report for one set of parameter values on request. Many real reporting workloads are not "render one report" but "render the same report design once per unit" -- once per TB programme district, once per quarter, once per facility. This section covers looping that rendering step across many parameter sets, and briefly touches on scheduling the whole pipeline to run unattended.

#agency-note[
  The district-level looping scenario below is a fictional illustrative example for this book, not a description of an actual published NTEP (National TB Elimination Programme) reporting workflow; it is included because looping a parameterised Markov-model report across administrative units is a realistic shape for routine TB programme reporting in practice.
]

=== Looping parameterised rendering across districts

Suppose the same New-regimen-vs-SoC Markov cohort report from earlier chapters needs to be produced once for each of several illustrative Indian TB programme districts, each with its own local case counts and perhaps slightly different baseline transition probabilities estimated from local notification data. Build a small data frame of per-district parameters, one row per report to generate, and loop `quarto::quarto_render()` over it.

```r
library(purrr)
library(quarto)

district_params <- tibble::tribble(
  ~district,    ~baseline_notifications, ~output_file,
  "Nashik",      2400,                    "report_nashik.pdf",
  "Nagpur",      3100,                    "report_nagpur.pdf",
  "Thane",       4800,                    "report_thane.pdf",
  "Pune Rural",  2950,                    "report_pune_rural.pdf"
)

# purrr::pwalk() calls a function once per row, passing each column as a
# named argument -- here, into quarto_render()'s params and output_file
pwalk(district_params, function(district, baseline_notifications, output_file) {
  quarto::quarto_render(
    input = "district_tb_report.qmd",
    execute_params = list(
      district = district,
      baseline_notifications = baseline_notifications
    ),
    output_file = output_file
  )
})
```

`purrr::pwalk()` is the multi-argument sibling of `purrr::walk()`: `walk()` calls a function once per element of a single vector/list purely for its side effect (here, writing a rendered report file to disk) and returns its input invisibly; `pwalk()` does the same but draws each call's arguments from the corresponding row of a data frame, matching columns to the function's argument names. Both are used here instead of `map()`/`pmap()` because the point of the loop is the side effect of writing files, not collecting a return value -- using `walk`/`pwalk` rather than `map`/`pmap` signals that intent to anyone reading the code later. A plain `for` loop over `seq_len(nrow(district_params))` with the equivalent `quarto_render()` call inside it works identically and is a perfectly reasonable alternative if `purrr`-style functional loops feel unfamiliar.

```r
# equivalent for-loop version
for (i in seq_len(nrow(district_params))) {
  row <- district_params[i, ]
  quarto::quarto_render(
    input = "district_tb_report.qmd",
    execute_params = list(
      district = row$district,
      baseline_notifications = row$baseline_notifications
    ),
    output_file = row$output_file
  )
}
```

#pitfall[
  Rendering many reports in a tight loop means a single malformed parameter value (a missing district name, a notification count accidentally read in as text) can abort the whole batch partway through, leaving you unsure which reports actually completed. Wrapping each render call in `tryCatch()` and logging successes/failures to a small results data frame lets the batch continue past one bad row and gives you a clear list of which districts need re-running, rather than guessing from a half-finished output folder.
]

=== Scheduling the pipeline for recurring reporting

A one-off script that loops over districts is useful on demand, but routine reporting (monthly district TB reports, say) usually needs to run unattended on a schedule. Two common approaches, at different levels of sophistication:

- *A scheduled job* (a `cron` job on Linux/macOS, or Windows Task Scheduler) simply runs an R or shell script -- containing the `pwalk()`/for-loop rendering code above -- at fixed times, e.g. the first day of every month. This is the simplest option and is adequate when the pipeline is small and failures can be caught by checking output files or an emailed log afterwards.

#difficult-terminology("targets pipeline")[
  The `targets` R package is a pipeline tool that tracks the dependencies between steps of an analysis (load data -> clean data -> fit model -> render report) and only re-runs the steps whose inputs have actually changed since the last run, skipping the rest. A "targets pipeline" means the whole workflow -- data loading, model fitting, report rendering -- is declared as a sequence of named, interdependent steps in a `_targets.R` file, run via `targets::tar_make()`. The analogy is a smart build system (like `make` for software): if only this month's notification data changed, it re-renders only the reports that actually depend on that data, rather than redoing every step for every district from scratch.
]

- *A `targets` pipeline* is worth the extra setup once the reporting workflow has enough interdependent steps that you want to avoid redundant recomputation -- for instance, if fitting the underlying Markov model parameters is itself slow, and only the final report-rendering step needs to re-run when a single district's raw notification file is updated. A `_targets.R` file would declare one target for the raw data, one for the fitted model, and (using the `tarchetypes` package's rendering/branching helpers) one target per rendered report, and `targets::tar_make()` would then only re-render the reports whose upstream data actually changed.

```r
# sketch of a _targets.R structure -- illustrative, not a tested pipeline
library(targets)
library(tarchetypes)

list(
  tar_target(district_data, load_district_notifications()),
  tar_target(fitted_model, fit_markov_model(district_data)),
  tar_render(district_report, "district_tb_report.qmd")
)
```

#pitfall[
  The `_targets.R` sketch above illustrates the general shape of a targets pipeline rather than a tested, complete pipeline definition -- `tarchetypes`'s rendering and dynamic-branching helpers have specific argument requirements that are easy to get wrong on a first attempt. Treat this as a starting point to adapt and test against the `targets`/`tarchetypes` package documentation, not code to copy verbatim into production.
]

#heor-practice[
  Start with the simplest scheduling mechanism that meets the actual recurrence requirement -- a monthly `cron` job calling a plain R script is often entirely sufficient for routine district reporting. Reach for `targets` only once you notice real pain from redundant recomputation (e.g. refitting a slow model every month even when only one district's input data changed), rather than adopting it pre-emptively for a workflow that does not yet need it.
]
