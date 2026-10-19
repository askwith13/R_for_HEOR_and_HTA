// Shared Typst helpers used by book.typ and every chapter file.
// Chapter files must start with: #import "../common.typ": *

#let heor-practice(body) = block(
  fill: rgb("#eef5ff"), stroke: (left: 2pt + rgb("#2b6cb0")),
  inset: 10pt, radius: 3pt, width: 100%,
)[*HEOR in practice.* #body]

#let pitfall(body) = block(
  fill: rgb("#fff5ee"), stroke: (left: 2pt + rgb("#c05621")),
  inset: 10pt, radius: 3pt, width: 100%,
)[*Common pitfall.* #body]

#let agency-note(body) = block(
  fill: rgb("#f0fff4"), stroke: (left: 2pt + rgb("#2f855a")),
  inset: 10pt, radius: 3pt, width: 100%,
)[*Agency perspective.* #body]

#let learning-objectives(items) = block(
  fill: rgb("#f7fafc"), stroke: 0.5pt + rgb("#cbd5e0"),
  inset: 10pt, radius: 3pt, width: 100%,
)[
  *Learning objectives*
  #list(..items)
]

// "How to report this" toy APA-style result table, used selectively after
// code blocks whose output has a genuine conventional reporting format in
// the field (ICER/NMB results, NMA league tables, pooled effects, model
// coefficient summaries, etc.) -- not after every code block. Produces a
// labelled, captioned table that is picked up separately by the back
// matter's "List of Tables" (kind: table, distinct from "List of Figures").
//
// Styled like a gt/gtsummary academic table (booktabs convention): NO
// internal horizontal rules between data rows -- only a rule above the
// header, a rule below the header (and below any column-spanner row), and
// a rule at the very bottom (and above any footer/note row). Use the
// `academic-table` helper below to build `body` instead of a bare
// `table(...)` call with `table.hline()` scattered between rows.
#let report-table(caption, body) = figure(
  kind: table,
  supplement: [Table],
  [
    #block(
      fill: rgb("#faf5ff"), stroke: (left: 2pt + rgb("#6b46c1")),
      inset: (top: 8pt, bottom: 0pt, left: 10pt, right: 10pt), radius: (top-left: 3pt, top-right: 3pt),
      width: 100%,
    )[*How to report this.*]
    #block(
      stroke: (left: 2pt + rgb("#6b46c1"), bottom: 0.5pt + rgb("#e2e8f0"), rest: 0.5pt + rgb("#e2e8f0")),
      inset: 10pt, width: 100%,
    )[#body]
  ],
  caption: caption,
)

// Plain academic reference/comparison table -- same booktabs formatting as
// report-table's inner table, but WITHOUT the "How to report this" purple
// label, because this table is not presenting the computed output of an
// analysis shown in the chapter. Use for informational/organizational
// content: agency comparisons, package listings, method-tradeoff
// comparisons, unit-cost reference lists, conventions across jurisdictions,
// equivalence tables, etc. -- anything that is not itself the reported
// result of a specific R computation in this chapter. Still a captioned,
// numbered figure(kind: table), still picked up by the back matter's
// "List of Tables". The "How to report this" label is reserved exclusively
// for report-table() and must not appear here.
#let ref-table(caption, body) = figure(
  kind: table,
  supplement: [Table],
  body,
  caption: caption,
)

// Booktabs/gt-style academic table engine. NEVER draws internal row rules.
// - `header`: an array of header cells (and, optionally, `table.hline(start:,
//   end:, stroke: 0.6pt)` calls for column-spanner partial rules, plus a
//   second row of sub-headers for spanning-header tables -- see the skill
//   doc / README example for the two-row spanner pattern).
// - `body`: an array of row cells, flattened (NOT nested per-row arrays),
//   e.g. (cellA1, cellA2, cellB1, cellB2, ...) -- exactly as you'd pass
//   directly to Typst's `table(...)`. No `table.hline()` calls belong here.
// - `footer`: optional array of cells for a final summary/note row (e.g. a
//   `table.cell(colspan: N)[...]` note); gets its own rule above it and
//   sits above the final bottom rule. Pass `none` to omit.
#let academic-table(
  columns: auto,
  align: auto,
  header: (),
  body: (),
  footer: none,
) = table(
  columns: columns,
  align: align,
  stroke: none,
  inset: 7pt,
  table.hline(stroke: 1pt),
  table.header(..header),
  table.hline(stroke: 0.6pt),
  ..body,
  ..if footer != none { (table.hline(stroke: 0.6pt), ..footer) } else { () },
  table.hline(stroke: 1pt),
)
