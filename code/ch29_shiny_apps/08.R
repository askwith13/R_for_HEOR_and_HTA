# Extracted from ch29_shiny_apps.typ, lines 326-346
# Section: == 29.5 Downloadable reports and audit trails
# Chapter: 29

output$download_report <- downloadHandler(
  filename = function() {
    paste0("tb_model_report_", Sys.Date(), ".docx")
  },
  content = function(file) {
    quarto::quarto_render(
      input = "report.qmd",
      output_file = basename(file),
      execute_params = list(
        wtp_threshold  = input$wtp,
        discount_rate  = input$discount_rate,
        n_psa          = input$n_psa,
        scenario_label = input$scenario_name
      )
    )
    file.copy(file.path(dirname("report.qmd"), basename(file)), file,
              overwrite = TRUE)
  }
)
