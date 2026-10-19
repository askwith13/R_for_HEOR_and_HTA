#import "../common.typ": *

= Chapter 3. R Essentials for Health Economists

#learning-objectives((
  [Use R's core data structures — vectors, lists, data frames/tibbles, matrices and arrays — fluently, including why each matters for later HEOR modelling work.],
  [Wrangle tabular data efficiently with both `tidyverse`/`dplyr` and `data.table`, and know when to prefer each.],
  [Apply vectorization and `purrr`'s functional-programming tools to iterate a calculation across many parameter sets — the exact pattern later used for probabilistic sensitivity analysis.],
  [Write well-structured, defensively-programmed R functions using named parameter lists, appropriate for models with many inputs.],
  [Profile R code before optimizing it, and know when `Rcpp` or parallelisation (`future`/`furrr`) is actually warranted.],
  [Handle dates, durations and time-to-event quantities correctly with `lubridate`, avoiding common international date-format pitfalls.],
  [Debug R code interactively and handle errors gracefully in long-running simulations such as PSA loops.],
))

== 3.1 Data structures: vectors, lists, data frames and tibbles, arrays and matrices

Almost everything you will ever compute in a health-economic evaluation — costs, utilities, probabilities, model traces — ultimately lives inside one of a handful of R data structures. Before Chapter 4 introduces any economic concepts, it is worth being fluent in these containers, because the structure you choose determines how easy (or treacherous) later calculations will be.

The atomic vector is the most basic unit. R has no true scalars: even a single number like `42` is a vector of length one. Vectors are homogeneous — every element shares one type (`logical`, `integer`, `double`, `character`) — and R exploits this to *vectorize* arithmetic, meaning operations apply element-by-element without an explicit loop:

```r
cost <- c(1200, 3400, 980, 15600)
outcome <- c(0.72, 0.65, 0.81, 0.40)
cost_per_outcome_unit <- cost / outcome
cost_per_outcome_unit
```

This vectorization is not a minor convenience; it is the reason R code that processes thousands of patient records runs in milliseconds rather than requiring hand-written loops. Mixing types in `c()` triggers implicit coercion (the hierarchy is roughly logical → integer → double → character), a frequent source of silent bugs — a logical vector accidentally combined with a character vector becomes character, and comparisons stop working as expected.

Lists relax the homogeneity rule: a list can hold elements of different types and lengths, including other lists. This makes lists the natural container for structured, non-tabular things — most importantly, bundles of model parameters. A typical pattern you will reuse heavily from Chapter 4 onward is a nested list holding every input a model needs:

```r
params <- list(
  costs = list(drugA = 1200, drugB = 980, monitoring = 150),
  utilities = list(well = 0.85, sick = 0.55, dead = 0),
  discount_rate = 0.035
)
params$costs$drugA
```

Access with `$` and `[[ ]]` extracts a single element; single-bracket `[ ]` on a list always returns a (sub-)list, even for one element — a distinction that trips up almost everyone at least once.

Tabular data is where `data.frame` and its tidyverse cousin `tibble` (from the `tibble` package, loaded automatically with `library(tidyverse)`) come in. Both store a collection of equal-length vectors as named columns, so a data frame can mix numeric, character and factor columns side by side — exactly the shape of a patient-level dataset with an ID, a cost, and a treatment arm. Tibbles behave identically for most purposes but deliberately tighten base R's looser habits: they print only the first ten rows with column types labeled, never do partial matching of column names, and `[` always returns a tibble (never silently drops to a vector) unlike a data frame, whose `[` drops to a vector when it selects a single column.

#pitfall[
  Base `data.frame` objects support *partial matching* on `$` and allow `drop = TRUE` behavior by default when subsetting a single column with `[`. So `df$cos` may silently return the `cost` column if no other column starts with `cos`, and `df[, "cost"]` returns a bare numeric vector, not a one-column data frame. Both behaviors have caused real analysis errors in published health-economic code. `tibble` objects disable partial matching entirely and never implicitly drop dimensions, which is one of the strongest arguments for using `as_tibble()` or `tibble()` constructors throughout your HEOR workflows.
]

Matrices and arrays generalize vectors to two or more dimensions while keeping a single data type. A matrix is just a vector with a `dim` attribute, built with `matrix()`; an array extends this to three or more dimensions. These matter enormously for the Markov cohort models you will build in Chapter 19: a transition probability matrix is naturally represented as a square matrix where rows sum to 1, and `%*%` (matrix multiplication) propagates a cohort distribution one cycle forward with a single operation.

#heor-practice[
  A toy three-state transition structure (Healthy, Sick, Dead) can be sketched now, long before any Markov-model machinery exists:
  ```r
  states <- c("Healthy", "Sick", "Dead")
  tm <- matrix(
    c(0.80, 0.15, 0.05,
      0.00, 0.70, 0.30,
      0.00, 0.00, 1.00),
    nrow = 3, byrow = TRUE,
    dimnames = list(states, states)
  )
  rowSums(tm)  # should equal 1 for every row
  ```
  Building this habit early — always naming dimensions with `dimnames` and always checking `rowSums()` equals 1 — will save debugging time when transition matrices grow to a dozen states.
]

Finally, three inspection functions should become reflexive: `class()` reports the object's high-level class (`"data.frame"`, `"matrix"`, `"numeric"`), `typeof()` reports R's internal storage type (`"double"`, `"list"`, `"character"`), and `str()` gives a compact recursive summary of structure and contents — indispensable for peering into a nested parameter list or confirming a column you expected to be numeric did not silently become a factor or character on import.

== 3.2 Data wrangling with `tidyverse` and `data.table`

Reading in raw data is rarely the hard part; reshaping it into the form an analysis needs almost always is. R offers two mature, widely used approaches to this reshaping, and a working HEOR analyst should be conversant in both: the `tidyverse` (principally the `dplyr` package, plus the pipe) and `data.table`. They are not rivals to be chosen once and for all — they solve the same problem with different trade-offs in readability and speed, and large pharmacoepi or claims-registry projects frequently use both in the same codebase.

The `dplyr` grammar is built from a small set of verbs that each do one thing: `filter()` keeps rows matching a condition, `select()` keeps columns, `mutate()` creates or modifies columns, `group_by()` partitions a data frame into groups for subsequent operations, and `summarise()` collapses each group to one row of aggregate statistics. These verbs are chained with the pipe operator — either `magrittr`'s `%>%` (the long-standing tidyverse convention) or base R's native `|>` (available since R 4.1, functionally equivalent for straightforward chains and increasingly the recommended default). The result reads almost like a sentence describing the transformation step by step:

```r
library(tidyverse)

patient_data |>
  filter(arm %in% c("Drug A", "Drug B")) |>
  group_by(arm) |>
  summarise(mean_cost = mean(total_cost), n = n())
```

`data.table` takes a different, more compact approach, built around a single indexing expression `DT[i, j, by]`: `i` selects/filters rows, `j` computes or selects columns, and `by` groups the computation — all inside one set of square brackets, operating on the table *in place* rather than copying it. The equivalent computation looks like this:

```r
library(data.table)

patient_dt <- as.data.table(patient_data)
patient_dt[arm %in% c("Drug A", "Drug B"),
           .(mean_cost = mean(total_cost), n = .N),
           by = arm]
```

Both snippets produce the same grouped summary, and once the `DT[i, j, by]` pattern is internalized it is no less readable than the pipe — it is simply denser. The practical difference that matters is performance and memory behavior at scale. `data.table` modifies data in place (via reference semantics and functions like `setDT()` and `:=` for in-place column assignment) and uses a highly optimized C-level radix sort and hash-based grouping, which makes it dramatically faster and more memory-efficient than `dplyr` once a dataset reaches into the millions of rows — exactly the regime of national claims databases, disease registries, or simulated patient-level microsimulation output with many replications. `dplyr`, by contrast, favors copy-on-modify semantics (it never silently alters your original object), which is safer for interactive, exploratory work but costs more memory and time as data grows.

#difficult-terminology("radix sort / hash-based grouping")[
Both are internal techniques for ordering or grouping rows of data
fast, and the reason `data.table` can out-perform more general
approaches at large scale. An ordinary comparison-based sort (the kind
most languages use by default) repeatedly compares pairs of whole
values against each other to decide their order, which gets slower as
the dataset grows because the number of comparisons needed grows
faster than the data itself. A *radix sort* instead orders data by
processing one digit, character, or byte at a time — rather like
sorting a stack of exam papers first by surname's first letter into
26 piles, then re-sorting each pile by the second letter, and so on —
which scales far better for the kinds of values (integers, short
strings, factor-coded categories) common in claims and registry data.
*Hash-based grouping* uses a related lookup-table trick for the
`by =` step in `DT[i, j, by]`: rather than comparing every row against
every other row to see which share a group, it computes a quick
numeric "fingerprint" (a hash) for each row's grouping value and uses
that fingerprint as a direct lookup key, finding matching rows nearly
instantly instead of scanning the whole table repeatedly. Neither
technique requires you to write any special code yourself — `data.table`
applies them automatically whenever you sort or group — but knowing
they exist explains *why* the same `DT[i, j, by]` syntax that looks
unremarkable on a 500-row toy dataset becomes dramatically faster than
`dplyr` once you are working with millions of claims records.
]

#list(
  [Prefer `tidyverse`/`dplyr` when the dataset is small-to-moderate (comfortably fits in memory with room to spare), when the code will be read and maintained by collaborators less fluent in R, or when the pipeline benefits from the broader tidyverse ecosystem (`tidyr` for reshaping, `ggplot2` for plotting the same tibbles downstream).],
  [Prefer `data.table` when working with claims-scale or registry-scale data (millions of rows, wide microsimulation outputs, repeated resampling such as probabilistic sensitivity analysis replications), when runtime or memory genuinely becomes a bottleneck, or when the same large table is updated repeatedly inside a loop, where `data.table`'s in-place `:=` avoids repeated full-table copies.],
  [Mixing both is common and acceptable: convert a `data.table` result back with `as_tibble()` or `setDF()` once the heavy aggregation is done, and finish the pipeline in `dplyr`/`ggplot2` for readability.],
)

#pitfall[
  `data.table`'s `:=` and in-place modification mean that assigning `dt2 <- dt1` does *not* create an independent copy the way it would for a data frame or tibble — `dt2` and `dt1` point to the same underlying object, and modifying one with `:=` silently modifies the other. If you need an independent copy, use `copy(dt1)` explicitly. This reference-semantics behavior is the single most common source of "my original data changed and I don't know why" bugs when analysts move from `dplyr` to `data.table`.
]

#agency-note[
  Whichever grammar you choose for a given analysis script, say so explicitly in the script header or project README (Chapter 2's `analysis/` convention) and stay consistent within that script — silently switching between `%>%`, `|>`, and `DT[]` syntax mid-pipeline makes code far harder for a collaborator, or your future self, to audit. The CHEERS 2022 reporting checklist (covered in full in Chapter 28), item 29, explicitly requires that analytic methods be reported in enough detail for a third party to reproduce them — code-style consistency within one script is a small thing that materially supports that requirement in practice, not just a stylistic nicety.
]

#ref-table(
  [Common data-wrangling operations: `dplyr`/tidyverse syntax versus the equivalent `data.table` expression.],
  academic-table(
    columns: (1.5fr, 1.8fr, 1.8fr),
    align: (left, left, left),
    header: ([*Operation*], [*`dplyr` / tidyverse*], [*`data.table`*]),
    body: (
      [Filter rows], [`filter(arm == "Drug A")`], [`DT[arm == "Drug A"]`],
      [Select columns], [`select(id, cost)`], [`DT[, .(id, cost)]`],
      [Create/modify column], [`mutate(cost2 = cost * 1.1)`], [`DT[, cost2 := cost * 1.1]`],
      [Group and summarise], [`group_by(arm) |> summarise(mean_cost = mean(cost))`], [`DT[, .(mean_cost = mean(cost)), by = arm]`],
      [Chain multiple steps], [`|>` or `%>%` pipe between verbs], [stacked `[i, j, by]` expressions],
      [Independent copy], [implicit (copy-on-modify)], [explicit: `copy(dt1)`],
    ),
    footer: (table.cell(colspan: 3)[*Note.* `data.table` modifies in place via reference semantics; `dplyr` never silently alters the original object.],),
  ),
) <tab-ch03-dplyr-datatable>

== 3.3 Functional programming with `purrr` and vectorization

R is a vectorized language at its core: arithmetic, comparisons, and most mathematical functions operate element-by-element on whole vectors without you writing an explicit loop. This matters for more than style. A `for` loop that grows a result vector by repeated `c()` or indexed assignment inside the loop forces R to reallocate memory on every iteration, and interpreted loop overhead adds up quickly once you are iterating over thousands of patients, cycles, or parameter draws — exactly the scale you hit in probabilistic sensitivity analysis (PSA) later in this book. A vectorized expression, by contrast, dispatches to compiled C code under the hood and processes the whole vector in one pass. The practical rule of thumb: if you find yourself writing `for (i in 1:n)` to apply the same arithmetic to each element of a vector, stop and ask whether the operation can be expressed directly on the vector instead.

```r
n_patients <- 1000
cost_per_visit <- rep(185.50, n_patients)
n_visits <- sample(1:12, n_patients, replace = TRUE)

# Avoid: explicit loop
total_cost_loop <- numeric(n_patients)
for (i in seq_len(n_patients)) {
  total_cost_loop[i] <- cost_per_visit[i] * n_visits[i]
}

# Prefer: vectorized
total_cost_vec <- cost_per_visit * n_visits
```

Not every problem reduces to simple elementwise arithmetic, though. Often you need to apply a more elaborate function — one with branching logic, multiple inputs, or a non-trivial return type — to each element of a list or each row of a parameter table. This is where the `purrr` package (part of the tidyverse) earns its place in your toolkit, as a more predictable and composable alternative to base R's `sapply()`/`lapply()`.

The core function is `purrr::map()`, which always returns a list, regardless of what you feed it — this predictability is the whole point. Where `sapply()` will silently simplify its output to a vector, a matrix, or a list depending on the data, `map()` never surprises you. When you know the output should be a specific atomic type, use the typed variants: `map_dbl()` returns a double vector (or errors if any element can't be coerced), `map_chr()` a character vector, `map_lgl()` a logical vector, and so on. This type enforcement is itself a form of defensive programming — a `map_dbl()` call that unexpectedly hits a non-numeric result fails loudly instead of quietly returning an untyped list you forget to unlist.

```r
library(purrr)

scenarios <- list(
  base_case  = list(cost_visit = 185.50, visits = 4, n_patients = 250),
  high_cost  = list(cost_visit = 240.00, visits = 4, n_patients = 250),
  high_util  = list(cost_visit = 185.50, visits = 7, n_patients = 250)
)

calc_total_cost <- function(params) {
  params$cost_visit * params$visits * params$n_patients
}

total_costs <- map_dbl(scenarios, calc_total_cost)
total_costs
#>  base_case  high_cost  high_util
#>     185500     240000     324625
```

When you need to iterate over two parallel vectors or lists simultaneously, `map2()` takes two inputs and applies a function pairwise; when you have three or more, `pmap()` takes a single list of input lists/vectors and applies a function across all of them element-by-element. These generalize naturally to the structure of a parameter table, where each row is one scenario and each column is one parameter.

```r
visit_counts <- c(4, 5, 6)
cost_per_visit <- c(185.50, 185.50, 200.00)

map2_dbl(visit_counts, cost_per_visit, ~ .x * .y * 250)

param_grid <- list(
  cost_visit  = c(185.50, 200.00, 220.00),
  visits      = c(4, 5, 6),
  n_patients  = c(250, 250, 300)
)

pmap_dbl(param_grid, calc_total_cost)
```

#heor-practice[
  This `scenarios` list and `pmap_dbl()` pattern is not a toy exercise — it is the literal skeleton of a PSA loop. In Chapter 25, you will replace this three-row `param_grid` with a parameter table of 1,000+ rows, each row a random draw from a cost or utility distribution, and replace `calc_total_cost()` with a full cost-effectiveness model function. The call becomes `pmap(psa_params, run_model)`, and the output list becomes your distribution of ICERs. Learning to think in terms of "a function applied across a parameter table" now will make that chapter feel like a straightforward extension rather than a new paradigm.
]

== 3.4 Writing functions, parameter lists and defensive programming

HEOR models rarely take two or three arguments. A Markov cost-effectiveness model might need transition probabilities, cost inputs, utility weights, a discount rate, a time horizon, and a cycle length — easily ten or more parameters. Writing a function that takes these as a long sequence of positional arguments is a recipe for subtle, hard-to-detect bugs: swap the order of `discount_rate` and `cycle_length` in a call several hundred lines away from the function definition, and R will not complain — it will just silently compute the wrong answer.

```r
# Fragile: positional arguments, easy to transpose by mistake
run_model <- function(p_progress, p_death, cost_well, cost_sick,
                       util_well, util_sick, discount_rate, horizon) {
  # ...
}
```

The more robust pattern is to bundle related parameters into a single named list (or, for larger models, a dedicated list-of-lists or a small S3/S4 object) and pass that one structured object into the function. Named access by `$` or `[[ ]]` makes every call self-documenting and immune to argument-order mistakes.

#difficult-terminology("S3 / S4 objects")[
R has more than one system for object-oriented programming — ways of
bundling data together with the functions ("methods") that know how to
act on it, so the data carries its own behaviour rather than living as
a bare, anonymous list. S3 is the older, lightweight system: you
simply attach a `class` attribute (a label) to an ordinary R object,
and then write functions named in a particular pattern (e.g.
`print.my_model`) that R automatically dispatches to whenever someone
calls `print()` on an object of that class. There is no formal
definition enforced anywhere — it works by convention and is
easy to get wrong silently. S4 is a stricter, more formal system:
you explicitly declare a class's structure in advance (which fields it
must have, and what type each one is), and R then checks that any
object you create actually conforms to that declaration, catching
mistakes earlier. A filing-cabinet analogy helps: S3 is like labelling
a folder "Patient Record" and trusting everyone to put the right kinds
of documents inside it; S4 is like a pre-printed form with named,
typed boxes for each field, which physically cannot be filled in with
the wrong kind of information. Most of this book's own worked examples
use plain named lists for simplicity, but model-parameter bundles,
`survival` package model-fit objects, and several HEOR packages
(`flexsurv`, `heemod`) use S3 or S4 objects internally, so recognising
the pattern when you see `class(x)` or `methods(print)` in someone
else's code is a practically useful skill even if you rarely need to
*write* a new S4 class yourself.
]

```r
model_params <- list(
  p_progress     = 0.15,
  p_death        = 0.05,
  cost_well      = 1200,
  cost_sick      = 8500,
  util_well      = 0.85,
  util_sick      = 0.55,
  discount_rate  = 0.035,
  horizon        = 10
)

run_model <- function(params) {
  stopifnot(is.list(params))
  with(params, {
    # model logic refers to p_progress, cost_sick, etc. by name
  })
}
```

Give arguments sensible default values wherever a standard convention exists — a discount rate of 3.5% per UK NICE guidance, or a cycle length of one year, for instance — using R's native `function(x, discount_rate = 0.035)` syntax. Defaults reduce boilerplate at every call site and document the "normal" assumption directly in the function signature, but be explicit in comments about where a default comes from, since a silently-applied wrong default is just as dangerous as a wrong argument.

The deeper issue is that R, by design, is permissive about types. A probability argument passed as the character string `"0.15"` instead of the numeric `0.15` will often not fail immediately — it may propagate through several calculations, coerced or recycled in ways that produce a number that looks plausible but is wrong, and surface only as an ICER that is subtly off, discovered (if you are lucky) by a reviewer long after submission. This is why defensive programming is not an optional style preference in HEOR work — it is a quality-assurance requirement.

The baseline tool is `stopifnot()`, which checks one or more conditions and halts execution immediately with an error if any is false — cheap insurance placed at the top of every model function.

```r
run_model <- function(params) {
  stopifnot(
    is.list(params),
    is.numeric(params$p_progress),
    params$p_progress >= 0, params$p_progress <= 1,
    is.numeric(params$discount_rate),
    params$discount_rate >= 0, params$discount_rate < 1,
    params$horizon > 0
  )
  # ... model logic ...
}
```

For checks that need a more informative, customized message than `stopifnot()`'s default, use `stop()` directly, and reserve `warning()` for conditions that are suspicious but not necessarily fatal — an unusually high cost input, say, that you want flagged without halting a long-running PSA batch.

```r
validate_probability <- function(p, name) {
  if (!is.numeric(p)) {
    stop(sprintf("'%s' must be numeric, got %s.", name, class(p)[1]))
  }
  if (p < 0 || p > 1) {
    stop(sprintf("'%s' must lie in [0, 1], got %s.", name, p))
  }
  if (p > 0.9) {
    warning(sprintf("'%s' = %s is unusually high; check the source.", name, p))
  }
  invisible(p)
}
```

A good discipline is to validate every input once, at the top of the function, rather than scattering `if` checks throughout the body — this keeps the "is this input sane?" logic separate from "what does this input mean for the model?" logic, and makes the function easy to audit.

#list(
  [State preconditions explicitly with `stopifnot()` before any computation runs.],
  [Use `stop()` with a formatted, specific message when a precondition fails outright.],
  [Use `warning()` for implausible-but-not-impossible values you want surfaced, not silenced.],
  [Bundle 5+ related arguments into a named list rather than a long positional signature.],
)

#pitfall[
  R's automatic type coercion is a frequent source of silent errors. `if (p_progress == "0.15")` will happily evaluate as `TRUE` even when `p_progress` is the numeric `0.15`, because R coerces the number to a string for the comparison — no error, no warning, just a wrong path taken. A function that checks `is.numeric()` explicitly, rather than relying on implicit coercion inside a comparison, catches this class of bug before it reaches your cost-effectiveness output.
]

#agency-note[
  When you ask an AI coding assistant to draft a model function for you, always ask it to add `stopifnot()` input validation and informative `stop()`/`warning()` messages in the same pass — generated code tends to implement the "happy path" calculation correctly but omit defensive checks unless specifically prompted, and an unvalidated function is the easiest place for a submission-breaking error to hide. NICE's technology appraisal process (Chapter 2) relies on the Evidence Review Group being able to re-run a submitted model and trust its outputs; a model that silently accepts an out-of-range probability and returns a plausible-looking but wrong ICER is a far worse submission failure than one that errors loudly and gets caught before submission.
]

== 3.5 Performance: profiling, `Rcpp`, parallelisation (`future`, `furrr`)

The first rule of optimisation is to not do it until you have evidence. R code that "feels slow" and R code that *is* slow in the place you think it is are often two different programs. Before touching a single line in the name of speed, profile it. `Rprof()` is the base-R sampling profiler — it periodically records the call stack while your code runs, and `summaryRprof()` turns that into a table of where time actually went. `profvis::profvis()` wraps the same mechanism in an interactive flame graph that is far easier to read:

#difficult-terminology("flame graph")[
A flame graph is a specific way of visualising where a program spent
its execution time, and it reads differently from an ordinary bar
chart. Each horizontal bar represents one function call, and its
*width* shows how much total time that call took (wider = slower).
Bars are stacked vertically to show the call hierarchy: a function
sits directly above the bars representing the functions it called, so
following a column straight down from any bar traces that call's
entire chain of parent functions back to the top-level script. The
name "flame graph" comes from the characteristic look of these stacked
bars — varying widths at each level resembling flickering flame tips.
Reading one is mostly about scanning for the *widest* bars, especially
ones near the bottom of a tall stack (meaning a deeply nested
function is eating a disproportionate share of total runtime) — those
are the parts of the code actually worth optimising, as opposed to
functions that are called often but individually fast, which will show
up as many thin bars rather than one wide one.
]

```r
library(profvis)

profvis({
  results <- vector("list", 500)
  for (i in seq_len(500)) {
    results[[i]] <- run_markov_trace(params_list[[i]])
  }
})
```

#figure(
  image("../images/r_generated/ch03_profiling_flamegraph.png", width: 90%),
  caption: [`Rprof()`/`summaryRprof()` output on a deliberately slow Markov-trace loop. The `rbind()`-in-a-loop anti-pattern dominates total time — `data.frame()`, `as.data.frame()` and `rbind()` together account for well over half of it — exactly the kind of result profiling should surface before any hand optimisation begins.],
) <fig-ch03-profiling>

#report-table(
  [Top functions by self + total time in the `summaryRprof()` output above, ranked by where profiling attention should go first.],
  academic-table(
    columns: (auto, 1.6fr, 2fr),
    align: (left, left, left),
    header: ([*Rank*], [*Function*], [*Why it dominates*]),
    body: (
      [1], [`rbind()`], [Called once per loop iteration; reallocates and copies the growing result object each time],
      [2], [`data.frame()`], [Invoked internally by `rbind()` on data-frame arguments, compounding the reallocation cost],
      [3], [`as.data.frame()`], [Coercion overhead triggered repeatedly as part of the same `rbind()` call chain],
      [4+], [model/arithmetic logic], [Comparatively minor; swamped by the three functions above combined],
    ),
    footer: (table.cell(colspan: 3)[*Note.* `data.frame()`, `as.data.frame()` and `rbind()` together account for well over half of total runtime — fix the growing-object pattern before considering `Rcpp` or parallelisation.],),
  ),
) <tab-ch03-profiling-summary>

Run this on a *representative* slice of the real workload, not a toy example — bottlenecks in a 500-iteration loop are not always visible at 5 iterations. Nine times out of ten the profiler finds the slow part in a place you didn't expect: a `data.frame` growing row-by-row inside a loop, an unnecessary `rbind()`, or repeated `read.csv()` calls on the same file. Fix those first; they are free wins that require no new tooling.

Occasionally the profiler confirms that the bottleneck is a genuine hot loop — tight, scalar, repeated millions of times — that vectorisation cannot absorb (e.g., a recursive Markov trace update computed one cycle at a time). This is the narrow case where `Rcpp` earns its keep: you rewrite just that loop in C++, compile it inline, and call it from R as an ordinary function.

```r
library(Rcpp)

cppFunction('
  double cycle_sum(NumericVector costs, double discount_rate) {
    double total = 0;
    int n = costs.size();
    for (int i = 0; i < n; i++) {
      total += costs[i] / pow(1 + discount_rate, i);
    }
    return total;
  }
')
```

Reach for this only after profiling has pointed a finger at a specific loop — `Rcpp` adds a C++ toolchain dependency (the one Chapter 2 flagged alongside `cmdstanr`) and a compiled artefact to maintain, so it should replace a measured bottleneck, not a hunch.

More often than not, the real lever is not making one iteration faster but running many iterations at once. This is directly relevant to the probabilistic sensitivity analyses (PSA) built in Chapter 25, where a model is re-run over thousands of parameter draws and each run is independent of the others — an "embarrassingly parallel" problem. The `future` package abstracts *how* code is executed from *what* is executed: you declare a plan once, and the same code then runs sequentially or in parallel without modification.

```r
library(future)
library(furrr)

plan(multisession, workers = 4)

psa_results <- future_map(psa_param_draws, run_model, .progress = TRUE)
```

`furrr::future_map()` is a drop-in parallel replacement for `purrr::map()` — same signature, same list-in/list-out contract, but each element is dispatched to a worker process under the active `future` plan. Swapping `map()` for `future_map()` and adding one `plan()` call is often the entire migration.

#heor-practice[
  Before parallelising a PSA, make sure each iteration is self-contained — no shared mutable state, no writing to the same file from multiple draws. `future`'s workers are separate R processes; they cannot see objects you forgot to pass in, and silent scoping bugs that worked by accident in a sequential `for` loop will fail (or worse, produce wrong numbers) under `multisession`.
]

Parallelising a model that has a bug does not fix the bug; it just produces the wrong answer faster, on four cores at once. Profile, fix the real bottleneck if there is one, parallelise last.

== 3.6 Dates, durations and time-to-event data (`lubridate`)

Health economic models built on trial data live and die by correct date arithmetic — time-to-progression, time-to-death, length of treatment exposure, time between visits, are all date subtractions underneath. Base R's `Date` class handles the simple cases, but `lubridate` makes the parsing, arithmetic and edge cases explicit rather than implicit, which matters when the input is a column of strings from a dozen different trial sites.

Parsing is the first hazard. `lubridate::ymd()`, `dmy()` and `mdy()` each commit to one date order and fail loudly (returning `NA` with a warning) rather than guessing silently:

```r
library(lubridate)

enrol_date <- ymd("2021-03-14")
visit_date <- dmy("14/03/2021")

as.Date("2021-03-14")  # base R equivalent, but order must match exactly
```

#pitfall[
  International trial data frequently mixes `DD/MM/YYYY` and `MM/DD/YYYY` formats across sites, and spreadsheet exports rarely declare which one they used. `as.Date("03/04/2021")` silently parses as 3rd April under one default and 4th March under another — no error, no warning, just a wrong date fed straight into a survival-time calculation. Always confirm the source format explicitly (check a known out-of-range day like the 25th against the site's convention) and parse with the matching `lubridate` function — `dmy()` or `mdy()` — rather than a bare `as.Date()` that silently assumes one order.
]

Once dates are parsed correctly, time-to-event quantities reduce to differences. `difftime()` computes a difference with an explicit unit, which avoids the ambiguity of letting R guess whether you meant days or weeks:

```r
time_to_progression <- difftime(progression_date, enrol_date, units = "days")
```

For anything beyond a single subtraction — durations spanning leap years, or lengths that should be expressed in calendar months rather than a fixed number of days — `lubridate::interval()` and `time_length()` are the more robust pair. An `interval` is a span between two specific timepoints (not just a duration), and `time_length()` converts it into whatever unit you need, correctly accounting for variable month and year lengths:

```r
progression_interval <- interval(enrol_date, progression_date)
time_length(progression_interval, unit = "months")
```

This distinction — duration as "an interval between two real dates" versus duration as "a fixed span of time" — becomes important once you reach the parametric survival models in Chapter 10, where time-to-event outcomes are the response variable and getting the units wrong (days vs. months) silently rescales every fitted hazard and every extrapolated curve downstream.

A related trap is censoring: a patient who has not progressed by the data cut-off does not have a missing progression date in the "NA means unknown" sense — they have a *censored* observation, and that status needs to be carried as its own column (commonly a 0/1 event indicator) rather than inferred from an `NA` in the date field. Confusing "no event date because censored" with "no event date because missing" is a common source of silently wrong survival curves, and it starts right here at the data-cleaning stage, well before any survival model is fitted.

== 3.7 Debugging and error handling

A health economic model that runs to completion and produces a wrong number is more dangerous than one that crashes, because a crash is visible and a silently wrong number is not. This section covers the tools for finding bugs interactively, and — more importantly for the long-running simulations in this book — the discipline of handling errors so that one bad input doesn't either kill a multi-hour run or, worse, let it finish with corrupted results.

When something throws an error, `traceback()` is the first diagnostic: run it immediately after the error to see the full call stack that led to it, innermost call first. This tells you *which* function actually failed, which is not always the function named in the error message:

```r
run_model(bad_params)
#> Error in sqrt(variance) : NaN produced
traceback()
```

For errors that are hard to pin down from the stack alone, `debug(fun_name)` flags a function so that the next call to it drops you into an interactive browser at its very first line, letting you step through line by line and inspect every intermediate object. `browser()` does the same thing but by inserting an explicit breakpoint directly in the source, which is more convenient when you already suspect roughly where the problem is:

```r
run_model <- function(params) {
  browser()  # execution pauses here; inspect `params` interactively
  variance <- compute_variance(params)
  sqrt(variance)
}
```

Both are for *finding* bugs during development. They are not a substitute for handling errors gracefully in code that will run unattended — and in health economic practice, nothing runs more unattended than a PSA loop iterating over thousands of parameter draws. `tryCatch()` is the tool for that: it lets you catch a specific failure, decide what to do about it, and let execution continue rather than halting the entire run.

```r
psa_results <- vector("list", n_iterations)

for (i in seq_len(n_iterations)) {
  psa_results[[i]] <- tryCatch(
    run_model(psa_param_draws[[i]]),
    error = function(e) {
      message(sprintf("Iteration %d failed: %s", i, conditionMessage(e)))
      NA
    }
  )
}
```

Here a single malformed draw — a negative cost sampled from a misspecified distribution, a file read that occasionally fails on a flaky network drive — logs itself and returns `NA` for that one iteration, instead of stopping the other 9,999.

#heor-practice[
  Wrap each individual PSA iteration in its own `tryCatch()`, not the whole loop. Wrapping the entire `for` loop in one `tryCatch()` means the *first* bad draw stops everything and you lose every result computed before it; wrapping each iteration means you lose exactly one data point and keep the other thousands. Always log which iteration failed and why — a silent `NA` with no record of the cause is a debugging problem for tomorrow-you.
]

#agency-note[
  An uncaught error partway through a PSA is the visible failure mode; the one that should worry you more is a *caught* error that is handled too permissively — a blanket `tryCatch(..., error = function(e) 0)` that replaces a failed iteration with zero instead of `NA`. Zero is a plausible-looking number that will quietly bias your cost-effectiveness acceptability curve (CEAC). ISPOR-SMDM good-practice guidance on model transparency (covered in Chapter 27) expects PSA results to be reported alongside the actual number of iterations successfully completed — silently padding a failed run back up to the intended iteration count with substituted zeros defeats that transparency requirement. `NA` at least survives downstream and forces you to notice and account for the dropped iterations before reporting final results.
]

The underlying principle is the same at every scale, from a single `browser()` session to a 10,000-iteration PSA: an error that stops execution is an inconvenience, but an error that gets silently absorbed into a "successful" result is the one that makes it into a published cost-effectiveness ratio.
