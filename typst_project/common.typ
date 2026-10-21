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

// Difficult Terminology box: inserted at the FIRST appearance of a
// technical term (statistics, mathematics, epidemiology, R/programming,
// or health-economics-specific) that is used in the surrounding prose
// without being explained -- built Oct 2026 following a book-wide
// terminology audit that found 70 such gaps across Chapters 1-21 (see
// progress/terminology_audit.md). Distinct teal/cyan styling so it reads
// differently from heor-practice (blue), pitfall (orange), agency-note
// (green), and report-table (purple) at a glance.
//
// `term`: the term/phrase being defined, shown as the box's bold title.
// `body`: the explanation -- should give a real plain-language
//   definition pitched at the book's stated reader (SQL basic/rusty,
//   medical/public-health background, not deeply technical in stats),
//   and an analogy or worked example WHEREVER one genuinely helps
//   (dense/abstract concepts like a hazard function, conjugate
//   posterior, or exchangeability benefit strongly from one; a
//   straightforward definitional term like "non-inferiority trial" may
//   not need one -- use judgement, don't force an analogy that adds
//   nothing). Keep to a tight paragraph or two, not a full subsection.
#let difficult-terminology(term, body) = block(
  fill: rgb("#ecfeff"), stroke: (left: 2pt + rgb("#0e7490")),
  inset: 10pt, radius: 3pt, width: 100%,
)[*Difficult terminology: #term.* #body]

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

// Part divider: a full-page break introducing one of the book's 8 Parts
// (Foundations, Data for HEOR, Statistical Methods, etc.), per the
// structure already stated in the Table of Contents and the Preface's
// "How to use this book" section -- which, until this was added, were
// the ONLY two places a reader could see the Part structure at all (the
// book.typ include list only had `// ---- Part N ----` Typst COMMENTS,
// invisible in the compiled PDF, so Parts appeared in neither the TOC
// nor between chapters -- fixed Oct 2026).
//
// Produces a real heading(level: 1, outlined: true, bookmarked: true),
// so it: (a) triggers the existing level-1 show rule's page break +
// large bold text, giving a genuine full-page divider in the body;
// (b) appears as its own line in the front matter's #outline() Table
// of Contents, in document order immediately before the chapters it
// introduces -- Parts and Chapters are siblings at heading level 1
// (chapters are NOT renumbered to level 2, since that would collide
// with every chapter's existing level-2 `== N.M ...` section headings
// and require touching all 20+ chapter files); (c) gets a PDF bookmark
// entry, so a reader's PDF-viewer sidebar also shows Part breaks.
//
// `roman`: the Part's roman numeral as a string, e.g. "I", "IV".
// `title`: the Part's title exactly as in the Table of Contents, e.g.
//   "Foundations", "Decision-Analytic Modelling".
//
// Styled distinctly from a chapter heading (which also lives at level
// 1) so a reader can tell a Part-divider page from a Chapter-opening
// page at a glance: centered, a small "PART" label above the roman
// numeral/title, and extra vertical space -- book.typ's existing
// level-1 show rule still fires (page break + bold text), this just
// adds Part-specific styling around that.
#let part-divider(roman, title) = heading(
  level: 1, outlined: true, bookmarked: true, numbering: none,
)[
  #align(center)[
    #text(size: 13pt, tracking: 2pt, fill: rgb("#6b7280"))[PART #roman]
    #v(0.3em)
    #text(size: 26pt, weight: "bold")[#title]
  ]
]

// Appendix E (Glossary) entry: term in bold, a short chapter-source tag,
// then the distilled 1-3 sentence definition. Deliberately lighter-weight
// than the four callout boxes (no colored border/fill) since a glossary
// page needs to scan quickly, not draw the eye to any one entry.
#let glossary-entry(term, definition, chapter) = block(
  above: 10pt, below: 4pt, breakable: true,
)[
  #text(weight: "bold")[#term] #text(size: 8pt, fill: rgb("#6b7280"))[(Ch. #chapter)] \
  #definition
]

// Small inline "try it live" box pointing to one specific companion Shiny
// app, placed right after the chapter section whose topic it illustrates
// (NOT a full-width callout like heor-practice/pitfall/agency-note --
// deliberately narrower and lighter so it reads as a pointer, not another
// explanatory box competing for the reader's attention).
//
// `slug`: the app's folder name under shiny_apps/, e.g.
//   "icer_quadrant_net_benefit_explorer" (no trailing slash).
// `blurb`: a single short sentence on what dragging the app's sliders
//   shows -- not a restatement of the section's prose, the SPECIFIC
//   live behaviour a reader gets by running it.
#let shiny-app-box(slug, blurb) = block(
  fill: rgb("#fdf4ff"), stroke: (left: 2pt + rgb("#9333ea")),
  inset: 8pt, radius: 3pt, width: 100%, above: 8pt, below: 8pt,
)[
  #text(size: 9.5pt)[
    #text(weight: "bold", fill: rgb("#7e22ce"))[Try it live:]
    #link("https://github.com/askwith13/R_for_HEOR_and_HTA/tree/main/shiny_apps/" + slug)[shiny\_apps/#slug]
    -- #blurb
  ]
]
