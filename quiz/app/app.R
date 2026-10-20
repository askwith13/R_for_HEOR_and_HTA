library(shiny)
library(bslib)
library(shinyWidgets)
library(readr)
library(dplyr)

# ---------------------------------------------------------------------------
# Data
# ---------------------------------------------------------------------------

quiz_bank <- read_csv("quiz_bank.csv", show_col_types = FALSE) %>%
  mutate(
    chapter_num = as.integer(chapter_num),
    difficulty  = factor(difficulty, levels = c("Easy", "Medium", "Hard")),
    weight      = case_when(
      difficulty == "Easy"   ~ 1L,
      difficulty == "Medium" ~ 2L,
      difficulty == "Hard"   ~ 3L
    )
  )

all_chapters <- quiz_bank %>%
  distinct(chapter_num, chapter) %>%
  arrange(chapter_num)

chapter_choices <- setNames(all_chapters$chapter_num, all_chapters$chapter)

# ---------------------------------------------------------------------------
# Theming
# ---------------------------------------------------------------------------

difficulty_colors <- c(
  "Easy"   = "#2e7d32",  # green
  "Medium" = "#e8a300",  # yellow/orange
  "Hard"   = "#c62828",  # red
  "Mixed"  = "#1565c0"   # blue
)

badge_colors <- c(
  "Easy"   = "#2e7d32",
  "Medium" = "#e8a300",
  "Hard"   = "#c62828"
)

make_theme <- function(selection) {
  primary <- difficulty_colors[[selection]]
  bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = primary,
    "progress-bar-bg" = primary
  )
}

difficulty_badge <- function(diff) {
  col <- badge_colors[[as.character(diff)]]
  span(
    as.character(diff),
    style = sprintf(
      "background-color:%s; color:white; padding:2px 10px; border-radius:10px; font-size:0.85em; font-weight:600;",
      col
    )
  )
}

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

ui <- fluidPage(
  theme = make_theme("Mixed"),
  uiOutput("theme_swap"),
  titlePanel("R for HEOR and HTA — Quiz"),
  uiOutput("main_ui")
)

# ---------------------------------------------------------------------------
# Server
# ---------------------------------------------------------------------------

server <- function(input, output, session) {

  # ---- reactive state ------------------------------------------------------
  stage <- reactiveVal("setup")  # "setup" | "quiz" | "scorecard"

  quiz_state <- reactiveValues(
    questions      = NULL,   # data frame, one row per question in play (already shuffled rows)
    shuffled_opts  = NULL,   # list, one element per question: data.frame(letter, text, is_correct)
    current_idx    = 1,
    answers        = NULL,   # data frame built up as user answers: question_id, correct (logical), weight
    submitted      = FALSE,
    selected_letter = NULL,
    difficulty_setting = "Mixed"
  )

  # ---- setup screen reactive pool ------------------------------------------

  filtered_pool <- reactive({
    req(input$chapters)
    df <- quiz_bank %>% filter(chapter_num %in% as.integer(input$chapters))
    if (!is.null(input$difficulty) && input$difficulty != "Mixed") {
      df <- df %>% filter(difficulty == input$difficulty)
    }
    df
  })

  observeEvent(input$select_all_chapters, {
    updateCheckboxGroupInput(session, "chapters", selected = as.character(all_chapters$chapter_num))
  })
  observeEvent(input$clear_all_chapters, {
    updateCheckboxGroupInput(session, "chapters", selected = character(0))
  })

  observe({
    pool_size <- nrow(filtered_pool())
    default_n <- min(10, max(pool_size, 1))
    updateSliderInput(session, "n_questions", max = max(pool_size, 1), value = min(default_n, max(pool_size,1)))
  })

  output$pool_info <- renderUI({
    pool_size <- nrow(filtered_pool())
    if (pool_size == 0) {
      div(style = "color:#c62828; font-weight:600;",
          "No questions match this chapter/difficulty combination. Choose different settings.")
    } else {
      div(style = "color:#555;", sprintf("%d question(s) available with current selection.", pool_size))
    }
  })

  output$theme_swap <- renderUI({
    session$setCurrentTheme(make_theme(quiz_state$difficulty_setting))
    NULL
  })

  # ---- main UI switcher ------------------------------------------------------

  output$main_ui <- renderUI({
    switch(stage(),
      "setup"     = setup_ui(),
      "quiz"      = quiz_ui(),
      "scorecard" = scorecard_ui()
    )
  })

  setup_ui <- function() {
    tagList(
      fluidRow(
        column(6,
          h4("1. Choose chapters"),
          div(
            actionButton("select_all_chapters", "Select All", class = "btn-sm btn-outline-primary"),
            actionButton("clear_all_chapters", "Clear All", class = "btn-sm btn-outline-secondary"),
            style = "margin-bottom:10px;"
          ),
          div(style = "max-height:350px; overflow-y:auto; border:1px solid #ddd; padding:10px; border-radius:6px;",
            checkboxGroupInput("chapters", NULL, choices = chapter_choices, selected = as.character(all_chapters$chapter_num))
          )
        ),
        column(6,
          h4("2. Choose difficulty"),
          radioButtons("difficulty", NULL,
                       choices = c("Easy", "Medium", "Hard", "Mixed"),
                       selected = "Mixed"),
          h4("3. Number of questions"),
          sliderInput("n_questions", NULL, min = 1, max = 426, value = 10, step = 1),
          uiOutput("pool_info"),
          br(),
          actionButton("start_quiz", "Start Quiz", class = "btn-primary btn-lg")
        )
      )
    )
  }

  observeEvent(input$start_quiz, {
    pool <- filtered_pool()
    req(nrow(pool) > 0)
    n <- min(input$n_questions, nrow(pool))

    chosen <- pool %>% slice_sample(n = n)

    # pre-shuffle options per question, tracking correct letter against new position
    shuffled <- lapply(seq_len(nrow(chosen)), function(i) {
      row <- chosen[i, ]
      opts <- data.frame(
        letter = c("A", "B", "C", "D"),
        text = c(row$option_a, row$option_b, row$option_c, row$option_d),
        stringsAsFactors = FALSE
      )
      opts$is_correct <- opts$letter == row$correct_answer
      opts <- opts[sample(nrow(opts)), ]
      opts$display_letter <- c("A", "B", "C", "D")
      opts
    })

    quiz_state$questions <- chosen
    quiz_state$shuffled_opts <- shuffled
    quiz_state$current_idx <- 1
    quiz_state$answers <- data.frame(
      question_id = character(0), correct = logical(0), weight = integer(0),
      difficulty = character(0), chapter = character(0), stringsAsFactors = FALSE
    )
    quiz_state$submitted <- FALSE
    quiz_state$selected_letter <- NULL
    quiz_state$difficulty_setting <- input$difficulty

    stage("quiz")
  })

  # ---- quiz screen ------------------------------------------------------------

  current_question <- reactive({
    req(quiz_state$questions)
    quiz_state$questions[quiz_state$current_idx, ]
  })

  current_opts <- reactive({
    req(quiz_state$shuffled_opts)
    quiz_state$shuffled_opts[[quiz_state$current_idx]]
  })

  quiz_ui <- function() {
    q <- current_question()
    opts <- current_opts()
    total_n <- nrow(quiz_state$questions)
    idx <- quiz_state$current_idx

    running_score <- sum(quiz_state$answers$weight[quiz_state$answers$correct])
    running_max <- sum(quiz_state$answers$weight)

    tagList(
      fluidRow(
        column(9,
          progressBar(id = "quiz_progress", value = idx - 1, total = total_n,
                      title = sprintf("Question %d of %d", idx, total_n),
                      status = "info", display_pct = TRUE)
        ),
        column(3, div(style="text-align:right; font-weight:600;",
                       sprintf("Score so far: %d / %d", running_score, running_max)))
      ),
      br(),
      div(
        difficulty_badge(q$difficulty),
        span(style = "margin-left:10px; font-weight:600;", q$chapter)
      ),
      br(),
      if (q$type == "Image" && !is.na(q$image_filepath) && nchar(q$image_filepath) > 0) {
        div(style="text-align:center; margin-bottom:15px;",
            tags$img(src = basename(q$image_filepath), style = "max-width:100%; max-height:400px; border:1px solid #ddd; border-radius:6px;"))
      },
      h4(q$question),
      br(),
      uiOutput("option_buttons"),
      br(),
      uiOutput("reveal_block"),
      br(),
      uiOutput("quiz_nav_buttons")
    )
  }

  output$option_buttons <- renderUI({
    opts <- current_opts()
    submitted <- quiz_state$submitted

    lapply(seq_len(nrow(opts)), function(i) {
      row <- opts[i, ]
      btn_id <- paste0("opt_", row$display_letter)

      style <- "width:100%; text-align:left; margin-bottom:8px; white-space:normal;"
      if (submitted) {
        if (row$is_correct) {
          style <- paste0(style, "background-color:#c8e6c9; border-color:#2e7d32; color:#1b5e20;")
        } else if (!is.null(quiz_state$selected_letter) && row$display_letter == quiz_state$selected_letter) {
          style <- paste0(style, "background-color:#ffcdd2; border-color:#c62828; color:#b71c1c;")
        }
      } else if (!is.null(quiz_state$selected_letter) && row$display_letter == quiz_state$selected_letter) {
        style <- paste0(style, "background-color:#e3f2fd; border-color:#1565c0;")
      }

      actionButton(btn_id, label = paste0(row$display_letter, ") ", row$text),
                   class = "btn btn-outline-secondary", style = style)
    })
  })

  observe({
    opts <- current_opts()
    for (letter in opts$display_letter) {
      local({
        l <- letter
        btn_id <- paste0("opt_", l)
        observeEvent(input[[btn_id]], {
          if (!quiz_state$submitted) {
            quiz_state$selected_letter <- l
          }
        }, ignoreInit = TRUE)
      })
    }
  })

  output$reveal_block <- renderUI({
    if (!quiz_state$submitted) return(NULL)
    q <- current_question()
    div(style = "background:#f5f5f5; border-left:4px solid #1565c0; padding:12px; border-radius:4px;",
        tags$b("Explanation: "), q$explanation,
        br(), tags$small(style="color:#777;", q$chapter)
    )
  })

  output$quiz_nav_buttons <- renderUI({
    if (!quiz_state$submitted) {
      btn <- actionButton("submit_answer", "Submit Answer", class = "btn-primary")
      if (is.null(quiz_state$selected_letter)) {
        btn <- htmltools::tagAppendAttributes(btn, disabled = "disabled")
      }
      btn
    } else {
      is_last <- quiz_state$current_idx >= nrow(quiz_state$questions)
      actionButton("next_question", if (is_last) "See Scorecard" else "Next Question", class = "btn-primary")
    }
  })

  observeEvent(input$submit_answer, {
    req(quiz_state$selected_letter)
    q <- current_question()
    opts <- current_opts()
    chosen_row <- opts[opts$display_letter == quiz_state$selected_letter, ]
    is_correct <- isTRUE(chosen_row$is_correct)

    quiz_state$answers <- rbind(
      quiz_state$answers,
      data.frame(
        question_id = q$question_id,
        correct = is_correct,
        weight = q$weight,
        difficulty = as.character(q$difficulty),
        chapter = q$chapter,
        stringsAsFactors = FALSE
      )
    )
    quiz_state$submitted <- TRUE
  })

  observeEvent(input$next_question, {
    if (quiz_state$current_idx >= nrow(quiz_state$questions)) {
      stage("scorecard")
    } else {
      quiz_state$current_idx <- quiz_state$current_idx + 1
      quiz_state$submitted <- FALSE
      quiz_state$selected_letter <- NULL
    }
  })

  # ---- scorecard ------------------------------------------------------------

  scorecard_ui <- function() {
    ans <- quiz_state$answers
    total_correct <- sum(ans$correct)
    total_n <- nrow(ans)
    weighted_score <- sum(ans$weight[ans$correct])
    weighted_max <- sum(ans$weight)
    pct <- round(100 * weighted_score / weighted_max, 1)

    tagList(
      h3("Scorecard"),
      div(style = "font-size:1.4em; font-weight:700; margin-bottom:10px;",
          sprintf("%d / %d weighted points (%s%%)", weighted_score, weighted_max, pct)),
      div(sprintf("Raw: %d correct out of %d questions", total_correct, total_n)),
      br(),
      h4("By difficulty"),
      tableOutput("scorecard_by_diff"),
      h4("By chapter"),
      tableOutput("scorecard_by_chapter"),
      br(),
      actionButton("restart_quiz", "Restart", class = "btn-primary btn-lg")
    )
  }

  output$scorecard_by_diff <- renderTable({
    req(quiz_state$answers)
    quiz_state$answers %>%
      group_by(Difficulty = difficulty) %>%
      summarise(
        Asked = n(),
        Correct = sum(correct),
        `Weighted Score` = sum(weight[correct]),
        `Weighted Max` = sum(weight),
        .groups = "drop"
      )
  })

  output$scorecard_by_chapter <- renderTable({
    req(quiz_state$answers)
    quiz_state$answers %>%
      group_by(Chapter = chapter) %>%
      summarise(Asked = n(), Correct = sum(correct), .groups = "drop") %>%
      arrange(Chapter)
  })

  observeEvent(input$restart_quiz, {
    stage("setup")
  })

}

shinyApp(ui, server)
