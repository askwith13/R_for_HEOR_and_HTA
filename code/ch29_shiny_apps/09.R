# Extracted from ch29_shiny_apps.typ, lines 360-377
# Section: == 29.5 Downloadable reports and audit trails
# Chapter: 29

log_event <- function(session_id, event, detail) {
  entry <- data.frame(
    timestamp  = Sys.time(),
    session_id = session_id,
    event      = event,
    detail     = detail
  )
  write.table(entry, "audit_log.csv", sep = ",", append = TRUE,
              col.names = !file.exists("audit_log.csv"), row.names = FALSE)
}

observeEvent(input$run_psa, {
  log_event(session$token, "run_psa",
            sprintf("n_psa=%s; wtp=%s; discount=%s",
                    input$n_psa, input$wtp, input$discount_rate))
})
