#--------------------------------------------------------------------
### engine ###
#--------------------------------------------------------------------
#' Report Engine: Dummy Model Summary Report
#'
#' Combines selected reportelements into a structured model summary report.
#'
#' **Input:**
#' - `reportelements`: A named list of precomputed reportelement outputs.
#' - `params`: A list containing the alias mapping of required elements.
#'
#' @param reportelements Named list of available reportelement outputs.
#' @param params List of reportelement aliases grouped by section.
#'
#' @return A standardized report list.
#' @export
engine_report_modelsummary <- function(reportelements, params) {
  
  mse_text <- reportelements_results[[params$mse_text]]
  gender_plot <- reportelements[[params$gender_box]]
  age_plot <- reportelements[[params$age_box]]
  metrics <- reportelements[[params$metrics_table]]
  
  sections <- list(
    list(
      heading = "MSE",
      content = list(mse_text)
    ),
    list(
      heading = "Visualisierung",
      content = list(gender_plot, age_plot)
    ),
    list(
      heading = "Metriken",
      content = list(metrics)
    )
  )
  
  return(sections)
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### wrapper ###
#--------------------------------------------------------------------
#' Wrapper for Report Engine: Dummy Model Summary Report
#'
#' Orchestrates the collection and structuring of reportelements into a model summary.
#'
#' @param control The control object.
#' @param workflow_results A named list of workflow results.
#' @param split_output Not used.
#' @param alias_report The report alias (e.g., "modelsummary").
#'
#' @return A standardized report structure.
#' @export
wrapper_report_modelsummary <- function(control, reportelements, alias_report = NULL) {
  if (is.null(alias_report)) stop("Report alias must be specified.")
  
  reportelements <- reportelements
  params <- control$params$report$params[[alias_report]]
  
  sections <- engine_report_modelsummary(
    reportelements = reportelements,
    params = params
  )
  
  initialize_output_report(
    report_title = "Modellzusammenfassung",
    report_type = "modelsummary",
    compatible_formats = c("pdf", "html", "json"),
    sections = sections,
    params = params
  )
}
#--------------------------------------------------------------------



#--------------------------------------------------------------------
### default params ###
#--------------------------------------------------------------------
#' Default Parameters for Report Engine: Dummy Model Summary
#'
#' No default aliases set – must be configured via control.
#'
#' @return An empty list.
#' @export
default_params_report_modelsummary <- function() {
  list()
}
#--------------------------------------------------------------------