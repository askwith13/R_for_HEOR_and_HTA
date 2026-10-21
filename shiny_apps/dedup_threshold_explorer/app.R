library(shiny)
library(ggplot2)
library(dplyr)

# Dedup Threshold Explorer
# Companion to Chapter 6, SS6.2: drag a similarity-threshold slider
# (normalised Optimal String Alignment distance cutoff) over a
# simulated reference set and watch duplicate-flag counts change live;
# a toggle switches exact-title vs fuzzy matching.

ui <- fluidPage(
  titlePanel("Dedup Threshold Explorer"),
  p("Companion app for Chapter 6, \u00a76.2 (Systematic Literature Review ",
    "Support in R). A simulated set of 200 reference titles (from a ",
    "literature search) contains a mix of true duplicates (same paper, ",
    "slightly different formatting/typos/abbreviations from different ",
    "databases) and genuinely distinct titles. Drag a string-similarity ",
    "threshold and watch how many duplicate PAIRS get flagged -- too ",
    "loose a threshold misses true duplicates, too tight flags distinct ",
    "papers as duplicates."),
  sidebarLayout(
    sidebarPanel(
      radioButtons("match_type", "Matching method",
                   choices = c("Exact title match" = "exact", "Fuzzy (OSA string distance)" = "fuzzy"),
                   selected = "fuzzy"),
      sliderInput("similarity_threshold", "Fuzzy match: max normalised edit distance (0 = exact, 1 = totally different)",
                  0, 0.5, 0.08, step = 0.01)
    ),
    mainPanel(
      plotOutput("dedupPlot", height = "350px"),
      verbatimTextOutput("dedupOut"),
      tableOutput("flaggedPairsTable"),
      tags$div(style = "background-color:#eef3fa; border-left:4px solid #2166ac; padding:10px 15px; margin:12px 0;",
        tags$strong("What you're seeing: "), textOutput("interpretation", inline = TRUE)),
      tags$div(style = "background-color:#fdf2f2; border-left:4px solid #d6604d; padding:10px 15px; margin:12px 0;",
        tags$strong("Pitfall: "),
        "Exact-title matching alone systematically UNDER-counts duplicates in a real multi-",
        "database literature search, because the same paper is indexed with different ",
        "capitalisation, punctuation, subtitle inclusion, or minor OCR/typo differences across ",
        "databases -- it will miss true duplicates that fuzzy matching catches. But fuzzy matching ",
        "pushed too loose (a high similarity threshold) starts flagging genuinely DIFFERENT papers ",
        "with merely similar titles (e.g. two different trials of the same drug class) as ",
        "duplicates, which would wrongly exclude a distinct paper from the review.")
    )
  )
)

server <- function(input, output, session) {

  reference_set <- reactive({
    set.seed(7)
    base_titles <- c(
      "Cost-effectiveness of tuberculosis treatment in low-income settings",
      "A randomized controlled trial of direct observed therapy for TB",
      "Health-related quality of life in patients with chronic kidney disease",
      "Economic burden of diabetes mellitus in South Asia",
      "Systematic review of HIV pre-exposure prophylaxis cost-effectiveness",
      "Budget impact analysis of a new long-acting injectable antipsychotic",
      "Real-world evidence for biologic therapies in rheumatoid arthritis",
      "Markov modelling approaches in oncology health technology assessment",
      "Patient-reported outcomes following total knee replacement surgery",
      "Network meta-analysis of antihypertensive drug classes"
    )
    # Create duplicate variants with realistic formatting differences
    variants <- c(
      "Cost effectiveness of tuberculosis treatment in low income settings",
      "A Randomized Controlled Trial of Direct Observed Therapy for TB.",
      "Health related quality of life in patients with chronic kidney disease",
      "Economic burden of diabetes mellitus in South-Asia",
      "A systematic review of HIV pre-exposure prophylaxis cost effectiveness"
    )
    distinct_titles <- c(
      "Cost-effectiveness of malaria treatment in low-income settings",
      "A randomized controlled trial of directly observed therapy for malaria",
      "Health-related quality of life in patients with chronic liver disease",
      "Economic burden of hypertension in South Asia",
      "Systematic review of HBV pre-exposure prophylaxis cost-effectiveness"
    )
    filler_titles <- paste("Study of clinical outcomes in condition", LETTERS[1:5], 1:5)

    # Give each "unrelated" filler a genuinely distinct subject so their
    # pairwise edit distance reflects real dissimilarity, not just a
    # changing index number (e.g. "paper number 1" vs "paper number 2"
    # would otherwise look nearly identical by edit distance)
    unrelated_subjects <- c(
      "wound healing", "sleep apnea", "vaccine hesitancy", "stroke rehabilitation",
      "antibiotic resistance", "maternal mortality", "obesity prevention",
      "palliative care", "genomic sequencing", "telemedicine adoption",
      "surgical site infection", "nutritional supplementation", "opioid dependence",
      "cognitive decline", "air pollution exposure", "occupational injury",
      "organ transplantation", "neonatal intensive care", "physical therapy outcomes",
      "dental caries prevalence"
    )
    unrelated_titles <- sapply(seq_len(200 - 25), function(i) {
      subj <- unrelated_subjects[((i - 1) %% length(unrelated_subjects)) + 1]
      sprintf("A cohort study of %s in adult populations, variant %d", subj, i)
    })

    all_titles <- c(base_titles, variants, distinct_titles, filler_titles, unrelated_titles)
    data.frame(id = seq_along(all_titles), title = all_titles,
               true_duplicate_of = c(rep(NA, 10), 1:5, rep(NA, 10), rep(NA, 200 - 25)))
  })

  dedup_result <- reactive({
    df <- reference_set()
    n <- nrow(df)
    titles <- tolower(trimws(df$title))

    if (input$match_type == "exact") {
      dup_pairs <- which(duplicated(titles) | duplicated(titles, fromLast = TRUE))
    } else {
      dist_matrix <- adist(titles)
      max_len <- outer(nchar(titles), nchar(titles), pmax)
      norm_dist <- dist_matrix / max_len
      diag(norm_dist) <- Inf
      flagged_pairs <- which(norm_dist <= input$similarity_threshold, arr.ind = TRUE)
      flagged_pairs <- flagged_pairs[flagged_pairs[, 1] < flagged_pairs[, 2], , drop = FALSE]
      dup_pairs <- unique(c(flagged_pairs[, 1], flagged_pairs[, 2]))
    }

    list(n_flagged_records = length(dup_pairs),
         flagged_pairs = if (input$match_type == "fuzzy") flagged_pairs else matrix(nrow = 0, ncol = 2),
         titles = df$title)
  })

  output$dedupPlot <- renderPlot({
    r <- dedup_result()
    df <- data.frame(category = c("Flagged as potential duplicate", "Not flagged"),
                      count = c(r$n_flagged_records, 200 - r$n_flagged_records))
    ggplot(df, aes(x = category, y = count, fill = category)) +
      geom_col() +
      geom_text(aes(label = count), vjust = -0.3, size = 5) +
      labs(x = NULL, y = "Record count", title = "Deduplication flag counts (200 references)") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "none")
  })

  output$dedupOut <- renderPrint({
    r <- dedup_result()
    cat(sprintf("Method: %s\n", if (input$match_type == "exact") "Exact match" else sprintf("Fuzzy match (threshold = %.2f)", input$similarity_threshold)))
    cat(sprintf("Records flagged as potential duplicates: %d of 200\n", r$n_flagged_records))
    cat(sprintf("Known true duplicate pairs in this simulated set: 5\n"))
  })

  output$flaggedPairsTable <- renderTable({
    r <- dedup_result()
    if (nrow(r$flagged_pairs) == 0) return(data.frame(Note = "No fuzzy pairs flagged at this threshold (or exact-match mode selected)."))
    pairs_df <- data.frame(
      title_1 = r$titles[r$flagged_pairs[, 1]],
      title_2 = r$titles[r$flagged_pairs[, 2]]
    )
    head(pairs_df, 10)
  })

  output$interpretation <- renderText({
    r <- dedup_result()
    df <- reference_set()
    # Check how many of the 5 known true-duplicate pairs were actually caught
    true_dup_ids <- 1:5
    true_dup_variant_ids <- 11:15
    caught_true_dups <- if (input$match_type == "fuzzy" && nrow(r$flagged_pairs) > 0) {
      sum(sapply(seq_along(true_dup_ids), function(i) {
        any((r$flagged_pairs[, 1] == true_dup_ids[i] & r$flagged_pairs[, 2] == true_dup_variant_ids[i]) |
            (r$flagged_pairs[, 2] == true_dup_ids[i] & r$flagged_pairs[, 1] == true_dup_variant_ids[i]))
      }))
    } else if (input$match_type == "exact") {
      0 # none of the 5 variants are byte-for-byte identical to their originals
    } else 0

    sprintf(paste0("With %s: %d of 200 records flagged. Of the 5 KNOWN true-duplicate pairs ",
                   "deliberately built into this simulated reference set (same paper, different ",
                   "database formatting), %d/5 were correctly caught at this setting. %s"),
            if (input$match_type == "exact") "exact matching" else sprintf("a fuzzy threshold of %.2f", input$similarity_threshold),
            r$n_flagged_records, caught_true_dups,
            if (input$match_type == "exact") "Exact matching catches ZERO of these, since none are byte-for-byte identical -- this illustrates why exact-only deduplication under-counts true duplicates in real multi-database searches." else "")
  })
}

shinyApp(ui, server)
