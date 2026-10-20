# Quiz Bank — R for HEOR and HTA

Machine-readable quiz question bank for building a Shiny quiz application.

## Files

- **`quiz_bank.csv`** — the file to load into the app. 426 rows, one per question.
- `quiz_bank_master.md` — human-readable assembled markdown version (same content, for review/editing).
- `quiz_ch01-03.md` ... `quiz_ch25-27.md` — the original per-batch markdown source files.
- `images/` — 55 PNG images for all image-based questions, named `Q<id>.png` matching `image_filepath` in the CSV.

## CSV columns

| Column | Description |
|---|---|
| `question_id` | Stable ID, e.g. `Q001` |
| `chapter_num` | Integer 1–27 |
| `chapter` | `"Chapter N: Title"` |
| `difficulty` | `Easy` / `Medium` / `Hard` |
| `type` | `MCQ` or `Image` |
| `question` | Question text. For `Image` type, this is the question only — the image itself should be displayed above/alongside it from `image_filepath`. |
| `option_a` … `option_d` | The four answer options, in fixed A–D order (shuffle at display time in the app, not in this file) |
| `correct_answer` | Single letter `A`–`D` |
| `explanation` | 1–3 sentence explanation, grounded in the book's actual text |
| `image_filepath` | Relative path from the `quiz/` folder (e.g. `images/Q013.png`), empty for MCQ rows |

## Stats

- 426 questions total (27 chapters, 13–23 questions each)
- 90 Easy / 218 Medium / 118 Hard
- 371 standard MCQ / 55 image-based

## Image provenance

- 30 of the 55 images are reused directly from the book's own rendered figures (`typst_project/images/`) — same chart, same underlying data as the chapter.
- 25 are newly built for this quiz (folder-tree diagram, missing-data visualizations, decision tree, M/M/1 queue diagram, Markov state diagram, several reference tables, etc.), each visually verified before inclusion.

## Known limitation

A handful of image questions (e.g. Q118, Q119, Q191, Q327) use **illustrative simulated data** to match the shape/pattern described in the book's own figure (since the book itself doesn't always give every exact number needed to reproduce a chart pixel-for-pixel) — the correct answer and explanation are grounded in the book's stated facts/numbers regardless, only the chart's plotted data points are synthetic where the book didn't specify them exactly.
