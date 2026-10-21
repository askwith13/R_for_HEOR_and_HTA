# Quiz Bank — R for HEOR and HTA

Machine-readable quiz question bank for building a Shiny quiz application.

## Files

- **`quiz_bank.csv`** — the file to load into the app. 661 rows, one per question, covering all 35 book chapters.
- `quiz_bank_master.md` — human-readable assembled markdown version (same content, for review/editing).
- `quiz_ch01-03.md` ... `quiz_ch34-35.md` — the original per-batch markdown source files.
- `images/` — 79 PNG images for all image-based questions, named `Q<id>.png` matching `image_filepath` in the CSV.
- `app/` — the runnable Shiny quiz app (`app.R`), with its own synced copy of `quiz_bank.csv` and `www/` image folder.

## CSV columns

| Column | Description |
|---|---|
| `question_id` | Stable ID, e.g. `Q001` |
| `chapter_num` | Integer 1–35 |
| `chapter` | `"Chapter N: Title"` |
| `difficulty` | `Easy` / `Medium` / `Hard` |
| `type` | `MCQ` or `Image` |
| `question` | Question text. For `Image` type, this is the question only — the image itself should be displayed above/alongside it from `image_filepath`. |
| `option_a` … `option_d` | The four answer options, in fixed A–D order (shuffle at display time in the app, not in this file) |
| `correct_answer` | Single letter `A`–`D` |
| `explanation` | 1–3 sentence explanation, grounded in the book's actual text |
| `image_filepath` | Relative path from the `quiz/` folder (e.g. `images/Q013.png`), empty for MCQ rows |

## Stats

- 661 questions total, covering all 35 chapters of the finished book
- 162 Easy / 335 Medium / 164 Hard
- 582 standard MCQ / 79 image-based

## Image provenance

- A majority of the 79 images are newly built for this quiz (folder-tree diagrams, missing-data visualizations, decision trees, Markov/cascade diagrams, reference tables matching the book's own verified numbers, survival-curve/cure-model plots, etc.), each visually verified before inclusion; a smaller number are reused directly from the book's own rendered figures (`typst_project/images/`) — same chart, same underlying data as the chapter.

## Appendix G

This quiz bank formally serves the role the Table of Contents originally
assigned to Appendix G ("Solutions to exercises"), per the author's
decision that no formal end-of-chapter exercises would be added to the
book — see `../typst_project/back_matter/` for the back matter this
replaces that appendix letter in.

## Known limitation

A handful of image questions (e.g. Q118, Q119, Q191, Q327) use **illustrative simulated data** to match the shape/pattern described in the book's own figure (since the book itself doesn't always give every exact number needed to reproduce a chart pixel-for-pixel) — the correct answer and explanation are grounded in the book's stated facts/numbers regardless, only the chart's plotted data points are synthetic where the book didn't specify them exactly.
