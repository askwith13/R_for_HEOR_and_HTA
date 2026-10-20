# R for HEOR and HTA — Quiz App Specification

**Status:** Approved, build in progress.
**Data source:** `quiz/quiz_bank.csv` (426 questions, 27 chapters) + `quiz/images/` (55 images).
**Framework:** R Shiny (`bslib` for theming, `shinyWidgets` for the progress bar).

---

## 1. Data

CSV columns (already present, no changes needed):

| Column | Use |
|---|---|
| `question_id` | stable ID |
| `chapter_num` | integer 1–27, used for chapter filter |
| `chapter` | display string "Chapter N: Title" |
| `difficulty` | Easy / Medium / Hard |
| `type` | MCQ / Image |
| `question` | question text |
| `option_a`–`option_d` | fixed A–D order in the file; **shuffled at display time**, not in the file |
| `correct_answer` | letter A–D, tracked against the **original** option text so shuffling doesn't break grading |
| `explanation` | shown after every answer |
| `image_filepath` | relative to `quiz/`, empty for MCQ rows |

## 2. Setup screen

Controls, in this order:

1. **Chapter selection** — checkbox group, one box per chapter (`"1: Introduction to HEOR and HTA"` … `"27: Model Calibration, Validation and Quality Assurance"`), plus a **"Select All / Clear All"** toggle button. At least one chapter must be selected to proceed.
2. **Difficulty selection** — single-select radio: `Easy` / `Medium` / `Hard` / `Mixed`. Drives both question filtering and the app's color theme (section 5).
3. **Number of questions** — numeric slider/input. **Max = size of the filtered pool** (selected chapters × selected difficulty), recalculated reactively every time chapter or difficulty selection changes. Min = 1. Default = min(10, pool size).
4. **Start Quiz** button — disabled if pool size is 0 (e.g. a chapter/difficulty combination with no questions), with an inline warning message in that case.

## 3. Quiz screen

- **Progress bar** at the top: "Question X of N" with a visual bar (`shinyWidgets::progressBar`), updates after every answer.
- **Chapter number** shown above each question (e.g. "Chapter 14: Bayesian Methods for HEOR").
- **Difficulty badge** shown next to the chapter (colored per section 5).
- **Question text**, rendered image above the question text if `type == "Image"`.
- **Four options**, order **shuffled per question per attempt** (re-shuffled if the user restarts), displayed as radio buttons / action-styled buttons.
- **Submit Answer** button — locks the choice, immediately reveals:
  - Each option re-rendered with green background on the correct option; red background on the user's choice if it was wrong.
  - `**Explanation:**` text block.
  - The chapter number is already visible above the question (not repeated in the reveal, just stays on screen).
- **Next Question** button — appears only after submission, advances to the next question (or to the scorecard if it was the last one).
- No timer anywhere in the flow.

## 4. Scoring

- **Weights:** Easy = 1, Medium = 2, Hard = 3.
- **Per-question score:** weight if correct, 0 if incorrect.
- **Running score** shown continuously (small widget, e.g. top-right): `current weighted score / max possible weighted score so far`.
- **Final scorecard** (after the last question):
  - Total weighted score / total possible weighted score, and as a percentage.
  - Raw counts: X correct / N questions.
  - Breakdown table: rows = difficulty (Easy/Medium/Hard present in this attempt), columns = questions asked, correct, weighted score, weighted max.
  - Breakdown table: rows = chapter (only chapters actually drawn from in this attempt), columns = questions asked, correct.
  - **"Restart"** button returns to the setup screen with selections preserved (so the user can easily re-run with a tweak).

## 5. Color theming by difficulty selection

The app's primary theme color changes based on the **difficulty setting chosen at setup** (not per-question — the whole session uses one theme once the quiz starts):

| Selection | Theme color |
|---|---|
| Easy | Green |
| Medium | Yellow/Orange |
| Hard | Red |
| Mixed | Blue |

Applied via a `bslib::bs_theme()` swapped reactively (primary color, progress bar color, button accent color). Per-question difficulty badges (shown during Mixed mode, since individual questions can differ from the session-level selection) use the same color mapping so a question's own difficulty is always visually legible even in Mixed mode.

## 6. Non-requirements (explicitly out of scope for this build)

- No timer.
- No user accounts / persistent history across sessions (each run is self-contained; can be added later).
- No negative marking.
- No multi-select or free-text question types (all 426 current questions are single-answer MCQ/Image).

## 7. File layout

```
quiz/
├── quiz_bank.csv
├── images/*.png
├── README.md                 <- existing CSV documentation
├── SPEC.md                   <- this file
└── app/
    ├── app.R                 <- Shiny app (ui + server + global data load)
    └── www/                  <- symlink or copy of images/ for Shiny static serving
```
