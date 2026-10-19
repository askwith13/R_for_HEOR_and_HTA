= Conventions, Package Versions and Reproducibility Notes

== Typographic conventions

- Inline R code, function names, and package names appear in
  `monospace`: e.g. `heemod::run_model()`, `flexsurv`.
- Standalone code listings are set in full-width monospace blocks
  with syntax-relevant elements distinguishable by weight; output
  shown beneath a listing is marked `#>` per R console convention.
- Mathematical notation follows standard health-economics usage:
  discount rate as $r$, time horizon as $T$, incremental cost as
  $Delta C$, incremental effect as $Delta E$, and the incremental
  cost-effectiveness ratio as $"ICER" = Delta C / Delta E$.
- Callout boxes recur across every methods chapter in three forms:
  *HEOR in practice* (a real-submission-shaped scenario illustrating
  the method just introduced), *Common pitfall* (a mistake that
  recurs often enough in actual agency technical-engagement queries
  to be worth naming explicitly), and *Agency perspective* (what a
  named HTA agency's published guidance or typical reviewer behaviour
  says about the method).

== Package versions

Each chapter's code is developed and checked against the CRAN package
versions current at the time that chapter is drafted; the exact
versions are pinned in that chapter's own `renv.lock` in the companion
repository (§ Companion Website, above) rather than hard-coded into
the printed text, because HEOR-relevant packages — `flexsurv`,
`hesim`, `heemod`, `BCEA`, `netmeta`, `mice`, among others — update
frequently enough that a version number printed in a book is stale
within a year or two. Where a function's behaviour has changed in a
way that would break a book example, the companion repository's
`CHANGES.md` is the authority, not the printed page.

== Reproducibility baseline

Every worked example and case study in this book is built to run
from a clean R session given only: base R, the packages named in
that chapter, and the `renv.lock` for that chapter. No worked example
depends on data, credentials, or infrastructure that a reader cannot
access independently — real patient-level trial data is never used;
synthetic or openly-licensed datasets (Appendix F) stand in throughout,
chosen specifically to reproduce the statistical features (skewness,
censoring, missingness patterns) that make the real-world versions of
these analyses hard.

== A note on country and agency defaults

Where a chapter must choose a concrete worked example — a willingness-
to-pay threshold, a reference case, a named agency's submission
template — this book deliberately rotates among NICE (UK), CADTH
(Canada), PBAC (Australia), and HTAIn (India) rather than defaulting
silently to a single high-income reference case throughout. Chapter
31 lays out the comparison explicitly; earlier chapters that use a
single agency's convention for a worked example say so directly
rather than implying it as the universal default.
