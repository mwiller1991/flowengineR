#--------------------------------------------------------------------
### helper for reporting-engines ###
#--------------------------------------------------------------------
#' Helper Function: Initialize Output for Reporting Engines
#'
#' Creates standardized output for reporting engines. 
#' Ensures consistency across all reporting engines.
#'
#' **Standardized Output:**
#' - `report_object`: A data.frame, ggplot object, or list representing the report content.
#' - `report_type`: A string specifying the report engine type (e.g., "table_splitmetrics").
#' - `input_data`: The original input data used for reporting (e.g., workflow_results).
#' - `params`: Parameters used for the report (optional).
#' - `specific_output`: Optional engine-specific outputs (e.g., annotations, stats).
#'
#' @param report_object The output object of the reporting engine (e.g., table or plot).
#' @param report_type A string specifying the type of reporting engine used.
#' @param input_data The raw input data used to generate the report.
#' @param params Optional parameters used for the report.
#' @param specific_output Optional engine-specific outputs.
#'
#' @return A standardized list containing the output fields for the reporting engine.
#' @export
initialize_output_report <- function(report_object, report_type, input_data, params = NULL, specific_output = NULL) {
  # Base fields: Required for all reporting engines
  output <- list(
    report_object = report_object,
    report_type = report_type,
    input_data = input_data
  )
  
  # Optional fields
  if (!is.null(params)) {
    output$params <- params
  }
  if (!is.null(specific_output)) {
    output$specific_output <- specific_output
  }
  
  return(output)
}
#--------------------------------------------------------------------