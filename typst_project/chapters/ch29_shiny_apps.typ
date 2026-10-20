#import "../common.typ": *

= Chapter 29. Interactive Models and Web Applications with Shiny

#learning-objectives((
  [Explain Shiny's `ui`/`server` architecture and reactive programming model, and build a minimal reactive cost-effectiveness calculator.],
  [Design a Shiny interface for non-programmer reviewers: layout choice, widget choice, plain-language labelling, tooltips and progressive disclosure.],
  [Compare plain Shiny modules, `golem` and `rhino` as ways of structuring a growing app, and choose the right level of investment for a given app's lifespan.],
  [Connect a Shiny front end to an underlying cost-effectiveness model, separating cheap continuously-updating reactives from expensive user-triggered PSA runs.],
  [Build a `downloadHandler()` that drives the same parameterised Quarto report pipeline from Chapter 28, and implement a basic audit trail of user interactions.],
  [Compare shinyapps.io, Posit Connect and Docker/self-hosted deployment routes, and choose among them based on an organisation's IT and data-governance constraints.],
  [Apply input validation (`req()`/`validate()`/`need()`) and authentication appropriately, and explain what NICE's Technology Appraisal process expects of a transparent, reviewable model.],
  [Assemble the chapter's techniques into a sketch of a transparent, reviewable, submission-ready Shiny app for an ERG-style review.],
))

Chapter 28 closed with reports that regenerate themselves from source — reproducible, but still fundamentally static documents, produced once and handed over. This chapter adds a second channel: a live, interactive front end that lets a reviewer change a parameter and watch the model respond immediately, without filing a request and waiting for a re-run. The two are not competitors. As this chapter will show repeatedly, the right design keeps them connected — a Shiny app's "download the full report" button should trigger the exact same Quarto pipeline built in Chapter 28, so that what a reviewer sees on screen and what they take away as a citable document are guaranteed to match.

== 29.1 Shiny fundamentals for model front-ends

Every health-economic model eventually needs a front door — a way for someone who is not going to open RStudio to turn your dials and see what happens to the ICER. In this book's running TB Markov example (Chapters 17-27) that "someone" is usually a clinical lead, a payer reviewer, or an HTA evaluator checking your sensitivity analysis live during technical engagement. Shiny is R's framework for building that front door: a web application whose logic is still ordinary R code.

A Shiny app has exactly two conceptual halves, conventionally split into two objects:

- `ui` — describes what the page _looks like_: panels, sliders, buttons, plot placeholders.
- `server` — describes what happens _when inputs change_: a function with arguments `input`, `output`, and (optionally) `session`.

What makes Shiny distinctive is not these two halves but the glue between them, called reactive programming.

#difficult-terminology("reactive programming")[
  A programming style in which you declare _relationships_ between values rather than a sequence of steps. In ordinary R you write `icer <- cost / qaly` once, and if `cost` later changes, `icer` is stale until you re-run the line. In Shiny, if you declare that same relationship as a reactive expression, Shiny automatically re-runs it whenever `cost` changes — rather like a spreadsheet cell with a formula in it that recalculates when you edit an input cell.
]

Every Shiny input widget (a slider, a numeric box, a dropdown) creates a reactive value, accessible in the server function as `input$treatment_cost`, `input$qaly_gain`, and so on. You never reassign these directly; they update automatically whenever the user moves the control.

#difficult-terminology("reactive expression")[
  Code wrapped in `reactive({...})` that Shiny treats like a cached, auto-updating calculation — similar to a view in SQL that recomputes only when the underlying tables it depends on actually change. You call it like a function, e.g. `icer()`, and Shiny only re-executes the body when one of the reactive values it reads (e.g. `input$treatment_cost`) has changed since the last call.
]

#difficult-terminology("observer")[
  Code wrapped in `observeEvent({...})` or `observe({...})` that _runs for its side effects_ — writing a log message, saving a file, popping up a warning — rather than returning a value for display. Where a reactive expression is "a formula that produces a number," an observer is "an action that happens when something changes."
]

Here is a minimal, complete toy app wrapping a two-input, one-output ICER calculator. It compares a new treatment against a fixed comparator (cost \$2,000, already on formulary) and lets the reviewer vary the new treatment's cost and incremental QALY gain.

```r
library(shiny)

comparator_cost <- 2000  # fixed cost of standard of care

ui <- fluidPage(
  titlePanel("Toy ICER calculator"),
  sidebarLayout(
    sidebarPanel(
      numericInput("treatment_cost", "New treatment cost ($)",
                   value = 5000, min = 0, step = 100),
      numericInput("qaly_gain", "Incremental QALYs gained",
                   value = 0.15, min = 0, step = 0.01)
    ),
    mainPanel(
      h4("Incremental cost-effectiveness ratio"),
      textOutput("icer_text")
    )
  )
)

server <- function(input, output, session) {

  # Reactive expression: recomputes only when its inputs change
  incremental <- reactive({
    list(
      d_cost = input$treatment_cost - comparator_cost,
      d_qaly = input$qaly_gain
    )
  })

  icer <- reactive({
    inc <- incremental()
    inc$d_cost / inc$d_qaly
  })

  output$icer_text <- renderText({
    paste0("$", format(round(icer(), 0), big.mark = ","), " per QALY gained")
  })
}

shinyApp(ui, server)
```

With the defaults shown (treatment cost \$5,000, comparator \$2,000, QALY gain 0.15), the incremental cost is \$3,000 and the ICER is \$3,000 / 0.15 = \$20,000 per QALY — move either slider and the displayed figure updates immediately, with no explicit "refresh" step anywhere in the code.

#heor-practice[
  Keep the server function's reactive graph shallow for a first app: one reactive expression per intermediate quantity (`incremental()`, then `icer()`) is easier for a future you — or a collaborator — to debug than one giant reactive block computing everything at once. Reactive expressions are also the natural unit to print with `print(icer())` inside `observe()` while developing, since you can inspect intermediate values without touching the UI.
]

#pitfall[
  Do not call `input$treatment_cost` or any reactive expression _outside_ a reactive context (i.e. outside `reactive({})`, `render*({})`, or `observe({})`). Shiny will throw `Error: Operation not allowed without an active reactive context` — a common early stumbling block that simply means "you tried to read a live value from plain, non-reactive R code."
]

== 29.2 Designing a user interface for non-programmers

A Shiny app built for yourself and one built for a non-technical HTA reviewer are different products even if the underlying model is identical. The reviewer is not trying to learn R; they are trying to answer "does this result hold up if I change this one assumption?" as quickly as possible, usually live on a call during technical engagement. Every design choice in this section is in service of that single goal.

*Layout: start simple, escalate only if needed.* `sidebarLayout()` (inputs on the left, results on the right) is the right default for a single-screen tool with a handful of parameters — it is what reviewers expect from a "calculator." Once you have more than one result view (say, a base-case summary, a CE plane, and a CEAC), move to a multi-page layout with `navbarPage()` or `tabsetPanel()`, so each result lives on its own tab rather than competing for space:

```r
library(shiny)
library(bslib)

ui <- page_navbar(
  title = "TB treatment cost-effectiveness explorer",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  nav_panel("Inputs & summary", icon = icon("sliders"),
    sidebarLayout(
      sidebarPanel(
        sliderInput("tx_cost", "Annual treatment cost ($)",
                    min = 500, max = 3000, value = 1200, step = 50),
        selectInput("regimen", "Treatment regimen",
                    choices = c("Standard 6-month" = "std",
                                "Shortened 4-month" = "short"))
      ),
      mainPanel(textOutput("icer_summary"))
    )
  ),
  nav_panel("Cost-effectiveness plane", icon = icon("chart-scatter"),
            plotOutput("ce_plane")),
  nav_panel("CEAC", icon = icon("chart-line"),
            plotOutput("ceac_plot"))
)
```

`bslib::page_navbar()` builds on the same Bootstrap theming system used throughout the tidyverse's web tooling and renders a noticeably more polished, modern interface than classic `fluidPage()` with almost no extra code — worth the small dependency for anything a reviewer outside your team will see.

*Widgets: match the control to the mental model.* `sliderInput()` communicates a bounded, continuous range intuitively (e.g. discount rate, WTP threshold); `numericInput()` is better when precision matters more than exploration (e.g. an exact unit cost from a costing study); `selectInput()` is right for a small set of named, mutually-exclusive options (e.g. choice of regimen) — never make a reviewer type a code like `"std"` when a label like "Standard 6-month" will do.

*Labels: write for a clinician, not a modeller.* "Discount rate" beats "r_d"; "Willingness-to-pay threshold (\$ per QALY)" beats "lambda." If a parameter cannot be labelled clearly in under eight words, it probably needs a tooltip rather than a longer label:

```r
tooltip(
  sliderInput("wtp", "Willingness-to-pay threshold", 20000, 100000, 50000),
  "The maximum amount a payer is willing to spend to gain one additional
   quality-adjusted life year (QALY). NICE typically references
   £20,000-£30,000 per QALY; other agencies use different thresholds."
)
```

`bslib::tooltip()` (or the older `shinyBS::bsTooltip()`) attaches a small hover-triggered explanation to any UI element without cluttering the visible layout — the Shiny equivalent of a cell comment in a spreadsheet.

*Progressive disclosure.* Not every parameter belongs on the main screen. Structural assumptions, PSA distribution choices, and rarely-touched calibration constants belong behind a collapsible "Advanced settings" panel (`bslib::accordion()` or `shiny::conditionalPanel()`), opened only on request:

```r
accordion(
  accordion_panel(
    "Advanced model settings",
    numericInput("psa_draws", "Number of PSA iterations", 1000),
    numericInput("half_cycle_corr", "Half-cycle correction", 0.5)
  )
)
```

#pitfall[
  The single most common mistake in reviewer-facing Shiny apps is exposing _every_ model parameter on one screen because it was easy to add another `sliderInput()`. A non-technical reviewer faced with twenty simultaneous sliders cannot tell which ones matter, and the app stops looking like a trustworthy decision tool and starts looking like the guts of a spreadsheet. Default to showing the handful of parameters that drive the policy question (price, regimen, WTP threshold) and move everything else behind progressive disclosure — you can always add a link-out to the full parameter table for technical appendices.
]

#agency-note[
  Several HTA bodies now expect submitted models to be usable, not merely inspectable. Australia's PBAC Guidelines (Version 5.0, 2016), in the section on economic evaluation, require sponsors to submit "a fully executable electronic model" that evaluators can run and interrogate themselves rather than a static report of results — a requirement a well-designed Shiny front-end satisfies directly, since an ERG or PBAC evaluator can change the WTP threshold or regimen live and see the ICER update, instead of requesting a re-run from the sponsor during technical engagement.
]

== 29.3 Modular Shiny with `golem` and `rhino`

A single-file `app.R` is fine for the toy calculator in Section 29.1, but the TB model app in this book has multiple tabs, several render functions, and inputs that interact across tabs (regimen choice affects both the cost-effectiveness plane and the CEAC). At that scale, copy-pasting `sliderInput("tx_cost", ...)` and its matching server logic across tabs becomes unmanageable, and the natural fix is the same one you already use for R functions: break the app into reusable, independently testable pieces, called Shiny modules.

#difficult-terminology("Shiny module")[
  A self-contained pair of functions — one for UI, one for server logic — that bundles a piece of an app (say, "the PSA results panel") so it can be reused and tested like any other R function, instead of being tangled into one giant `ui`/`server` pair. Modules are created with `moduleServer()` for the server half and a plain function returning UI elements for the UI half.
]

```r
# A module for a single cost-effectiveness summary box
ceSummaryUI <- function(id) {
  ns <- NS(id)
  tagList(
    h4("Incremental results"),
    textOutput(ns("icer_text"))
  )
}

ceSummaryServer <- function(id, incremental_results) {
  moduleServer(id, function(input, output, session) {
    output$icer_text <- renderText({
      res <- incremental_results()
      paste0("ICER: $", format(round(res$icer, 0), big.mark = ","))
    })
  })
}
```

#difficult-terminology("namespacing")[
  The mechanism (`NS(id)` above) that prefixes every input/output ID inside a module with a unique identifier, so that two copies of the same module on one page — e.g. a CE-summary box for the "standard regimen" scenario and another for the "shortened regimen" scenario — don't collide by both trying to use an ID like `icer_text`. It is conceptually the same problem a SQL table alias solves when joining a table to itself.
]

Once an app grows past a handful of modules, two competing packaged conventions for organizing the whole project are widely used in the R community: `golem` and `rhino`. Treat the specifics below as illustrative of each package's philosophy rather than exact, version-pinned syntax — check the current documentation for the precise function signatures before relying on them in production, since both packages have evolved their APIs across versions.

#difficult-terminology("golem")[
  An R package (from ThinkR) for structuring a Shiny app as if it were an R _package_: your app's functions live in `R/`, are documented with roxygen comments, and are tested with `testthat`, exactly like the modelling functions from Chapter 27. `golem::create_golem()` scaffolds the package skeleton, and helpers such as `golem::add_module()` generate the boilerplate UI/server pair for a new module.
]

#difficult-terminology("rhino")[
  A newer, more opinionated framework from Posit/Appsilon for production Shiny apps, which enforces a stricter folder structure, bundles its own linting and automated testing conventions, and — distinctively — integrates a JavaScript/Sass build pipeline so custom front-end styling and behaviour are first-class, version-controlled parts of the app rather than inline `tags$script()` calls scattered through UI code.
]

#difficult-terminology("hot-reloading")[
  A development convenience, present to varying degrees in `golem` and `rhino` tooling, where saving a changed source file automatically refreshes the running app in your browser without you manually re-launching it — similar to how editing a Shiny `app.R` under `shiny::runApp()` with auto-reload enabled saves you from repeatedly clicking "Run App."
]

For the TB model app specifically, the right level of investment depends on audience and lifespan. An app built for one HTA submission, shown to an ERG on a handful of calls, rarely justifies `golem`'s or `rhino`'s full package scaffolding — plain Shiny modules (`moduleServer()` + `NS()`) usually suffice, and keep the barrier to entry low for collaborators who know R but not package development. An app intended to be maintained across multiple submissions, countries, or technology appraisals over several years is a better candidate for the discipline both frameworks impose.

#ref-table(
  [Comparing plain Shiny modules, `golem`, and `rhino`],
  academic-table(
    columns: (1.3fr, 1.4fr, 1.4fr, 1.4fr),
    align: (left, left, left, left),
    header: ([*Dimension*], [*Plain Shiny modules*], [*`golem`*], [*`rhino`*]),
    body: (
      [Setup overhead], [Minimal], [Moderate (package scaffold)], [Higher (build tooling)],
      [Best for], [Single-submission apps, small teams], [Apps reused across years / submissions], [Apps needing custom JS/CSS, larger dev teams],
      [Testing convention], [Ad hoc `testthat` if added], [`testthat` built into package structure], [Enforced test + lint conventions],
      [Front-end styling], [Inline CSS / `tags$script()`], [Standard R package assets], [First-class Sass/JS build pipeline],
      [Learning curve for a non-SE R user], [Low], [Moderate (package dev concepts)], [Higher (JS build chain)],
    ),
    footer: none,
  ),
) <tab-ch29-golem-rhino>

#heor-practice[
  Whichever structure you choose, keep the model engine itself (the Markov transition functions and PSA draws from Chapters 17-26) as ordinary, package-independent R functions with no Shiny dependency at all. Modules, `golem`, and `rhino` are all about organizing the _app layer_; none of them should dictate how the cost-effectiveness model is written. This separation is what makes Section 29.4's testing story possible.
]

== 29.4 Linking Shiny to the model engine and PSA outputs

Everything in Sections 29.1-29.3 has been about the app's surface. This section connects that surface to the actual TB Markov model and its PSA output — the same base-case results carried through Chapters 17-27: an incremental cost of approximately -\$844.14 (the new regimen is cost-saving), an incremental QALY gain of approximately 0.1440, and, at a willingness-to-pay threshold of \$50,000 per QALY, an incremental net monetary benefit of approximately \$8,044 (NMB = \$50,000 x 0.1440 - (-\$844.14) = \$7,200 + \$844.14 = \$8,044.14).

The guiding principle is the one flagged at the end of Section 29.3: the model engine is a set of plain R functions, independently unit-tested with `testthat` as in Chapter 27, and Shiny's job is only to call those functions in response to user input and display what comes back. Two reactive patterns handle the "when does it recompute" question differently depending on cost.

*Cheap, continuously-updating reactives.* If a quantity is cheap to compute — say, recalculating the deterministic ICER from the base-case transition probabilities whenever the discount rate changes — a plain `reactive({})` is appropriate, because it is fine for it to re-run on every slider tweak:

```r
# run_markov_model() and compute_icer() are the pure functions from Ch. 17-20
deterministic_results <- reactive({
  run_markov_model(
    discount_rate = input$discount_rate,
    regimen       = input$regimen
  )
})
```

*Expensive, user-triggered reactives.* Running a full PSA — say 1,000 or 10,000 Monte Carlo draws through the Markov model, as built up across Chapters 23-26 — is not something you want firing every time a reviewer nudges a slider. Instead, tie it to an explicit `actionButton()` using `eventReactive()`, which only recomputes when its named event (the button) fires, regardless of how many other reactive values have changed in the meantime:

```r
ui <- page_navbar(
  title = "TB model PSA explorer",
  nav_panel("PSA results",
    sidebarLayout(
      sidebarPanel(
        numericInput("n_psa", "Number of PSA iterations", 1000),
        numericInput("wtp", "WTP threshold ($/QALY)", 50000),
        actionButton("run_psa", "Run model", class = "btn-primary")
      ),
      mainPanel(
        plotOutput("ce_plane"),
        plotOutput("ceac_plot")
      )
    )
  )
)

server <- function(input, output, session) {

  psa_results <- eventReactive(input$run_psa, {
    # run_psa() is the pure PSA engine built in Ch. 23-26;
    # it returns a data frame with one row per Monte Carlo draw
    run_psa(n_draws = input$n_psa, wtp = input$wtp)
  })

  output$ce_plane <- renderPlot({
    req(psa_results())
    draws <- psa_results()
    ggplot(draws, aes(x = d_qaly, y = d_cost)) +
      geom_point(alpha = 0.3) +
      geom_hline(yintercept = 0, linetype = "dashed") +
      geom_vline(xintercept = 0, linetype = "dashed") +
      labs(x = "Incremental QALYs", y = "Incremental cost ($)",
           title = "Cost-effectiveness plane")
  })

  output$ceac_plot <- renderPlot({
    req(psa_results())
    ceac_data <- build_ceac(psa_results(), wtp_range = seq(0, 100000, 1000))
    ggplot(ceac_data, aes(x = wtp, y = prob_cost_effective)) +
      geom_line() +
      labs(x = "Willingness-to-pay threshold ($/QALY)",
           y = "Probability cost-effective",
           title = "Cost-effectiveness acceptability curve")
  })
}
```

Until the reviewer clicks "Run model," `psa_results()` has not been evaluated, so `req(psa_results())` inside each `renderPlot()` simply holds the plots blank rather than erroring — a standard Shiny idiom for "wait until this upstream reactive has a value." Once the button is clicked, both plots redraw from the same single `eventReactive()` call, so the CE plane and the CEAC are always showing draws from the same PSA run rather than two independently-triggered, potentially mismatched runs.

#heor-practice[
  Resist the temptation to write model logic directly inside `reactive({})` or `eventReactive({})` blocks. Keep `run_markov_model()`, `run_psa()`, and `build_ceac()` as ordinary functions defined and unit-tested outside the Shiny app (per Chapter 27's `testthat` suite), and let the reactive blocks do nothing but call them with the current inputs. This keeps the Shiny layer thin enough that a bug report ("the CEAC looks wrong") can be reproduced and fixed by calling `run_psa()` directly at the console, with no need to launch the app, click through the UI, or reason about reactivity at all.
]

#agency-note[
  NICE's Decision Support Unit Technical Support Document 12 (_The Use of Probabilistic Sensitivity Analysis in Decision-Analytic Modelling_) specifically expects a cost-effectiveness plane and a CEAC as standard PSA outputs. A Shiny front-end that reruns `run_psa()` on demand and regenerates both plots from the same draws gives an ERG or NICE committee the ability to re-examine PSA results interactively during technical engagement — e.g. rerunning at an increased iteration count if asked — rather than depending on a fixed set of static figures in the submitted report.
]

== 29.5 Downloadable reports and audit trails

An interactive Shiny app is excellent for exploration, but an HTA submission is ultimately judged on fixed, citable documents: a PDF or Word report that an Evidence Review Group (ERG) can print, annotate, and quote by page number. The app should therefore not replace the parameterised Quarto reporting pipeline built in Chapter 28 — it should _drive_ it. A button inside the app re-renders the same report template, with the current widget values passed through as Quarto parameters, so that the downloadable document is guaranteed to match what the reviewer saw on screen.

Shiny's mechanism for this is `downloadHandler()`, paired with a `downloadButton()` or `downloadLink()` in the UI. The handler is a reactive-aware function that writes a file to the path Shiny gives it; critically, its body can call `quarto::quarto_render()` on the exact `.qmd` file and parameter list from Chapter 28, rather than reimplementing export logic from scratch.

#difficult-terminology("downloadHandler()")[
  A Shiny server-side function that tells the browser "when the user clicks this button, generate a file and offer it as a download." You supply two pieces: a `filename` (what the browser should call the saved file) and a `content` function (the code that actually writes the file to a temporary path Shiny manages). It is the standard Shiny mechanism for exporting any file — CSV, PNG, PDF, Word — from a running app.
]

```r
output$download_report <- downloadHandler(
  filename = function() {
    paste0("tb_model_report_", Sys.Date(), ".docx")
  },
  content = function(file) {
    quarto::quarto_render(
      input = "report.qmd",
      output_file = basename(file),
      execute_params = list(
        wtp_threshold  = input$wtp,
        discount_rate  = input$discount_rate,
        n_psa          = input$n_psa,
        scenario_label = input$scenario_name
      )
    )
    file.copy(file.path(dirname("report.qmd"), basename(file)), file,
              overwrite = TRUE)
  }
)
```

The same pattern works for narrower exports — a CE-plane `ggplot2` object saved as PNG via `ggsave()`, or the raw PSA draws saved as CSV via `write.csv()` — each wired to its own `downloadButton()`. The principle is consistent: whatever the reviewer downloads must be traceable to a reproducible rendering step, not a screenshot or a manually copied table.

#heor-practice[
  Give every downloadable artefact a filename that encodes the key parameters and a timestamp, e.g. `tb_psa_wtp20000_2024-03-11.csv`. Reviewers routinely compare several downloaded files across review cycles, and an uninformative name like `export.csv` forces them to reopen each one to find out what it is.
]

Equally important for submission transparency is the audit trail: a running record of who did what, when, inside the app. For a model under ERG scrutiny, the question "what inputs produced this ICER?" must have a verifiable answer, not a recollection. The simplest implementation logs every parameter change and every model run to an append-only file.

#difficult-terminology("audit trail")[
  A chronological log of actions taken in a system, kept so that any past event can be reconstructed later. In clinical and regulatory contexts the term comes from electronic data capture systems, where every edit to a case report form is time-stamped and attributed. For a Shiny model app, the audit trail is simply a growing table of "who/when/what-changed/what-result" rows, usually written to a CSV or a lightweight SQLite database.
]

```r
log_event <- function(session_id, event, detail) {
  entry <- data.frame(
    timestamp  = Sys.time(),
    session_id = session_id,
    event      = event,
    detail     = detail
  )
  write.table(entry, "audit_log.csv", sep = ",", append = TRUE,
              col.names = !file.exists("audit_log.csv"), row.names = FALSE)
}

observeEvent(input$run_psa, {
  log_event(session$token, "run_psa",
            sprintf("n_psa=%s; wtp=%s; discount=%s",
                    input$n_psa, input$wtp, input$discount_rate))
})
```

Using `session$token` (a per-session identifier Shiny already generates) rather than any personal identifier keeps the log anonymous while still letting a reviewer distinguish one exploration session from another. For heavier use, the same rows can be written to a SQLite file with the `RSQLite` package instead of a flat CSV, which scales better once the log reaches tens of thousands of rows and supports simple SQL filtering (`SELECT * FROM audit_log WHERE event = 'run_psa'`) for later review.

#pitfall[
  Logging is easy to over-collect by accident. If a future version of the app adds a text box for reviewer comments, free-text search terms, or an uploaded patient-level dataset, a blanket "log every input" habit can silently write identifiable or commercially sensitive content to a plain-text file with no access control. The running TB model example has no real patient data, but build the logging function to log _parameter values and event names only_, and treat any free-text or file-upload input as excluded unless there is a deliberate, reviewed decision to include it.
]

#agency-note[
  NICE's Decision Support Unit technical support documents (the TSD series, e.g. TSD 12 on probabilistic sensitivity analysis and TSD 19 on partitioned-survival modelling) do not mandate a specific audit-logging format, but NICE's broader stance in Technology Appraisal — that the ERG must be able to reproduce the submitted results from the supplied model — makes an audit trail a practical way to demonstrate that the figures in a downloaded report were in fact generated by the inputs claimed in the accompanying write-up.
]

== 29.6 Deployment: shinyapps.io, Posit Connect, Docker, servers

A finished Shiny app is only useful to an ERG or a client reviewer once it is reachable at a URL they can open without installing R. There are three broad routes, differing mainly in who manages the server and how much control that gives you over the environment.

*shinyapps.io* is Posit's managed hosting service. You deploy with a single call to `rsconnect::deployApp()`, and Posit runs the server, handles HTTPS, and scales instances up and down automatically.

#difficult-terminology("shinyapps.io")[
  A hosting service, run by Posit (the company behind RStudio), that takes your Shiny app's files and runs them on servers Posit manages, giving you a public web address. You do not need to know anything about Linux servers to use it — you authenticate once, then deploy with one R command.
]

```r
rsconnect::setAccountInfo(
  name   = "your-account",
  token  = "xxxxxxxxxxxxxxxx",
  secret = "yyyyyyyyyyyyyyyy"
)

rsconnect::deployApp(
  appDir  = "tb_model_app",
  appName = "tb-markov-psa-explorer"
)
```

*Posit Connect* is a more capable platform, available either as a Posit-managed cloud service or installed on an organisation's own servers. It hosts Shiny apps alongside scheduled Quarto reports — the same scheduled-rendering mechanism introduced in Chapter 28 for recurring report generation can live on the identical server that hosts the interactive app, which matters when a client wants both a live explorer and a weekly automated PDF built from the same codebase.

*Docker plus a plain Linux server* gives full control: you define the exact R version, package versions, and system libraries in a container image, and run that container on infrastructure you or your organisation's IT team owns.

#difficult-terminology("Docker image / containerization")[
  A Docker image is a self-contained snapshot of an operating system, R installation, and all required packages, built from a text recipe called a Dockerfile. "Containerization" is the practice of packaging software this way so it runs identically on any machine with Docker installed — your laptop, a test server, and the production server all run the exact same environment, which avoids the classic "it worked on my machine" problem.
]

```dockerfile
# Illustrative only -- verify exact base image and package list for your setup
FROM rocker/shiny:4.3.2

RUN install2.r --error \
    shiny ggplot2 dplyr quarto rsconnect RSQLite

COPY ./tb_model_app /srv/shiny-server/tb_model_app

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
```

A server built this way typically sits behind a reverse proxy — a second piece of server software (commonly nginx or Apache) that receives the public HTTPS traffic and forwards it internally to the Shiny container, handling certificates and routing so the app itself never deals with raw internet traffic directly.

#difficult-terminology("reverse proxy")[
  A server that sits in front of your actual application and forwards incoming requests to it, while handling tasks like HTTPS encryption, load balancing across multiple copies of the app, and hiding the internal server address from the public internet. Think of it as a receptionist who takes every visitor's request and relays it to the right office, rather than visitors walking directly into back rooms.
]

#heor-practice[
  Pin exact package versions (with `renv::snapshot()`, per Chapter 28's reproducibility discussion) _before_ building the Docker image or deploying to shinyapps.io. A deployment that silently picks up a newer CRAN package version than the one used to validate the model is a reproducibility risk an ERG reviewer has no way of detecting from the outside.
]

#ref-table(
  [Comparing the three main Shiny deployment routes for an HTA submission app],
  academic-table(
    columns: (1.5fr, 1.3fr, 1.5fr, 1.7fr),
    align: (left, left, left, left),
    header: ([*Criterion*], [*shinyapps.io*], [*Posit Connect*], [*Docker + own server*]),
    body: (
      [Setup effort], [Minutes], [Hours (if self-hosted)], [Hours to days],
      [Ongoing maintenance], [Low (Posit-managed)], [Low-medium], [Medium-high (own team patches OS/R)],
      [Cost], [Free tier; paid tiers scale with usage], [Licence fee (enterprise)], [Server/cloud cost + staff time],
      [Data stays on-premises], [No (Posit cloud)], [Yes, if self-hosted], [Yes],
      [Scheduled Quarto reports alongside app], [No], [Yes (native)], [Possible, self-configured],
      [Typical fit], [Pilot work, non-sensitive data], [Orgs with existing Posit licence], [Orgs with strict data-governance/on-prem rules],
    ),
    footer: none,
  ),
) <tab-ch29-deployment>

None of these three is universally correct. A small consultancy producing an exploratory model for internal client review may be well served by shinyapps.io's free tier; a manufacturer with an existing enterprise Posit licence and recurring submission-cycle reporting needs will likely already have Posit Connect available; and an academic health economics group bound by a university or NHS data-governance policy that prohibits sending anything (even synthetic parameter values) to third-party cloud infrastructure may have no option but self-hosted Docker. The right choice is set by the agency's or organisation's IT and data-governance constraints well before it is set by the app's technical requirements.

== 29.7 Security, validation and agency expectations for web-based models

Putting a health-economic model on the web introduces failure modes that a script run locally in RStudio never faces: an anonymous user can type anything into an input box, and that input will reach the model's arithmetic unless the app actively defends against it. Shiny's three-function pattern — `req()`, `validate()`, and `need()` — exists precisely to turn "silently produces a nonsensical ICER" into "clearly tells the user why this input cannot be processed."

#difficult-terminology("input validation")[
  Input validation is the practice of checking that a value entered by a user is sensible _before_ using it in a calculation — for example, rejecting a negative discount rate or a utility value above 1. Without it, a model may run without error but produce a meaningless result (a negative QALY gain, an ICER of zero), which is far more dangerous than an obvious crash because a reviewer may not notice.
]

```r
output$icer_result <- renderText({
  req(input$wtp, input$discount_rate)

  validate(
    need(input$discount_rate >= 0 && input$discount_rate <= 0.1,
         "Discount rate must be between 0% and 10%."),
    need(input$wtp > 0,
         "Willingness-to-pay threshold must be a positive number."),
    need(input$n_psa >= 100,
         "Please run at least 100 PSA iterations for a stable estimate.")
  )

  icer <- run_markov_model(wtp = input$wtp,
                            discount_rate = input$discount_rate,
                            n_psa = input$n_psa)
  scales::dollar(icer)
})
```

`req()` quietly halts the reactive if a required input is missing (e.g. before the user has touched a slider); `validate()` paired with `need()` instead shows the user an explicit, readable message explaining exactly which constraint failed. For a model intended for ERG review, the second behaviour is the right default for anything that isn't simply "not yet filled in" — a reviewer testing the boundaries of the model (what happens at a 0% discount rate, or an implausibly high utility value) should get a clear rejection message, not a cryptic R error trace or, worse, a plausible-looking but wrong number.

A second, distinct concern is exposure of the model itself. Shiny apps run your R code on a server; end users interact only through the rendered HTML/JavaScript front end and never see the server-side source by default. That is a genuine protection for commercially sensitive model structure, but it is not absolute — browser developer tools can reveal client-side logic if any calculation is mistakenly pushed into JavaScript, and a misconfigured server can expose file-browsing endpoints. Where the model contains unpublished structure (e.g. a manufacturer's not-yet-public cost-effectiveness model ahead of submission), restrict access with authentication rather than relying on "security by obscurity" of an unlisted URL: shinyapps.io offers an authorized-users tier that requires login before the app loads, and Posit Connect has built-in user and group authentication, including integration with an organisation's existing login system.

#difficult-terminology("penetration testing")[
  A deliberate, authorised attempt to find security weaknesses in a system by trying to break into it the way a malicious actor would — probing for ways to access files, data, or functionality that should be restricted. For a web-hosted health-economic model, the practical equivalent most teams can realistically do is a lighter checklist: confirm no server files are browsable, confirm authentication actually blocks unauthenticated access, and confirm input validation cannot be bypassed by unusual values (blank, negative, extremely large, or non-numeric text) — a full formal penetration test is usually reserved for apps handling real patient-level data.
]

#pitfall[
  A `validate()`/`need()` check only runs inside the reactive expression it is written in. A common mistake is validating the input used to _display_ a result while a separate `downloadHandler()` or a different output re-reads the same raw `input$x` without its own validation — meaning an out-of-range value blocked on screen can still slip into a downloaded report. Centralise validation in a single reactive (or a small validation function called from every consumer) rather than repeating ad-hoc checks per output.
]

What do HTA agencies actually expect from an interactive model app submitted alongside written evidence? NICE's Technology Appraisal process is explicit that the underlying economic model must be fully transparent to the Evidence Review Group: the ERG is expected to be able to interrogate the model's structure, assumptions, and calculations directly, not merely read a results summary. A Shiny app that lets the ERG change any input NICE's TSDs identify as a key driver of uncertainty, rerun the analysis, and see the ICER and CEAC update live is a natural extension of that transparency requirement — provided the app is accompanied by (not a replacement for) the full underlying R code and documentation, since "transparent" in NICE's process means reviewable in detail, not merely interactive at the surface.

#agency-note[
  NICE's process for Technology Appraisal requires that the company's economic model be made available to the ERG in a form that permits full technical scrutiny, with ERG critique and company response iterated through the "technical engagement" stage of the appraisal. An interactive Shiny front-end is a supplement to this requirement, not a substitute: the ERG still needs access to the executable model and its full code, and any app presented for review should make clear which parameters are exposed as adjustable inputs versus fixed by the submitted base case.
]

== 29.8 Case study: a transparent, reviewable submission-ready model app

This closing case study pulls together the chapter's threads — reactive design (Sections 29.1-29.4), downloadable audited reports (29.5), a deployment decision (29.6), and agency-grounded security practice (29.7) — into a single sketch of what a submission-ready Shiny front end for the book's running TB Markov model (Chapters 17-27) might look like.

The design brief is simple to state and demanding to execute: an ERG reviewer should be able to open the app, see the base-case results immediately, adjust any parameter NICE's TSDs would flag as a key uncertainty driver, rerun the probabilistic analysis, watch the CE-plane and CEAC update, and download a fully parameterised Quarto report (via the Chapter 28 pipeline) that reproduces exactly what they saw — all while every action is captured in an audit log and every input is bounded so a mistyped value fails loudly rather than silently.

The UI groups inputs by clinical plausibility, each with an explicit bound enforced later in validation rather than left to the slider's default range alone:

```r
ui <- fluidPage(
  titlePanel("TB Markov Model -- Interactive PSA Explorer (ERG Review Build)"),
  sidebarLayout(
    sidebarPanel(
      numericInput("tx_success_prob", "Treatment success probability",
                   value = 0.85, min = 0, max = 1, step = 0.01),
      numericInput("relapse_rate", "Annual relapse rate",
                   value = 0.05, min = 0, max = 0.5, step = 0.01),
      numericInput("discount_rate", "Discount rate (%)",
                   value = 3.5, min = 0, max = 10, step = 0.5),
      numericInput("wtp", "Willingness-to-pay threshold (£/QALY)",
                   value = 20000, min = 1000, max = 100000, step = 1000),
      numericInput("n_psa", "Number of PSA iterations",
                   value = 1000, min = 100, max = 10000, step = 100),
      actionButton("run_psa", "Run PSA", class = "btn-primary"),
      downloadButton("download_report", "Download full audited report")
    ),
    mainPanel(
      plotOutput("ce_plane"),
      plotOutput("ceac"),
      verbatimTextOutput("icer_summary")
    )
  )
)
```

The server logic follows the `eventReactive()` pattern from Section 29.4: nothing recomputes until "Run PSA" is clicked, every click is validated and logged, and the three outputs (CE-plane, CEAC, ICER summary) all read from the one reactive result so they stay consistent with each other.

```r
server <- function(input, output, session) {

  psa_results <- eventReactive(input$run_psa, {
    validate(
      need(input$tx_success_prob > 0 && input$tx_success_prob <= 1,
           "Treatment success probability must be between 0 and 1."),
      need(input$relapse_rate >= 0 && input$relapse_rate <= 0.5,
           "Relapse rate must be between 0 and 0.5."),
      need(input$discount_rate >= 0 && input$discount_rate <= 10,
           "Discount rate must be between 0% and 10%."),
      need(input$n_psa >= 100, "Use at least 100 PSA iterations.")
    )

    log_event(session$token, "run_psa",
               sprintf("tx_success=%s; relapse=%s; discount=%s; wtp=%s; n_psa=%s",
                       input$tx_success_prob, input$relapse_rate,
                       input$discount_rate, input$wtp, input$n_psa))

    run_tb_markov_psa(
      tx_success_prob = input$tx_success_prob,
      relapse_rate    = input$relapse_rate,
      discount_rate   = input$discount_rate / 100,
      n_psa           = input$n_psa
    )
  })

  output$ce_plane <- renderPlot(plot_ce_plane(psa_results(), wtp = input$wtp))
  output$ceac     <- renderPlot(plot_ceac(psa_results()))
  output$icer_summary <- renderText(summarise_icer(psa_results()))

  output$download_report <- downloadHandler(
    filename = function() paste0("tb_erg_report_", Sys.Date(), ".docx"),
    content = function(file) {
      log_event(session$token, "download_report", "triggered")
      quarto::quarto_render(
        input = "erg_report.qmd",
        output_file = basename(file),
        execute_params = list(
          tx_success_prob = input$tx_success_prob,
          relapse_rate    = input$relapse_rate,
          discount_rate   = input$discount_rate,
          wtp             = input$wtp,
          n_psa           = input$n_psa
        )
      )
      file.copy(basename(file), file, overwrite = TRUE)
    }
  )
}
```

Every element here answers a concern raised earlier in the chapter. The bounded `numericInput()`s plus `validate()`/`need()` calls stop an ERG reviewer's boundary-testing from producing a nonsensical or silently wrong ICER (Section 29.7). The `eventReactive()`/action-button pattern avoids the PSA rerunning on every keystroke, keeping the app responsive during exploration (29.4). `log_event()` builds the audit trail that lets anyone reconstruct which inputs produced which plot (29.5). And the `downloadHandler()` calls the same `quarto_render()` pipeline from Chapter 28, so the downloaded Word document is guaranteed to match the on-screen results rather than being a separately maintained export routine.

#heor-practice[
  Before submission, run through the app yourself entering the extreme ends of every bound (minimum and maximum allowed values, and values just outside them) and confirm each produces either a sensible result or a clear `validate()` message — never a raw error trace or a plausible-but-wrong number. This ten-minute check is the single highest-value piece of QA for a submission-facing app.
]

Deployment choice for this app (Section 29.6) should follow the sponsoring organisation's existing arrangement rather than a technical ideal: if a Posit Connect licence and scheduled-reporting workflow from Chapter 28 already exist, hosting the app there alongside the scheduled report keeps everything in one governed environment; if not, shinyapps.io with the authorized-users tier is a reasonable interim choice for a reviewer group of known individuals.

#agency-note[
  This app is, in miniature, the kind of artefact NICE's Technology Appraisal process is pointed toward when it asks for a fully transparent, ERG-reviewable economic model: the parameters the ERG is most likely to probe during technical engagement are exposed as adjustable inputs, the PSA and CEAC are generated live rather than pre-baked, and the downloadable report is traceable via the audit log to the exact inputs that produced it. It supplements, rather than replaces, providing the ERG with the full underlying R codebase.
]

With a working, validated, auditable interactive front end now sitting on top of the TB Markov model, the natural next step is to stop treating that model as a loose collection of scripts and start treating it as proper software: Chapter 30 turns to packaging the model, its documentation, and its tests into an installable R package, and to the pipeline tooling that keeps a model reproducible as it evolves through successive submission cycles.
