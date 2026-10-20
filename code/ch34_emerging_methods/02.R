# Extracted from ch34_emerging_methods.typ, lines 94-114
# Section: == 34.2 Large language models in HEOR workflows (SLR, extraction, coding assistance) and their validation
# Chapter: 34

# Illustrative prompt-template structure for LLM-assisted PICOS extraction
# (not executed -- shown to illustrate the expected input/output contract)

extraction_prompt <- "
From the attached trial report text, extract the following fields
into a single-row data frame with these exact column names:
  study_id, population, intervention, comparator,
  primary_outcome, primary_outcome_value, primary_outcome_ci_lower,
  primary_outcome_ci_upper, sample_size_total

Rules:
- If a field cannot be found in the text, return NA for that field --
  never estimate, infer, or fabricate a value.
- Quote the exact source sentence used for each numeric field
  alongside the extracted value.
"
# A human reviewer then checks every extracted value and its quoted
# source sentence against the original PDF before the row enters
# the analysis dataset.
