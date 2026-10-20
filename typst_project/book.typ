// R for Health Economics and Outcomes Research (HEOR) and Health Technology Assessment (HTA)
// Main book assembly file — imports front matter, all chapters, back matter.
// Compile with: typst compile book.typ book.pdf
// (Compile a single chapter standalone during drafting via its own .typ file's preview mode.)

#set document(title: "R for HEOR and HTA", author: "Dr Aswath Karunakaran")
#set page(paper: "a4", margin: (x: 2.8cm, y: 3cm), numbering: "i")
#set text(font: "Libertinus Serif", size: 11pt, lang: "en")
#set par(justify: true, leading: 0.65em)
// Chapter and section numbers are typed manually in each heading's text
// ("= Chapter 1. ...", "== 1.1 ..."), so Typst's automatic heading
// counter is switched off everywhere to avoid double numbering
// (e.g. an auto "6.1" prefix glued in front of a manually-typed "2.1").
#set heading(numbering: none)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(1em)
  text(size: 22pt, weight: "bold", it)
  v(1em)
}
#show heading.where(level: 2): it => {
  v(0.8em)
  text(size: 15pt, weight: "bold", it)
  v(0.4em)
}

// ---- Callout boxes used throughout chapters (shared, see common.typ) ----
#import "common.typ": heor-practice, pitfall, agency-note, learning-objectives, report-table, ref-table, academic-table, part-divider, difficult-terminology

// ---- Front matter ----
#include "front_matter/title_page.typ"
#include "front_matter/foreword.typ"
#include "front_matter/preface.typ"
#include "front_matter/companion_website.typ"
#include "front_matter/conventions.typ"
#include "front_matter/abbreviations.typ"

#outline(title: "Table of Contents", indent: auto)
#pagebreak()

// Front matter (Foreword, Preface, etc.) is paginated with roman numerals
// above; the numbered chapters that follow restart at Arabic page 1.
#set page(numbering: "1")
#counter(page).update(1)

// ---- Part I: Foundations ----
#part-divider("I", "Foundations")
#include "chapters/ch01_intro_heor_hta.typ"
#include "chapters/ch02_r_environment.typ"
#include "chapters/ch03_r_essentials.typ"
#include "chapters/ch04_core_concepts.typ"

// ---- Part II: Data for HEOR ----
#part-divider("II", "Data for HEOR")
#include "chapters/ch05_data_sources.typ"
#include "chapters/ch06_slr_support.typ"
#include "chapters/ch07_missing_data.typ"
#include "chapters/ch08_utilities.typ"
#include "chapters/ch09_costs_resource_use.typ"

// ---- Part III: Statistical Methods for Evidence Synthesis and Analysis ----
#part-divider("III", "Statistical Methods for Evidence Synthesis and Analysis")
#include "chapters/ch10_survival_analysis.typ"
#include "chapters/ch11_meta_analysis.typ"
#include "chapters/ch12_itc_nma.typ"
#include "chapters/ch13_population_adjusted.typ"
#include "chapters/ch14_bayesian_methods.typ"
#include "chapters/ch15_rwe_causal_inference.typ"
#include "chapters/ch16_regression_models.typ"

// ---- Part IV: Decision-Analytic Modelling ----
#part-divider("IV", "Decision-Analytic Modelling")
#include "chapters/ch17_decision_modelling.typ"
#include "chapters/ch18_decision_trees.typ"
#include "chapters/ch19_markov_cohort.typ"
#include "chapters/ch20_partitioned_survival.typ"
#include "chapters/ch21_microsimulation.typ"
#include "chapters/ch22_des_dynamic_models.typ"
#include "chapters/ch23_budget_impact.typ"
#include "chapters/ch24_cba_dcea_ecea.typ"

// ---- Part V: Uncertainty, Value of Information and Model Validation ----
#part-divider("V", "Uncertainty, Value of Information and Model Validation")
#include "chapters/ch25_handling_uncertainty.typ"
#include "chapters/ch26_voi.typ"
#include "chapters/ch27_calibration_validation.typ"

// ---- Part VI: Reporting, Communication and Deployment ----
#part-divider("VI", "Reporting, Communication and Deployment")
#include "chapters/ch28_reproducible_reporting.typ"

// ---- Back matter ----
#pagebreak(weak: true)
#heading(level: 1, numbering: none)[List of Figures]
#outline(title: none, target: figure.where(kind: image))

#pagebreak(weak: true)
#heading(level: 1, numbering: none)[List of Tables]
#outline(title: none, target: figure.where(kind: table))
